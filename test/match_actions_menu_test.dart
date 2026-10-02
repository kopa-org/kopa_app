import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_actions_menu.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  for (final action in [
    'match-register-result-action',
    'create-external-player',
    'delete-match-action'
  ]) {
    testWidgets('menu dispatches $action', (tester) async {
      String? selected;
      await tester.pumpWidget(_app(MatchActionsMenu(
        isTraining: false,
        hasFinalScore: false,
        isAddingExternalPlayer: false,
        onDelete: () => selected = 'delete-match-action',
        onEnterResult: () => selected = 'match-register-result-action',
        onCreateExternalPlayer: () => selected = 'create-external-player',
        onEditTraining: () => selected = 'training',
      )));
      expect(find.text('Registrer resultat'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('match-actions-menu')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('delete-match-action')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('create-external-player')), findsOneWidget);
      await tester.tap(find.byKey(ValueKey(action)));
      await tester.pumpAndSettle();
      expect(selected, action);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'training keeps edit and delete actions without match-only options',
      (tester) async {
    var edits = 0;
    await tester.pumpWidget(_app(MatchActionsMenu(
      isTraining: true,
      hasFinalScore: false,
      isAddingExternalPlayer: false,
      onDelete: () {},
      onEnterResult: () {},
      onCreateExternalPlayer: () {},
      onEditTraining: () => edits++,
    )));
    await tester.tap(find.byKey(const ValueKey('match-actions-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('match-register-result-action')),
        findsNothing);
    expect(find.byKey(const ValueKey('create-external-player')), findsNothing);
    final editItem = find.byKey(const ValueKey('edit-training-action'));
    await tester.tap(editItem);
    await tester.pumpAndSettle();
    expect(edits, 1);
  });
}

Widget _app(Widget menu) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(appBar: AppBar(actions: [menu])),
    );
