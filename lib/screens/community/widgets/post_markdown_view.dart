import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PostMarkdownView extends StatelessWidget {
  const PostMarkdownView({
    super.key,
    required this.content,
    this.pendingImagePaths = const <String, String>{},
  });

  final String content;
  final Map<String, String> pendingImagePaths;

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge,
      blockSpacing: 12,
      blockquote: theme.textTheme.bodyLarge,
      blockquotePadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
      ),
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      listBullet: theme.textTheme.bodyLarge,
    );

    return MarkdownBody(
      data: content,
      styleSheet: styleSheet,
      sizedImageBuilder: (config) => _buildImage(context, config.uri),
      onTapLink: (text, href, title) {
        // 링크 탭은 기본 렌더링만 제공하고 외부 앱 실행은 지원하지 않습니다.
      },
    );
  }

  Widget _buildImage(BuildContext context, Uri uri) {
    final padding = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: const AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(color: Colors.black12),
        ),
      ),
    );

    if (uri.scheme == 'pending') {
      final path = pendingImagePaths[uri.toString()];
      if (path == null || path.isEmpty) {
        return padding;
      }

      return _buildTappableImageFrame(
        context: context,
        onTap: () => _openFullscreenImage(
          context,
          Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _fullscreenPlaceholder(context),
          ),
        ),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => padding,
        ),
      );
    }

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return _buildTappableImageFrame(
        context: context,
        onTap: () => _openFullscreenImage(
          context,
          Image.network(
            uri.toString(),
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) =>
                _fullscreenPlaceholder(context),
          ),
        ),
        child: Image.network(
          uri.toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => padding,
        ),
      );
    }

    return padding;
  }

  Widget _buildTappableImageFrame({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(aspectRatio: 16 / 9, child: child),
        ),
      ),
    );
  }

  Future<void> _openFullscreenImage(BuildContext context, Widget image) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'fullscreen-image',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Center(child: image),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fullscreenPlaceholder(BuildContext context) {
    return Icon(
      Icons.broken_image_outlined,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      size: 40,
    );
  }
}
