import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

const _flagMascot = 'assets/illustrations/kopa_flag.svg';
const _walkMascot = 'assets/illustrations/kopa_walk.svg';

/// First onboarding screen: choose between creating a team (and becoming its
/// leader) or joining an existing team as a player.
class OnboardingTeamChoiceView extends StatelessWidget {
  final VoidCallback onCreateTeam;
  final VoidCallback onJoinTeam;
  final VoidCallback? onExit;

  const OnboardingTeamChoiceView({
    super.key,
    required this.onCreateTeam,
    required this.onJoinTeam,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.md + Spacing.xs,
                          Spacing.sm,
                          Spacing.sm,
                          0,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/logos/Logo.svg',
                              key: const ValueKey('onboarding-header-logo'),
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                colors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const Spacer(),
                            if (onExit != null)
                              IconButton(
                                key: const ValueKey('onboarding-exit-button'),
                                onPressed: onExit,
                                tooltip: l10n.onboardingExit,
                                icon: const Icon(Icons.close),
                                color: colors.textPrimary,
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.md + Spacing.xs,
                          Spacing.lg,
                          Spacing.md + Spacing.xs,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.onboardingGetStartedTitle,
                              style: textStyles.pageTitle
                                  .copyWith(color: colors.textPrimary),
                            ),
                            const SizedBox(height: Spacing.sm),
                            Text(
                              l10n.onboardingGetStartedSubtitle,
                              style: textStyles.body
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.md,
                          Spacing.lg,
                          Spacing.md,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TeamChoiceCard(
                              key: const ValueKey('onboarding-create-team'),
                              title: l10n.onboardingCreateTeamCardTitle,
                              description: l10n.onboardingCreateTeamCardBody,
                              actionLabel: l10n.onboardingCreateTeam,
                              mascot: _flagMascot,
                              highlighted: true,
                              onTap: onCreateTeam,
                            ),
                            const SizedBox(height: Spacing.itemGap),
                            _TeamChoiceCard(
                              key: const ValueKey('onboarding-join-team'),
                              title: l10n.onboardingJoinTeamCardTitle,
                              description: l10n.onboardingJoinTeamCardBody,
                              actionLabel: l10n.onboardingFindTeam,
                              mascot: _walkMascot,
                              highlighted: false,
                              onTap: onJoinTeam,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.md,
                          Spacing.lg,
                          Spacing.md,
                          Spacing.md,
                        ),
                        child: _InviteLinkHint(
                          text: l10n.onboardingInviteLinkHint,
                          colors: colors,
                          textStyles: textStyles,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TeamChoiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final String mascot;
  final bool highlighted;
  final VoidCallback onTap;

  const _TeamChoiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.mascot,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final borderRadius =
        BorderRadius.circular(Spacing.borderRadiusLargeIncreased);

    return Semantics(
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      child: Material(
        color: highlighted ? colors.lightGrass : colors.surface,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: 4,
                bottom: 6,
                child: InFormMascot(
                  asset: mascot,
                  size: 120,
                  color: colors.dirt,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.lg - 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 96),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textStyles.sectionHeader
                                .copyWith(color: colors.textPrimary),
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            description,
                            style: textStyles.body3.copyWith(
                              color: highlighted
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.lg - 4),
                    _ActionPill(
                      label: actionLabel,
                      highlighted: highlighted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual call to action inside a choice card; the whole card is the tap
/// target, so this is not a separate button.
class _ActionPill extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _ActionPill({required this.label, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final foreground = highlighted ? colors.white : colors.textPrimary;

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      decoration: BoxDecoration(
        color: highlighted ? colors.grass : colors.background,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textStyles.body4.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 16, color: foreground),
        ],
      ),
    );
  }
}

class _InviteLinkHint extends StatelessWidget {
  final String text;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _InviteLinkHint({
    required this.text,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colors.infoSurface,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.link_rounded, size: 20, color: colors.infoForeground),
          const SizedBox(width: Spacing.itemGap),
          Expanded(
            child: Text(
              text,
              style: textStyles.body3.copyWith(color: colors.infoForeground),
            ),
          ),
        ],
      ),
    );
  }
}
