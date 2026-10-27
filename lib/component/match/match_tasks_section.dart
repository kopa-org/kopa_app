import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/match/task_name_dialog.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_task.dart';
import 'package:kopa/page/team/team_tasks_page.dart';
import 'package:kopa/repository/match_tasks_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Who is responsible for each task at this match (beer, laundry, ...).
///
/// Recurring tasks come from the team settings and rotate through a queue;
/// one-off tasks only belong to this match. The team leader is not always at
/// the match, so anybody on the team can add one-off tasks, change who is
/// responsible and tick tasks off. Only setting up the recurring tasks is
/// left to the leader.
class MatchTasksSection extends StatefulWidget {
  final int matchId;
  final int currentUserId;

  /// Whether the user can set up the team's recurring tasks.
  final bool canManage;

  const MatchTasksSection({
    super.key,
    required this.matchId,
    required this.currentUserId,
    required this.canManage,
  });

  @override
  State<MatchTasksSection> createState() => _MatchTasksSectionState();
}

class _MatchTasksSectionState extends State<MatchTasksSection> {
  List<MatchTask>? _tasks;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tasks = await MatchTasksRepository.getMatchTasks(widget.matchId);
      if (mounted) setState(() => _tasks = tasks);
    } catch (_) {
      if (mounted) setState(() => _tasks ??= const []);
    }
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_isBusy) return false;
    setState(() => _isBusy = true);
    try {
      await action();
      await _load();
      return true;
    } catch (_) {
      if (mounted) _showError(context);
      return false;
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// [asCurrentUser] registers the current user as the one who did it;
  /// otherwise the responsible player gets the credit.
  Future<void> _complete(MatchTask task, {required bool asCurrentUser}) async {
    final l10n = AppLocalizations.of(context)!;
    final doer = asCurrentUser || widget.currentUserId == task.assigneeId
        ? null
        : task.assigneeName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.matchTasksConfirmTitle(task.name)),
        content: doer == null
            ? null
            : Text(
                task.isRecurring
                    ? l10n.matchTasksConfirmRecurring(doer)
                    : l10n.matchTasksConfirmOneOff(doer),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.matchTasksCancel),
          ),
          FilledButton(
            key: const ValueKey('match-task-confirm-done'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.matchTasksMarkDone),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _run(() => MatchTasksRepository.complete(
          widget.matchId,
          task.id,
          completedByUserId: asCurrentUser ? widget.currentUserId : null,
        ));
  }

  Future<void> _openTask(MatchTask task) async {
    final action = await showModalBottomSheet<_TaskSheetResult>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TaskSheet(
        matchId: widget.matchId,
        task: task,
        isMine: task.assigneeId == widget.currentUserId,
      ),
    );
    if (!mounted) return;

    switch (action) {
      case _TaskSheetResult.completedByMe:
        await _complete(task, asCurrentUser: true);
      case _TaskSheetResult.changed:
      case null:
        await _load();
    }
  }

  Future<void> _addOneOff() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await TaskNameDialog.show(
      context,
      title: l10n.matchTasksAddOneOff,
      confirmLabel: l10n.matchTasksCreateConfirm,
      hint: l10n.matchTasksOneOffNameHint,
    );
    if (name == null || !mounted) return;

    int? taskId;
    final created = await _run(() async {
      taskId = await MatchTasksRepository.createMatchTask(widget.matchId, name);
    });
    if (!created || !mounted) return;

    // Straight on to picking who does it, so the task never sits unassigned
    // by accident.
    final task = _tasks?.where((t) => t.id == taskId).firstOrNull;
    if (task != null) await _openTask(task);
  }

  Future<void> _openTeamTasks() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TeamTasksPage()),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    if (tasks == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      key: const ValueKey('match-tasks-section'),
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.matchTasksTitle,
                  style: styles.h5.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (widget.canManage)
                TextButton.icon(
                  key: const ValueKey('match-tasks-manage'),
                  onPressed: _openTeamTasks,
                  icon:
                      const Icon(CupertinoIcons.slider_horizontal_3, size: 16),
                  label: Text(l10n.matchTasksManage),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(Spacing.borderRadius),
              border: Border.all(color: colors.grey4.withValues(alpha: 0.25)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Text(
                      widget.canManage
                          ? l10n.matchTasksEmptyLeader
                          : l10n.matchTasksEmptyPlayer,
                      style: styles.body3.copyWith(color: colors.grey5),
                    ),
                  ),
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0) _divider(colors),
                  _TaskRow(
                    task: tasks[i],
                    isBusy: _isBusy,
                    onOpen: () => _openTask(tasks[i]),
                    // Whoever ticks it off, the responsible player gets the
                    // credit; "Jeg har gjort det" in the sheet is for taking
                    // it over.
                    onComplete: () => _complete(tasks[i], asCurrentUser: false),
                  ),
                ],
                if (tasks.isNotEmpty) _divider(colors),
                InkWell(
                  key: const ValueKey('match-tasks-add-one-off'),
                  onTap: _isBusy ? null : _addOneOff,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.itemGap + 2,
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.plus,
                            size: 18, color: colors.successForeground),
                        const SizedBox(width: Spacing.itemGap),
                        Text(
                          l10n.matchTasksAddOneOff,
                          style: styles.bodyBold.copyWith(
                            color: colors.successForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(AppColors colors) => Divider(
        height: 1,
        thickness: 1,
        indent: Spacing.md,
        endIndent: Spacing.md,
        color: colors.grey4.withValues(alpha: 0.2),
      );
}

void _showError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.matchTasksError)),
  );
}

