class PasswordResetRequest {
  final String email;
  final String code;

  const PasswordResetRequest({required this.email, required this.code});
}
