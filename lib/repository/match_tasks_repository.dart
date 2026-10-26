import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/match_task.dart';
import 'package:kopa/services/api_client.dart';

class MatchTasksRepository {
  static final _apiClient = ApiClient.shared;

  static Uri _matchTaskUrl(int matchId, [String suffix = '']) =>
      Uri.parse('${ApiConfig.baseUrl}/match/$matchId/tasks$suffix');

  static Future<List<MatchTask>> getMatchTasks(int matchId) async {
    final response = await _apiClient.get(_matchTaskUrl(matchId));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch match tasks');
    }

    final tasks = jsonDecode(response.body)['tasks'] as List<dynamic>;
    return tasks
        .map((task) => MatchTask.fromJson(task as Map<String, dynamic>))
        .toList();
  }

  static Future<List<TaskQueuePlayer>> getQueue(
    int matchId,
    int taskId,
  ) async {
    final response =
        await _apiClient.get(_matchTaskUrl(matchId, '/$taskId/queue'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch task queue');
    }

    final players = jsonDecode(response.body)['players'] as List<dynamic>;
    return players
        .map((p) => TaskQueuePlayer.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  static Future<void> assign(int matchId, int taskId, int userId) async {
    final response = await _apiClient.postJson(
      _matchTaskUrl(matchId, '/$taskId/assignee'),
      body: {'user_id': userId},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to assign task');
    }
  }

  /// [completedByUserId] is only honoured for team leaders; players always
  /// complete the task as themselves.
  static Future<void> complete(
    int matchId,
    int taskId, {
    int? completedByUserId,
  }) async {
    final response = await _apiClient.postJson(
      _matchTaskUrl(matchId, '/$taskId/complete'),
      body: {
        if (completedByUserId != null)
          'completed_by_user_id': completedByUserId,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to complete task');
    }
  }

  static Future<void> createTask(String name) async {
    final response = await _apiClient.postJson(
      Uri.parse('${ApiConfig.baseUrl}/tasks'),
      body: {'name': name},
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }
  }

  static Future<void> deleteTask(int taskId) async {
    final response = await _apiClient.delete(
      Uri.parse('${ApiConfig.baseUrl}/tasks/$taskId'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  static Future<void> resetQueue(int taskId) async {
    final response = await _apiClient.postJson(
      Uri.parse('${ApiConfig.baseUrl}/tasks/$taskId/queue/reset'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reset task queue');
    }
  }
}
