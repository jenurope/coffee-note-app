import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/coffee_bean.dart';

part 'bean_detail_state.freezed.dart';

@freezed
sealed class BeanDetailState with _$BeanDetailState {
  const factory BeanDetailState.initial() = BeanDetailInitial;
  const factory BeanDetailState.loading() = BeanDetailLoading;
  const factory BeanDetailState.loaded({required CoffeeBean bean}) =
      BeanDetailLoaded;
  const factory BeanDetailState.error({required String message}) =
      BeanDetailError;
}
