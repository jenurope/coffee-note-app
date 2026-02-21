import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_filters.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../cubits/community/post_list_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/community_post.dart';
import 'post_markdown_utils.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/user_avatar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchController = TextEditingController();
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_onListScroll);
    final cubit = context.read<PostListCubit>();
    final authState = context.read<AuthCubit>().state;
    if (cubit.state is PostListInitial && authState is AuthAuthenticated) {
      cubit.load();
    }
  }

  @override
  void dispose() {
    _listScrollController
      ..removeListener(_onListScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onListScroll() {
    if (!_listScrollController.hasClients) return;
    final postState = context.read<PostListCubit>().state;
    if (postState is! PostListLoaded) return;
    if (!postState.hasMore || postState.isLoadingMore) return;
    if (_listScrollController.position.extentAfter < 300) {
      context.read<PostListCubit>().loadMore();
    }
  }

  void _search() {
    if (_listScrollController.hasClients) {
      _listScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    final cubit = context.read<PostListCubit>();
    final currentFilters = _currentFilters(cubit.state);
    cubit.updateFilters(currentFilters.copyWith(searchQuery: query));
  }

  void _showAll() {
    final cubit = context.read<PostListCubit>();
    final currentFilters = _currentFilters(cubit.state);
    final hasSearchQuery =
        (currentFilters.searchQuery?.trim().isNotEmpty ?? false);
    if (!hasSearchQuery) {
      return;
    }
    _searchController.clear();
    cubit.updateFilters(currentFilters.copyWith(searchQuery: null));
  }

  PostFilters _currentFilters(PostListState state) {
    return switch (state) {
      PostListLoaded(filters: final f) => f,
      PostListLoading(filters: final f) => f,
      PostListError(filters: final f) => f,
      _ => const PostFilters(),
    };
  }

  String _resolveAuthorName(AppLocalizations l10n, CommunityPost post) {
    final author = post.author;
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

  String _resolvePostSnippet(AppLocalizations l10n, CommunityPost post) {
    if (post.isWithdrawnContent) {
      return l10n.withdrawnPostMessage;
    }
    return markdownToPlainTextSnippet(post.content);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final dateFormat = DateFormat.Md(
      Localizations.localeOf(context).toString(),
    ).add_Hm();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final isGuest = authState is AuthGuest;

        if (isGuest) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.communityScreenTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.guestMode,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.communityGuestSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: l10n.loginNow,
                      onPressed: () {
                        context.read<AuthCubit>().exitGuestMode();
                        context.go('/auth/login');
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 로그인 필요 안내
        if (currentUser == null && !isGuest) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.communityScreenTitle)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.communityScreenTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.communityWelcomeSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: l10n.loginNow,
                    onPressed: () => context.go('/auth/login'),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocBuilder<PostListCubit, PostListState>(
          builder: (context, postState) {
            final currentFilters = _currentFilters(postState);
            final isSearchApplied =
                (currentFilters.searchQuery?.trim().isNotEmpty ?? false);

            return Scaffold(
              appBar: AppBar(title: Text(l10n.communityScreenTitle)),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _search(),
                            decoration: InputDecoration(
                              hintText: l10n.postSearchHint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, value, _) {
                            final hasQuery = value.text.trim().isNotEmpty;
                            return SizedBox(
                              width: 56,
                              height: 56,
                              child: FilledButton(
                                onPressed: hasQuery ? _search : null,
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Icon(Icons.search),
                              ),
                            );
                          },
                        ),
                        if (isSearchApplied) ...[
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: _showAll,
                            child: Text(l10n.showAll),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: switch (postState) {
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
                                buttonText: currentUser != null
                                    ? l10n.writePost
                                    : null,
                                onButtonPressed: currentUser != null
                                    ? () => context.push('/community/new')
                                    : null,
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    context.read<PostListCubit>().reload(),
                                child: ListView.builder(
                                  controller: _listScrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
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
                                                    Icons
                                                        .expand_circle_down_outlined,
                                                  ),
                                                  tooltip:
                                                      MaterialLocalizations.of(
                                                        context,
                                                      ).moreButtonTooltip,
                                                ),
                                        ),
                                      );
                                    }
                                    final post = posts[index];
                                    final authorName = _resolveAuthorName(
                                      l10n,
                                      post,
                                    );
                                    final postTitle = _resolvePostTitle(
                                      l10n,
                                      post,
                                    );
                                    final postSnippet = _resolvePostSnippet(
                                      l10n,
                                      post,
                                    );
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        onTap: () => context.push(
                                          '/community/${post.id}',
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  UserAvatar(
                                                    nickname: authorName,
                                                    avatarUrl:
                                                        post.author?.avatarUrl,
                                                    radius: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      authorName,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                  Text(
                                                    dateFormat.format(
                                                      post.createdAt,
                                                    ),
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                postTitle,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                postSnippet,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.7,
                                                          ),
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (post.commentCount != null &&
                                                  post.commentCount! > 0) ...[
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.chat_bubble_outline,
                                                      size: 16,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      l10n.commentsCount(
                                                        post.commentCount!,
                                                      ),
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: theme
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                            const SizedBox(height: 16),
                            Text(
                              l10n.errorOccurredWithMessage(
                                UserErrorMessage.localize(l10n, message),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: l10n.retry,
                              onPressed: () =>
                                  context.read<PostListCubit>().reload(),
                            ),
                          ],
                        ),
                      ),
                    },
                  ),
                ],
              ),
              floatingActionButton: currentUser != null && !isGuest
                  ? FloatingActionButton(
                      onPressed: () => context.push('/community/new'),
                      child: const Icon(Icons.edit),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
