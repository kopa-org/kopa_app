import 'package:flutter/material.dart';
import 'package:kopa/helpers/mobile_pay_box_link.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/helpers/url_opener.dart';

class MobilePayButton extends StatelessWidget {
  final int? amount;
  final String? message;
  final String? mobilePayBoxId;
  final String? buttonText;

  const MobilePayButton({
    super.key,
    this.amount,
    this.message,
    this.mobilePayBoxId,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Button(
        buttonText: buttonText ??
            (amount != null && amount! > 0
                ? l10n.mobilePayAmount(amount!)
                : l10n.mobilePayGoToBox),
        onPressed: () async {
          final opened = await UrlOpener.openMobilePay(
            amount: amount,
            message: message,
            mobilePayBoxId: mobilePayBoxId,
          );
          if (!opened && context.mounted) {
            final invalidBox = mobilePayBoxId?.trim().isNotEmpty == true &&
                MobilePayBoxLink.boxId(mobilePayBoxId!) == null;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(invalidBox
                  ? l10n.mobilePayBoxLinkRequired
                  : l10n.mobilePayOpenFailed),
            ));
          }
        },
        outlined: true);
  }
}
