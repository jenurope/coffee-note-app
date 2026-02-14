import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../services/coffee_log_service.dart';
import 'log_filters.dart';
import 'log_list_state.dart';

class LogListCubit extends Cubit<LogListState> {
  LogListCubit({CoffeeLogService? service, String? userId})
    : _service = service ?? getIt<CoffeeLogService>(),
      _userId = userId,
      super(const LogListState.initial());

  final CoffeeLogService _service;
  final String? _userId;

  Future<void> load([LogFilters filters = const LogFilters()]) async {
    emit(LogListState.loading(filters: filters));
    try {
      final logs = await _service.getLogs(
        userId: filters.onlyMine ? _userId : null,
        searchQuery: filters.searchQuery,
        sortBy: filters.sortBy,
        ascending: filters.ascending,
        minRating: filters.minRating,
        coffeeType: filters.coffeeType,
        limit: filters.limit,
        offset: filters.offset,
      );
      emit(LogListState.loaded(logs: logs, filters: filters));
    } catch (e) {
      debugPrint('LogListCubit.load error: $e');
      emit(LogListState.error(message: e.toString(), filters: filters));
    }
  }

  Future<void> reload() async {
    final currentFilters = switch (state) {
      LogListLoading(filters: final f) => f,
      LogListLoaded(filters: final f) => f,
      LogListError(filters: final f) => f,
      _ => const LogFilters(),
    };
    await load(currentFilters);
  }

  Future<void> updateFilters(LogFilters filters) async {
    await load(filters);
  }
}
