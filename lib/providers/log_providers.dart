import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coffee_log.dart';
import '../services/coffee_log_service.dart';
import 'auth_provider.dart';

import '../config/supabase_config.dart';

// Service Provider
final coffeeLogServiceProvider =
    Provider<CoffeeLogService>((ref) => CoffeeLogService(SupabaseConfig.client));

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

// Filter 클래스
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
