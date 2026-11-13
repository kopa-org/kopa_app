import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/card/player_plus_stat_tile.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/scaffold/tab_page_header.dart';
import 'package:kopa/component/season/season_selector.dart';
import 'package:kopa/component/section_header/section_header.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/statistics_cubit.dart';
import 'package:kopa/cubits/statistics_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/statistics/team_stats_card.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teamId = context.select(
      (AuthCubit cubit) => cubit.state.user?.teamDetails?.id,
    );

    return PageScaffold.tab(
      title: l10n.navStatistics,
      body: teamId == null
          ? Center(child: Text(l10n.uiNoTeamSelected))
          : BlocProvider(
              key: ValueKey('statistics-$teamId'),
              create: (_) => StatisticsCubit(teamId: teamId)..load(),
              child: const _StatisticsView(),
            ),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final stats = state.stats;
        final pastSeason =
            state.isViewingPastSeason ? state.selectedSeason : null;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.md,
            Spacing.lg + mainTabBottomContentPadding(context),
          ),
          children: [
            _StatisticsHeader(state: state),
            if (pastSeason != null) ...[
              const SizedBox(height: Spacing.itemGap),
              PastSeasonBanner(
                season: pastSeason,
                onBackToCurrent: () =>
                    context.read<StatisticsCubit>().showActiveSeason(),
              ),
            ],
            const SizedBox(height: Spacing.md),
            if (state.status == StatisticsStatus.failure)
              ErrorMessage(
                message: AppLocalizations.of(context)!
                    .uiSomethingWentWrongPleaseTryAgain,
              )
            else if (stats == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
                child: LoadingIndicator(),
              )
            else
              _StatisticsContent(stats: stats),
          ],
        );
      },
    );
  }
}

/// Page title with the season selector underneath, as on the match schedule.
class _StatisticsHeader extends StatelessWidget {
  final StatisticsState state;

  const _StatisticsHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final season = state.selectedSeason;

    return TabPageHeader(
      title: AppLocalizations.of(context)!.navStatistics,
      bottom: season == null
          ? null
          : SeasonSelectorButton(
              season: season,
              onTap:
                  state.seasons.length > 1 ? () => _pickSeason(context) : null,
            ),
    );
  }

  Future<void> _pickSeason(BuildContext context) async {
    final cubit = context.read<StatisticsCubit>();
    final picked = await showSeasonPicker(
      context,
      seasons: cubit.state.seasons,
      selected: cubit.state.selectedSeason,
    );
    if (picked != null) await cubit.selectSeason(picked);
  }
}

class _StatisticsContent extends StatelessWidget {
  final StatisticsResponse stats;

  const _StatisticsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = context.read<AuthCubit>().state.user?.id;
    final inFormIndex = stats.inFormRows.indexWhere(
      (row) => _isCurrentUser(row.userId, row.userName, currentUserId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InFormCallout(
          rank: inFormIndex == -1 ? null : inFormIndex + 1,
          points:
              inFormIndex == -1 ? null : stats.inFormRows[inFormIndex].total,
          onTap: () => context.push(AppRouter.playerPlusInForm),
        ),
        const SizedBox(height: Spacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: SectionHeader(title: l10n.uiYourStats),
        ),
        _PlayerStatTiles(stats: stats, currentUserId: currentUserId),
        const SizedBox(height: Spacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: SectionHeader(title: l10n.uiTeamStats),
        ),
        TeamStatsCard(stats: stats),
      ],
    );
  }

  bool _isCurrentUser(int userId, String userName, int? currentUserId) {
    if (currentUserId != null) return userId == currentUserId;
    return userName == stats.player.name;
  }
}

/// Shortcut to the In-form table, showing the player's own placing.
class _InFormCallout extends StatelessWidget {
  final int? rank;
  final double? points;
  final VoidCallback onTap;

  const _InFormCallout({
    required this.rank,
    required this.points,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final rank = this.rank;

    return KopaCard(
      key: const ValueKey('statistics-in-form-callout'),
      color: colors.lightGrass,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.grass,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_fire_department, color: colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.statisticsInFormTitle,
                  style: styles.subtitle1.copyWith(
                    color: colors.dirt,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (rank != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.uiYouAreNoWith(
                      rank,
                      '${inFormNumber(points ?? 0)} ${l10n.uiPointsLabel}',
                    ),
                    style: styles.body4.copyWith(
                      color: colors.dirt,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  l10n.uiSeeTheFormTableStreaksAnd,
                  style: styles.body4.copyWith(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Icon(CupertinoIcons.chevron_right, size: 18, color: colors.dirt),
        ],
      ),
    );
  }
}

/// The player's own numbers; each tile opens the team leaderboard for it.
class _PlayerStatTiles extends StatelessWidget {
  final StatisticsResponse stats;
  final int? currentUserId;

  const _PlayerStatTiles({required this.stats, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = AppLocalizations.of(context)!;
    final tiles = [
      _tile(
        title: l10n.matchTimelineGoal,
        value: '${stats.player.goalsScored}',
        rows: stats.leaderboards.topScorers,
        icon: Icons.sports_score,
        accent: colors.sky,
        background: colors.white,
      ),
      _tile(
        title: l10n.statisticsAssists,
        value: '${stats.player.assists}',
        rows: stats.leaderboards.assists,
        icon: Icons.handshake,
        accent: colors.success,
        background: colors.white,
      ),
      _tile(
        title: l10n.navMatches,
        value: '${stats.player.matchesPlayed}',
        rows: stats.leaderboards.matchesPlayed,
        icon: Icons.sports_soccer,
        accent: colors.sunset,
        background: colors.white,
      ),
      _tile(
        title: l10n.uiVotes,
        value: _ownValue(stats.leaderboards.mostVotes),
        rows: stats.leaderboards.mostVotes,
        icon: Icons.how_to_vote,
        accent: colors.dirt,
        background: colors.white,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Spacing.itemGap,
        crossAxisSpacing: Spacing.itemGap,
        mainAxisExtent:
            150 + (MediaQuery.textScalerOf(context).scale(100) - 100),
      ),
      itemBuilder: (context, index) => PlayerPlusStatTile(
        data: tiles[index],
        currentUserId: currentUserId,
      ),
    );
  }

  PlayerPlusStatTileData _tile({
    required String title,
    required String value,
    required List<LeaderboardRow> rows,
    required IconData icon,
    required Color accent,
    required Color background,
  }) {
    return PlayerPlusStatTileData(
      title: title,
      value: value,
      // Null lets the tile work out the rank from the rows.
      rank: null,
      rows: [
        for (final row in rows)
          PlayerPlusStatRankingRow(
            userId: row.userId,
            userName: row.userName,
            value: '${row.value}',
          ),
      ],
      icon: icon,
      accentColor: accent,
      backgroundColor: background,
    );
  }

  String _ownValue(List<LeaderboardRow> rows) {
    for (final row in rows) {
      final isCurrentUser = currentUserId != null
          ? row.userId == currentUserId
          : row.userName == stats.player.name;
      if (isCurrentUser) return '${row.value}';
    }
    return '-';
  }
}
