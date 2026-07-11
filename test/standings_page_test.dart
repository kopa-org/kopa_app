import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/standings/standings_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('renders DBU cutoff lines in the full standings table',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: StandingsPage(
          standings: DbuStandings(
            poolId: 489363,
            currentTeamId: 2,
            seriesName: 'Serie 4',
            rows: [
              _row(position: 1, boundaryAfter: 'dotted'),
              _row(position: 2, teamName: 'Kopa IF'),
              _row(position: 3, boundaryAfter: 'solid'),
              _row(position: 4),
            ],
          ),
          currentUser: _user(),
        ),
      ),
    );

    expect(find.text('Serie 4'), findsOneWidget);
    expect(
      tester.widgetList<CustomPaint>(find.byType(CustomPaint)).where(
            (paint) =>
                paint.painter.runtimeType.toString() == '_BoundaryLinePainter',
          ),
      hasLength(2),
    );
  });
}

DbuStandingRow _row({
  required int position,
  String? teamName,
  String? boundaryAfter,
}) {
  return DbuStandingRow(
    position: position,
    dbuTeamId: position,
    teamName: teamName ?? 'Hold $position',
    matchesPlayed: 8,
    wins: 4,
    draws: 1,
    losses: 3,
    goalsFor: 18,
    goalsAgainst: 12,
    points: 13,
    boundaryAfter: boundaryAfter,
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
