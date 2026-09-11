import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final winnerName = playerName?.trim();
    final hasWinner = winnerName != null && winnerName.isNotEmpty;
    final isActionable = onPressed != null;
    final isHighlighted = hasWinner || isActionable;

    final child = SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: hasWinner
                ? appColors.lightGrass.withValues(alpha: 0.62)
                : isActionable
                    ? appColors.lightGrass.withValues(alpha: 0.36)
                    : appColors.offWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasWinner
                  ? appColors.grass.withValues(alpha: 0.24)
                  : isActionable
                      ? appColors.grass.withValues(alpha: 0.34)
                      : appColors.grey3.withValues(alpha: 0.36),
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasWinner
                          ? appColors.sunset
                          : isActionable
                              ? appColors.primary
                              : appColors.grey3,
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
                          l10n.matchPollTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyles.label.copyWith(
                            color: isHighlighted
                                ? appColors.grass
                                : appColors.grey5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasWinner ? winnerName : 'Ikke valgt endnu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyles.subtitle2.copyWith(
                            color: isHighlighted
                                ? appColors.dirt
                                : appColors.grey5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!hasWinner && isActionable) ...[
                    const SizedBox(width: Spacing.sm),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.matchPollCreateAction,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: appTextStyles.caption2.copyWith(
                                color: appColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: appColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
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
            ),
          ),
        ),
      ),
    );

    if (!isActionable) return child;

    return Semantics(
      button: true,
      child: child,
    );
  }
}
