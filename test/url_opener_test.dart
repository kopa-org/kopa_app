import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/helpers/url_opener.dart';

void main() {
  group('UrlOpener MobilePay Box URLs', () {
    test('converts kroner to minor units for Box amount parameter', () {
      final uri = UrlOpener.mobilePayBoxUriFromIdForTesting(
        '518aff76-4902-4482-ae1d-967fde993155',
        amount: 100,
        message: 'Bøder - Test',
      );

      expect(uri.toString(),
          contains('/box/518aff76-4902-4482-ae1d-967fde993155/pay-in'));
      expect(uri.queryParameters['amount'], '10000');
      expect(uri.queryParameters['message'], 'Bøder - Test');
    });

    test('keeps existing query parameters and skips empty optional values', () {
      final uri = UrlOpener.mobilePayBoxUriForTesting(
        'https://qr.mobilepay.dk/box/518aff76-4902-4482-ae1d-967fde993155/pay-in?source=kopa',
        amount: 0,
        message: '  ',
      );

      expect(uri.queryParameters, {'source': 'kopa'});
    });
  });
}
