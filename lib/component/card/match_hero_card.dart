import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class MatchHeroCard extends StatelessWidget {
  final MatchDetails match;
  final VoidCallback? onTap;

  const MatchHeroCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final dateFormat = DateFormat('EEE d. MMM', 'da_DK');
    final timeFormat = DateFormat('HH:mm');

    return KopaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: appColors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(match.date).toUpperCase(),
                  style: appTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: Text(
                    match.location,
                    style: appTextStyles.caption.copyWith(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Spacing.lg,
              horizontal: Spacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      AppAvatar(
                        initials: _getInitials(match.homeTeam),
                        radius: 30,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        match.homeTeam ?? 'Hjemme',
                        style: appTextStyles.bodyBold,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      if (match.hasMatchBeenPlayed)
                        Text(
                          '${match.homeTeamScore} - ${match.awayTeamScore}',
                          style: appTextStyles.pageTitle.copyWith(
                            fontSize: 32,
                          ),
                        )
                      else
                        Text(
                          timeFormat.format(match.date),
                          style: appTextStyles.pageTitle.copyWith(
                            fontSize: 32,
                          ),
                        ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        match.type,
                        style: appTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      AppAvatar(
                        initials: _getInitials(match.awayTeam),
                        radius: 30,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        match.awayTeam ?? 'Ude',
                        style: appTextStyles.bodyBold,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? teamName) {
    if (teamName == null || teamName.isEmpty) return '?';
    return teamName.substring(0, 1).toUpperCase();
  }
}
