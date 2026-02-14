import 'dart:math' as math;

import '../models/bean_detail.dart';
import '../models/brew_detail.dart';
import '../models/coffee_bean.dart';
import '../models/coffee_log.dart';
import '../models/community_post.dart';
import '../models/guest_dashboard_snapshot.dart';
import '../models/user_profile.dart';

class GuestSampleService {
  GuestSampleService()
    : _beans = _buildBeans(),
      _logs = _buildLogs(),
      _postDetails = _buildPostDetails() {
    _postDetailsById = {for (final post in _postDetails) post.id: post};
    _postSummaries = _postDetails
        .map(
          (post) => CommunityPost(
            id: post.id,
            userId: post.userId,
            title: post.title,
            content: post.content,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            author: post.author,
            commentCount: post.comments?.length ?? 0,
          ),
        )
        .toList(growable: false);
  }

  static const String guestUserId = 'guest-user';

  final List<CoffeeBean> _beans;
  final List<CoffeeLog> _logs;
  final List<CommunityPost> _postDetails;
  late final Map<String, CommunityPost> _postDetailsById;
  late final List<CommunityPost> _postSummaries;

  Future<List<CoffeeBean>> getBeans({
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    double? minRating,
    String? roastLevel,
    int? limit,
    int? offset,
  }) async {
    final normalized = _normalizeQuery(searchQuery);
    final filtered = _beans
        .where((bean) {
          final matchesQuery =
              normalized == null ||
              bean.name.toLowerCase().contains(normalized) ||
              bean.roastery.toLowerCase().contains(normalized) ||
              (bean.tastingNotes?.toLowerCase().contains(normalized) ?? false);
          final matchesRating = minRating == null || bean.rating >= minRating;
          final matchesRoast =
              roastLevel == null || bean.roastLevel == roastLevel;
          return matchesQuery && matchesRating && matchesRoast;
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final orderColumn = sortBy ?? 'created_at';
      final comparison = switch (orderColumn) {
        'name' => _compareText(a.name, b.name),
        'rating' => a.rating.compareTo(b.rating),
        'purchase_date' => a.purchaseDate.compareTo(b.purchaseDate),
        _ => a.createdAt.compareTo(b.createdAt),
      };
      return ascending ? comparison : -comparison;
    });

    return _applyPagination(filtered, limit: limit, offset: offset);
  }

  Future<CoffeeBean?> getBean(String id) async {
    return _firstWhereOrNull(_beans, (bean) => bean.id == id);
  }

  Future<List<CoffeeLog>> getLogs({
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    double? minRating,
    String? coffeeType,
    int? limit,
    int? offset,
  }) async {
    final normalized = _normalizeQuery(searchQuery);
    final filtered = _logs
        .where((log) {
          final matchesQuery =
              normalized == null ||
              (log.coffeeName?.toLowerCase().contains(normalized) ?? false) ||
              log.cafeName.toLowerCase().contains(normalized) ||
              (log.notes?.toLowerCase().contains(normalized) ?? false);
          final matchesRating = minRating == null || log.rating >= minRating;
          final matchesType =
              coffeeType == null || log.coffeeType == coffeeType;
          return matchesQuery && matchesRating && matchesType;
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final orderColumn = sortBy ?? 'cafe_visit_date';
      final comparison = switch (orderColumn) {
        'rating' => a.rating.compareTo(b.rating),
        'created_at' => a.createdAt.compareTo(b.createdAt),
        _ => a.cafeVisitDate.compareTo(b.cafeVisitDate),
      };
      return ascending ? comparison : -comparison;
    });

    return _applyPagination(filtered, limit: limit, offset: offset);
  }

  Future<CoffeeLog?> getLog(String id) async {
    return _firstWhereOrNull(_logs, (log) => log.id == id);
  }

