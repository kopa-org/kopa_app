class CreateUserFineCommand {
  String userId;
  String fineTypeId;
  String owedAmount;

  CreateUserFineCommand({
    required this.userId,
    required this.fineTypeId,
    required this.owedAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fine_type_id': fineTypeId,
      'owed_amount': owedAmount,
    };
  }
}
