import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/image/app_image_cache_policy.dart';
import '../domain/catalogs/coffee_type_catalog.dart';
import '../l10n/l10n.dart';
import '../models/coffee_log.dart';
import 'common/common_widgets.dart';

class CoffeeLogListTile extends StatelessWidget {
  static const double _imageWidth = 88;
  static const double _minTileHeight = 96;

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
    final cafeName = log.cafeName.trim();
    final hasCafeName = cafeName.isNotEmpty;
    final notes = log.notes?.trim();
    final hasNotes = notes != null && notes.isNotEmpty;

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
                  key: const Key('coffee-log-list-tile-image'),
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
                                log.coffeeName ??
                                    CoffeeTypeCatalog.label(
                                      context.l10n,
                                      log.coffeeType,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hasCafeName)
                                Text(
                                  cafeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              if (hasNotes)
                                Text(
                                  notes,
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
                            RatingStars(rating: log.rating, size: 14),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(log.cafeVisitDate),
                              style: theme.textTheme.labelSmall,
                            ),
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
        Icons.local_cafe,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
