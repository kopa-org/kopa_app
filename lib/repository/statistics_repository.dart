import 'dart:convert';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/services/api_client.dart';

class StatisticsRepository {
  static final _apiClient = ApiClient.shared;

  static Future<StatisticsResponse> getStatistics(int teamId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/statistics/$teamId');
    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['statistics'];
      return StatisticsResponse.fromJson(json);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to fetch statistics');
    }
  }
}