class _TaskRow extends StatelessWidget {
  final MatchTask task;
  final bool isBusy;
  final VoidCallback onOpen;
  final VoidCallback onComplete;

  const _TaskRow({
    required this.task,
    required this.isBusy,
    required this.onOpen,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final hasAssignee = task.assigneeName != null;
    final canTickOff = !task.isCompleted && hasAssignee;

    String? detail;
    var detailColor = colors.grey5;
    if (task.isCompleted) {
      if (task.completedByName != null) {
        detail = l10n.matchTasksCompletedBy(task.completedByName!);
        detailColor = colors.successForeground;
      }
    } else if (task.isRecurring && task.upNext.isNotEmpty) {
      detail = l10n.matchTasksUpNext(
        task.upNext.map((player) => _firstName(player.name)).join(', '),
      );
    }

    final tag = !task.isRecurring
        ? l10n.matchTasksOneOffBadge
        : !hasAssignee
            ? null
            : task.isAutomatic
                ? l10n.matchTasksNextInLine
                : l10n.matchTasksChosenByLeader;

    return InkWell(
      key: ValueKey('match-task-${task.id}'),
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.itemGap,
        ),
        child: Row(
          children: [
            _TaskIcon(task: task),
            const SizedBox(width: Spacing.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          task.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.body3.copyWith(color: colors.grey5),
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: Spacing.xs + 2),
                        _Tag(label: tag),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.assigneeName ?? l10n.matchTasksNoAssignee,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.bodyBold.copyWith(
                      color: hasAssignee ? colors.textPrimary : colors.grey5,
                    ),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.body3.copyWith(
                        fontSize: 11,
                        color: detailColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            _DoneCheckbox(
              key: ValueKey('match-task-done-${task.id}'),
              checked: task.isCompleted,
              label: l10n.matchTasksMarkDone,
              onTap: canTickOff && !isBusy ? onComplete : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Round checkbox that ticks a task off. A completed task stays ticked, since
/// completing it already moved the queue.
class _DoneCheckbox extends StatelessWidget {
  final bool checked;
  final String label;
  final VoidCallback? onTap;

  const _DoneCheckbox({
    super.key,
    required this.checked,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final enabled = onTap != null;

    return Semantics(
      checked: checked,
      enabled: enabled,
      label: label,
      child: InkResponse(
        onTap: checked ? null : onTap,
        radius: 22,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? colors.grass : AppColors.transparent,
                border: Border.all(
                  width: 2,
                  color: checked
                      ? colors.grass
                      : enabled
                          ? colors.grey5
                          : colors.grey4.withValues(alpha: 0.5),
                ),
              ),
              child: checked
                  ? Icon(CupertinoIcons.checkmark,
                      size: 15, color: colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskIcon extends StatelessWidget {
  final MatchTask task;

  const _TaskIcon({required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: task.isRecurring
            ? colors.grey4.withValues(alpha: 0.12)
            : colors.infoSurface,
        shape: BoxShape.circle,
      ),
      child: Icon(
        task.isRecurring
            ? CupertinoIcons.arrow_2_circlepath
            : CupertinoIcons.flag,
        size: 17,
        color: task.isRecurring ? colors.textSecondary : colors.infoForeground,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? background;

  const _Tag({required this.label, this.color, this.background});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: background ?? colors.grey4.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Text(
        label,
        style: styles.body3.copyWith(
          fontSize: 10,
          height: 14 / 10,
          fontWeight: FontWeight.w700,
          color: color ?? colors.textSecondary,
        ),
      ),
    );
  }
}

String _firstName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts.isEmpty || parts.first.isEmpty ? name : parts.first;
}

enum _TaskSheetResult { changed, completedByMe }

/// Details of one task at this match: who is responsible and, for recurring
/// tasks, the queue. Tap a player to hand them the task.
class _TaskSheet extends StatefulWidget {
  final int matchId;
  final MatchTask task;
  final bool isMine;

  const _TaskSheet({
    required this.matchId,
    required this.task,
    required this.isMine,
  });

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  List<TaskQueuePlayer>? _players;
  bool _isBusy = false;
  bool _changed = false;

  MatchTask get _task => widget.task;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final players =
          await MatchTasksRepository.getQueue(widget.matchId, _task.id);
      if (mounted) setState(() => _players = players);
    } catch (_) {
      if (mounted) setState(() => _players ??= const []);
    }
  }

  Future<void> _assign(TaskQueuePlayer player) async {
    if (_isBusy || player.isAssigned) return;
    setState(() => _isBusy = true);
    try {
      await MatchTasksRepository.assign(
          widget.matchId, _task.id, player.userId);
      _changed = true;
      await _load();
    } catch (_) {
      if (mounted) _showError(context);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteOneOff() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.matchTasksDeleteOneOffConfirm(_task.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.matchTasksCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.matchTasksDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await MatchTasksRepository.deleteTask(_task.id);
      if (mounted) Navigator.of(context).pop(_TaskSheetResult.changed);
    } catch (_) {
      if (mounted) {
        _showError(context);
        setState(() => _isBusy = false);
      }
    }
  }

  void _close([_TaskSheetResult? result]) {
    Navigator.of(context)
        .pop(result ?? (_changed ? _TaskSheetResult.changed : null));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final players = _players;
    final canPick = !_task.isCompleted;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.grey4.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.md, Spacing.md, Spacing.sm, Spacing.xs),
                child: Row(
                  children: [
                    _TaskIcon(task: _task),
                    const SizedBox(width: Spacing.itemGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_task.name, style: styles.h5),
                          Text(
                            _task.isRecurring
                                ? l10n.matchTasksQueueTitle
                                : l10n.matchTasksOneOffBadge,
                            style: styles.body3.copyWith(color: colors.grey5),
                          ),
                        ],
                      ),
                    ),
                    if (!_task.isRecurring)
                      IconButton(
                        key: const ValueKey('match-task-delete'),
                        tooltip: l10n.matchTasksDelete,
                        onPressed: _isBusy ? null : _deleteOneOff,
                        icon: Icon(CupertinoIcons.delete,
                            color: colors.errorForeground),
                      ),
                    IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => _close(),
                      icon: const Icon(CupertinoIcons.xmark),
                    ),
                  ],
                ),
              ),
              if (canPick)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.md, Spacing.xs, Spacing.md, Spacing.sm),
                  child: Text(
                    l10n.matchTasksChangeResponsible,
                    style: styles.body3.copyWith(color: colors.grey5),
                  ),
                ),
              Expanded(
                child: players == null
                    ? const Center(child: CupertinoActivityIndicator())
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.md, Spacing.xs, Spacing.md, Spacing.lg),
                        itemCount: players.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: Spacing.xs + 2),
                        itemBuilder: (context, index) => _PlayerRow(
                          player: players[index],
                          showPosition: _task.isRecurring,
                          enabled: canPick && !_isBusy,
                          onTap: () => _assign(players[index]),
                        ),
                      ),
              ),
              if (!_task.isCompleted && !widget.isMine)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Spacing.md, Spacing.sm, Spacing.md, Spacing.md),
                    child: OutlinedButton.icon(
                      key: const ValueKey('match-task-i-did-it'),
                      onPressed: _isBusy
                          ? null
                          : () => _close(_TaskSheetResult.completedByMe),
                      icon: const Icon(CupertinoIcons.hand_thumbsup, size: 18),
                      label: Text(l10n.matchTasksIDidIt),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.grey4),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Spacing.borderRadiusMedium),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final TaskQueuePlayer player;
  final bool showPosition;
  final bool enabled;
  final VoidCallback onTap;

  const _PlayerRow({
    required this.player,
    required this.showPosition,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: player.isAssigned ? colors.successSurface : colors.white,
      borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      child: InkWell(
        key: ValueKey('task-queue-player-${player.userId}'),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.itemGap, vertical: Spacing.itemGap),
          child: Row(
            children: [
              if (showPosition && player.position != null)
                SizedBox(
                  width: 28,
                  child: Text(
                    '${player.position}.',
                    style: styles.body3.copyWith(color: colors.grey5),
                  ),
                ),
              Expanded(
                child: Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.bodyBold.copyWith(
                    color:
                        player.isSelected ? colors.textPrimary : colors.grey5,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              _Tag(
                label: player.isSelected
                    ? l10n.matchTasksSelectedTag
                    : l10n.matchTasksNotSelected,
                color: player.isSelected
                    ? colors.successForeground
                    : colors.textSecondary,
                background: player.isSelected
                    ? colors.successSurface
                    : colors.grey4.withValues(alpha: 0.14),
              ),
              if (player.isAssigned) ...[
                const SizedBox(width: Spacing.sm),
                Icon(CupertinoIcons.checkmark_circle_fill,
                    size: 20, color: colors.successForeground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
