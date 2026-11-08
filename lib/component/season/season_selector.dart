import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/component/chip/match_result_badge.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// "Aug 2025 – Jul 2026", or the start month alone for an open season.
String seasonDateRange(SeasonDetails season) {
  String monthYear(DateTime date) =>
      '${DateHelper.getShortMonthName(date)} ${date.year}';

  final endsOn = season.endsOn;
  if (endsOn == null) return monthYear(season.startsOn);
  return '${monthYear(season.startsOn)} – ${monthYear(endsOn)}';
}

/// Pill under the match schedule title showing which season is listed.
///
/// [onTap] is null when the team has a single season; the pill then reads as
/// a label without the dropdown chevron.
class SeasonSelectorButton extends StatelessWidget {
  final SeasonDetails season;
  final VoidCallback? onTap;

  const SeasonSelectorButton({
    super.key,
    required this.season,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final borderRadius = BorderRadius.circular(Spacing.borderRadiusFull);

    return Semantics(
      button: onTap != null,
      label: l10n.matchSeasonSelectorLabel(season.name),
      excludeSemantics: true,
      child: Material(
        color: colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: colors.grey3.withValues(alpha: 0.6)),
        ),
        child: InkWell(
          key: const ValueKey('match-season-selector'),
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: borderRadius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (season.isActive)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.grass,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    Icon(
                      CupertinoIcons.archivebox,
                      size: 16,
                      color: colors.grey5,
                    ),
                  const SizedBox(width: Spacing.sm),
                  Flexible(
                    child: Text(
                      season.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.body4.copyWith(
                        color: colors.dirt,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (season.isActive) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· ${l10n.matchSeasonActive}',
                      style: styles.body4.copyWith(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (onTap != null) ...[
                    const SizedBox(width: 6),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet listing the team's seasons. Resolves to the chosen season, or
/// null when dismissed.
Future<SeasonDetails?> showSeasonPicker(
  BuildContext context, {
  required List<SeasonDetails> seasons,
  required SeasonDetails? selected,
}) {
  return showModalBottomSheet<SeasonDetails>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => _SeasonPickerSheet(
      seasons: seasons,
      selected: selected,
    ),
  );
}

class _SeasonPickerSheet extends StatelessWidget {
  final List<SeasonDetails> seasons;
  final SeasonDetails? selected;

  const _SeasonPickerSheet({
    required this.seasons,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final active = seasons.where((season) => season.isActive).toList();
    final past = seasons.where((season) => !season.isActive).toList()
      ..sort((a, b) => b.startsOn.compareTo(a.startsOn));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.grey3,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.matchSeasonPickerTitle,
                      style: styles.subtitle1.copyWith(
                        color: colors.dirt,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.matchSeasonClose,
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.offWhite,
                      minimumSize: const Size(44, 44),
                    ),
                    icon: Icon(
                      CupertinoIcons.xmark,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  for (final season in active)
                    _SeasonTile(
                      season: season,
                      isSelected: season.id == selected?.id,
                    ),
                  if (past.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                      child: Text(
                        l10n.matchSeasonPreviousSeasons.toUpperCase(),
                        style: styles.buttonTiny.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    for (final season in past) ...[
                      _SeasonTile(
                        season: season,
                        isSelected: season.id == selected?.id,
                      ),
                      const SizedBox(height: Spacing.sm),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonTile extends StatelessWidget {
  final SeasonDetails season;
  final bool isSelected;

  const _SeasonTile({required this.season, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final borderRadius = BorderRadius.circular(14);
    final subtitle = season.isActive
        ? l10n.matchSeasonStartedOn(
            DateHelper.getFormattedLongDate(season.startsOn),
          )
        : seasonDateRange(season);

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? colors.lightGrass55 : colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: isSelected
                ? colors.grass
                : colors.grey3.withValues(alpha: 0.45),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: ValueKey('match-season-option-${season.id}'),
          onTap: () => Navigator.of(context).pop(season),
          customBorder: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: season.isActive ? colors.grass : colors.offWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    season.isActive
                        ? CupertinoIcons.clock
                        : CupertinoIcons.archivebox,
                    size: 20,
                    color: season.isActive ? colors.white : colors.grey7,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: Spacing.sm,
                        runSpacing: Spacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            season.name,
                            style: styles.subtitle2.copyWith(
                              color: colors.dirt,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (season.isActive)
                            MatchOverviewChip(
                              label: l10n.matchSeasonActive,
                              status: MatchOverviewChipStatus.success,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: styles.body4.copyWith(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Icon(
                  isSelected
                      ? CupertinoIcons.checkmark_alt
                      : CupertinoIcons.chevron_right,
                  size: isSelected ? 22 : 18,
                  color: isSelected ? colors.grass : colors.grey5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner shown above a finished season's matches, with a shortcut back to
/// the active season.
class PastSeasonBanner extends StatelessWidget {
  final SeasonDetails season;
  final VoidCallback onBackToCurrent;

  const PastSeasonBanner({
    super.key,
    required this.season,
    required this.onBackToCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: colors.dirt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.matchSeasonFinished,
                  style: styles.body4.copyWith(
                    color: colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.matchSeasonViewingRange(seasonDateRange(season)),
                  style: styles.body4.copyWith(
                    color: colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            key: const ValueKey('match-season-back-to-current'),
            onPressed: onBackToCurrent,
            style: FilledButton.styleFrom(
              backgroundColor: colors.lightGrass,
              foregroundColor: colors.dirt,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: const StadiumBorder(),
              textStyle: styles.body4.copyWith(fontWeight: FontWeight.w700),
            ),
            child: Text(l10n.matchSeasonBackToCurrent),
          ),
        ],
      ),
    );
  }
}

/// Matches played plus won/drawn/lost for a finished season.
class SeasonResultSummary extends StatelessWidget {
  final List<MatchDetails> matches;
  final String? ownTeamName;

  const SeasonResultSummary({
    super.key,
    required this.matches,
    required this.ownTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final results = ownTeamResults(matches, ownTeamName);
    int count(MatchResultStatus status) =>
        results.where((result) => result == status).length;

    final tiles = [
      (
        matches.where((match) => match.isMatch).length,
        l10n.matchSeasonSummaryMatches
      ),
      (count(MatchResultStatus.win), l10n.matchSeasonSummaryWon),
      (count(MatchResultStatus.draw), l10n.matchSeasonSummaryDrawn),
      (count(MatchResultStatus.loss), l10n.matchSeasonSummaryLost),
    ];

    return Row(
      children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (index > 0) const SizedBox(width: Spacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    '${tile.$1}',
                    style: styles.subtitle1.copyWith(
                      color: colors.dirt,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tile.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.buttonTiny.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
