import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';

/// Asks for a task name and pops with the trimmed text, or null on cancel.
///
/// The dialog owns its text controller so it is only disposed once the exit
/// animation has finished and the field is gone from the tree.
class TaskNameDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String? hint;
  final String initialName;

  const TaskNameDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    this.hint,
    this.initialName = '',
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String? hint,
    String initialName = '',
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => TaskNameDialog(
        title: title,
        confirmLabel: confirmLabel,
        hint: hint,
        initialName: initialName,
      ),
    );
    return (name == null || name.isEmpty) ? null : name;
  }

  @override
  State<TaskNameDialog> createState() => _TaskNameDialogState();
}

class _TaskNameDialogState extends State<TaskNameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const ValueKey('task-name-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.matchTasksNameLabel,
          hintText: widget.hint,
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.matchTasksCancel),
        ),
        FilledButton(
          key: const ValueKey('task-name-confirm'),
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
