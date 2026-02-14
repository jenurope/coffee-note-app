import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_filters.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../cubits/community/post_list_state.dart';
import '../../widgets/common/common_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PostListCubit>();
    if (cubit.state is PostListInitial) {
      cubit.load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final cubit = context.read<PostListCubit>();
    final currentFilters = switch (cubit.state) {
      PostListLoaded(filters: final f) => f,
      PostListLoading(filters: final f) => f,
      PostListError(filters: final f) => f,
      _ => const PostFilters(),
    };
    cubit.updateFilters(
      currentFilters.copyWith(searchQuery: _searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MM/dd HH:mm');

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final isGuest = authState is AuthGuest;

        // 로그인 필요 안내
        if (currentUser == null && !isGuest) {
          return Scaffold(
            appBar: AppBar(title: const Text('커뮤니티')),
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
                    '커뮤니티',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '다른 커피 애호가들과\n이야기를 나눠보세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: '로그인하기',
                    onPressed: () => context.go('/auth/login'),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocBuilder<PostListCubit, PostListState>(
          builder: (context, postState) {
            return Scaffold(
              appBar: AppBar(title: const Text('커뮤니티')),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: '게시글 검색...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _search();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: switch (postState) {
                      PostListInitial() || PostListLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      PostListLoaded(posts: final posts) =>
                        posts.isEmpty
                            ? EmptyState(
                                icon: Icons.forum_outlined,
                                title: '게시글이 없습니다',
                                subtitle: '첫 번째 게시글을 작성해보세요!',
                                buttonText: currentUser != null
                                    ? '글 작성하기'
                                    : null,
                                onButtonPressed: currentUser != null
                                    ? () => context.push('/community/new')
                                    : null,
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    context.read<PostListCubit>().reload(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    final post = posts[index];
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
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor: theme
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.1),
                                                    child: Text(
                                                      post
                                                              .author
                                                              ?.nickname
                                                              .characters
                                                              .first
                                                              .toUpperCase() ??
                                                          '?',
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      post.author?.nickname ??
                                                          '익명',
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
                                                post.title,
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
                                                post.content,
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
                                                      '댓글 ${post.commentCount}',
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
                            Text('오류가 발생했습니다\n$message'),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: '다시 시도',
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
