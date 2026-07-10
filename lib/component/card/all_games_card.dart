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

  const AllGamesCard({
    required this.matches,
    required this.onMatchTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingMatches = matches
        .where((match) => !match.hasMatchBeenPlayed)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final completedMatches = matches
        .where((match) => match.hasMatchBeenPlayed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (upcomingMatches.isNotEmpty)
          _MatchSection(
            title: 'Kommende kampe',
            matches: upcomingMatches,
            onMatchTap: onMatchTap,
          ),
        if (upcomingMatches.isNotEmpty && completedMatches.isNotEmpty)
          const SizedBox(height: Spacing.lg),
        if (completedMatches.isNotEmpty)
          _MatchSection(
            title: 'Tidligere kampe',
            matches: completedMatches,
            onMatchTap: onMatchTap,
          ),
      ],
    );
  }
}

class _MatchSection extends StatelessWidget {
  final String title;
  final List<MatchDetails> matches;
  final ValueChanged<MatchDetails> onMatchTap;

  const _MatchSection({
    required this.title,
    required this.matches,
    required this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: appTextStyles.subtitle2.copyWith(
                  color: appColors.dirt,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 24),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: appColors.grey2,
                borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
              ),
              child: Text(
                '${matches.length}',
                textAlign: TextAlign.center,
                style: appTextStyles.buttonTiny.copyWith(
                  color: appColors.grass,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        ...matches.indexed.expand((entry) sync* {
          yield _GameResultRow(
            match: entry.$2,
            onTap: () => onMatchTap(entry.$2),
          );
          if (entry.$1 != matches.length - 1) {
            yield const SizedBox(height: Spacing.sm);
          }
        }),
      ],
    );
  }
}

class _GameResultRow extends StatelessWidget {
  final MatchDetails match;
  final VoidCallback onTap;

  const _GameResultRow({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final status = _MatchStatus.from(match, appColors);
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
            border: Border.all(
              color: appColors.grey3.withValues(alpha: 0.62),
            ),
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
                            _StatusBadge(status: status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GameTeamLine(
                          name: match.homeTeam ?? 'Hjemme',
                          score: match.homeTeamScore,
                        ),
                        const SizedBox(height: Spacing.sm),
                        _GameTeamLine(
                          name: match.awayTeam ?? 'Ude',
                          score: match.awayTeamScore,
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

  const _GameTeamLine({
    required this.name,
    required this.score,
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
            labelStyle: appTextStyles.body4.copyWith(
              color: appColors.dirt,
              fontWeight: FontWeight.w700,
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

  factory _MatchStatus.from(MatchDetails match, AppColors colors) {
    if (!match.hasMatchBeenPlayed) {
      return _MatchStatus(
        label: DateHelper.getFormattedTime(match.date),
        backgroundColor: colors.lightSky55,
        foregroundColor: colors.sky,
      );
    }

    final isHomeTeam = match.isHomeTeam != false;
    final teamScore = isHomeTeam ? match.homeTeamScore! : match.awayTeamScore!;
    final opponentScore =
        isHomeTeam ? match.awayTeamScore! : match.homeTeamScore!;

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
