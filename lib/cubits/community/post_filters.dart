import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_filters.freezed.dart';

@freezed
sealed class PostFilters with _$PostFilters {
  const factory PostFilters({
    String? searchQuery,
    String? sortBy,
    @Default(false) bool ascending,
    int? limit,
    int? offset,
  }) = _PostFilters;
}
