import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/page/statistics/club_stats_section.dart';
import 'package:kopa/page/statistics/player_stats_section.dart';
import 'package:kopa/repository/statistics_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;

    return PageScaffold(
      title: 'Statistik',
      body: teamId == null
          ? const Center(child: Text('Ingen hold valgt.'))
          : FutureHandler<StatisticsResponse>(
              future: StatisticsRepository.getStatistics(teamId),
              onSuccess: (context, stats) => _StatisticsView(stats: stats),
            ),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  final StatisticsResponse stats;

  const _StatisticsView({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: PlayerStatsSection(player: stats.player)),
        SliverToBoxAdapter(child: ClubStatsSection(club: stats.club)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _SectionCard(
              title: 'In-form tabel',
              child: stats.inFormRows.isEmpty
                  ? Text('Ingen ratings registreret endnu.', style: styles.body)
                  : Column(
                      children: stats.inFormRows.asMap().entries.map((entry) {
                        final index = entry.key;
                        final row = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '${index + 1}',
                                  style: styles.bodyBold.copyWith(
                                    color: appColors.primary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child:
                                    Text(row.userName, style: styles.bodyBold),
                              ),
                              Text('${row.points} point', style: styles.body),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _SectionCard(
              title: 'Lister med statistikker',
              child: Column(
                children: [
                  _LeaderboardGroup(
                    title: 'Topscorerliste',
                    rows: stats.leaderboards.topScorers,
                  ),
                  const SizedBox(height: 16),
                  _LeaderboardGroup(
                    title: 'Assistliste',
                    rows: stats.leaderboards.assists,
                  ),
                  const SizedBox(height: 16),
                  _LeaderboardGroup(
                    title: 'Kampe spillet',
                    rows: stats.leaderboards.matchesPlayed,
                  ),
                  const SizedBox(height: 16),
                  _LeaderboardGroup(
                    title: 'Flest stemmer',
                    rows: stats.leaderboards.mostVotes,
                  ),
                  const SizedBox(height: 16),
                  _LeaderboardGroup(
                    title: 'Bedste pointsnit',
                    rows: stats.leaderboards.bestPointsAverage,
                    decimal: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: _SectionCard(
              title: 'Holdets nøgletal',
              child: Column(
                children: [
                  _MetricRow(
                    label: 'Holdets pointsnit',
                    value: stats.teamMetrics.teamAveragePoints
                            ?.toStringAsFixed(1) ??
                        '-',
                  ),
                  const SizedBox(height: 12),
                  _MetricRow(
                    label: 'Holdets form',
                    value: stats.teamMetrics.teamForm.isEmpty
                        ? '-'
                        : stats.teamMetrics.teamForm
                            .map((result) => result == 1
                                ? 'V'
                                : result == 0
                                    ? 'U'
                                    : 'T')
                            .join(' · '),
                  ),
                  const SizedBox(height: 12),
                  _MetricRow(
                    label: 'Mål scoret',
                    value: '${stats.teamMetrics.goalsScored}',
                  ),
                  const SizedBox(height: 12),
                  _MetricRow(
                    label: 'Mål lukket ind',
                    value: '${stats.teamMetrics.goalsConceded}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: styles.sectionHeader),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LeaderboardGroup extends StatelessWidget {
  final String title;
  final List<LeaderboardRow> rows;
  final bool decimal;

  const _LeaderboardGroup({
    required this.title,
    required this.rows,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: styles.bodyBold),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          Text('Ingen data endnu.', style: styles.body)
        else
          ...rows.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final value = decimal
                ? row.value.toDouble().toStringAsFixed(1)
                : '${row.value}';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                      width: 28,
                      child: Text('${index + 1}', style: styles.caption)),
                  Expanded(child: Text(row.userName, style: styles.body)),
                  Text(value, style: styles.bodyBold),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: styles.body)),
        Text(value, style: styles.bodyBold),
      ],
    );
  }
}
