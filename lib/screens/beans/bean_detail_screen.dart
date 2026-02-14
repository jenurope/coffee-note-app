import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/bean/bean_detail_cubit.dart';
import '../../cubits/bean/bean_detail_state.dart';
import '../../cubits/bean/bean_list_cubit.dart';
import '../../services/coffee_bean_service.dart';
import '../../widgets/common/common_widgets.dart';

class BeanDetailScreen extends StatelessWidget {
  final String beanId;

  const BeanDetailScreen({super.key, required this.beanId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthAuthenticated
            ? authState.user.id
            : null;

        return BlocBuilder<BeanDetailCubit, BeanDetailState>(
          builder: (context, beanState) {
            return switch (beanState) {
              BeanDetailInitial() || BeanDetailLoading() => Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()),
              ),
              BeanDetailLoaded(bean: final bean) => () {
                final isOwner = currentUserId == bean.userId;
                return Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 250,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: bean.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: bean.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      _buildPlaceholder(theme),
                                )
                              : _buildPlaceholder(theme),
                        ),
                        actions: isOwner
                            ? [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      context.push('/beans/$beanId/edit'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDeleteDialog(context),
                                ),
                              ]
                            : null,
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (bean.roastLevel != null)
                                Chip(
                                  label: Text(bean.roastLevel!),
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                bean.name,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bean.roastery,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  RatingStars(rating: bean.rating, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    bean.rating.toStringAsFixed(1),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              _buildInfoSection(theme, [
                                _buildInfoRow(
                                  theme,
                                  icon: Icons.calendar_today,
                                  label: '구매일',
                                  value: dateFormat.format(bean.purchaseDate),
                                ),
                                if (bean.price != null)
                                  _buildInfoRow(
                                    theme,
                                    icon: Icons.attach_money,
                                    label: '가격',
                                    value:
                                        '${NumberFormat('#,###').format(bean.price)}원',
                                  ),
                                if (bean.purchaseLocation != null)
                                  _buildInfoRow(
                                    theme,
                                    icon: Icons.store,
                                    label: '구매처',
                                    value: bean.purchaseLocation!,
                                  ),
                              ]),
                              if (bean.tastingNotes != null &&
                                  bean.tastingNotes!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text(
                                  '테이스팅 노트',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      bean.tastingNotes!,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                              ],
                              if (bean.beanDetails != null &&
                                  bean.beanDetails!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text(
                                  '원두 상세',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...bean.beanDetails!.map(
                                  (detail) => Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              if (detail.ratio != null) ...[
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${detail.ratio}%',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Text(
                                                detail.origin,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          if (detail.variety != null ||
                                              detail.process != null) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              children: [
                                                if (detail.variety != null)
                                                  Chip(
                                                    label: Text(
                                                      '품종: ${detail.variety}',
                                                    ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                if (detail.process != null)
                                                  Chip(
                                                    label: Text(
                                                      '가공: ${detail.process}',
                                                    ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (bean.brewDetails != null &&
                                  bean.brewDetails!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '추출 기록',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '${bean.brewDetails!.length}건',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...bean.brewDetails!
                                    .take(3)
                                    .map(
                                      (brew) => Card(
                                        child: ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.coffee_maker,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          title: Text(brew.brewMethod ?? '추출'),
                                          subtitle: Text(
                                            dateFormat.format(brew.brewDate),
                                          ),
                                          trailing: brew.grindSize != null
                                              ? Chip(
                                                  label: Text(brew.grindSize!),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                              ],
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }(),
              BeanDetailError(message: final message) => Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text('오류가 발생했습니다\n$message'),
                    ],
                  ),
                ),
              ),
            };
          },
        );
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.coffee,
          size: 80,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('원두 삭제'),
        content: const Text('이 원두를 삭제하시겠습니까?\n관련된 추출 기록도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await getIt<CoffeeBeanService>().deleteBean(beanId);
        if (context.mounted) {
          context.read<BeanListCubit>().reload();
          context.go('/beans');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('원두가 삭제되었습니다.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')));
        }
      }
    }
  }
}
