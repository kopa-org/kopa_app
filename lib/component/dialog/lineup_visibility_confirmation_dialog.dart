import 'package:flutter/cupertino.dart';
import 'package:kopa/l10n/app_localizations.dart';

class LineupVisibilityConfirmationDialog extends StatelessWidget {
  const LineupVisibilityConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoAlertDialog(
      content: Text(l10n.lineupVisibilityRevealMessage),
      actions: [
        CupertinoDialogAction(
          key: const ValueKey('lineup-visibility-reveal-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.lineupVisibilityRevealCancel),
        ),
        CupertinoDialogAction(
          key: const ValueKey('lineup-visibility-reveal-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.lineupVisibilityRevealConfirm),
        ),
      ],
    );
  }
}
