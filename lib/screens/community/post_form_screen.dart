import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../core/image/app_image_cache_policy.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/community/post_list_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/navigation/form_leave_confirm_dialog.dart';
import 'post_markdown_utils.dart';

class PostFormScreen extends StatefulWidget {
  final String? postId;

  const PostFormScreen({super.key, this.postId});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  static const int _minTitleLength = 2;
  static const int _maxTitleLength = 50;
  static const int _minContentLength = 2;
  static const int _maxContentLength = 500;
  static const int _maxImagesPerPost = 3;

  final _formKey = GlobalKey<FormState>();
  final _contentFieldKey = GlobalKey<FormFieldState<String>>();
  final _titleController = TextEditingController();
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();

  late final QuillController _quillController;
  late final MarkdownToDelta _markdownToDelta;
  late final DeltaToMarkdown _deltaToMarkdown;

  final Map<String, XFile> _pendingImages = <String, XFile>{};

  bool _isLoading = false;
  bool _isInitialized = false;
  String _originalContent = '';
  String _initialTitle = '';
  String _initialContent = '';
  bool _allowPop = false;
  bool _isLeaveDialogOpen = false;

  bool get isEditing => widget.postId != null;

  String _currentMarkdownContent({bool trim = false}) {
    final markdown = _deltaToMarkdown.convert(
      _quillController.document.toDelta(),
    );
    return trim ? markdown.trim() : markdown;
  }

  String _currentPlainTextContent({bool trim = false}) {
    var text = _quillController.document.toPlainText().replaceAll(
      '\u{fffc}',
      '',
    );
    if (text.endsWith('\n')) {
      text = text.substring(0, text.length - 1);
    }
    return trim ? text.trim() : text;
  }

  int get _imageCount => countMarkdownImages(_currentMarkdownContent());

  Map<String, String> get _pendingImagePathsByUrl {
    return {
      for (final entry in _pendingImages.entries)
        '$pendingImageSchemePrefix${entry.key}': entry.value.path,
    };
  }

