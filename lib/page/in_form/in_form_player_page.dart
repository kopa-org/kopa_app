import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/in_form_player_cubit.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_match_edit_sheet.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class InFormPlayerPage extends StatelessWidget {
  final int teamId;
  final InFormLeaderboardRow row;
  final InFormPeriod period;

  /// A finished season to show (period "Sæson"); null = the active season.
  final int? seasonId;

  /// Shown next to "Kampe"; defaults to the period's name.
  final String? periodLabel;

  /// Called after match data was changed, so the league table can refresh.
  final VoidCallback? onScoresChanged;

  @visibleForTesting
  final InFormPlayerLoader? loader;

  const InFormPlayerPage({
    super.key,
    required this.teamId,
    required this.row,
    required this.period,
    this.seasonId,
    this.periodLabel,
    this.onScoresChanged,
    this.loader,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InFormPlayerCubit(
        teamId: teamId,
        playerId: row.userId,
        period: period,
        seasonId: seasonId,
        loader: loader,
      )..load(),
      child: _InFormPlayerView(
        row: row,
        periodLabel: periodLabel ?? period.label,
        onScoresChanged: onScoresChanged,
      ),
    );
  }
}

class _InFormPlayerView extends StatelessWidget {
  final InFormLeaderboardRow row;
  final String periodLabel;
  final VoidCallback? onScoresChanged;

