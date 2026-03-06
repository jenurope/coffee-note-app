import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

Future<bool> showCommunityContentPolicyConfirmDialog(
  BuildContext context,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 10),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(
            context.l10n.communityContentPolicyConfirmMessage,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(context.l10n.save),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
