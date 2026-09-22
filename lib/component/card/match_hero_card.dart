import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class MatchHeroCard extends StatelessWidget {
  final MatchDetails match;
  final VoidCallback? onTap;
  final Widget? topRightAction;
  final Widget? bottomAction;
  final bool animateCard;
  final String? heroTag;
  final String? ownTeamName;
  final TeamLogoDesign? ownTeamLogoDesign;

  const MatchHeroCard({
    super.key,
    required this.match,
    this.onTap,
    this.topRightAction,
    this.bottomAction,
    this.animateCard = true,
    this.heroTag,
    this.ownTeamName,
    this.ownTeamLogoDesign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final hasScore = match.hasFinalScore;

    final cardContent = KopaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: Spacing.borderRadiusLargeIncreased,
      color: match.isTraining ? appColors.lightSky65 : null,
      child: match.isTraining
          ? _TrainingHeroContent(match: match, title: l10n.eventTraining)
          : Column(
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
                          logoDesign: _logoForTeam(match.homeTeam ?? 'Hjemme'),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.md,
                          ),
                          child: Text(
                            'VS',
                            style: appTextStyles.h5.copyWith(
                              color: appColors.dirt,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 100,
                        child: TeamBadgeLabel(
                          teamName: match.awayTeam ?? 'Ude',
                          teamId: stableTeamSeed(match.awayTeam ?? 'Ude'),
                          logoDesign: _logoForTeam(match.awayTeam ?? 'Ude'),
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
                if (bottomAction != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: bottomAction!,
                  ),
              ],
            ),
    );

    final card = topRightAction == null
        ? cardContent
        : Stack(
            clipBehavior: Clip.none,
            children: [
              cardContent,
              Positioned(
                top: -8,
                right: -8,
                child: topRightAction!,
              ),
            ],
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

  TeamLogoDesign? _logoForTeam(String teamName) {
    if (ownTeamName == null || ownTeamLogoDesign == null) return null;
    return teamNamesMatch(teamName, ownTeamName!) ? ownTeamLogoDesign : null;
  }

  static String defaultHeroTag(int matchId) => 'match-$matchId-hero-card';

  static String logoHeroTag(String cardHeroTag, TeamSide side) {
    return '$cardHeroTag-${side.name}-team-logo';
  }
}

class _TrainingHeroContent extends StatelessWidget {
  final MatchDetails match;
  final String title;

  const _TrainingHeroContent({required this.match, required this.title});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: appColors.lightSky95,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              color: appColors.sky,
              size: 28,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appTextStyles.h5.copyWith(
                    color: appColors.dirt,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (match.category?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    match.category!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.body3.copyWith(
                      color: appColors.grey5,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${DateHelper.getFormattedTime(match.date)} · ${match.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.body3.copyWith(color: appColors.grey5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      ],
    );
  }
}

enum TeamSide { home, away }
