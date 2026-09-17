import 'package:kopa/model/card_type.dart';
import 'package:kopa/model/match_event_type.dart';

class CreateMatchEventCommand {
  final int eventId;
  final MatchEventType type;
  final int? minute;
  final int teamId;
  final int? goalscorerUserId;
  final int? goalscorerExternalPlayerId;
  final int? assistMakerUserId;
  final int? assistMakerExternalPlayerId;
  final CardType? cardType;

  CreateMatchEventCommand({
    required this.eventId,
    required this.type,
    this.minute,
    required this.teamId,
    this.goalscorerUserId,
    this.goalscorerExternalPlayerId,
    this.assistMakerUserId,
    this.assistMakerExternalPlayerId,
    this.cardType,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'type': type.wire,
      if (minute != null) 'minute': minute,
      'team_id': teamId,
      if (goalscorerUserId != null) 'goalscorer_user_id': goalscorerUserId,
      if (goalscorerExternalPlayerId != null)
        'goalscorer_external_player_id': goalscorerExternalPlayerId,
      if (assistMakerUserId != null) 'assist_maker_user_id': assistMakerUserId,
      if (assistMakerExternalPlayerId != null)
        'assist_maker_external_player_id': assistMakerExternalPlayerId,
      if (cardType != null) 'card_type': cardType!.wire,
    };
  }
}
