import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/add_user_to_team_command.dart';
import 'package:kopa/model/player_profile.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class UsersRepository {
  static Future<List<UserDetails>> getSquad() async {
    final token = await SecureStorageService.getToken();
    var url = Uri.parse('${ApiConfig.baseUrl}/user/all');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch squad');
    }

    Iterable json = jsonDecode(response.body)['users'];

    return List<UserDetails>.from(
        json.map((content) => UserDetails.fromJson(content)));
  }

  static Future<int> createPlayer(String name, String email) async {
    final token = await SecureStorageService.getToken();
    var url = Uri.parse('${ApiConfig.baseUrl}/user');

    AddUserToTeamCommand addUserToTeamCommand =
        AddUserToTeamCommand(name, email, false);

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: addUserToTeamCommand.toJson());

    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }

    var json = jsonDecode(response.body);

    return json['id'];
  }

  static Future<void> syncDbuMatchProgram(
      Map<String, dynamic> dbuContext) async {
    final token = await SecureStorageService.getToken();
    var url = Uri.parse('${ApiConfig.baseUrl}/team/calendar_url');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        ..._dbuContextPayload(dbuContext),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update DBU match program');
    }
  }

  static Map<String, dynamic> _dbuContextPayload(Map<String, dynamic> context) {
    return {
      if (context['clubName'] != null) 'club_name': context['clubName'],
      if (context['dbuTeamLabel'] != null)
        'dbu_team_label': context['dbuTeamLabel'],
      if (context['dbuTeamId'] != null) 'dbu_team_id': context['dbuTeamId'],
      if (context['dbuPoolId'] != null) 'dbu_pool_id': context['dbuPoolId'],
      if (context['season'] != null) 'season': context['season'],
      if (context['region'] != null) 'region': context['region'],
      if (context['seriesName'] != null) 'series_name': context['seriesName'],
    };
  }

  static Future<PlayerProfile> getPlayerProfile(int playerId) async {
    final token = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/user/$playerId/profile');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch player profile');
    }

    final json = jsonDecode(response.body)['profile'];
    return PlayerProfile.fromJson(json);
  }

  static Future<UserDetails> updatePosition(String position) async {
    final token = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/user/profile');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'position': position}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update position');
    }

    return UserDetails.fromJson(jsonDecode(response.body)['user']);
  }
}
