import 'package:flutter/cupertino.dart';
import 'package:kopa/l10n/app_localizations.dart';

enum LineupUnsavedChangesAction { save, discard }

class LineupUnsavedChangesDialog extends StatelessWidget {
  const LineupUnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoAlertDialog(
      title: Text(l10n.lineupUnsavedChangesTitle),
      content: Text(l10n.lineupUnsavedChangesMessage),
      actions: [
        CupertinoDialogAction(
          key: const ValueKey('lineup-unsaved-discard'),
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(
            LineupUnsavedChangesAction.discard,
          ),
          child: Text(l10n.lineupUnsavedChangesDiscard),
        ),
        CupertinoDialogAction(
          key: const ValueKey('lineup-unsaved-save'),
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(
            LineupUnsavedChangesAction.save,
          ),
          child: Text(l10n.lineupUnsavedChangesSave),
        ),
      ],
    );
  }
}
