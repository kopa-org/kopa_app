import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/component/card/player_plus_stat_tile.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/statistics/club_stats_section.dart';
import 'package:kopa/repository/statistics_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int? _loadedTeamId;
  Future<_StatisticsPageData>? _statisticsFuture;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final teamId = user?.teamDetails?.id;

    if (teamId != null &&
        (_loadedTeamId != teamId || _statisticsFuture == null)) {
      _loadedTeamId = teamId;
      _statisticsFuture = _loadStatisticsPageData(teamId);
    }

    return PageScaffold.tab(
      title: 'Statistik',
      body: teamId == null
          ? const Center(child: Text('Ingen hold valgt.'))
          : FutureHandler<_StatisticsPageData>(
              future: _statisticsFuture!,
              onSuccess: (context, data) => _StatisticsView(
                stats: data.stats,
                currentUser: user,
                hasPlayerPlus: true,
              ),
            ),
    );
  }

  Future<_StatisticsPageData> _loadStatisticsPageData(int teamId) async {
    final stats = await StatisticsRepository.getStatistics(teamId);

    return _StatisticsPageData(
      stats: stats,
      hasPlayerPlus: false,
    );
  }
}

class _StatisticsPageData {
  final StatisticsResponse stats;
  final bool hasPlayerPlus;

  const _StatisticsPageData({
    required this.stats,
    required this.hasPlayerPlus,
  });
}

class _StatisticsView extends StatelessWidget {
  final StatisticsResponse stats;
  final UserDetails? currentUser;
  final bool hasPlayerPlus;

  const _StatisticsView({
    required this.stats,
    required this.currentUser,
    required this.hasPlayerPlus,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: _InFormCallout(
              onTap: () => context.push(AppRouter.playerPlusInForm),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _PlayerPlusStatsSection(
            stats: stats,
            currentUser: currentUser,
            hasPlayerPlus: hasPlayerPlus,
          ),
        ),
        SliverToBoxAdapter(child: ClubStatsSection(club: stats.club)),
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

class _InFormCallout extends StatelessWidget {
  final VoidCallback onTap;

  const _InFormCallout({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: colors.lightGrass,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.grass,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('In-form', style: styles.sectionHeader),
                    const SizedBox(height: 3),
                    Text(
                      'Se formranglisten, streaks og point.',
                      style: styles.caption,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: colors.grass),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerPlusStatsSection extends StatelessWidget {
  final StatisticsResponse stats;
  final UserDetails? currentUser;
  final bool hasPlayerPlus;

  const _PlayerPlusStatsSection({
    required this.stats,
    required this.currentUser,
    required this.hasPlayerPlus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final tiles = _buildTiles(appColors);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player+',
            style: styles.pageTitle.copyWith(color: appColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            hasPlayerPlus
                ? 'Dine tal og placeringer på holdets ranglister.'
                : 'Få Player+ for at låse alle placeringer op.',
            style: styles.body.copyWith(color: appColors.textSecondary),
          ),
          if (!hasPlayerPlus) ...[
            const SizedBox(height: 12),
            _PlayerPlusLockedCallout(
              onTap: () => context.push(AppRouter.playerPlus),
            ),
          ],
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.04,
            ),
            itemBuilder: (context, index) => _PlayerPlusStatTile(
              tile: tiles[index],
              currentUserId: currentUser?.id,
              locked: !hasPlayerPlus,
              obscureValue: !hasPlayerPlus && index >= tiles.length - 2,
            ),
          ),
        ],
      ),
    );
  }

  List<_PlayerPlusTileData> _buildTiles(AppColors appColors) {
    return [
      _leaderboardTile(
        title: 'Pointsnit',
        value: _currentLeaderboardValue(
          stats.leaderboards.bestPointsAverage,
          decimal: true,
        ),
        rows: stats.leaderboards.bestPointsAverage,
        icon: Icons.trending_up,
        accentColor: appColors.grass,
        decimal: true,
      ),
      _leaderboardTile(
        title: 'Mål',
        value: stats.player.goalsScored.toString(),
        rows: stats.leaderboards.topScorers,
        icon: Icons.sports_score,
        accentColor: appColors.sky,
      ),
      _leaderboardTile(
        title: 'Assists',
        value: stats.player.assists.toString(),
        rows: stats.leaderboards.assists,
        icon: Icons.handshake,
        accentColor: appColors.success,
      ),
      _leaderboardTile(
        title: 'Kampe',
        value: stats.player.matchesPlayed.toString(),
        rows: stats.leaderboards.matchesPlayed,
        icon: Icons.sports_soccer,
        accentColor: appColors.sunset,
      ),
      _leaderboardTile(
        title: 'Stemmer',
        value: _currentLeaderboardValue(stats.leaderboards.mostVotes),
        rows: stats.leaderboards.mostVotes,
        icon: Icons.how_to_vote,
        accentColor: appColors.dirt,
      ),
      _inFormTile(appColors),
    ];
  }

  _PlayerPlusTileData _leaderboardTile({
    required String title,
    required String value,
    required List<LeaderboardRow> rows,
    required IconData icon,
    required Color accentColor,
    bool decimal = false,
  }) {
    final rankingRows = rows
        .map(
          (row) => _StatRankingRow(
            userId: row.userId,
            userName: row.userName,
            value: decimal
                ? row.value.toDouble().toStringAsFixed(1)
                : '${row.value}',
          ),
        )
        .toList();

    return _PlayerPlusTileData(
      title: title,
      value: value,
      rows: rankingRows,
      icon: icon,
      accentColor: accentColor,
    );
  }

  _PlayerPlusTileData _inFormTile(AppColors appColors) {
    final rows = stats.inFormRows
        .map(
          (row) => _StatRankingRow(
            userId: row.userId,
            userName: row.userName,
            value: '${row.points}',
            suffix: 'point',
          ),
        )
        .toList();

    final currentRow = _findCurrentRow(rows);

    return _PlayerPlusTileData(
      title: 'In-form',
      value: currentRow?.value ?? '-',
      rows: rows,
      icon: Icons.local_fire_department,
      accentColor: appColors.error,
    );
  }

  String _currentLeaderboardValue(
    List<LeaderboardRow> rows, {
    bool decimal = false,
  }) {
    final currentRow = rows.cast<dynamic>().where((row) {
      if (currentUser != null && row.userId == currentUser!.id) {
        return true;
      }
      return row.userName == stats.player.name;
    }).firstOrNull;

    if (currentRow == null) {
      return '-';
    }

    return decimal
        ? currentRow.value.toDouble().toStringAsFixed(1)
        : '${currentRow.value}';
  }

  _StatRankingRow? _findCurrentRow(List<_StatRankingRow> rows) {
    return rows.where((row) {
      if (currentUser != null && row.userId == currentUser!.id) {
        return true;
      }
      return row.userName == stats.player.name;
    }).firstOrNull;
  }
}

class _PlayerPlusTileData {
  final String title;
  final String value;
  final List<_StatRankingRow> rows;
  final IconData icon;
  final Color accentColor;

  const _PlayerPlusTileData({
    required this.title,
    required this.value,
    required this.rows,
    required this.icon,
    required this.accentColor,
  });
}

class _StatRankingRow {
  final int userId;
  final String userName;
  final String value;
  final String? suffix;

  const _StatRankingRow({
    required this.userId,
    required this.userName,
    required this.value,
    this.suffix,
  });
}

class _PlayerPlusStatTile extends StatelessWidget {
  final _PlayerPlusTileData tile;
  final int? currentUserId;
  final bool locked;
  final bool obscureValue;

  const _PlayerPlusStatTile({
    required this.tile,
    required this.currentUserId,
    required this.locked,
    required this.obscureValue,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        tile.rows.indexWhere((row) => row.userId == currentUserId);
    final rank = currentIndex == -1 ? null : currentIndex + 1;
    final obscureRank = locked;

    return PlayerPlusStatTile(
      data: PlayerPlusStatTileData(
        title: tile.title,
        value: tile.value,
        rank: rank,
        rows: tile.rows
            .map(
              (row) => PlayerPlusStatRankingRow(
                userId: row.userId,
                userName: row.userName,
                value: row.value,
                suffix: row.suffix,
              ),
            )
            .toList(),
        icon: tile.icon,
        accentColor: tile.accentColor,
      ),
      obscureValue: obscureValue,
      obscureRank: obscureRank,
      onTap: locked ? null : () => _showLeaderboardSheet(context),
    );
  }

  void _showLeaderboardSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LeaderboardSheet(
        tile: tile,
        currentUserId: currentUserId,
        locked: locked,
      ),
    );
  }
}

class _LeaderboardSheet extends StatelessWidget {
  final _PlayerPlusTileData tile;
  final int? currentUserId;
  final bool locked;

