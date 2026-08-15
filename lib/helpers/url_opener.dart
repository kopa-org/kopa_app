import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlOpener {
  static const _appStoreUrl = 'https://apps.apple.com/dk/app/624499138';

  static Future<bool> openMobilePay({
    int? amount,
    String? message,
    String? mobilePayBoxId,
  }) async {
    final number = dotenv.maybeGet('MOBILEPAY_NUMBER')?.trim();
    final boxUrl = dotenv.maybeGet('MOBILEPAY_BOX_URL')?.trim();
    final configuredBoxId = mobilePayBoxId?.trim();

    if (configuredBoxId != null && configuredBoxId.isNotEmpty) {
      final target = _mobilePayBoxUriFromId(
        configuredBoxId,
        amount: amount,
        message: message,
      );

      if (await _launch(target)) {
        return true;
      }
    }

    if (number != null && number.isNotEmpty) {
      final deeplink = Uri(
        scheme: 'mobilepay',
        host: 'send',
        queryParameters: {
          'phone': number,
          if (amount != null && amount > 0) 'amount': amount.toString(),
          if (message != null && message.trim().isNotEmpty)
            'comment': message.trim(),
        },
      );

      if (await _launch(deeplink)) {
        return true;
      }
    }

    final target = boxUrl != null && boxUrl.isNotEmpty
        ? _mobilePayBoxUri(boxUrl, amount: amount, message: message)
        : null;

    if (target != null && await _launch(target)) {
      return true;
    }

    return _launch(Uri.parse(_appStoreUrl));
  }

  static Uri _mobilePayBoxUri(
    String rawUrl, {
    int? amount,
    String? message,
  }) {
    final uri = Uri.parse(rawUrl);
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        if (amount != null && amount > 0)
          'amount': _mobilePayBoxAmount(amount).toString(),
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );
  }

  static Uri _mobilePayBoxUriFromId(
    String boxId, {
    int? amount,
    String? message,
  }) {
    return _mobilePayBoxUri(
      'https://qr.mobilepay.dk/box/${Uri.encodeComponent(boxId)}/pay-in',
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
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
