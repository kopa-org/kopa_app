import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/match/task_name_dialog.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_task.dart';
import 'package:kopa/repository/match_tasks_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Team settings for recurring match tasks (beer, laundry, ...): create them
/// and see who is next in each task's queue.
class TeamTasksPage extends StatefulWidget {
  const TeamTasksPage({super.key});

  @override
  State<TeamTasksPage> createState() => _TeamTasksPageState();
}

class _TeamTasksPageState extends State<TeamTasksPage> {
  List<TeamTask>? _tasks;
  bool _hasError = false;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tasks = await MatchTasksRepository.getTeamTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _hasError = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await TaskNameDialog.show(
      context,
      title: l10n.teamTasksCreate,
      confirmLabel: l10n.matchTasksCreateConfirm,
      hint: l10n.teamTasksNameHint,
    );
    if (name == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await MatchTasksRepository.createTask(name);
      await _load();
    } catch (_) {
      if (mounted) _showError(context);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _open(TeamTask task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TeamTaskQueuePage(task: task)),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final tasks = _tasks;

    return PageScaffold(
      title: l10n.teamTasksTitle,
      showBackButton: true,
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('team-tasks-create'),
        heroTag: 'team-tasks-create',
        tooltip: l10n.teamTasksCreate,
        backgroundColor: AppColors.matchDetailsHeader,
        foregroundColor: colors.white,
        onPressed: _isBusy ? null : _create,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: colors.grass,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              Spacing.md, Spacing.md, Spacing.md, 120),
          children: [
            Text(
              l10n.teamTasksIntro,
              style: styles.body3.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: Spacing.lg),
            if (tasks == null && !_hasError)
              const Padding(
                padding: EdgeInsets.only(top: Spacing.xl),
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (tasks == null)
              Text(l10n.matchTasksError, style: styles.body3)
            else if (tasks.isEmpty)
              _EmptyState(onCreate: _isBusy ? null : _create)
            else
              for (final task in tasks) ...[
                _TeamTaskCard(task: task, onTap: () => _open(task)),
                const SizedBox(height: Spacing.itemGap),
              ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.arrow_2_circlepath,
              size: 32, color: colors.grey4),
          const SizedBox(height: Spacing.itemGap),
          Text(
            l10n.teamTasksEmpty,
            textAlign: TextAlign.center,
            style: styles.body3.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: Spacing.md),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(CupertinoIcons.plus, size: 18),
            label: Text(l10n.teamTasksCreate),
            style: FilledButton.styleFrom(
              backgroundColor: colors.grass,
              foregroundColor: colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamTaskCard extends StatelessWidget {
  final TeamTask task;
  final VoidCallback onTap;

  const _TeamTaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final upNext = task.queue.take(3).toList();

    return Material(
      color: colors.white,
      borderRadius: BorderRadius.circular(Spacing.borderRadius),
      child: InkWell(
        key: ValueKey('team-task-${task.id}'),
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.name, style: styles.bodyBold),
                        Text(
                          l10n.teamTasksPlayers(task.queue.length),
                          style: styles.body3.copyWith(
                            fontSize: 11,
                            color: colors.grey5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right,
                      size: 16, color: colors.grey4),
                ],
              ),
              if (upNext.isNotEmpty) ...[
                const SizedBox(height: Spacing.itemGap),
                Text(
                  l10n.matchTasksNextInLine.toUpperCase(),
                  style: styles.body3.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.grey5,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                for (var i = 0; i < upNext.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            '${i + 1}.',
                            style: styles.body3.copyWith(color: colors.grey5),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            upNext[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: i == 0
                                ? styles.bodyBold
                                : styles.body3
                                    .copyWith(color: colors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The full queue of one recurring task. Drag to reorder; rename, reset or
/// delete from the menu.
class TeamTaskQueuePage extends StatefulWidget {
  final TeamTask task;

  const TeamTaskQueuePage({super.key, required this.task});

  @override
  State<TeamTaskQueuePage> createState() => _TeamTaskQueuePageState();
}

enum _QueueMenuAction { rename, reset, delete }

class _TeamTaskQueuePageState extends State<TeamTaskQueuePage> {
  late String _name = widget.task.name;
  late List<TaskPlayer> _queue = List.of(widget.task.queue);
  bool _isBusy = false;

  Future<void> _reload() async {
    final tasks = await MatchTasksRepository.getTeamTasks();
    final task = tasks.where((t) => t.id == widget.task.id).firstOrNull;
    if (task != null && mounted) {
      setState(() {
        _name = task.name;
        _queue = List.of(task.queue);
      });
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final previous = List.of(_queue);
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      _queue.insert(newIndex, _queue.removeAt(oldIndex));
    });

    try {
      await MatchTasksRepository.reorderQueue(
        widget.task.id,
        _queue.map((player) => player.id).toList(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _queue = previous);
      _showError(context);
    }
  }

  Future<void> _onMenu(_QueueMenuAction action) async {
    switch (action) {
      case _QueueMenuAction.rename:
        await _rename();
      case _QueueMenuAction.reset:
        await _reset();
      case _QueueMenuAction.delete:
        await _delete();
    }
  }

  Future<void> _rename() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await TaskNameDialog.show(
      context,
      title: l10n.teamTasksRename,
      confirmLabel: l10n.matchTasksSave,
      initialName: _name,
    );
    if (name == null || name == _name) return;

    await _busy(() async {
      await MatchTasksRepository.renameTask(widget.task.id, name);
      if (mounted) setState(() => _name = name);
    });
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      l10n.matchTasksResetConfirm,
      l10n.matchTasksReset,
    );
    if (!confirmed) return;

    await _busy(() async {
      await MatchTasksRepository.resetQueue(widget.task.id);
      await _reload();
    });
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      l10n.matchTasksDeleteConfirm(_name),
      l10n.matchTasksDelete,
      destructive: true,
    );
    if (!confirmed) return;

    await _busy(() async {
      await MatchTasksRepository.deleteTask(widget.task.id);
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<bool> _confirm(
    String message,
    String action, {
    bool destructive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.matchTasksCancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: colors.error)
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _busy(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) _showError(context);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: _name,
      showBackButton: true,
      backgroundColor: colors.background,
      trailing: [
        PopupMenuButton<_QueueMenuAction>(
          key: const ValueKey('team-task-menu'),
          enabled: !_isBusy,
          icon: Icon(CupertinoIcons.ellipsis_circle, color: colors.textPrimary),
          onSelected: _onMenu,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _QueueMenuAction.rename,
              child: Text(l10n.teamTasksRename),
            ),
            PopupMenuItem(
              value: _QueueMenuAction.reset,
              child: Text(l10n.matchTasksReset),
            ),
            PopupMenuItem(
              value: _QueueMenuAction.delete,
              child: Text(
                l10n.matchTasksDelete,
                style: TextStyle(color: colors.errorForeground),
              ),
            ),
          ],
        ),
      ],
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(
            Spacing.md, Spacing.md, Spacing.md, Spacing.xl),
        header: Padding(
          padding: const EdgeInsets.only(bottom: Spacing.md),
          child: Text(
            l10n.teamTasksQueueHint,
            style: styles.body3.copyWith(color: colors.textSecondary),
          ),
        ),
        buildDefaultDragHandles: false,
        itemCount: _queue.length,
        onReorder: _isBusy ? (_, __) {} : _reorder,
        itemBuilder: (context, index) {
          final player = _queue[index];
          final isNext = index == 0;

          return Padding(
            key: ValueKey('team-task-queue-${player.id}'),
            padding: const EdgeInsets.only(bottom: Spacing.xs + 2),
            child: Material(
              color: isNext ? colors.successSurface : colors.white,
              borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.itemGap, Spacing.sm, Spacing.xs, Spacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}.',
                        style: styles.body3.copyWith(color: colors.grey5),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styles.bodyBold,
                          ),
                          if (isNext)
                            Text(
                              l10n.matchTasksNextInLine,
                              style: styles.body3.copyWith(
                                fontSize: 11,
                                color: colors.successForeground,
                              ),
                            ),
                        ],
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      enabled: !_isBusy,
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.sm),
                        child: Icon(Icons.drag_handle_rounded,
                            color: colors.grey4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.matchTasksError)),
  );
}
