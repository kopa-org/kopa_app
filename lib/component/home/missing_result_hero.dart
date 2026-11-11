import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Shown once nothing is left on the schedule but a played match still has no
/// result. The Season Wrapped is built from results, so it waits for this.
class MissingResultHero extends StatelessWidget {
  /// The most recent match without a result.
  final MatchDetails match;

  /// How many other played matches also miss a result.
  final int otherMissing;
  final bool canEnterResult;
  final VoidCallback onEnterResult;

  const MissingResultHero({
    super.key,
    required this.match,
    required this.otherMissing,
    required this.canEnterResult,
    required this.onEnterResult,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final home = match.homeTeam ?? l10n.matchScoreHome;
    final away = match.awayTeam ?? l10n.matchScoreAway;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.wrappedMissingResultEyebrow,
            style: textStyles.caption2.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.wrappedMissingResultTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyles.h2.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.05,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Container(
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(HomeBentoCard.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    14,
                    Spacing.md,
                    Spacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.lightGrass,
                    borderRadius:
                        BorderRadius.circular(HomeBentoCard.cardRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateHelper.getFormattedMatchDate(match.date),
                        style: textStyles.caption.copyWith(
                          color: colors.dirt,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _Team(name: home)),
                          SizedBox(
                            width: 64,
                            height: 54,
                            child: Center(
                              child: Text(
                                '? - ?',
                                style: textStyles.h5.copyWith(
                                  color: colors.dirt,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: _Team(name: away)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.sunset.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.scoreboard_outlined,
                              color: WrappedPalette.warningText,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: Spacing.itemGap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.wrappedMissingResultBody,
                                  style: textStyles.body3.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                                if (otherMissing > 0) ...[
                                  const SizedBox(height: Spacing.xs),
                                  Text(
                                    l10n.wrappedMissingResultMore(
                                      otherMissing,
                                    ),
                                    style: textStyles.caption3.copyWith(
                                      color: WrappedPalette.warningText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      if (canEnterResult)
                        FullWidthButton(
                          icon: Icons.edit_outlined,
                          buttonText: l10n.wrappedEnterResult,
                          onPressed: onEnterResult,
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: colors.grey5,
                            ),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: Text(
                                l10n.wrappedMissingResultPlayerHint,
                                style: textStyles.caption.copyWith(
                                  color: colors.grey5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Team extends StatelessWidget {
  final String name;

  const _Team({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Center(
      child: TeamBadgeLabel(
        teamName: name,
        teamId: stableTeamSeed(name),
        width: 86,
        radius: 22,
        labelMaxLines: 2,
        labelStyle: textStyles.caption.copyWith(
          color: colors.dirt,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
