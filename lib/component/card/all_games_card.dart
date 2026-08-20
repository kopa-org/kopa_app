import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/chip/match_result_badge.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class AllGamesCard extends StatelessWidget {
  final List<MatchDetails> matches;
  final ValueChanged<MatchDetails> onMatchTap;
  final Map<int, GlobalKey>? matchItemKeys;
  final String? ownTeamName;
  final TeamLogoDesign? ownTeamLogoDesign;
  final int? currentUserId;

  const AllGamesCard({
    required this.matches,
    required this.onMatchTap,
    this.matchItemKeys,
    this.ownTeamName,
    this.ownTeamLogoDesign,
    this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMatches = matches.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final resolvedOwnTeamName = _inferOwnTeamName(sortedMatches, ownTeamName);

    return _MatchList(
      matches: sortedMatches,
      onMatchTap: onMatchTap,
      matchItemKeys: matchItemKeys,
      ownTeamName: resolvedOwnTeamName,
      ownTeamLogoDesign: ownTeamLogoDesign,
      currentUserId: currentUserId,
    );
  }
}

class _MatchList extends StatelessWidget {
  final List<MatchDetails> matches;
  final ValueChanged<MatchDetails> onMatchTap;
  final Map<int, GlobalKey>? matchItemKeys;
  final String? ownTeamName;
  final TeamLogoDesign? ownTeamLogoDesign;
  final int? currentUserId;

  const _MatchList({
    required this.matches,
    required this.onMatchTap,
    this.matchItemKeys,
    this.ownTeamName,
    this.ownTeamLogoDesign,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: matches.indexed.expand((entry) sync* {
        final row = _GameResultRow(
          match: entry.$2,
          onTap: () => onMatchTap(entry.$2),
          ownTeamName: ownTeamName,
          ownTeamLogoDesign: ownTeamLogoDesign,
          currentUserId: currentUserId,
        );
        final itemKey = matchItemKeys?[entry.$2.id];

        yield itemKey == null ? row : KeyedSubtree(key: itemKey, child: row);
        if (entry.$1 != matches.length - 1) {
          yield const SizedBox(height: Spacing.sm);
        }
      }).toList(),
    );
  }
}

class _GameResultRow extends StatelessWidget {
  final MatchDetails match;
  final VoidCallback onTap;
  final String? ownTeamName;
  final TeamLogoDesign? ownTeamLogoDesign;
  final int? currentUserId;

  const _GameResultRow({
    required this.match,
    required this.onTap,
    required this.ownTeamName,
    required this.ownTeamLogoDesign,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final ownSide = _OwnTeamSide.from(match, ownTeamName);
    final status = _MatchStatus.from(match, appColors, ownSide);
    final currentUserDeclined = _currentUserDeclined(match, currentUserId);
    final borderRadius = BorderRadius.circular(Spacing.borderRadiusSmall);

    return Semantics(
      key: ValueKey('match-entry-${match.id}'),
      button: true,
      label: 'Åbn kamp: ${match.matchName}',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: appColors.white,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: appColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              size: 14,
                              color: appColors.grey5,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                DateHelper.getFormattedShortWeekdayDate(
                                        match.date)
                                    .toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: appTextStyles.buttonTiny.copyWith(
                                  color: appColors.grey5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (match.isCurrentUserRegistered) ...[
                              const SizedBox(width: 6),
                              const _AttendanceBadge.registered(),
                            ] else if (currentUserDeclined) ...[
                              const SizedBox(width: 6),
                              const _AttendanceBadge.declined(),
                            ],
                            const SizedBox(width: 6),
                            _StatusBadge(status: status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GameTeamLine(
                          name: match.homeTeam ?? 'Hjemme',
                          score: match.homeTeamScore,
                          isOwnTeam: ownSide.isHome,
                          ownTeamLogoDesign: ownTeamLogoDesign,
                        ),
                        const SizedBox(height: Spacing.sm),
                        _GameTeamLine(
                          name: match.awayTeam ?? 'Ude',
                          score: match.awayTeamScore,
                          isOwnTeam: ownSide.isAway,
                          ownTeamLogoDesign: ownTeamLogoDesign,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 17,
                      color: appColors.dirt,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _currentUserDeclined(MatchDetails match, int? currentUserId) {
    if (currentUserId == null) return false;

    return (match.attendanceDetailsList ?? []).any(
      (attendance) =>
          attendance.userDetails.id == currentUserId && !attendance.isAttending,
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color Function(AppColors colors) foregroundColor;
  final Color Function(AppColors colors) backgroundColor;

  const _AttendanceBadge.registered()
      : label = 'Tilmeldt',
        icon = CupertinoIcons.check_mark,
        foregroundColor = _registeredForegroundColor,
        backgroundColor = _registeredBackgroundColor;

  const _AttendanceBadge.declined()
      : label = 'Frameldt',
        icon = CupertinoIcons.xmark,
        foregroundColor = _declinedForegroundColor,
        backgroundColor = _declinedBackgroundColor;

  static Color _registeredForegroundColor(AppColors colors) => colors.grass;
  static Color _registeredBackgroundColor(AppColors colors) =>
      colors.lightGrass55;
  static Color _declinedForegroundColor(AppColors colors) => colors.error;
  static Color _declinedBackgroundColor(AppColors colors) =>
      colors.error.withValues(alpha: 0.10);

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor(appColors),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: foregroundColor(appColors),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: appTextStyles.buttonTiny.copyWith(
              color: foregroundColor(appColors),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _MatchStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final result = status.result;
    if (result != null) {
      return MatchResultBadge(result: result);
    }

    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor!,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Text(
        status.label!,
        style: appTextStyles.buttonTiny.copyWith(
          color: status.foregroundColor!,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GameTeamLine extends StatelessWidget {
  final String name;
  final int? score;
  final bool isOwnTeam;
  final TeamLogoDesign? ownTeamLogoDesign;

  const _GameTeamLine({
    required this.name,
    required this.score,
    required this.isOwnTeam,
    this.ownTeamLogoDesign,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Row(
      children: [
        Expanded(
          child: TeamBadgeLabel(
            teamName: name,
            teamId: stableTeamSeed(name),
            logoDesign: isOwnTeam ? ownTeamLogoDesign : null,
            radius: 10,
            badgePadding: 2,
            isHighlighted: isOwnTeam,
            labelStyle: appTextStyles.body4.copyWith(
              color: isOwnTeam ? appColors.dirt : appColors.grey5,
              fontWeight: isOwnTeam ? FontWeight.w900 : FontWeight.w600,
            ),
            layout: TeamBadgeLabelLayout.horizontal,
          ),
        ),
        if (score != null) ...[
          const SizedBox(width: Spacing.sm),
          SizedBox(
            width: 24,
            child: Text(
              '$score',
              textAlign: TextAlign.end,
              style: appTextStyles.subtitle2.copyWith(
                color: appColors.dirt,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MatchStatus {
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final MatchResultStatus? result;

  const _MatchStatus({
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.result,
  });

  factory _MatchStatus.from(
    MatchDetails match,
    AppColors colors,
    _OwnTeamSide ownSide,
  ) {
    if (!match.hasMatchBeenPlayed) {
      return _MatchStatus(
        label: DateHelper.getFormattedTime(match.date),
        backgroundColor: colors.lightSky55,
        foregroundColor: colors.sky,
      );
    }

    if (!match.hasFinalScore) {
      return _MatchStatus(
        label: 'FÆRDIG',
        backgroundColor: colors.lightGrass,
        foregroundColor: colors.primary,
      );
    }

    final teamScore =
        ownSide.isAway ? match.awayTeamScore! : match.homeTeamScore!;
    final opponentScore =
        ownSide.isAway ? match.homeTeamScore! : match.awayTeamScore!;

    if (teamScore == opponentScore) {
      return const _MatchStatus(result: MatchResultStatus.draw);
    }

    return _MatchStatus(
      result: MatchResultStatus.fromScores(
        teamScore: teamScore,
        opponentScore: opponentScore,
      ),
    );
  }
}

enum _OwnTeamSide {
  home,
  away;

  bool get isHome => this == _OwnTeamSide.home;
  bool get isAway => this == _OwnTeamSide.away;

  factory _OwnTeamSide.from(MatchDetails match, String? ownTeamName) {
    final normalizedOwnTeamName = _normalizeTeamName(ownTeamName);
    if (normalizedOwnTeamName != null) {
      if (_normalizeTeamName(match.homeTeam) == normalizedOwnTeamName) {
        return _OwnTeamSide.home;
      }
      if (_normalizeTeamName(match.awayTeam) == normalizedOwnTeamName) {
        return _OwnTeamSide.away;
      }
    }

    return match.isHomeTeam == false ? _OwnTeamSide.away : _OwnTeamSide.home;
  }
}

String? _normalizeTeamName(String? value) {
  final normalized = value?.trim().toLowerCase();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? _inferOwnTeamName(List<MatchDetails> matches, String? fallbackName) {
  if (matches.length < 2) {
    return fallbackName;
  }

  final appearancesByTeam = <String, ({String displayName, int count})>{};

  for (final match in matches) {
    final namesInMatch = <String, String>{};
    for (final name in [match.homeTeam, match.awayTeam]) {
      final normalized = _normalizeTeamName(name);
      if (normalized != null) {
        namesInMatch[normalized] = name!.trim();
      }
    }

    for (final entry in namesInMatch.entries) {
      final previous = appearancesByTeam[entry.key];
      appearancesByTeam[entry.key] = (
        displayName: previous?.displayName ?? entry.value,
        count: (previous?.count ?? 0) + 1,
      );
    }
  }

  final commonTeams = appearancesByTeam.values
      .where((team) => team.count == matches.length)
      .toList(growable: false);

  if (commonTeams.length == 1) {
    return commonTeams.single.displayName;
  }

  return fallbackName;
}
