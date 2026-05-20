import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlOpener {
  static const _defaultMobilePayBoxUrl =
      'https://qr.mobilepay.dk/box/74f833d8-ca7f-496c-8c2e-2302f9fbc58e/pay-in';
  static const _appStoreUrl = 'https://apps.apple.com/dk/app/624499138';

  static Future<bool> openMobilePay({
    int? amount,
    String? message,
  }) async {
    final number = dotenv.maybeGet('MOBILEPAY_NUMBER')?.trim();
    final boxUrl = dotenv.maybeGet('MOBILEPAY_BOX_URL')?.trim();

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

    final target = _mobilePayBoxUri(
      boxUrl == null || boxUrl.isEmpty ? _defaultMobilePayBoxUrl : boxUrl,
      amount: amount,
      message: message,
    );

    if (await _launch(target)) {
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
        if (amount != null && amount > 0) 'amount': amount.toString(),
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );
  }

  static Future<bool> _launch(Uri uri) async {
    try {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
