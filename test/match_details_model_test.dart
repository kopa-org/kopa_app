import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_player.dart';
import 'package:kopa/model/user_details.dart';

void main() {
  test('a match is played only after both result scores are entered', () {
    final kickoff = DateTime(2026, 7, 28, 19);
    final unplayed = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
    );
    final played = MatchDetails(
      id: 2,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
      homeTeamScore: 0,
      awayTeamScore: 0,
    );

    expect(unplayed.hasMatchBeenPlayed, isFalse);
    expect(
        unplayed.shouldPromptForResultAt(
          kickoff.add(const Duration(minutes: 29)),
        ),
        isFalse);
    expect(
        unplayed.shouldPromptForResultAt(
          kickoff.add(const Duration(minutes: 30)),
        ),
        isTrue);
    expect(played.hasMatchBeenPlayed, isTrue);
    expect(
        played.shouldPromptForResultAt(
          kickoff.add(const Duration(hours: 2)),
        ),
        isFalse);
  });

  test('an unrecorded result remains unplayed after the match time', () {
    final kickoff = DateTime(2026, 7, 28, 19);
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
    );

    expect(match.hasMatchBeenPlayed, isFalse);
    expect(match.hasFinalScore, isFalse);
  });

  test('training has no match result state', () {
    final date = DateTime(2026, 7, 28, 19);
    final training = MatchDetails(
      id: 3,
      type: MatchDetails.trainingType,
      date: date,
      location: 'Training Pitch',
      createdAt: date,
      updatedAt: date,
      homeTeamScore: 1,
      awayTeamScore: 0,
    );

    expect(training.isTraining, isTrue);
    expect(training.hasMatchBeenPlayed, isFalse);
    expect(training.shouldPromptForResultAt(date.add(const Duration(hours: 1))),
        isFalse);
    expect(training.canSetFinalScore(_user(isTeamOwner: true)), isFalse);
  });

  test('training category is optional and parsed from the API', () {
    final training = MatchDetails.fromJson({
      ..._matchJson(),
      'type': MatchDetails.trainingType,
      'home_team': null,
      'away_team': null,
      'category': 'Pasninger',
    });

    expect(training.category, 'Pasninger');
  });

  test('score entry is available to owners at any time', () {
    final kickoff = DateTime(2026, 7, 28, 19);
    final owner = _user(isTeamOwner: true);
    final player = _user(isTeamOwner: false);
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
    );

    expect(
      match.canSetFinalScore(
        owner,
        now: kickoff.subtract(const Duration(days: 1)),
      ),
      isTrue,
    );
    expect(
      match.canSetFinalScore(player),
      isFalse,
    );
  });

  test('score entry is unavailable when final score already exists', () {
    final kickoff = DateTime(2026, 7, 28, 19);
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
      homeTeamScore: 2,
      awayTeamScore: 1,
    );

    expect(
      match.canSetFinalScore(_user(isTeamOwner: true)),
      isFalse,
    );
  });

  test('splits attending and declined attendance details', () {
    final kickoff = DateTime(2026, 7, 28, 19);
    final attending = _attendance(
      id: 1,
      name: 'Attending Player',
      isAttending: true,
    );
    final declined = _attendance(
      id: 2,
      name: 'Declined Player',
      isAttending: false,
    );
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
      attendanceDetailsList: [attending, declined],
    );

    expect(match.attendingAttendanceDetails, [attending]);
    expect(match.declinedAttendanceDetails, [declined]);
  });

  test('lineup visibility defaults to hidden when missing', () {
    final match = MatchDetails.fromJson(_matchJson());

    expect(match.lineupVisible, isFalse);
  });

  test('lineup visibility parses from json', () {
    final match = MatchDetails.fromJson(_matchJson(lineupVisible: false));

    expect(match.lineupVisible, isFalse);
  });

  test('summary attendance status parses independently from registration', () {
    final match = MatchDetails.fromJson(
      _matchJson(isCurrentUserAttending: false),
    );

    expect(match.isCurrentUserRegistered, isFalse);
    expect(match.isCurrentUserAttending, isFalse);
  });

  test('parses match-only external players', () {
    final match = MatchDetails.fromJson({
      ..._matchJson(),
      'external_player_details_list': [
        {
          'id': 42,
          'event_id': 1,
          'name': 'Guest Player',
          'lineup_slot': null,
          'created_at': '2026-07-28T12:00:00Z',
          'updated_at': '2026-07-28T12:00:00Z',
        },
      ],
    });

    expect(match.externalPlayerDetailsList, hasLength(1));
    expect(match.externalPlayerDetailsList!.single.name, 'Guest Player');
    expect(match.externalPlayerDetailsList!.single.lineupSlot, isNull);
    expect(
      MatchPlayer.external(match.externalPlayerDetailsList!.single).isExternal,
      isTrue,
    );
  });
}

Map<String, dynamic> _matchJson({
  bool? lineupVisible,
  bool? isCurrentUserAttending,
}) {
  return {
    'id': 1,
    'type': 'MATCH',
    'home_team': 'Kopa IF',
    'away_team': 'Fremad',
    'date': '2026-07-28T19:00:00Z',
    'location': 'Kopa Stadion',
    'created_at': '2026-07-28T12:00:00Z',
    'updated_at': '2026-07-28T12:00:00Z',
    if (lineupVisible != null) 'lineup_visible': lineupVisible,
    if (isCurrentUserAttending != null)
      'is_current_user_attending': isCurrentUserAttending,
  };
}

UserDetails _user({required bool isTeamOwner}) {
  final now = DateTime(2026, 7, 28, 12);

  return UserDetails(
    id: isTeamOwner ? 1 : 2,
    name: isTeamOwner ? 'Owner' : 'Player',
    email: isTeamOwner ? 'owner@example.com' : 'player@example.com',
    isTeamOwner: isTeamOwner,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}

EventAttendanceDetails _attendance({
  required int id,
  required String name,
  required bool isAttending,
}) {
  final now = DateTime(2026, 7, 28, 12);

  return EventAttendanceDetails(
    id: id,
    userDetails: UserDetails(
      id: id,
      name: name,
      email: '$id@example.com',
      isTeamOwner: false,
      roleId: 1,
      createdAt: now,
      updatedAt: now,
      teamDetails: null,
    ),
    isAttending: isAttending,
    createdAt: now,
    updatedAt: now,
  );
}
