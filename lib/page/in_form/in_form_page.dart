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
                      sliver: SliverToBoxAdapter(
                        child: _LeaderboardList(
                          rows: rows.skip(3).toList(),
                          currentUserId: widget.currentUserId,
                          onPlayerTap: _openPlayer,
                        ),
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

    return InFormPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _PodiumRow(
              row: rows[index],
              accent: switch (index) {
                0 => colors.grass,
                1 => colors.sky,
                _ => colors.sunset,
              },
              leader: index == 0,
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

class _PodiumRow extends StatelessWidget {
  final InFormLeaderboardRow row;
  final Color accent;
  final bool leader;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const _PodiumRow({
    required this.row,
    required this.accent,
    required this.leader,
    required this.isCurrentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: leader ? colors.lightGrass.withValues(alpha: .36) : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCurrentUser ? Spacing.md - 3 : Spacing.md,
          vertical: leader ? 14 : 11,
        ),
        child: Row(
          children: [
            _RankBadge(
              rank: row.rank,
              color: leader ? accent : accent.withValues(alpha: .14),
              foregroundColor: leader ? Colors.white : accent,
              size: leader ? 34 : 30,
            ),
            const SizedBox(width: 12),
            InFormAvatar(
              name: row.userName,
              radius: leader ? 22 : 19,
              backgroundColor: leader ? colors.surface : colors.offWhite,
              foregroundColor: accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                row.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.bodyBold.copyWith(
                  fontSize: leader ? 17 : 15,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              _number(row.total),
              style: (leader ? styles.sectionHeader : styles.bodyBold).copyWith(
                color: colors.dirt,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              'pt',
              style: styles.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<InFormLeaderboardRow> rows;
  final int? currentUserId;
  final ValueChanged<InFormLeaderboardRow> onPlayerTap;

  const _LeaderboardList({
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
          for (var index = 0; index < rows.length; index++) ...[
            _LeaderboardRow(
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

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isCurrentUser ? colors.lightGrass.withValues(alpha: .18) : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCurrentUser ? Spacing.md - 3 : Spacing.md,
          vertical: 11,
        ),
        child: Row(
          children: [
            _RankBadge(
              rank: row.rank,
              color: colors.offWhite,
              size: 30,
            ),
            const SizedBox(width: 12),
            InFormAvatar(name: row.userName, radius: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                row.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.bodyBold.copyWith(fontSize: 15),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              _number(row.total),
              style: styles.bodyBold.copyWith(
                color: colors.dirt,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              'pt',
              style: styles.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 18),
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

String _number(double value) {
  return value == value.roundToDouble()
      ? '${value.toInt()}'
      : value.toStringAsFixed(1);
}

String _points(double value) => '${_number(value)} point';
