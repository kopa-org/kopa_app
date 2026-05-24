import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/page/statistics/player_stats_section.dart';
import 'package:kopa/page/statistics/club_stats_section.dart';
import 'package:kopa/page/statistics/player_plus_teaser_section.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final player = MockData.playerStats;
    final club = MockData.clubStats;

    return PageScaffold(
      title: 'Statistik',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PlayerStatsSection(player: player),
          ),
          SliverToBoxAdapter(
            child: ClubStatsSection(club: club),
          ),
          const SliverToBoxAdapter(
            child: PlayerPlusTeaserSection(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
