import 'coffee_bean.dart';
import 'coffee_log.dart';
import 'user_profile.dart';

class GuestDashboardSnapshot {
  final int totalBeans;
  final double averageBeanRating;
  final int totalLogs;
  final double averageLogRating;
  final Map<String, int> coffeeTypeCount;
  final List<CoffeeBean> recentBeans;
  final List<CoffeeLog> recentLogs;
  final UserProfile userProfile;

  GuestDashboardSnapshot({
    required this.totalBeans,
    required this.averageBeanRating,
    required this.totalLogs,
    required this.averageLogRating,
    required this.coffeeTypeCount,
    required this.recentBeans,
    required this.recentLogs,
    required this.userProfile,
  });
}
