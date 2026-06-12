import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/repository/in_form_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class InFormMatchEditorPage extends StatefulWidget {
  final int eventId;

  const InFormMatchEditorPage({super.key, required this.eventId});

  @override
  State<InFormMatchEditorPage> createState() => _InFormMatchEditorPageState();
}

class _InFormMatchEditorPageState extends State<InFormMatchEditorPage> {
  InFormMatchRecord? _record;
  List<InFormPerformance> _performances = const [];
  Map<int, UserDetails> _users = const {};
  Object? _error;
  bool _saving = false;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        InFormRepository.getMatchRecord(widget.eventId),
        UsersRepository.getSquad(),
      ]);
      final record = results[0] as InFormMatchRecord;
      final users = results[1] as List<UserDetails>;
      final usersById = {for (final user in users) user.id: user};
      final performancesByUser = <int, InFormPerformance>{};

      for (final performance in record.performances) {
        final existing = performancesByUser[performance.userId];
        if (existing == null ||
            (existing.position == null && performance.position != null)) {
          performancesByUser[performance.userId] = performance.copyWith(
            position:
                usersById[performance.userId]?.position ?? performance.position,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _record = record;
        _performances = performancesByUser.values.toList();
        _users = usersById;
        _cancelled = record.cancelled;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Registrer In-form',
      showBackButton: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: InFormPanel(
            color: colors.lightSky,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InFormMascot(
                  asset: 'assets/illustrations/kopa_heart.svg',
                  size: 68,
                  color: colors.dirt,
                ),
                const SizedBox(height: Spacing.md),
                const Text('Kunne ikke hente kampdata.'),
                const SizedBox(height: Spacing.sm),
                TextButton(onPressed: _load, child: const Text('Prøv igen')),
              ],
            ),
          ),
        ),
      );
    }
    if (_record == null) {
      return Center(child: CircularProgressIndicator(color: colors.grass));
    }

    final played = _performances.where((item) => item.played).length;
    final goals =
        _performances.fold<int>(0, (total, item) => total + item.goals);
    final assists =
        _performances.fold<int>(0, (total, item) => total + item.assists);

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EditorHero(record: _record!),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    InFormMetric(
                      label: 'Spillere',
                      value: '$played',
                      color: colors.lightGrass,
                      icon: Icons.groups_outlined,
                    ),
                    const SizedBox(width: Spacing.sm),
                    InFormMetric(
                      label: 'Mål',
                      value: '$goals',
                      color: colors.sunset.withValues(alpha: .3),
                      icon: Icons.sports_soccer,
                    ),
                    const SizedBox(width: Spacing.sm),
                    InFormMetric(
                      label: 'Assists',
                      value: '$assists',
                      color: colors.lightSky,
                      icon: Icons.handshake_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _CancelledControl(
                  value: _cancelled,
                  onChanged: (value) => setState(() => _cancelled = value),
                ),
                const SizedBox(height: Spacing.lg),
                const InFormSectionTitle(title: 'Spillerkort'),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Vælg deltagere og fold kortene ud for at registrere bidrag.',
                  style: (Theme.of(context).extension<AppTextStyles>() ??
                          AppTextStyles.light)
                      .caption,
                ),
                const SizedBox(height: Spacing.md),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          sliver: SliverList.builder(
            itemCount: _performances.length,
            itemBuilder: (context, index) {
              final performance = _performances[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: _PerformanceCard(
                  key: ValueKey(performance.userId),
                  performance: performance,
                  playerName:
                      _users[performance.userId]?.name ?? 'Ukendt spiller',
                  onChanged: (updatedPerformance) {
                    setState(() {
                      final updated =
                          List<InFormPerformance>.from(_performances);
                      updated[index] = updatedPerformance;
                      _performances = updated;
                    });
                  },
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.md,
            Spacing.xxl,
          ),
          sliver: SliverToBoxAdapter(
            child: Button(
              buttonText: _saving ? 'Gemmer...' : 'Gem kampdata',
              icon: Icons.check,
              width: double.infinity,
              enabled: !_saving,
              onPressed: _save,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await InFormRepository.updateMatchRecord(
        record: _record!,
        performances: _performances,
        cancelled: _cancelled,
      );
      if (!mounted) return;
      setState(() => _record = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('In-form data er gemt.')),
      );
    } on InFormConflictException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En anden har ændret kampen. Data genindlæses.'),
        ),
      );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kunne ikke gemme In-form data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _EditorHero extends StatelessWidget {
  final InFormMatchRecord record;

  const _EditorHero({required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final editor = record.editedByName;

    return InFormPanel(
      color: colors.surface,
      border: Border.all(color: colors.grass, width: 2),
      padding: const EdgeInsets.all(Spacing.lg),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: 2,
            child: InFormMascot(
              asset: 'assets/illustrations/kopa_flag.svg',
              size: 90,
              color: colors.grass,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InFormEyebrow(
                  label: 'Kampens scorekort',
                  color: colors.lightGrass,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Registrer det,\nder skete',
                  style: styles.pageTitle.copyWith(
                    color: colors.dirt,
                    fontSize: 32,
                    height: 1,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  editor == null
                      ? 'Alle på holdet kan redigere.'
                      : 'Version ${record.version} · senest gemt af $editor',
                  style: styles.caption.copyWith(
                    color: colors.textSecondary,
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

class _CancelledControl extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CancelledControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      color: value ? colors.error.withValues(alpha: .1) : colors.surface,
      border: value ? Border.all(color: colors.error, width: 2) : null,
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  value ? colors.error.withValues(alpha: .14) : colors.offWhite,
              shape: BoxShape.circle,
            ),
            child: Icon(
              value ? Icons.event_busy : Icons.event_available,
              color: value ? colors.error : colors.grass,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kampen blev aflyst', style: styles.bodyBold),
                const SizedBox(height: 2),
                Text(
                  'Aflyste kampe påvirker ikke streaks.',
                  style: styles.caption,
                ),
              ],
            ),
          ),
          _BrandSwitch(value: value),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatefulWidget {
  final InFormPerformance performance;
  final String playerName;
  final ValueChanged<InFormPerformance> onChanged;

  const _PerformanceCard({
    super.key,
    required this.performance,
    required this.playerName,
    required this.onChanged,
  });

  @override
  State<_PerformanceCard> createState() => _PerformanceCardState();
}

class _PerformanceCardState extends State<_PerformanceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final performance = widget.performance;

    return InFormPanel(
      color: colors.surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  InFormAvatar(name: widget.playerName),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.playerName, style: styles.bodyBold),
                        const SizedBox(height: 2),
                        Text(
                          performance.position == null
                              ? 'Position ikke valgt'
                              : inFormPositionLabel(performance.position),
                          style: styles.caption,
                        ),
                      ],
                    ),
                  ),
                  _AttendanceButton(
                    value: performance.played,
                    onTap: () => widget.onChanged(
                      performance.copyWith(played: !performance.played),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  AnimatedRotation(
                    turns: _expanded ? .5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.dirt,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.topCenter,
              child: _expanded
                  ? _PerformanceDetails(
                      performance: performance,
                      onChanged: widget.onChanged,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceDetails extends StatelessWidget {
  final InFormPerformance performance;
  final ValueChanged<InFormPerformance> onChanged;

  const _PerformanceDetails({
    required this.performance,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colors.dirt.withValues(alpha: .15)),
          const SizedBox(height: Spacing.sm),
          const InFormSectionTitle(title: 'Rolle'),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              _BooleanControl(
                label: 'Hele kampen',
                icon: Icons.timer_outlined,
                value: performance.fullMatch,
                onTap: () => onChanged(
                  performance.copyWith(fullMatch: !performance.fullMatch),
                ),
              ),
              _BooleanControl(
                label: 'Kaptajn',
                icon: Icons.shield_outlined,
                value: performance.captain,
                onTap: () => onChanged(
                  performance.copyWith(captain: !performance.captain),
                ),
              ),
              _BooleanControl(
                label: 'Udtaget',
                icon: Icons.how_to_reg_outlined,
                value: performance.expected,
                onTap: () => onChanged(
                  performance.copyWith(expected: !performance.expected),
                ),
              ),
              _BooleanControl(
                label: 'Gyldigt fravær',
                icon: Icons.event_available_outlined,
                value: performance.excusedAbsence,
                onTap: () => onChanged(
                  performance.copyWith(
                    excusedAbsence: !performance.excusedAbsence,
                  ),
                ),
              ),
              _BooleanControl(
                label: 'Kampens spiller',
                icon: Icons.star_outline,
                value: performance.motm,
                onTap: () => onChanged(
                  performance.copyWith(motm: !performance.motm),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          const InFormSectionTitle(title: 'Mål & assists'),
          const SizedBox(height: Spacing.sm),
          _CounterGrid(
            items: [
              _CounterData(
                'Mål',
                performance.goals,
                colors.lightGrass,
                (value) => onChanged(performance.copyWith(goals: value)),
              ),
              _CounterData(
                'Assists',
                performance.assists,
                colors.lightSky,
                (value) => onChanged(performance.copyWith(assists: value)),
              ),
              _CounterData(
                'Afgørende mål',
                performance.decisiveGoals,
                colors.sunset.withValues(alpha: .3),
                (value) =>
                    onChanged(performance.copyWith(decisiveGoals: value)),
              ),
              _CounterData(
                'Dødboldsmål',
                performance.setPieceGoals,
                colors.sun.withValues(alpha: .45),
                (value) =>
                    onChanged(performance.copyWith(setPieceGoals: value)),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          const InFormSectionTitle(title: 'Disciplin & special'),
          const SizedBox(height: Spacing.sm),
          _CounterGrid(
            items: [
              _CounterData(
                'Gule kort',
                performance.yellowCards,
                colors.sun.withValues(alpha: .45),
                (value) => onChanged(performance.copyWith(yellowCards: value)),
              ),
              _CounterData(
                'Andet gule',
                performance.secondYellowCards,
                colors.sunset.withValues(alpha: .3),
                (value) =>
                    onChanged(performance.copyWith(secondYellowCards: value)),
              ),
              _CounterData(
                'Direkte røde',
                performance.redCards,
                colors.error.withValues(alpha: .12),
                (value) => onChanged(performance.copyWith(redCards: value)),
              ),
              _CounterData(
                'Selvmål',
                performance.ownGoals,
                colors.error.withValues(alpha: .12),
                (value) => onChanged(performance.copyWith(ownGoals: value)),
              ),
              _CounterData(
                'Brændte straffe',
                performance.penaltiesMissed,
                colors.error.withValues(alpha: .12),
                (value) =>
                    onChanged(performance.copyWith(penaltiesMissed: value)),
              ),
              _CounterData(
                'Reddede straffe',
                performance.penaltiesSaved,
                colors.lightSky,
                (value) =>
                    onChanged(performance.copyWith(penaltiesSaved: value)),
              ),
              _CounterData(
                'MOTM-stemmer',
                performance.motmVotes,
                colors.lightGrass,
                (value) => onChanged(performance.copyWith(motmVotes: value)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const _AttendanceButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Material(
      color: value ? colors.grass : colors.offWhite,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value ? Icons.check : Icons.add,
                size: 15,
                color: value ? Colors.white : colors.dirt,
              ),
              const SizedBox(width: 4),
              Text(
                value ? 'Deltog' : 'Tilføj',
                style: styles.caption.copyWith(
                  color: value ? Colors.white : colors.dirt,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BooleanControl extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final VoidCallback onTap;

  const _BooleanControl({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: value ? colors.dirt : colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: value ? null : Border.all(color: colors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value ? Icons.check : icon,
                size: 16,
                color: value ? colors.lightGrass : colors.dirt,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: styles.caption.copyWith(
                  color: value ? Colors.white : colors.dirt,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterGrid extends StatelessWidget {
  final List<_CounterData> items;

  const _CounterGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - Spacing.sm) / 2;
        return Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _CounterTile(data: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CounterData {
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _CounterData(this.label, this.value, this.color, this.onChanged);
}

class _CounterTile extends StatelessWidget {
  final _CounterData data;

  const _CounterTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.caption.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CounterButton(
                icon: Icons.remove,
                enabled: data.value > 0,
                onTap: () => data.onChanged(data.value - 1),
              ),
              Text(
                '${data.value}',
                style: styles.sectionHeader.copyWith(
                  color: colors.dirt,
                  height: 1,
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                onTap: () => data.onChanged(data.value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Material(
      color: enabled ? colors.dirt : colors.dirt.withValues(alpha: .12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 16,
            color: enabled ? Colors.white : colors.dirt.withValues(alpha: .35),
          ),
        ),
      ),
    );
  }
}

class _BrandSwitch extends StatelessWidget {
  final bool value;

  const _BrandSwitch({required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? colors.error : colors.divider,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
