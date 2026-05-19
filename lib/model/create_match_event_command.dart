import 'package:kopa/model/card_type.dart';
import 'package:kopa/model/match_event_type.dart';

class CreateMatchEventCommand {
  final int eventId;
  final MatchEventType type;
  final int? minute;
  final int teamId;
  final int goalscorerUserId;
  final int? assistMakerUserId;
  final CardType? cardType;

  CreateMatchEventCommand({
    required this.eventId,
    required this.type,
    this.minute,
    required this.teamId,
    required this.goalscorerUserId,
    this.assistMakerUserId,
    this.cardType,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'type': type.wire,
      if (minute != null) 'minute': minute,
      'team_id': teamId,
      'goalscorer_user_id': goalscorerUserId,
      if (assistMakerUserId != null) 'assist_maker_user_id': assistMakerUserId,
      if (cardType != null) 'card_type': cardType!.wire,
    };
  }
}
