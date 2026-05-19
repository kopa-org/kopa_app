class CreateFineTypeCommand {
  final String title;
  final String defaultAmount;

  CreateFineTypeCommand({required this.title, required this.defaultAmount});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'default_amount': defaultAmount,
    };
  }
}
