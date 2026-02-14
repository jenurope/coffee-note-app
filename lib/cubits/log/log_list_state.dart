import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/coffee_log.dart';
import 'log_filters.dart';

part 'log_list_state.freezed.dart';

@freezed
sealed class LogListState with _$LogListState {
  const factory LogListState.initial() = LogListInitial;
  const factory LogListState.loading({required LogFilters filters}) =
      LogListLoading;
  const factory LogListState.loaded({
    required List<CoffeeLog> logs,
    required LogFilters filters,
  }) = LogListLoaded;
  const factory LogListState.error({
    required String message,
    required LogFilters filters,
  }) = LogListError;
}
