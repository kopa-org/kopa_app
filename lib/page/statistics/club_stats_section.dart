import 'package:flutter/material.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/page/statistics/widgets/stat_card.dart';
import 'package:kopa/page/statistics/widgets/mini_stat_card.dart';
import 'package:kopa/page/statistics/widgets/form_card.dart';

class ClubStatsSection extends StatelessWidget {
  final ClubStats club;

  const ClubStatsSection({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalDiff = club.goalsFor - club.goalsAgainst;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'Holdets Stats',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FormCard(lastFiveMatchesForm: club.lastFiveMatchesForm),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              MiniStatCard(
                title: 'Vundne',
                value: club.wins.toString(),
                color: Colors.green.shade700,
              ),
              MiniStatCard(
                title: 'Uafgjorte',
                value: club.draws.toString(),
                color: Colors.orange.shade700,
              ),
              MiniStatCard(
                title: 'Tabte',
                value: club.losses.toString(),
                color: Colors.red.shade700,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                title: 'Målscorer',
                value: '${club.goalsFor} - ${club.goalsAgainst}',
                icon: Icons.sports_baseball,
                color: Colors.indigo,
              ),
              StatCard(
                title: 'Målforskel',
                value: '${goalDiff > 0 ? "+" : ""}$goalDiff',
                icon: Icons.leaderboard,
                color: Colors.amber.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }
}