import 'package:flutter/material.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/page/statistics/widgets/stat_card.dart';
import 'package:kopa/page/statistics/widgets/attendance_card.dart';
import 'package:kopa/page/statistics/widgets/fines_card.dart';

class PlayerStatsSection extends StatelessWidget {
  final PlayerStats player;

  const PlayerStatsSection({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            'Mine Stats',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
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
                title: 'Kampe',
                value: player.matchesPlayed.toString(),
                icon: Icons.sports_soccer,
                color: Colors.blueAccent,
              ),
              StatCard(
                title: 'Mål',
                value: player.goalsScored.toString(),
                icon: Icons.sports_score,
                color: Colors.green,
              ),
              StatCard(
                title: 'Assists',
                value: player.assists.toString(),
                icon: Icons.handshake,
                color: Colors.teal,
              ),
              StatCard(
                title: 'Kort (G/R)',
                value: '${player.yellowCards} / ${player.redCards}',
                icon: Icons.style,
                color: Colors.orange,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: AttendanceCard(
            percentage: player.trainingAttendancePercentage,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: FinesCard(totalFines: player.finesTotal),
        ),
      ],
    );
  }
}