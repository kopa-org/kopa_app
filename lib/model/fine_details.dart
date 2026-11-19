import 'package:kopa/model/fine_type_details.dart';

class FineDetails {
  final int id;
  final FineTypeDetails fineTypeDetails;
  final int owedAmount;
  final bool hasBeenPaid;
  final String? note;

  /// The match the fine was given at, if the fine admin picked one.
  final FineMatch? match;
  final DateTime createdAt;
  final DateTime updatedAt;

  FineDetails({
    required this.id,
    required this.fineTypeDetails,
    required this.owedAmount,
    required this.hasBeenPaid,
    this.note,
    this.match,
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
      match: json['match'] is Map<String, dynamic>
          ? FineMatch.fromJson(json['match'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class FineMatch {
  final int id;
  final String? opponent;
  final DateTime date;

  const FineMatch({required this.id, this.opponent, required this.date});

  factory FineMatch.fromJson(Map<String, dynamic> json) {
    return FineMatch(
      id: json['id'],
      opponent: json['opponent'],
      date: DateTime.parse(json['date']).toLocal(),
    );
  }
}
