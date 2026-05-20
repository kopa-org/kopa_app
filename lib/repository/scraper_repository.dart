import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
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
  static Future<ScraperManifest> getDbuScraper() async {
    await dotenv.load();

    final token = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/scraper/dbu');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch DBU scraper');
    }

    final manifest = ScraperManifest.fromJson(jsonDecode(response.body));
    if (manifest.script.isEmpty) {
      throw Exception('DBU scraper script is empty');
    }

    return manifest;
  }
}
