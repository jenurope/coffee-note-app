import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../services/coffee_bean_service.dart';
import 'bean_detail_state.dart';

class BeanDetailCubit extends Cubit<BeanDetailState> {
  BeanDetailCubit({CoffeeBeanService? service})
    : _service = service ?? getIt<CoffeeBeanService>(),
      super(const BeanDetailState.initial());

  final CoffeeBeanService _service;

  Future<void> load(String beanId) async {
    emit(const BeanDetailState.loading());
    try {
      final bean = await _service.getBean(beanId);
      if (bean != null) {
        emit(BeanDetailState.loaded(bean: bean));
      } else {
        emit(const BeanDetailState.error(message: '원두를 찾을 수 없습니다.'));
      }
    } catch (e) {
      debugPrint('BeanDetailCubit.load error: $e');
      emit(BeanDetailState.error(message: e.toString()));
    }
  }
}
