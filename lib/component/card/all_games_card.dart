import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class AllGamesCard extends StatelessWidget {
  final List<MatchDetails> matches;
  final ValueChanged<MatchDetails> onMatchTap;
  final Map<int, GlobalKey>? matchItemKeys;
  final String? ownTeamName;

  const AllGamesCard({
    required this.matches,
    required this.onMatchTap,
    this.matchItemKeys,
    this.ownTeamName,
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
    );
  }
}

class _MatchList extends StatelessWidget {
  final List<MatchDetails> matches;
  final ValueChanged<MatchDetails> onMatchTap;
  final Map<int, GlobalKey>? matchItemKeys;
  final String? ownTeamName;

  const _MatchList({
    required this.matches,
    required this.onMatchTap,
    this.matchItemKeys,
    this.ownTeamName,
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

  const _GameResultRow({
    required this.match,
    required this.onTap,
    required this.ownTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final ownSide = _OwnTeamSide.from(match, ownTeamName);
    final status = _MatchStatus.from(match, appColors, ownSide);
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
                                DateFormat('EEE d. MMM', 'da_DK')
                                    .format(match.date)
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
                              const _SignupBadge(),
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
                        ),
                        const SizedBox(height: Spacing.sm),
                        _GameTeamLine(
                          name: match.awayTeam ?? 'Ude',
                          score: match.awayTeamScore,
                          isOwnTeam: ownSide.isAway,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appColors.lightGrass55,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 17,
                      color: appColors.grass,
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
}

class _SignupBadge extends StatelessWidget {
  const _SignupBadge();

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.lightGrass55,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.check_mark,
            size: 10,
            color: appColors.grass,
          ),
          const SizedBox(width: 4),
          Text(
            'Tilmeldt',
            style: appTextStyles.buttonTiny.copyWith(
              color: appColors.grass,
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
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Text(
        status.label,
        style: appTextStyles.buttonTiny.copyWith(
          color: status.foregroundColor,
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

  const _GameTeamLine({
    required this.name,
    required this.score,
    required this.isOwnTeam,
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
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _MatchStatus({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
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

    final teamScore =
        ownSide.isAway ? match.awayTeamScore! : match.homeTeamScore!;
    final opponentScore =
        ownSide.isAway ? match.homeTeamScore! : match.awayTeamScore!;

    if (teamScore == opponentScore) {
      return _MatchStatus(
        label: 'UAFGJORT',
        backgroundColor: colors.sunset,
        foregroundColor: colors.offWhite,
      );
    }

    final isWin = teamScore > opponentScore;
    return _MatchStatus(
      label: isWin ? 'SEJR' : 'TABT',
      backgroundColor: isWin ? colors.success : colors.error,
      foregroundColor: isWin ? colors.dirt : colors.offWhite,
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
