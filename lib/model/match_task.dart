enum MatchTaskKind {
  /// Belongs to the team, shows up on every match and is handed out through
  /// the task's queue.
  recurring,

  /// Only belongs to a single match; the team leader picks who does it.
  oneOff;

  static MatchTaskKind fromJson(Object? value) =>
      value == 'one_off' ? MatchTaskKind.oneOff : MatchTaskKind.recurring;
}

class TaskPlayer {
  final int id;
  final String name;

  const TaskPlayer({required this.id, required this.name});

  factory TaskPlayer.fromJson(Map<String, dynamic> json) =>
      TaskPlayer(id: json['id'] as int, name: json['name'] as String);
}

class MatchTask {
  final int id;
  final String name;
  final MatchTaskKind kind;
  final int? assigneeId;
  final String? assigneeName;
  final bool isAutomatic;
  final bool isCompleted;
  final String? completedByName;

  /// The players after the responsible one in the queue, front first.
  final List<TaskPlayer> upNext;

  const MatchTask({
    required this.id,
    required this.name,
    this.kind = MatchTaskKind.recurring,
    this.assigneeId,
    this.assigneeName,
    this.isAutomatic = false,
    this.isCompleted = false,
    this.completedByName,
    this.upNext = const [],
  });

  bool get isRecurring => kind == MatchTaskKind.recurring;

  factory MatchTask.fromJson(Map<String, dynamic> json) {
    final assignee = json['assignee'] as Map<String, dynamic>?;
    final completedBy = json['completed_by'] as Map<String, dynamic>?;

    return MatchTask(
      id: json['id'] as int,
      name: json['name'] as String,
      kind: MatchTaskKind.fromJson(json['kind']),
      assigneeId: assignee?['id'] as int?,
      assigneeName: assignee?['name'] as String?,
      isAutomatic: json['is_automatic'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedByName: completedBy?['name'] as String?,
      upNext: (json['up_next'] as List<dynamic>? ?? const [])
          .map((p) => TaskPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TaskQueuePlayer {
  /// Queue position for recurring tasks; null for one-off tasks.
  final int? position;
  final int userId;
  final String name;
  final bool isSelected;
  final bool isAutoSelected;
  final bool isAssigned;

  const TaskQueuePlayer({
    this.position,
    required this.userId,
    required this.name,
    required this.isSelected,
    required this.isAutoSelected,
    required this.isAssigned,
  });

  factory TaskQueuePlayer.fromJson(Map<String, dynamic> json) {
    return TaskQueuePlayer(
      position: json['position'] as int?,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      isSelected: json['is_selected'] as bool? ?? false,
      isAutoSelected: json['is_auto_selected'] as bool? ?? false,
      isAssigned: json['is_assigned'] as bool? ?? false,
    );
  }
}

/// A recurring task with its whole queue, for the team admin page.
class TeamTask {
  final int id;
  final String name;
  final List<TaskPlayer> queue;

  const TeamTask({required this.id, required this.name, required this.queue});

  factory TeamTask.fromJson(Map<String, dynamic> json) {
    return TeamTask(
      id: json['id'] as int,
      name: json['name'] as String,
      queue: (json['queue'] as List<dynamic>? ?? const [])
          .map((entry) => entry as Map<String, dynamic>)
          .map((entry) => TaskPlayer(
                id: entry['user_id'] as int,
                name: entry['name'] as String,
              ))
          .toList(),
    );
  }
}
