import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_external_player_fab.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('runs its action and can be disabled while saving',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(
      MatchExternalPlayerFab(matchId: 42, onPressed: () => taps++),
    ));
    await tester.tap(find.text('Tilføj ekst. spiller'));
    expect(taps, 1);

    await tester.pumpWidget(_app(
      const MatchExternalPlayerFab(matchId: 42, onPressed: null),
    ));
    expect(
      tester
          .widget<FloatingActionButton>(
            find.byKey(const ValueKey('match-external-player-fab')),
          )
          .onPressed,
      isNull,
    );
  });
}

Widget _app(Widget fab) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(floatingActionButton: fab),
    );
