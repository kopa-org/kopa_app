import 'dart:convert';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/statistics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StatisticsRepository {
  static final _secureStorage = FlutterSecureStorage();

  static Future<StatisticsResponse> getStatistics(int teamId) async {
    await dotenv.load();

    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/statistics/$teamId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['body'];
      return StatisticsResponse.fromJson(json);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to fetch statistics');
    }
  }
}
