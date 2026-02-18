import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../widgets/common/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<String> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = _loadVersion();
  }

  Future<String> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final isGuest = authState is AuthGuest;

        // 게스트 모드일 때
        if (isGuest) {
          return Scaffold(
            appBar: AppBar(title: const Text('프로필')),
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
                      '게스트 모드',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '로그인하면 더 많은 기능을 사용할 수 있습니다',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: '로그인하기',
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
            appBar: AppBar(title: const Text('프로필')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashState) {
            final userProfile = dashState is DashboardLoaded
                ? dashState.userProfile
                : null;

            return Scaffold(
              appBar: AppBar(
                title: const Text('프로필'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('설정 기능은 준비 중입니다.')),
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
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              child: Text(
                                userProfile?.nickname.characters.first
                                        .toUpperCase() ??
                                    '?',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userProfile?.nickname ?? '사용자',
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
                            title: '내 게시글',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('준비 중입니다.')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildMenuTile(
                            context,
                            title: '내 댓글',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('준비 중입니다.')),
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
                            title: '문의/제보하기',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('문의/제보 기능은 준비 중입니다.'),
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
                      text: '로그아웃',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('로그아웃'),
                            content: const Text('로그아웃 하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('로그아웃'),
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
            ? '버전 ${snapshot.data}'
            : '버전 확인 중...';

        return ListTile(
          title: const Text('앱 정보'),
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
