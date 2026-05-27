import 'package:flutter/material.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

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

    final motm =
        match.matchPollDetails?.playerOfTheMatchDetails.name ?? 'Ingen valgt';
    final scorers = match.matchEventDetailsList
            ?.where((event) => event.type == MatchEventType.goal)
            .map((event) => event.goalscorerUserName)
            .toList() ??
        [];

    final score = '${match.homeTeamScore ?? 0} - ${match.awayTeamScore ?? 0}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: appColors.surface,
            border: Border.all(
              color: appColors.lightGrass.withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: appColors.grass.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.offWhite,
                        border: Border.all(
                          color: appColors.divider,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Seneste opgør',
                        style: appTextStyles.caption.copyWith(
                          color: appColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateHelper.getFormattedDate(match.date),
                      style: appTextStyles.caption.copyWith(
                        color: appColors.textSecondary.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _TeamColumn(
                        label: match.homeTeam ?? 'Hjemme',
                        alignEnd: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Text(
                            score,
                            style: appTextStyles.pageTitle.copyWith(
                              color: appColors.black,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 52,
                            height: 4,
                            decoration: BoxDecoration(
                              color: appColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _TeamColumn(
                        label: match.awayTeam ?? 'Ude',
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: appColors.offWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: appColors.lightGrass.withValues(alpha: 0.85),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: appColors.sun.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: appColors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            const SizedBox(height: 2),
                            Text(
                              motm,
                              style: appTextStyles.bodyBold.copyWith(
                                color: appColors.black,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Målscorere',
                  style: appTextStyles.caption.copyWith(
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Åbn kampdetaljer',
                      style: appTextStyles.bodyBold.copyWith(
                        color: appColors.black,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: appColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: appColors.offWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appColors.divider),
          ),
          alignment: Alignment.center,
          child: Text(
            _getInitials(label),
            style: appTextStyles.bodyBold.copyWith(
              color: appColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: appTextStyles.bodyBold.copyWith(
            color: const Color(0xFF101010),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getInitials(String teamName) {
    final parts = teamName
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
