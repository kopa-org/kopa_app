import 'package:kopa/model/fine_type_details.dart';

class FineDetails {
  final int id;
  final FineTypeDetails fineTypeDetails;
  final int owedAmount;
  final bool hasBeenPaid;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  FineDetails({
    required this.id,
    required this.fineTypeDetails,
    required this.owedAmount,
    required this.hasBeenPaid,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FineDetails.fromJson(Map<String, dynamic> json) {
    return FineDetails(
      id: json['id'],
      fineTypeDetails: FineTypeDetails.fromJson(json['fine_type_details']),
      owedAmount: (json['owed_amount'] as num).toInt(),
      hasBeenPaid: json['has_been_paid'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
