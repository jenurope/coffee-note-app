import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<String> _versionFuture;
  bool _isWithdrawing = false;

  @override
  void initState() {
    super.initState();
    _versionFuture = _loadVersion();
  }

  Future<String> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> _handleWithdraw(BuildContext context) async {
    if (_isWithdrawing) {
      return;
    }

    final l10n = context.l10n;
    final warningConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.withdrawWarningTitle),
        content: Text(l10n.withdrawWarningBodyStrong),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.withdrawAccount),
          ),
        ],
      ),
    );

    if (warningConfirmed != true || !context.mounted) {
      return;
    }

    final finalConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.withdrawFinalConfirmTitle),
        content: Text(l10n.withdrawFinalConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.withdrawAccount),
          ),
        ],
      ),
    );

    if (finalConfirmed != true || !context.mounted) {
      return;
    }

    setState(() {
      _isWithdrawing = true;
    });

    try {
      await context.read<AuthCubit>().withdraw();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.withdrawCompleted)));
      context.go('/auth/login');
    } catch (e) {
      if (!context.mounted) return;
      final messageKey = UserErrorMessage.from(
        e,
        fallbackKey: 'withdrawFailed',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(UserErrorMessage.localize(context.l10n, messageKey)),
        ),
      );
    } finally {
      if (context.mounted) {
        setState(() {
          _isWithdrawing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final isGuest = authState is AuthGuest;

        // 게스트 모드일 때
        if (isGuest) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.profileScreenTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
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
                      l10n.guestProfileSubtitle,
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

        // 로그인하지 않은 경우
        if (currentUser == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.profileScreenTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashState) {
            final userProfile = dashState is DashboardLoaded
                ? dashState.userProfile
                : null;
            final rawName = currentUser.userMetadata?['name'];
            final metadataName = rawName is String ? rawName.trim() : '';
            final fallbackNickname = metadataName.isNotEmpty
                ? metadataName
                : l10n.userDefault;
            final displayNickname = userProfile?.nickname.isNotEmpty == true
                ? userProfile!.nickname
                : fallbackNickname;

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.profileScreenTitle),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.push('/profile/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.settingsPreparing)),
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 프로필 카드
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            UserAvatar(
                              nickname: displayNickname,
                              avatarUrl: userProfile?.avatarUrl,
                              radius: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              displayNickname,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentUser.email ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 메뉴
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _buildMenuTile(
                            context,
                            title: l10n.myPosts,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.preparing)),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildMenuTile(
                            context,
                            title: l10n.myComments,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.preparing)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 기타 메뉴
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _buildMenuTile(
                            context,
                            title: l10n.contactReport,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.contactReportPreparing),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildAppInfoTile(theme),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 로그아웃 버튼
                    CustomButton(
                      text: l10n.logout,
                      onPressed: _isWithdrawing
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.logoutConfirmTitle),
                                  content: Text(l10n.logoutConfirmContent),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(l10n.logout),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                await context.read<AuthCubit>().signOut();
                                if (context.mounted) {
                                  context.go('/auth/login');
                                }
                              }
                            },
                      isOutlined: true,
                      width: double.infinity,
                      textColor: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.error,
                    ),

                    const SizedBox(height: 24),

                    // 회원탈퇴 텍스트 액션
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: _isWithdrawing
                            ? null
                            : () => _handleWithdraw(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: theme.colorScheme.error.withValues(
                            alpha: 0.85,
                          ),
                        ),
                        child: Text(
                          l10n.withdrawAccount,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Widget _buildAppInfoTile(ThemeData theme) {
    return FutureBuilder<String>(
      future: _versionFuture,
      builder: (context, snapshot) {
        final versionText = snapshot.hasData
            ? context.l10n.versionLabel(snapshot.data!)
            : context.l10n.versionChecking;

        return ListTile(
          title: Text(context.l10n.appInfo),
          trailing: Text(
            versionText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        );
      },
    );
  }
}
