import 'package:flutter/material.dart';
import 'package:kopa/component/card/player_plus_stat_tile.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class HomeStatisticsStrip extends StatelessWidget {
  final StatisticsResponse? stats;
  final UserDetails currentUser;

  const HomeStatisticsStrip({
    super.key,
    required this.stats,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final stats = this.stats;

    if (stats == null) {
      return HomeBentoCard(
        color: appColors.grey2,
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          'Ingen statistik tilgængelig',
          style: appTextStyles.caption1.copyWith(color: appColors.grey5),
        ),
      );
    }

    final tiles = [
      PlayerPlusStatTileData(
        title: 'Pointsnit',
        backgroundColor: appColors.lightGrass.withValues(alpha: 0.27),
        value: _currentLeaderboardValue(
          stats.leaderboards.bestPointsAverage,
          decimal: true,
        ),
        rank: _rankFor(stats.leaderboards.bestPointsAverage),
        rows: _leaderboardRows(
          stats.leaderboards.bestPointsAverage,
          decimal: true,
        ),
        icon: Icons.trending_up,
        accentColor: appColors.grass,
      ),
      PlayerPlusStatTileData(
        title: 'Mål',
        backgroundColor: appColors.lightSky.withValues(alpha: 0.27),
        value: stats.player.goalsScored.toString(),
        rank: _rankFor(stats.leaderboards.topScorers),
        rows: _leaderboardRows(stats.leaderboards.topScorers),
        icon: Icons.sports_score,
        accentColor: appColors.sky,
      ),
      PlayerPlusStatTileData(
        title: 'Assists',
        backgroundColor: appColors.lightGrass.withValues(alpha: 0.27),
        value: stats.player.assists.toString(),
        rank: _rankFor(stats.leaderboards.assists),
        rows: _leaderboardRows(stats.leaderboards.assists),
        icon: Icons.handshake,
        accentColor: appColors.success,
      ),
      PlayerPlusStatTileData(
        title: 'Kampe',
        backgroundColor: appColors.sunset.withValues(alpha: 0.27),
        value: stats.player.matchesPlayed.toString(),
        rank: _rankFor(stats.leaderboards.matchesPlayed),
        rows: _leaderboardRows(stats.leaderboards.matchesPlayed),
        icon: Icons.sports_soccer,
        accentColor: appColors.sunset,
      ),
      PlayerPlusStatTileData(
        title: 'Stemmer',
        backgroundColor: appColors.dirt.withValues(alpha: 0.27),
        value: _currentLeaderboardValue(stats.leaderboards.mostVotes),
        rank: _rankFor(stats.leaderboards.mostVotes),
        rows: _leaderboardRows(stats.leaderboards.mostVotes),
        icon: Icons.how_to_vote,
        accentColor: appColors.dirt,
      ),
      PlayerPlusStatTileData(
        backgroundColor: appColors.error.withValues(alpha: 0.27),
        title: 'In-form',
        value: _currentInFormValue(),
        rank: _rankForInForm(),
        rows: _inFormRows(),
        icon: Icons.local_fire_department,
        accentColor: appColors.error,
      ),
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: PlayerPlusAccess.temporaryUnlocked,
      builder: (context, hasPlayerPlus, _) => SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: tiles.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: Spacing.md),
          itemBuilder: (context, index) => PlayerPlusStatTile(
            data: tiles[index],
            currentUserId: currentUser.id,
            locked: !hasPlayerPlus,
            width: 156,
            padding: const EdgeInsets.all(12),
            valueFontSize: 28,
            titleFontSize: 14,
            rankFontSize: 11,
            obscureValue: hasPlayerPlus,
            obscureRank: !hasPlayerPlus,
            showShadow: true,
          ),
        ),
      ),
    );
  }

  List<PlayerPlusStatRankingRow> _leaderboardRows(
    List<LeaderboardRow> rows, {
    bool decimal = false,
  }) {
    return rows
        .map(
          (row) => PlayerPlusStatRankingRow(
            userId: row.userId,
            userName: row.userName,
            value: decimal
                ? row.value.toDouble().toStringAsFixed(1)
                : '${row.value}',
          ),
        )
        .toList();
  }

  List<PlayerPlusStatRankingRow> _inFormRows() {
    final stats = this.stats;
    if (stats == null) return const [];

    return stats.inFormRows
        .map(
          (row) => PlayerPlusStatRankingRow(
            userId: row.userId,
            userName: row.userName,
            value: '${row.points}',
            suffix: 'point',
          ),
        )
        .toList();
  }

  String _currentLeaderboardValue(
    List<LeaderboardRow> rows, {
    bool decimal = false,
  }) {
    final row = _currentLeaderboardRow(rows);
    if (row == null) return '-';
    return decimal ? row.value.toDouble().toStringAsFixed(1) : '${row.value}';
  }

  LeaderboardRow? _currentLeaderboardRow(List<LeaderboardRow> rows) {
    final stats = this.stats;
    if (stats == null) return null;

    for (final row in rows) {
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return row;
      }
    }
    return null;
  }

  int? _rankFor(List<LeaderboardRow> rows) {
    final stats = this.stats;
    if (stats == null) return null;

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return i + 1;
      }
    }
    return null;
  }

  String _currentInFormValue() {
    final stats = this.stats;
    if (stats == null) return '-';

    for (final row in stats.inFormRows) {
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return '${row.points}';
      }
    }
    return '-';
  }

  int? _rankForInForm() {
    final stats = this.stats;
    if (stats == null) return null;

    for (var i = 0; i < stats.inFormRows.length; i++) {
      final row = stats.inFormRows[i];
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return i + 1;
      }
    }
    return null;
  }
}
