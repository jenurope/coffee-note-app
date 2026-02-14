import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_filters.freezed.dart';

@freezed
sealed class LogFilters with _$LogFilters {
  const factory LogFilters({
    @Default(true) bool onlyMine,
    String? searchQuery,
    String? sortBy,
    @Default(false) bool ascending,
    double? minRating,
    String? coffeeType,
    int? limit,
    int? offset,
  }) = _LogFilters;
}
