import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../core/image/app_image_cache_policy.dart';
import '../domain/catalogs/coffee_type_catalog.dart';
import '../l10n/l10n.dart';
import '../models/coffee_log.dart';
import 'common/common_widgets.dart';

class CoffeeLogCard extends StatelessWidget {
  final CoffeeLog log;
  final VoidCallback? onTap;

  const CoffeeLogCard({super.key, required this.log, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    );
    final imageUrl = log.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

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
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      cacheManager: AppImageCachePolicy.cacheManager,
                      cacheKey: AppImageCachePolicy.cacheKeyFor(imageUrl),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildPlaceholder(theme),
                    )
                  : _buildPlaceholder(theme),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 커피 종류 칩
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
                      CoffeeTypeCatalog.label(context.l10n, log.coffeeType),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 커피/카페 이름
                  Text(
                    log.coffeeName ??
                        CoffeeTypeCatalog.label(context.l10n, log.coffeeType),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 카페 이름
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.cafeName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 평점과 날짜
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingStars(rating: log.rating, size: 16),
                      Text(
                        dateFormat.format(log.cafeVisitDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 메모
                  if (log.notes != null && log.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      log.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
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
          Icons.local_cafe,
          size: 48,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class CoffeeLogListTile extends StatelessWidget {
  final CoffeeLog log;
  final VoidCallback? onTap;

  const CoffeeLogListTile({super.key, required this.log, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.Md(
      Localizations.localeOf(context).toString(),
    );
    final imageUrl = log.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    cacheManager: AppImageCachePolicy.cacheManager,
                    cacheKey: AppImageCachePolicy.cacheKeyFor(imageUrl),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildPlaceholder(theme),
                  )
                : _buildPlaceholder(theme),
          ),
        ),
        title: Text(
          log.coffeeName ??
              CoffeeTypeCatalog.label(context.l10n, log.coffeeType),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          log.cafeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RatingStars(rating: log.rating, size: 14),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(log.cafeVisitDate),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.local_cafe,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
