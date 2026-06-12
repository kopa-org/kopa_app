class CreateUserFineCommand {
  String userId;
  String fineTypeId;
  String owedAmount;
  String? note;

  CreateUserFineCommand({
    required this.userId,
    required this.fineTypeId,
    required this.owedAmount,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fine_type_id': fineTypeId,
      'owed_amount': owedAmount,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }
}
