import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/post_match_details_page.dart';
import 'package:kopa/template/match_detail_template.dart';

void main() {
  testWidgets('shows match phases in chronological order with events',
      (tester) async {
    final kickoff = DateTime(2026, 1, 1, 19);
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
      matchEventDetailsList: [
        _event(id: 1, minute: 70, name: 'Sen målscorer'),
        _event(id: 2, minute: 10, name: 'Tidlig målscorer'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PostMatchDetailsPage(
          match: match,
          user: _owner(kickoff),
          heroCard: const SizedBox(height: 1),
          attendanceList: const [],
          onAddEvent: _noop,
          onSetMatchScore: _noop,
          onCreateMatchPoll: _noop,
          selectedSegment: MatchDetailSegment.overview,
          onSegmentChanged: (_) {},
        ),
      ),
    );

    final labels = [
      'Kampstart',
      'Mål: Tidlig målscorer',
      'Pause',
      'Mål: Sen målscorer',
      'Kamp slut',
    ];

    final verticalPositions =
        labels.map((label) => tester.getTopLeft(find.text(label)).dy).toList();

    expect(find.text('Kampstart'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Kamp slut'), findsOneWidget);
    expect(
      verticalPositions,
      orderedEquals(verticalPositions.toList()..sort()),
    );
  });
}

MatchEventDetails _event({
  required int id,
  required int minute,
  required String name,
}) {
  return MatchEventDetails(
    id: id,
    eventId: 1,
    type: MatchEventType.goal,
    minute: minute,
    teamId: 1,
    goalscorerUserId: id,
    goalscorerUserName: name,
  );
}

UserDetails _owner(DateTime now) {
  return UserDetails(
    id: 1,
    name: 'Owner',
    email: 'owner@example.com',
    isTeamOwner: true,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}

void _noop() {}
