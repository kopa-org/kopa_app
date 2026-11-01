import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/page/statistics/widgets/stat_card.dart';
import 'package:kopa/page/statistics/widgets/attendance_card.dart';
import 'package:kopa/page/statistics/widgets/fines_card.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class PlayerStatsSection extends StatelessWidget {
  final PlayerStats player;

  const PlayerStatsSection({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)!.uiMyStats,
            style: appTextStyles.sectionHeader.copyWith(
              color: appColors.primary,
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
                title: AppLocalizations.of(context)!.navMatches,
                value: player.matchesPlayed.toString(),
                icon: Icons.sports_soccer,
                color: appColors.sky,
              ),
              StatCard(
                title: AppLocalizations.of(context)!.matchTimelineGoal,
                value: player.goalsScored.toString(),
                icon: Icons.sports_score,
                color: appColors.success,
              ),
              StatCard(
                title: 'Assists',
                value: player.assists.toString(),
                icon: Icons.handshake,
                color: appColors.grass,
              ),
              StatCard(
                title: AppLocalizations.of(context)!.uiCardsYR,
                value: '${player.yellowCards} / ${player.redCards}',
                icon: Icons.style,
                color: appColors.warning,
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
