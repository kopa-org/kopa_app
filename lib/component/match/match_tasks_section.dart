import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_task.dart';
import 'package:kopa/repository/match_tasks_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Shows who is responsible for each match task (candy bag, laundry, ...).
/// The team leader can open a task to see the player queue and change the
/// responsible player; whoever does the task marks it as done.
class MatchTasksSection extends StatefulWidget {
  final int matchId;
  final int currentUserId;
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

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.matchTasksError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _complete(MatchTask task) => _run(
        () => MatchTasksRepository.complete(
          widget.matchId,
          task.id,
          completedByUserId: widget.currentUserId,
        ),
      );

  Future<void> _openQueue(MatchTask task) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TaskQueueSheet(
        matchId: widget.matchId,
        task: task,
        canManage: widget.canManage,
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _createTask() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.matchTasksCreate),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.matchTasksNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.matchTasksCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.matchTasksCreateConfirm),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;

    await _run(() => MatchTasksRepository.createTask(name));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    if (tasks == null || (tasks.isEmpty && !widget.canManage)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                CupertinoButton(
                  key: const ValueKey('match-tasks-create'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
                  onPressed: _isBusy ? null : _createTask,
                  child: Icon(CupertinoIcons.plus_circle, color: colors.black),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          for (final task in tasks) ...[
            _TaskRow(
              task: task,
              canManage: widget.canManage,
              // Anybody can register the work they did, even when someone
              // else was picked.
              canComplete: !_isBusy,
              onOpen: () => _openQueue(task),
              onComplete: () => _complete(task),
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final MatchTask task;
  final bool canManage;
  final bool canComplete;
  final VoidCallback onOpen;
  final VoidCallback onComplete;

  const _TaskRow({
    required this.task,
    required this.canManage,
    required this.canComplete,
    required this.onOpen,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final assignee = task.assigneeName ?? l10n.matchTasksNoAssignee;
    final subtitle = task.isCompleted && task.completedByName != null
        ? l10n.matchTasksCompletedBy(task.completedByName!)
        : task.isAutomatic
            ? l10n.matchTasksAutoSelected
            : null;

    return Material(
      color: colors.white,
      borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      child: InkWell(
        key: ValueKey('match-task-${task.id}'),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.itemGap,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name.toUpperCase(),
                      style: styles.body3.copyWith(
                        fontSize: 10,
                        color: colors.grey5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(assignee, style: styles.bodyBold),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: styles.body3.copyWith(
                          fontSize: 11,
                          color: colors.successForeground,
                        ),
                      ),
                  ],
                ),
              ),
              if (task.isCompleted)
                Icon(CupertinoIcons.checkmark_circle_fill,
                    color: colors.successForeground)
              else if (task.assigneeId != null)
                OutlinedButton(
                  key: ValueKey('match-task-done-${task.id}'),
                  onPressed: canComplete ? onComplete : null,
                  child: Text(l10n.matchTasksMarkDone),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskQueueSheet extends StatefulWidget {
  final int matchId;
  final MatchTask task;
  final bool canManage;

  const _TaskQueueSheet({
    required this.matchId,
    required this.task,
    required this.canManage,
  });

  @override
  State<_TaskQueueSheet> createState() => _TaskQueueSheetState();
}

class _TaskQueueSheetState extends State<_TaskQueueSheet> {
  List<TaskQueuePlayer>? _players;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final players = await MatchTasksRepository.getQueue(
        widget.matchId,
        widget.task.id,
      );
      if (mounted) setState(() => _players = players);
    } catch (_) {
      if (mounted) setState(() => _players ??= const []);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.matchTasksError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.matchTasksResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.matchTasksCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.matchTasksReset),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _run(() => MatchTasksRepository.resetQueue(widget.task.id));
  }

  Future<void> _delete() async {
    await _run(() => MatchTasksRepository.deleteTask(widget.task.id));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final players = _players;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.md, Spacing.md, Spacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.name.toUpperCase(),
                          style: styles.body3
                              .copyWith(fontSize: 10, color: colors.grey5),
                        ),
                        Text(l10n.matchTasksQueueTitle, style: styles.h5),
                      ],
                    ),
                  ),
                  if (widget.canManage) ...[
                    OutlinedButton.icon(
                      key: const ValueKey('match-task-queue-reset'),
                      onPressed: _isBusy ? null : _reset,
                      icon: const Icon(CupertinoIcons.arrow_counterclockwise,
                          size: 16),
                      label: Text(l10n.matchTasksReset),
                    ),
                    IconButton(
                      key: const ValueKey('match-task-delete'),
                      tooltip: l10n.matchTasksDelete,
                      onPressed: _isBusy ? null : _delete,
                      icon: const Icon(CupertinoIcons.delete),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.matchTasksQueuePlayer, style: styles.body3),
                  Text(l10n.matchTasksQueueSelected, style: styles.body3),
                ],
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Expanded(
              child: players == null
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                          Spacing.md, 0, Spacing.md, Spacing.lg),
                      itemCount: players.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Spacing.xs + 2),
                      itemBuilder: (context, index) => _QueueRow(
                        player: players[index],
                        enabled: widget.canManage && !_isBusy,
                        onTap: () => _run(() => MatchTasksRepository.assign(
                              widget.matchId,
                              widget.task.id,
                              players[index].userId,
                            )),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final TaskQueuePlayer player;
  final bool enabled;
  final VoidCallback onTap;

  const _QueueRow({
    required this.player,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    // "Automatisk valgt" only applies while the leader has not overridden it.
    final label = player.isAssigned
        ? (player.isAutoSelected
            ? l10n.matchTasksAutoSelected
            : l10n.matchTasksChosenByLeader)
        : !player.isSelected
            ? l10n.matchTasksNotSelected
            : null;

    return Material(
      color: player.isAssigned
          ? colors.successSurface
          : colors.grey4.withValues(alpha: 0.12),
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
              SizedBox(
                width: 28,
                child: Text('${player.position}.', style: styles.body3),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name, style: styles.bodyBold),
                    if (label != null)
                      Text(
                        label,
                        style: styles.body3.copyWith(
                          fontSize: 10,
                          color: player.isAssigned
                              ? colors.successForeground
                              : colors.grey5,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                player.isSelected
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                color: player.isSelected ? colors.black : colors.grey4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
