import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_detail_cubit.dart';
import '../../cubits/community/post_detail_state.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = getIt<CommunityService>();
      await service.createComment(
        CommunityComment(
          id: '',
          postId: widget.postId,
          userId: currentUser.id,
          content: _commentController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      _commentController.clear();
      if (mounted) {
        context.read<PostDetailCubit>().load(widget.postId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.commentCreated)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              UserErrorMessage.localize(
                context.l10n,
                UserErrorMessage.from(e, fallbackKey: 'commentCreateFailed'),
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    ).add_Hm();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final isGuest = authState is AuthGuest;

        return BlocBuilder<PostDetailCubit, PostDetailState>(
          builder: (context, postState) {
            return switch (postState) {
              PostDetailInitial() || PostDetailLoading() => Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()),
              ),
              PostDetailLoaded(post: final post) => () {
                final isOwner = currentUser?.id == post.userId;
                return Scaffold(
                  appBar: AppBar(
                    title: Text(l10n.postScreenTitle),
                    actions: isOwner
                        ? [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => context.push(
                                '/community/${widget.postId}/edit',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(context),
                            ),
                          ]
                        : null,
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      post.author?.nickname.characters.first
                                              .toUpperCase() ??
                                          '?',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.author?.nickname ??
                                              l10n.guestNickname,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Text(
                                          dateFormat.format(post.createdAt),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              Text(
                                post.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                post.content,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const Divider(height: 32),
                              Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.commentsCount(
                                      post.comments?.length ?? 0,
                                    ),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (post.comments != null &&
                                  post.comments!.isNotEmpty)
                                ...post.comments!.map(
                                  (comment) => _buildCommentTile(
                                    context,
                                    comment,
                                    currentUser?.id == comment.userId,
                                  ),
                                )
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      l10n.commentNone,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (currentUser != null && !isGuest)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: InputDecoration(
                                      hintText: l10n.commentHint,
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _submitComment,
                                  icon: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.send),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }(),
              PostDetailError(message: final message) => Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorOccurredWithMessage(
                          UserErrorMessage.localize(l10n, message),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            };
          },
        );
      },
    );
  }

  Widget _buildCommentTile(
    BuildContext context,
    CommunityComment comment,
    bool isOwner,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final dateFormat = DateFormat.Md(
      Localizations.localeOf(context).toString(),
    ).add_Hm();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    comment.author?.nickname.characters.first.toUpperCase() ??
                        '?',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.author?.nickname ?? l10n.guestNickname,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(comment.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(context.l10n.delete),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        try {
                          await getIt<CommunityService>().deleteComment(
                            comment.id,
                          );
                          if (context.mounted) {
                            context.read<PostDetailCubit>().load(widget.postId);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  UserErrorMessage.localize(
                                    context.l10n,
                                    UserErrorMessage.from(
                                      e,
                                      fallbackKey: 'commentDeleteFailed',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.postDeleteTitle),
        content: Text(context.l10n.postDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await getIt<CommunityService>().deletePost(widget.postId);
        if (context.mounted) {
          context.read<PostListCubit>().reload();
          context.go('/community');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.postDeleted)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                UserErrorMessage.localize(
                  context.l10n,
                  UserErrorMessage.from(e, fallbackKey: 'postDeleteFailed'),
                ),
              ),
            ),
          );
        }
      }
    }
  }
}
