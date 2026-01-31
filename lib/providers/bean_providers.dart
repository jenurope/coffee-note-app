import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coffee_bean.dart';
import '../services/coffee_bean_service.dart';
import 'auth_provider.dart';

import '../config/supabase_config.dart';

// Service Provider
final coffeeBeanServiceProvider =
    Provider<CoffeeBeanService>((ref) => CoffeeBeanService(SupabaseConfig.client));

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

// Filter 클래스
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
