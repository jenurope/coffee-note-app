import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/image/app_image_cache_policy.dart';

class UserAvatar extends StatelessWidget {
  final String? nickname;
  final String? avatarUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const UserAvatar({
    super.key,
    required this.nickname,
    required this.avatarUrl,
    required this.radius,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedNickname = nickname?.trim();
    final initial =
        (normalizedNickname != null && normalizedNickname.isNotEmpty)
        ? normalizedNickname.characters.first.toUpperCase()
        : '?';
    final effectiveBackground =
        backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.1);
    final effectiveForeground = foregroundColor ?? theme.colorScheme.primary;
    final avatarImageUrl = avatarUrl?.trim();
    final hasAvatar = avatarImageUrl != null && avatarImageUrl.isNotEmpty;

    if (!hasAvatar) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackground,
        child: _FallbackInitial(
          initial: initial,
          color: effectiveForeground,
          fontSize: radius * 0.75,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBackground,
      child: ClipOval(
        child: SizedBox.expand(
          child: CachedNetworkImage(
            imageUrl: avatarImageUrl,
            cacheManager: AppImageCachePolicy.cacheManager,
            cacheKey: AppImageCachePolicy.cacheKeyFor(avatarImageUrl),
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: _FallbackInitial(
                initial: initial,
                color: effectiveForeground,
                fontSize: radius * 0.75,
              ),
            ),
            errorWidget: (context, url, error) => Center(
              child: _FallbackInitial(
                initial: initial,
                color: effectiveForeground,
                fontSize: radius * 0.75,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackInitial extends StatelessWidget {
  final String initial;
  final Color color;
  final double fontSize;

  const _FallbackInitial({
    required this.initial,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      initial,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    );
  }
}
