import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/l10n.dart';

/// 이미지 소스 선택 바텀시트
class ImagePickerBottomSheet extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback? onDeleteTap;

  const ImagePickerBottomSheet({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
    this.onDeleteTap,
  });

  static Future<ImageSource?> show(
    BuildContext context, {
    bool showDelete = false,
  }) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                context.l10n.photoSelectTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    label: context.l10n.gallery,
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    label: context.l10n.camera,
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  if (showDelete)
                    _buildOption(
                      context,
                      icon: Icons.delete,
                      label: context.l10n.photoDelete,
                      onTap: () => Navigator.pop(context, null),
                      color: Theme.of(context).colorScheme.error,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: effectiveColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.l10n.pickFromGallery),
              onTap: onGalleryTap,
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.l10n.takeFromCamera),
              onTap: onCameraTap,
            ),
            if (onDeleteTap != null)
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  context.l10n.photoDeleteMenu,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: onDeleteTap,
              ),
          ],
        ),
      ),
    );
  }
}

/// 이미지 선택 및 미리보기 위젯
class ImagePickerWidget extends StatelessWidget {
  final String? imageUrl;
  final String? localImagePath;
  final VoidCallback onTap;
  final double height;
  final IconData placeholderIcon;

  const ImagePickerWidget({
    super.key,
    this.imageUrl,
    this.localImagePath,
    required this.onTap,
    this.height = 200,
    this.placeholderIcon = Icons.add_a_photo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl != null || localImagePath != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
            style: hasImage ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    if (localImagePath != null)
                      Image.asset(
                        localImagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) =>
                            _buildPlaceholder(context, theme),
                      )
                    else if (imageUrl != null)
                      Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, error, stackTrace) =>
                            _buildPlaceholder(context, theme),
                      ),
                    // 변경 오버레이
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.photoChange,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : _buildPlaceholder(context, theme),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          placeholderIcon,
          size: 48,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.photoAdd,
          style: TextStyle(
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
