import 'package:freezed_annotation/freezed_annotation.dart';

part 'bean_filters.freezed.dart';

@freezed
sealed class BeanFilters with _$BeanFilters {
  const factory BeanFilters({
    @Default(true) bool onlyMine,
    String? searchQuery,
    String? sortBy,
    @Default(false) bool ascending,
    double? minRating,
    String? roastLevel,
    int? limit,
    int? offset,
  }) = _BeanFilters;
}
