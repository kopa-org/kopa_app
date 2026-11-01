import 'dart:ui' show lerpDouble;

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

/// Tells a [MatchHeroCard] how far its pinned header has collapsed, from 0
/// (expanded) to 1 (fully pinned).
class MatchHeroCollapse extends InheritedWidget {
  final double value;

  const MatchHeroCollapse({
    super.key,
    required this.value,
    required super.child,
  });

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MatchHeroCollapse>()?.value ??
      0;

  @override
  bool updateShouldNotify(MatchHeroCollapse oldWidget) =>
      value != oldWidget.value;
}

class MatchHeroCard extends StatelessWidget {
  final MatchDetails match;
  final VoidCallback? onTap;
  final Widget? topRightAction;
  final Widget? bottomAction;
  final bool animateCard;
  final String? heroTag;
  final String? ownTeamName;
  final TeamLogoDesign? ownTeamLogoDesign;
  final bool darkHeader;

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
    this.darkHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final hasScore = match.hasFinalScore;
    final useDarkHeader = darkHeader && !match.isTraining;
    final heroTextColor = appColors.dirt;
    final collapse = MatchHeroCollapse.of(context);
    final badgeRadius = lerpDouble(23, 12, collapse)!;
    final badgePadding = lerpDouble(5, 2, collapse)!;
    final labelFontSize = lerpDouble(12, 11, collapse)!;
    final centerTextScale = lerpDouble(1, 0.72, collapse)!;

    final cardContent = KopaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: Spacing.borderRadiusLargeIncreased,
      color: useDarkHeader
          ? appColors.lightGrass
          : match.isTraining
              ? appColors.lightSky65
              : null,
      child: match.isTraining
          ? _TrainingHeroContent(
              match: match,
              title: l10n.eventTraining,
              collapse: collapse,
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: lerpDouble(12, 2, collapse)!,
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
                          radius: badgeRadius,
                          badgePadding: badgePadding,
                          labelMaxLines: 1,
                          labelStyle: appTextStyles.caption.copyWith(
                            color: heroTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: labelFontSize,
                          ),
                        ),
                      ),
                      if (hasScore)
                        _FinalScorePill(
                          match: match,
                          textColor: heroTextColor,
                          textScale: centerTextScale,
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.md,
                          ),
                          child: Text(
                            'VS',
                            style: appTextStyles.h5.copyWith(
                              color: heroTextColor,
                              fontWeight: FontWeight.w900,
                              fontSize:
                                  appTextStyles.h5.fontSize! * centerTextScale,
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
                          radius: badgeRadius,
                          badgePadding: badgePadding,
                          labelMaxLines: 1,
                          labelStyle: appTextStyles.caption.copyWith(
                            color: heroTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: labelFontSize,
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
  final double collapse;

  const _TrainingHeroContent({
    required this.match,
    required this.title,
    required this.collapse,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final circleSize = lerpDouble(52, 36, collapse)!;
    final details = [
      if (match.category?.trim().isNotEmpty ?? false) match.category!.trim(),
      '${DateHelper.getFormattedTime(match.date)} · ${match.location}',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: lerpDouble(8, 2, collapse)!,
      ),
      child: Row(
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: appColors.lightSky95,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              color: appColors.sky,
              size: circleSize * 0.54,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: appTextStyles.h5.copyWith(
                    color: appColors.dirt,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                // Only the title stays once the header is pinned.
                ClipRect(
                  child: Align(
                    alignment: Alignment.topLeft,
                    heightFactor: 1 - collapse,
                    child: Opacity(
                      opacity: 1 - collapse,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final detail in details) ...[
                            const SizedBox(height: 4),
                            Text(
                              detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: appTextStyles.body3.copyWith(
                                color: appColors.grey5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

class _FinalScorePill extends StatelessWidget {
  final MatchDetails match;
  final Color textColor;
  final double textScale;

  const _FinalScorePill({
    required this.match,
    required this.textColor,
    required this.textScale,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${match.homeTeamScore} - ${match.awayTeamScore}',
          style: appTextStyles.h3.copyWith(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: appTextStyles.h3.fontSize! * textScale,
          ),
        ),
      ],
    );
  }
}

enum TeamSide { home, away }
