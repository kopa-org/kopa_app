import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/home/home_statistics_strip.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('uses per-tile stat background colors', (tester) async {
    final appColors = AppColors.light;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            appColors,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          body: HomeStatisticsStrip(
            stats: _stats(),
            currentUser: _user(),
          ),
        ),
      ),
    );

    expect(find.text('Pointsnit'), findsOneWidget);
    expect(
      _decorations(tester),
      _containsColor(appColors.lightGrass.withValues(alpha: 0.27)),
    );
  });
}

Iterable<BoxDecoration> _decorations(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .map((container) => container.decoration)
      .whereType<BoxDecoration>();
}

Matcher _containsColor(Color color) {
  return anyElement(
    isA<BoxDecoration>().having(
      (decoration) => decoration.color,
      'color',
      color,
    ),
  );
}

StatisticsResponse _stats() {
  final currentRow = LeaderboardRow(
    userId: 1,
    userName: 'Test User',
    value: 8,
  );

  return StatisticsResponse(
    player: PlayerStats(
      name: 'Test User',
      matchesPlayed: 12,
      trainingAttendancePercentage: 90,
      goalsScored: 4,
      assists: 3,
      yellowCards: 1,
      redCards: 0,
      finesTotal: 50,
    ),
    club: ClubStats(
      wins: 8,
      draws: 1,
      losses: 2,
      goalsFor: 30,
      goalsAgainst: 12,
      lastFiveMatchesForm: const [3, 3, 1, 0, 3],
    ),
    inFormRows: [
      InFormRow(userId: 1, userName: 'Test User', points: 14),
    ],
    leaderboards: Leaderboards(
      topScorers: [currentRow],
      assists: [currentRow],
      matchesPlayed: [currentRow],
      mostVotes: [currentRow],
      bestPointsAverage: [currentRow],
    ),
    teamMetrics: TeamMetrics(
      teamAveragePoints: 2.1,
      teamForm: const [3, 3, 1, 0, 3],
      goalsScored: 30,
      goalsConceded: 12,
    ),
  );
}

UserDetails _user() {
  final now = DateTime(2026, 1, 1);
  return UserDetails(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    isTeamOwner: false,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}
