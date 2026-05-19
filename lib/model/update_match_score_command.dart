class UpdateMatchScoreCommand {
  final int eventId;
  final int homeTeamScore;
  final int awayTeamScore;

  UpdateMatchScoreCommand({
    required this.eventId,
    required this.homeTeamScore,
    required this.awayTeamScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'home_team_score': homeTeamScore,
      'away_team_score': awayTeamScore,
    };
  }
}
