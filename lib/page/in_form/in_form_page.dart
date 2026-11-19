import 'package:kopa/l10n/current_l10n.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/season/season_selector.dart';
import 'package:kopa/component/segment/expanding_segmented_control.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/in_form_cubit.dart';
import 'package:kopa/cubits/in_form_state.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_player_page.dart';
import 'package:kopa/page/in_form/in_form_points_system_page.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class InFormPage extends StatelessWidget {
  const InFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final teamId = user?.teamDetails?.id;

    return BlocProvider(
      create: (_) => InFormCubit()..load(teamId ?? 0),
      child: _InFormView(
        teamId: teamId,
        currentUserId: user?.id,
        initialPosition: user?.position,
      ),
    );
  }
}

class _InFormView extends StatefulWidget {
  final int? teamId;
  final int? currentUserId;
  final String? initialPosition;

  const _InFormView({
    required this.teamId,
    required this.currentUserId,
    required this.initialPosition,
  });

  @override
  State<_InFormView> createState() => _InFormViewState();
}

class _InFormViewState extends State<_InFormView> {
  String? _profilePosition;
  bool _savingPosition = false;

  @override
  void initState() {
    super.initState();
    _profilePosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return PageScaffold(
      title: 'In-form',
      showBackButton: true,
      body: BlocBuilder<InFormCubit, InFormState>(
        builder: (context, state) {
          if (widget.teamId == null) {
            return Center(
                child: Text(AppLocalizations.of(context)!.uiNoTeamSelected));
          }

          final rows = state.leaderboard?.rows ?? const [];
          final currentPlayer = rows.cast<InFormLeaderboardRow?>().firstWhere(
                (row) => row?.userId == widget.currentUserId,
                orElse: () => null,
              );

          return RefreshIndicator(
            color: colors.grass,
            onRefresh: () => context.read<InFormCubit>().load(widget.teamId!),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LeaderboardHero(currentPlayer: currentPlayer),
                        if (_profilePosition == null) ...[
                          const SizedBox(height: Spacing.md),
                          _PositionPrompt(
                            saving: _savingPosition,
                            onSelected: _savePosition,
                          ),
                        ],
                        const SizedBox(height: Spacing.md),
                        InFormSectionTitle(
                          title: AppLocalizations.of(context)!.uiTable,
                          action: AppLocalizations.of(context)!
                              .inFormSeeHowPointsWork,
                          onAction: _openPointsSystem,
                        ),
                        const SizedBox(height: Spacing.sm),
                        _FilterBar(
                          period: state.period,
                          position: state.position,
                          onPeriodChanged:
                              context.read<InFormCubit>().selectPeriod,
                          onPositionChanged:
                              context.read<InFormCubit>().selectPosition,
                        ),
                        if (state.period == InFormPeriod.currentSeason &&
                            state.selectedSeason != null) ...[
                          const SizedBox(height: Spacing.sm),
                          SeasonSelectorButton(
                            key: const ValueKey('in-form-season-selector'),
                            season: state.selectedSeason!,
                            onTap: state.seasons.length > 1
                                ? () => _pickSeason(context)
                                : null,
                          ),
                        ],
                        if (state.isViewingPastSeason) ...[
                          const SizedBox(height: Spacing.md),
                          PastSeasonBanner(
                            season: state.selectedSeason!,
                            onBackToCurrent: () =>
                                context.read<InFormCubit>().showActiveSeason(),
                          ),
                        ],
                        const SizedBox(height: Spacing.lg),
                      ],
                    ),
                  ),
                ),
                if (state.status == InFormStatus.loading ||
                    state.status == InFormStatus.initial)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                    sliver: SliverToBoxAdapter(child: _LoadingPanel()),
                  )
                else if (state.status == InFormStatus.failure)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    sliver: SliverToBoxAdapter(
                      child: _MessagePanel(
                        text: state.errorMessage ??
                            AppLocalizations.of(context)!.uiSomethingWentWrong,
                        color: colors.lightSky,
                        mascot: 'assets/illustrations/kopa_heart.svg',
                      ),
                    ),
                  )
                else if (state.status == InFormStatus.empty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    sliver: SliverToBoxAdapter(
                      child: _MessagePanel(
                        text: AppLocalizations.of(context)!
                            .uiNoPointsYetRecordMatchData,
                        color: colors.lightGrass,
                        mascot: 'assets/illustrations/kopa_flag.svg',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    sliver: SliverToBoxAdapter(
                      child: InFormLeagueTable(
                        rows: rows,
                        currentUserId: widget.currentUserId,
                        onPlayerTap: _openPlayer,
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

  Future<void> _pickSeason(BuildContext context) async {
    final cubit = context.read<InFormCubit>();
    final picked = await showSeasonPicker(
      context,
      seasons: cubit.state.seasons,
      selected: cubit.state.selectedSeason,
    );
    if (picked != null) await cubit.selectSeason(picked);
  }

  void _openPlayer(InFormLeaderboardRow row) {
    final cubit = context.read<InFormCubit>();
    final state = cubit.state;
    final season = state.selectedSeason;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InFormPlayerPage(
          teamId: widget.teamId!,
          row: row,
          period: state.period,
          seasonId: state.requestSeasonId,
          periodLabel:
              state.period == InFormPeriod.currentSeason && season != null
                  ? season.name
                  : null,
          // Match edits change everyone's totals, so refresh the table.
          onScoresChanged: () => cubit.load(widget.teamId!),
        ),
      ),
    );
  }

  void _openPointsSystem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InFormPointsSystemPage(
          initialPosition: _profilePosition,
        ),
      ),
    );
  }

  Future<void> _savePosition(String position) async {
    setState(() => _savingPosition = true);
    try {
      final user = await UsersRepository.updatePosition(position);
      if (!mounted) return;
      context.read<AuthCubit>().updateUser(user);
      setState(() => _profilePosition = user.position);
    } finally {
      if (mounted) setState(() => _savingPosition = false);
    }
  }
}

