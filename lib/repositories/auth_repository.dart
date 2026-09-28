import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/services/secure_storage_service.dart';

abstract interface class AuthRepository {
  Future<UserDetails?> getCurrentUser();
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  });
}

abstract interface class PasswordResetRepository {
  Future<void> requestPasswordResetCode(String email);
  Future<bool> verifyPasswordResetCode(String email, String code);
  Future<UserDetails> resetPassword({
    required String email,
    required String code,
    required String password,
  });
}

class ApiAuthRepository implements AuthRepository, PasswordResetRepository {
  static const _requestTimeout = Duration(seconds: 20);
  final http.Client _httpClient;

  ApiAuthRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<UserDetails?> getCurrentUser() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return null;

    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/current_user');
    try {
      final response = await _httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = UserDetails.fromJson(json);
        await SecureStorageService.setUserInfo(user);
        return user;
      }
    } catch (e) {
      throw Exception('Failed to fetch current user');
    }
    return null;
  }

  @override
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/login');
    try {
      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await SecureStorageService.setToken(data['token']);
        return true;
      }
    } catch (e) {
      print('Error logging in: $e');
    }
    return false;
  }

  @override
  Future<void> logout() async {
    await SecureStorageService.deleteToken();
    await SecureStorageService.clearUserData();
  }

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/register');
    try {
      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
              'role_id': roleId,
            }),
          )
          .timeout(_requestTimeout);

      return response.statusCode == 201;
    } catch (e) {
      print('Error registering user: $e');
    }
    return false;
  }

  @override
  Future<void> requestPasswordResetCode(String email) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/authentication/password/reset/request',
    );
    final response = await _httpClient
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email}),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Could not request password reset code');
    }
  }

  @override
  Future<bool> verifyPasswordResetCode(String email, String code) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/authentication/password/reset/verify',
    );
    final response = await _httpClient
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'code': code}),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200) return true;
    if (response.statusCode == 422) return false;
    throw Exception('Could not verify password reset code');
  }

  @override
  Future<UserDetails> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/password/reset');
    final response = await _httpClient
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'code': code,
            'password': password,
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Could not reset password');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final user = UserDetails.fromJson(data['user'] as Map<String, dynamic>);
    await SecureStorageService.setToken(data['token'] as String);
    await SecureStorageService.setUserInfo(user);
    return user;
  }
}
