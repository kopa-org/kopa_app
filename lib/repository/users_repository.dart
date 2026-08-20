import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/add_user_to_team_command.dart';
import 'package:kopa/model/player_profile.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/services/api_client.dart';

class UsersRepository {
  static final _apiClient = ApiClient.shared;

  static Future<List<UserDetails>> getSquad() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/all');

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch squad');
    }

    Iterable json = jsonDecode(response.body)['users'];

    return List<UserDetails>.from(
        json.map((content) => UserDetails.fromJson(content)));
  }

  static Future<int> createPlayer(String name, String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user');

    AddUserToTeamCommand addUserToTeamCommand =
        AddUserToTeamCommand(name, email, false);

    final response = await _apiClient.postJson(
      url,
      body: addUserToTeamCommand.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }

    var json = jsonDecode(response.body);

    return json['id'];
  }

  static Future<void> syncDbuMatchProgram(
      Map<String, dynamic> dbuContext) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/team/calendar_url');

    final response = await _apiClient.postJson(
      url,
      body: {
        ..._dbuContextPayload(dbuContext),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update DBU match program');
    }
  }

  static Future<TeamDetails> updateTeamSettings({
    required int teamId,
    required int? defaultMeetingOffsetMinutes,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/settings');

    final response = await _apiClient.patchJson(
      url,
      body: {
        'default_meeting_offset_minutes': defaultMeetingOffsetMinutes,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Kunne ikke gemme mødetid.');
    }

    return TeamDetails.fromJson(jsonDecode(response.body)['team']);
  }

  static Map<String, dynamic> _dbuContextPayload(Map<String, dynamic> context) {
    final clubName = context['clubName'] ?? context['publicClubName'];
    final dbuTeamLabel = context['dbuTeamLabel'] ?? context['publicTeamLabel'];

    return {
      if (clubName != null) 'club_name': clubName,
      if (dbuTeamLabel != null) 'dbu_team_label': dbuTeamLabel,
      if (context['dbuTeamId'] != null) 'dbu_team_id': context['dbuTeamId'],
      if (context['dbuPoolId'] != null) 'dbu_pool_id': context['dbuPoolId'],
      if (context['season'] != null) 'season': context['season'],
      if (context['region'] != null) 'region': context['region'],
      if (context['seriesName'] != null) 'series_name': context['seriesName'],
    };
  }

  static Future<PlayerProfile> getPlayerProfile(int playerId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/$playerId/profile');

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch player profile');
    }

    final json = jsonDecode(response.body)['profile'];
    return PlayerProfile.fromJson(json);
  }

  static Future<UserDetails> updatePosition(String position) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/profile');

    final response = await _apiClient.patchJson(
      url,
      body: {'position': position},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update position');
    }

    return UserDetails.fromJson(jsonDecode(response.body)['user']);
  }
}
