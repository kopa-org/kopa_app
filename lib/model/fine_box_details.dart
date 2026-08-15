import 'package:kopa/model/user_fine_details.dart';

class FineBoxDetails {
  final int id;
  final String? mobilePayBoxId;
  final double currentAmount;
  final double totalOwedAmount;
  final List<UserFineDetails> userFineDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  FineBoxDetails(
      {required this.id,
      this.mobilePayBoxId,
      required this.currentAmount,
      required this.totalOwedAmount,
      required this.userFineDetails,
      required this.createdAt,
      required this.updatedAt});

  bool get hasMobilePayBox =>
      mobilePayBoxId != null && mobilePayBoxId!.trim().isNotEmpty;

  factory FineBoxDetails.fromJson(Map<String, dynamic> json) {
    return FineBoxDetails(
      id: json['id'],
      mobilePayBoxId: json['mobilepay_box_id'],
      currentAmount: json['current_amount'] + .0, // Convert to double
      totalOwedAmount: json['total_owed_amount'] + .0, // Convert to double
      userFineDetails: json['user_fine_details'] != null
          ? List<UserFineDetails>.from(
              json['user_fine_details'].map((x) => UserFineDetails.fromJson(x)))
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