/// Compact intro above the table: the table is what the page is about.
class _LeaderboardHero extends StatelessWidget {
  final InFormLeaderboardRow? currentPlayer;

  const _LeaderboardHero({required this.currentPlayer});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return InFormPanel(
      key: const ValueKey('in-form-hero'),
      color: colors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.itemGap,
      ),
      child: Row(
        children: [
          InFormMascot(
            asset: 'assets/illustrations/kopa_flag.svg',
            size: 44,
            color: colors.grass,
          ),
          const SizedBox(width: Spacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.uiWhoIsNinForm,
                  style: styles.bodyBold.copyWith(
                    color: colors.dirt,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentPlayer == null
                      ? l10n.uiMatchDataStreaksAndBonusesIn
                      : l10n.uiYouAreNoWith(
                          currentPlayer!.rank, _points(currentPlayer!.total)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styles.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final InFormPeriod period;
  final String? position;
  final ValueChanged<InFormPeriod> onPeriodChanged;
  final ValueChanged<String?> onPositionChanged;

  const _FilterBar({
    required this.period,
    required this.position,
    required this.onPeriodChanged,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final filtered = position != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              // Same tab menu as match details and the fine box.
              child: ExpandingSegmentedControl<InFormPeriod>(
                key: const ValueKey('in-form-period-control'),
                segments: [
                  // Season first, then the shorter and longer views.
                  for (final item in const [
                    InFormPeriod.currentSeason,
                    InFormPeriod.rollingThreeMonths,
                    InFormPeriod.allTime,
                  ])
                    ExpandingSegment(
                      value: item,
                      label: item.label,
                      icon: _periodIcon(item),
                      keyName: 'in-form-period-${item.name}',
                    ),
                ],
                selected: period,
                onChanged: onPeriodChanged,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Semantics(
              button: true,
              label: l10n.uiChoosePosition,
              child: Material(
                color: filtered ? colors.sky : colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  key: const ValueKey('in-form-position-filter'),
                  customBorder: const CircleBorder(),
                  onTap: () => _selectPosition(context),
                  child: SizedBox.square(
                    dimension: 44,
                    child: Icon(
                      Icons.tune,
                      size: 18,
                      color: filtered ? colors.white : colors.dirt,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (filtered) ...[
          const SizedBox(height: Spacing.sm),
          InputChip(
            label: Text(
              inFormPositionLabel(position),
              style: styles.caption.copyWith(
                color: colors.dirt,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: colors.lightSky,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            onPressed: () => _selectPosition(context),
            onDeleted: () => onPositionChanged(null),
            deleteIconColor: colors.dirt,
          ),
        ],
      ],
    );
  }

  static IconData _periodIcon(InFormPeriod period) => switch (period) {
        InFormPeriod.rollingThreeMonths => Icons.date_range_outlined,
        InFormPeriod.currentSeason => Icons.emoji_events_outlined,
        InFormPeriod.allTime => Icons.all_inclusive_rounded,
      };

  Future<void> _selectPosition(BuildContext context) async {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: colors.offWhite,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.uiChoosePosition,
                  style: styles.sectionHeader),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  InFormPill(
                    label: AppLocalizations.of(context)!.uiAllPositions,
                    selected: position == null,
                    onTap: () => Navigator.pop(context, '__all__'),
                  ),
                  ...inFormPositions.map(
                    (item) => InFormPill(
                      label: inFormPositionLabel(item),
                      selected: position == item,
                      onTap: () => Navigator.pop(context, item),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    onPositionChanged(selected == '__all__' ? null : selected);
  }
}

class _PositionPrompt extends StatelessWidget {
  final bool saving;
  final ValueChanged<String> onSelected;

  const _PositionPrompt({
    required this.saving,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      color: colors.lightSky,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InFormMascot(
            asset: 'assets/illustrations/kopa_thumb.svg',
            size: 54,
            color: colors.sky,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.uiWhichPositionDoYouPlay,
                    style: styles.bodyBold),
                const SizedBox(height: Spacing.xs),
                Text(
                  AppLocalizations.of(context)!
                      .uiYourPositionGivesThePointRules,
                  style: styles.caption,
                ),
                const SizedBox(height: Spacing.md),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: inFormPositions
                      .map(
                        (position) => InFormPill(
                          label: inFormPositionLabel(position),
                          selected: false,
                          onTap: saving ? () {} : () => onSelected(position),
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
}

/// The league table from the concept: rank, movement since the latest
/// round, points in the latest round, distance to first place and total.
class InFormLeagueTable extends StatelessWidget {
  final List<InFormLeaderboardRow> rows;
  final int? currentUserId;
  final ValueChanged<InFormLeaderboardRow> onPlayerTap;

  const InFormLeagueTable({
    required this.rows,
    required this.currentUserId,
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return InFormPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _LeagueTableHeader(),
          Divider(height: 1, color: colors.divider),
          for (var index = 0; index < rows.length; index++) ...[
            _LeagueTableRow(
              row: rows[index],
              isCurrentUser: rows[index].userId == currentUserId,
              onTap: () => onPlayerTap(rows[index]),
            ),
            if (index < rows.length - 1)
              Divider(
                height: 1,
                indent: Spacing.md,
                endIndent: Spacing.md,
                color: colors.divider,
              ),
          ],
        ],
      ),
    );
  }
}

const double _rankColumnWidth = 30;

class _LeagueTableHeader extends StatelessWidget {
  const _LeagueTableHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final style = styles.caption.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w700,
      fontSize: 11,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.itemGap,
        Spacing.md,
        Spacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(width: _rankColumnWidth, child: Text('#', style: style)),
          const SizedBox(width: Spacing.sm),
          Expanded(child: Text(l10n.inFormColumnPlayer, style: style)),
          // Explains the green and red numbers under each total.
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '+ ${l10n.inFormLegendLatest}',
                style: style.copyWith(color: colors.grass),
              ),
              const TextSpan(text: '  '),
              TextSpan(
                text: '− ${l10n.inFormLegendToFirst}',
                style: style.copyWith(color: colors.error),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _LeagueTableRow extends StatelessWidget {
  final InFormLeaderboardRow row;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const _LeagueTableRow({
    required this.row,
    required this.isCurrentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final podiumColor = switch (row.rank) {
      1 => colors.grass,
      2 => colors.sky,
      3 => colors.sunset,
      _ => null,
    };
    final detailStyle = styles.caption.copyWith(fontWeight: FontWeight.w700);
    final behindFirst = row.rank != 1 && row.pointsToFirst > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isCurrentUser ? colors.lightGrass.withValues(alpha: .28) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.itemGap,
        ),
        child: Row(
          children: [
            SizedBox(
              width: _rankColumnWidth,
              child: _RankBadge(
                rank: row.rank,
                color: podiumColor ?? colors.offWhite,
                foregroundColor:
                    podiumColor != null ? AppColors.of(context).white : null,
                size: 28,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          row.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.bodyBold.copyWith(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      InFormMovement(change: row.rankChange),
                    ],
                  ),
                  if (row.position != null)
                    Text(
                      inFormPositionLabel(row.position),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  inFormNumber(row.total),
                  key: ValueKey('in-form-total-${row.userId}'),
                  style: styles.bodyBold.copyWith(
                    color: colors.dirt,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  key: ValueKey('in-form-detail-${row.userId}'),
                  TextSpan(children: [
                    TextSpan(
                      text: inFormSigned(row.latestRound),
                      style: detailStyle.copyWith(
                        color: row.latestRound < 0
                            ? colors.textSecondary
                            : colors.grass,
                      ),
                    ),
                    if (behindFirst)
                      TextSpan(
                        text: '  -${inFormNumber(row.pointsToFirst)}',
                        style: detailStyle.copyWith(color: colors.error),
                      ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;
  final Color? foregroundColor;
  final double size;

  const _RankBadge({
    required this.rank,
    required this.color,
    this.foregroundColor,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        '#$rank',
        style: styles.caption.copyWith(
          color: foregroundColor ?? colors.dirt,
          fontWeight: FontWeight.w800,
          fontSize: size < 34 ? 12 : null,
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return InFormPanel(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
        child: Center(
          child: CircularProgressIndicator(color: colors.grass),
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  final String text;
  final Color color;
  final String mascot;

  const _MessagePanel({
    required this.text,
    required this.color,
    required this.mascot,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return InFormPanel(
      color: color,
      child: Column(
        children: [
          InFormMascot(asset: mascot, size: 72, color: colors.dirt),
          const SizedBox(height: Spacing.md),
          Text(
            text,
            textAlign: TextAlign.center,
            style: styles.body.copyWith(color: colors.dirt),
          ),
        ],
      ),
    );
  }
}

String _points(double value) => currentL10n.uiPoints(inFormNumber(value));
