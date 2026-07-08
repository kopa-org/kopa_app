import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
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
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final sortedMatches = [...matches]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.grey2,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Serie 1',
              style: appTextStyles.caption3.copyWith(color: appColors.grey3),
            ),
          ),
          const SizedBox(height: Spacing.md),
          if (sortedMatches.isEmpty)
            Text('Ingen kampe endnu', style: appTextStyles.body3)
          else
            ...sortedMatches.indexed.expand((entry) sync* {
              final index = entry.$1;
              final match = entry.$2;
              yield _GameResultRow(
                match: match,
                onTap: () => onMatchTap(match),
              );
              if (index != sortedMatches.length - 1) {
                yield const SizedBox(height: Spacing.md);
              }
            }),
        ],
      ),
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
    final homeScore = match.homeTeamScore;
    final awayScore = match.awayTeamScore;
    final homeScoreValue = homeScore ?? 0;
    final awayScoreValue = awayScore ?? 0;
    final result = homeScoreValue == awayScoreValue
        ? 'UAFGJORT'
        : homeScoreValue > awayScoreValue
            ? 'SEJR'
            : 'TABT';
    final resultColor = result == 'SEJR'
        ? appColors.success
        : result == 'TABT'
            ? appColors.error
            : appColors.sunset;
    final resultTextColor =
        result == 'SEJR' ? appColors.lightGrass : appColors.offWhite;

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE dd.MM', 'da_DK').format(match.date),
            style: appTextStyles.caption3.copyWith(color: appColors.grey5),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                child: match.hasMatchBeenPlayed
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: resultColor,
                            borderRadius:
                                BorderRadius.circular(Spacing.borderRadiusFull),
                          ),
                          child: Text(
                            result,
                            style: appTextStyles.label
                                .copyWith(color: resultTextColor),
                          ),
                        ),
                      )
                    : Text(
                        DateHelper.getFormattedTime(match.date),
                        style: appTextStyles.buttonSmall
                            .copyWith(color: appColors.grey5),
                      ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GameTeamLine(
                      name: match.homeTeam ?? 'Hjemme',
                      score: homeScore,
                    ),
                    const SizedBox(height: 6),
                    _GameTeamLine(
                      name: match.awayTeam ?? 'Ude',
                      score: awayScore,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameTeamLine extends StatelessWidget {
  final String name;
  final int? score;

  const _GameTeamLine({required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Row(
      children: [
        AppAvatar(initials: _initials(name), radius: 10),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            name,
            style: appTextStyles.caption1.copyWith(color: appColors.dirt),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: appTextStyles.caption1.copyWith(color: appColors.dirt),
          ),
      ],
    );
  }
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  return words
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0].toUpperCase())
      .join();
}
