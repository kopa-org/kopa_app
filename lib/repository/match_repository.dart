import 'dart:convert';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/create_match_comand.dart';
import 'package:kopa/model/create_match_event_command.dart';
import 'package:kopa/model/register_for_unregister_from_match_command.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/update_match_score_command.dart';
import 'package:kopa/services/api_client.dart';

class MatchRepository {
  static final _apiClient = ApiClient.shared;
  static Future<List<MatchDetails>>? _summaryRequest;
  static List<MatchDetails>? _summaryCache;

  static Future<List<MatchDetails>> getMatches() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match');
    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['matches'];
      return List<MatchDetails>.from(
        json.map((content) => MatchDetails.fromJson(content)),
      );
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to fetch matches');
    }
  }

  static Future<List<MatchDetails>> getMatchSummaries({
    bool forceRefresh = false,
  }) {
    final inFlight = _summaryRequest;
    if (inFlight != null) return inFlight;

    final cached = _summaryCache;
    if (!forceRefresh && cached != null) {
      return Future.value(cached);
    }

    final request = _fetchMatchSummaries();
    _summaryRequest = request;

    return request.then((matches) {
      _summaryCache = List.unmodifiable(matches);
      return _summaryCache!;
    }).whenComplete(() {
      _summaryRequest = null;
    });
  }

  static void invalidateMatchSummaries() {
    _summaryCache = null;
  }

  static Future<List<MatchDetails>> _fetchMatchSummaries() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/summaries');
    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['matches'] as List<dynamic>;
      return json
          .map((content) => MatchDetails.fromJson(content))
          .toList(growable: false);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      // Keep the app usable while the client and API are on different
      // releases. The summary endpoint is an optimization; the existing
      // match endpoint remains the compatible source of truth.
      return getMatches();
    }
  }

  static Future<int> createMatch(
    String firstTeam,
    String secondTeam,
    DateTime date,
    String location,
    DateTime? meetingTime, {
    String? notes,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match');

    final createMatchCommand = CreateMatchCommand(
        firstTeam, secondTeam, location, meetingTime, date, notes);

    final response = await _apiClient.postJson(
      url,
      body: createMatchCommand.toJson(),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create match');
    }

    final decodedJson = jsonDecode(response.body);
    invalidateMatchSummaries();

    return decodedJson['id'] ?? decodedJson['match']['id'];
  }

  static Future<void> deleteMatch(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/$id');
    final response = await _apiClient.delete(url);

    if (response.statusCode == 200) {
      invalidateMatchSummaries();
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to delete match');
    }
  }

  static Future<MatchDetails> getMatch(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/$id');
    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)['match'];

      return MatchDetails.fromJson(json);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to fetch match');
    }
  }

  static Future<void> registerForMatch(int matchId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/register');

    final command = RegisterForUnregisterFromEventCommand(
      eventId: matchId.toString(),
    );

    final response = await _apiClient.postJson(
      url,
      body: command.toJson(),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to register for match');
    }

    invalidateMatchSummaries();
    return;
  }

  static Future<void> unregisterFromMatch(int matchId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/unregister');

    final command = RegisterForUnregisterFromEventCommand(
      eventId: matchId.toString(),
    );

    final response = await _apiClient.postJson(
      url,
      body: command.toJson(),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to unregister from match');
    }

    invalidateMatchSummaries();
    return;
  }

  static Future<void> updateMatchScore(
      int matchId, int homeTeamScore, int awayTeamScore) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/score');

    final command = UpdateMatchScoreCommand(
      eventId: matchId,
      homeTeamScore: homeTeamScore,
      awayTeamScore: awayTeamScore,
    );

    final response = await _apiClient.patchJson(
      url,
      body: command.toJson(),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to upodate match score');
    }

    invalidateMatchSummaries();
  }

  static Future<void> updateMatchFormation(
      int matchId, String formation) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/formation');

    final response = await _apiClient.patchJson(
      url,
      body: {
        'event_id': matchId,
        'formation': formation,
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to update match formation');
    }

    invalidateMatchSummaries();
  }

  static Future<MatchDetails> updateMatchLineup(
    int matchId,
    String formation,
    List<Map<String, dynamic>> lineup,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/lineup');

    final response = await _apiClient.patchJson(
      url,
      body: {
        'event_id': matchId,
        'formation': formation,
        'lineup': lineup,
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to update match lineup');
    }

    final updatedMatch = jsonDecode(response.body)['match'];
    if (updatedMatch is! Map<String, dynamic>) {
      throw Exception('Updated match was not returned');
    }

    invalidateMatchSummaries();
    return MatchDetails.fromJson(updatedMatch);
  }

  static Future<MatchDetails> updateMatchLineupVisibility(
    int matchId,
    bool visible,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/lineup_visibility');

    final response = await _apiClient.patchJson(
      url,
      body: {
        'event_id': matchId,
        'lineup_visible': visible,
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to update match lineup visibility');
    }

    final updatedMatch = jsonDecode(response.body)['match'];
    if (updatedMatch is! Map<String, dynamic>) {
      throw Exception('Updated match was not returned');
    }

    invalidateMatchSummaries();
    return MatchDetails.fromJson(updatedMatch);
  }

  static Future<void> updateAttendanceSelection(
    int matchId,
    int userId,
    bool isSelected,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/attendance_selection');

    final response = await _apiClient.patchJson(
      url,
      body: {
        'event_id': matchId,
        'user_id': userId,
        'is_selected': isSelected,
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to update attendance selection');
    }

    invalidateMatchSummaries();
  }

  static Future<List<int>> createMatchEvents(
      List<CreateMatchEventCommand> createMatchEventCommands) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/event');

    final response = await _apiClient.postJson(
      url,
      body: createMatchEventCommands.map((e) => e.toJson()).toList(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create match');
    }

    var jsonDecoded = jsonDecode(response.body);

    return _parseIds(jsonDecoded);
  }

  static Future<bool> deleteMatchEvent(int matchEventId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/event/$matchEventId');

    final response = await _apiClient.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to delete match event');
    }
  }

  static List<int> _parseIds(dynamic decoded) {
    if (decoded == null) return const [];

    // { ids: [...] }
    if (decoded is Map<String, dynamic>) {
      if (decoded['ids'] is List) {
        return (decoded['ids'] as List).map(_toInt).toList();
      }
      if (decoded['id'] != null) {
        return [_toInt(decoded['id'])];
      }
      if (decoded['data'] is List) {
        final List data = decoded['data'];
        return data
            .whereType<Map>()
            .where((m) => m['id'] != null)
            .map((m) => _toInt(m['id']))
            .toList();
      }
    }

    // [ {id: 1}, {id: 2} ] or [1,2]
    if (decoded is List) {
      if (decoded.isEmpty) return const [];
      if (decoded.first is int || decoded.first is String) {
        return decoded.map(_toInt).toList();
      }
      return decoded
          .whereType<Map>()
          .where((m) => m['id'] != null)
          .map((m) => _toInt(m['id']))
          .toList();
    }

    return const [];
  }

  static int _toInt(dynamic v) => v is int ? v : int.parse(v.toString());
}
