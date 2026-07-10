import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('da_DK');
  });

  testWidgets('groups matches and makes every entry actionable',
      (tester) async {
    final upcomingMatch = _match(
      id: 1,
      date: DateTime(2027, 8, 12, 19),
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
    );
    final completedMatch = _match(
      id: 2,
      date: DateTime(2026, 5, 2, 13),
      homeTeam: 'Kopa IF',
      awayTeam: 'Boldklubben',
      homeScore: 3,
      awayScore: 1,
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
              matches: [completedMatch, upcomingMatch],
              onMatchTap: (match) => tappedMatch = match,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kommende kampe'), findsOneWidget);
    expect(find.text('Tidligere kampe'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chevron_right), findsNWidgets(2));
    expect(find.byType(Hero), findsNothing);

    await tester.tap(find.byKey(const ValueKey('match-entry-1')));
    await tester.pump();

    expect(tappedMatch, same(upcomingMatch));
  });
}

MatchDetails _match({
  required int id,
  required DateTime date,
  required String homeTeam,
  required String awayTeam,
  int? homeScore,
  int? awayScore,
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
    isHomeTeam: true,
  );
}
