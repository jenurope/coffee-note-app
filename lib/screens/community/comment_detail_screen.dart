import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/community_post.dart';
import '../../models/user_profile.dart';
import '../../services/community_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/user_avatar.dart';

class CommentDetailScreen extends StatefulWidget {
  final String postId;
  final String commentId;

  const CommentDetailScreen({
    super.key,
    required this.postId,
    required this.commentId,
  });

  @override
  State<CommentDetailScreen> createState() => _CommentDetailScreenState();
}

class _CommentDetailScreenState extends State<CommentDetailScreen> {
  static const int _defaultReplyPageSize = 20;
  static const int _maxReportReasonLength = 500;
  static const Key _reportReasonFieldKey = Key('reportReasonField');

  final _replyController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isLoadingMore = false;
  bool _hasMoreReplies = true;
  String? _errorMessageKey;

  CommunityComment? _parentComment;
  List<CommunityComment> _replies = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_hasMoreReplies || _isLoadingMore) {
      return;
    }
    if (_scrollController.position.extentAfter < 260) {
      _loadMoreReplies();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessageKey = null;
    });

    try {
      final service = getIt<CommunityService>();
      final parent = await service.getCommentById(commentId: widget.commentId);
      if (parent == null || parent.postId != widget.postId) {
        setState(() {
          _isLoading = false;
          _errorMessageKey = 'errNotFound';
        });
        return;
      }

      final replies = await service.getReplies(
        parentCommentId: widget.commentId,
        limit: _defaultReplyPageSize,
        offset: 0,
        ascending: true,
      );

      setState(() {
        _parentComment = parent;
        _replies = replies;
        _hasMoreReplies = replies.length == _defaultReplyPageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessageKey = UserErrorMessage.from(
          e,
          fallbackKey: 'errLoadPostDetail',
        );
      });
    }
  }

  Future<void> _loadMoreReplies() async {
    if (_isLoadingMore || !_hasMoreReplies) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final service = getIt<CommunityService>();
      final nextReplies = await service.getReplies(
        parentCommentId: widget.commentId,
        limit: _defaultReplyPageSize,
        offset: _replies.length,
        ascending: true,
      );

      setState(() {
        _replies = [..._replies, ...nextReplies];
        _hasMoreReplies = nextReplies.length == _defaultReplyPageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _submitReply() async {
    final parent = _parentComment;
    if (parent == null) return;
    if (!_canReply(parent)) return;
    if (_replyController.text.trim().isEmpty) return;

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
          content: _replyController.text.trim(),
          parentId: widget.commentId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _replyController.clear();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.commentCreated)));
    } catch (e) {
      if (!mounted) return;
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _canReply(CommunityComment parent) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return false;
    if (authState is AuthGuest) return false;
    if (parent.parentId != null) return false;
    if (parent.isDeletedContent) return false;
    if (parent.isWithdrawnContent) return false;
    return true;
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final service = getIt<CommunityService>();
      await service.deleteComment(commentId);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UserErrorMessage.localize(
              context.l10n,
              UserErrorMessage.from(e, fallbackKey: 'commentDeleteFailed'),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openReportDialog({required String commentId}) async {
    final reason = await _showReportReasonDialog(context);
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
      await service.reportComment(
        commentId: commentId,
        userId: currentUser.id,
        reason: reason,
      );

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

  Future<String?> _showReportReasonDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.reportCommentTitle),
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

  String _resolveAuthorName(AppLocalizations l10n, UserProfile? author) {
    if (author == null) {
      return l10n.guestNickname;
    }
    if (author.isWithdrawn) {
      return l10n.withdrawnUser;
    }
    return author.nickname;
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

  Widget _buildCommentCard(
    BuildContext context,
    CommunityComment comment, {
    bool isReply = false,
  }) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final margin = EdgeInsets.only(left: isReply ? 20 : 0, bottom: 8);
    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    final isGuest = authState is AuthGuest;
    final isOwner = currentUser?.id == comment.userId;
    final canReport = currentUser != null && !isGuest && !isOwner;
    final showActionMenu =
        (isOwner || canReport) &&
        !comment.isDeletedContent &&
        !comment.isWithdrawnContent;

    if (_isDeletedCommentPlaceholder(comment)) {
      return Card(
        margin: margin,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(
            l10n.deletedCommentMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat.Md(
      Localizations.localeOf(context).toString(),
    ).add_Hm();
    final authorName = _resolveAuthorName(l10n, comment.author);
    final content = _resolveCommentContent(l10n, comment);

    return Card(
      margin: margin,
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
                Expanded(
                  child: Text(
                    authorName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(comment.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (showActionMenu)
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
                        await _deleteComment(comment.id);
                      } else if (value == 'report') {
                        await _openReportDialog(commentId: comment.id);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final parent = _parentComment;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.commentDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessageKey != null || parent == null) {
      final messageKey = _errorMessageKey ?? 'errNotFound';
      return Scaffold(
        appBar: AppBar(title: Text(l10n.commentDetailTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                l10n.errorOccurredWithMessage(
                  UserErrorMessage.localize(l10n, messageKey),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomButton(text: l10n.retry, onPressed: _load),
            ],
          ),
        ),
      );
    }

    final canReply =
        authState is AuthAuthenticated &&
        authState is! AuthGuest &&
        _canReply(parent);
    final visibleReplyCount = _replies
        .where((reply) => !reply.isDeletedContent)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commentDetailTitle)),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommentCard(context, parent),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.reply_all_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.commentsCount(visibleReplyCount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_replies.isNotEmpty)
                      ..._replies.map(
                        (reply) =>
                            _buildCommentCard(context, reply, isReply: true),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            l10n.commentNone,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_hasMoreReplies || _isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: _isLoadingMore
                              ? const CircularProgressIndicator()
                              : IconButton(
                                  onPressed: _loadMoreReplies,
                                  icon: const Icon(
                                    Icons.expand_circle_down_outlined,
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
          ),
          if (canReply)
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
                        controller: _replyController,
                        decoration: InputDecoration(
                          hintText: l10n.replyHint,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isSubmitting ? null : _submitReply,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
  }
}
