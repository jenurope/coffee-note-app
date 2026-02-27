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
import '../../domain/catalogs/brew_method_catalog.dart';
import '../../domain/catalogs/roast_level_catalog.dart';
import '../../l10n/l10n.dart';
import '../../models/bean_recipe.dart';
import '../../models/coffee_bean.dart';

import '../../services/bean_recipe_service.dart';
import '../../services/coffee_bean_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/navigation/form_leave_confirm_dialog.dart';

class BeanFormScreen extends StatefulWidget {
  final String? beanId;

  const BeanFormScreen({super.key, this.beanId});

  @override
  State<BeanFormScreen> createState() => _BeanFormScreenState();
}

class _BeanFormScreenState extends State<BeanFormScreen> {
  static const String _manualRecipeOption = '__manual__';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roasteryController = TextEditingController();
  final _tastingNotesController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchaseLocationController = TextEditingController();
  final _recipeController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  double _rating = 3.0;
  String? _roastLevel = RoastLevelCatalog.medium;
  String _selectedRecipeOption = _manualRecipeOption;
  String _brewMethod = BrewMethodCatalog.pourOver;
  List<BeanRecipe> _managedRecipes = const <BeanRecipe>[];
  bool _isLoadingManagedRecipes = false;
  bool _didLoadManagedRecipes = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _allowPop = false;
  bool _isLeaveDialogOpen = false;
  _BeanFormSnapshot? _initialSnapshot;

