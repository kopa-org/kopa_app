import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/match/match_score_sheet.dart';
import 'package:kopa/page/match/match_score_sheet_preview.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  Future<void> open(
    WidgetTester tester, {
    required Future<void> Function(int, int) onSave,
    ValueChanged<(int, int)?>? onClosed,
    double scale = 1,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.android),
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
          body: Builder(
              builder: (context) => TextButton(
                    onPressed: () async {
                      final result = await showMatchScoreSheet(
                          context: context,
                          homeTeam: 'Kopa FC',
                          awayTeam: 'Frederiksberg Boldklub og Idrætsforening',
                          homeScore: 2,
                          awayScore: 1,
                          onSave: onSave);
                      onClosed?.call(result);
                    },
                    child: const Text('Open'),
                  ))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Android opens a themed sheet without opening the keyboard',
      (tester) async {
    await open(tester, onSave: (home, away) async {});
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.testTextInput.isVisible, isFalse);
    for (final field
        in tester.widgetList<EditableText>(find.byType(EditableText))) {
      expect(field.style.decoration, TextDecoration.none);
    }
    final textContext =
        tester.element(find.text('Indtast slutresultatet for hvert hold.'));
    expect(
        DefaultTextStyle.of(textContext).style.decoration, TextDecoration.none);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Annuller'));
    await tester.pumpAndSettle();
    expect(find.byType(MatchScoreSheet), findsNothing);
  });

  testWidgets(
      'updates validation as scores change and saves home/away order once',
      (tester) async {
    final pending = Completer<void>();
    final saves = <(int, int)>[];
    (int, int)? result;
    await open(tester,
        onSave: (h, a) {
          saves.add((h, a));
          return pending.future;
        },
        onClosed: (value) => result = value);
    await tester.enterText(find.byKey(const ValueKey('home-score')), '');
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await tester.enterText(find.byKey(const ValueKey('home-score')), '4');
    await tester.enterText(find.byKey(const ValueKey('away-score')), '0');
    await tester.pump();
    await tester.tap(find.text('Gem resultat'));
    await tester.pump();
    expect(saves, [(4, 0)]);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(MatchScoreSheet), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(result, (4, 0));
    expect(find.byType(MatchScoreSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed save preserves edits and allows retry', (tester) async {
    var attempts = 0;
    await open(tester, onSave: (home, away) async {
      if (attempts++ == 0) throw StateError('offline');
    });
    await tester.enterText(find.byKey(const ValueKey('away-score')), '3');
    await tester.pump();
    await tester.tap(find.text('Gem resultat'));
    await tester.pumpAndSettle();
    expect(
        find.text('Resultatet kunne ikke gemmes. Prøv igen.'), findsOneWidget);
    expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('away-score')))
            .controller!
            .text,
        '3');
    await tester.tap(find.text('Gem resultat'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(MatchScoreSheet), findsNothing);
  });

  testWidgets('compact keyboard viewport and large text remain scrollable',
      (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await open(tester, scale: 2, onSave: (home, away) async {});
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gem resultat'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Gem resultat').hitTestable(), findsOneWidget);
  });

  testWidgets('score sheet visual reference', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(matchScoreSheetPreview());
    await tester.pumpAndSettle();
    await expectLater(find.byType(Scaffold),
        matchesGoldenFile('goldens/match_score_sheet.png'));
  });
}
