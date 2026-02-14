import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/coffee_log.dart';

part 'log_detail_state.freezed.dart';

@freezed
sealed class LogDetailState with _$LogDetailState {
  const factory LogDetailState.initial() = LogDetailInitial;
  const factory LogDetailState.loading() = LogDetailLoading;
  const factory LogDetailState.loaded({required CoffeeLog log}) =
      LogDetailLoaded;
  const factory LogDetailState.error({required String message}) =
      LogDetailError;
}
