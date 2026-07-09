import 'package:flutter/material.dart';
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
                  child: _TeamMark(
                    name: match.homeTeam ?? 'Hjemme',
                    teamId: _stableTeamSeed(match.homeTeam ?? 'Hjemme'),
                    heroTag: heroTag == null
                        ? null
                        : logoHeroTag(heroTag!, TeamSide.home),
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
                    heroTag: heroTag == null
                        ? null
                        : logoHeroTag(heroTag!, TeamSide.away),
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

class _TeamMark extends StatelessWidget {
  final String name;
  final int teamId;
  final String? heroTag;

  const _TeamMark({
    required this.name,
    required this.teamId,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final badge = Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appColors.white.withValues(alpha: 0.74),
        boxShadow: [
          BoxShadow(
            color: appColors.dirt.withValues(alpha: 0.16),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: appColors.dirt.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TeamAvatar(
        teamName: name,
        teamId: teamId,
        radius: 22,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoHero(tag: heroTag, child: badge),
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

class _LogoHero extends StatelessWidget {
  final String? tag;
  final Widget child;

  const _LogoHero({
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tag = this.tag;
    if (tag == null) return child;

    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      flightShuttleBuilder: (
        context,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final fromHero = fromHeroContext.widget as Hero;
        final toHero = toHeroContext.widget as Hero;

        return ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: flightDirection == HeroFlightDirection.push
              ? toHero.child
              : fromHero.child,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
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
