import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_avatar.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

int stableTeamSeed(String name) {
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

bool teamNamesMatch(String first, String second) {
  return first.trim().toLowerCase() == second.trim().toLowerCase();
}

enum TeamBadgeLabelLayout { vertical, horizontal }

class TeamBadgeLabel extends StatelessWidget {
  final String teamName;
  final int teamId;
  final String? colorSourceUrl;
  final TeamLogoDesign? logoDesign;
  final double radius;
  final double badgePadding;
  final double? width;
  final TextStyle? labelStyle;
  final int labelMaxLines;
  final String? heroTag;
  final bool isHighlighted;
  final bool showAvatar;
  final bool showShadow;
  final TeamBadgeLabelLayout layout;

  const TeamBadgeLabel({
    super.key,
    required this.teamName,
    required this.teamId,
    this.colorSourceUrl,
    this.logoDesign,
    this.radius = 22,
    this.badgePadding = 5,
    this.width,
    this.labelStyle,
    this.labelMaxLines = 1,
    this.heroTag,
    this.isHighlighted = false,
    this.showAvatar = true,
    this.showShadow = true,
    this.layout = TeamBadgeLabelLayout.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final effectiveLabelStyle = labelStyle ??
        appTextStyles.caption.copyWith(
          color: isHighlighted ? appColors.primary : appColors.dirt,
          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
        );
    final logoShape = logoDesign?.shape ?? TeamLogoShape.circle;

    final badge = showAvatar
        ? _TeamBadgeHero(
            tag: heroTag,
            child: _TeamBadgeShell(
              padding: badgePadding,
              showShadow: showShadow,
              shape: logoShape,
              child: TeamAvatar(
                teamName: teamName,
                teamId: teamId,
                colorSourceUrl: colorSourceUrl,
                logoDesign: logoDesign,
                radius: radius,
              ),
            ),
          )
        : const SizedBox.shrink();

    final label = Text(
      teamName,
      maxLines: labelMaxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: layout == TeamBadgeLabelLayout.vertical
          ? TextAlign.center
          : TextAlign.start,
      style: effectiveLabelStyle,
    );

    final content = switch (layout) {
      TeamBadgeLabelLayout.vertical => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAvatar) badge,
            if (showAvatar) const SizedBox(height: Spacing.xs),
            label,
          ],
        ),
      TeamBadgeLabelLayout.horizontal => Row(
          children: [
            if (showAvatar) badge,
            if (showAvatar) const SizedBox(width: Spacing.sm),
            Expanded(child: label),
          ],
        ),
    };

    if (width == null) return content;
    return SizedBox(width: width, child: content);
  }
}

class _TeamBadgeShell extends StatelessWidget {
  final double padding;
  final bool showShadow;
  final TeamLogoShape shape;
  final Widget child;

  const _TeamBadgeShell({
    required this.padding,
    required this.showShadow,
    required this.shape,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: EdgeInsets.all(padding),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: TeamLogoShapeBorder(shape),
        color: appColors.white.withValues(alpha: 0.74),
        shadows: showShadow
            ? [
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
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _TeamBadgeHero extends StatelessWidget {
  final String? tag;
  final Widget child;

  const _TeamBadgeHero({
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

        return RepaintBoundary(
          child: flightDirection == HeroFlightDirection.push
              ? toHero.child
              : fromHero.child,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(child: child),
      ),
    );
  }
}
