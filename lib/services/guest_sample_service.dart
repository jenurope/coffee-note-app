import 'dart:math' as math;
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:coffee_note_app/l10n/app_localizations.dart';

import '../domain/catalogs/brew_method_catalog.dart';
import '../domain/catalogs/coffee_type_catalog.dart';
import '../domain/catalogs/grind_size_catalog.dart';
import '../domain/catalogs/roast_level_catalog.dart';
import '../models/bean_detail.dart';
import '../models/brew_detail.dart';
import '../models/coffee_bean.dart';
import '../models/coffee_log.dart';
import '../models/guest_dashboard_snapshot.dart';
import '../models/user_profile.dart';

class GuestSampleService {
  GuestSampleService({String? languageCode})
    : _l10nFuture = AppLocalizations.delegate.load(
        Locale(_resolveLanguageCode(languageCode)),
      );

  static const String guestUserId = 'guest-user';

  final Future<AppLocalizations> _l10nFuture;
  List<CoffeeBean>? _beans;
  List<CoffeeLog>? _logs;

  Future<List<CoffeeBean>> getBeans({
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    double? minRating,
    String? roastLevel,
    int? limit,
    int? offset,
  }) async {
    await _ensureInitialized();
    final beans = _beans!;

    final normalized = _normalizeQuery(searchQuery);
    final filtered = beans
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
    await _ensureInitialized();
    return _firstWhereOrNull(_beans!, (bean) => bean.id == id);
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
    await _ensureInitialized();
    final logs = _logs!;

    final normalized = _normalizeQuery(searchQuery);
    final filtered = logs
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
    await _ensureInitialized();
    return _firstWhereOrNull(_logs!, (log) => log.id == id);
  }

