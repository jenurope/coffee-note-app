import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/service_locator.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../l10n/l10n.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/user_avatar.dart';

enum _ProfileImageAction { gallery, camera, delete, cancel }

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;

  String? _initialAvatarUrl;
  String? _existingAvatarUrl;
  XFile? _selectedAvatar;
  bool _markAvatarDeleted = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      return;
    }

    UserProfile? profile;
    final dashboardState = context.read<DashboardCubit>().state;
    if (dashboardState is DashboardLoaded) {
      profile = dashboardState.userProfile;
    }
    profile ??= await getIt<AuthService>().getProfile(currentUser.id);

    if (!mounted) return;

    final rawName = currentUser.userMetadata?['name'];
    final metadataName = rawName is String ? rawName.trim() : '';
    final fallbackNickname = metadataName.isNotEmpty ? metadataName : 'user';
    final nickname = (profile?.nickname.trim().isNotEmpty ?? false)
        ? profile!.nickname
        : fallbackNickname;

    setState(() {
      _nicknameController.text = nickname;
      _initialAvatarUrl = profile?.avatarUrl;
      _existingAvatarUrl = profile?.avatarUrl;
      _isInitialized = true;
    });
  }

  Future<_ProfileImageAction> _showImageActionSheet() async {
    final hasAvatar =
        _selectedAvatar != null ||
        (!_markAvatarDeleted &&
            _existingAvatarUrl != null &&
            _existingAvatarUrl!.isNotEmpty);

    final result = await showModalBottomSheet<_ProfileImageAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = context.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(l10n.pickFromGallery),
                  onTap: () =>
                      Navigator.pop(context, _ProfileImageAction.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(l10n.takeFromCamera),
                  onTap: () =>
                      Navigator.pop(context, _ProfileImageAction.camera),
                ),
                if (hasAvatar)
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      l10n.photoDeleteMenu,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: () =>
                        Navigator.pop(context, _ProfileImageAction.delete),
                  ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(l10n.cancel),
                  onTap: () =>
                      Navigator.pop(context, _ProfileImageAction.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? _ProfileImageAction.cancel;
  }

  Future<void> _onAvatarTap() async {
    final imageService = getIt<ImageUploadService>();
    final action = await _showImageActionSheet();

    switch (action) {
      case _ProfileImageAction.gallery:
        final picked = await imageService.pickImageFromGallery();
        if (picked == null || !mounted) return;
        setState(() {
          _selectedAvatar = picked;
          _markAvatarDeleted = false;
        });
        return;
      case _ProfileImageAction.camera:
        final picked = await imageService.pickImageFromCamera();
        if (picked == null || !mounted) return;
        setState(() {
          _selectedAvatar = picked;
          _markAvatarDeleted = false;
        });
        return;
      case _ProfileImageAction.delete:
        setState(() {
          _selectedAvatar = null;
          _existingAvatarUrl = null;
          _markAvatarDeleted = true;
        });
        return;
      case _ProfileImageAction.cancel:
        return;
    }
  }

  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';

    if (nickname.isEmpty) {
      return context.l10n.profileEditNicknameRequired;
    }

    if (nickname.length < 2 || nickname.length > 20) {
      return context.l10n.profileEditNicknameLength;
    }

    return null;
  }

  Future<void> _rollbackUploadedAvatar(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      await getIt<ImageUploadService>().deleteImage(
        bucket: 'avatars',
        imageUrl: imageUrl,
      );
    } catch (_) {
      // best-effort rollback
    }
  }

  Future<void> _cleanupOldAvatar({
    required String? previousAvatarUrl,
    required String? nextAvatarUrl,
  }) async {
    if (previousAvatarUrl == null || previousAvatarUrl.isEmpty) return;
    if (previousAvatarUrl == nextAvatarUrl) return;

    try {
      await getIt<ImageUploadService>().deleteImage(
        bucket: 'avatars',
        imageUrl: previousAvatarUrl,
      );
    } catch (_) {
      // best-effort cleanup
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    final authService = getIt<AuthService>();
    final imageService = getIt<ImageUploadService>();

    setState(() {
      _isLoading = true;
    });

    String? uploadedAvatarUrl;
    final previousAvatarUrl = _initialAvatarUrl;

    try {
      String? nextAvatarUrl = _markAvatarDeleted ? null : _existingAvatarUrl;

      if (_selectedAvatar != null) {
        uploadedAvatarUrl = await imageService.uploadImage(
          bucket: 'avatars',
          userId: currentUser.id,
          file: _selectedAvatar!,
        );

        if (uploadedAvatarUrl == null || uploadedAvatarUrl.isEmpty) {
          throw Exception('Avatar upload failed');
        }

        nextAvatarUrl = uploadedAvatarUrl;
      }

      await authService.updateProfile(
        userId: currentUser.id,
        nickname: _nicknameController.text,
        avatarUrl: nextAvatarUrl,
      );

      await _cleanupOldAvatar(
        previousAvatarUrl: previousAvatarUrl,
        nextAvatarUrl: nextAvatarUrl,
      );

      if (!mounted) return;

      context.read<DashboardCubit>().refresh();
      context.read<PostListCubit>().reload();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileEditSaveSuccess)),
      );
      Navigator.of(context).pop();
    } on PostgrestException catch (e) {
      await _rollbackUploadedAvatar(uploadedAvatarUrl);

      if (!mounted) return;

      final message = e.code == '23505'
          ? context.l10n.profileEditNicknameDuplicate
          : context.l10n.profileEditSaveFailed;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      await _rollbackUploadedAvatar(uploadedAvatarUrl);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileEditSaveFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatarPreview() {
    final trimmedNickname = _nicknameController.text.trim();
    final displayNickname = trimmedNickname.isEmpty ? null : trimmedNickname;

    if (_selectedAvatar != null) {
      return CircleAvatar(
        radius: 52,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        child: ClipOval(
          child: Image.file(
            File(_selectedAvatar!.path),
            width: 104,
            height: 104,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return UserAvatar(
      nickname: displayNickname,
      avatarUrl: _markAvatarDeleted ? null : _existingAvatarUrl,
      radius: 52,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileEditTitle)),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _onAvatarTap,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildAvatarPreview(),
                              Positioned(
                                right: -4,
                                bottom: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _onAvatarTap,
                          child: Text(context.l10n.profileEditPhotoAction),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: context.l10n.profileEditNicknameLabel,
                        hint: context.l10n.profileEditNicknameHint,
                        controller: _nicknameController,
                        validator: _validateNickname,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _saveProfile(),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.profileEditNicknameRule,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: context.l10n.save,
                        onPressed: _saveProfile,
                        isLoading: _isLoading,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
