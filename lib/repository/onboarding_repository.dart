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
      int teamId, List<Map<String, String>> invites) async {
    final userToken = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/team/invite/email');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({'team_id': teamId, 'emails': invites}),
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

  Future<Map<String, dynamic>> resendPendingInvites(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    final url =
        Uri.parse('${ApiConfig.baseUrl}/team/$teamId/invites/resend_pending');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Kunne ikke sende invitationer igen'};
      }
    } catch (e) {
      return {'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> createTeam({
    required String title,
    String? dbuCalendarUrl,
    Map<String, dynamic>? dbuContext,
    List<Map<String, dynamic>> matches = const [],
    List<Map<String, dynamic>> standings = const [],
    List<Map<String, String>> inviteEmails = const [],
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
          if (dbuContext != null) ..._dbuContextPayload(dbuContext),
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

  Map<String, dynamic> _dbuContextPayload(Map<String, dynamic> context) {
    return {
      if (context['clubName'] != null) 'club_name': context['clubName'],
      if (context['dbuTeamLabel'] != null)
        'dbu_team_label': context['dbuTeamLabel'],
      if (context['dbuTeamId'] != null) 'dbu_team_id': context['dbuTeamId'],
      if (context['dbuPoolId'] != null) 'dbu_pool_id': context['dbuPoolId'],
      if (context['season'] != null) 'season': context['season'],
      if (context['region'] != null) 'region': context['region'],
      if (context['seriesName'] != null) 'series_name': context['seriesName'],
    };
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

  Future<Map<String, dynamic>> listJoinRequests(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': 'Ikke logget ind'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/join_requests');
    try {
      final response = await http.get(
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
        'error': body['error'] ?? 'Kunne ikke hente anmodninger'
      };
    } catch (e) {
      return {'success': false, 'error': 'Netværksfejl'};
    }
  }

  Future<Map<String, dynamic>> approveJoinRequest(int requestId) async {
    return _respondToJoinRequest(requestId, 'approve');
  }

  Future<Map<String, dynamic>> rejectJoinRequest(int requestId) async {
    return _respondToJoinRequest(requestId, 'reject');
  }

  Future<Map<String, dynamic>> _respondToJoinRequest(
    int requestId,
    String action,
  ) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': 'Ikke logget ind'};
    }

    final url =
        Uri.parse('${ApiConfig.baseUrl}/team_join_requests/$requestId/$action');
    try {
      final response = await http.post(
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
        'error': body['error'] ?? 'Kunne ikke behandle anmodning'
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
