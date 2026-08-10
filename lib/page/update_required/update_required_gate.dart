import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/cubits/feature_flags_cubit.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateRequiredGate extends StatelessWidget {
  const UpdateRequiredGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagsCubit, FeatureFlagsState>(
      buildWhen: (previous, current) =>
          previous.updateRequired != current.updateRequired,
      builder: (context, state) {
        if (!state.updateRequired) return child;

        return const UpdateRequiredPage();
      },
    );
  }
}

class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key});

  static final Uri _androidUpdateUri =
      Uri.parse('https://play.google.com/apps/testing/dk.kopa.app');
  static final Uri _iosUpdateUri =
      Uri.parse('https://testflight.apple.com/join/cXrT8De7');
  static final Uri _fallbackUpdateUri = Uri.parse('https://kopa.dk');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Scaffold(
      backgroundColor: colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _KopaWordmark(),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 342),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _BallIllustration(),
                            SizedBox(
                              height: constraints.maxHeight < 700 ? 28 : 36,
                            ),
                            Text(
                              'Opdatering påkrævet',
                              textAlign: TextAlign.center,
                              style: styles.h4.copyWith(
                                color: colors.dirt,
                                fontWeight: FontWeight.w800,
                                height: 36 / 28,
                              ),
                            ),
                            const SizedBox(height: Spacing.md),
                            Text(
                              'En ny version af Kopa er tilgængelig. Opdater venligst for at fortsætte din holdoplevelse.',
                              textAlign: TextAlign.center,
                              style: styles.body4.copyWith(
                                color: colors.grey5,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _UpdateActionButton(
                    label: 'Opdater nu',
                    backgroundColor: colors.primary,
                    foregroundColor: colors.white,
                    shadowColor: colors.primary.withValues(alpha: 0.20),
                    onPressed: () {
                      launchUrl(
                        _updateUriForPlatform(defaultTargetPlatform),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Uri _updateUriForPlatform(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.android => _androidUpdateUri,
      TargetPlatform.iOS => _iosUpdateUri,
      _ => _fallbackUpdateUri,
    };
  }
}

class _KopaWordmark extends StatelessWidget {
  const _KopaWordmark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SvgPicture.asset(
        'assets/logos/Logo.svg',
        width: 64,
        height: 26,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _BallIllustration extends StatelessWidget {
  const _BallIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      width: 220,
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
      ),
      child: Lottie.asset(
        'assets/lottie/Ball.json',
        width: 180,
        height: 180,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _UpdateActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final Color? shadowColor;

  const _UpdateActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: shadowColor == null
            ? null
            : [
                BoxShadow(
                  color: shadowColor!,
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              label,
              style: styles.subtitle2.copyWith(
                color: foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
