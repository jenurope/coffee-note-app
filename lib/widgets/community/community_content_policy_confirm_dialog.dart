import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

Future<bool> showCommunityContentPolicyConfirmDialog(
  BuildContext context,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(context.l10n.communityContentPolicyConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(context.l10n.save),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
