import 'dart:convert';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/create_match_comand.dart';
import 'package:kopa/model/create_match_event_command.dart';
import 'package:kopa/model/register_for_unregister_from_match_command.dart';
import 'package:kopa/model/match_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kopa/model/update_match_score_command.dart';

class MatchRepository {
  static final _secureStorage = FlutterSecureStorage();

  static Future<List<MatchDetails>> getMatches() async {
    await dotenv.load(); // Initialize dotenv

    // Get token
    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/match');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['body'];
      return List<MatchDetails>.from(
        json.map((content) => MatchDetails.fromJson(content)),
      );
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to fetch matches');
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
    await dotenv.load(); // Initialize dotenv

    var url = Uri.parse('${ApiConfig.baseUrl}/match');

    CreateMatchCommand createMatchCommand = CreateMatchCommand(
        firstTeam, secondTeam, location, meetingTime, date, notes);

    var response = await http.post(url, body: createMatchCommand.toJson());

    if (response.statusCode != 200) {
      throw Exception('Failed to create match');
    }

    var json = jsonDecode(response.body);

    return json['id'];
  }

  static Future<void> deleteMatch(int id) async {
    await dotenv.load(); // Initialize dotenv

    // Get token
    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/match/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to delete match');
    }
  }

  static Future<MatchDetails> getMatch(int id) async {
    await dotenv.load(); // Initialize dotenv

    // Get token
    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/match/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)['body'];

      return MatchDetails.fromJson(json);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to fetch match');
    }
  }

  static Future<int> registerForMatch(int matchId) async {
    await dotenv.load(); // Initialize dotenv

    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/match/register');

    final command = RegisterForUnregisterFromEventCommand(
      eventId: matchId.toString(),
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(command.toJson()),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to register for match');
    }

    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['id'];
  }

  static Future<int> unregisterFromMatch(int matchId) async {
    await dotenv.load(); // Initialize dotenv

    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/match/unregister');

    final command = RegisterForUnregisterFromEventCommand(
      eventId: matchId.toString(),
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(command.toJson()),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to unregister from match');
    }

    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['id'];
  }

  static Future<void> updateMatchScore(
      int matchId, int homeTeamScore, int awayTeamScore) async {
    await dotenv.load(); // Initialize dotenv

    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/match/score');

    final command = UpdateMatchScoreCommand(
      eventId: matchId,
      homeTeamScore: homeTeamScore,
      awayTeamScore: awayTeamScore,
    );

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(command.toJson()),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to upodate match score');
    }
  }

  static Future<List<int>> createMatchEvents(
      List<CreateMatchEventCommand> createMatchEventCommands) async {
    await dotenv.load(); // Initialize dotenv

    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/match/event');

    var jsonEncoded =
        jsonEncode(createMatchEventCommands.map((e) => e.toJson()).toList());

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncoded,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create match');
    }

    var jsonDecoded = jsonDecode(response.body);

    return _parseIds(jsonDecoded);
  }

  static Future<bool> deleteMatchEvent(int matchEventId) async {
    await dotenv.load(); // Initialize dotenv

    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/match/event/$matchEventId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

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
