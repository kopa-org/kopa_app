import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/chip/match_result_badge.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Form, results, goals and rating average for the team in one card.
class TeamStatsCard extends StatelessWidget {
  final StatisticsResponse stats;

  const TeamStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final club = stats.club;
    // The API lists the newest match first; show it on the right.
    final form = club.lastFiveMatchesForm.reversed
        .map(MatchResultStatus.fromForm)
        .toList(growable: false);
    final goalDifference = club.goalsFor - club.goalsAgainst;
    final average = stats.teamMetrics.teamAveragePoints;

    return KopaCard(
      key: const ValueKey('statistics-team-card'),
      color: colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.statisticsFormTitle,
                style: styles.bodyBold.copyWith(color: colors.dirt),
              ),
              const Spacer(),
              if (form.isNotEmpty)
                Text(
                  l10n.statisticsFormHint(form.length),
                  style: styles.caption.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (form.isEmpty)
            Text(
              l10n.statisticsNoFormYet,
              style: styles.body4.copyWith(color: colors.textSecondary),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final result in form)
                  ResultLetterBadge(result: result, size: 40),
              ],
            ),
          const _CardDivider(),
          Row(
            children: [
              for (final (index, (value, label)) in [
                (
                  club.wins + club.draws + club.losses,
                  l10n.matchSeasonSummaryMatches
                ),
                (club.wins, l10n.matchSeasonSummaryWon),
                (club.draws, l10n.matchSeasonSummaryDrawn),
                (club.losses, l10n.matchSeasonSummaryLost),
              ].indexed) ...[
                if (index > 0) const SizedBox(width: Spacing.sm),
                Expanded(child: _TotalTile(value: '$value', label: label)),
              ],
            ],
          ),
          const _CardDivider(),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  label: l10n.uiGoalsScored,
                  value: '${club.goalsFor}',
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _Figure(
                  label: l10n.uiGoalsConceded,
                  value: '${club.goalsAgainst}',
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _Figure(
                  label: l10n.uiGoalDifference,
                  value: goalDifference > 0
                      ? '+$goalDifference'
                      : '$goalDifference',
                  color: goalDifference > 0
                      ? colors.successForeground
                      : goalDifference < 0
                          ? colors.errorForeground
                          : colors.dirt,
                ),
              ),
            ],
          ),
          const _CardDivider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.uiTeamPointsAverage,
                  style: styles.body4.copyWith(color: colors.dirt),
                ),
              ),
              Text(
                average == null
                    ? '-'
                    : NumberFormat('0.0', l10n.localeName).format(average),
                style: styles.subtitle2.copyWith(
                  color: colors.dirt,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Container(height: 1, color: colors.offWhite),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String value;
  final String label;

  const _TotalTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: colors.offWhite,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: styles.subtitle1.copyWith(
              color: colors.dirt,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.buttonTiny.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Figure({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          style: styles.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: styles.subtitle1.copyWith(
            color: color ?? colors.dirt,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
