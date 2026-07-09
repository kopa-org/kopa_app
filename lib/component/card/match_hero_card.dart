import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/team_avatar.dart';
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

    final dateLabel =
        DateFormat('EEE d. MMM', 'da_DK').format(match.date).toUpperCase();

    final card = KopaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: appColors.grass,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.label.copyWith(
                      color: appColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  flex: 2,
                  child: Text(
                    match.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.label.copyWith(
                      color: appColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _TeamMark(
                    name: match.homeTeam ?? 'Hjemme',
                    teamId: _stableTeamSeed(match.homeTeam ?? 'Hjemme'),
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
                  child: _TeamMark(
                    name: match.awayTeam ?? 'Ude',
                    teamId: _stableTeamSeed(match.awayTeam ?? 'Ude'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!animateCard) return card;

    return Hero(
      tag: heroTag ?? defaultHeroTag(match.id),
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
}

class _TeamMark extends StatelessWidget {
  final String name;
  final int teamId;

  const _TeamMark({
    required this.name,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: 0.72,
          child: TeamAvatar(
            teamName: name,
            teamId: teamId,
            radius: 28,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: appTextStyles.caption.copyWith(
            color: appColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

int _stableTeamSeed(String name) {
  var hash = 0;
  for (final codeUnit in name.codeUnits) {
    hash = 0x1fffffff & (hash + codeUnit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= hash >> 11;
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
