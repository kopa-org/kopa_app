enum MatchEventType { goal, yellowCard, redCard, substitution, penaltyKick }

extension MatchEventTypeWire on MatchEventType {
  String get wire => const {
        MatchEventType.goal: 'GOAL',
        MatchEventType.yellowCard: 'YELLOW_CARD',
        MatchEventType.redCard: 'RED_CARD',
        MatchEventType.substitution: 'SUBSTITUTION',
        MatchEventType.penaltyKick: 'PENALTY_KICK',
      }[this]!;
}
