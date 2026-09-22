import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_poll_details_card.dart';
import 'package:kopa/component/match_poll_row_item.dart';
import 'package:kopa/component/match/player_of_match_summary_card.dart';
import 'package:kopa/cubits/match_polls_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/external_player_details.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/match_poll_user_votes_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/user_vote.dart';
import 'package:kopa/page/match_polls/create_match_poll_page.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows every vote total and exposes the edit action',
      (tester) async {
    final now = DateTime(2026, 1, 1);
    var editCount = 0;

    await tester.pumpWidget(
      _app(
        MatchPollDetailsCard(
          poll: _poll(now),
          onEdit: () => editCount++,
        ),
      ),
    );

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Charlie'), findsNothing);
    expect(find.text('I alt: 4 stemmer'), findsOneWidget);
    expect(find.text('3 stemmer'), findsOneWidget);
    expect(find.text('1 stemme'), findsOneWidget);
    expect(find.text('0 stemmer'), findsNothing);
    expect(find.byTooltip('Rediger afstemning'), findsOneWidget);

    await tester.tap(find.byTooltip('Rediger afstemning'));
    expect(editCount, 1);
  });

  testWidgets('empty MOTM state invites the owner to create a poll',
      (tester) async {
    var createCount = 0;

    await tester.pumpWidget(
      _app(
        PlayerOfMatchSummaryCard(
          playerName: null,
          onPressed: () => createCount++,
        ),
      ),
    );

    expect(find.text('Ikke valgt endnu'), findsOneWidget);
    expect(find.text('Opret afstemning'), findsOneWidget);
    expect(find.byType(InkWell), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    expect(createCount, 1);
  });

  testWidgets('edit form starts with the persisted votes', (tester) async {
    final now = DateTime(2026, 1, 1);
    final poll = _poll(now);
    final squad = [
      _user(1, 'Alice', now),
      _user(2, 'Bob', now),
    ];
    final cubit = MatchPollsCubit()
      ..setData(
        squad: squad,
        matches: [_match(now)],
        matchPolls: [poll],
      );
    final votes = UserVotesState(
      initialVotes: [
        UserVote(userId: 1, votes: 3),
        UserVote(userId: 2, votes: 1),
      ],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _app(
        BlocProvider.value(
          value: cubit,
          child: ChangeNotifierProvider.value(
            value: votes,
            child: CreateMatchPollPage(initialPoll: poll),
          ),
        ),
      ),
    );

    expect(find.text('Rediger afstemning'), findsOneWidget);
    expect(find.text('Gem ændringer'), findsOneWidget);
    expect(find.byType(MatchPollRowItem), findsNWidgets(2));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('loan player can receive a MOTM vote', (tester) async {
    final now = DateTime(2026, 1, 1);
    final match = MatchDetails(
      id: 20,
      date: now,
      location: 'Kopa Park',
      createdAt: now,
      updatedAt: now,
      externalPlayerDetailsList: [
        ExternalPlayerDetails(
          id: 7,
          eventId: 20,
          name: 'Guest Player',
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    final cubit = MatchPollsCubit()
      ..setData(squad: [_user(1, 'Alice', now)], matches: [match]);
    final votes = UserVotesState();
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(
      BlocProvider.value(
        value: cubit,
        child: ChangeNotifierProvider.value(
          value: votes,
          child: const CreateMatchPollPage(),
        ),
      ),
    ));

    final guestRow = find.ancestor(
      of: find.text('Guest Player'),
      matching: find.byType(MatchPollRowItem),
    );
    expect(guestRow, findsOneWidget);
    await tester.tap(find.descendant(
      of: guestRow,
      matching: find.byIcon(CupertinoIcons.plus),
    ));
    await tester.pump();

    expect(votes.userVotes.single.externalPlayerId, 7);
    expect(votes.userVotes.single.votes, 1);
  });
}

Widget _app(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('da'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

MatchPollDetails _poll(DateTime now) {
  return MatchPollDetails(
    id: 10,
    eventId: 20,
    playerOfTheMatchDetails: _user(1, 'Alice', now),
    playerOfTheMatchVotes: 3,
    matchPollUserVotesDetails: [
      MatchPollUserVotesDetails(
        id: 1,
        matchPollId: 10,
        userId: 1,
        userName: 'Alice',
        numberOfVotes: 3,
        createdAt: now,
        updatedAt: now,
      ),
      MatchPollUserVotesDetails(
        id: 2,
        matchPollId: 10,
        userId: 2,
        userName: 'Bob',
        numberOfVotes: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

MatchDetails _match(DateTime now) {
  return MatchDetails(
    id: 20,
    homeTeam: 'Kopa FC',
    awayTeam: 'Fremad',
    date: now,
    location: 'Kopa Park',
    createdAt: now,
    updatedAt: now,
  );
}

UserDetails _user(int id, String name, DateTime now) {
  return UserDetails(
    id: id,
    name: name,
    email: '$name@example.com',
    isTeamOwner: false,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}
