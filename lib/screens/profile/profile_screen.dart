import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/common/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final isGuest = ref.watch(isGuestModeProvider);
    final stats = ref.watch(dashboardStatsProvider);

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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: '로그인하기',
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).exitGuestMode();
                    context.go('/auth/login');
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '회원가입',
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).exitGuestMode();
                    context.push('/auth/signup');
                  },
                  isOutlined: true,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 설정 화면
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('설정 기능은 준비 중입니다.')));
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
                    // 아바타
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: userProfile.when(
                        data: (profile) => Text(
                          profile?.nickname.characters.first.toUpperCase() ??
                              '?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 닉네임
                    userProfile.when(
                      data: (profile) => Text(
                        profile?.nickname ?? '사용자',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const Text('사용자'),
                    ),
                    const SizedBox(height: 4),

                    // 이메일
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
            const SizedBox(height: 16),

            // 통계
            stats.when(
              data: (data) => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      icon: Icons.coffee,
                      label: '기록한 원두',
                      value: '${data.totalBeans}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      icon: Icons.local_cafe,
                      label: '커피 기록',
                      value: '${data.totalLogs}',
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 80),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // 메뉴
            Card(
              child: Column(
                children: [
                  _buildMenuTile(
                    context,
                    icon: Icons.coffee,
                    title: '내 원두 기록',
                    onTap: () => context.go('/beans'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    context,
                    icon: Icons.local_cafe,
                    title: '내 커피 기록',
                    onTap: () => context.go('/logs'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    context,
                    icon: Icons.forum,
                    title: '내 게시글',
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('준비 중입니다.')));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 기타 메뉴
            Card(
              child: Column(
                children: [
                  _buildMenuTile(
                    context,
                    icon: Icons.help,
                    title: '도움말',
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('준비 중입니다.')));
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    context,
                    icon: Icons.info,
                    title: '앱 정보',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: '나만의 커피 로그',
                        applicationVersion: '1.0.0',
                        applicationIcon: Icon(
                          Icons.coffee,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        children: [const Text('당신의 커피 여정을 기록하세요.')],
                      );
                    },
                  ),
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
                  await ref.read(authNotifierProvider.notifier).signOut();
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
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
