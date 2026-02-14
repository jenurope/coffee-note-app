import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/service_locator.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../widgets/common/common_widgets.dart';

class PostFormScreen extends StatefulWidget {
  final String? postId;

  const PostFormScreen({super.key, this.postId});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isEditing => widget.postId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadPost();
    }
  }

  void _loadPost() {
    final service = getIt<CommunityService>();
    service.getPost(widget.postId!).then((post) {
      if (post != null && mounted) {
        setState(() {
          _initializeWithPost(post);
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _initializeWithPost(CommunityPost post) {
    if (_isInitialized) return;
    _isInitialized = true;

    _titleController.text = post.title;
    _contentController.text = post.content;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = getIt<CommunityService>();

      final post = CommunityPost(
        id: widget.postId ?? '',
        userId: currentUser.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await service.updatePost(post);
      } else {
        await service.createPost(post);
      }

      if (mounted) {
        context.read<PostListCubit>().reload();
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '게시글이 수정되었습니다.' : '게시글이 등록되었습니다.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 수정 모드일 때 기존 데이터 로드 (initState로 이동됨)

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '게시글 수정' : '새 게시글'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEditing ? '수정' : '등록'),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목
                CustomTextField(
                  label: '제목',
                  hint: '제목을 입력하세요',
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    if (value.trim().length < 2) {
                      return '제목은 2자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 내용
                CustomTextField(
                  label: '내용',
                  hint: '커피에 대한 이야기를 나눠보세요...',
                  controller: _contentController,
                  maxLines: 15,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '내용을 입력해주세요';
                    }
                    if (value.trim().length < 10) {
                      return '내용은 10자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
