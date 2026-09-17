import 'package:kopa/model/team_logo_design.dart';

class TeamDetails {
  static const String firstComeFirstServed = 'first_come_first_served';
  static const String teamLeaderSelection = 'team_leader_selection';

  final TeamLogoDesign logoDesign;
  final int id;
  final String title;
  final int playerCount;
  final int? defaultMeetingOffsetMinutes;
  final String rsvpSelectionMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeamDetails({
    required this.id,
    required this.title,
    this.playerCount = 7,
    this.logoDesign = TeamLogoDesign.defaultDesign,
    this.defaultMeetingOffsetMinutes,
    this.rsvpSelectionMode = firstComeFirstServed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      id: json['id'],
      title: json['title'],
      playerCount: json['player_count'] ?? 7,
      logoDesign: TeamLogoDesign.fromJson(json),
      defaultMeetingOffsetMinutes: json['default_meeting_offset_minutes'],
      rsvpSelectionMode:
          json['rsvp_selection_mode'] as String? ?? firstComeFirstServed,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
