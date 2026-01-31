import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/common/common_widgets.dart';

class CoffeeLogDetailScreen extends ConsumerWidget {
  final String logId;

  const CoffeeLogDetailScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logAsync = ref.watch(coffeeLogDetailProvider(logId));
    final currentUser = ref.watch(currentUserProvider);
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    return logAsync.when(
      data: (log) {
        if (log == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('기록을 찾을 수 없습니다.')),
          );
        }

        final isOwner = currentUser?.id == log.userId;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 앱바 with 이미지
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: log.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: log.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                          onPressed: () => context.push('/logs/$logId/edit'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteDialog(context, ref),
                        ),
                      ]
                    : null,
              ),

              // 내용
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 커피 종류 칩
                      Chip(
                        label: Text(log.coffeeType),
                        backgroundColor:
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 커피 이름
                      Text(
                        log.coffeeName ?? log.coffeeType,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 카페 이름
                      Row(
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 20,
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            log.cafeName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 평점
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

                      // 방문일
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
                                '방문일',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                dateFormat.format(log.cafeVisitDate),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 메모
                      if (log.notes != null && log.notes!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          '메모',
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
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다\n$error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.local_cafe,
          size: 80,
          color: theme.colorScheme.secondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 커피 기록을 삭제하시겠습니까?'),
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
        await ref.read(coffeeLogServiceProvider).deleteLog(logId);
        ref.invalidate(coffeeLogsProvider);
        ref.invalidate(recentLogsProvider);
        if (context.mounted) {
          context.go('/logs');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기록이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }
}
