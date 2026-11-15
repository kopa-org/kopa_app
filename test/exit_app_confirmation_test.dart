import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/dialog/exit_app_confirmation.dart';
import 'package:kopa/l10n/app_localizations.dart';

void main() {
  Widget app() => const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ExitAppConfirmationScope(child: Scaffold(body: Text('tab'))),
      );

  testWidgets('back on a root tab asks before closing the app',
      (tester) async {
    await tester.pumpWidget(app());

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Close Kopa?'), findsOneWidget);
    expect(find.text('tab'), findsOneWidget);
  });

  testWidgets('choosing Stay keeps the tab open', (tester) async {
    await tester.pumpWidget(app());

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('app-exit-confirm-stay')));
    await tester.pumpAndSettle();

    expect(find.text('Close Kopa?'), findsNothing);
    expect(find.text('tab'), findsOneWidget);
  });
}
