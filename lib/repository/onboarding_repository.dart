import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/services/secure_storage_service.dart';

class OnboardingRepository {
  Future<Map<String, dynamic>> validateToken(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/onboarding/validate/$token');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'valid': false, 'error': 'Kunne ikke validere invitation'};
      }
    } catch (e) {
      if (kDebugMode) print('Validate token error: $e');
      return {'valid': false, 'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> joinTeam(String token) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': 'Ikke logget ind'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/team/join');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Kunne ikke tilmelde holdet'
        };
      }
    } catch (e) {
      if (kDebugMode) print('Join team error: $e');
      return {'success': false, 'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> getJoinToken(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/team/$teamId/join_token');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Kunne ikke hente kode'};
      }
    } catch (e) {
      return {'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> rotateJoinToken(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    final url =
        Uri.parse('${ApiConfig.baseUrl}/team/$teamId/join_token/rotate');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Kunne ikke rotere kode'};
      }
    } catch (e) {
      return {'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> sendEmailInvites(
      int teamId, List<String> emails) async {
    final userToken = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/team/invite/email');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({'team_id': teamId, 'emails': emails}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Kunne ikke sende invitationer'};
      }
    } catch (e) {
      return {'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> createTeam({
    required String title,
    String? dbuCalendarUrl,
    List<Map<String, dynamic>> matches = const [],
    List<Map<String, dynamic>> standings = const [],
    List<String> inviteEmails = const [],
  }) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': 'Ikke logget ind'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/teams');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'title': title,
          if (dbuCalendarUrl != null) 'dbu_calendar_url': dbuCalendarUrl,
          'matches': matches,
          'standings': standings,
          'invite_emails': inviteEmails,
        }),
      );

      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : json.decode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, ...body};
      }
      return {
        'success': false,
        'error': body['error'] ?? 'Kunne ikke oprette holdet'
      };
    } catch (e) {
      if (kDebugMode) print('Create team error: $e');
      return {'success': false, 'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> searchTeams(String query) async {
    final userToken = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/teams/search')
        .replace(queryParameters: {'q': query});
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'teams': [], 'error': 'Kunne ikke søge efter hold'};
    } catch (e) {
      return {'teams': [], 'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> requestToJoinTeam(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': 'Ikke logget ind'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/join_requests');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : json.decode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, ...body};
      }
      return {
        'success': false,
        'error': body['error'] ?? 'Kunne ikke sende anmodning'
      };
    } catch (e) {
      return {'success': false, 'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> cancelJoinRequest(int requestId) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': 'Ikke logget ind'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/team_join_requests/$requestId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      }
      return {
        'success': false,
        'error': body['error'] ?? 'Kunne ikke annullere anmodning'
      };
    } catch (e) {
      return {'success': false, 'error': 'Netværksfejl'};
    }
  }
}
