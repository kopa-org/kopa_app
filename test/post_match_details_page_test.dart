import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/component/match/match_events_timeline.dart';
import 'package:kopa/component/match/match_poll_details_card.dart';
import 'package:kopa/component/match/player_of_match_summary_card.dart';
import 'package:kopa/component/timeline/timeline_item.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/post_match_details_page.dart';
import 'package:kopa/template/match_detail_template.dart';

void main() {
  testWidgets(
      'untimed events show the event label once and allow registration during play',
      (tester) async {
    var adds = 0;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: SingleChildScrollView(
              child: MatchEventsTimeline(
        events: [_event(id: 1, name: 'Alice Jensen')],
        canAddEvent: true,
        canReorderEvents: false,
        onAddEvent: () => adds++,
        onDeleteEvent: null,
        onReorderEvents: null,
        showFullTime: false,
      ))),
    ));
    expect(find.text('Mål: Alice Jensen'), findsOneWidget);
    expect(find.text('MÅL'), findsNothing);
    expect(find.text('Mål'), findsNothing);
    expect(find.text('Kamp slut'), findsNothing);
    final goal = tester.widget<TimelineItem>(
        find.byKey(const ValueKey('match-event-timeline-1')));
    expect(goal.time, isEmpty);
    expect(goal.subtitle, isNull);
    await tester.tap(find.text('+ Tilføj hændelse'));
    expect(adds, 1);
    expect(tester.takeException(), isNull);
  });

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
          selectedSegment: MatchDetailSegment.overview,
          onSegmentChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Registrer kampens resultat'), findsNothing);
    expect(find.byType(PlayerOfMatchSummaryCard), findsOneWidget);
    expect(find.byType(MatchPollDetailsCard), findsNothing);

    final labels = [
      'Kampstart',
      'Mål: Tidlig målscorer',
      'Mål: Sen målscorer',
      'Kamp slut',
    ];

    final verticalPositions =
        labels.map((label) => tester.getTopLeft(find.text(label)).dy).toList();

    expect(find.text('Kampstart'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Kamp slut'), findsOneWidget);
    expect(
      verticalPositions,
      orderedEquals(verticalPositions.toList()..sort()),
    );
  });

  for (final isManager in [true, false]) {
    for (final hasPoll in [true, false]) {
      testWidgets('post-match MOTM: manager=$isManager, poll=$hasPoll',
          (tester) async {
        final now = DateTime(2026, 1, 1);
        var creates = 0;
        var edits = 0;
        final winner = _owner(now);
        await tester.pumpWidget(MaterialApp(
          locale: const Locale('da'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PostMatchDetailsPage(
            match: MatchDetails(
              id: 1,
              homeTeam: 'Kopa IF',
              awayTeam: 'Fremad',
              date: now,
              location: 'Kopa Stadion',
              createdAt: now,
              updatedAt: now,
              matchPollDetails: hasPoll
                  ? MatchPollDetails(
                      id: 1,
                      eventId: 1,
                      playerOfTheMatchDetails: winner,
                      playerOfTheMatchVotes: 3,
                      matchPollUserVotesDetails: const [],
                      createdAt: now,
                      updatedAt: now,
                    )
                  : null,
            ),
            user: _owner(now, isTeamOwner: isManager),
            heroCard: const SizedBox(height: 1),
            attendanceList: const [],
            onAddEvent: _noop,
            onCreateMatchPoll: () => creates++,
            onEditMatchPoll: () => edits++,
            selectedSegment: MatchDetailSegment.overview,
            onSegmentChanged: (_) {},
          ),
        ));

        expect(find.text('Kampens spiller'), findsOneWidget);
        if (hasPoll) {
          expect(find.byType(MatchPollDetailsCard), findsOneWidget);
          expect(find.text('Owner'), findsOneWidget);
          expect(find.text('3 stemmer'), findsOneWidget);
          expect(find.byTooltip('Rediger afstemning'), findsOneWidget);
          {
            await tester.tap(find.byTooltip('Rediger afstemning'));
            expect(edits, 1);
          }
        } else {
          expect(find.byType(PlayerOfMatchSummaryCard), findsOneWidget);
          expect(find.text('Opret afstemning'), findsOneWidget);
          {
            await tester.tap(find.text('Opret afstemning'));
            expect(creates, 1);
          }
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

MatchEventDetails _event({
  required int id,
  int? minute,
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

UserDetails _owner(DateTime now, {bool isTeamOwner = true}) {
  return UserDetails(
    id: 1,
    name: 'Owner',
    email: 'owner@example.com',
    isTeamOwner: isTeamOwner,
    roleId: isTeamOwner ? 1 : 2,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}

void _noop() {}
