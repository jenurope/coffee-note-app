import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

Future<bool> showFormLeaveConfirmDialog(
  BuildContext context, {
  required bool isEditing,
}) async {
  final theme = Theme.of(context);
  final message = isEditing
      ? context.l10n.formLeaveConfirmEdit
      : context.l10n.formLeaveConfirmCreate;

  final shouldLeave = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: theme.textTheme.titleMedium),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(context.l10n.cancel),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(context.l10n.leave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return shouldLeave ?? false;
}
