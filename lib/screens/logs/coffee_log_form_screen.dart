import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/log/log_list_cubit.dart';
import '../../models/coffee_log.dart';
import '../../services/coffee_log_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/image_picker_widget.dart';

class CoffeeLogFormScreen extends StatefulWidget {
  final String? logId;

  const CoffeeLogFormScreen({super.key, this.logId});

  @override
  State<CoffeeLogFormScreen> createState() => _CoffeeLogFormScreenState();
}

class _CoffeeLogFormScreenState extends State<CoffeeLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coffeeNameController = TextEditingController();
  final _cafeNameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _visitDate = DateTime.now();
  String _coffeeType = CoffeeLog.coffeeTypes.first;
  double _rating = 3.0;
  bool _isLoading = false;
  bool _isInitialized = false;

  // 이미지 관련 상태
  String? _existingImageUrl;
  XFile? _selectedImage;
  bool _isUploadingImage = false;

  bool get isEditing => widget.logId != null;

  @override
  void dispose() {
    _coffeeNameController.dispose();
    _cafeNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeWithLog(CoffeeLog log) {
    if (_isInitialized) return;
    _isInitialized = true;

    _coffeeNameController.text = log.coffeeName ?? '';
    _cafeNameController.text = log.cafeName;
    _notesController.text = log.notes ?? '';
    _visitDate = log.cafeVisitDate;
    _coffeeType = log.coffeeType;
    _rating = log.rating;
    _existingImageUrl = log.imageUrl;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final source = await ImagePickerBottomSheet.show(
      context,
      showDelete: _existingImageUrl != null || _selectedImage != null,
    );

    if (source == null) {
      // 삭제 선택
      setState(() {
        _selectedImage = null;
        _existingImageUrl = null;
      });
      return;
    }

    final imageService = getIt<ImageUploadService>();
    XFile? picked;

    if (source == ImageSource.gallery) {
      picked = await imageService.pickImageFromGallery();
    } else {
      picked = await imageService.pickImageFromCamera();
    }

    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  Future<String?> _uploadImageIfNeeded(String userId) async {
    if (_selectedImage == null) {
      return _existingImageUrl;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageService = getIt<ImageUploadService>();
      final imageUrl = await imageService.uploadImage(
        bucket: 'logs',
        userId: userId,
        file: _selectedImage!,
      );
      return imageUrl ?? _existingImageUrl;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
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
      // 이미지 업로드
      final imageUrl = await _uploadImageIfNeeded(currentUser.id);

      final service = getIt<CoffeeLogService>();

      final log = CoffeeLog(
        id: widget.logId ?? '',
        userId: currentUser.id,
        cafeVisitDate: _visitDate,
        coffeeType: _coffeeType,
        coffeeName: _coffeeNameController.text.trim().isEmpty
            ? null
            : _coffeeNameController.text.trim(),
        cafeName: _cafeNameController.text.trim(),
        rating: _rating,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await service.updateLog(log);
      } else {
        await service.createLog(log);
      }

      // Cubit 간 갱신 계약 (P1)
      if (mounted) {
        context.read<LogListCubit>().reload();
        // DashboardCubit.refresh() — Phase 6에서 추가
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? '기록이 수정되었습니다.' : '기록이 등록되었습니다.')),
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
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    // 수정 모드일 때 기존 데이터 로드
    if (isEditing && !_isInitialized) {
      final service = getIt<CoffeeLogService>();
      service.getLog(widget.logId!).then((log) {
        if (log != null && mounted) {
          setState(() {
            _initializeWithLog(log);
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? '기록 수정' : '새 커피 기록')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 이미지 선택
                Text('커피 사진', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.file(
                          File(_selectedImage!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '사진 변경',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ImagePickerWidget(
                    imageUrl: _existingImageUrl,
                    onTap: _pickImage,
                    height: 200,
                    placeholderIcon: Icons.local_cafe,
                  ),
                const SizedBox(height: 16),

                // 커피 종류
                Text('커피 종류 *', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CoffeeLog.coffeeTypes.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _coffeeType == type,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _coffeeType = type;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 커피 이름
                CustomTextField(
                  label: '커피 이름',
                  hint: '예: 시그니처 라떼',
                  controller: _coffeeNameController,
                  prefixIcon: Icons.local_cafe,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 카페 이름
                CustomTextField(
                  label: '카페 이름 *',
                  hint: '예: 블루보틀 성수점',
                  controller: _cafeNameController,
                  prefixIcon: Icons.storefront,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '카페 이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 방문일
                Text('방문일 *', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(dateFormat.format(_visitDate)),
                  ),
                ),
                const SizedBox(height: 16),

                // 평점
                Text('평점 *', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        RatingBar.builder(
                          initialRating: _rating,
                          minRating: 0.5,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 40,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 메모
                CustomTextField(
                  label: '메모',
                  hint: '커피에 대한 감상을 적어주세요...',
                  controller: _notesController,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 32),

                // 저장 버튼
                CustomButton(
                  text: isEditing ? '수정하기' : '등록하기',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading || _isUploadingImage,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
