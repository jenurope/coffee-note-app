import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/log/log_detail_cubit.dart';
import '../../cubits/log/log_detail_state.dart';
import '../../cubits/log/log_list_cubit.dart';
import '../../domain/catalogs/coffee_type_catalog.dart';
import '../../l10n/l10n.dart';
import '../../services/coffee_log_service.dart';
import '../../widgets/common/common_widgets.dart';

class CoffeeLogDetailScreen extends StatelessWidget {
  final String logId;

  const CoffeeLogDetailScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeTag = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(localeTag);
    final l10n = context.l10n;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthAuthenticated
            ? authState.user.id
            : null;

        return BlocBuilder<LogDetailCubit, LogDetailState>(
          builder: (context, logState) {
            return switch (logState) {
              LogDetailInitial() || LogDetailLoading() => Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()),
              ),
              LogDetailLoaded(log: final log) => () {
                final isOwner = currentUserId == log.userId;
                final hasImage = _hasValidImageUrl(log.imageUrl);
                return Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 250,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: hasImage
                              ? CachedNetworkImage(
                                  imageUrl: log.imageUrl!.trim(),
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
                                  onPressed: () =>
                                      context.push('/logs/$logId/edit'),
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
                              Chip(
                                label: Text(
                                  CoffeeTypeCatalog.label(l10n, log.coffeeType),
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
                                log.coffeeName ??
                                    CoffeeTypeCatalog.label(
                                      l10n,
                                      log.coffeeType,
                                    ),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.storefront,
                                    size: 20,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    log.cafeName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  RatingStars(rating: log.rating, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    log.rating.toStringAsFixed(1),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.visitDate,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        dateFormat.format(log.cafeVisitDate),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (log.notes != null &&
                                  log.notes!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text(
                                  l10n.memo,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      log.notes!,
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
              LogDetailError(message: final message) => Scaffold(
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
                Icons.local_cafe,
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

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.logDeleteTitle),
        content: Text(context.l10n.logDeleteConfirm),
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
        await getIt<CoffeeLogService>().deleteLog(logId);
        if (context.mounted) {
          context.read<LogListCubit>().reload();
          context.go('/logs');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.logDeleted)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                UserErrorMessage.localize(
                  context.l10n,
                  UserErrorMessage.from(e, fallbackKey: 'logDeleteFailed'),
                ),
              ),
            ),
          );
        }
      }
    }
  }
}
