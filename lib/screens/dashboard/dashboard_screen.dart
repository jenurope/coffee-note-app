import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../l10n/l10n.dart';
import '../../widgets/bean_list_tile.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/coffee_log_list_tile.dart';

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
            final loadedProfile = dashState is DashboardLoaded
                ? dashState.userProfile
                : null;
            final beanRecordsVisible =
                loadedProfile?.isBeanRecordsEnabled ?? true;
            final coffeeRecordsVisible =
                loadedProfile?.isCoffeeRecordsEnabled ?? true;
            final anyFeatureVisible =
                beanRecordsVisible || coffeeRecordsVisible;
            return Scaffold(
              appBar: AppBar(title: Text(l10n.appTitle)),
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
                          if (beanRecordsVisible && coffeeRecordsVisible) ...[
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
                          ] else if (beanRecordsVisible) ...[
                            SizedBox(
                              width: double.infinity,
                              child: StatCard(
                                title: l10n.beanRecords,
                                value: l10n.countBeans(totalBeans),
                                icon: Icons.coffee,
                                onTap: () => context.go('/beans'),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else if (coffeeRecordsVisible) ...[
                            SizedBox(
                              width: double.infinity,
                              child: StatCard(
                                title: l10n.coffeeRecords,
                                value: l10n.countLogs(totalLogs),
                                icon: Icons.local_cafe,
                                onTap: () => context.go('/logs'),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 빠른 액션 버튼
                          if (currentUser != null &&
                              !isGuest &&
                              anyFeatureVisible) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: beanRecordsVisible && coffeeRecordsVisible
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: CustomButton(
                                            text: l10n.beansRecordButton,
                                            icon: Icons.add,
                                            onPressed: () =>
                                                context.go('/beans/new'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CustomButton(
                                            text: l10n.logsRecordButton,
                                            icon: Icons.add,
                                            isOutlined: true,
                                            onPressed: () =>
                                                context.go('/logs/new'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : CustomButton(
                                      text: beanRecordsVisible
                                          ? l10n.beansRecordButton
                                          : l10n.logsRecordButton,
                                      icon: Icons.add,
                                      isOutlined: !beanRecordsVisible,
                                      onPressed: () => context.go(
                                        beanRecordsVisible
                                            ? '/beans/new'
                                            : '/logs/new',
                                      ),
                                      width: double.infinity,
                                    ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (!anyFeatureVisible) ...[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        l10n.profileSettingsEmptyState,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 최근 원두 기록
                          if (beanRecordsVisible) ...[
                            _buildSectionHeader(
                              context,
                              title: l10n.recentBeanRecords,
                              onViewAll: () => context.go('/beans'),
                            ),
                            const SizedBox(height: 12),
                            recentBeans.isEmpty
                                ? _buildEmptyRecordCard(
                                    context,
                                    key: const ValueKey(
                                      'dashboardEmptyBeanCard',
                                    ),
                                    icon: Icons.coffee,
                                    iconColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.5),
                                    message: l10n.noBeanRecordsYet,
                                    actionLabel: l10n.firstBeanRecord,
                                    onAction: currentUser != null && !isGuest
                                        ? () => context.go('/beans/new')
                                        : null,
                                  )
                                : Column(
                                    children: recentBeans
                                        .map(
                                          (bean) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: BeanListTile(
                                              bean: bean,
                                              onTap: () => context.go(
                                                '/beans/${bean.id}',
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                            const SizedBox(height: 24),
                          ],

                          // 최근 커피 기록
                          if (coffeeRecordsVisible) ...[
                            _buildSectionHeader(
                              context,
                              title: l10n.recentCoffeeRecords,
                              onViewAll: () => context.go('/logs'),
                            ),
                            const SizedBox(height: 12),
                            recentLogs.isEmpty
                                ? _buildEmptyRecordCard(
                                    context,
                                    key: const ValueKey(
                                      'dashboardEmptyCoffeeCard',
                                    ),
                                    icon: Icons.local_cafe,
                                    iconColor: theme.colorScheme.secondary
                                        .withValues(alpha: 0.5),
                                    message: l10n.noCoffeeRecordsYet,
                                    actionLabel: l10n.firstCoffeeRecord,
                                    onAction: currentUser != null && !isGuest
                                        ? () => context.go('/logs/new')
                                        : null,
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
                          ],

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

  Widget _buildEmptyRecordCard(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required Color iconColor,
    required String message,
    required String actionLabel,
    VoidCallback? onAction,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: iconColor),
              const SizedBox(height: 12),
              Text(message),
              if (onAction != null) ...[
                const SizedBox(height: 12),
                TextButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
