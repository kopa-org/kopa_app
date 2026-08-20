import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/services/api_client.dart';
import 'package:kopa/services/secure_storage_service.dart';

class AuthenticationRepository {
  static final _apiClient = ApiClient.shared;

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/login');
    try {
      final response = await _apiClient.postJson(
        url,
        authenticated: false,
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Save the token securely
        await SecureStorageService.setToken(data['token']);

        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login fejlede'
        };
      }
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      return {
        'success': false,
        'message': 'Der skete en fejl under login. Prøv igen.'
      };
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, int roleId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/register');
    try {
      final response = await _apiClient.postJson(
        url,
        authenticated: false,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role_id': roleId,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registrering fejlede'
        };
      }
    } catch (e) {
      if (kDebugMode) print('Registration error: $e');
      return {
        'success': false,
        'message': 'Der skete en fejl under registering. Prøv igen.'
      };
    }
  }

  static Future<bool> logout() async {
    await SecureStorageService.deleteToken();

    return true;
  }

  static Future<UserDetails> getCurrentUser() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login again.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/current_user');
    try {
      final response = await _apiClient.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return UserDetails.fromJson(json);
      } else {
        final error = jsonDecode(response.body);

        throw Exception('An error occurred: ${error['message']}');
      }
    } catch (e) {
      if (kDebugMode) print('Get current user error: $e');
      throw Exception('Failed to fetch current user data.');
    }
  }
}
