import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';

/// One thing the user can create from a page, e.g. a match or a training.
class AddAction {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const AddAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

/// iOS puts a screen's create actions in the top-right of the navigation
/// bar, not in a floating button; Android keeps Material's FAB. Pages show
/// [NavBarAddButton] in their header when this is true, and their FAB
/// otherwise.
bool usesNavBarAddButton(BuildContext context) =>
    Theme.of(context).platform == TargetPlatform.iOS;

/// The iOS "+" button for a page header. One action runs straight away;
/// several open an action sheet to pick from.
class NavBarAddButton extends StatelessWidget {
  final List<AddAction> actions;

  /// Read by VoiceOver and shown as the action sheet's title.
  final String label;
  final Color? color;

  const NavBarAddButton({
    super.key,
    required this.actions,
    required this.label,
    this.color,
  });

  bool get _enabled => actions.any((action) => action.onPressed != null);

  Future<void> _showActions(BuildContext context) async {
    final picked = await showCupertinoModalPopup<AddAction>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(label),
        actions: [
          for (final action in actions)
            CupertinoActionSheetAction(
              onPressed: action.onPressed == null
                  ? () {}
                  : () => Navigator.of(sheetContext).pop(action),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.icon, size: 22),
                  const SizedBox(width: 10),
                  Text(action.label),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(AppLocalizations.of(context)!.onboardingCancel),
        ),
      ),
    );
    picked?.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = !_enabled
        ? null
        : actions.length == 1
            ? actions.single.onPressed
            : () => _showActions(context);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        // Apple's minimum tap target.
        minimumSize: const Size.square(44),
        onPressed: onPressed,
        child: Icon(
          CupertinoIcons.add,
          size: 28,
          color: color ?? AppColors.of(context).dirt,
        ),
      ),
    );
  }
}
