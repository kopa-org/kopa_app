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

class MatchOverviewChip extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData? icon;

  const MatchOverviewChip({
    super.key,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

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
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final (foreground, background) = switch (result) {
      MatchResultStatus.win => (
          appColors.successForeground,
          appColors.successSurface
        ),
      MatchResultStatus.draw => (appColors.dirt, appColors.offWhite),
      MatchResultStatus.loss => (
          appColors.errorForeground,
          appColors.errorSurface
        ),
    };

    return MatchOverviewChip(
      label: result.label,
      foregroundColor: foreground,
      backgroundColor: background,
    );
  }
}