  const _InFormPlayerView({
    required this.row,
    required this.periodLabel,
    required this.onScoresChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: row.userName,
      showBackButton: true,
      body: BlocBuilder<InFormPlayerCubit, InFormPlayerState>(
        builder: (context, state) {
          final breakdown = state.breakdown;
          if (breakdown == null) {
            if (state.status == InFormPlayerStatus.failure) {
              return _PlayerMessage(
                text: l10n.uiCouldNotFetchPointDetails,
                color: colors.lightSky,
              );
            }
            return Center(
              child: CircularProgressIndicator(color: colors.grass),
            );
          }

          final matches = breakdown.matches;

          return RefreshIndicator(
            color: colors.grass,
            onRefresh: context.read<InFormPlayerCubit>().load,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.sm,
                    Spacing.md,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _PlayerHero(row: row, total: breakdown.total),
                        const SizedBox(height: Spacing.md),
                        _PlayerMetrics(row: row),
                        const SizedBox(height: Spacing.sm),
                        _SummaryStrip(summary: breakdown.summary),
                        const SizedBox(height: Spacing.lg),
                        InFormSectionTitle(
                          title: l10n.inFormMatches,
                          action: periodLabel,
                        ),
                        const SizedBox(height: Spacing.sm),
                      ],
                    ),
                  ),
                ),
                if (matches.isEmpty && breakdown.bonuses.isEmpty)
                  SliverToBoxAdapter(
                    child: _PlayerMessage(
                      text: l10n.uiNoPointsInTheSelectedPeriod,
                      color: colors.lightGrass,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    sliver: SliverList.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: _MatchCard(
                            match: match,
                            expanded:
                                state.expandedEventIds.contains(match.eventId),
                            canEditPosition: breakdown.canEditPosition,
                            canEditMatchData: breakdown.canEditMatchData,
                            onToggle: () => context
                                .read<InFormPlayerCubit>()
                                .toggleMatch(match.eventId),
                            onEdit: () => _editMatch(
                              context,
                              match,
                              breakdown.canEditMatchData,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (breakdown.bonuses.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.md,
                      Spacing.md,
                      Spacing.md,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InFormSectionTitle(title: l10n.inFormBonuses),
                          const SizedBox(height: Spacing.sm),
                          InFormPanel(
                            child: Column(
                              children: [
                                for (final entry in breakdown.bonuses)
                                  _ScoreLine(
                                    label: entry.description,
                                    caption: DateHelper.getFormattedLongDate(
                                        entry.awardedOn),
                                    value: entry.value,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: Spacing.xxl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _editMatch(
    BuildContext context,
    InFormMatchBreakdown match,
    bool canEditMatchData,
  ) async {
    final cubit = context.read<InFormPlayerCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    final changes = await showInFormMatchEditSheet(
      context,
      match: match,
      canEditMatchData: canEditMatchData,
    );
    if (changes == null || changes.isEmpty) return;

    final saved = await cubit.updateMatch(match.eventId, changes);
    messenger.showSnackBar(
      SnackBar(content: Text(saved ? l10n.inFormSaved : l10n.inFormSaveFailed)),
    );
    if (saved) onScoresChanged?.call();
  }
}

class _PlayerHero extends StatelessWidget {
  final InFormLeaderboardRow row;
  final double total;

  const _PlayerHero({required this.row, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return InFormPanel(
      color: colors.surface,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -12,
            child: InFormMascot(
              asset: 'assets/illustrations/kopa_thumb.svg',
              size: 108,
              color: colors.grass,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InFormAvatar(
                      name: row.userName,
                      radius: 28,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InFormEyebrow(
                            label: l10n.uiOnTheTeam(row.rank),
                            color: colors.lightGrass,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            row.userName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: styles.sectionHeader.copyWith(
                              color: colors.dirt,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  inFormNumber(total),
                  style: styles.pageTitle.copyWith(
                    color: colors.grass,
                    fontSize: 42,
                    height: .9,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.uiPoints2(inFormPositionLabel(row.position)),
                  style: styles.body.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerMetrics extends StatelessWidget {
  final InFormLeaderboardRow row;

  const _PlayerMetrics({required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = AppLocalizations.of(context)!;
    final movement = row.rankChange == 0
        ? l10n.uiStable
        : '${row.rankChange > 0 ? '+' : '-'}${row.rankChange.abs()}';

    return Row(
      children: [
        InFormMetric(
          label: l10n.uiLatestRound,
          value: inFormSigned(row.latestRound),
          color: colors.lightGrass,
          icon: Icons.bolt,
        ),
        const SizedBox(width: Spacing.sm),
        InFormMetric(
          label: l10n.uiToFirstPlace,
          value: row.rank == 1
              ? l10n.uiLeading
              : '-${inFormNumber(row.pointsToFirst)}',
          color: colors.lightSky,
          icon: Icons.flag_outlined,
        ),
        const SizedBox(width: Spacing.sm),
        InFormMetric(
          label: l10n.uiMovement,
          value: movement,
          color: colors.sunset.withValues(alpha: .3),
          icon: row.rankChange >= 0 ? Icons.trending_up : Icons.trending_down,
        ),
      ],
    );
  }
}

/// Key data points for the period: matches, goals, assists, cards, MOTM and
/// average points per match.
class _SummaryStrip extends StatelessWidget {
  final InFormPlayerSummary summary;

  const _SummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    final items = [
      (l10n.inFormMatches, '${summary.matches}'),
      (l10n.inFormGoals, '${summary.goals}'),
      (l10n.inFormAssists, '${summary.assists}'),
      (l10n.inFormCards, '${summary.yellowCards + summary.redCards}'),
      (l10n.inFormMotm, '${summary.motm}'),
      (l10n.inFormAverage, inFormNumber(summary.average)),
    ];

    return InFormPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.itemGap,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
                child: _SummaryCell(label: items[i].$1, value: items[i].$2)),
            if (i < items.length - 1)
              Container(width: 1, height: 28, color: colors.divider),
          ],
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      children: [
        Text(
          value,
          style: styles.bodyBold.copyWith(
            color: colors.dirt,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: styles.caption.copyWith(
            color: colors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final InFormMatchBreakdown match;
  final bool expanded;
  final bool canEditPosition;
  final bool canEditMatchData;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _MatchCard({
    required this.match,
    required this.expanded,
    required this.canEditPosition,
    required this.canEditMatchData,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    final venue = match.isHomeTeam ? l10n.inFormHome : l10n.inFormAway;
    final dateLabel = match.date == null
        ? venue
        : '${DateHelper.getFormattedLongDate(match.date!)} · $venue';
    final positionLabel = match.position == null
        ? null
        : l10n.inFormPlayedAs(inFormPositionLabel(match.position)) +
            (match.override.position != null
                ? ' (${l10n.inFormPositionChanged})'
                : '');

    return InFormPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel,
                          style: styles.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                match.opponent ?? l10n.inFormUnknownOpponent,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.bodyBold,
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            _ResultBadge(match: match),
                          ],
                        ),
                        if (positionLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            positionLabel,
                            style: styles.caption.copyWith(
                              color: match.override.position != null
                                  ? colors.sky
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  _PointBadge(value: match.total, strong: true),
                  AnimatedRotation(
                    turns: expanded ? .5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.expand_more,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? _MatchDetails(
                    match: match,
                    canEdit: canEditPosition || canEditMatchData,
                    editLabel: canEditMatchData
                        ? l10n.inFormEditMatch
                        : l10n.inFormChangePosition,
                    onEdit: onEdit,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final InFormMatchBreakdown match;

  const _ResultBadge({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.teamGoals == null || match.opponentGoals == null) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final color = switch (match.result) {
      InFormMatchResult.win => colors.grass,
      InFormMatchResult.loss => colors.error,
      _ => colors.sunset,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusExtraSmall),
      ),
      child: Text(
        '${match.teamGoals}–${match.opponentGoals}',
        style: styles.caption.copyWith(
          color: AppColors.of(context).white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// The drop-down for one match: every point line grouped by category.
class _MatchDetails extends StatelessWidget {
  final InFormMatchBreakdown match;
  final bool canEdit;
  final String editLabel;
  final VoidCallback onEdit;

  const _MatchDetails({
    required this.match,
    required this.canEdit,
    required this.editLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final byCategory = <String, List<InFormScoreEntry>>{};
    for (final entry in match.entries) {
      byCategory.putIfAbsent(entry.category, () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: colors.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.md,
            Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final category in inFormCategories)
                if (byCategory[category] case final entries?) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.sm),
                    child: Text(
                      inFormCategoryLabel(category).toUpperCase(),
                      style: styles.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: .6,
                      ),
                    ),
                  ),
                  for (final entry in entries)
                    _ScoreLine(label: entry.description, value: entry.value),
                ],
              if (canEdit)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(editLabel),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreLine extends StatelessWidget {
  final String label;
  final String? caption;
  final double value;

  const _ScoreLine({required this.label, required this.value, this.caption});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: styles.body.copyWith(height: 1.2)),
                if (caption != null)
                  Text(
                    caption!,
                    style: styles.caption.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            inFormSigned(value),
            style: styles.bodyBold.copyWith(
              color: value < 0 ? colors.error : colors.grass,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointBadge extends StatelessWidget {
  final double value;
  final bool strong;

  const _PointBadge({required this.value, this.strong = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final positive = value >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            positive ? colors.lightGrass : colors.error.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        inFormSigned(value),
        style: (strong ? styles.bodyBold : styles.caption).copyWith(
          color: positive ? colors.dirt : colors.error,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PlayerMessage extends StatelessWidget {
  final String text;
  final Color color;

  const _PlayerMessage({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: InFormPanel(
        color: color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InFormMascot(
              asset: 'assets/illustrations/kopa_heart.svg',
              size: 64,
              color: colors.dirt,
            ),
            const SizedBox(height: Spacing.md),
            Text(text, textAlign: TextAlign.center, style: styles.body),
          ],
        ),
      ),
    );
  }
}
