import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/add_user_to_team_command.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class UsersRepository {
  static Future<List<UserDetails>> getSquad() async {
    await dotenv.load(); // Initialize dotenv

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
    await dotenv.load(); // Initialize dotenv

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

  static Future<void> setCalendarUrl(String calendarUrl) async {
    await dotenv.load();

    final token = await SecureStorageService.getToken();
    var url = Uri.parse('${ApiConfig.baseUrl}/team/calendar_url');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'calendar_url': calendarUrl}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update calendar URL');
    }
  }
}
