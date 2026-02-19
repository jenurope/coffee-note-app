import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/bean/bean_list_cubit.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../domain/catalogs/roast_level_catalog.dart';
import '../../l10n/l10n.dart';
import '../../models/coffee_bean.dart';

import '../../services/coffee_bean_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/image_picker_widget.dart';

class BeanFormScreen extends StatefulWidget {
  final String? beanId;

  const BeanFormScreen({super.key, this.beanId});

  @override
  State<BeanFormScreen> createState() => _BeanFormScreenState();
}

class _BeanFormScreenState extends State<BeanFormScreen> {
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

  @override
  void initState() {
    super.initState();
    if (widget.beanId != null) {
      _loadBean();
    }
  }

  void _loadBean() {
    final service = getIt<CoffeeBeanService>();
    service.getBean(widget.beanId!).then((bean) {
      if (bean != null && mounted) {
        setState(() {
          _initializeWithBean(bean);
        });
      }
    });
  }

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
    final locale = Localizations.localeOf(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: locale,
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

    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 이미지 업로드
      final imageUrl = await _uploadImageIfNeeded(currentUser.id);

      final service = getIt<CoffeeBeanService>();

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

      // Cubit 간 갱신 계약 (P1)
      if (mounted) {
        context.read<BeanListCubit>().reload();
        context.read<DashboardCubit>().refresh();
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? context.l10n.beanUpdated : context.l10n.beanCreated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              UserErrorMessage.localize(
                context.l10n,
                UserErrorMessage.from(e, fallbackKey: 'beanSaveFailed'),
              ),
            ),
          ),
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
    final localizations = MaterialLocalizations.of(context);

    // 수정 모드일 때 기존 데이터 로드 (initState로 이동됨)

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.beanFormEditTitle
              : context.l10n.beanFormNewTitle,
        ),
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
                Text(context.l10n.beanPhoto, style: theme.textTheme.bodyLarge),
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
                  label: context.l10n.beanNameLabel,
                  hint: context.l10n.beanNameHint,
                  controller: _nameController,
                  prefixIcon: Icons.coffee,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.beanNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 로스터리
                CustomTextField(
                  label: context.l10n.roasteryLabel,
                  hint: context.l10n.roasteryHint,
                  controller: _roasteryController,
                  prefixIcon: Icons.store,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.roasteryRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 구매일
                Text(
                  context.l10n.purchaseDate,
                  style: theme.textTheme.bodyLarge,
                ),
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
                    child: Text(localizations.formatMediumDate(_purchaseDate)),
                  ),
                ),
                const SizedBox(height: 16),

                // 평점
                Text(context.l10n.rating, style: theme.textTheme.bodyLarge),
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

                // 로스팅 레벨
                Text(context.l10n.roastLevel, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: CoffeeBean.roastLevels.map((level) {
                    return ChoiceChip(
                      label: Text(RoastLevelCatalog.label(context.l10n, level)),
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
                  label: context.l10n.price,
                  hint: context.l10n.priceHint,
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 구매처
                CustomTextField(
                  label: context.l10n.purchaseLocation,
                  hint: context.l10n.purchaseLocationHint,
                  controller: _purchaseLocationController,
                  prefixIcon: Icons.shopping_bag,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // 테이스팅 노트
                CustomTextField(
                  label: context.l10n.tastingNotes,
                  hint: context.l10n.tastingNotesHint,
                  controller: _tastingNotesController,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 32),

                // 저장 버튼
                CustomButton(
                  text: isEditing
                      ? context.l10n.saveAsEdit
                      : context.l10n.saveAsNew,
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
