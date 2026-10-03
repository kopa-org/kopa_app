import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_actions_menu.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  for (final isTraining in [false, true]) {
    testWidgets('menu only offers deletion: training=$isTraining',
        (tester) async {
      var deletions = 0;
      await tester.pumpWidget(_app(MatchActionsMenu(
        isTraining: isTraining,
        onDelete: () => deletions++,
      )));
      await tester.tap(find.byKey(const ValueKey('match-actions-menu')));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is PopupMenuItem),
          findsOneWidget);
      expect(find.byKey(const ValueKey('match-register-result-action')),
          findsNothing);
      expect(
          find.byKey(const ValueKey('create-external-player')), findsNothing);
      expect(find.byKey(const ValueKey('edit-training-action')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('delete-match-action')));
      await tester.pumpAndSettle();
      expect(deletions, 1);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _app(Widget menu) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(appBar: AppBar(actions: [menu])),
    );
