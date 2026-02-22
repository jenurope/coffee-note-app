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

class ServiceInquiryListScreen extends StatefulWidget {
  const ServiceInquiryListScreen({super.key, this.service});

  final ServiceInquiryService? service;

  @override
  State<ServiceInquiryListScreen> createState() =>
      _ServiceInquiryListScreenState();
}

class _ServiceInquiryListScreenState extends State<ServiceInquiryListScreen> {
  bool _didLoad = false;
  bool _isLoading = false;
  String? _errorMessageKey;
  List<ServiceInquiry> _items = const <ServiceInquiry>[];

  ServiceInquiryService get _service =>
      widget.service ?? getIt<ServiceInquiryService>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _load();
  }

  Future<void> _load() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _items = const <ServiceInquiry>[];
        _isLoading = false;
        _errorMessageKey = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessageKey = null;
    });

    try {
      final items = await _service.getMyInquiries(authState.user.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessageKey = UserErrorMessage.from(
          e,
          fallbackKey: 'inquiryLoadFailed',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openNewInquiry() async {
    final created = await context.push<bool>('/profile/inquiries/new');
    if (created == true && mounted) {
      await _load();
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

  String _statusLabel(InquiryStatus status) {
    final l10n = context.l10n;
    return switch (status) {
      InquiryStatus.pending => l10n.inquiryStatusPending,
      InquiryStatus.inProgress => l10n.inquiryStatusInProgress,
      InquiryStatus.resolved => l10n.inquiryStatusResolved,
      InquiryStatus.closed => l10n.inquiryStatusClosed,
    };
  }

  Color _statusColor(InquiryStatus status, ColorScheme colorScheme) {
    return switch (status) {
      InquiryStatus.pending => colorScheme.outline,
      InquiryStatus.inProgress => colorScheme.primary,
      InquiryStatus.resolved => Colors.green.shade700,
      InquiryStatus.closed => colorScheme.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.inquiryListTitle)),
            body: EmptyState(
              icon: Icons.lock_outline,
              title: context.l10n.requiredLogin,
              subtitle: context.l10n.inquiryListLoginRequired,
              buttonText: context.l10n.loginNow,
              onButtonPressed: () {
                context.read<AuthCubit>().exitGuestMode();
                context.go('/auth/login');
              },
            ),
          );
        }

        if (_isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.inquiryListTitle)),
            body: const Center(child: CircularProgressIndicator()),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openNewInquiry,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.inquiryNewAction),
            ),
          );
        }

        if (_errorMessageKey != null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.inquiryListTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: UserErrorMessage.localize(context.l10n, _errorMessageKey!),
              buttonText: context.l10n.retry,
              onButtonPressed: _load,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openNewInquiry,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.inquiryNewAction),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.inquiryListTitle)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openNewInquiry,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.inquiryNewAction),
          ),
          body: _items.isEmpty
              ? EmptyState(
                  icon: Icons.support_agent,
                  title: context.l10n.inquiryEmptyTitle,
                  subtitle: context.l10n.inquiryEmptySubtitle,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final statusColor = _statusColor(
                      item.status,
                      Theme.of(context).colorScheme,
                    );
                    final answer = item.adminResponse?.trim();
                    final hasAnswer = answer != null && answer.isNotEmpty;
                    final localizations = MaterialLocalizations.of(context);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _typeLabel(item.inquiryType),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _statusLabel(item.status),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(item.content),
                            const SizedBox(height: 8),
                            Text(
                              localizations.formatMediumDate(item.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                hasAnswer
                                    ? '${context.l10n.inquiryAnswerLabel}\n$answer'
                                    : context.l10n.inquiryAnswerPending,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
