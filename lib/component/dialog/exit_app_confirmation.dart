import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kopa/l10n/app_localizations.dart';

/// Wraps a main tab's root page so a system back gesture there asks before
/// closing the app, instead of closing it straight away.
///
/// go_router asks the tab's own navigator first, so this only intercepts the
/// back gesture when nothing is pushed on top of the tab; pushed pages still
/// pop normally.
class ExitAppConfirmationScope extends StatefulWidget {
  final Widget child;

  const ExitAppConfirmationScope({super.key, required this.child});

  @override
  State<ExitAppConfirmationScope> createState() =>
      _ExitAppConfirmationScopeState();
}

class _ExitAppConfirmationScopeState extends State<ExitAppConfirmationScope> {
  bool _isAsking = false;

  Future<void> _confirmExit() async {
    // A second back gesture while the dialog is open closes the dialog
    // (it is the top route), so only one dialog is ever shown.
    if (_isAsking) return;
    _isAsking = true;
    final shouldExit = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ExitAppConfirmationDialog(),
    );
    _isAsking = false;
    if (shouldExit == true) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: widget.child,
    );
  }
}

class ExitAppConfirmationDialog extends StatelessWidget {
  const ExitAppConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoAlertDialog(
      title: Text(l10n.appExitConfirmTitle),
      content: Text(l10n.appExitConfirmMessage),
      actions: [
        CupertinoDialogAction(
          key: const ValueKey('app-exit-confirm-exit'),
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.appExitConfirmExit),
        ),
        CupertinoDialogAction(
          key: const ValueKey('app-exit-confirm-stay'),
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.appExitConfirmStay),
        ),
      ],
    );
  }
}