  @override
  void initState() {
    super.initState();
    if (widget.beanId != null) {
      _loadBean();
    } else {
      _captureInitialSnapshot();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadManagedRecipes) {
      return;
    }
    _didLoadManagedRecipes = true;
    _loadManagedRecipes();
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

  int _roastIndexFromPosition(double dx, double width) {
    if (width <= 0) return 0;

    final ratio = (dx / width).clamp(0.0, 0.999999).toDouble();
    return (ratio * CoffeeBean.roastLevels.length).floor();
  }

  void _updateRoastLevelFromPosition(double dx, double width) {
    final nextLevel =
        CoffeeBean.roastLevels[_roastIndexFromPosition(dx, width)];
    if (_roastLevel == nextLevel) return;

    setState(() {
      _roastLevel = nextLevel;
    });
  }

  void _applyManagedRecipe(String? id) {
    if (id == null || id == _manualRecipeOption) {
      setState(() {
        _selectedRecipeOption = _manualRecipeOption;
      });
      return;
    }

    BeanRecipe? recipe;
    for (final item in _managedRecipes) {
      if (item.id == id) {
        recipe = item;
        break;
      }
    }
    if (recipe == null) {
      return;
    }
    final selectedRecipe = recipe;

    setState(() {
      _selectedRecipeOption = id;
      _brewMethod = selectedRecipe.brewMethod;
      _recipeController.text = selectedRecipe.recipe;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roasteryController.dispose();
    _tastingNotesController.dispose();
    _priceController.dispose();
    _purchaseLocationController.dispose();
    _recipeController.dispose();
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
    _brewMethod = bean.brewMethod ?? BrewMethodCatalog.pourOver;
    _recipeController.text = bean.recipe ?? '';
    _existingImageUrl = bean.imageUrl;
    _captureInitialSnapshot();
  }

  Future<void> _loadManagedRecipes() async {
    AuthState? authState;
    try {
      authState = context.read<AuthCubit>().state;
    } catch (_) {
      authState = null;
    }
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    if (currentUser == null) {
      return;
    }

    setState(() {
      _isLoadingManagedRecipes = true;
    });

    try {
      final service = getIt<BeanRecipeService>();
      final recipes = await service.getRecipes(currentUser.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _managedRecipes = recipes;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.beanRecipeLoadFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingManagedRecipes = false;
        });
      }
    }
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
    final selection = await ImagePickerBottomSheet.show(
      context,
      showDelete: _existingImageUrl != null || _selectedImage != null,
    );

    if (selection == ImagePickerSelection.dismissed) return;

    if (selection == ImagePickerSelection.delete) {
      setState(() {
        _selectedImage = null;
        _existingImageUrl = null;
      });
      return;
    }

    final imageService = getIt<ImageUploadService>();
    XFile? picked;

    if (selection == ImagePickerSelection.gallery) {
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
      return _normalizedExistingImageReference();
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

      if (imageUrl == null || imageUrl.isEmpty) {
        throw const ImageUploadException('Image upload failed');
      }

      return imageUrl;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  String? _normalizedExistingImageReference() {
    final existing = _existingImageUrl?.trim();
    if (existing == null || existing.isEmpty) {
      return null;
    }

    final filePath = ImageUploadService.extractFilePathFromReference(
      bucket: 'beans',
      imageReference: existing,
    );
    return filePath ?? existing;
  }

  DateTime _normalizedDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _normalizedText(String value) => value.trim();

  _BeanFormSnapshot _currentSnapshot() {
    return _BeanFormSnapshot(
      name: _normalizedText(_nameController.text),
      roastery: _normalizedText(_roasteryController.text),
      tastingNotes: _normalizedText(_tastingNotesController.text),
      price: _normalizedText(_priceController.text),
      purchaseLocation: _normalizedText(_purchaseLocationController.text),
      purchaseDate: _normalizedDate(_purchaseDate),
      rating: _rating,
      roastLevel: _roastLevel,
      brewMethod: _brewMethod,
      recipe: _normalizedText(_recipeController.text),
      imageReference: _normalizedExistingImageReference(),
      selectedImagePath: _selectedImage?.path,
    );
  }

  void _captureInitialSnapshot() {
    _initialSnapshot = _currentSnapshot();
  }

  bool get _hasUnsavedChanges {
    if (_allowPop) return false;
    if (isEditing && !_isInitialized) return false;
    final initialSnapshot = _initialSnapshot;
    if (initialSnapshot == null) return false;
    return _currentSnapshot() != initialSnapshot;
  }

  Future<bool> _confirmLeaveIfNeeded() async {
    if (!_hasUnsavedChanges) {
      return true;
    }
    if (_isLeaveDialogOpen) {
      return false;
    }

    _isLeaveDialogOpen = true;
    final shouldLeave = await showFormLeaveConfirmDialog(
      context,
      isEditing: isEditing,
    );
    _isLeaveDialogOpen = false;
    return shouldLeave;
  }

  void _popSafely() {
    if (_allowPop) {
      if (mounted) {
        context.pop();
      }
      return;
    }

    setState(() {
      _allowPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pop();
    });
  }

  Future<void> _handlePopInvoked() async {
    if (_isLoading || _isUploadingImage) return;

    final shouldLeave = await _confirmLeaveIfNeeded();
    if (!mounted || !shouldLeave) return;

    _popSafely();
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
        brewMethod: _brewMethod,
        recipe: _recipeController.text.trim().isEmpty
            ? null
            : _recipeController.text.trim(),
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
        final messenger = ScaffoldMessenger.of(context);
        _captureInitialSnapshot();
        _popSafely();
        messenger.showSnackBar(
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
    final appBarActionColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;
    final appBarDisabledActionColor = appBarActionColor.withValues(alpha: 0.5);
    final recipeIds = _managedRecipes.map((e) => e.id).toSet();
    final recipeSelectionValue = recipeIds.contains(_selectedRecipeOption)
        ? _selectedRecipeOption
        : _manualRecipeOption;

    // 수정 모드일 때 기존 데이터 로드 (initState로 이동됨)

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handlePopInvoked();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing
                ? context.l10n.beanFormEditTitle
                : context.l10n.beanFormNewTitle,
          ),
          actions: [
            TextButton(
              onPressed: _isLoading || _isUploadingImage ? null : _handleSubmit,
              style: TextButton.styleFrom(
                foregroundColor: appBarActionColor,
                disabledForegroundColor: appBarDisabledActionColor,
              ),
              child: Text(context.l10n.save),
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
                  // 이미지 선택
                  Text(
                    context.l10n.beanPhoto,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  ImagePickerWidget(
                    imageUrl: _existingImageUrl,
                    localImagePath: _selectedImage?.path,
                    onTap: _pickImage,
                    height: 200,
                    placeholderIcon: Icons.coffee,
                  ),
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
                      child: Text(
                        localizations.formatMediumDate(_purchaseDate),
                      ),
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
                  Text(
                    context.l10n.roastLevel,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final trackWidth = constraints.maxWidth;

                              return Listener(
                                behavior: HitTestBehavior.opaque,
                                onPointerDown: (event) {
                                  _updateRoastLevelFromPosition(
                                    event.localPosition.dx,
                                    trackWidth,
                                  );
                                },
                                onPointerMove: (event) {
                                  _updateRoastLevelFromPosition(
                                    event.localPosition.dx,
                                    trackWidth,
                                  );
                                },
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFC4A676),
                                        const Color(0xFFA97445),
                                        const Color(0xFF7A4A27),
                                        const Color(0xFF4F2B17),
                                        const Color(0xFF2D160C),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: CoffeeBean.roastLevels
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final level = entry.value;
                                          final isSelected =
                                              _roastLevel == level;

                                          return Expanded(
                                            child: Center(
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                height: isSelected ? 26 : 14,
                                                width: isSelected ? 26 : 14,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white.withValues(
                                                          alpha: 0.35,
                                                        ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF2D160C,
                                                          )
                                                        : Colors.white
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                    width: 2,
                                                  ),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                  alpha: 0.25,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  3,
                                                                ),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(
                              CoffeeBean.roastLevels.length,
                              (index) {
                                final String? label = switch (index) {
                                  0 => context.l10n.roastLight,
                                  2 => context.l10n.roastMedium,
                                  4 => context.l10n.roastDark,
                                  _ => null,
                                };

                                return Expanded(
                                  child: Center(
                                    child: label == null
                                        ? const SizedBox.shrink()
                                        : Text(
                                            label,
                                            style: theme.textTheme.labelMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 관리 레시피 불러오기
                  DropdownButtonFormField<String>(
                    key: const Key('bean_recipe_template_dropdown'),
                    initialValue: recipeSelectionValue,
                    decoration: InputDecoration(
                      labelText: context.l10n.beanRecipeSelectLabel,
                      hintText: context.l10n.beanRecipeSelectHint,
                      prefixIcon: const Icon(Icons.menu_book_outlined),
                      suffixIcon: IconButton(
                        icon: _isLoadingManagedRecipes
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        onPressed: _isLoadingManagedRecipes
                            ? null
                            : _loadManagedRecipes,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: _manualRecipeOption,
                        child: Text(context.l10n.beanRecipeManualInput),
                      ),
                      ..._managedRecipes.map(
                        (recipe) => DropdownMenuItem<String>(
                          value: recipe.id,
                          child: Text(
                            '${recipe.name} · ${BrewMethodCatalog.label(context.l10n, recipe.brewMethod)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: _isLoadingManagedRecipes
                        ? null
                        : _applyManagedRecipe,
                  ),
                  const SizedBox(height: 16),

                  // 추출 방식
                  Text(
                    context.l10n.brewMethodLabel,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BrewMethodCatalog.codes
                        .map((method) {
                          return ChoiceChip(
                            label: Text(
                              BrewMethodCatalog.label(context.l10n, method),
                            ),
                            selected: _brewMethod == method,
                            onSelected: (selected) {
                              if (!selected) {
                                return;
                              }
                              setState(() {
                                _brewMethod = method;
                                _selectedRecipeOption = _manualRecipeOption;
                              });
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 16),

                  // 레시피
                  CustomTextField(
                    key: const Key('bean_recipe_text_field'),
                    label: context.l10n.recipeLabel,
                    hint: context.l10n.recipeHint,
                    controller: _recipeController,
                    maxLines: 5,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_selectedRecipeOption != _manualRecipeOption) {
                        setState(() {
                          _selectedRecipeOption = _manualRecipeOption;
                        });
                      }
                    },
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BeanFormSnapshot {
  const _BeanFormSnapshot({
    required this.name,
    required this.roastery,
    required this.tastingNotes,
    required this.price,
    required this.purchaseLocation,
    required this.purchaseDate,
    required this.rating,
    required this.roastLevel,
    required this.brewMethod,
    required this.recipe,
    required this.imageReference,
    required this.selectedImagePath,
  });

  final String name;
  final String roastery;
  final String tastingNotes;
  final String price;
  final String purchaseLocation;
  final DateTime purchaseDate;
  final double rating;
  final String? roastLevel;
  final String brewMethod;
  final String recipe;
  final String? imageReference;
  final String? selectedImagePath;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _BeanFormSnapshot &&
        other.name == name &&
        other.roastery == roastery &&
        other.tastingNotes == tastingNotes &&
        other.price == price &&
        other.purchaseLocation == purchaseLocation &&
        other.purchaseDate == purchaseDate &&
        other.rating == rating &&
        other.roastLevel == roastLevel &&
        other.brewMethod == brewMethod &&
        other.recipe == recipe &&
        other.imageReference == imageReference &&
        other.selectedImagePath == selectedImagePath;
  }

  @override
  int get hashCode => Object.hash(
    name,
    roastery,
    tastingNotes,
    price,
    purchaseLocation,
    purchaseDate,
    rating,
    roastLevel,
    brewMethod,
    recipe,
    imageReference,
    selectedImagePath,
  );
}
