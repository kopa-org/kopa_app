import 'dart:convert';

class DepositAmountToFineBoxCommand {
  final String fineBoxId;
  final String amountToDeposit;
  final List<String> userFineIds;

  DepositAmountToFineBoxCommand({
    required this.fineBoxId,
    required this.amountToDeposit,
    required this.userFineIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'fine_box_id': fineBoxId,
      'amount_to_deposit': amountToDeposit,
      'user_fine_ids': jsonEncode(userFineIds),
    };
  }
}
