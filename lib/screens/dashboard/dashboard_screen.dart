import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/bean_card.dart';
import '../../widgets/coffee_log_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<DashboardCubit>();
    if (cubit.state is DashboardInitial) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final isGuest = authState is AuthGuest;

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashState) {
            final l10n = context.l10n;
            final rawName = currentUser?.userMetadata?['name'];
            final metadataName = rawName is String ? rawName.trim() : '';
            final authenticatedFallbackName = metadataName.isNotEmpty
                ? metadataName
                : l10n.userDefault;
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.appTitle),
              ),
              body: RefreshIndicator(
                onRefresh: () => context.read<DashboardCubit>().refresh(),
                child: switch (dashState) {
                  DashboardInitial() || DashboardLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  DashboardError(message: final message) =>
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                l10n.errorOccurredWithMessage(
                                  UserErrorMessage.localize(l10n, message),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: l10n.retry,
                                onPressed: () =>
                                    context.read<DashboardCubit>().refresh(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  DashboardLoaded(
                    totalBeans: final totalBeans,
                    totalLogs: final totalLogs,
                    recentBeans: final recentBeans,
                    recentLogs: final recentLogs,
                    userProfile: final userProfile,
                  ) =>
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 인사말
                          Text(
                            l10n.helloUser(
                              userProfile?.nickname ??
                                  (isGuest
                                      ? l10n.guestNickname
                                      : authenticatedFallbackName),
                            ),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.dashboardSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 통계 카드
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: l10n.beanRecords,
                                  value: l10n.countBeans(totalBeans),
                                  icon: Icons.coffee,
                                  onTap: () => context.go('/beans'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: l10n.coffeeRecords,
                                  value: l10n.countLogs(totalLogs),
                                  icon: Icons.local_cafe,
                                  onTap: () => context.go('/logs'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // 빠른 액션 버튼
                          if (currentUser != null && !isGuest) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: l10n.recordBean,
                                      icon: Icons.add,
                                      onPressed: () => context.go('/beans/new'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomButton(
                                      text: l10n.recordCoffee,
                                      icon: Icons.add,
                                      isOutlined: true,
                                      onPressed: () => context.go('/logs/new'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 최근 원두 기록
                          _buildSectionHeader(
                            context,
                            title: l10n.recentBeanRecords,
                            onViewAll: () => context.go('/beans'),
                          ),
                          const SizedBox(height: 12),
                          recentBeans.isEmpty
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.coffee,
                                          size: 48,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(l10n.noBeanRecordsYet),
                                        if (currentUser != null &&
                                            !isGuest) ...[
                                          const SizedBox(height: 12),
                                          TextButton(
                                            onPressed: () =>
                                                context.go('/beans/new'),
                                            child: Text(l10n.firstBeanRecord),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  height: 280,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    clipBehavior: Clip.none,
                                    itemCount: recentBeans.length,
                                    itemBuilder: (context, index) {
                                      final bean = recentBeans[index];
                                      return Container(
                                        width: 200,
                                        margin: EdgeInsets.only(
                                          right: index < recentBeans.length - 1
                                              ? 12
                                              : 0,
                                        ),
                                        child: BeanCard(
                                          bean: bean,
                                          onTap: () =>
                                              context.go('/beans/${bean.id}'),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                          const SizedBox(height: 24),

                          // 최근 커피 기록
                          _buildSectionHeader(
                            context,
                            title: l10n.recentCoffeeRecords,
                            onViewAll: () => context.go('/logs'),
                          ),
                          const SizedBox(height: 12),
                          recentLogs.isEmpty
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.local_cafe,
                                          size: 48,
                                          color: theme.colorScheme.secondary
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(l10n.noCoffeeRecordsYet),
                                        if (currentUser != null &&
                                            !isGuest) ...[
                                          const SizedBox(height: 12),
                                          TextButton(
                                            onPressed: () =>
                                                context.go('/logs/new'),
                                            child: Text(l10n.firstCoffeeRecord),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: recentLogs
                                      .map(
                                        (log) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: CoffeeLogListTile(
                                            log: log,
                                            onTap: () =>
                                                context.go('/logs/${log.id}'),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                },
              ),
            );
          },
        );
      },
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.viewMore),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 14),
              ],
            ),
          ),
      ],
    );
  }
}
