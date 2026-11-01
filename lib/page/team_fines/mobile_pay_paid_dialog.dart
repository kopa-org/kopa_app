import 'package:flutter/cupertino.dart';
import 'package:kopa/l10n/app_localizations.dart';

/// Asks whether the player finished the payment in MobilePay.
Future<bool> showMobilePayPaidDialog(BuildContext context, int amount) async {
  final l10n = AppLocalizations.of(context)!;
  final paid = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      key: const ValueKey('mobile-pay-paid-dialog'),
      title: Text(l10n.mobilePayPaidTitle(amount)),
      content: Text(l10n.mobilePayPaidBody),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.mobilePayPaidNo),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.mobilePayPaidYes),
        ),
      ],
    ),
  );
  return paid ?? false;
}
