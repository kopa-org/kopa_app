class TeamDetails {
  final int id;
  final String title;
  final int playerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeamDetails({
    required this.id,
    required this.title,
    this.playerCount = 7,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      id: json['id'],
      title: json['title'],
      playerCount: json['player_count'] ?? 7,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
