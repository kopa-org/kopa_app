import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/repository/in_form_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class InFormPlayerPage extends StatefulWidget {
  final int teamId;
  final InFormLeaderboardRow row;
  final InFormPeriod period;

  const InFormPlayerPage({
    super.key,
    required this.teamId,
    required this.row,
    required this.period,
  });

  @override
  State<InFormPlayerPage> createState() => _InFormPlayerPageState();
}

class _InFormPlayerPageState extends State<InFormPlayerPage> {
  late final Future<InFormPlayerBreakdown> _breakdown;

  @override
  void initState() {
    super.initState();
    _breakdown = InFormRepository.getPlayerBreakdown(
      teamId: widget.teamId,
      playerId: widget.row.userId,
      period: widget.period,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return PageScaffold(
      title: widget.row.userName,
      showBackButton: true,
      body: FutureBuilder<InFormPlayerBreakdown>(
        future: _breakdown,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: colors.grass),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _PlayerMessage(
              text: 'Kunne ikke hente pointdetaljer.',
              color: colors.lightSky,
            );
          }

          final breakdown = snapshot.data!;
          final groups = _groupByDate(breakdown.entries).entries.toList();

          return CustomScrollView(
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
                      _PlayerHero(
                        row: widget.row,
                        total: breakdown.total,
                      ),
                      const SizedBox(height: Spacing.md),
                      _PlayerMetrics(row: widget.row),
                      const SizedBox(height: Spacing.lg),
                      InFormSectionTitle(
                        title: 'Pointfortælling',
                        action: widget.period.label,
                      ),
                      const SizedBox(height: Spacing.sm),
                    ],
                  ),
                ),
              ),
              if (groups.isEmpty)
                SliverToBoxAdapter(
                  child: _PlayerMessage(
                    text: 'Ingen point i den valgte periode.',
                    color: colors.lightGrass,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  sliver: SliverList.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.md),
                        child: _ScoreDay(
                          date: group.key,
                          entries: group.value,
                        ),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: Spacing.xxl),
              ),
            ],
          );
        },
      ),
    );
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

    return InFormPanel(
      color: colors.surface,
      border: Border.all(color: colors.grass, width: 2),
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
                      foregroundColor: colors.grass,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InFormEyebrow(
                            label: '#${row.rank} på holdet',
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
                  _number(total),
                  style: styles.pageTitle.copyWith(
                    color: colors.grass,
                    fontSize: 42,
                    height: .9,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'point · ${inFormPositionLabel(row.position)}',
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
    final movement = row.rankChange == 0
        ? 'Stabil'
        : '${row.rankChange > 0 ? '+' : '-'}${row.rankChange.abs()}';

    return Row(
      children: [
        InFormMetric(
          label: 'Seneste runde',
          value: _signed(row.latestRound),
          color: colors.lightGrass,
          icon: Icons.bolt,
        ),
        const SizedBox(width: Spacing.sm),
        InFormMetric(
          label: 'Til førsteplads',
          value: row.rank == 1 ? 'Fører' : '-${_number(row.pointsToFirst)}',
          color: colors.lightSky,
          icon: Icons.flag_outlined,
        ),
        const SizedBox(width: Spacing.sm),
        InFormMetric(
          label: 'Bevægelse',
          value: movement,
          color: colors.sunset.withValues(alpha: .3),
          icon: row.rankChange >= 0 ? Icons.trending_up : Icons.trending_down,
        ),
      ],
    );
  }
}

class _ScoreDay extends StatelessWidget {
  final DateTime date;
  final List<InFormScoreEntry> entries;

  const _ScoreDay({required this.date, required this.entries});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final dayTotal =
        entries.fold<double>(0, (total, entry) => total + entry.value);

    return InFormPanel(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.offWhite,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: colors.grass,
                  size: 20,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dateLabel(date), style: styles.bodyBold),
                    Text(
                      '${entries.length} ${entries.length == 1 ? 'hændelse' : 'hændelser'}',
                      style: styles.caption,
                    ),
                  ],
                ),
              ),
              _PointBadge(value: dayTotal, strong: true),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Divider(color: colors.divider, height: 1),
          ...entries.map(
            (entry) => _ScoreEntry(
              entry: entry,
              showDivider: entry != entries.last,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreEntry extends StatelessWidget {
  final InFormScoreEntry entry;
  final bool showDivider;

  const _ScoreEntry({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final positive = entry.value >= 0;
    final bonus = _isBonus(entry.rule);
    final iconColor = positive ? colors.grass : colors.error;
    final iconBackground = bonus
        ? colors.sunset.withValues(alpha: .24)
        : positive
            ? colors.lightGrass.withValues(alpha: .6)
            : colors.error.withValues(alpha: .1);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.md),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                      BorderRadius.circular(Spacing.borderRadiusSmall),
                ),
                child: Icon(
                  bonus
                      ? Icons.auto_awesome
                      : positive
                          ? Icons.add
                          : Icons.remove,
                  color: bonus ? colors.sunset : iconColor,
                  size: 17,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  entry.description,
                  style: styles.body.copyWith(height: 1.2),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              _PointBadge(value: entry.value),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: colors.divider,
            height: 1,
            indent: 50,
          ),
      ],
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
        _signed(value),
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

Map<DateTime, List<InFormScoreEntry>> _groupByDate(
  List<InFormScoreEntry> entries,
) {
  final groups = <DateTime, List<InFormScoreEntry>>{};
  for (final entry in entries) {
    final date = DateTime(
      entry.awardedOn.year,
      entry.awardedOn.month,
      entry.awardedOn.day,
    );
    groups.putIfAbsent(date, () => []).add(entry);
  }
  return groups;
}

bool _isBonus(String rule) {
  return rule.contains('streak') ||
      rule.contains('bonus') ||
      rule.contains('season') ||
      rule.contains('monthly') ||
      rule.contains('utility');
}

String _dateLabel(DateTime date) {
  const months = [
    'januar',
    'februar',
    'marts',
    'april',
    'maj',
    'juni',
    'juli',
    'august',
    'september',
    'oktober',
    'november',
    'december',
  ];
  return '${date.day}. ${months[date.month - 1]} ${date.year}';
}

String _number(double value) {
  return value == value.roundToDouble()
      ? '${value.toInt()}'
      : value.toStringAsFixed(1);
}

String _signed(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${_number(value)}';
}
