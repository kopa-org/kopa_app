import 'package:flutter/cupertino.dart';
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
    return Button(
        buttonText: buttonText ??
            (amount != null && amount! > 0
                ? 'Betal $amount kr. med MobilePay'
                : 'Gå til MobilePay Box'),
        onPressed: () {
          UrlOpener.openMobilePay(
            amount: amount,
            message: message,
            mobilePayBoxId: mobilePayBoxId,
          );
        },
        outlined: true);
  }
}
