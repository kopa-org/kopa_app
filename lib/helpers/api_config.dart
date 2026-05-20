// lib/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    final raw = dotenv.env['API_BASE_URL'];
    if (raw == null || raw.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }

    return raw;
  }
}
