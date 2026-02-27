import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../core/image/app_image_cache_policy.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/bean/bean_detail_cubit.dart';
import '../../cubits/bean/bean_detail_state.dart';
import '../../cubits/bean/bean_list_cubit.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../domain/catalogs/brew_method_catalog.dart';
import '../../domain/catalogs/roast_level_catalog.dart';
import '../../l10n/l10n.dart';
import '../../services/coffee_bean_service.dart';
import '../../widgets/common/common_widgets.dart';

class BeanDetailScreen extends StatelessWidget {
  final String beanId;

  const BeanDetailScreen({super.key, required this.beanId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeTag = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(localeTag);
    final numberFormat = NumberFormat.decimalPattern(localeTag);
    final l10n = context.l10n;

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
                final imageUrl = bean.imageUrl?.trim();
                final hasImage = _hasValidImageUrl(imageUrl);
                return Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 250,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: hasImage
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl!,
                                  cacheManager:
                                      AppImageCachePolicy.cacheManager,
                                  cacheKey: AppImageCachePolicy.cacheKeyFor(
                                    imageUrl,
                                  ),
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
                                      _buildPlaceholder(context, theme),
                                )
                              : _buildPlaceholder(context, theme),
                        ),
                        actions: isOwner
                            ? [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    await context.push('/beans/$beanId/edit');
                                    if (context.mounted) {
                                      context.read<BeanDetailCubit>().load(
                                        beanId,
                                      );
                                    }
                                  },
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
                                  label: Text(
                                    RoastLevelCatalog.label(
                                      l10n,
                                      bean.roastLevel!,
                                    ),
                                  ),
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
                                  label: l10n.beanInfoPurchaseDate,
                                  value: dateFormat.format(bean.purchaseDate),
                                ),
                                if (bean.price != null)
                                  _buildInfoRow(
                                    theme,
                                    icon: Icons.attach_money,
                                    label: l10n.beanInfoPrice,
                                    value: numberFormat.format(bean.price),
                                  ),
                                if (bean.purchaseLocation != null)
                                  _buildInfoRow(
                                    theme,
                                    icon: Icons.store,
                                    label: l10n.beanInfoPurchaseLocation,
                                    value: bean.purchaseLocation!,
                                  ),
                                if (bean.brewMethod != null)
                                  _buildInfoRow(
                                    theme,
                                    icon: Icons.menu_book,
                                    label: l10n.beanInfoBrewMethod,
                                    value: BrewMethodCatalog.label(
                                      l10n,
                                      bean.brewMethod!,
                                    ),
                                  ),
                              ]),
                              if (bean.recipe != null &&
                                  bean.recipe!.trim().isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text(
                                  l10n.recipeLabel,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      bean.recipe!,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                              ],
                              if (bean.tastingNotes != null &&
                                  bean.tastingNotes!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text(
                                  l10n.tastingNotes,
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
                      Text(
                        l10n.errorOccurredWithMessage(
                          UserErrorMessage.localize(l10n, message),
                        ),
                      ),
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

  Widget _buildPlaceholder(BuildContext context, ThemeData theme) {
    final topInset = MediaQuery.paddingOf(context).top;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.92),
            theme.colorScheme.primary.withValues(alpha: 0.78),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: topInset,
            child: Center(
              child: Icon(
                Icons.coffee,
                size: 64,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasValidImageUrl(String? imageUrl) {
    final trimmed = imageUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
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
        title: Text(context.l10n.beanDeleteTitle),
        content: Text(context.l10n.beanDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await getIt<CoffeeBeanService>().deleteBean(beanId);
        if (context.mounted) {
          context.read<BeanListCubit>().reload();
          context.read<DashboardCubit>().refresh();
          context.go('/beans');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.beanDeleted)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                UserErrorMessage.localize(
                  context.l10n,
                  UserErrorMessage.from(e, fallbackKey: 'beanDeleteFailed'),
                ),
              ),
            ),
          );
        }
      }
    }
  }
}
