import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';

void main() {
  test('post-match details start one hour after kampstart', () {
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

    expect(
        match.isPostMatchAt(kickoff.add(const Duration(minutes: 59))), isFalse);
    expect(match.isPostMatchAt(kickoff.add(const Duration(hours: 1))), isTrue);
  });

  test('final score is independent from post-match timing', () {
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

    expect(match.isPostMatchAt(kickoff.add(const Duration(hours: 2))), isTrue);
    expect(match.hasFinalScore, isFalse);
  });

  test('score entry is only available to owners after post-match timing', () {
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
        now: kickoff.add(const Duration(minutes: 59)),
      ),
      isFalse,
    );
    expect(
      match.canSetFinalScore(
        owner,
        now: kickoff.add(const Duration(hours: 1)),
      ),
      isTrue,
    );
    expect(
      match.canSetFinalScore(
        player,
        now: kickoff.add(const Duration(hours: 1)),
      ),
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
      match.canSetFinalScore(
        _user(isTeamOwner: true),
        now: kickoff.add(const Duration(hours: 1)),
      ),
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

  test('lineup visibility defaults to visible when missing', () {
    final match = MatchDetails.fromJson(_matchJson());

    expect(match.lineupVisible, isTrue);
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
