import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/my_comment_list_cubit.dart';
import '../../cubits/community/my_comment_list_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/community_post.dart';
import '../../widgets/common/common_widgets.dart';

class MyCommentListScreen extends StatefulWidget {
  const MyCommentListScreen({super.key});

  @override
  State<MyCommentListScreen> createState() => _MyCommentListScreenState();
}

class _MyCommentListScreenState extends State<MyCommentListScreen> {
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
      context.read<MyCommentListCubit>().loadForUser(authState.user.id);
    }
  }

  void _onListScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final state = context.read<MyCommentListCubit>().state;
    if (state is! MyCommentListLoaded) {
      return;
    }
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }
    if (_scrollController.position.extentAfter < 300) {
      context.read<MyCommentListCubit>().loadMore();
    }
  }

  String _resolveCommentContent(
    AppLocalizations l10n,
    CommunityComment comment,
  ) {
    if (comment.isWithdrawnContent) {
      return l10n.withdrawnCommentMessage;
    }
    if (comment.isDeletedContent) {
      return l10n.deletedCommentMessage;
    }
    return comment.content;
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
            appBar: AppBar(title: Text(l10n.myComments)),
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

        return BlocBuilder<MyCommentListCubit, MyCommentListState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.myComments)),
              body: switch (state) {
                MyCommentListInitial() || MyCommentListLoading() =>
                  const Center(child: CircularProgressIndicator()),
                MyCommentListLoaded(
                  comments: final comments,
                  isLoadingMore: final isLoadingMore,
                  hasMore: final hasMore,
                ) =>
                  comments.isEmpty
                      ? EmptyState(
                          icon: Icons.chat_bubble_outline,
                          title: l10n.commentNone,
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              context.read<MyCommentListCubit>().reload(),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: comments.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= comments.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: isLoadingMore
                                        ? const CircularProgressIndicator()
                                        : IconButton(
                                            onPressed: () => context
                                                .read<MyCommentListCubit>()
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

                              final comment = comments[index];
                              final commentContent = _resolveCommentContent(
                                l10n,
                                comment,
                              );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => context.push(
                                    '/profile/comments/${comment.postId}',
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            commentContent,
                                            style: theme.textTheme.bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          dateFormat.format(comment.createdAt),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                MyCommentListError(message: final message) => Center(
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
                        onPressed: () =>
                            context.read<MyCommentListCubit>().reload(),
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
