import 'package:kopa/model/card_type.dart';
import 'package:kopa/model/match_event_type.dart';

class CreateMatchEventCommand {
  final int eventId;
  final MatchEventType type;
  final int teamId;
  final int goalscorerUserId;
  final int? assistMakerUserId;
  final CardType? cardType;

  CreateMatchEventCommand({
    required this.eventId,
    required this.type,
    required this.teamId,
    required this.goalscorerUserId,
    this.assistMakerUserId,
    this.cardType,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'type': type.wire,
      'teamId': teamId,
      'goalscorerUserId': goalscorerUserId,
      if (assistMakerUserId != null) 'assistMakerUserId': assistMakerUserId,
      if (cardType != null) 'cardType': cardType!.wire,
    };
  }
}
