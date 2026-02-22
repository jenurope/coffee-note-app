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
import '../../cubits/log/log_list_cubit.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../domain/catalogs/coffee_type_catalog.dart';
import '../../l10n/l10n.dart';
import '../../models/coffee_log.dart';
import '../../services/coffee_log_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/navigation/form_leave_confirm_dialog.dart';

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
  bool _allowPop = false;
  bool _isLeaveDialogOpen = false;
  _CoffeeLogFormSnapshot? _initialSnapshot;

  @override
  void initState() {
    super.initState();
    if (widget.logId != null) {
      _loadLog();
    } else {
      _captureInitialSnapshot();
    }
  }

  void _loadLog() {
    final service = getIt<CoffeeLogService>();
    service.getLog(widget.logId!).then((log) {
      if (log != null && mounted) {
        setState(() {
          _initializeWithLog(log);
        });
      }
    });
  }

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
    _captureInitialSnapshot();
  }

  Future<void> _selectDate() async {
    final locale = Localizations.localeOf(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: locale,
    );
    if (picked != null) {
      setState(() {
        _visitDate = picked;
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
        bucket: 'logs',
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
      bucket: 'logs',
      imageReference: existing,
    );
    return filePath ?? existing;
  }

  DateTime _normalizedDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _normalizedText(String value) => value.trim();

  _CoffeeLogFormSnapshot _currentSnapshot() {
    return _CoffeeLogFormSnapshot(
      coffeeName: _normalizedText(_coffeeNameController.text),
      cafeName: _normalizedText(_cafeNameController.text),
      notes: _normalizedText(_notesController.text),
      visitDate: _normalizedDate(_visitDate),
      coffeeType: _coffeeType,
      rating: _rating,
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
        context.read<DashboardCubit>().refresh();
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        _captureInitialSnapshot();
        _popSafely();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? context.l10n.logUpdated : context.l10n.logCreated,
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
                UserErrorMessage.from(e, fallbackKey: 'logSaveFailed'),
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
                ? context.l10n.logFormEditTitle
                : context.l10n.logFormNewTitle,
          ),
          actions: [
            TextButton(
              onPressed: _isLoading || _isUploadingImage ? null : _handleSubmit,
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
                    context.l10n.coffeePhoto,
                    style: theme.textTheme.bodyLarge,
                  ),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      context.l10n.photoChange,
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
                  Text(
                    context.l10n.coffeeType,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CoffeeLog.coffeeTypes.map((type) {
                      return ChoiceChip(
                        label: Text(
                          CoffeeTypeCatalog.label(context.l10n, type),
                        ),
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
                    label: context.l10n.coffeeName,
                    hint: context.l10n.coffeeNameHint,
                    controller: _coffeeNameController,
                    prefixIcon: Icons.local_cafe,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 카페 이름
                  CustomTextField(
                    label: context.l10n.cafeName,
                    hint: context.l10n.cafeNameHint,
                    controller: _cafeNameController,
                    prefixIcon: Icons.storefront,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.cafeNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 방문일
                  Text(
                    context.l10n.visitDate,
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
                      child: Text(localizations.formatMediumDate(_visitDate)),
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

                  // 메모
                  CustomTextField(
                    label: context.l10n.memo,
                    hint: context.l10n.memoHint,
                    controller: _notesController,
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

class _CoffeeLogFormSnapshot {
  const _CoffeeLogFormSnapshot({
    required this.coffeeName,
    required this.cafeName,
    required this.notes,
    required this.visitDate,
    required this.coffeeType,
    required this.rating,
    required this.imageReference,
    required this.selectedImagePath,
  });

  final String coffeeName;
  final String cafeName;
  final String notes;
  final DateTime visitDate;
  final String coffeeType;
  final double rating;
  final String? imageReference;
  final String? selectedImagePath;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CoffeeLogFormSnapshot &&
        other.coffeeName == coffeeName &&
        other.cafeName == cafeName &&
        other.notes == notes &&
        other.visitDate == visitDate &&
        other.coffeeType == coffeeType &&
        other.rating == rating &&
        other.imageReference == imageReference &&
        other.selectedImagePath == selectedImagePath;
  }

  @override
  int get hashCode => Object.hash(
    coffeeName,
    cafeName,
    notes,
    visitDate,
    coffeeType,
    rating,
    imageReference,
    selectedImagePath,
  );
}
