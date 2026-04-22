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
      'eventId': eventId,
      'homeTeamScore': homeTeamScore,
      'awayTeamScore': awayTeamScore,
    };
  }
}
