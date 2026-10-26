class MatchTask {
  final int id;
  final String name;
  final int? assigneeId;
  final String? assigneeName;
  final bool isAutomatic;
  final bool isCompleted;
  final String? completedByName;

  const MatchTask({
    required this.id,
    required this.name,
    this.assigneeId,
    this.assigneeName,
    this.isAutomatic = false,
    this.isCompleted = false,
    this.completedByName,
  });

  factory MatchTask.fromJson(Map<String, dynamic> json) {
    final assignee = json['assignee'] as Map<String, dynamic>?;
    final completedBy = json['completed_by'] as Map<String, dynamic>?;

    return MatchTask(
      id: json['id'] as int,
      name: json['name'] as String,
      assigneeId: assignee?['id'] as int?,
      assigneeName: assignee?['name'] as String?,
      isAutomatic: json['is_automatic'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedByName: completedBy?['name'] as String?,
    );
  }
}

class TaskQueuePlayer {
  final int position;
  final int userId;
  final String name;
  final bool isSelected;
  final bool isAutoSelected;
  final bool isAssigned;

  const TaskQueuePlayer({
    required this.position,
    required this.userId,
    required this.name,
    required this.isSelected,
    required this.isAutoSelected,
    required this.isAssigned,
  });

  factory TaskQueuePlayer.fromJson(Map<String, dynamic> json) {
    return TaskQueuePlayer(
      position: json['position'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      isSelected: json['is_selected'] as bool? ?? false,
      isAutoSelected: json['is_auto_selected'] as bool? ?? false,
      isAssigned: json['is_assigned'] as bool? ?? false,
    );
  }
}
