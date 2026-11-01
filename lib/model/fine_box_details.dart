import 'package:kopa/model/user_fine_details.dart';

class FineBoxDetails {
  final int id;
  final String? mobilePayBoxId;
  final double currentAmount;
  final double totalOwedAmount;
  final List<UserFineDetails> userFineDetails;
  final List<FineBoxWithdrawal> withdrawals;
  final DateTime createdAt;
  final DateTime updatedAt;

  FineBoxDetails(
      {required this.id,
      this.mobilePayBoxId,
      required this.currentAmount,
      required this.totalOwedAmount,
      required this.userFineDetails,
      this.withdrawals = const [],
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
      withdrawals: json['withdrawals'] != null
          ? List<FineBoxWithdrawal>.from(
              json['withdrawals'].map((x) => FineBoxWithdrawal.fromJson(x)))
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Money a fine admin took out of the box, newest first from the API.
class FineBoxWithdrawal {
  final int id;
  final double amount;
  final String? note;
  final String? userName;
  final DateTime createdAt;

  FineBoxWithdrawal({
    required this.id,
    required this.amount,
    this.note,
    this.userName,
    required this.createdAt,
  });

  factory FineBoxWithdrawal.fromJson(Map<String, dynamic> json) {
    return FineBoxWithdrawal(
      id: json['id'],
      amount: json['amount'] + .0,
      note: json['note'],
      userName: json['user_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
