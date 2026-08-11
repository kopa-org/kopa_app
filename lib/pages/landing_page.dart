import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 52),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const _LandingLogo(),
              const Spacer(flex: 2),
              Text(
                'Saml dit hold\nét sted',
                style: styles.h3.copyWith(
                  color: colors.dirt,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: Text(
                  'Få fuldt overblik over dine kampe, holdopstillinger, '
                  'bødekasse og kommunikation på holdet.',
                  style: styles.body3.copyWith(
                    color: colors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),
              _LandingActionButton.primary(
                label: 'Opret konto',
                onPressed: () => context.push(AppRouter.register),
              ),
              const SizedBox(height: 12),
              _LandingActionButton.secondary(
                label: 'Log ind',
                onPressed: () => context.push(AppRouter.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingLogo extends StatelessWidget {
  const _LandingLogo();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/logos/logomark_outline_foreground.svg',
          width: 60,
          height: 60,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        const SizedBox(width: 6),
        Text(
          'KOPA',
          style: styles.h2.copyWith(
            color: colors.primary,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _LandingActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final List<BoxShadow> boxShadow;

  const _LandingActionButton._({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.boxShadow = const [],
  });

  factory _LandingActionButton.primary({
    required String label,
    required VoidCallback onPressed,
  }) {
    return _LandingActionButton._(
      label: label,
      onPressed: onPressed,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0C8A45).withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  factory _LandingActionButton.secondary({
    required String label,
    required VoidCallback onPressed,
  }) {
    return _LandingActionButton._(
      label: label,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF2D1000),
      borderColor: const Color(0xFFD1D6E0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF0C8A45),
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 1.5),
          borderRadius: BorderRadius.circular(28),
          boxShadow: boxShadow,
        ),
        child: Text(
          label,
          style: styles.subtitle2.copyWith(
            color: foregroundColor ?? colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
