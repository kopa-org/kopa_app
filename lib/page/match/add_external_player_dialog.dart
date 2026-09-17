import 'package:flutter/cupertino.dart';
import 'package:kopa/l10n/app_localizations.dart';

Future<String?> showAddExternalPlayerDialog(BuildContext context) {
  return showCupertinoDialog<String>(
    context: context,
    builder: (_) => const _AddExternalPlayerDialog(),
  );
}

class _AddExternalPlayerDialog extends StatefulWidget {
  const _AddExternalPlayerDialog();

  @override
  State<_AddExternalPlayerDialog> createState() =>
      _AddExternalPlayerDialogState();
}

class _AddExternalPlayerDialogState extends State<_AddExternalPlayerDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAdd = _controller.text.trim().isNotEmpty;

    return CupertinoAlertDialog(
      title: Text(l10n.externalPlayerTitle),
      content: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CupertinoTextField(
          key: const ValueKey('external-player-name-field'),
          controller: _controller,
          autofocus: true,
          placeholder: l10n.externalPlayerNameHint,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          key: const ValueKey('external-player-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.externalPlayerCancel),
        ),
        CupertinoDialogAction(
          key: const ValueKey('external-player-add'),
          isDefaultAction: true,
          onPressed: canAdd
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: Text(l10n.externalPlayerAdd),
        ),
      ],
    );
  }
}
