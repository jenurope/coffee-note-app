import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/terms/term_policy.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _client;
  late final GoTrueClient _auth;
  bool _skipGetClaimsValidation = false;
  static const List<String> _withdrawStorageBuckets = <String>[
    'beans',
    'logs',
    'avatars',
    'community',
  ];

  // iOS 클라이언트 ID
  static const String _iosClientId =
      '8081750780-m14ad4segdpjfcdve6tk62489eqqkd6u.apps.googleusercontent.com';
  // Web 클라이언트 ID (Supabase용)
  static const String _webClientId =
      '8081750780-scf0av9f4beqnb2in0p2sshqava1us8h.apps.googleusercontent.com';

  AuthService(this._client) {
    _auth = _client.auth;
  }

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 로그인 상태 스트림
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // 앱 시작 시 로컬 세션을 클레임 기반으로 검증
  Future<User?> getValidatedCurrentUser() async {
    final localUser = _auth.currentUser;
    if (localUser == null) return null;

    if (_skipGetClaimsValidation) {
      return _validateCurrentUserViaGetUser(localUser);
    }

    try {
      final claimsResponse = await _auth.getClaims();
      final claimsSub = claimsResponse.claims.sub;

      if (claimsSub == null || claimsSub.isEmpty) {
        debugPrint('Validate current user failed: claims.sub is empty');
        await _clearLocalSession();
        return null;
      }

      if (claimsSub != localUser.id) {
        debugPrint(
          'Validate current user failed: claims.sub mismatch '
          '(claims: $claimsSub, local: ${localUser.id})',
        );
        await _clearLocalSession();
        return null;
      }

      final algorithm = claimsResponse.header.alg;
      final kid = claimsResponse.header.kid;
      final likelyServerFallback = algorithm.startsWith('HS') || kid == null;

      if (likelyServerFallback) {
        debugPrint(
          'Validate current user via getClaims fallback(server): '
          'alg=$algorithm, kid=$kid',
        );
      } else {
        debugPrint(
          'Validate current user via getClaims local verification success: '
          'alg=$algorithm, kid=$kid',
        );
      }

      return localUser;
    } on AuthException catch (e) {
      if (_shouldForceSignOutForValidationError(e.message)) {
        debugPrint(
          'Validate current user via getClaims failed and session cleared: '
          '${e.message}',
        );
        await _clearLocalSession();
        return null;
      }

      // 네트워크 등 일시 오류 시에는 로컬 세션을 유지
      debugPrint(
        'Validate current user via getClaims skipped (transient): ${e.message}',
      );
      return localUser;
    } catch (e) {
      if (_isGetClaimsJwksCacheBug(e)) {
        _skipGetClaimsValidation = true;
        debugPrint(
          'Validate current user via getClaims disabled and fallback(getUser)',
        );
        return _validateCurrentUserViaGetUser(localUser);
      }
      debugPrint('Validate current user via getClaims unexpected error: $e');
      return localUser;
    }
  }

  // 구글 로그인
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: _iosClientId,
        serverClientId: _webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다.');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
      }

      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 프로필이 없으면 생성
      if (response.user != null) {
        await _ensureProfileExists(response.user!);
      }

      return response;
    } catch (e) {
      debugPrint('SignInWithGoogle error: $e');
      rethrow;
    }
  }

  // 프로필 존재 확인 및 생성
  Future<void> _ensureProfileExists(User user) async {
    try {
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        // 프로필이 없으면 생성
        final email = user.email ?? '';
        final nickname =
            user.userMetadata?['name'] ??
            user.userMetadata?['full_name'] ??
            email.split('@').first;

        await _client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'nickname': nickname,
        });
      }
    } catch (e) {
      debugPrint('Ensure profile exists error: $e');
      // 프로필 생성 실패해도 로그인은 성공으로 처리
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // local scope는 로컬 세션을 즉시 제거하고, accessToken이 있으면 서버 로그아웃도 시도한다.
      await _auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SignOut remote sync skipped: $e');
      }
    }
  }

  @visibleForTesting
  Future<void> invokeWithdrawRpc() async {
    await _client.rpc('withdraw_my_account');
  }

  // 회원 탈퇴
  Future<void> withdrawAccount() async {
    try {
      final userId = _auth.currentUser?.id;
      if (userId != null && userId.isNotEmpty) {
        try {
          await cleanupWithdrawStorageBestEffort(userId);
        } catch (e) {
          debugPrint('Withdraw storage cleanup unexpected error: $e');
        }
      }
      await invokeWithdrawRpc();
      await _clearLocalSession();
    } catch (e) {
      debugPrint('Withdraw account error: $e');
      rethrow;
    }
  }

  // 사용자 프로필 가져오기
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select(
            'id, nickname, email, avatar_url, is_withdrawn, created_at, updated_at',
          )
          .eq('id', userId)
          .maybeSingle();

      return response == null ? null : UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Get profile error: $e');
      return null;
    }
  }

  // 프로필 업데이트
  Future<void> updateProfile({
    required String userId,
    required String nickname,
    required String? avatarUrl,
  }) async {
    try {
      final normalizedNickname = nickname.trim();
      final now = DateTime.now().toIso8601String();
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await _client.from('profiles').insert({
          'id': userId,
          'email': _auth.currentUser?.email ?? '',
          'nickname': normalizedNickname,
          'avatar_url': avatarUrl,
          'updated_at': now,
        });
        return;
      }

      final updates = <String, dynamic>{
        'nickname': normalizedNickname,
        'avatar_url': avatarUrl,
        'updated_at': now,
      };

      await _client.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<bool> hasPendingRequiredTerms(String userId) async {
    final requiredTerms = await fetchActiveRequiredTermVersions();
    if (requiredTerms.isEmpty) {
      return false;
    }

    final agreedRows = await fetchUserAgreedTermsConsents(userId);
    final agreedVersionByCode = <String, int>{};
    for (final row in agreedRows) {
      final termCode = row['term_code']?.toString();
      final version = row['version'];
      if (termCode == null || termCode.isEmpty || version is! int) {
        continue;
      }
      final previous = agreedVersionByCode[termCode] ?? 0;
      if (version > previous) {
        agreedVersionByCode[termCode] = version;
      }
    }

    for (final requiredTerm in requiredTerms) {
      final code = requiredTerm['code']?.toString();
      final currentVersion = requiredTerm['current_version'];
      if (code == null || code.isEmpty || currentVersion is! int) {
        throw StateError('invalid_required_term_row');
      }
      final agreedVersion = agreedVersionByCode[code] ?? 0;
      if (agreedVersion < currentVersion) {
        return true;
      }
    }

    return false;
  }

  Future<List<TermPolicy>> fetchActiveTerms({
    required String localeCode,
    String? userId,
  }) async {
    final activeTermsRows = await fetchActiveTermsWithContents();
    Set<String>? pendingTermCodes;
    if (userId != null && userId.isNotEmpty) {
      final userConsents = await fetchUserTermsConsents(userId);
      pendingTermCodes = _resolvePendingTermCodes(
        activeTermsRows: activeTermsRows,
        userConsentRows: userConsents,
      );
    }
    final normalizedLocale = _normalizeLocaleCode(localeCode);
    final terms = <TermPolicy>[];

    for (final row in activeTermsRows) {
      final code = row['code']?.toString();
      final isRequired = row['is_required'];
      final version = row['current_version'];
      final sortOrder = row['sort_order'];
      final contents = row['terms_contents'];

      if (code == null ||
          code.isEmpty ||
          isRequired is! bool ||
          version is! int ||
          sortOrder is! int ||
          contents is! List) {
        throw StateError('invalid_active_term_row');
      }
      if (pendingTermCodes != null && !pendingTermCodes.contains(code)) {
        continue;
      }

      final contentRows = contents.whereType<Map<String, dynamic>>().toList(
        growable: false,
      );

      Map<String, dynamic>? selectedContent = _findTermContent(
        contentRows: contentRows,
        locale: normalizedLocale,
        version: version,
      );
      selectedContent ??= _findTermContent(
        contentRows: contentRows,
        locale: 'ko',
        version: version,
      );
      selectedContent ??= contentRows.firstWhere(
        (contentRow) => contentRow['version'] == version,
        orElse: () => <String, dynamic>{},
      );

      final title = selectedContent['title']?.toString();
      final content = selectedContent['content']?.toString();
      if (title == null ||
          title.isEmpty ||
          content == null ||
          content.isEmpty) {
        throw StateError('missing_term_content:$code:$version');
      }

      terms.add(
        TermPolicy(
          code: code,
          title: title,
          content: content,
          version: version,
          isRequired: isRequired,
          sortOrder: sortOrder,
        ),
      );
    }

    terms.sort((a, b) {
      if (a.isRequired != b.isRequired) {
        return a.isRequired ? -1 : 1;
      }
      final sortOrderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortOrderCompare != 0) {
        return sortOrderCompare;
      }
      return a.code.compareTo(b.code);
    });

    return terms;
  }

  Future<void> saveTermsConsents({
    required String userId,
    required Map<String, bool> decisions,
  }) async {
    final activeTermsRows = await fetchActiveTermsMeta();
    if (activeTermsRows.isEmpty) {
      return;
    }

    final userConsents = await fetchUserTermsConsents(userId);
    final pendingTermCodes = _resolvePendingTermCodes(
      activeTermsRows: activeTermsRows,
      userConsentRows: userConsents,
    );
    if (pendingTermCodes.isEmpty) {
      return;
    }

    final pendingRows = <Map<String, dynamic>>[];
    for (final row in activeTermsRows) {
      final code = row['code']?.toString();
      final isRequired = row['is_required'];
      if (code == null || code.isEmpty || isRequired is! bool) {
        throw StateError('invalid_active_term_meta_row');
      }
      if (!pendingTermCodes.contains(code)) {
        continue;
      }
      if (isRequired && decisions[code] != true) {
        throw Exception('required_terms_not_agreed');
      }
      pendingRows.add(row);
    }

    final nowIso = DateTime.now().toIso8601String();
    final upsertRows = pendingRows
        .map((row) {
          final code = row['code']?.toString();
          final version = row['current_version'];
          if (code == null || code.isEmpty || version is! int) {
            throw StateError('invalid_active_term_meta_row');
          }
          final agreed = decisions[code] == true;
          return <String, dynamic>{
            'user_id': userId,
            'term_code': code,
            'version': version,
            'agreed': agreed,
            'agreed_at': agreed ? nowIso : null,
            'updated_at': nowIso,
          };
        })
        .toList(growable: false);

    await upsertUserTermsConsents(upsertRows);
  }

  // 로그인 에러 메시지 한글 변환
  String getSignInErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('cancel')) {
      return 'errGoogleLoginCanceled';
    }
    if (message.contains('token')) {
      return 'errGoogleTokenUnavailable';
    }
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout')) {
      return 'errNetwork';
    }

    return 'errLoginFailed';
  }

  String getTermsErrorMessage(
    dynamic error, {
    String fallback = 'errTermsConsentFailed',
  }) {
    final message = error.toString().toLowerCase();
    if (message.contains('required_terms_not_agreed')) {
      return 'errTermsRequiredNotAgreed';
    }
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout')) {
      return 'errNetwork';
    }
    if (message.contains('permission') ||
        message.contains('forbidden') ||
        message.contains('rls')) {
      return 'errPermissionDenied';
    }
    return fallback;
  }

  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchActiveRequiredTermVersions() async {
    final rows = await _client
        .from('terms_catalog')
        .select('code,current_version')
        .eq('is_active', true)
        .eq('is_required', true)
        .order('sort_order', ascending: true)
        .order('code', ascending: true);
    return rows
        .map<Map<String, dynamic>>(
          (row) => Map<String, dynamic>.from(row as Map),
        )
        .toList(growable: false);
  }

  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchUserAgreedTermsConsents(
    String userId,
  ) async {
    final rows = await _client
        .from('user_terms_consents')
        .select('term_code,version,agreed')
        .eq('user_id', userId)
        .eq('agreed', true);
    return rows
        .map<Map<String, dynamic>>(
          (row) => Map<String, dynamic>.from(row as Map),
        )
        .toList(growable: false);
  }

  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchUserTermsConsents(
    String userId,
  ) async {
    final rows = await _client
        .from('user_terms_consents')
        .select('term_code,version,agreed')
        .eq('user_id', userId);
    return rows
        .map<Map<String, dynamic>>(
          (row) => Map<String, dynamic>.from(row as Map),
        )
        .toList(growable: false);
  }

  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchActiveTermsMeta() async {
    final rows = await _client
        .from('terms_catalog')
        .select('code,is_required,current_version,sort_order')
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('code', ascending: true);
    return rows
        .map<Map<String, dynamic>>(
          (row) => Map<String, dynamic>.from(row as Map),
        )
        .toList(growable: false);
  }

  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchActiveTermsWithContents() async {
    final rows = await _client
        .from('terms_catalog')
        .select(
          'code,is_required,current_version,sort_order,terms_contents(locale,version,title,content)',
        )
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('code', ascending: true);
    return rows
        .map<Map<String, dynamic>>(
          (row) => Map<String, dynamic>.from(row as Map),
        )
        .toList(growable: false);
  }

  @visibleForTesting
  Future<void> upsertUserTermsConsents(List<Map<String, dynamic>> rows) async {
    await _client
        .from('user_terms_consents')
        .upsert(rows, onConflict: 'user_id,term_code,version');
  }

  String _normalizeLocaleCode(String localeCode) {
    final normalized = localeCode.toLowerCase();
    if (normalized.startsWith('ko')) return 'ko';
    if (normalized.startsWith('ja')) return 'ja';
    return 'en';
  }

  Map<String, dynamic>? _findTermContent({
    required List<Map<String, dynamic>> contentRows,
    required String locale,
    required int version,
  }) {
    for (final row in contentRows) {
      if (row['locale'] == locale && row['version'] == version) {
        return row;
      }
    }
    return null;
  }

  Set<String> _resolvePendingTermCodes({
    required List<Map<String, dynamic>> activeTermsRows,
    required List<Map<String, dynamic>> userConsentRows,
  }) {
    final currentVersionByCode = <String, int>{};
    final isRequiredByCode = <String, bool>{};

    for (final row in activeTermsRows) {
      final code = row['code']?.toString();
      final currentVersion = row['current_version'];
      final isRequired = row['is_required'];
      if (code == null ||
          code.isEmpty ||
          currentVersion is! int ||
          isRequired is! bool) {
        throw StateError('invalid_active_term_meta_row');
      }
      currentVersionByCode[code] = currentVersion;
      isRequiredByCode[code] = isRequired;
    }

    final currentConsentByCode = <String, bool>{};
    for (final row in userConsentRows) {
      final code = row['term_code']?.toString();
      final version = row['version'];
      final agreed = row['agreed'];
      if (code == null || code.isEmpty || version is! int || agreed is! bool) {
        continue;
      }

      final currentVersion = currentVersionByCode[code];
      if (currentVersion == null || version != currentVersion) {
        continue;
      }
      currentConsentByCode[code] = agreed;
    }

    final pendingCodes = <String>{};
    for (final entry in isRequiredByCode.entries) {
      final code = entry.key;
      final agreed = currentConsentByCode[code];
      if (agreed != true) {
        pendingCodes.add(code);
      }
    }
    return pendingCodes;
  }

  Future<void> _clearLocalSession() async {
    try {
      await _auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Clear local session error: $e');
      }
    }
  }

  bool _shouldForceSignOutForValidationError(String message) {
    final normalized = message.toLowerCase();
    const patterns = <String>[
      'user not found',
      'does not exist',
      'invalid claim',
      'invalid jwt',
      'jwt expired',
      'token expired',
      'invalid signature',
      'invalid refresh token',
      'refresh token not found',
      'session not found',
      'auth session missing',
    ];
    return patterns.any(normalized.contains);
  }

  bool _isGetClaimsJwksCacheBug(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('null check operator used on a null value');
  }

  @visibleForTesting
  Future<void> cleanupWithdrawStorageBestEffort(String userId) async {
    final objectPrefix = '$userId/';
    for (final bucket in _withdrawStorageBuckets) {
      try {
        await _removeStorageObjectsByPrefix(bucket: bucket, userId: userId);
      } catch (e) {
        debugPrint('Withdraw storage cleanup failed ($bucket): $e');
        await _recordWithdrawStorageCleanupFailure(
          bucket: bucket,
          objectPrefix: objectPrefix,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> _removeStorageObjectsByPrefix({
    required String bucket,
    required String userId,
  }) async {
    final storage = _client.storage.from(bucket);

    for (var i = 0; i < 100; i++) {
      final objects = await storage.list(
        path: userId,
        searchOptions: const SearchOptions(limit: 100, offset: 0),
      );

      if (objects.isEmpty) {
        return;
      }

      final paths = objects
          .where((object) => object.metadata != null)
          .map(
            (object) => _toStoragePath(userId: userId, objectName: object.name),
          )
          .where((path) => path.isNotEmpty)
          .toList(growable: false);

      if (paths.isEmpty) {
        return;
      }

      await storage.remove(paths);
    }

    throw Exception('storage cleanup exceeded max iterations');
  }

  String _toStoragePath({required String userId, required String objectName}) {
    final normalizedName = objectName.trim();
    if (normalizedName.isEmpty) return '';
    if (normalizedName.startsWith('$userId/')) return normalizedName;
    if (normalizedName.startsWith('/')) return '$userId$normalizedName';
    return '$userId/$normalizedName';
  }

  Future<void> _recordWithdrawStorageCleanupFailure({
    required String bucket,
    required String objectPrefix,
    required String errorMessage,
  }) async {
    try {
      await _client.rpc(
        'log_withdraw_storage_cleanup_failure',
        params: {
          'p_bucket': bucket,
          'p_object_prefix': objectPrefix,
          'p_error_message': errorMessage,
        },
      );
    } catch (e) {
      debugPrint('Record withdraw storage cleanup failure error: $e');
    }
  }

  Future<User?> _validateCurrentUserViaGetUser(User localUser) async {
    try {
      final response = await _auth.getUser();
      final serverUserId = response.user?.id;

      if (serverUserId == null || serverUserId.isEmpty) {
        debugPrint('Validate current user via getUser failed: user is empty');
        await _clearLocalSession();
        return null;
      }

      if (serverUserId != localUser.id) {
        debugPrint(
          'Validate current user via getUser failed: id mismatch '
          '(server: $serverUserId, local: ${localUser.id})',
        );
        await _clearLocalSession();
        return null;
      }

      debugPrint(
        'Validate current user via getUser success: userId=$serverUserId',
      );
      return localUser;
    } on AuthException catch (e) {
      if (_shouldForceSignOutForValidationError(e.message)) {
        debugPrint(
          'Validate current user via getUser failed and session cleared: '
          '${e.message}',
        );
        await _clearLocalSession();
        return null;
      }

      debugPrint(
        'Validate current user via getUser skipped (transient): ${e.message}',
      );
      return localUser;
    } catch (e) {
      debugPrint('Validate current user via getUser unexpected error: $e');
      return localUser;
    }
  }
}
