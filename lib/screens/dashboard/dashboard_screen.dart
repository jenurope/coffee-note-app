import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/bean_card.dart';
import '../../widgets/coffee_log_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final isGuest = ref.watch(isGuestModeProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final recentBeans = ref.watch(recentBeansProvider);
    final recentLogs = ref.watch(recentLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나만의 커피 로그'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentBeansProvider);
          ref.invalidate(recentLogsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 인사말
              userProfile.when(
                data: (profile) => Text(
                  '안녕하세요, ${profile?.nickname ?? (isGuest ? '게스트' : '커피러버')}님! ☕',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => Text(
                  '안녕하세요! ☕',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘도 향긋한 커피 한 잔 어떠세요?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 24),

              // 통계 카드
              stats.when(
                data: (data) => Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '기록한 원두',
                        value: '${data.totalBeans}개',
                        icon: Icons.coffee,
                        onTap: () => context.go('/beans'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: '커피 기록',
                        value: '${data.totalLogs}개',
                        icon: Icons.local_cafe,
                        iconColor: theme.colorScheme.secondary,
                        onTap: () => context.go('/logs'),
                      ),
                    ),
                  ],
                ),
                loading: () => Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Container(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Container(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // 빠른 액션 버튼
              if (currentUser != null && !isGuest) ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: '원두 기록하기',
                        icon: Icons.add,
                        onPressed: () => context.push('/beans/new'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: '커피 기록하기',
                        icon: Icons.add,
                        isOutlined: true,
                        onPressed: () => context.push('/logs/new'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 최근 기록 원두
              _buildSectionHeader(
                context,
                title: '최근 기록 원두',
                onViewAll: () => context.go('/beans'),
              ),
              const SizedBox(height: 12),
              recentBeans.when(
                data: (beans) {
                  if (beans.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.coffee_outlined,
                              size: 48,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text('아직 기록한 원두가 없습니다'),
                            if (currentUser != null && !isGuest) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.push('/beans/new'),
                                child: const Text('첫 원두 기록하기'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: beans.length,
                      itemBuilder: (context, index) {
                        final bean = beans[index];
                        return Container(
                          width: 200,
                          margin: EdgeInsets.only(
                            right: index < beans.length - 1 ? 12 : 0,
                          ),
                          child: BeanCard(
                            bean: bean,
                            onTap: () => context.push('/beans/${bean.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // 최근 커피 기록
              _buildSectionHeader(
                context,
                title: '최근 커피 기록',
                onViewAll: () => context.go('/logs'),
              ),
              const SizedBox(height: 12),
              recentLogs.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_cafe_outlined,
                              size: 48,
                              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text('아직 커피 기록이 없습니다'),
                            if (currentUser != null && !isGuest) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.push('/logs/new'),
                                child: const Text('첫 커피 기록하기'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: logs
                        .map((log) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: CoffeeLogListTile(
                                log: log,
                                onTap: () => context.push('/logs/${log.id}'),
                              ),
                            ))
                        .toList(),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('더보기'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
      ],
    );
  }
}
