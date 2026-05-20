import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/event_attendance_details.dart';

class MatchDetails {
  final int id;
  final String type;
  final String? homeTeam;
  final String? awayTeam;
  final DateTime date;
  final DateTime? meetingTime;
  final String location;
  final String? notes;
  final MatchPollDetails? matchPollDetails;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final bool? isHomeTeam;
  final bool isCurrentUserRegistered;
  final List<EventAttendanceDetails>? attendanceDetailsList;
  final List<MatchEventDetails>? matchEventDetailsList;

  MatchDetails({
    required this.id,
    this.type = 'MATCH',
    this.homeTeam,
    this.awayTeam,
    required this.date,
    this.meetingTime,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.matchPollDetails,
    this.homeTeamScore,
    this.awayTeamScore,
    this.isHomeTeam,
    this.isCurrentUserRegistered = false,
    this.attendanceDetailsList = const [],
    this.matchEventDetailsList = const [],
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    return MatchDetails(
      id: json['id'],
      type: json['type'] ?? 'MATCH',
      homeTeam: json['home_team'],
      awayTeam: json['away_team'],
      date: DateTime.parse(json['date']),
      meetingTime: _parseMeetingTime(json['meeting_time']),
      location: json['location'],
      notes: json['notes'],
      matchPollDetails: json['match_poll'] != null
          ? MatchPollDetails.fromJson(json['match_poll'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      homeTeamScore: json['home_team_score'],
      awayTeamScore: json['away_team_score'],
      isHomeTeam: json['is_home_team'],
      isCurrentUserRegistered: json['is_current_user_registered'] ?? false,
      attendanceDetailsList: json['attendance_details_list'] != null
          ? List<EventAttendanceDetails>.from(json['attendance_details_list']
              .map((x) => EventAttendanceDetails.fromJson(x)))
          : [],
      matchEventDetailsList: json['match_event_details_list'] != null
          ? List<MatchEventDetails>.from(json['match_event_details_list']
              .map((x) => MatchEventDetails.fromJson(x)))
          : [],
    );
  }

  String get matchName {
    return '${homeTeam ?? "?"} vs ${awayTeam ?? "?"}';
  }

  bool get hasMatchBeenPlayed {
    return homeTeamScore != null && awayTeamScore != null;
  }
}

DateTime? _parseMeetingTime(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  final re = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)(?::([0-5]\d))?$');
  final m = re.firstMatch(s);
  if (m != null) {
    final h = int.parse(m.group(1) ?? '0');
    final mm = int.parse(m.group(2) ?? '0');
    final ss = m.group(3) != null ? int.parse(m.group(3)!) : 0;
    return DateTime.utc(1970, 1, 1, h, mm, ss);
  }
  // Ellers prøv ISO
  return DateTime.parse(s);
}