  Future<List<CommunityPost>> getPosts({
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    final normalized = _normalizeQuery(searchQuery);
    final filtered = _postSummaries
        .where((post) {
          if (normalized == null) return true;
          return post.title.toLowerCase().contains(normalized) ||
              post.content.toLowerCase().contains(normalized);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final orderColumn = sortBy ?? 'created_at';
      final comparison = switch (orderColumn) {
        'title' => _compareText(a.title, b.title),
        _ => a.createdAt.compareTo(b.createdAt),
      };
      return ascending ? comparison : -comparison;
    });

    return _applyPagination(filtered, limit: limit, offset: offset);
  }

  Future<CommunityPost?> getPost(String id) async {
    return _postDetailsById[id];
  }

  Future<GuestDashboardSnapshot> getDashboardSnapshot() async {
    final coffeeTypeCount = <String, int>{};
    for (final log in _logs) {
      coffeeTypeCount[log.coffeeType] =
          (coffeeTypeCount[log.coffeeType] ?? 0) + 1;
    }

    final averageBeanRating = _beans.isEmpty
        ? 0.0
        : _beans.fold<double>(0.0, (sum, bean) => sum + bean.rating) /
              _beans.length;
    final averageLogRating = _logs.isEmpty
        ? 0.0
        : _logs.fold<double>(0.0, (sum, log) => sum + log.rating) /
              _logs.length;

    final recentBeans = await getBeans(
      sortBy: 'created_at',
      ascending: false,
      limit: 5,
    );
    final recentLogs = await getLogs(
      sortBy: 'created_at',
      ascending: false,
      limit: 5,
    );

    return GuestDashboardSnapshot(
      totalBeans: _beans.length,
      averageBeanRating: averageBeanRating,
      totalLogs: _logs.length,
      averageLogRating: averageLogRating,
      coffeeTypeCount: coffeeTypeCount,
      recentBeans: recentBeans,
      recentLogs: recentLogs,
      userProfile: _profiles.guest,
    );
  }

  List<T> _applyPagination<T>(
    List<T> items, {
    required int? limit,
    required int? offset,
  }) {
    final start = math.max(0, offset ?? 0);
    if (start >= items.length) return <T>[];
    final sanitizedLimit = limit == null ? null : math.max(0, limit);
    final end = sanitizedLimit == null
        ? items.length
        : math.min(items.length, start + sanitizedLimit);
    return items.sublist(start, end);
  }

  String? _normalizeQuery(String? searchQuery) {
    if (searchQuery == null) return null;
    final normalized = searchQuery.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }

  int _compareText(String a, String b) {
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  static List<CoffeeBean> _buildBeans() {
    final now = DateTime(2026, 2, 14, 9);
    return <CoffeeBean>[
      CoffeeBean(
        id: 'sample-bean-ethiopia-1',
        userId: guestUserId,
        name: '예가체프 G1',
        roastery: '샘플 로스터스',
        purchaseDate: DateTime(2026, 1, 22),
        rating: 4.6,
        tastingNotes: '꽃향, 자스민, 복숭아',
        roastLevel: '라이트',
        price: 19000,
        purchaseLocation: '온라인 스토어',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 18)),
        beanDetails: <BeanDetail>[
          BeanDetail(
            id: 'sample-bean-detail-1',
            coffeeBeanId: 'sample-bean-ethiopia-1',
            origin: '에티오피아',
            variety: 'Heirloom',
            process: '워시드',
            ratio: 100,
            createdAt: now.subtract(const Duration(days: 20)),
          ),
        ],
        brewDetails: <BrewDetail>[
          BrewDetail(
            id: 'sample-brew-detail-1',
            coffeeBeanId: 'sample-bean-ethiopia-1',
            brewDate: DateTime(2026, 2, 3),
            brewMethod: '핸드드립',
            grindSize: '중',
            brewTime: '2:45',
            waterTemperature: 92,
            pairedFood: '레몬 파운드 케이크',
            brewNotes: '클린컵이 좋고 단맛이 길게 남음.',
            createdAt: now.subtract(const Duration(days: 11)),
          ),
        ],
      ),
      CoffeeBean(
        id: 'sample-bean-colombia-1',
        userId: guestUserId,
        name: '콜롬비아 우일라',
        roastery: '하우스 커피랩',
        purchaseDate: DateTime(2026, 1, 30),
        rating: 4.3,
        tastingNotes: '카라멜, 오렌지, 밀크초콜릿',
        roastLevel: '미디엄',
        price: 17500,
        purchaseLocation: '성수 오프라인 매장',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 14)),
        beanDetails: <BeanDetail>[
          BeanDetail(
            id: 'sample-bean-detail-2',
            coffeeBeanId: 'sample-bean-colombia-1',
            origin: '콜롬비아',
            variety: 'Caturra',
            process: '허니',
            ratio: 100,
            createdAt: now.subtract(const Duration(days: 15)),
          ),
        ],
      ),
      CoffeeBean(
        id: 'sample-bean-kenya-1',
        userId: guestUserId,
        name: '케냐 AA',
        roastery: '모닝바스켓',
        purchaseDate: DateTime(2026, 2, 5),
        rating: 4.8,
        tastingNotes: '블랙커런트, 자몽, 브라운슈가',
        roastLevel: '미디엄 라이트',
        price: 22000,
        purchaseLocation: '정기 구독',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 7)),
        beanDetails: <BeanDetail>[
          BeanDetail(
            id: 'sample-bean-detail-3',
            coffeeBeanId: 'sample-bean-kenya-1',
            origin: '케냐',
            variety: 'SL28',
            process: '워시드',
            ratio: 100,
            createdAt: now.subtract(const Duration(days: 8)),
          ),
        ],
      ),
    ];
  }

  static List<CoffeeLog> _buildLogs() {
    final now = DateTime(2026, 2, 14, 9);
    return <CoffeeLog>[
      CoffeeLog(
        id: 'sample-log-1',
        userId: guestUserId,
        cafeVisitDate: DateTime(2026, 2, 12),
        coffeeType: '아메리카노',
        coffeeName: '싱글 오리진 아메리카노',
        cafeName: '브루 스테이션',
        rating: 4.5,
        notes: '산미가 선명하고 끝맛이 깨끗했다.',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      CoffeeLog(
        id: 'sample-log-2',
        userId: guestUserId,
        cafeVisitDate: DateTime(2026, 2, 8),
        coffeeType: '라떼',
        coffeeName: '오트 라떼',
        cafeName: '그레인 카페',
        rating: 4.2,
        notes: '바디감은 좋았지만 후반에 단맛이 살짝 과함.',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      CoffeeLog(
        id: 'sample-log-3',
        userId: guestUserId,
        cafeVisitDate: DateTime(2026, 2, 1),
        coffeeType: '콜드브루',
        coffeeName: '콜드브루 블렌드',
        cafeName: '딥바이브',
        rating: 4.7,
        notes: '초콜릿과 견과류 뉘앙스가 안정적이었다.',
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 13)),
        updatedAt: now.subtract(const Duration(days: 13)),
      ),
    ];
  }

  static List<CommunityPost> _buildPostDetails() {
    final now = DateTime(2026, 2, 14, 9);
    return <CommunityPost>[
      CommunityPost(
        id: 'sample-post-1',
        userId: _profiles.minji.id,
        title: '핸드드립 추출 시간은 어느 정도로 맞추시나요?',
        content: '원두마다 다르긴 한데 보통 2분 30초 전후로 맞추고 있습니다. 다들 어떤 기준으로 맞추는지 궁금해요.',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        author: _profiles.minji,
        comments: <CommunityComment>[
          CommunityComment(
            id: 'sample-comment-1',
            postId: 'sample-post-1',
            userId: _profiles.guest.id,
            content: '저는 15g 기준 2분 40초 정도로 맞추고 있어요!',
            createdAt: now.subtract(const Duration(days: 3, hours: 1)),
            updatedAt: now.subtract(const Duration(days: 3, hours: 1)),
            author: _profiles.guest,
          ),
          CommunityComment(
            id: 'sample-comment-2',
            postId: 'sample-post-1',
            userId: _profiles.juno.id,
            content: '분쇄도를 먼저 고정한 뒤 시간으로 미세 조정하는 편입니다.',
            createdAt: now.subtract(const Duration(days: 2, hours: 20)),
            updatedAt: now.subtract(const Duration(days: 2, hours: 20)),
            author: _profiles.juno,
          ),
        ],
      ),
      CommunityPost(
        id: 'sample-post-2',
        userId: _profiles.juno.id,
        title: '최근 마신 케냐 원두 추천 받아요',
        content: '블랙커런트 계열의 선명한 산미를 좋아합니다. 최근 인상 깊었던 케냐 원두 있으신가요?',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 6)),
        author: _profiles.juno,
        comments: <CommunityComment>[
          CommunityComment(
            id: 'sample-comment-3',
            postId: 'sample-post-2',
            userId: _profiles.minji.id,
            content: 'AA 등급 워시드 추천해요. 드립에서 향이 꽤 잘 올라옵니다.',
            createdAt: now.subtract(const Duration(days: 1, hours: 3)),
            updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
            author: _profiles.minji,
          ),
        ],
      ),
    ];
  }
}

class _SampleProfiles {
  final UserProfile guest = UserProfile(
    id: GuestSampleService.guestUserId,
    nickname: '게스트',
    email: 'guest@local.sample',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final UserProfile minji = UserProfile(
    id: 'sample-user-minji',
    nickname: '민지',
    email: 'minji@local.sample',
    createdAt: DateTime(2026, 1, 2),
    updatedAt: DateTime(2026, 1, 2),
  );

  final UserProfile juno = UserProfile(
    id: 'sample-user-juno',
    nickname: '주노',
    email: 'juno@local.sample',
    createdAt: DateTime(2026, 1, 3),
    updatedAt: DateTime(2026, 1, 3),
  );
}

final _profiles = _SampleProfiles();
