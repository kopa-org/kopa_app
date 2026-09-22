class UserVote {
  final int? userId;
  final int? externalPlayerId;
  int votes;

  UserVote({this.userId, this.externalPlayerId, required this.votes})
      : assert((userId == null) != (externalPlayerId == null));

  int get stableId => userId ?? -externalPlayerId!;

  void setVotes(int votes) {
    this.votes = votes;
  }
}
