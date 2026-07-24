import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/services/secure_storage_service.dart';

class TeamSeasonRepository {
  static Future<List<SeasonDetails>> getSeasons(int teamId) async {
    final token = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/seasons');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _decodedError(response, 'Kunne ikke hente sæsoner').message,
      );
    }

    final seasons = jsonDecode(response.body)['seasons'] as List<dynamic>;
    return seasons.map((season) => SeasonDetails.fromJson(season)).toList();
  }

  static Future<SeasonDetails> startSeason({
    required int teamId,
    required DateTime startsOn,
    String? name,
    bool allowUnsettledMatches = false,
  }) async {
    final token = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/seasons');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'starts_on': _dateOnly(startsOn),
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (allowUnsettledMatches) 'allow_unsettled_matches': true,
      }),
    );

    if (response.statusCode != 201) {
      final error = _decodedError(response);
      final unsettledCount = error.unsettledMatchesCount;
      if (unsettledCount != null) {
        throw UnsettledMatchesWarning(error.message, unsettledCount);
      }

      throw Exception(error.message);
    }

    return SeasonDetails.fromJson(jsonDecode(response.body)['season']);
  }

  static String _dateOnly(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static _SeasonApiError _decodedError(
    http.Response response, [
    String fallback = 'Kunne ikke starte ny sæson',
  ]) {
    try {
      final decoded = jsonDecode(response.body);
      final error = decoded['error']?.toString();
      final count = decoded['unsettled_matches_count'];

      return _SeasonApiError(
        error != null && error.isNotEmpty ? error : fallback,
        count is int ? count : null,
      );
    } catch (_) {
      // Use the fallback below when the API does not return JSON.
    }

    return _SeasonApiError(fallback, null);
  }
}

class UnsettledMatchesWarning implements Exception {
  final String message;
  final int unsettledMatchesCount;

  UnsettledMatchesWarning(this.message, this.unsettledMatchesCount);

  @override
  String toString() => message;
}

class _SeasonApiError {
  final String message;
  final int? unsettledMatchesCount;

  const _SeasonApiError(this.message, this.unsettledMatchesCount);
}
