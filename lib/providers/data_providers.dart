import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coffee_bean.dart';
import '../models/coffee_log.dart';
import '../models/community_post.dart';
import '../services/coffee_bean_service.dart';
import '../services/coffee_log_service.dart';
import '../services/community_service.dart';
import '../services/image_upload_service.dart';
import 'auth_provider.dart';

// Service Providers
final coffeeBeanServiceProvider =
    Provider<CoffeeBeanService>((ref) => CoffeeBeanService());

final coffeeLogServiceProvider =
    Provider<CoffeeLogService>((ref) => CoffeeLogService());

final communityServiceProvider =
    Provider<CommunityService>((ref) => CommunityService());

final imageUploadServiceProvider =
    Provider<ImageUploadService>((ref) => ImageUploadService());

// 원두 목록 Provider
final beansProvider = FutureProvider.family<List<CoffeeBean>, BeanFilters>(
  (ref, filters) async {
    final service = ref.watch(coffeeBeanServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    return await service.getBeans(
      userId: filters.onlyMine ? currentUser?.id : null,
      searchQuery: filters.searchQuery,
      sortBy: filters.sortBy,
      ascending: filters.ascending,
      minRating: filters.minRating,
      roastLevel: filters.roastLevel,
      limit: filters.limit,
      offset: filters.offset,
    );
  },
);

// 원두 상세 Provider
final beanDetailProvider = FutureProvider.family<CoffeeBean?, String>(
  (ref, id) async {
    final service = ref.watch(coffeeBeanServiceProvider);
    return await service.getBean(id);
  },
);

// 커피 로그 목록 Provider
final coffeeLogsProvider = FutureProvider.family<List<CoffeeLog>, LogFilters>(
  (ref, filters) async {
    final service = ref.watch(coffeeLogServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    return await service.getLogs(
      userId: filters.onlyMine ? currentUser?.id : null,
      searchQuery: filters.searchQuery,
      sortBy: filters.sortBy,
      ascending: filters.ascending,
      minRating: filters.minRating,
      coffeeType: filters.coffeeType,
      limit: filters.limit,
      offset: filters.offset,
    );
  },
);

// 커피 로그 상세 Provider
final coffeeLogDetailProvider = FutureProvider.family<CoffeeLog?, String>(
  (ref, id) async {
    final service = ref.watch(coffeeLogServiceProvider);
    return await service.getLog(id);
  },
);

// 커뮤니티 게시글 목록 Provider
final communityPostsProvider =
    FutureProvider.family<List<CommunityPost>, PostFilters>(
  (ref, filters) async {
    final service = ref.watch(communityServiceProvider);
    return await service.getPosts(
      searchQuery: filters.searchQuery,
      sortBy: filters.sortBy,
      ascending: filters.ascending,
      limit: filters.limit,
      offset: filters.offset,
    );
  },
);

// 커뮤니티 게시글 상세 Provider
final communityPostDetailProvider =
    FutureProvider.family<CommunityPost?, String>(
  (ref, id) async {
    final service = ref.watch(communityServiceProvider);
    return await service.getPost(id);
  },
);

// 대시보드 통계 Provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return DashboardStats.empty();
  }

  final beanService = ref.watch(coffeeBeanServiceProvider);
  final logService = ref.watch(coffeeLogServiceProvider);

  final beanStats = await beanService.getUserBeanStats(currentUser.id);
  final logStats = await logService.getUserLogStats(currentUser.id);

  return DashboardStats(
    totalBeans: beanStats['totalCount'] as int,
    averageBeanRating: beanStats['averageRating'] as double,
    totalLogs: logStats['totalCount'] as int,
    averageLogRating: logStats['averageRating'] as double,
    coffeeTypeCount: logStats['typeCount'] as Map<String, int>,
  );
});

// 최근 원두 Provider
final recentBeansProvider = FutureProvider<List<CoffeeBean>>((ref) async {
  final service = ref.watch(coffeeBeanServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return await service.getBeans(
    userId: currentUser?.id,
    sortBy: 'created_at',
    ascending: false,
    limit: 5,
  );
});

// 최근 커피 로그 Provider
final recentLogsProvider = FutureProvider<List<CoffeeLog>>((ref) async {
  final service = ref.watch(coffeeLogServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return await service.getLogs(
    userId: currentUser?.id,
    sortBy: 'created_at',
    ascending: false,
    limit: 5,
  );
});

// Filter 클래스들
class BeanFilters {
  final bool onlyMine;
  final String? searchQuery;
  final String? sortBy;
  final bool ascending;
  final double? minRating;
  final String? roastLevel;
  final int? limit;
  final int? offset;

  const BeanFilters({
    this.onlyMine = true,
    this.searchQuery,
    this.sortBy,
    this.ascending = false,
    this.minRating,
    this.roastLevel,
    this.limit,
    this.offset,
  });

  BeanFilters copyWith({
    bool? onlyMine,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
    double? minRating,
    String? roastLevel,
    int? limit,
    int? offset,
  }) {
    return BeanFilters(
      onlyMine: onlyMine ?? this.onlyMine,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      minRating: minRating ?? this.minRating,
      roastLevel: roastLevel ?? this.roastLevel,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeanFilters &&
        other.onlyMine == onlyMine &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy &&
        other.ascending == ascending &&
        other.minRating == minRating &&
        other.roastLevel == roastLevel &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
        onlyMine,
        searchQuery,
        sortBy,
        ascending,
        minRating,
        roastLevel,
        limit,
        offset,
      );
}

class LogFilters {
  final bool onlyMine;
  final String? searchQuery;
  final String? sortBy;
  final bool ascending;
  final double? minRating;
  final String? coffeeType;
  final int? limit;
  final int? offset;

  const LogFilters({
    this.onlyMine = true,
    this.searchQuery,
    this.sortBy,
    this.ascending = false,
    this.minRating,
    this.coffeeType,
    this.limit,
    this.offset,
  });

  LogFilters copyWith({
    bool? onlyMine,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
    double? minRating,
    String? coffeeType,
    int? limit,
    int? offset,
  }) {
    return LogFilters(
      onlyMine: onlyMine ?? this.onlyMine,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      minRating: minRating ?? this.minRating,
      coffeeType: coffeeType ?? this.coffeeType,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogFilters &&
        other.onlyMine == onlyMine &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy &&
        other.ascending == ascending &&
        other.minRating == minRating &&
        other.coffeeType == coffeeType &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
        onlyMine,
        searchQuery,
        sortBy,
        ascending,
        minRating,
        coffeeType,
        limit,
        offset,
      );
}

class PostFilters {
  final String? searchQuery;
  final String? sortBy;
  final bool ascending;
  final int? limit;
  final int? offset;

  const PostFilters({
    this.searchQuery,
    this.sortBy,
    this.ascending = false,
    this.limit,
    this.offset,
  });

  PostFilters copyWith({
    String? searchQuery,
    String? sortBy,
    bool? ascending,
    int? limit,
    int? offset,
  }) {
    return PostFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostFilters &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy &&
        other.ascending == ascending &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        sortBy,
        ascending,
        limit,
        offset,
      );
}

class DashboardStats {
  final int totalBeans;
  final double averageBeanRating;
  final int totalLogs;
  final double averageLogRating;
  final Map<String, int> coffeeTypeCount;

  DashboardStats({
    required this.totalBeans,
    required this.averageBeanRating,
    required this.totalLogs,
    required this.averageLogRating,
    required this.coffeeTypeCount,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalBeans: 0,
      averageBeanRating: 0,
      totalLogs: 0,
      averageLogRating: 0,
      coffeeTypeCount: {},
    );
  }
}
