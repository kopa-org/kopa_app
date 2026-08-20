import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
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
      attendanceDetailsList: [
        _attendance(
          id: 1,
          userId: 7,
          name: 'Current User',
          isAttending: false,
        ),
      ],
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
  });
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
    attendanceDetailsList: attendanceDetailsList,
  );
}

EventAttendanceDetails _attendance({
  required int id,
  required int userId,
  required String name,
  required bool isAttending,
}) {
  final now = DateTime.utc(2026, 1, 1);

  return EventAttendanceDetails(
    id: id,
    userDetails: UserDetails(
      id: userId,
      name: name,
      email: 'user$userId@example.com',
      isTeamOwner: false,
      roleId: 3,
      createdAt: now,
      updatedAt: now,
      teamDetails: null,
    ),
    isAttending: isAttending,
    createdAt: now,
    updatedAt: now,
  );
}
