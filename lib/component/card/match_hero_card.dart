import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class MatchHeroCard extends StatelessWidget {
  final MatchDetails match;
  final VoidCallback? onTap;
  final bool animateCard;
  final String? heroTag;

  const MatchHeroCard({
    super.key,
    required this.match,
    this.onTap,
    this.animateCard = true,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final hasScore = match.hasMatchBeenPlayed;

    final card = KopaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: Spacing.borderRadiusLargeIncreased,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: TeamBadgeLabel(
                    teamName: match.homeTeam ?? 'Hjemme',
                    teamId: stableTeamSeed(match.homeTeam ?? 'Hjemme'),
                    heroTag: heroTag == null
                        ? null
                        : logoHeroTag(heroTag!, TeamSide.home),
                    radius: 23,
                    labelMaxLines: 1,
                    labelStyle: appTextStyles.caption.copyWith(
                      color: appColors.dirt,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (hasScore)
                  _FinalScorePill(match: match)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: Text(
                      'VS',
                      style: appTextStyles.h5.copyWith(
                        color: appColors.grass,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 100,
                  child: TeamBadgeLabel(
                    teamName: match.awayTeam ?? 'Ude',
                    teamId: stableTeamSeed(match.awayTeam ?? 'Ude'),
                    heroTag: heroTag == null
                        ? null
                        : logoHeroTag(heroTag!, TeamSide.away),
                    radius: 23,
                    labelMaxLines: 1,
                    labelStyle: appTextStyles.caption.copyWith(
                      color: appColors.dirt,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!animateCard || heroTag != null) return card;

    return Hero(
      tag: defaultHeroTag(match.id),
      transitionOnUserGestures: true,
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      child: Material(
        type: MaterialType.transparency,
        child: card,
      ),
    );
  }

  static String defaultHeroTag(int matchId) => 'match-$matchId-hero-card';

  static String logoHeroTag(String cardHeroTag, TeamSide side) {
    return '$cardHeroTag-${side.name}-team-logo';
  }
}

class _FinalScorePill extends StatelessWidget {
  final MatchDetails match;

  const _FinalScorePill({required this.match});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${match.homeTeamScore} - ${match.awayTeamScore}',
          style: appTextStyles.h3.copyWith(
            color: appColors.dirt,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: appColors.lightGrass,
            borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
          ),
          child: Text(
            'Færdig',
            style: appTextStyles.caption2.copyWith(
              color: const Color(0xFF105230),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

enum TeamSide { home, away }
