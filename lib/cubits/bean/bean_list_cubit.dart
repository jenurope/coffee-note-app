import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../services/auth_service.dart';
import '../../services/coffee_bean_service.dart';
import 'bean_filters.dart';
import 'bean_list_state.dart';

class BeanListCubit extends Cubit<BeanListState> {
  BeanListCubit({CoffeeBeanService? service, AuthService? authService})
    : _service = service ?? getIt<CoffeeBeanService>(),
      _authService = authService ?? getIt<AuthService>(),
      super(const BeanListState.initial());

  final CoffeeBeanService _service;
  final AuthService _authService;

  /// 현재 필터로 목록 로드
  Future<void> load([BeanFilters filters = const BeanFilters()]) async {
    emit(BeanListState.loading(filters: filters));
    try {
      final userId = _authService.currentUser?.id;
      final beans = await _service.getBeans(
        userId: filters.onlyMine ? userId : null,
        searchQuery: filters.searchQuery,
        sortBy: filters.sortBy,
        ascending: filters.ascending,
        minRating: filters.minRating,
        roastLevel: filters.roastLevel,
        limit: filters.limit,
        offset: filters.offset,
      );
      emit(BeanListState.loaded(beans: beans, filters: filters));
    } catch (e) {
      debugPrint('BeanListCubit.load error: $e');
      emit(BeanListState.error(message: e.toString(), filters: filters));
    }
  }

  /// CRUD 후 현재 필터로 재로드 (Cubit 간 갱신 계약)
  Future<void> reload() async {
    final currentFilters = switch (state) {
      BeanListLoading(filters: final f) => f,
      BeanListLoaded(filters: final f) => f,
      BeanListError(filters: final f) => f,
      _ => const BeanFilters(),
    };
    await load(currentFilters);
  }

  /// 필터 변경
  Future<void> updateFilters(BeanFilters filters) async {
    await load(filters);
  }
}
