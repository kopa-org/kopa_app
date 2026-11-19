import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/button/nav_bar_add_button.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';

Widget _app(TargetPlatform platform, Widget child) => MaterialApp(
      theme: AppTheme.lightTheme.copyWith(platform: platform),
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: Text(usesNavBarAddButton(context) ? 'header' : 'fab'),
          ),
        ),
        appBar: AppBar(actions: [child]),
      ),
    );

void main() {
  testWidgets('only iOS moves create actions into the header', (tester) async {
    await tester.pumpWidget(_app(TargetPlatform.iOS, const SizedBox()));
    expect(find.text('header'), findsOneWidget);
    await tester.pumpWidget(_app(TargetPlatform.android, const SizedBox()));
    await tester.pumpAndSettle();
    expect(find.text('fab'), findsOneWidget);
  });

  testWidgets('a single action runs straight away', (tester) async {
    var created = 0;
    await tester.pumpWidget(_app(
      TargetPlatform.iOS,
      NavBarAddButton(label: 'Opret opgave', actions: [
        AddAction(
          label: 'Opret opgave',
          icon: CupertinoIcons.add,
          onPressed: () => created++,
        ),
      ]),
    ));
    await tester.tap(find.bySemanticsLabel('Opret opgave'));
    await tester.pumpAndSettle();
    expect(created, 1);
    expect(find.byType(CupertinoActionSheet), findsNothing);
  });

  testWidgets('several actions open an action sheet', (tester) async {
    final picked = <String>[];
    await tester.pumpWidget(_app(
      TargetPlatform.iOS,
      NavBarAddButton(label: 'Opret', actions: [
        AddAction(
          label: 'Kamp',
          icon: Icons.sports_soccer,
          onPressed: () => picked.add('match'),
        ),
        AddAction(
          label: 'Træning',
          icon: Icons.fitness_center,
          onPressed: () => picked.add('training'),
        ),
      ]),
    ));
    await tester.tap(find.bySemanticsLabel('Opret'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoActionSheet), findsOneWidget);

    await tester.tap(find.text('Træning'));
    await tester.pumpAndSettle();
    expect(picked, ['training']);
    expect(find.byType(CupertinoActionSheet), findsNothing);
  });
}
