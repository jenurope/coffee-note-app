import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../cubits/community/post_list_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/community_post.dart';
import '../../widgets/common/common_widgets.dart';
import '../community/post_markdown_utils.dart';

class MyPostListScreen extends StatefulWidget {
  const MyPostListScreen({super.key});

  @override
  State<MyPostListScreen> createState() => _MyPostListScreenState();
}

class _MyPostListScreenState extends State<MyPostListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onListScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onListScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<PostListCubit>().loadForUser(authState.user.id);
    }
  }

  void _onListScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final state = context.read<PostListCubit>().state;
    if (state is! PostListLoaded) {
      return;
    }
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }
    if (_scrollController.position.extentAfter < 300) {
      context.read<PostListCubit>().loadMore();
    }
  }

  String _resolvePostTitle(AppLocalizations l10n, CommunityPost post) {
    if (post.isWithdrawnContent) {
      return l10n.withdrawnPostMessage;
    }
    return post.title;
  }

  String _resolvePostSnippet(CommunityPost post) {
    if (post.isWithdrawnContent) {
      return '';
    }
    return markdownToPlainTextSnippet(post.content);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.Md(
      Localizations.localeOf(context).toString(),
    ).add_Hm();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.myPosts)),
            body: EmptyState(
              icon: Icons.lock_outline,
              title: l10n.requiredLogin,
              subtitle: l10n.communityGuestSubtitle,
              buttonText: l10n.loginNow,
              onButtonPressed: () {
                context.read<AuthCubit>().exitGuestMode();
                context.go('/auth/login');
              },
            ),
          );
        }

        return BlocBuilder<PostListCubit, PostListState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.myPosts)),
              body: switch (state) {
                PostListInitial() || PostListLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                PostListLoaded(
                  posts: final posts,
                  isLoadingMore: final isLoadingMore,
                  hasMore: final hasMore,
                ) =>
                  posts.isEmpty
                      ? EmptyState(
                          icon: Icons.forum_outlined,
                          title: l10n.postsEmptyTitle,
                          subtitle: l10n.postsEmptySubtitle,
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              context.read<PostListCubit>().reload(),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: posts.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= posts.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: isLoadingMore
                                        ? const CircularProgressIndicator()
                                        : IconButton(
                                            onPressed: () => context
                                                .read<PostListCubit>()
                                                .loadMore(),
                                            icon: const Icon(
                                              Icons.expand_circle_down_outlined,
                                            ),
                                            tooltip: MaterialLocalizations.of(
                                              context,
                                            ).moreButtonTooltip,
                                          ),
                                  ),
                                );
                              }

                              final post = posts[index];
                              final postTitle = _resolvePostTitle(l10n, post);
                              final postSnippet = _resolvePostSnippet(post);
                              final commentCount = post.commentCount ?? 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () =>
                                      context.push('/profile/posts/${post.id}'),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          postTitle,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (postSnippet.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            postSnippet,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.7),
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Text(
                                              dateFormat.format(post.createdAt),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                            const Spacer(),
                                            if (commentCount > 0)
                                              Text(
                                                l10n.commentsCount(
                                                  commentCount,
                                                ),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                PostListError(message: final message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        l10n.errorOccurredWithMessage(
                          UserErrorMessage.localize(l10n, message),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: l10n.retry,
                        onPressed: () => context.read<PostListCubit>().reload(),
                      ),
                    ],
                  ),
                ),
              },
            );
          },
        );
      },
    );
  }
}
