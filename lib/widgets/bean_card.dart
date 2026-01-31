import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/coffee_bean.dart';
import 'common/common_widgets.dart';

class BeanCard extends StatelessWidget {
  final CoffeeBean bean;
  final VoidCallback? onTap;

  const BeanCard({
    super.key,
    required this.bean,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            AspectRatio(
              aspectRatio: 16 / 9,
              child: bean.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: bean.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(theme),
                    )
                  : _buildPlaceholder(theme),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 로스팅 레벨 칩
                  if (bean.roastLevel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bean.roastLevel!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // 원두 이름
                  Text(
                    bean.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 로스터리
                  Text(
                    bean.roastery,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 평점
                  Row(
                    children: [
                      RatingStars(rating: bean.rating, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        bean.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // 테이스팅 노트
                  if (bean.tastingNotes != null &&
                      bean.tastingNotes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      bean.tastingNotes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.coffee,
          size: 48,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class BeanListTile extends StatelessWidget {
  final CoffeeBean bean;
  final VoidCallback? onTap;

  const BeanListTile({
    super.key,
    required this.bean,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: bean.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: bean.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    errorWidget: (context, url, error) => _buildPlaceholder(theme),
                  )
                : _buildPlaceholder(theme),
          ),
        ),
        title: Text(
          bean.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          bean.roastery,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RatingStars(rating: bean.rating, size: 14),
            if (bean.roastLevel != null) ...[
              const SizedBox(height: 4),
              Text(
                bean.roastLevel!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.coffee,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
