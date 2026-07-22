class SeasonDetails {
  final int id;
  final int teamId;
  final String name;
  final DateTime startsOn;
  final DateTime? endsOn;
  final bool isActive;

  SeasonDetails({
    required this.id,
    required this.teamId,
    required this.name,
    required this.startsOn,
    required this.endsOn,
    required this.isActive,
  });

  factory SeasonDetails.fromJson(Map<String, dynamic> json) {
    return SeasonDetails(
      id: json['id'],
      teamId: json['team_id'],
      name: json['name'],
      startsOn: DateTime.parse(json['starts_on']),
      endsOn: json['ends_on'] == null ? null : DateTime.parse(json['ends_on']),
      isActive: json['is_active'] ?? json['ends_on'] == null,
    );
  }
}
