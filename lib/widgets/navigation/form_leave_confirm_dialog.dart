import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

Future<bool> showFormLeaveConfirmDialog(
  BuildContext context, {
  required bool isEditing,
}) async {
  final shouldLeave = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(
        isEditing
            ? context.l10n.formLeaveConfirmEdit
            : context.l10n.formLeaveConfirmCreate,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.leave),
        ),
      ],
    ),
  );

  return shouldLeave ?? false;
}
