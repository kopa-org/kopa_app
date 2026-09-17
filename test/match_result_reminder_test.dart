import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_result_reminder.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('shows the yellow result reminder after 30 minutes',
      (tester) async {
    var pressed = false;
    final match = _match(
      date: DateTime.now().subtract(const Duration(minutes: 31)),
    );

    await tester.pumpWidget(_app(
      MatchResultReminderButton(
        match: match,
        onPressed: () => pressed = true,
      ),
    ));

    final icon = tester.widget<Icon>(find.byIcon(Icons.info_outline));
    expect(icon.color, AppColors.light.sun);

    final circle = tester.widget<Container>(
      find
          .ancestor(
            of: find.byIcon(Icons.info_outline),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = circle.decoration! as BoxDecoration;
    expect(circle.constraints?.minWidth, 34);
    expect(circle.constraints?.maxWidth, 34);
    expect(circle.constraints?.minHeight, 34);
    expect(circle.constraints?.maxHeight, 34);
    expect(decoration.color, AppColors.light.white);
    expect(decoration.shape, BoxShape.circle);

    await tester.tap(find.byKey(const ValueKey('match-result-reminder')));
    expect(pressed, isTrue);
  });

  testWidgets('does not show the reminder before 30 minutes', (tester) async {
    await tester.pumpWidget(_app(
      MatchResultReminderButton(
        match: _match(
          date: DateTime.now().subtract(const Duration(minutes: 29)),
        ),
        onPressed: () {},
      ),
    ));

    expect(find.byIcon(Icons.info_outline), findsNothing);
  });

  testWidgets('dialog offers to enter the match result', (tester) async {
    var entered = false;

    await tester.pumpWidget(_app(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showMatchResultReminderDialog(
            context,
            onEnterResult: () => entered = true,
          ),
          child: const Text('Open reminder'),
        ),
      ),
    ));

    await tester.tap(find.text('Open reminder'));
    await tester.pumpAndSettle();

    expect(find.text('Indtast kampens resultat'), findsOneWidget);
    expect(find.text('Indtast resultat'), findsOneWidget);
    final dialogCircle = tester.widget<Container>(
      find
          .ancestor(
            of: find.byIcon(Icons.info_outline),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (dialogCircle.decoration! as BoxDecoration).color,
      AppColors.light.sunset,
    );

    await tester.tap(find.text('Indtast resultat'));
    await tester.pumpAndSettle();

    expect(entered, isTrue);
  });
}

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('da'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        AppColors.light,
        AppTextStyles.light,
      ],
    ),
    home: Scaffold(body: child),
  );
}

MatchDetails _match({required DateTime date}) {
  return MatchDetails(
    id: 1,
    homeTeam: 'Kopa IF',
    awayTeam: 'Fremad',
    date: date,
    location: 'Kopa Stadion',
    createdAt: date,
    updatedAt: date,
  );
}
