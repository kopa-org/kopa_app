import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/repository/authentication_repository.dart';
import 'package:kopa/services/platform_service.dart';
import 'package:kopa/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthenticationRepository.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      2,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      // Auto-login after successful registration
      try {
        await context.read<AuthCubit>().login(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.uiCouldNotLogInAutomatically;
        });
      }
    } else {
      setState(() {
        _errorMessage = result['message'] ??
            AppLocalizations.of(context)!.uiRegistrationFailedTryAgain;
      });
    }
  }

  // --- Validators (Danish messages; English comments) ---
  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.uiPleaseEnterYourName;
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppLocalizations.of(context)!.uiPleaseEnterYourEmail;
    if (!v.contains('@') || !v.contains('.')) {
      return AppLocalizations.of(context)!.uiPleaseEnterAValidEmail;
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppLocalizations.of(context)!.uiPleaseEnterAPassword;
    if (v.length < 6) {
      return AppLocalizations.of(context)!.uiThePasswordMustBeAtLeast;
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useCupertino = PlatformService.isIOS;
    final theme = Theme.of(context);

    // Shared content built once; fields switch inline based on platform
    final content = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.sports_soccer,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Kopa',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)!.uiCreateUser,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 30),

              // --- Name field ---
              useCupertino
                  ? _cupertinoField(
                      controller: _nameController,
                      placeholder: AppLocalizations.of(context)!.uiName,
                      validator: _nameValidator,
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.name],
                    )
                  : TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.uiName,
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.name],
                      validator: _nameValidator,
                    ),

              const SizedBox(height: 20),

              // --- Email field ---
              useCupertino
                  ? _cupertinoField(
                      controller: _emailController,
                      placeholder:
                          AppLocalizations.of(context)!.forgotPasswordEmail,
                      validator: _emailValidator,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email
                      ],
                    )
                  : TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.forgotPasswordEmail,
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email
                      ],
                      validator: _emailValidator,
                    ),

              const SizedBox(height: 20),

              // --- Password field ---
              useCupertino
                  ? _cupertinoField(
                      controller: _passwordController,
                      placeholder: AppLocalizations.of(context)!.uiPassword,
                      validator: _passwordValidator,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _register(),
                    )
                  : TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.uiPassword,
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _register(),
                      validator: _passwordValidator,
                    ),

              const SizedBox(height: 30),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              _isLoading
                  ? const LoadingIndicator()
                  : FullWidthButton(
                      buttonText: AppLocalizations.of(context)!.uiCreateAccount,
                      onPressed: _register,
                    ),

              const SizedBox(height: 20),

              FullWidthButton(
                buttonText: AppLocalizations.of(context)!.uiCancel,
                onPressed: () => Navigator.of(context).pop(),
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap in the native scaffold for each platform
    return useCupertino
        ? CupertinoPageScaffold(
            backgroundColor: AppColors.of(context).background,
            child: content,
          )
        : Scaffold(
            backgroundColor: AppColors.of(context).background,
            body: content,
          );
  }

  /// Reusable Cupertino field with inline validator error presentation.
  Widget _cupertinoField({
    required TextEditingController controller,
    required String placeholder,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<String>? autofillHints,
    void Function(String)? onSubmitted,
  }) {
    return FormField<String>(
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              autofillHints: autofillHints,
              textInputAction:
                  obscureText ? TextInputAction.done : TextInputAction.next,
              onSubmitted: onSubmitted,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              placeholder: placeholder,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: state.didChange,
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 8),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: AppColors.of(context).error,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
