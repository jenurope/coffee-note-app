import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../services/auth_service.dart';
import '../../services/coffee_bean_service.dart';
import '../../services/coffee_log_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    AuthService? authService,
    CoffeeBeanService? beanService,
    CoffeeLogService? logService,
  }) : _authService = authService ?? getIt<AuthService>(),
       _beanService = beanService ?? getIt<CoffeeBeanService>(),
       _logService = logService ?? getIt<CoffeeLogService>(),
       super(const DashboardState.initial());

  final AuthService _authService;
  final CoffeeBeanService _beanService;
  final CoffeeLogService _logService;

  Future<void> load() async {
    emit(const DashboardState.loading());
    try {
      final currentUser = _authService.currentUser;

      // 프로필 로드
      final userProfile = currentUser != null
          ? await _authService.getProfile(currentUser.id)
          : null;

      // 통계 로드
      int totalBeans = 0;
      double averageBeanRating = 0;
      int totalLogs = 0;
      double averageLogRating = 0;
      Map<String, int> coffeeTypeCount = {};

      if (currentUser != null) {
        final beanStats = await _beanService.getUserBeanStats(currentUser.id);
        final logStats = await _logService.getUserLogStats(currentUser.id);
        totalBeans = beanStats['totalCount'] as int;
        averageBeanRating = beanStats['averageRating'] as double;
        totalLogs = logStats['totalCount'] as int;
        averageLogRating = logStats['averageRating'] as double;
        coffeeTypeCount = logStats['typeCount'] as Map<String, int>;
      }

      // 최근 기록 로드
      final recentBeans = await _beanService.getBeans(
        userId: currentUser?.id,
        sortBy: 'created_at',
        ascending: false,
        limit: 5,
      );
      final recentLogs = await _logService.getLogs(
        userId: currentUser?.id,
        sortBy: 'created_at',
        ascending: false,
        limit: 5,
      );

      emit(
        DashboardState.loaded(
          totalBeans: totalBeans,
          averageBeanRating: averageBeanRating,
          totalLogs: totalLogs,
          averageLogRating: averageLogRating,
          coffeeTypeCount: coffeeTypeCount,
          recentBeans: recentBeans,
          recentLogs: recentLogs,
          userProfile: userProfile,
        ),
      );
    } catch (e) {
      debugPrint('DashboardCubit.load error: $e');
      emit(DashboardState.error(message: e.toString()));
    }
  }

  Future<void> refresh() => load();
}
