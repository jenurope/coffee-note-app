import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../l10n/l10n.dart';
import '../../models/terms/term_policy.dart';

class TermsConsentScreen extends StatefulWidget {
  const TermsConsentScreen({super.key});

  @override
  State<TermsConsentScreen> createState() => _TermsConsentScreenState();
}

class _TermsConsentScreenState extends State<TermsConsentScreen> {
  bool _didLoad = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<TermPolicy> _terms = const <TermPolicy>[];
  final Map<String, bool> _decisions = <String, bool>{};
  final Map<String, bool> _expandedByCode = <String, bool>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final localeCode = Localizations.localeOf(context).languageCode;
      final terms = await context.read<AuthCubit>().fetchActiveTerms(
        localeCode: localeCode,
      );

      if (!mounted) return;

      final nextDecisions = <String, bool>{};
      final nextExpanded = <String, bool>{};
      for (final term in terms) {
        nextDecisions[term.code] = _decisions[term.code] ?? false;
        nextExpanded[term.code] = _expandedByCode[term.code] ?? true;
      }

      setState(() {
        _terms = terms;
        _decisions
          ..clear()
          ..addAll(nextDecisions);
        _expandedByCode
          ..clear()
          ..addAll(nextExpanded);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorToast('errTermsLoadFailed');
    }
  }

  bool get _allRequiredAgreed {
    for (final term in _terms) {
      if (term.isRequired && _decisions[term.code] != true) {
        return false;
      }
    }
    return true;
  }

  Future<void> _handleAgree() async {
    if (_isSubmitting || !_allRequiredAgreed) {
      return;
    }
    final authCubit = context.read<AuthCubit>();

    setState(() {
      _isSubmitting = true;
    });
    await WidgetsBinding.instance.endOfFrame;

    try {
      final errorMessage = await authCubit.acceptTermsConsents(_decisions);
      if (!mounted) return;

      if (errorMessage != null) {
        _showErrorToast(errorMessage);
      }
    } catch (_) {
      if (!mounted) return;
      _showErrorToast('errTermsConsentFailed');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleDecline() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<AuthCubit>().declineTerms();
    } catch (_) {
      if (!mounted) return;
      _showErrorToast('errTermsConsentFailed');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorToast(String errorKey) {
    final message = UserErrorMessage.localize(context.l10n, errorKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.termsConsentTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.termsConsentSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.termsRequiredHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _terms.isEmpty
                      ? Center(
                          child: Text(
                            l10n.termsEmpty,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: _terms.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final term = _terms[index];
                            final agreed = _decisions[term.code] ?? false;
                            final isExpanded =
                                _expandedByCode[term.code] ?? true;
                            return _TermConsentCard(
                              term: term,
                              agreed: agreed,
                              isExpanded: isExpanded,
                              onChanged: (checked) {
                                setState(() {
                                  _decisions[term.code] = checked;
                                  if (checked) {
                                    _expandedByCode[term.code] = false;
                                  }
                                });
                              },
                              onToggleExpanded: () {
                                setState(() {
                                  _expandedByCode[term.code] = !isExpanded;
                                });
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  key: const Key('terms-accept-button'),
                  onPressed:
                      _isSubmitting || _terms.isEmpty || !_allRequiredAgreed
                      ? null
                      : _handleAgree,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            key: Key('terms-accept-progress'),
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.termsAgreeAndContinue),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('terms-decline-button'),
                  onPressed: _isSubmitting ? null : _handleDecline,
                  child: Text(l10n.termsDeclineAndLogout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermConsentCard extends StatelessWidget {
  const _TermConsentCard({
    required this.term,
    required this.agreed,
    required this.isExpanded,
    required this.onChanged,
    required this.onToggleExpanded,
  });

  final TermPolicy term;
  final bool agreed;
  final bool isExpanded;
  final ValueChanged<bool> onChanged;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final agreementTypeLabel = term.isRequired
        ? l10n.termsRequiredLabel
        : l10n.termsOptionalLabel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  key: Key('term-checkbox-${term.code}'),
                  value: agreed,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onToggleExpanded,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('($agreementTypeLabel) ${term.title}'),
                    ),
                  ),
                ),
                IconButton(
                  key: Key('term-toggle-${term.code}'),
                  onPressed: onToggleExpanded,
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              ],
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: SelectableText(
                  term.content,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
