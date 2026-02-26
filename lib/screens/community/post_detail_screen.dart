import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_detail_cubit.dart';
import '../../cubits/community/post_detail_state.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/community_post.dart';
import '../../models/user_profile.dart';
import '../../services/community_service.dart';
import 'widgets/post_markdown_view.dart';
import '../../widgets/common/user_avatar.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

enum _ReportTargetType { post, comment }

class _PostDetailScreenState extends State<PostDetailScreen> {
  static const int _maxReportReasonLength = 500;
  static const Key _postReportButtonKey = Key('postReportButton');
  static const Key _reportReasonFieldKey = Key('reportReasonField');
  static const String _replyActionButtonKeyPrefix = 'replyActionButton';
  final _commentController = TextEditingController();
  final _detailScrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _detailScrollController.addListener(_onDetailScroll);
  }

  @override
  void dispose() {
    _detailScrollController
      ..removeListener(_onDetailScroll)
      ..dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onDetailScroll() {
    if (!_detailScrollController.hasClients) return;
    final postState = context.read<PostDetailCubit>().state;
    if (postState is! PostDetailLoaded) return;
    if (!postState.hasMoreComments || postState.isLoadingMoreComments) {
      return;
    }
    if (_detailScrollController.position.extentAfter < 260) {
      context.read<PostDetailCubit>().loadMoreComments();
    }
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
        _reloadPostList();
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

  String _resolveAuthorName(AppLocalizations l10n, UserProfile? author) {
    if (author == null) {
      return l10n.guestNickname;
    }
    if (author.isWithdrawn) {
      return l10n.withdrawnUser;
    }
    return author.nickname;
  }

  String _resolvePostTitle(AppLocalizations l10n, CommunityPost post) {
    if (post.isWithdrawnContent) {
      return l10n.withdrawnPostMessage;
    }
    return post.title;
  }

  String _resolvePostContent(AppLocalizations l10n, CommunityPost post) {
    if (post.isWithdrawnContent) {
      return '';
    }
    return post.content;
  }

  void _reloadPostList() {
    try {
      context.read<PostListCubit>().reload();
    } catch (_) {
      // 목록 Cubit이 없는 컨텍스트(예: 딥링크 단독 진입)에서는 무시합니다.
    }
  }

  String _resolveCommentContent(
    AppLocalizations l10n,
    CommunityComment comment,
  ) {
    if (comment.isWithdrawnContent) {
      return l10n.withdrawnCommentMessage;
    }
    return comment.content;
  }

  bool _isDeletedCommentPlaceholder(CommunityComment comment) {
    return comment.isDeletedContent && !comment.isWithdrawnContent;
  }

  Future<void> _openReportDialog({
    required _ReportTargetType targetType,
    required String targetId,
  }) async {
    final reason = await _showReportReasonDialog(
      context,
      targetType: targetType,
    );
    if (!mounted || reason == null) return;

    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    try {
      final service = getIt<CommunityService>();
      if (targetType == _ReportTargetType.post) {
        await service.reportPost(
          postId: targetId,
          userId: currentUser.id,
          reason: reason,
        );
      } else {
        await service.reportComment(
          commentId: targetId,
          userId: currentUser.id,
          reason: reason,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reportSubmitSuccess)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_reportFailureMessage(context, e))),
      );
    }
  }

  Future<String?> _showReportReasonDialog(
    BuildContext context, {
    required _ReportTargetType targetType,
  }) async {
    final reasonController = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                targetType == _ReportTargetType.post
                    ? context.l10n.reportPostTitle
                    : context.l10n.reportCommentTitle,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: TextField(
                  key: _reportReasonFieldKey,
                  controller: reasonController,
                  maxLines: 4,
                  maxLength: _maxReportReasonLength,
                  decoration: InputDecoration(
                    hintText: context.l10n.reportReasonHint,
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                  ),
                  onChanged: (_) {
                    if (errorText != null) {
                      setDialogState(() {
                        errorText = null;
                      });
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      setDialogState(() {
                        errorText = context.l10n.reportReasonRequired;
                      });
                      return;
                    }
                    Navigator.pop(dialogContext, reason);
                  },
                  child: Text(context.l10n.reportSubmitAction),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _reportFailureMessage(BuildContext context, Object error) {
    if (error is FormatException) {
      return switch (error.message) {
        'report_reason_required' => context.l10n.reportReasonRequired,
        'report_reason_too_long' => context.l10n.reportReasonTooLong,
        _ => context.l10n.reportSubmitFailed,
      };
    }

    if (error is PostgrestException && error.code == '23505') {
      return context.l10n.reportDuplicate;
    }

    return context.l10n.reportSubmitFailed;
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
              PostDetailLoaded(
                post: final post,
                isLoadingMoreComments: final isLoadingMoreComments,
                hasMoreComments: final hasMoreComments,
              ) =>
                () {
                  final allComments =
                      post.comments ?? const <CommunityComment>[];
                  final visibleComments = allComments
                      .where((comment) => comment.parentId == null)
                      .toList(growable: false);
                  final replyCountByParentId = <String, int>{};
                  for (final comment in allComments) {
                    final parentId = comment.parentId;
                    if (parentId == null) continue;
                    replyCountByParentId[parentId] =
                        (replyCountByParentId[parentId] ?? 0) + 1;
                  }
                  final isOwner = currentUser?.id == post.userId;
                  final canReportPost =
                      !isOwner &&
                      currentUser != null &&
                      !isGuest &&
                      !post.isWithdrawnContent;
                  final appBarActions = <Widget>[
                    if (isOwner) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final updated = await context.push<bool>(
                            '/community/${widget.postId}/edit',
                          );
                          if (!context.mounted) return;
                          if (updated == true) {
                            context.read<PostDetailCubit>().load(widget.postId);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ],
                    if (canReportPost)
                      IconButton(
                        key: _postReportButtonKey,
                        icon: const Icon(Icons.flag_outlined),
                        tooltip: l10n.reportAction,
                        onPressed: () => _openReportDialog(
                          targetType: _ReportTargetType.post,
                          targetId: post.id,
                        ),
                      ),
                  ];
                  final authorName = _resolveAuthorName(l10n, post.author);
                  final postTitle = _resolvePostTitle(l10n, post);
                  final postContent = _resolvePostContent(l10n, post);
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(l10n.postScreenTitle),
                      actions: appBarActions.isEmpty ? null : appBarActions,
                    ),
                    body: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _detailScrollController,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    UserAvatar(
                                      nickname: authorName,
                                      avatarUrl: post.author?.avatarUrl,
                                      radius: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            authorName,
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
                                  postTitle,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                if (postContent.isNotEmpty)
                                  PostMarkdownView(content: postContent),
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
                                        post.commentCount ??
                                            post.comments?.length ??
                                            0,
                                      ),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (visibleComments.isNotEmpty)
                                  ...visibleComments.map((comment) {
                                    final canReply =
                                        currentUser != null &&
                                        !isGuest &&
                                        comment.parentId == null &&
                                        !comment.isDeletedContent &&
                                        !comment.isWithdrawnContent;
                                    return _buildCommentTile(
                                      context,
                                      comment,
                                      currentUser?.id == comment.userId,
                                      currentUser != null &&
                                          !isGuest &&
                                          currentUser.id != comment.userId &&
                                          !comment.isDeletedContent &&
                                          !comment.isWithdrawnContent,
                                      canReply: canReply,
                                      isReply: false,
                                      replyCount:
                                          replyCountByParentId[comment.id] ?? 0,
                                    );
                                  })
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
                                if (hasMoreComments || isLoadingMoreComments)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Center(
                                      child: isLoadingMoreComments
                                          ? const CircularProgressIndicator()
                                          : IconButton(
                                              onPressed: () => context
                                                  .read<PostDetailCubit>()
                                                  .loadMoreComments(),
                                              icon: const Icon(
                                                Icons
                                                    .expand_circle_down_outlined,
                                              ),
                                              tooltip: MaterialLocalizations.of(
                                                context,
                                              ).moreButtonTooltip,
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
    bool canReport, {
    required bool canReply,
    required bool isReply,
    required int replyCount,
  }) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cardMargin = EdgeInsets.only(left: isReply ? 24 : 0, bottom: 8);

    if (_isDeletedCommentPlaceholder(comment)) {
      return SizedBox(
        width: double.infinity,
        child: Card(
          margin: cardMargin,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Text(
              l10n.deletedCommentMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat.Md(
      Localizations.localeOf(context).toString(),
    ).add_Hm();
    final authorName = _resolveAuthorName(l10n, comment.author);
    final commentContent = _resolveCommentContent(l10n, comment);
    final replyActionLabel = replyCount > 0
        ? '${l10n.replyAction} ($replyCount)'
        : l10n.replyAction;

    return Card(
      margin: cardMargin,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  nickname: authorName,
                  avatarUrl: comment.author?.avatarUrl,
                  radius: 14,
                  backgroundColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.1,
                  ),
                  foregroundColor: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  authorName,
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
                if ((isOwner || canReport) &&
                    !comment.isDeletedContent &&
                    !comment.isWithdrawnContent)
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: isOwner ? 'delete' : 'report',
                        child: Text(
                          isOwner
                              ? context.l10n.delete
                              : context.l10n.reportAction,
                        ),
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
                            _reloadPostList();
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
                      } else if (value == 'report') {
                        await _openReportDialog(
                          targetType: _ReportTargetType.comment,
                          targetId: comment.id,
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(commentContent),
            if (canReply)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    key: ValueKey('$_replyActionButtonKeyPrefix-${comment.id}'),
                    onPressed: () =>
                        context.push(_commentDetailPath(context, comment)),
                    icon: const Icon(Icons.reply_outlined, size: 18),
                    label: Text(replyActionLabel),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(88, 30),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _commentDetailPath(BuildContext context, CommunityComment comment) {
    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath.startsWith('/profile/posts/')) {
      return '/profile/posts/${comment.postId}/comments/${comment.id}';
    }
    if (currentPath.startsWith('/profile/comments/')) {
      return '/profile/comments/${comment.postId}/comments/${comment.id}';
    }
    return '/community/${comment.postId}/comments/${comment.id}';
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
