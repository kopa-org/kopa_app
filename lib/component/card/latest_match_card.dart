import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class LatestMatchCard extends StatelessWidget {
  final MatchDetails match;
  final VoidCallback? onTap;

  const LatestMatchCard({
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
    final motm =
        match.matchPollDetails?.playerOfTheMatchDetails.name ?? 'Ingen valgt';
    final scorers = match.matchEventDetailsList
            ?.where((event) => event.type == MatchEventType.goal)
            .map((event) => event.goalscorerUserName)
            .toList() ??
        [];

    final score = '${match.homeTeamScore ?? 0} - ${match.awayTeamScore ?? 0}';

    return KopaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header bar — mirrors MatchHeroCard for a shared match-card language.
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
            child: Column(
              children: [
                // Teams + score — same layout as MatchHeroCard.
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _TeamColumn(
                        label: match.homeTeam ?? 'Hjemme',
                        alignEnd: false,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Text(
                            score,
                            style: appTextStyles.pageTitle.copyWith(
                              color: appColors.black,
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
                      child: _TeamColumn(
                        label: match.awayTeam ?? 'Ude',
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                // Kampens spiller — muted, flat (no sun-yellow fill, no nested box).
                Row(
                  children: [
                    AppAvatar(
                      initials: _getInitials(motm),
                      radius: 20,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kampens spiller',
                            style: appTextStyles.caption.copyWith(
                              color: appColors.textSecondary,
                            ),
                          ),
                          Text(
                            motm,
                            style: appTextStyles.bodyBold.copyWith(
                              color: appColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                // Målscorere.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Målscorere',
                    style: appTextStyles.caption.copyWith(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: scorers.isEmpty
                      ? [
                          _ScorerChip(
                            label: 'Ingen mål registreret',
                            color: appColors.sky,
                          ),
                        ]
                      : scorers
                          .map(
                            (scorer) => _ScorerChip(
                              label: scorer,
                              color: appColors.lightSky,
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name == 'Ingen valgt') return '?';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _TeamColumn extends StatelessWidget {
  final String label;
  final bool alignEnd;

  const _TeamColumn({
    required this.label,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        AppAvatar(
          initials: _getInitial(label),
          radius: 30,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          label,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: appTextStyles.bodyBold.copyWith(
            color: appColors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getInitial(String teamName) {
    final trimmed = teamName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _ScorerChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ScorerChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: appTextStyles.caption.copyWith(
          color: appColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
