import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/navigation/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final onboardingState = context.read<OnboardingCubit>().state;
    if (onboardingState.email != null) {
      _emailController.text = onboardingState.email!;
    }
    if (onboardingState.name != null) {
      _nameController.text = onboardingState.name!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) async {
            if (ModalRoute.of(context)?.isCurrent != true) return;
            if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ??
                      AppLocalizations.of(context)!.uiRegistrationFailed),
                  backgroundColor: appColors.error,
                ),
              );
            } else if (state.status == AuthStatus.authenticated) {
              context.push(AppRouter.onboarding);
            }
          },
        ),
        BlocListener<OnboardingCubit, OnboardingState>(
          listener: (context, state) async {
            if (ModalRoute.of(context)?.isCurrent != true) return;
            if (state.status == OnboardingStatus.validated &&
                (state.email != null || state.name != null)) {
              if (state.email != null) {
                _emailController.text = state.email!;
              }
              if (state.name != null) {
                _nameController.text = state.name!;
              }
            } else if (state.status == OnboardingStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.uiYouHaveJoinedTheTeam),
                  backgroundColor: AppColors.of(context).success,
                ),
              );
              final authCubit = context.read<AuthCubit>();
              final onboardingCubit = context.read<OnboardingCubit>();
              await authCubit.init();
              if (!context.mounted) return;
              onboardingCubit.clearOnboarding();
              if (context.mounted) context.go(AppRouter.home);
            } else if (state.status == OnboardingStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ??
                      AppLocalizations.of(context)!.uiCouldNotJoinTheTeam),
                  backgroundColor: appColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: appColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.transparent,
              elevation: 0,
              leading: BackButton(
                  color: appColors.black,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRouter.welcome);
                    }
                  }),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SvgPicture.asset(
                        'assets/logos/Logo.svg',
                        height: 80,
                      ),
                      const SizedBox(height: 48),
                      BlocBuilder<OnboardingCubit, OnboardingState>(
                        builder: (context, onboardingState) {
                          if (onboardingState.teamTitle != null) {
                            return Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.uiBecomePartOf,
                                  style: appTextStyles.body,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  onboardingState.teamTitle!,
                                  style: appTextStyles.sectionHeader
                                      .copyWith(color: appColors.primary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }
                          return Text(
                            AppLocalizations.of(context)!.uiCreateUser,
                            style: appTextStyles.sectionHeader,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.uiName,
                          border: const OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.person, color: appColors.grass),
                        ),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!
                                .uiPleaseEnterYourName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: appColors.grass),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .uiPleaseEnterYourEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.uiPassword,
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock, color: appColors.grass),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .uiPleaseEnterYourPassword;
                          }
                          if (value.length < 6) {
                            return AppLocalizations.of(context)!
                                .uiPasswordMustBeAtLeast6;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.primary,
                          foregroundColor: AppColors.of(context).white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: appTextStyles.button,
                        ),
                        child: state.status == AuthStatus.loading
                            ? CircularProgressIndicator(
                                color: AppColors.of(context).white)
                            : Text(
                                AppLocalizations.of(context)!.uiCreateAccount2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
