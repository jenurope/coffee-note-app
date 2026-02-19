import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/coffee_log_service.dart';
import '../../services/guest_sample_service.dart';
import 'log_detail_state.dart';

class LogDetailCubit extends Cubit<LogDetailState> {
  LogDetailCubit({
    CoffeeLogService? service,
    AuthCubit? authCubit,
    GuestSampleService? sampleService,
  }) : _service = service ?? getIt<CoffeeLogService>(),
       _authCubit = authCubit,
       _sampleService = sampleService ?? getIt<GuestSampleService>(),
       super(const LogDetailState.initial());

  final CoffeeLogService _service;
  final AuthCubit? _authCubit;
  final GuestSampleService _sampleService;

  Future<void> load(String logId) async {
    emit(const LogDetailState.loading());
    try {
      final authState = _authCubit?.state;
      if (authState is AuthGuest) {
        final log = await _sampleService.getLog(logId);
        if (log != null) {
          emit(LogDetailState.loaded(log: log));
        } else {
          emit(const LogDetailState.error(message: 'errSampleLogNotFound'));
        }
        return;
      }

      if (authState != null && authState is! AuthAuthenticated) {
        emit(const LogDetailState.error(message: 'requiredLogin'));
        return;
      }

      final log = await _service.getLog(logId);
      if (log != null) {
        emit(LogDetailState.loaded(log: log));
      } else {
        emit(const LogDetailState.error(message: 'errLogNotFound'));
      }
    } catch (e) {
      debugPrint('LogDetailCubit.load error: $e');
      emit(
        LogDetailState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errLoadLogDetail'),
        ),
      );
    }
  }
}
