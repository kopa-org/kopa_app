import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/fine_details.dart';
import 'package:kopa/model/fine_type_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/user_fine_details.dart';
import 'package:kopa/page/team_fines/team_fines_page.dart';
import 'package:kopa/theme/app_theme.dart';

final _now = DateTime(2026, 1, 10);

void main() {
  test('collected ignores spending from the box', () {
    final fineBox = _fineBox(current: 100, withdrawn: 300, owed: 50);
    expect(fineBox.collectedAmount, 400);
    expect(fineBox.totalAmount, 450);
  });

  testWidgets('players are listed by amount owed and open their fines',
      (tester) async {
    await tester.pumpWidget(_app(FineBoxPlayersPage(
      canDelete: false,
      loadFineBox: () async => _fineBox(),
    )));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Anna')).dy,
      lessThan(tester.getTopLeft(find.text('Bo')).dy),
    );
    expect(find.text('Alt betalt'), findsOneWidget);

    await tester.tap(find.text('Bo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Trøje'), findsOneWidget);
    expect(find.textContaining('For sent'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Anna'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history deletes unpaid fines after confirmation',
      (tester) async {
    final deleted = <int>[];
    var loads = 0;
    await tester.pumpWidget(_app(FineBoxHistoryPage(
      title: 'Alle bøder',
      canDelete: true,
      loadFineBox: () async {
        loads++;
        return _fineBox();
      },
      deleteFine: (id) async => deleted.add(id),
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('delete-fine-1')), findsOneWidget);
    // The paid fine has no delete action.
    expect(find.byKey(const ValueKey('delete-fine-2')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('delete-fine-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuller'));
    await tester.pumpAndSettle();
    expect(deleted, isEmpty);

    await tester.tap(find.byKey(const ValueKey('delete-fine-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slet bøde').last);
    await tester.pumpAndSettle();
    expect(deleted, [1]);
    expect(find.text('Bøden kunne ikke slettes. Prøv igen.'), findsNothing);
    expect(loads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('players without management rights cannot delete',
      (tester) async {
    await tester.pumpWidget(_app(FineBoxHistoryPage(
      title: 'Alle bøder',
      canDelete: false,
      loadFineBox: () async => _fineBox(),
    )));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('delete-fine-1')), findsNothing);
  });
}

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

FineBoxDetails _fineBox({
  double current = 0,
  double withdrawn = 0,
  double owed = 0,
}) {
  return FineBoxDetails(
    id: 1,
    currentAmount: current,
    totalOwedAmount: owed,
    createdAt: _now,
    updatedAt: _now,
    withdrawals: [
      if (withdrawn > 0)
        FineBoxWithdrawal(id: 1, amount: withdrawn, createdAt: _now),
    ],
    userFineDetails: [
      _userFines(2, 'Bo', [_fine(2, 'Trøje', 50, paid: true)]),
      _userFines(1, 'Anna', [_fine(1, 'For sent', 25, paid: false)]),
    ],
  );
}

UserFineDetails _userFines(int id, String name, List<FineDetails> fines) {
  return UserFineDetails(
    id: id,
    userDetails: UserDetails(
      id: id,
      name: name,
      email: '$name@example.com',
      isTeamOwner: false,
      roleId: 1,
      createdAt: _now,
      updatedAt: _now,
      teamDetails: null,
    ),
    fineDetailsList: fines,
  );
}

FineDetails _fine(int id, String title, int amount, {required bool paid}) {
  return FineDetails(
    id: id,
    fineTypeDetails: FineTypeDetails(
      id: id,
      title: title,
      defaultAmount: amount,
      createdAt: _now,
      updatedAt: _now,
    ),
    owedAmount: amount,
    hasBeenPaid: paid,
    createdAt: _now,
    updatedAt: _now,
  );
}
