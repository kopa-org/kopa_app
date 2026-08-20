import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/services/api_client.dart';
import 'package:kopa/services/secure_storage_service.dart';

class ScraperManifest {
  const ScraperManifest({
    required this.version,
    required this.targetHost,
    required this.script,
  });

  final String version;
  final String targetHost;
  final String script;

  factory ScraperManifest.fromJson(Map<String, dynamic> json) {
    return ScraperManifest(
      version: json['version']?.toString() ?? '',
      targetHost: json['targetHost']?.toString() ?? '',
      script: json['script']?.toString() ?? '',
    );
  }
}

class ScraperRepository {
  static final _apiClient = ApiClient.shared;

  static Future<ScraperManifest> getDbuScraper() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/scraper/dbu');

    final response = await _apiClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch DBU scraper');
    }

    final manifest = ScraperManifest.fromJson(jsonDecode(response.body));
    if (manifest.script.isEmpty) {
      throw Exception('DBU scraper script is empty');
    }

    return manifest;
  }

  static Future<void> uploadDbuDebug(Map<String, dynamic> payload) async {
    if (await SecureStorageService.getToken() == null) return;

    final url = Uri.parse('${ApiConfig.baseUrl}/scraper/dbu/debug');
    await _apiClient.postJson(
      url,
      body: payload,
    );
  }
}
