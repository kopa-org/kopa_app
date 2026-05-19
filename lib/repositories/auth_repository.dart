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

class ApiAuthRepository implements AuthRepository {
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
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = UserDetails.fromJson(json);
        await SecureStorageService.setUserInfo(user);
        return user;
      }
    } catch (_) {
      // Handle error or rethrow
    }
    return null;
  }

  @override
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/authentication/login');
    try {
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

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
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role_id': roleId,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error registering user: $e');
    }
    return false;
  }
}
