import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/coffee_bean.dart';
import '../../models/coffee_log.dart';
import '../../models/user_profile.dart';

part 'dashboard_state.freezed.dart';

@freezed
sealed class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = DashboardInitial;
  const factory DashboardState.loading() = DashboardLoading;
  const factory DashboardState.loaded({
    required int totalBeans,
    required double averageBeanRating,
    required int totalLogs,
    required double averageLogRating,
    required Map<String, int> coffeeTypeCount,
    required List<CoffeeBean> recentBeans,
    required List<CoffeeLog> recentLogs,
    UserProfile? userProfile,
  }) = DashboardLoaded;
  const factory DashboardState.error({required String message}) =
      DashboardError;
}
