import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/image/app_image_cache_policy.dart';
import '../domain/catalogs/roast_level_catalog.dart';
import '../l10n/l10n.dart';
import '../models/coffee_bean.dart';
import 'common/common_widgets.dart';

class BeanListTile extends StatelessWidget {
  static const double _imageWidth = 88;

  final CoffeeBean bean;
  final VoidCallback? onTap;

  const BeanListTile({super.key, required this.bean, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = bean.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 88,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                key: const Key('bean-list-tile-image'),
                width: _imageWidth,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        cacheManager: AppImageCachePolicy.cacheManager,
                        cacheKey: AppImageCachePolicy.cacheKeyFor(imageUrl),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildPlaceholder(theme),
                      )
                    : _buildPlaceholder(theme),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bean.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              bean.roastery,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RatingStars(rating: bean.rating, size: 14),
                          if (bean.roastLevel != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              RoastLevelCatalog.label(
                                context.l10n,
                                bean.roastLevel!,
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
