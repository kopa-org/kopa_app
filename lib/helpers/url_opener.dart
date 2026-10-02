import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kopa/helpers/mobile_pay_box_link.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlOpener {
  static Future<bool> openMobilePay({
    int? amount,
    String? message,
    String? mobilePayBoxId,
  }) async {
    final configuredBox = mobilePayBoxId?.trim();
    final box = configuredBox != null && configuredBox.isNotEmpty
        ? configuredBox
        : dotenv.maybeGet('MOBILEPAY_BOX_URL')?.trim();
    if (box != null && box.isNotEmpty) {
      final uri = MobilePayBoxLink.webUri(box);
      // A short Box code cannot be substituted for the shared link's UUID.
      if (uri == null) return false;
      final target =
          _mobilePayBoxUri(uri.toString(), amount: amount, message: message);
      final appLink = Uri(
        scheme: 'mobilepay',
        host: 'box',
        path: target.path.substring('/box'.length),
        queryParameters:
            target.queryParameters.isEmpty ? null : target.queryParameters,
      );
      if (await _launch(appLink)) return true;
      return _launch(target);
    }

    final number = dotenv.maybeGet('MOBILEPAY_NUMBER')?.trim();
    if (number == null || number.isEmpty) return false;
    return _launch(Uri(
      scheme: 'mobilepay',
      host: 'send',
      queryParameters: {
        'phone': number,
        if (amount != null && amount > 0) 'amount': amount.toString(),
        if (message != null && message.trim().isNotEmpty)
          'comment': message.trim(),
      },
    ));
  }

  static Uri _mobilePayBoxUri(
    String rawUrl, {
    int? amount,
    String? message,
  }) {
    final uri = Uri.parse(rawUrl);
    final parameters = {
      ...uri.queryParameters,
      if (amount != null && amount > 0)
        'amount': _mobilePayBoxAmount(amount).toString(),
      if (message != null && message.trim().isNotEmpty)
        'message': message.trim(),
    };
    return parameters.isEmpty ? uri : uri.replace(queryParameters: parameters);
  }

  static Uri _mobilePayBoxUriFromId(
    String boxId, {
    int? amount,
    String? message,
  }) {
    return _mobilePayBoxUri(
      MobilePayBoxLink.webUri(boxId)!.toString(),
      amount: amount,
      message: message,
    );
  }

  static Uri mobilePayBoxUriForTesting(
    String rawUrl, {
    int? amount,
    String? message,
  }) {
    return _mobilePayBoxUri(rawUrl, amount: amount, message: message);
  }

  static Uri mobilePayBoxUriFromIdForTesting(
    String boxId, {
    int? amount,
    String? message,
  }) {
    return _mobilePayBoxUriFromId(boxId, amount: amount, message: message);
  }

  static int _mobilePayBoxAmount(int amountInKroner) => amountInKroner * 100;

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
