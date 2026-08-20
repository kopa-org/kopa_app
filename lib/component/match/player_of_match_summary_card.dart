import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class PlayerOfMatchSummaryCard extends StatelessWidget {
  final String? playerName;
  final int? voteCount;
  final VoidCallback? onPressed;

  const PlayerOfMatchSummaryCard({
    super.key,
    required this.playerName,
    this.voteCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final winnerName = playerName?.trim();
    final hasWinner = winnerName != null && winnerName.isNotEmpty;

    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: hasWinner
            ? appColors.lightGrass.withValues(alpha: 0.62)
            : appColors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasWinner
              ? appColors.grass.withValues(alpha: 0.24)
              : appColors.grey3.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasWinner ? appColors.sunset : appColors.grey3,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 21,
              color: appColors.white,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kampens spiller',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.label.copyWith(
                    color: hasWinner ? appColors.grass : appColors.grey5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasWinner ? winnerName : 'Ikke valgt endnu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.subtitle2.copyWith(
                    color: hasWinner ? appColors.dirt : appColors.grey5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (hasWinner && voteCount != null) ...[
            const SizedBox(width: Spacing.sm),
            Text(
              'Stemmer: $voteCount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.caption2.copyWith(
                color: appColors.grass,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );

    final onPressed = this.onPressed;
    if (onPressed == null) return child;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: child,
      ),
    );
  }
}
