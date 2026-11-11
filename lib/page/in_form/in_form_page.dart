import 'package:kopa/l10n/current_l10n.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/season/season_selector.dart';
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
                        const SizedBox(height: Spacing.lg),
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

class _LeaderboardHero extends StatelessWidget {
  final InFormLeaderboardRow? currentPlayer;

  const _LeaderboardHero({required this.currentPlayer});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      color: colors.surface,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: 2,
            child: Opacity(
              opacity: .92,
              child: InFormMascot(
                asset: 'assets/illustrations/kopa_flag.svg',
                size: 108,
                color: colors.grass,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InFormEyebrow(
                  label: AppLocalizations.of(context)!.uiTheTeamCompetition,
                  color: colors.lightGrass,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  AppLocalizations.of(context)!.uiWhoIsNinForm,
                  style: styles.pageTitle.copyWith(
                    color: colors.dirt,
                    fontSize: 34,
                    height: .98,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  currentPlayer == null
                      ? AppLocalizations.of(context)!
                          .uiMatchDataStreaksAndBonusesIn
                      : AppLocalizations.of(context)!.uiYouAreNoWith(
                          currentPlayer!.rank, _points(currentPlayer!.total)),
                  style: styles.body.copyWith(
                    color: colors.textSecondary,
                    height: 1.25,
                  ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: InFormPeriod.values
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: Spacing.sm),
                    child: InFormPill(
                      label: item.label,
                      selected: period == item,
                      onTap: () => onPeriodChanged(item),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        InFormPill(
          label: inFormPositionLabel(position),
          selected: position != null,
          selectedColor: colors.sky,
          icon: Icons.tune,
          onTap: () => _selectPosition(context),
        ),
      ],
    );
  }

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
const double _numberColumnWidth = 54;

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

    Widget number(String label) => SizedBox(
          width: _numberColumnWidth,
          child: Text(label, textAlign: TextAlign.right, style: style),
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
          number(l10n.inFormColumnLatest),
          number(l10n.inFormColumnToFirst),
          number(l10n.inFormColumnTotal),
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
            SizedBox(
              width: _numberColumnWidth,
              child: Text(
                inFormSigned(row.latestRound),
                textAlign: TextAlign.right,
                style: styles.caption.copyWith(
                  color: row.latestRound < 0 ? colors.error : colors.grass,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              width: _numberColumnWidth,
              child: Text(
                row.rank == 1 || row.pointsToFirst == 0
                    ? '–'
                    : '-${inFormNumber(row.pointsToFirst)}',
                textAlign: TextAlign.right,
                style: styles.caption.copyWith(color: colors.textSecondary),
              ),
            ),
            SizedBox(
              width: _numberColumnWidth,
              child: Text(
                inFormNumber(row.total),
                textAlign: TextAlign.right,
                style: styles.bodyBold.copyWith(
                  color: colors.dirt,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
