import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../l10n/l10n.dart';
import '../../models/service_inquiry.dart';
import '../../services/service_inquiry_service.dart';
import '../../widgets/common/common_widgets.dart';

class ServiceInquiryFormScreen extends StatefulWidget {
  const ServiceInquiryFormScreen({
    super.key,
    this.service,
    this.allowGuest = false,
  });

  final ServiceInquiryService? service;
  final bool allowGuest;

  @override
  State<ServiceInquiryFormScreen> createState() =>
      _ServiceInquiryFormScreenState();
}

class _ServiceInquiryFormScreenState extends State<ServiceInquiryFormScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _emailController = TextEditingController();

  InquiryType _inquiryType = InquiryType.general;
  bool _personalInfoConsent = false;
  bool _isSubmitting = false;
  bool _didInitializeAuthDefaults = false;

  ServiceInquiryService get _service =>
      widget.service ?? getIt<ServiceInquiryService>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitializeAuthDefaults) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _emailController.text = authState.user.email ?? '';
      _personalInfoConsent = true;
    }

    _didInitializeAuthDefaults = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthState authState) async {
    if (_isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    final isAuthenticated = authState is AuthAuthenticated;
    if (!isAuthenticated && !widget.allowGuest) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    if (!isAuthenticated && !_personalInfoConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.inquiryGuestConsentRequired)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = switch (authState) {
        AuthAuthenticated(user: final user) => user.id,
        _ => null,
      };
      final inquiry = ServiceInquiry(
        id: '',
        userId: userId,
        inquiryType: _inquiryType,
        status: InquiryStatus.pending,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        email: _emailController.text.trim(),
        personalInfoConsent: isAuthenticated ? true : _personalInfoConsent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.createInquiry(inquiry);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.inquirySubmitSuccess)),
      );
      if (context.canPop()) {
        context.pop(true);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      final messageKey = UserErrorMessage.from(
        e,
        fallbackKey: 'inquirySubmitFailed',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(UserErrorMessage.localize(context.l10n, messageKey)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _typeLabel(InquiryType type) {
    final l10n = context.l10n;
    return switch (type) {
      InquiryType.general => l10n.inquiryTypeGeneral,
      InquiryType.bug => l10n.inquiryTypeBug,
      InquiryType.feature => l10n.inquiryTypeFeature,
      InquiryType.account => l10n.inquiryTypeAccount,
      InquiryType.technical => l10n.inquiryTypeTechnical,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is AuthAuthenticated;
        final guestAllowed = widget.allowGuest || isAuthenticated;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isAuthenticated
                  ? context.l10n.inquiryFormTitleUser
                  : context.l10n.inquiryFormTitleGuest,
            ),
          ),
          body: LoadingOverlay(
            isLoading: _isSubmitting,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<InquiryType>(
                        initialValue: _inquiryType,
                        decoration: InputDecoration(
                          labelText: context.l10n.inquiryTypeLabel,
                        ),
                        items: InquiryType.values
                            .map(
                              (type) => DropdownMenuItem<InquiryType>(
                                value: type,
                                child: Text(_typeLabel(type)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() {
                                  _inquiryType = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: context.l10n.inquiryTitleLabel,
                        hint: context.l10n.inquiryTitleHint,
                        controller: _titleController,
                        enabled: !_isSubmitting,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return context.l10n.inquiryTitleRequired;
                          }
                          if (text.length < 2) {
                            return context.l10n.inquiryTitleLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: context.l10n.inquiryContentLabel,
                        hint: context.l10n.inquiryContentHint,
                        controller: _contentController,
                        enabled: !_isSubmitting,
                        maxLines: 6,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return context.l10n.inquiryContentRequired;
                          }
                          if (text.length < 5) {
                            return context.l10n.inquiryContentLength;
                          }
                          return null;
                        },
                      ),
                      if (!isAuthenticated) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: context.l10n.inquiryEmailLabel,
                          hint: context.l10n.inquiryEmailHint,
                          controller: _emailController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return context.l10n.inquiryEmailRequired;
                            }
                            if (!_emailRegex.hasMatch(text)) {
                              return context.l10n.inquiryEmailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _personalInfoConsent,
                          onChanged: _isSubmitting
                              ? null
                              : (value) {
                                  setState(() {
                                    _personalInfoConsent = value ?? false;
                                  });
                                },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(context.l10n.inquiryGuestConsentLabel),
                        ),
                      ],
                      const SizedBox(height: 24),
                      CustomButton(
                        text: context.l10n.inquirySubmitAction,
                        onPressed: _isSubmitting || !guestAllowed
                            ? null
                            : () => _submit(authState),
                        isLoading: _isSubmitting,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
