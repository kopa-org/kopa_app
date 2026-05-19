class TeamDetails {
  final int id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeamDetails({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
