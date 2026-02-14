import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/coffee_bean.dart';
import 'bean_filters.dart';

part 'bean_list_state.freezed.dart';

@freezed
sealed class BeanListState with _$BeanListState {
  const factory BeanListState.initial() = BeanListInitial;
  const factory BeanListState.loading({required BeanFilters filters}) =
      BeanListLoading;
  const factory BeanListState.loaded({
    required List<CoffeeBean> beans,
    required BeanFilters filters,
  }) = BeanListLoaded;
  const factory BeanListState.error({
    required String message,
    required BeanFilters filters,
  }) = BeanListError;
}