  const _LeaderboardSheet({
    required this.tile,
    required this.currentUserId,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: appColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: appColors.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    Icon(tile.icon, color: tile.accentColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tile.title,
                        style: styles.sectionHeader.copyWith(
                          color: appColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tile.rows.isEmpty
                    ? Center(
                        child: Text('Ingen data endnu.', style: styles.body),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        itemCount: tile.rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final row = tile.rows[index];
                          final isCurrentUser = row.userId == currentUserId;
                          return _LeaderboardSheetRow(
                            rank: index + 1,
                            row: row,
                            isCurrentUser: isCurrentUser,
                            accentColor: tile.accentColor,
                            locked: locked,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardSheetRow extends StatelessWidget {
  final int rank;
  final _StatRankingRow row;
  final bool isCurrentUser;
  final Color accentColor;
  final bool locked;

  const _LeaderboardSheetRow({
    required this.rank,
    required this.row,
    required this.isCurrentUser,
    required this.accentColor,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final obscureFirstPlace = locked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? accentColor.withValues(alpha: 0.14)
            : appColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: BlurredValue(
              blurred: obscureFirstPlace,
              sigma: 3,
              child: Text(
                '$rank.',
                style: styles.bodyBold.copyWith(
                  color: isCurrentUser ? accentColor : appColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlurredValue(
              blurred: obscureFirstPlace,
              sigma: 4,
              child: Text(
                row.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.bodyBold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          BlurredValue(
            blurred: obscureFirstPlace,
            sigma: 4,
            child: Text(
              row.suffix == null ? row.value : '${row.value} ${row.suffix}',
              style: styles.bodyBold.copyWith(
                color: isCurrentUser ? accentColor : appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerPlusLockedCallout extends StatelessWidget {
  final VoidCallback onTap;

  const _PlayerPlusLockedCallout({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: appColors.lightGrass.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.workspace_premium, color: appColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nogle resultater er låst. Se Player+ for at låse hele ranglisten op.',
                  style: styles.caption.copyWith(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: appColors.primary, size: 18),
            ],
          ),
        ),
      ),
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
