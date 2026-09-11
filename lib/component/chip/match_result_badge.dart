import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

enum MatchResultStatus {
  win,
  draw,
  loss;

  static MatchResultStatus fromScores({
    required int teamScore,
    required int opponentScore,
  }) {
    if (teamScore == opponentScore) return MatchResultStatus.draw;
    return teamScore > opponentScore
        ? MatchResultStatus.win
        : MatchResultStatus.loss;
  }

  String get label => switch (this) {
        MatchResultStatus.win => 'Sejr',
        MatchResultStatus.draw => 'Uafgjort',
        MatchResultStatus.loss => 'Tabt',
      };
}

enum MatchOverviewChipStatus { success, warning, error, info, neutral }

class MatchOverviewChip extends StatelessWidget {
  final String label;
  final MatchOverviewChipStatus status;
  final IconData? icon;

  const MatchOverviewChip({
    super.key,
    required this.label,
    this.status = MatchOverviewChipStatus.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final (foregroundColor, backgroundColor) = switch (status) {
      MatchOverviewChipStatus.success => (
          appColors.successForeground,
          appColors.successSurface,
        ),
      MatchOverviewChipStatus.warning => (
          appColors.warningForeground,
          appColors.warningSurface,
        ),
      MatchOverviewChipStatus.error => (
          appColors.errorForeground,
          appColors.errorSurface,
        ),
      MatchOverviewChipStatus.info => (
          appColors.infoForeground,
          appColors.infoSurface,
        ),
      MatchOverviewChipStatus.neutral => (appColors.dirt, appColors.offWhite),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: foregroundColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: appTextStyles.buttonTiny.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class MatchResultBadge extends StatelessWidget {
  final MatchResultStatus result;

  const MatchResultBadge({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    final status = switch (result) {
      MatchResultStatus.win => MatchOverviewChipStatus.success,
      MatchResultStatus.draw => MatchOverviewChipStatus.neutral,
      MatchResultStatus.loss => MatchOverviewChipStatus.error,
    };

    return MatchOverviewChip(
      label: result.label,
      status: status,
    );
  }
}
