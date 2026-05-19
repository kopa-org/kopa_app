class MatchPollUserVotesDetails {
  final int id;
  final int matchPollId;
  final int userId;
  final int numberOfVotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatchPollUserVotesDetails(
      {required this.id,
      required this.matchPollId,
      required this.userId,
      required this.numberOfVotes,
      required this.createdAt,
      required this.updatedAt});

  factory MatchPollUserVotesDetails.fromJson(Map<String, dynamic> json) {
    return MatchPollUserVotesDetails(
      id: json['id'],
      matchPollId: json['match_poll_id'],
      userId: json['user_id'],
      numberOfVotes: json['number_of_votes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
