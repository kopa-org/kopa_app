import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/password_reset_request.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_codeSent && !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await context
          .read<AuthCubit>()
          .requestPasswordResetCode(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.resetCodeSent)),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context)!.resetRequestFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final code = _codeController.text.trim();
      final isValid =
          await context.read<AuthCubit>().verifyPasswordResetCode(email, code);
      if (!mounted) return;
      if (!isValid) {
        _showMessage(AppLocalizations.of(context)!.resetCodeInvalid);
        return;
      }
      context.push(
        AppRouter.resetPassword,
        extra: PasswordResetRequest(email: email, code: code),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context)!.resetCodeInvalid);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: BackButton(color: appColors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset('assets/logos/Logo.svg', height: 80),
                const SizedBox(height: 40),
                Text(l10n.forgotPasswordTitle,
                    style: appTextStyles.sectionHeader),
                const SizedBox(height: 12),
                Text(
                  _codeSent
                      ? l10n.forgotPasswordCodeInstructions
                      : l10n.forgotPasswordInstructions,
                  style: appTextStyles.body,
                ),
                const SizedBox(height: 24),
                if (!_codeSent)
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.forgotPasswordEmail,
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: appColors.grass),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.forgotPasswordEmailRequired;
                      }
                      if (!value.contains('@')) {
                        return l10n.forgotPasswordEmailInvalid;
                      }
                      return null;
                    },
                  )
                else ...[
                  Text(
                    _emailController.text.trim(),
                    style: appTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: l10n.forgotPasswordCode,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.length != 6) {
                        return l10n.forgotPasswordCodeLength;
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _isLoading ? null : _requestCode,
                      child: Text(l10n.forgotPasswordResend),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _codeSent
                          ? _verifyCode
                          : _requestCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    foregroundColor: AppColors.of(context).white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: appTextStyles.button,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: AppColors.of(context).white)
                      : Text(_codeSent
                          ? l10n.forgotPasswordVerify
                          : l10n.forgotPasswordSendCode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
