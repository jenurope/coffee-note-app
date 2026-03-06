import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../l10n/l10n.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/common_widgets.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isBeanRecordsEnabled = true;
  bool _isCoffeeRecordsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;

    if (currentUser == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitialized = true;
      });
      return;
    }

    UserProfile? profile;
    final dashboardState = context.read<DashboardCubit>().state;
    if (dashboardState is DashboardLoaded) {
      profile = dashboardState.userProfile;
    }
    profile ??= await getIt<AuthService>().getProfile(currentUser.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isBeanRecordsEnabled = profile?.isBeanRecordsEnabled ?? true;
      _isCoffeeRecordsEnabled = profile?.isCoffeeRecordsEnabled ?? true;
      _isInitialized = true;
    });
  }

  Future<void> _saveSettings() async {
    if (_isSaving) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await getIt<AuthService>().updateFeatureVisibilitySettings(
        userId: currentUser.id,
        isBeanRecordsEnabled: _isBeanRecordsEnabled,
        isCoffeeRecordsEnabled: _isCoffeeRecordsEnabled,
      );

      if (!mounted) {
        return;
      }

      await context.read<DashboardCubit>().refresh();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileSettingsSaveSuccess)),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileSettingsSaveFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final allDisabled = !_isBeanRecordsEnabled && !_isCoffeeRecordsEnabled;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileSettingsTitle)),
      body: LoadingOverlay(
        isLoading: _isSaving,
        child: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.profileSettingsSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            title: Text(l10n.profileSettingsBeanTitle),
                            subtitle: Text(l10n.profileSettingsBeanSubtitle),
                            value: _isBeanRecordsEnabled,
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      _isBeanRecordsEnabled = value;
                                    });
                                  },
                          ),
                          const Divider(height: 1),
                          SwitchListTile.adaptive(
                            title: Text(l10n.profileSettingsCoffeeTitle),
                            subtitle: Text(l10n.profileSettingsCoffeeSubtitle),
                            value: _isCoffeeRecordsEnabled,
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      _isCoffeeRecordsEnabled = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                    if (allDisabled) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.profileSettingsEmptyState,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      text: l10n.save,
                      onPressed: _isSaving ? null : _saveSettings,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
