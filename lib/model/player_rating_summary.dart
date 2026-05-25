class PlayerRatingSummary {
  final int userId;
  final String userName;
  final double averageRating;
  final int voteCount;

  PlayerRatingSummary({
    required this.userId,
    required this.userName,
    required this.averageRating,
    required this.voteCount,
  });

  factory PlayerRatingSummary.fromJson(Map<String, dynamic> json) {
    return PlayerRatingSummary(
      userId: json['user_id'],
      userName: json['user_name'],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] ?? 0,
    );
  }
}
