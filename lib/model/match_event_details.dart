import 'package:kopa/model/card_type.dart';
import 'package:kopa/model/match_event_type.dart';

class MatchEventDetails {
  final int id;
  final int eventId;
  final MatchEventType type;
  final int? minute;
  final int teamId;
  final int goalscorerUserId;
  final String goalscorerUserName;
  final int? assistMakerUserId;
  final String? assistMakerUserName;
  final CardType? cardType;

  MatchEventDetails({
    required this.id,
    required this.eventId,
    required this.type,
    this.minute,
    required this.teamId,
    required this.goalscorerUserId,
    required this.goalscorerUserName,
    this.assistMakerUserId,
    this.assistMakerUserName,
    this.cardType,
  });

  factory MatchEventDetails.fromJson(Map<String, dynamic> json) {
    return MatchEventDetails(
      id: json['id'],
      eventId: json['event_id'],
      type: MatchEventType.values.firstWhere((e) => e.wire == json['type']),
      minute: json['minute'],
      teamId: json['team_id'],
      goalscorerUserId: json['goalscorer_user_id'],
      goalscorerUserName: json['goalscorer_user_name'],
      assistMakerUserId: json['assist_maker_user_id'],
      assistMakerUserName: json['assist_maker_user_name'],
      cardType: json['card_type'] != null
          ? CardType.values.firstWhere((e) => e.wire == json['card_type'])
          : null,
    );
  }
}
