import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/component/chip/match_result_badge.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('da_DK');
  });

  testWidgets('sorts matches ascending and makes every entry actionable',
      (tester) async {
    final upcomingMatch = _match(
      id: 1,
      date: DateTime.utc(2027, 8, 12, 20),
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      isCurrentUserRegistered: true,
    );
    final completedMatch = _match(
      id: 2,
      date: DateTime(2026, 5, 2, 13),
      homeTeam: 'Kopa IF',
      awayTeam: 'Boldklubben',
      homeScore: 3,
      awayScore: 1,
    );
    final earliestMatch = _match(
      id: 3,
      date: DateTime(2026, 1, 9, 11),
      homeTeam: 'Østerbro',
      awayTeam: 'Kopa IF',
      homeScore: 0,
      awayScore: 2,
    );
    MatchDetails? tappedMatch;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: AllGamesCard(
              matches: [completedMatch, upcomingMatch, earliestMatch],
              ownTeamName: 'Profile team name',
              currentUserId: 7,
              onMatchTap: (match) => tappedMatch = match,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kommende kampe'), findsNothing);
    expect(find.text('Tidligere kampe'), findsNothing);
    expect(find.text('Tilmeldt'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('Sejr'), findsNWidgets(2));
    expect(find.byIcon(CupertinoIcons.chevron_right), findsNWidgets(3));
    expect(find.byType(Hero), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('match-entry-3'))).dy,
      lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('match-entry-2'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('match-entry-2'))).dy,
      lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('match-entry-1'))).dy),
    );

    final kopaLabels = tester
        .widgetList<Text>(find.text('Kopa IF'))
        .map((text) => text.style?.fontWeight)
        .toList();
    expect(kopaLabels, everyElement(FontWeight.w900));
    expect(
      tester.widget<Text>(find.text('Østerbro')).style?.fontWeight,
      isNot(FontWeight.w900),
    );

    await tester.tap(find.byKey(const ValueKey('match-entry-1')));
    await tester.pump();

    expect(tappedMatch, same(upcomingMatch));
  });

  testWidgets('shows declined badge for current user decline', (tester) async {
    final declinedMatch = _match(
      id: 4,
      date: DateTime.utc(2027, 8, 13, 20),
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      isCurrentUserAttending: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          body: AllGamesCard(
            matches: [declinedMatch],
            currentUserId: 7,
            onMatchTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Frameldt'), findsOneWidget);
    expect(find.text('Tilmeldt'), findsNothing);
    expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Frameldt')).style?.color,
      AppColors.light.errorForeground,
    );
  });

  testWidgets('uses shared title-case typography for match status chips',
      (tester) async {
    final finishedMatch = _match(
      id: 5,
      date: DateTime(2026, 5, 1, 19),
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      isCurrentUserRegistered: true,
    );
    final lossMatch = _match(
      id: 6,
      date: DateTime(2026, 5, 2, 19),
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      homeScore: 0,
      awayScore: 1,
      isCurrentUserAttending: false,
    );
    final drawMatch = _match(
      id: 7,
      date: DateTime(2026, 5, 3, 19),
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      homeScore: 1,
      awayScore: 1,
    );
    final winMatch = _match(
      id: 8,
      date: DateTime(2026, 5, 4, 19),
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      homeScore: 2,
      awayScore: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          body: AllGamesCard(
            matches: [finishedMatch, lossMatch, drawMatch, winMatch],
            currentUserId: 7,
            onMatchTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Færdig'), findsOneWidget);
    expect(find.text('Tabt'), findsOneWidget);
    expect(find.text('Uafgjort'), findsOneWidget);
    expect(find.text('Tilmeldt'), findsOneWidget);
    expect(find.text('Frameldt'), findsOneWidget);
    expect(find.text('FÆRDIG'), findsNothing);
    expect(find.text('TABT'), findsNothing);
    expect(find.text('UAFGJORT'), findsNothing);
    expect(find.text('Sejr'), findsOneWidget);

    final registeredStyle = tester.widget<Text>(find.text('Tilmeldt')).style!;
    for (final label in ['Færdig', 'Tabt', 'Uafgjort', 'Frameldt']) {
      final style = tester.widget<Text>(find.text(label)).style!;
      expect(style.fontFamily, registeredStyle.fontFamily);
      expect(style.fontSize, registeredStyle.fontSize);
      expect(style.fontWeight, registeredStyle.fontWeight);
      expect(style.height, registeredStyle.height);
      expect(style.letterSpacing, registeredStyle.letterSpacing);
    }

    final registeredChip = _chipFor(tester, 'Tilmeldt');
    final finishedChip = _chipFor(tester, 'Færdig');
    final winChip = _chipFor(tester, 'Sejr');
    final declinedChip = _chipFor(tester, 'Frameldt');
    final lossChip = _chipFor(tester, 'Tabt');

    expect(finishedChip.status, registeredChip.status);
    expect(winChip.status, registeredChip.status);
    expect(lossChip.status, declinedChip.status);

    final registeredDecoration = _chipDecoration(tester, 'Tilmeldt');
    for (final label in ['Færdig', 'Sejr']) {
      expect(
        _chipDecoration(tester, label).color,
        registeredDecoration.color,
      );
      expect(
        tester.widget<Text>(find.text(label)).style?.color,
        registeredStyle.color,
      );
    }
    final declinedDecoration = _chipDecoration(tester, 'Frameldt');
    expect(_chipDecoration(tester, 'Tabt').color, declinedDecoration.color);
    expect(
      tester.widget<Text>(find.text('Tabt')).style?.color,
      tester.widget<Text>(find.text('Frameldt')).style?.color,
    );
  });
}

MatchOverviewChip _chipFor(WidgetTester tester, String label) {
  return tester.widget<MatchOverviewChip>(
    find.byWidgetPredicate(
      (widget) => widget is MatchOverviewChip && widget.label == label,
    ),
  );
}

BoxDecoration _chipDecoration(WidgetTester tester, String label) {
  return tester
      .widget<Container>(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byType(Container),
            )
            .first,
      )
      .decoration! as BoxDecoration;
}

MatchDetails _match({
  required int id,
  required DateTime date,
  required String homeTeam,
  required String awayTeam,
  int? homeScore,
  int? awayScore,
  bool isHomeTeam = true,
  bool isCurrentUserRegistered = false,
  bool? isCurrentUserAttending,
  List<EventAttendanceDetails> attendanceDetailsList = const [],
}) {
  return MatchDetails(
    id: id,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    date: date,
    location: 'Kopa Stadion',
    createdAt: date,
    updatedAt: date,
    homeTeamScore: homeScore,
    awayTeamScore: awayScore,
    isHomeTeam: isHomeTeam,
    isCurrentUserRegistered: isCurrentUserRegistered,
    isCurrentUserAttending: isCurrentUserAttending,
    attendanceDetailsList: attendanceDetailsList,
  );
}
