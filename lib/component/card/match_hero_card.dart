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

    final card = KopaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TeamBadgeLabel(
                    teamName: match.homeTeam ?? 'Hjemme',
                    teamId: stableTeamSeed(match.homeTeam ?? 'Hjemme'),
                    heroTag: heroTag == null
                        ? null
                        : logoHeroTag(heroTag!, TeamSide.home),
                    radius: 22,
                    labelMaxLines: 2,
                    labelStyle: appTextStyles.caption.copyWith(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
                Expanded(
                  child: TeamBadgeLabel(
                    teamName: match.awayTeam ?? 'Ude',
                    teamId: stableTeamSeed(match.awayTeam ?? 'Ude'),
                    heroTag: heroTag == null
                        ? null
                        : logoHeroTag(heroTag!, TeamSide.away),
                    radius: 22,
                    labelMaxLines: 2,
                    labelStyle: appTextStyles.caption.copyWith(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w700,
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

enum TeamSide { home, away }
