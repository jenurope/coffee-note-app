import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/community_post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = ref.read(communityServiceProvider);
      await service.createComment(CommunityComment(
        id: '',
        postId: widget.postId,
        userId: currentUser.id,
        content: _commentController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      _commentController.clear();
      ref.invalidate(communityPostDetailProvider(widget.postId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 등록되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
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
    final postAsync = ref.watch(communityPostDetailProvider(widget.postId));
    final currentUser = ref.watch(currentUserProvider);
    final isGuest = ref.watch(isGuestModeProvider);
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return postAsync.when(
      data: (post) {
        if (post == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('게시글을 찾을 수 없습니다.')),
          );
        }

        final isOwner = currentUser?.id == post.userId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('게시글'),
            actions: isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          context.push('/community/${widget.postId}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, ref),
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
                      // 작성자 정보
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                theme.colorScheme.primary.withValues(alpha: 0.1),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author?.nickname ?? '익명',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  dateFormat.format(post.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // 제목
                      Text(
                        post.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 내용
                      Text(
                        post.content,
                        style: theme.textTheme.bodyLarge,
                      ),

                      const Divider(height: 32),

                      // 댓글 섹션
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '댓글 ${post.comments?.length ?? 0}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 댓글 목록
                      if (post.comments != null && post.comments!.isNotEmpty)
                        ...post.comments!.map((comment) => _buildCommentTile(
                              context,
                              ref,
                              comment,
                              currentUser?.id == comment.userId,
                            ))
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              '아직 댓글이 없습니다.\n첫 번째 댓글을 남겨보세요!',
                              style: theme.textTheme.bodyMedium?.copyWith(
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

              // 댓글 입력
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
                            decoration: const InputDecoration(
                              hintText: '댓글을 입력하세요...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _isSubmitting ? null : _submitComment,
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
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다\n$error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTile(
    BuildContext context,
    WidgetRef ref,
    CommunityComment comment,
    bool isOwner,
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MM/dd HH:mm');

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
                  backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                  comment.author?.nickname ?? '익명',
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
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('삭제'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        try {
                          await ref
                              .read(communityServiceProvider)
                              .deleteComment(comment.id);
                          ref.invalidate(
                              communityPostDetailProvider(widget.postId));
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('삭제 실패: $e')),
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

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('이 게시글을 삭제하시겠습니까?\n댓글도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(communityServiceProvider).deletePost(widget.postId);
        ref.invalidate(communityPostsProvider);
        if (context.mounted) {
          context.go('/community');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }
}
