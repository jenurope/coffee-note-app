import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../models/coffee_bean.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/coffee_bean_service.dart';
import '../../services/guest_sample_service.dart';
import 'bean_filters.dart';
import 'bean_list_state.dart';

class BeanListCubit extends Cubit<BeanListState> {
  BeanListCubit({
    CoffeeBeanService? service,
    AuthCubit? authCubit,
    GuestSampleService? sampleService,
  }) : _service = service ?? getIt<CoffeeBeanService>(),
       _authCubit = authCubit,
       _sampleService = sampleService ?? getIt<GuestSampleService>(),
       super(const BeanListState.initial());

  final CoffeeBeanService _service;
  final AuthCubit? _authCubit;
  final GuestSampleService _sampleService;
  static const int _pageSize = 20;

  BeanFilters _baseFilters = const BeanFilters();
  List<CoffeeBean> _beans = const [];
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  /// 현재 필터로 목록 로드
  Future<void> load([BeanFilters filters = const BeanFilters()]) async {
    _baseFilters = _normalizeFilters(filters);
    _beans = const [];
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    emit(BeanListState.loading(filters: _baseFilters));
    try {
      final beans = await _fetchPage(offset: 0);
      _beans = beans;
      _offset = beans.length;
      _hasMore = beans.length == _pageSize;
      emit(
        BeanListState.loaded(
          beans: List.unmodifiable(_beans),
          filters: _baseFilters,
        ),
      );
    } catch (e) {
      debugPrint('BeanListCubit.load error: $e');
      emit(
        BeanListState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errLoadBeans'),
          filters: _baseFilters,
        ),
      );
    }
  }

  /// 현재 목록 하단 기준 다음 페이지를 로드합니다.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final currentState = state;
    if (currentState is! BeanListLoaded) return;

    _isLoadingMore = true;
    try {
      final next = await _fetchPage(offset: _offset);
      if (next.isEmpty) {
        _hasMore = false;
        return;
      }
      _beans = [..._beans, ...next];
      _offset = _beans.length;
      _hasMore = next.length == _pageSize;
      emit(currentState.copyWith(beans: List.unmodifiable(_beans)));
    } catch (e) {
      debugPrint('BeanListCubit.loadMore error: $e');
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
    _baseFilters = const BeanFilters();
    _beans = const [];
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    emit(const BeanListState.initial());
  }

  BeanFilters _currentFilters() {
    return switch (state) {
      BeanListLoading(filters: final f) => f,
      BeanListLoaded(filters: final f) => f,
      BeanListError(filters: final f) => f,
      _ => _baseFilters,
    };
  }

  /// CRUD 후 현재 필터로 재로드 (Cubit 간 갱신 계약)
  Future<void> reload() async {
    await load(_currentFilters());
  }

  /// 필터 변경
  Future<void> updateFilters(BeanFilters filters) async {
    await load(filters);
  }

  BeanFilters _normalizeFilters(BeanFilters filters) {
    return filters.copyWith(limit: null, offset: null);
  }

  Future<List<CoffeeBean>> _fetchPage({required int offset}) async {
    final authState = _authCubit?.state;
    if (authState is AuthGuest) {
      return _sampleService.getBeans(
        searchQuery: _baseFilters.searchQuery,
        sortBy: _baseFilters.sortBy,
        ascending: _baseFilters.ascending,
        minRating: _baseFilters.minRating,
        roastLevel: _baseFilters.roastLevel,
        limit: _pageSize,
        offset: offset,
      );
    }

    if (authState is AuthAuthenticated) {
      return _service.getBeans(
        userId: _baseFilters.onlyMine ? authState.user.id : null,
        searchQuery: _baseFilters.searchQuery,
        sortBy: _baseFilters.sortBy,
        ascending: _baseFilters.ascending,
        minRating: _baseFilters.minRating,
        roastLevel: _baseFilters.roastLevel,
        limit: _pageSize,
        offset: offset,
      );
    }

    return const [];
  }
}
