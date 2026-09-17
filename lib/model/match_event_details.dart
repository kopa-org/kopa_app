import 'package:kopa/model/card_type.dart';
import 'package:kopa/model/match_event_type.dart';

class MatchEventDetails {
  final int id;
  final int eventId;
  final MatchEventType type;
  final int? minute;
  final int teamId;
  final int? goalscorerUserId;
  final int? goalscorerExternalPlayerId;
  final String goalscorerUserName;
  final int? assistMakerUserId;
  final int? assistMakerExternalPlayerId;
  final String? assistMakerUserName;
  final CardType? cardType;

  MatchEventDetails({
    required this.id,
    required this.eventId,
    required this.type,
    this.minute,
    required this.teamId,
    this.goalscorerUserId,
    this.goalscorerExternalPlayerId,
    required this.goalscorerUserName,
    this.assistMakerUserId,
    this.assistMakerExternalPlayerId,
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
      goalscorerExternalPlayerId: json['goalscorer_external_player_id'],
      goalscorerUserName: json['goalscorer_user_name'] ?? 'Ukendt spiller',
      assistMakerUserId: json['assist_maker_user_id'],
      assistMakerExternalPlayerId: json['assist_maker_external_player_id'],
      assistMakerUserName: json['assist_maker_user_name'],
      cardType: json['card_type'] != null
          ? CardType.values.firstWhere((e) => e.wire == json['card_type'])
          : null,
    );
  }
}
