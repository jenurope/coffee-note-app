import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../services/coffee_log_service.dart';
import 'log_detail_state.dart';

class LogDetailCubit extends Cubit<LogDetailState> {
  LogDetailCubit({CoffeeLogService? service})
    : _service = service ?? getIt<CoffeeLogService>(),
      super(const LogDetailState.initial());

  final CoffeeLogService _service;

  Future<void> load(String logId) async {
    emit(const LogDetailState.loading());
    try {
      final log = await _service.getLog(logId);
      if (log != null) {
        emit(LogDetailState.loaded(log: log));
      } else {
        emit(const LogDetailState.error(message: '기록을 찾을 수 없습니다.'));
      }
    } catch (e) {
      debugPrint('LogDetailCubit.load error: $e');
      emit(LogDetailState.error(message: e.toString()));
    }
  }
}
