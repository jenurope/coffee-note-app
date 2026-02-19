import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/coffee_log_service.dart';
import '../../services/guest_sample_service.dart';
import 'log_filters.dart';
import 'log_list_state.dart';

class LogListCubit extends Cubit<LogListState> {
  LogListCubit({
    CoffeeLogService? service,
    AuthCubit? authCubit,
    GuestSampleService? sampleService,
  }) : _service = service ?? getIt<CoffeeLogService>(),
       _authCubit = authCubit,
       _sampleService = sampleService ?? getIt<GuestSampleService>(),
       super(const LogListState.initial());

  final CoffeeLogService _service;
  final AuthCubit? _authCubit;
  final GuestSampleService _sampleService;

  Future<void> load([LogFilters filters = const LogFilters()]) async {
    emit(LogListState.loading(filters: filters));
    try {
      final authState = _authCubit?.state;
      if (authState is AuthGuest) {
        final logs = await _sampleService.getLogs(
          searchQuery: filters.searchQuery,
          sortBy: filters.sortBy,
          ascending: filters.ascending,
          minRating: filters.minRating,
          coffeeType: filters.coffeeType,
          limit: filters.limit,
          offset: filters.offset,
        );
        emit(LogListState.loaded(logs: logs, filters: filters));
        return;
      }

      if (authState is AuthAuthenticated) {
        final logs = await _service.getLogs(
          userId: filters.onlyMine ? authState.user.id : null,
          searchQuery: filters.searchQuery,
          sortBy: filters.sortBy,
          ascending: filters.ascending,
          minRating: filters.minRating,
          coffeeType: filters.coffeeType,
          limit: filters.limit,
          offset: filters.offset,
        );
        emit(LogListState.loaded(logs: logs, filters: filters));
        return;
      }

      emit(LogListState.loaded(logs: const [], filters: filters));
    } catch (e) {
      debugPrint('LogListCubit.load error: $e');
      emit(
        LogListState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errLoadLogs'),
          filters: filters,
        ),
      );
    }
  }

  Future<void> onAuthStateChanged(AuthState authState) async {
    if (authState is AuthGuest || authState is AuthAuthenticated) {
      await load(_currentFilters());
      return;
    }

    reset();
  }

  void reset() {
    emit(const LogListState.initial());
  }

  LogFilters _currentFilters() {
    return switch (state) {
      LogListLoading(filters: final f) => f,
      LogListLoaded(filters: final f) => f,
      LogListError(filters: final f) => f,
      _ => const LogFilters(),
    };
  }

  Future<void> reload() async {
    await load(_currentFilters());
  }

  Future<void> updateFilters(LogFilters filters) async {
    await load(filters);
  }
}
