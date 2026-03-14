import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/image/app_image_cache_policy.dart';
import '../domain/catalogs/roast_level_catalog.dart';
import '../l10n/l10n.dart';
import '../models/coffee_bean.dart';
import 'common/common_widgets.dart';

class BeanListTile extends StatelessWidget {
  final CoffeeBean bean;
  final VoidCallback? onTap;

  const BeanListTile({super.key, required this.bean, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = bean.imageUrl?.trim();
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
        title: Text(bean.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                RoastLevelCatalog.label(context.l10n, bean.roastLevel!),
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
