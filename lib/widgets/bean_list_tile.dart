import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/image/app_image_cache_policy.dart';
import '../domain/catalogs/roast_level_catalog.dart';
import '../l10n/l10n.dart';
import '../models/coffee_bean.dart';
import 'common/common_widgets.dart';

class BeanListTile extends StatelessWidget {
  static const double _imageWidth = 88;
  static const double _minTileHeight = 96;

  final CoffeeBean bean;
  final VoidCallback? onTap;

  const BeanListTile({super.key, required this.bean, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = bean.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final purchaseLocation = bean.purchaseLocation?.trim();
    final hasPurchaseLocation =
        purchaseLocation != null && purchaseLocation.isNotEmpty;
    final tastingNotes = bean.tastingNotes?.trim();
    final hasTastingNotes = tastingNotes != null && tastingNotes.isNotEmpty;
    final secondaryText = hasPurchaseLocation
        ? purchaseLocation
        : bean.roastery;
    final tertiaryText = hasTastingNotes
        ? tastingNotes
        : hasPurchaseLocation
        ? bean.roastery
        : null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minTileHeight),
          child: IntrinsicHeight(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bean.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                secondaryText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                              if (tertiaryText != null)
                                Text(
                                  tertiaryText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
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
