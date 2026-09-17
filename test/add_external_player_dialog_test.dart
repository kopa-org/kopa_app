import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/match/add_external_player_dialog.dart';

void main() {
  testWidgets('adding an external player returns the trimmed name',
      (tester) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showAddExternalPlayerDialog(context);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Tilføj lånespiller'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('external-player-name-field')),
      '  Guest Player  ',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('external-player-add')));
    await tester.pumpAndSettle();

    expect(result, 'Guest Player');
  });
}
