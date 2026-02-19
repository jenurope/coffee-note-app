import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/coffee_bean_service.dart';
import '../../services/guest_sample_service.dart';
import 'bean_detail_state.dart';

class BeanDetailCubit extends Cubit<BeanDetailState> {
  BeanDetailCubit({
    CoffeeBeanService? service,
    AuthCubit? authCubit,
    GuestSampleService? sampleService,
  }) : _service = service ?? getIt<CoffeeBeanService>(),
       _authCubit = authCubit,
       _sampleService = sampleService ?? getIt<GuestSampleService>(),
       super(const BeanDetailState.initial());

  final CoffeeBeanService _service;
  final AuthCubit? _authCubit;
  final GuestSampleService _sampleService;

  Future<void> load(String beanId) async {
    emit(const BeanDetailState.loading());
    try {
      final authState = _authCubit?.state;
      if (authState is AuthGuest) {
        final bean = await _sampleService.getBean(beanId);
        if (bean != null) {
          emit(BeanDetailState.loaded(bean: bean));
        } else {
          emit(const BeanDetailState.error(message: 'errSampleBeanNotFound'));
        }
        return;
      }

      if (authState != null && authState is! AuthAuthenticated) {
        emit(const BeanDetailState.error(message: 'requiredLogin'));
        return;
      }

      final bean = await _service.getBean(beanId);
      if (bean != null) {
        emit(BeanDetailState.loaded(bean: bean));
      } else {
        emit(const BeanDetailState.error(message: 'errBeanNotFound'));
      }
    } catch (e) {
      debugPrint('BeanDetailCubit.load error: $e');
      emit(
        BeanDetailState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errLoadBeanDetail'),
        ),
      );
    }
  }
}
