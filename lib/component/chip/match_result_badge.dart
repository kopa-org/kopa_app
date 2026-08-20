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
        MatchResultStatus.draw => 'UAFGJORT',
        MatchResultStatus.loss => 'TABT',
      };
}

class MatchResultBadge extends StatelessWidget {
  final MatchResultStatus result;

  const MatchResultBadge({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.lightGrass55,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Text(
        result.label,
        style: appTextStyles.buttonTiny.copyWith(
          color: appColors.grass,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
