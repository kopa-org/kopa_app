class CreateMatchPollUserVoteCommand {
  String? userId;
  String? externalPlayerId;
  String userVotes;

  CreateMatchPollUserVoteCommand(
      {this.userId, this.externalPlayerId, required this.userVotes});

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (externalPlayerId != null) 'external_player_id': externalPlayerId,
      'user_votes': userVotes,
    };
  }
}
