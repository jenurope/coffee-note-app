import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
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

  /// 현재 필터로 목록 로드
  Future<void> load([BeanFilters filters = const BeanFilters()]) async {
    emit(BeanListState.loading(filters: filters));
    try {
      final authState = _authCubit?.state;
      if (authState is AuthGuest) {
        final beans = await _sampleService.getBeans(
          searchQuery: filters.searchQuery,
          sortBy: filters.sortBy,
          ascending: filters.ascending,
          minRating: filters.minRating,
          roastLevel: filters.roastLevel,
          limit: filters.limit,
          offset: filters.offset,
        );
        emit(BeanListState.loaded(beans: beans, filters: filters));
        return;
      }

      if (authState is AuthAuthenticated) {
        final beans = await _service.getBeans(
          userId: filters.onlyMine ? authState.user.id : null,
          searchQuery: filters.searchQuery,
          sortBy: filters.sortBy,
          ascending: filters.ascending,
          minRating: filters.minRating,
          roastLevel: filters.roastLevel,
          limit: filters.limit,
          offset: filters.offset,
        );
        emit(BeanListState.loaded(beans: beans, filters: filters));
        return;
      }

      emit(BeanListState.loaded(beans: const [], filters: filters));
    } catch (e) {
      debugPrint('BeanListCubit.load error: $e');
      emit(BeanListState.error(message: e.toString(), filters: filters));
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
    emit(const BeanListState.initial());
  }

  BeanFilters _currentFilters() {
    return switch (state) {
      BeanListLoading(filters: final f) => f,
      BeanListLoaded(filters: final f) => f,
      BeanListError(filters: final f) => f,
      _ => const BeanFilters(),
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
}
