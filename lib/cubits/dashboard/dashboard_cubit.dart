import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/auth_service.dart';
import '../../services/coffee_bean_service.dart';
import '../../services/coffee_log_service.dart';
import '../../services/guest_sample_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    AuthCubit? authCubit,
    AuthService? authService,
    CoffeeBeanService? beanService,
    CoffeeLogService? logService,
    GuestSampleService? sampleService,
  }) : super(const DashboardState.initial()) {
    try {
      _authCubit = authCubit;
      _authService = authService ?? getIt<AuthService>();
      _beanService = beanService ?? getIt<CoffeeBeanService>();
      _logService = logService ?? getIt<CoffeeLogService>();
      _sampleService = sampleService ?? getIt<GuestSampleService>();
    } catch (e) {
      debugPrint('DashboardCubit failed to resolve services: $e');
    }
  }

  AuthCubit? _authCubit;
  AuthService? _authService;
  CoffeeBeanService? _beanService;
  CoffeeLogService? _logService;
  GuestSampleService? _sampleService;

  Future<void> load() async {
    emit(const DashboardState.loading());
    try {
      final authCubit = _authCubit;
      final authService = _authService;
      final beanService = _beanService;
      final logService = _logService;
      final sampleService = _sampleService;

      if (authService == null ||
          beanService == null ||
          logService == null ||
          sampleService == null) {
        throw Exception('필수 서비스가 초기화되지 않았습니다.');
      }

      final authState = authCubit?.state;

      if (authState is AuthGuest) {
        final snapshot = await sampleService.getDashboardSnapshot();
        emit(
          DashboardState.loaded(
            totalBeans: snapshot.totalBeans,
            averageBeanRating: snapshot.averageBeanRating,
            totalLogs: snapshot.totalLogs,
            averageLogRating: snapshot.averageLogRating,
            coffeeTypeCount: snapshot.coffeeTypeCount,
            recentBeans: snapshot.recentBeans,
            recentLogs: snapshot.recentLogs,
            userProfile: snapshot.userProfile,
          ),
        );
        return;
      }

      if (authState is! AuthAuthenticated) {
        emit(
          const DashboardState.loaded(
            totalBeans: 0,
            averageBeanRating: 0,
            totalLogs: 0,
            averageLogRating: 0,
            coffeeTypeCount: {},
            recentBeans: [],
            recentLogs: [],
          ),
        );
        return;
      }

      final userId = authState.user.id;
      final userProfile = await authService.getProfile(userId);
      final beanStats = await beanService.getUserBeanStats(userId);
      final logStats = await logService.getUserLogStats(userId);

      final recentBeans = await beanService.getBeans(
        userId: userId,
        sortBy: 'created_at',
        ascending: false,
        limit: 5,
      );
      final recentLogs = await logService.getLogs(
        userId: userId,
        sortBy: 'created_at',
        ascending: false,
        limit: 5,
      );

      emit(
        DashboardState.loaded(
          totalBeans: beanStats['totalCount'] as int,
          averageBeanRating: beanStats['averageRating'] as double,
          totalLogs: logStats['totalCount'] as int,
          averageLogRating: logStats['averageRating'] as double,
          coffeeTypeCount: logStats['typeCount'] as Map<String, int>,
          recentBeans: recentBeans,
          recentLogs: recentLogs,
          userProfile: userProfile,
        ),
      );
    } catch (e) {
      debugPrint('DashboardCubit.load error: $e');
      emit(
        DashboardState.error(
          message: UserErrorMessage.from(
            e,
            fallback: '대시보드 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
          ),
        ),
      );
    }
  }

  Future<void> onAuthStateChanged(AuthState authState) async {
    if (authState is AuthGuest || authState is AuthAuthenticated) {
      await load();
      return;
    }

    reset();
  }

  void reset() {
    emit(const DashboardState.initial());
  }

  Future<void> refresh() => load();
}
