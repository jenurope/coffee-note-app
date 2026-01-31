import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/coffee_bean.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/image_picker_widget.dart';

class BeanFormScreen extends ConsumerStatefulWidget {
  final String? beanId;

  const BeanFormScreen({super.key, this.beanId});

  @override
  ConsumerState<BeanFormScreen> createState() => _BeanFormScreenState();
}

class _BeanFormScreenState extends ConsumerState<BeanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roasteryController = TextEditingController();
  final _tastingNotesController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchaseLocationController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  double _rating = 3.0;
  String? _roastLevel;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // 이미지 관련 상태
  String? _existingImageUrl;
  XFile? _selectedImage;
  bool _isUploadingImage = false;

  bool get isEditing => widget.beanId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _roasteryController.dispose();
    _tastingNotesController.dispose();
    _priceController.dispose();
    _purchaseLocationController.dispose();
    super.dispose();
  }

  void _initializeWithBean(CoffeeBean bean) {
    if (_isInitialized) return;
    _isInitialized = true;

    _nameController.text = bean.name;
    _roasteryController.text = bean.roastery;
    _tastingNotesController.text = bean.tastingNotes ?? '';
    _priceController.text = bean.price?.toString() ?? '';
    _purchaseLocationController.text = bean.purchaseLocation ?? '';
    _purchaseDate = bean.purchaseDate;
    _rating = bean.rating;
    _roastLevel = bean.roastLevel;
    _existingImageUrl = bean.imageUrl;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
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

    final imageService = ref.read(imageUploadServiceProvider);
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
      final imageService = ref.read(imageUploadServiceProvider);
      final imageUrl = await imageService.uploadImage(
        bucket: 'beans',
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

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 이미지 업로드
      final imageUrl = await _uploadImageIfNeeded(currentUser.id);
      
      final service = ref.read(coffeeBeanServiceProvider);

      final bean = CoffeeBean(
        id: widget.beanId ?? '',
        userId: currentUser.id,
        name: _nameController.text.trim(),
        roastery: _roasteryController.text.trim(),
        purchaseDate: _purchaseDate,
        rating: _rating,
        tastingNotes: _tastingNotesController.text.trim().isEmpty
            ? null
            : _tastingNotesController.text.trim(),
        roastLevel: _roastLevel,
        price: _priceController.text.isEmpty
            ? null
            : int.tryParse(_priceController.text),
        purchaseLocation: _purchaseLocationController.text.trim().isEmpty
            ? null
            : _purchaseLocationController.text.trim(),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await service.updateBean(bean);
      } else {
        await service.createBean(bean);
      }

      ref.invalidate(beansProvider);
      ref.invalidate(recentBeansProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '원두가 수정되었습니다.' : '원두가 등록되었습니다.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
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
    if (isEditing) {
      final beanAsync = ref.watch(beanDetailProvider(widget.beanId!));
      beanAsync.whenData((bean) {
        if (bean != null) _initializeWithBean(bean);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '원두 수정' : '새 원두 기록'),
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
                // 이미지 선택
                Text('원두 사진', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                ImagePickerWidget(
                  imageUrl: _existingImageUrl,
                  localImagePath: _selectedImage?.path,
                  onTap: _pickImage,
                  height: 200,
                  placeholderIcon: Icons.coffee,
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                
                // 원두 이름
                CustomTextField(
                  label: '원두 이름 *',
                  hint: '예: 에티오피아 예가체프',
                  controller: _nameController,
                  prefixIcon: Icons.coffee,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '원두 이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 로스터리
                CustomTextField(
                  label: '로스터리 *',
                  hint: '예: 커피리브레',
                  controller: _roasteryController,
                  prefixIcon: Icons.store,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '로스터리를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 구매일
                Text('구매일 *', style: theme.textTheme.bodyLarge),
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
                    child: Text(dateFormat.format(_purchaseDate)),
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
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
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

                // 로스팅 레벨
                Text('로스팅 레벨', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: CoffeeBean.roastLevels.map((level) {
                    return ChoiceChip(
                      label: Text(level),
                      selected: _roastLevel == level,
                      onSelected: (selected) {
                        setState(() {
                          _roastLevel = selected ? level : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 가격
                CustomTextField(
                  label: '가격',
                  hint: '원',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 구매처
                CustomTextField(
                  label: '구매처',
                  hint: '예: 공식 홈페이지',
                  controller: _purchaseLocationController,
                  prefixIcon: Icons.shopping_bag,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 테이스팅 노트
                CustomTextField(
                  label: '테이스팅 노트',
                  hint: '이 원두의 맛을 설명해주세요...',
                  controller: _tastingNotesController,
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
