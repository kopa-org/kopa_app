import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/helpers/url_opener.dart';

void main() {
  group('UrlOpener MobilePay Box URLs', () {
    test('converts kroner to minor units for Box amount parameter', () {
      final uri = UrlOpener.mobilePayBoxUriFromIdForTesting(
        'test-box',
        amount: 100,
        message: 'Bøder - Test',
      );

      expect(uri.toString(), contains('/box/test-box/pay-in'));
      expect(uri.queryParameters['amount'], '10000');
      expect(uri.queryParameters['message'], 'Bøder - Test');
    });

    test('keeps existing query parameters and skips empty optional values', () {
      final uri = UrlOpener.mobilePayBoxUriForTesting(
        'https://qr.mobilepay.dk/box/test-box/pay-in?source=kopa',
        amount: 0,
        message: '  ',
      );

      expect(uri.queryParameters, {'source': 'kopa'});
    });
  });
}
