import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCachePolicy {
  AppImageCachePolicy._();

  static const String _signedUrlPathToken = '/storage/v1/object/sign/';

  static final CacheManager cacheManager = CacheManager(
    Config(
      'coffee_note_image_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 300,
    ),
  );

  static String? cacheKeyFor(String imageUrl) {
    final normalizedUrl = imageUrl.trim();
    if (normalizedUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      return null;
    }

    if (!uri.path.contains(_signedUrlPathToken)) {
      return null;
    }

    if (!uri.hasScheme && !uri.hasAuthority) {
      return uri.path;
    }

    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();
  }

  static Set<String> evictionKeysFor(String? imageUrl) {
    final normalizedUrl = imageUrl?.trim();
    if (normalizedUrl == null || normalizedUrl.isEmpty) {
      return const <String>{};
    }

    final keys = <String>{normalizedUrl};
    final cacheKey = cacheKeyFor(normalizedUrl);
    if (cacheKey != null && cacheKey.isNotEmpty) {
      keys.add(cacheKey);
    }
    return keys;
  }

  static Future<void> evict(String? imageUrl) async {
    for (final key in evictionKeysFor(imageUrl)) {
      try {
        await cacheManager.removeFile(key);
      } catch (_) {
        // Ignore cache eviction failures and continue with the refresh flow.
      }
    }
  }
}
