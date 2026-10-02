import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/button/mobile_pay_button.dart';
import 'package:kopa/helpers/mobile_pay_box_link.dart';
import 'package:kopa/helpers/url_opener.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/team_fines/mobile_pay_setup_modal.dart';

const _id = '518aff76-4902-4482-ae1d-967fde993155';
const _url = 'https://qr.mobilepay.dk/box/$_id/pay-in';

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final launches = <String>[];
  var appInstalled = true;
  var webAvailable = true;

  setUp(() {
    launches.clear();
    appInstalled = true;
    webAvailable = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'launch') return false;
      final url = (call.arguments as Map)['url'] as String;
      launches.add(url);
      if (url.startsWith('mobilepay:') && !appInstalled) {
        throw PlatformException(code: 'ACTIVITY_NOT_FOUND');
      }
      return url.startsWith('mobilepay:') || webAvailable;
    });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('shared link and stored UUID identify the same Box', () {
    expect(MobilePayBoxLink.boxId(' $_url '), _id);
    expect(MobilePayBoxLink.webUri(_id).toString(), _url);
    for (final invalid in [
      '5289PN',
      'https://example.org/box/$_id/pay-in',
      'https://qr.mobilepay.dk/box/5289PN/pay-in',
      'not a link'
    ]) {
      expect(MobilePayBoxLink.boxId(invalid), isNull);
    }
  });

  test('opens the installed app directly with the Box and amount', () async {
    expect(
        await UrlOpener.openMobilePay(mobilePayBoxId: _id, amount: 25), isTrue);
    expect(launches, ['mobilepay://box/$_id/pay-in?amount=2500']);
  });

  test('falls back to the Box web link after an asynchronous app failure',
      () async {
    appInstalled = false;
    expect(await UrlOpener.openMobilePay(mobilePayBoxId: _url), isTrue);
    expect(launches, ['mobilepay://box/$_id/pay-in', _url]);
  });

  testWidgets('payment failure is visible instead of silently discarded',
      (tester) async {
    appInstalled = false;
    webAvailable = false;
    await tester.pumpWidget(_app(const MobilePayButton(mobilePayBoxId: _id)));
    await tester.tap(find.text('Go to MobilePay Box'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Could not open MobilePay. Check that the app is installed and try again.'),
        findsOneWidget);
  });

  testWidgets('legacy short codes explain how to repair the Box link',
      (tester) async {
    await tester
        .pumpWidget(_app(const MobilePayButton(mobilePayBoxId: '5289PN')));
    await tester.tap(find.text('Go to MobilePay Box'));
    await tester.pumpAndSettle();
    expect(launches, isEmpty);
    expect(find.textContaining('Ask the team owner to edit'), findsOneWidget);
  });

  testWidgets('editing prefills existing link and saves replacement UUID',
      (tester) async {
    String? saved;
    await tester.pumpWidget(_app(MobilePaySetupModal(
      initialValue: _id,
      saveBox: (value) async {
        saved = value;
        return true;
      },
    )));
    final field = find.byType(CupertinoTextField);
    expect(tester.widget<CupertinoTextField>(field).controller!.text, _url);
    const replacement = '11111111-2222-3333-4444-555555555555';
    await tester.enterText(
        field, 'https://qr.mobilepay.dk/box/$replacement/pay-in');
    await tester.tap(find.text('Save MobilePay Box'));
    await tester.pumpAndSettle();
    expect(saved, replacement);
  });

  testWidgets('invalid setup never saves and failed saves remain editable',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(MobilePaySetupModal(
      initialValue: '5289PN',
      saveBox: (_) async {
        calls++;
        throw Exception('network');
      },
    )));
    await tester.tap(find.text('Save MobilePay Box'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.textContaining('A short code such as'), findsOneWidget);
    await tester.enterText(find.byType(CupertinoTextField), _url);
    await tester.tap(find.text('Save MobilePay Box'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
        find.text('Could not save MobilePay Box. Try again.'), findsOneWidget);
    expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .enabled,
        isTrue);
  });
}
