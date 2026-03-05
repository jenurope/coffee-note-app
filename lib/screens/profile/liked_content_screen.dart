import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';

class LikedContentScreen extends StatelessWidget {
  const LikedContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.likedContents)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildMenuTile(
                context,
                title: l10n.likedPosts,
                onTap: () => context.push('/profile/liked/posts'),
              ),
              const Divider(height: 1),
              _buildMenuTile(
                context,
                title: l10n.likedComments,
                onTap: () => context.push('/profile/liked/comments'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
