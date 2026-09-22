class MatchPollUserVotesDetails {
  final int id;
  final int matchPollId;
  final int? userId;
  final String? userName;
  final int? externalPlayerId;
  final String? externalPlayerName;
  final int numberOfVotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatchPollUserVotesDetails(
      {required this.id,
      required this.matchPollId,
      required this.userId,
      this.userName,
      this.externalPlayerId,
      this.externalPlayerName,
      required this.numberOfVotes,
      required this.createdAt,
      required this.updatedAt});

  factory MatchPollUserVotesDetails.fromJson(Map<String, dynamic> json) {
    return MatchPollUserVotesDetails(
      id: json['id'],
      matchPollId: json['match_poll_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      externalPlayerId: json['external_player_id'],
      externalPlayerName: json['external_player_name'],
      numberOfVotes: json['number_of_votes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