  Future<GuestDashboardSnapshot> getDashboardSnapshot() async {
    await _ensureInitialized();
    final beans = _beans!;
    final logs = _logs!;
    final l10n = await _l10nFuture;

    final coffeeTypeCount = <String, int>{};
    for (final log in logs) {
      coffeeTypeCount[log.coffeeType] =
          (coffeeTypeCount[log.coffeeType] ?? 0) + 1;
    }

    final averageBeanRating = beans.isEmpty
        ? 0.0
        : beans.fold<double>(0.0, (sum, bean) => sum + bean.rating) /
              beans.length;
    final averageLogRating = logs.isEmpty
        ? 0.0
        : logs.fold<double>(0.0, (sum, log) => sum + log.rating) / logs.length;

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
      totalBeans: beans.length,
      averageBeanRating: averageBeanRating,
      totalLogs: logs.length,
      averageLogRating: averageLogRating,
      coffeeTypeCount: coffeeTypeCount,
      recentBeans: recentBeans,
      recentLogs: recentLogs,
      userProfile: UserProfile(
        id: guestUserId,
        nickname: l10n.guestNickname,
        email: 'guest@local.sample',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  }

  Future<void> _ensureInitialized() async {
    if (_beans != null && _logs != null) {
      return;
    }

    final l10n = await _l10nFuture;
    _beans = _buildBeans(l10n);
    _logs = _buildLogs(l10n);
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

  List<CoffeeBean> _buildBeans(AppLocalizations l10n) {
    final now = DateTime(2026, 2, 14, 9);
    return <CoffeeBean>[
      CoffeeBean(
        id: 'sample-bean-ethiopia-1',
        userId: guestUserId,
        name: l10n.sampleBeanName1,
        roastery: l10n.sampleRoasteryA,
        purchaseDate: DateTime(2026, 1, 22),
        rating: 4.6,
        tastingNotes: l10n.sampleBeanNote1,
        roastLevel: RoastLevelCatalog.light,
        price: 19000,
        purchaseLocation: l10n.sampleStoreOnline,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 18)),
        beanDetails: <BeanDetail>[
          BeanDetail(
            id: 'sample-bean-detail-1',
            coffeeBeanId: 'sample-bean-ethiopia-1',
            origin: l10n.sampleOriginEthiopia,
            variety: 'Heirloom',
            process: l10n.sampleProcessWashed,
            ratio: 100,
            createdAt: now.subtract(const Duration(days: 20)),
          ),
        ],
        brewDetails: <BrewDetail>[
          BrewDetail(
            id: 'sample-brew-detail-1',
            coffeeBeanId: 'sample-bean-ethiopia-1',
            brewDate: DateTime(2026, 2, 3),
            brewMethod: BrewMethodCatalog.pourOver,
            grindSize: GrindSizeCatalog.medium,
            brewTime: '2:45',
            waterTemperature: 92,
            pairedFood: l10n.sampleFood1,
            brewNotes: l10n.sampleBrewNote1,
            createdAt: now.subtract(const Duration(days: 11)),
          ),
        ],
      ),
      CoffeeBean(
        id: 'sample-bean-colombia-1',
        userId: guestUserId,
        name: l10n.sampleBeanName2,
        roastery: l10n.sampleRoasteryB,
        purchaseDate: DateTime(2026, 1, 30),
        rating: 4.3,
        tastingNotes: l10n.sampleBeanNote2,
        roastLevel: RoastLevelCatalog.medium,
        price: 17500,
        purchaseLocation: l10n.sampleStoreOffline,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 14)),
        beanDetails: <BeanDetail>[
          BeanDetail(
            id: 'sample-bean-detail-2',
            coffeeBeanId: 'sample-bean-colombia-1',
            origin: l10n.sampleOriginColombia,
            variety: 'Caturra',
            process: l10n.sampleProcessHoney,
            ratio: 100,
            createdAt: now.subtract(const Duration(days: 15)),
          ),
        ],
      ),
      CoffeeBean(
        id: 'sample-bean-kenya-1',
        userId: guestUserId,
        name: l10n.sampleBeanName3,
        roastery: l10n.sampleRoasteryA,
        purchaseDate: DateTime(2026, 2, 5),
        rating: 4.8,
        tastingNotes: l10n.sampleBeanNote3,
        roastLevel: RoastLevelCatalog.mediumLight,
        price: 22000,
        purchaseLocation: l10n.sampleStoreSubscription,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 7)),
        beanDetails: <BeanDetail>[
          BeanDetail(
            id: 'sample-bean-detail-3',
            coffeeBeanId: 'sample-bean-kenya-1',
            origin: l10n.sampleOriginKenya,
            variety: 'SL28',
            process: l10n.sampleProcessWashed,
            ratio: 100,
            createdAt: now.subtract(const Duration(days: 8)),
          ),
        ],
      ),
    ];
  }

  List<CoffeeLog> _buildLogs(AppLocalizations l10n) {
    final now = DateTime(2026, 2, 14, 9);
    return <CoffeeLog>[
      CoffeeLog(
        id: 'sample-log-1',
        userId: guestUserId,
        cafeVisitDate: DateTime(2026, 2, 12),
        coffeeType: CoffeeTypeCatalog.americano,
        coffeeName: l10n.sampleCoffeeName1,
        cafeName: l10n.sampleCafe,
        rating: 4.5,
        notes: l10n.sampleLogNote1,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      CoffeeLog(
        id: 'sample-log-2',
        userId: guestUserId,
        cafeVisitDate: DateTime(2026, 2, 8),
        coffeeType: CoffeeTypeCatalog.latte,
        coffeeName: l10n.sampleCoffeeName2,
        cafeName: l10n.sampleCafe,
        rating: 4.2,
        notes: l10n.sampleLogNote2,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      CoffeeLog(
        id: 'sample-log-3',
        userId: guestUserId,
        cafeVisitDate: DateTime(2026, 2, 1),
        coffeeType: CoffeeTypeCatalog.coldBrew,
        coffeeName: l10n.sampleCoffeeName3,
        cafeName: l10n.sampleCafe,
        rating: 4.7,
        notes: l10n.sampleLogNote3,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 13)),
        updatedAt: now.subtract(const Duration(days: 13)),
      ),
    ];
  }

  static String _resolveLanguageCode(String? languageCode) {
    final code =
        (languageCode ?? PlatformDispatcher.instance.locale.languageCode)
            .toLowerCase();
    if (code == 'ko' || code == 'ja') {
      return code;
    }
    return 'en';
  }
}
