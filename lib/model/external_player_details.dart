class ExternalPlayerDetails {
  final int id;
  final int eventId;
  final String name;
  final int? lineupSlot;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExternalPlayerDetails({
    required this.id,
    required this.eventId,
    required this.name,
    this.lineupSlot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExternalPlayerDetails.fromJson(Map<String, dynamic> json) {
    return ExternalPlayerDetails(
      id: json['id'],
      eventId: json['event_id'],
      name: json['name'],
      lineupSlot: json['lineup_slot'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
