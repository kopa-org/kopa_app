import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/in_form_cubit.dart';
import 'package:kopa/cubits/in_form_state.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_player_page.dart';
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
            return const Center(child: Text('Ingen hold valgt.'));
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
                        const InFormSectionTitle(title: 'Rangliste'),
                        const SizedBox(height: Spacing.sm),
                        _FilterBar(
                          period: state.period,
                          position: state.position,
                          onPeriodChanged:
                              context.read<InFormCubit>().selectPeriod,
                          onPositionChanged:
                              context.read<InFormCubit>().selectPosition,
                        ),
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
                        text: state.errorMessage ?? 'Der skete en fejl.',
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
                        text:
                            'Ingen point endnu. Registrer kampdata for at starte holdkonkurrencen.',
                        color: colors.lightGrass,
                        mascot: 'assets/illustrations/kopa_flag.svg',
                      ),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    sliver: SliverToBoxAdapter(
                      child: _Podium(
                        rows: rows.take(3).toList(),
                        currentUserId: widget.currentUserId,
                        onPlayerTap: _openPlayer,
                      ),
                    ),
                  ),
                  if (rows.length > 3)
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        Spacing.md,
                        Spacing.lg,
                        Spacing.md,
                        Spacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: InFormSectionTitle(title: 'Resten af holdet'),
                      ),
                    ),
                  if (rows.length > 3)
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Spacing.md),
                      sliver: SliverList.builder(
                        itemCount: rows.length - 3,
                        itemBuilder: (context, index) {
                          final row = rows[index + 3];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: Spacing.sm),
                            child: _LeaderboardRow(
                              row: row,
                              isCurrentUser: row.userId == widget.currentUserId,
                              onTap: () => _openPlayer(row),
                            ),
                          );
                        },
                      ),
                    ),
                ],
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

  void _openPlayer(InFormLeaderboardRow row) {
    final state = context.read<InFormCubit>().state;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InFormPlayerPage(
          teamId: widget.teamId!,
          row: row,
          period: state.period,
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
      border: Border.all(color: colors.grass, width: 2),
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
                  label: 'Holdkonkurrencen',
                  color: colors.lightGrass,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Hvem er\ni form?',
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
                      ? 'Kampdata, streaks og bonusser samlet ét sted.'
                      : 'Du er nr. ${currentPlayer!.rank} med ${_points(currentPlayer!.total)}.',
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
              Text('Vælg position', style: styles.sectionHeader),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  InFormPill(
                    label: 'Alle positioner',
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
                Text('Hvilken position spiller du?', style: styles.bodyBold),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Din position giver pointreglerne den rigtige vægt.',
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

class _Podium extends StatelessWidget {
  final List<InFormLeaderboardRow> rows;
  final int? currentUserId;
  final ValueChanged<InFormLeaderboardRow> onPlayerTap;

  const _Podium({
    required this.rows,
    required this.currentUserId,
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final leader = rows.first;

    return Column(
      children: [
        _PodiumCard(
          row: leader,
          color: colors.lightGrass,
          accent: colors.grass,
          large: true,
          isCurrentUser: leader.userId == currentUserId,
          onTap: () => onPlayerTap(leader),
        ),
        if (rows.length > 1) ...[
          const SizedBox(height: Spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PodiumCard(
                  row: rows[1],
                  color: colors.lightSky,
                  accent: colors.sky,
                  isCurrentUser: rows[1].userId == currentUserId,
                  onTap: () => onPlayerTap(rows[1]),
                ),
              ),
              if (rows.length > 2) ...[
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _PodiumCard(
                    row: rows[2],
                    color: colors.sunset.withValues(alpha: .22),
                    accent: colors.sunset,
                    isCurrentUser: rows[2].userId == currentUserId,
                    onTap: () => onPlayerTap(rows[2]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final InFormLeaderboardRow row;
  final Color color;
  final Color accent;
  final bool large;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const _PodiumCard({
    required this.row,
    required this.color,
    required this.accent,
    required this.isCurrentUser,
    required this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      color: color,
      onTap: onTap,
      border: isCurrentUser ? Border.all(color: colors.dirt, width: 2) : null,
      child: large
          ? Row(
              children: [
                _RankBadge(rank: row.rank, color: accent),
                const SizedBox(width: Spacing.md),
                InFormAvatar(name: row.userName, radius: 27),
                const SizedBox(width: Spacing.md),
                Expanded(child: _PlayerLabel(row: row)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _number(row.total),
                      style: styles.pageTitle.copyWith(
                        color: colors.dirt,
                        height: 1,
                      ),
                    ),
                    Text('point', style: styles.caption),
                    const SizedBox(height: Spacing.xs),
                    _Movement(row: row),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RankBadge(rank: row.rank, color: accent),
                    _Movement(row: row),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                InFormAvatar(name: row.userName, radius: 23),
                const SizedBox(height: Spacing.sm),
                Text(
                  row.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.bodyBold,
                ),
                Text(
                  inFormPositionLabel(row.position),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.caption,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  '${_number(row.total)} point',
                  style: styles.sectionHeader.copyWith(color: colors.dirt),
                ),
              ],
            ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final InFormLeaderboardRow row;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const _LeaderboardRow({
    required this.row,
    required this.isCurrentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      onTap: onTap,
      border: isCurrentUser ? Border.all(color: colors.grass, width: 2) : null,
      child: Row(
        children: [
          _RankBadge(rank: row.rank, color: colors.offWhite),
          const SizedBox(width: Spacing.md),
          InFormAvatar(name: row.userName),
          const SizedBox(width: Spacing.md),
          Expanded(child: _PlayerLabel(row: row)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_number(row.total)} point', style: styles.bodyBold),
              const SizedBox(height: Spacing.xs),
              _Movement(row: row),
            ],
          ),
          const SizedBox(width: Spacing.xs),
          Icon(Icons.chevron_right, color: colors.dirt, size: 20),
        ],
      ),
    );
  }
}

class _PlayerLabel extends StatelessWidget {
  final InFormLeaderboardRow row;

  const _PlayerLabel({required this.row});

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: styles.bodyBold,
        ),
        const SizedBox(height: 2),
        Text(
          '${inFormPositionLabel(row.position)} · Senest ${_signed(row.latestRound)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: styles.caption,
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;

  const _RankBadge({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        '#$rank',
        style: styles.caption.copyWith(
          color: colors.dirt,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Movement extends StatelessWidget {
  final InFormLeaderboardRow row;

  const _Movement({required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final rising = row.rankChange > 0;
    final falling = row.rankChange < 0;
    final color = rising
        ? colors.grass
        : falling
            ? colors.error
            : colors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          rising
              ? Icons.arrow_upward
              : falling
                  ? Icons.arrow_downward
                  : Icons.remove,
          size: 15,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          row.rankChange == 0 ? 'Stabil' : '${row.rankChange.abs()}',
          style: styles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

String _number(double value) {
  return value == value.roundToDouble()
      ? '${value.toInt()}'
      : value.toStringAsFixed(1);
}

String _points(double value) => '${_number(value)} point';

String _signed(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${_number(value)}';
}
