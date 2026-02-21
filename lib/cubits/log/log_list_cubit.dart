import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../models/coffee_log.dart';
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
  static const int _pageSize = 20;

  LogFilters _baseFilters = const LogFilters();
  List<CoffeeLog> _logs = const [];
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> load([LogFilters filters = const LogFilters()]) async {
    _baseFilters = _normalizeFilters(filters);
    _logs = const [];
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    emit(LogListState.loading(filters: _baseFilters));
    try {
      final logs = await _fetchPage(offset: 0);
      _logs = logs;
      _offset = logs.length;
      _hasMore = logs.length == _pageSize;
      emit(
        LogListState.loaded(
          logs: List.unmodifiable(_logs),
          filters: _baseFilters,
        ),
      );
    } catch (e) {
      debugPrint('LogListCubit.load error: $e');
      emit(
        LogListState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errLoadLogs'),
          filters: _baseFilters,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final currentState = state;
    if (currentState is! LogListLoaded) return;

    _isLoadingMore = true;
    try {
      final next = await _fetchPage(offset: _offset);
      if (next.isEmpty) {
        _hasMore = false;
        return;
      }
      _logs = [..._logs, ...next];
      _offset = _logs.length;
      _hasMore = next.length == _pageSize;
      emit(currentState.copyWith(logs: List.unmodifiable(_logs)));
    } catch (e) {
      debugPrint('LogListCubit.loadMore error: $e');
    } finally {
      _isLoadingMore = false;
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
    _baseFilters = const LogFilters();
    _logs = const [];
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    emit(const LogListState.initial());
  }

  LogFilters _currentFilters() {
    return switch (state) {
      LogListLoading(filters: final f) => f,
      LogListLoaded(filters: final f) => f,
      LogListError(filters: final f) => f,
      _ => _baseFilters,
    };
  }

  Future<void> reload() async {
    await load(_currentFilters());
  }

  Future<void> updateFilters(LogFilters filters) async {
    await load(filters);
  }

  LogFilters _normalizeFilters(LogFilters filters) {
    return filters.copyWith(limit: null, offset: null);
  }

  Future<List<CoffeeLog>> _fetchPage({required int offset}) async {
    final authState = _authCubit?.state;
    if (authState is AuthGuest) {
      return _sampleService.getLogs(
        searchQuery: _baseFilters.searchQuery,
        sortBy: _baseFilters.sortBy,
        ascending: _baseFilters.ascending,
        minRating: _baseFilters.minRating,
        coffeeType: _baseFilters.coffeeType,
        limit: _pageSize,
        offset: offset,
      );
    }

    if (authState is AuthAuthenticated) {
      return _service.getLogs(
        userId: _baseFilters.onlyMine ? authState.user.id : null,
        searchQuery: _baseFilters.searchQuery,
        sortBy: _baseFilters.sortBy,
        ascending: _baseFilters.ascending,
        minRating: _baseFilters.minRating,
        coffeeType: _baseFilters.coffeeType,
        limit: _pageSize,
        offset: offset,
      );
    }

    return const [];
  }
}
