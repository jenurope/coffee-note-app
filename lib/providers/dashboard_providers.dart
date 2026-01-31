import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'bean_providers.dart';
import 'log_providers.dart';

// 대시보드 통계 Provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return DashboardStats.empty();
  }

  final beanService = ref.watch(coffeeBeanServiceProvider);
  final logService = ref.watch(coffeeLogServiceProvider);

  final beanStats = await beanService.getUserBeanStats(currentUser.id);
  final logStats = await logService.getUserLogStats(currentUser.id);

  return DashboardStats(
    totalBeans: beanStats['totalCount'] as int,
    averageBeanRating: beanStats['averageRating'] as double,
    totalLogs: logStats['totalCount'] as int,
    averageLogRating: logStats['averageRating'] as double,
    coffeeTypeCount: logStats['typeCount'] as Map<String, int>,
  );
});

// Stats Class
class DashboardStats {
  final int totalBeans;
  final double averageBeanRating;
  final int totalLogs;
  final double averageLogRating;
  final Map<String, int> coffeeTypeCount;

  DashboardStats({
    required this.totalBeans,
    required this.averageBeanRating,
    required this.totalLogs,
    required this.averageLogRating,
    required this.coffeeTypeCount,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalBeans: 0,
      averageBeanRating: 0,
      totalLogs: 0,
      averageLogRating: 0,
      coffeeTypeCount: {},
    );
  }
}
