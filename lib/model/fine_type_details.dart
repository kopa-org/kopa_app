class FineTypeDetails {
  final int id;
  final String title;
  final int defaultAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  FineTypeDetails({
    required this.id,
    required this.title,
    required this.defaultAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FineTypeDetails.fromJson(Map<String, dynamic> json) {
    return FineTypeDetails(
      id: json['id'],
      title: json['title'],
      defaultAmount: json['default_amount'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