  @override
  void initState() {
    super.initState();

    _markdownToDelta = MarkdownToDelta(
      markdownDocument: md.Document(
        encodeHtml: false,
        extensionSet: md.ExtensionSet.gitHubFlavored,
      ),
    );
    _deltaToMarkdown = DeltaToMarkdown();
    _quillController = QuillController.basic();
    _quillController.addListener(_handleEditorChanged);

    if (isEditing) {
      _loadPost();
    } else {
      _captureInitialSnapshot();
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
    _quillController.removeListener(_handleEditorChanged);
    _quillController.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _initializeWithPost(CommunityPost post) {
    if (_isInitialized) return;
    _isInitialized = true;

    _titleController.text = post.title;
    _originalContent = post.content;
    _setEditorMarkdown(post.content);
    _prunePendingImages();
    _captureInitialSnapshot();
  }

  void _setEditorMarkdown(String markdownContent) {
    Document document;
    try {
      final delta = _markdownToDelta.convert(markdownContent);
      document = Document.fromDelta(delta);
    } catch (_) {
      document = Document();
      if (markdownContent.isNotEmpty) {
        document.insert(0, markdownContent);
      }
    }

    _quillController.document = document;
    final cursorOffset = (document.length - 1)
        .clamp(0, document.length)
        .toInt();
    _quillController.updateSelection(
      TextSelection.collapsed(offset: cursorOffset),
      ChangeSource.local,
    );
  }

  void _handleEditorChanged() {
    _prunePendingImages();
    _contentFieldKey.currentState?.didChange(_currentMarkdownContent());
    if (mounted) {
      setState(() {});
    }
  }

  void _prunePendingImages() {
    final imageUrls = extractImageUrlsFromMarkdown(_currentMarkdownContent());
    final activePendingIds = imageUrls
        .where((url) => url.startsWith(pendingImageSchemePrefix))
        .map((url) => url.substring(pendingImageSchemePrefix.length))
        .toSet();

    _pendingImages.removeWhere((id, _) => !activePendingIds.contains(id));
  }

  Future<void> _insertImageEmbed() async {
    if (_imageCount >= _maxImagesPerPost) {
      _showMessage(context.l10n.postImageLimitReached);
      return;
    }

    final selection = await ImagePickerBottomSheet.show(context);
    if (!mounted || selection == ImagePickerSelection.dismissed) {
      return;
    }

    final imageService = getIt<ImageUploadService>();
    XFile? pickedFile;

    if (selection == ImagePickerSelection.gallery) {
      pickedFile = await imageService.pickImageFromGallery();
    } else if (selection == ImagePickerSelection.camera) {
      pickedFile = await imageService.pickImageFromCamera();
    }

    if (!mounted || pickedFile == null) {
      return;
    }

    final pendingId = DateTime.now().microsecondsSinceEpoch.toString();
    final pendingUrl = '$pendingImageSchemePrefix$pendingId';

    final currentSelection = _quillController.selection;
    final maxOffset = (_quillController.document.length - 1)
        .clamp(0, _quillController.document.length)
        .toInt();
    final start =
        (currentSelection.isValid
                ? currentSelection.start
                : _quillController.document.length - 1)
            .clamp(0, maxOffset)
            .toInt();
    final end = (currentSelection.isValid ? currentSelection.end : start)
        .clamp(start, maxOffset)
        .toInt();

    _pendingImages[pendingId] = pickedFile;
    _quillController.replaceText(
      start,
      end - start,
      BlockEmbed.image(pendingUrl),
      TextSelection.collapsed(offset: start + 1),
    );

    if (_imageCount > _maxImagesPerPost) {
      _pendingImages.remove(pendingId);
      _quillController.replaceText(
        start,
        1,
        '',
        TextSelection.collapsed(offset: start),
      );
      _showMessage(context.l10n.postImageLimitReached);
      return;
    }

    _showMessage(context.l10n.postImageCount(_imageCount));
  }

  String? _validateContent(String? _) {
    final plainText = _currentPlainTextContent(trim: true);
    final markdownContent = _currentMarkdownContent(trim: true);

    if (plainText.isEmpty) {
      return context.l10n.postContentRequired;
    }
    if (plainText.length < _minContentLength) {
      return context.l10n.postContentMinLength;
    }
    if (plainText.length > _maxContentLength) {
      return context.l10n.postContentMaxLength;
    }
    if (countMarkdownImages(markdownContent) > _maxImagesPerPost) {
      return context.l10n.postImageLimitReached;
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    if (currentUser == null) {
      _showMessage(context.l10n.requiredLogin);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final service = getIt<CommunityService>();
    final imageService = getIt<ImageUploadService>();
    final uploadedUrls = <String>[];

    try {
      var content = await _uploadPendingImagesAndReplace(
        userId: currentUser.id,
        uploadedUrls: uploadedUrls,
      );

      final post = CommunityPost(
        id: widget.postId ?? '',
        userId: currentUser.id,
        title: _titleController.text.trim(),
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await service.updatePost(post);
      } else {
        await service.createPost(post);
      }

      if (isEditing) {
        await _deleteRemovedCommunityImages(
          before: _originalContent,
          after: content,
          imageService: imageService,
        );
      }

      _originalContent = content;
      _pendingImages.clear();
      _captureInitialSnapshot();

      if (mounted) {
        context.read<PostListCubit>().reload();
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        _popSafely();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? context.l10n.postUpdated : context.l10n.postCreated,
            ),
          ),
        );
      }
    } catch (e) {
      await _rollbackUploadedImages(
        uploadedUrls: uploadedUrls,
        imageService: imageService,
      );

      if (mounted) {
        _showMessage(
          UserErrorMessage.localize(
            context.l10n,
            UserErrorMessage.from(e, fallbackKey: 'postSaveFailed'),
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

  Future<String> _uploadPendingImagesAndReplace({
    required String userId,
    required List<String> uploadedUrls,
  }) async {
    final imageService = getIt<ImageUploadService>();
    final content = _currentMarkdownContent(trim: true);
    final imageUrls = extractImageUrlsFromMarkdown(content);
    final pendingUrls = imageUrls
        .where((url) => url.startsWith(pendingImageSchemePrefix))
        .toSet();

    if (pendingUrls.isEmpty) {
      return content;
    }

    _showMessage(context.l10n.postImageUploadPreparing);

    final replacements = <String, String>{};
    for (final pendingUrl in pendingUrls) {
      final pendingId = pendingUrl.substring(pendingImageSchemePrefix.length);
      final file = _pendingImages[pendingId];
      if (file == null) {
        throw const ImageUploadException('Missing pending image');
      }

      final uploadedUrl = await imageService.uploadImage(
        bucket: 'community',
        userId: userId,
        file: file,
      );

      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        throw const ImageUploadException('Image upload failed');
      }

      replacements[pendingUrl] = uploadedUrl;
      uploadedUrls.add(uploadedUrl);
    }

    _replacePendingImageEmbeds(replacements);

    var resolvedContent = _currentMarkdownContent(trim: true);
    if (resolvedContent.contains(pendingImageSchemePrefix)) {
      // Fallback: markdown 문자열에 pending이 남아있는 경우를 대비합니다.
      resolvedContent = replacePendingImageTokens(
        resolvedContent,
        replacements,
      );
    }

    return resolvedContent;
  }

  void _replacePendingImageEmbeds(Map<String, String> replacements) {
    if (replacements.isEmpty) return;

    final sourceDelta = _quillController.document.toDelta();
    final nextDelta = Delta();

    for (final operation in sourceDelta.toList()) {
      if (operation.isInsert && operation.data is Map) {
        final embedData = Map<String, dynamic>.from(
          operation.data as Map<dynamic, dynamic>,
        );

        if (embedData.containsKey(BlockEmbed.imageType)) {
          final currentUrl = embedData[BlockEmbed.imageType];
          if (currentUrl is String && replacements.containsKey(currentUrl)) {
            embedData[BlockEmbed.imageType] = replacements[currentUrl]!;
            nextDelta.push(Operation.insert(embedData, operation.attributes));
            continue;
          }
        }
      }

      nextDelta.push(operation);
    }

    _quillController.document = Document.fromDelta(nextDelta);
    final cursorOffset = (_quillController.document.length - 1)
        .clamp(0, _quillController.document.length)
        .toInt();
    _quillController.updateSelection(
      TextSelection.collapsed(offset: cursorOffset),
      ChangeSource.local,
    );
  }

  Future<void> _deleteRemovedCommunityImages({
    required String before,
    required String after,
    required ImageUploadService imageService,
  }) async {
    final beforeUrls = extractCommunityImageUrls(before);
    final afterUrls = extractCommunityImageUrls(after);
    final removedUrls = beforeUrls.difference(afterUrls);

    for (final url in removedUrls) {
      try {
        await imageService.deleteImage(bucket: 'community', imageUrl: url);
      } catch (_) {
        // 정리 실패는 게시글 저장을 막지 않습니다.
      }
    }
  }

  Future<void> _rollbackUploadedImages({
    required List<String> uploadedUrls,
    required ImageUploadService imageService,
  }) async {
    for (final uploadedUrl in uploadedUrls) {
      try {
        await imageService.deleteImage(
          bucket: 'community',
          imageUrl: uploadedUrl,
        );
      } catch (_) {
        // 롤백 정리 실패는 추가 예외를 발생시키지 않습니다.
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _currentTitle => _titleController.text.trim();

  String get _currentContent => _currentMarkdownContent(trim: true);

  void _captureInitialSnapshot() {
    _initialTitle = _currentTitle;
    _initialContent = _currentContent;
  }

  bool get _hasUnsavedChanges {
    if (_allowPop) return false;
    if (isEditing && !_isInitialized) return false;
    return _currentTitle != _initialTitle || _currentContent != _initialContent;
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
        context.pop(true);
      }
      return;
    }

    setState(() {
      _allowPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pop(true);
    });
  }

  Future<void> _handlePopInvoked() async {
    if (_isLoading) return;

    final shouldLeave = await _confirmLeaveIfNeeded();
    if (!mounted || !shouldLeave) return;

    _popSafely();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarActionColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;
    final appBarDisabledActionColor = appBarActionColor.withValues(alpha: 0.5);

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
                ? context.l10n.postFormEditTitle
                : context.l10n.postFormNewTitle,
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _handleSubmit,
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
                  CustomTextField(
                    label: context.l10n.postTitle,
                    hint: context.l10n.postTitleHint,
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.postTitleRequired;
                      }
                      final title = value.trim();
                      if (title.length < _minTitleLength) {
                        return context.l10n.postTitleMinLength;
                      }
                      if (title.length > _maxTitleLength) {
                        return context.l10n.postTitleMaxLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      context.l10n.postTitleCount(
                        _titleController.text.trim().length,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuillSimpleToolbar(
                    controller: _quillController,
                    config: QuillSimpleToolbarConfig(
                      showDividers: false,
                      showFontFamily: false,
                      showFontSize: false,
                      showBoldButton: true,
                      showItalicButton: true,
                      showUnderLineButton: true,
                      showStrikeThrough: true,
                      showLink: true,
                      showInlineCode: false,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showHeaderStyle: false,
                      showListNumbers: false,
                      showListBullets: false,
                      showListCheck: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showUndo: false,
                      showRedo: false,
                      showSearchButton: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showSmallButton: false,
                      showAlignmentButtons: false,
                      showIndent: false,
                      showDirection: false,
                      showLineHeightButton: false,
                      showClipboardCut: false,
                      showClipboardCopy: false,
                      showClipboardPaste: false,
                      customButtons: [
                        QuillToolbarCustomButtonOptions(
                          icon: const Icon(Icons.image_outlined),
                          tooltip: context.l10n.postImageInsert,
                          onPressed: _isLoading ? null : _insertImageEmbed,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormField<String>(
                    key: _contentFieldKey,
                    validator: _validateContent,
                    initialValue: _currentMarkdownContent(),
                    builder: (state) {
                      final borderColor = state.hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline.withValues(alpha: 0.3);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            constraints: const BoxConstraints(minHeight: 280),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QuillEditor(
                              focusNode: _editorFocusNode,
                              scrollController: _editorScrollController,
                              controller: _quillController,
                              config: QuillEditorConfig(
                                scrollable: false,
                                placeholder: context.l10n.postContentHint,
                                padding: const EdgeInsets.all(12),
                                embedBuilders: [
                                  _PostImageEmbedBuilder(
                                    pendingImagePathsByUrl:
                                        _pendingImagePathsByUrl,
                                  ),
                                  const _HorizontalRuleEmbedBuilder(),
                                ],
                                unknownEmbedBuilder:
                                    const _UnknownEmbedBuilder(),
                              ),
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                              child: Text(
                                state.errorText!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Text(
                                  context.l10n.postImageCount(_imageCount),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  context.l10n.postContentCount(
                                    _currentPlainTextContent(trim: true).length,
                                  ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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

class _PostImageEmbedBuilder extends EmbedBuilder {
  const _PostImageEmbedBuilder({required this.pendingImagePathsByUrl});

  final Map<String, String> pendingImagePathsByUrl;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final raw = embedContext.node.value.data;
    final imageUrl = raw is String ? raw : raw.toString();
    final uri = Uri.tryParse(imageUrl);

    if (uri?.scheme == 'pending') {
      final localPath = pendingImagePathsByUrl[imageUrl];
      if (localPath == null || localPath.isEmpty) {
        return _imagePlaceholder(context);
      }
      return _imageFrame(
        context,
        Image.file(
          File(localPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _imagePlaceholder(context),
        ),
      );
    }

    if (uri?.scheme == 'http' || uri?.scheme == 'https') {
      final normalizedImageUrl = imageUrl.trim();
      return _imageFrame(
        context,
        CachedNetworkImage(
          imageUrl: normalizedImageUrl,
          cacheManager: AppImageCachePolicy.cacheManager,
          cacheKey: AppImageCachePolicy.cacheKeyFor(normalizedImageUrl),
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _imagePlaceholder(context),
        ),
      );
    }

    return _imagePlaceholder(context);
  }

  Widget _imageFrame(BuildContext context, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 180, maxHeight: 280),
          child: child,
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: color.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _HorizontalRuleEmbedBuilder extends EmbedBuilder {
  const _HorizontalRuleEmbedBuilder();

  @override
  String get key => 'divider';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1),
    );
  }
}

class _UnknownEmbedBuilder extends EmbedBuilder {
  const _UnknownEmbedBuilder();

  @override
  String get key => 'unknown';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '[지원하지 않는 임베드: ${embedContext.node.value.type}]',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
