import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/team_fines/withdraw_modal.dart';
import 'package:kopa/repository/fines_repository.dart';

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('records a withdrawal with an optional note', (tester) async {
    final calls = <(int, String?)>[];
    await tester.pumpWidget(_app(WithdrawModal(
      currentAmount: 300,
      withdraw: (amount, {note}) async => calls.add((amount, note)),
    )));

    expect(find.textContaining('300 kr.'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('withdraw-amount')), '120');
    await tester.enterText(
        find.byKey(const ValueKey('withdraw-note')), ' Sæsonfest ');
    await tester.tap(find.byKey(const ValueKey('withdraw-save')));
    await tester.pumpAndSettle();

    expect(calls, [(120, 'Sæsonfest')]);
  });

  testWidgets('rejects empty amounts and more than the box holds',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(WithdrawModal(
      currentAmount: 100,
      withdraw: (amount, {note}) async => calls++,
    )));

    await tester.tap(find.byKey(const ValueKey('withdraw-save')));
    await tester.pump();
    expect(find.text('Indtast et beløb større end 0 kr.'), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('withdraw-amount')), '101');
    await tester.tap(find.byKey(const ValueKey('withdraw-save')));
    await tester.pump();
    expect(find.text('Der er ikke så mange penge i kassen.'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('shows the server refusing an overdraw', (tester) async {
    await tester.pumpWidget(_app(WithdrawModal(
      currentAmount: 100,
      withdraw: (amount, {note}) async => throw InsufficientFundsException(),
    )));

    await tester.enterText(find.byKey(const ValueKey('withdraw-amount')), '50');
    await tester.tap(find.byKey(const ValueKey('withdraw-save')));
    await tester.pumpAndSettle();
    expect(find.text('Der er ikke så mange penge i kassen.'), findsOneWidget);
  });
}
