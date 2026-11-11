import 'dart:convert';
import 'package:kopa/l10n/current_l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/services/secure_storage_service.dart';
import 'package:kopa/services/api_client.dart';

class OnboardingRepository {
  final _apiClient = ApiClient.shared;

  Future<Map<String, dynamic>> validateToken(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/onboarding/validate/$token');
    try {
      final response = await _apiClient.get(url, authenticated: false);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'valid': false,
          'error': currentL10n.uiCouldNotValidateTheInvitation
        };
      }
    } catch (e) {
      if (kDebugMode) print('Validate token error: $e');
      return {'valid': false, 'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> joinTeam(String token,
      {bool isTeamLeader = false}) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': currentL10n.uiNotLoggedIn};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/team/join');
    try {
      final response = await _apiClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({'token': token, 'is_team_leader': isTeamLeader}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? currentL10n.uiCouldNotJoinTheTeam
        };
      }
    } catch (e) {
      if (kDebugMode) print('Join team error: $e');
      return {'success': false, 'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> getJoinToken(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/team/$teamId/join_token');
    try {
      final response = await _apiClient.get(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': currentL10n.uiCouldNotFetchTheCode};
      }
    } catch (e) {
      return {'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> rotateJoinToken(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    final url =
        Uri.parse('${ApiConfig.baseUrl}/team/$teamId/join_token/rotate');
    try {
      final response = await _apiClient.post(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': currentL10n.uiCouldNotRotateTheCode};
      }
    } catch (e) {
      return {'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> updateTeamLogo({
    required int teamId,
    required TeamLogoDesign logoDesign,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/settings');
    try {
      final response = await _apiClient.patchJson(
        url,
        body: logoDesign.toJson(),
      );
      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...body};
      }
      return {
        'success': false,
        'error': body['error'] ?? currentL10n.uiNetworkError,
      };
    } catch (e) {
      if (kDebugMode) print('Update team logo error: $e');
      return {'success': false, 'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> createTeam({
    required String title,
    required int playerCount,
    bool isTeamLeader = true,
    TeamLogoDesign? logoDesign,
    Map<String, dynamic>? dbuContext,
    List<Map<String, dynamic>> standings = const [],
  }) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': currentL10n.uiNotLoggedIn};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/teams');
    try {
      final response = await _apiClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'title': title,
          'player_count': playerCount,
          'is_team_leader': isTeamLeader,
          if (logoDesign != null) ...logoDesign.toJson(),
          if (dbuContext != null) ..._dbuContextPayload(dbuContext),
          'standings': standings,
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
        'error': body['error'] ?? currentL10n.uiCouldNotCreateTheTeam
      };
    } catch (e) {
      if (kDebugMode) print('Create team error: $e');
      return {'success': false, 'error': currentL10n.uiNetworkError};
    }
  }

  Map<String, dynamic> _dbuContextPayload(Map<String, dynamic> context) {
    final clubName = context['clubName'] ?? context['publicClubName'];
    final dbuTeamLabel = context['dbuTeamLabel'] ?? context['publicTeamLabel'];

    return {
      if (clubName != null) 'club_name': clubName,
      if (dbuTeamLabel != null) 'dbu_team_label': dbuTeamLabel,
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
      final response = await _apiClient.get(
        url,
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'teams': [], 'error': currentL10n.uiCouldNotSearchForTeams};
    } catch (e) {
      return {'teams': [], 'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> requestToJoinTeam(int teamId,
      {bool isTeamLeader = false}) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': currentL10n.uiNotLoggedIn};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/join_requests');
    try {
      final response = await _apiClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json'
        },
        body: json.encode({'is_team_leader': isTeamLeader}),
      );
      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : json.decode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, ...body};
      }
      return {
        'success': false,
        'error': body['error'] ?? currentL10n.uiCouldNotSendTheRequest
      };
    } catch (e) {
      return {'success': false, 'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> getCurrentJoinRequest() async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': currentL10n.uiNotLoggedIn};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/team_join_requests/current');
    try {
      final response = await _apiClient.get(
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
        'error': body['error'] ?? currentL10n.uiCouldNotFetchTheRequest
      };
    } catch (e) {
      return {'success': false, 'error': currentL10n.uiNetworkError};
    }
  }

  /// Number of pending join requests for [teamId] (team owners only).
  Future<int> countPendingJoinRequests(int teamId) async {
    final result = await listJoinRequests(teamId);
    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Could not load join requests.');
    }
    return (result['join_requests'] as List<dynamic>? ?? []).length;
  }

  Future<Map<String, dynamic>> listJoinRequests(int teamId) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': currentL10n.uiNotLoggedIn};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/join_requests');
    try {
      final response = await _apiClient.get(
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
        'error': body['error'] ?? currentL10n.uiCouldNotFetchTheRequests
      };
    } catch (e) {
      return {'success': false, 'error': currentL10n.uiNetworkError};
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
      return {'success': false, 'error': currentL10n.uiNotLoggedIn};
    }

    final url =
        Uri.parse('${ApiConfig.baseUrl}/team_join_requests/$requestId/$action');
    try {
      final response = await _apiClient.post(
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
        'error': body['error'] ?? currentL10n.uiCouldNotProcessTheRequest
      };
    } catch (e) {
      return {'success': false, 'error': currentL10n.uiNetworkError};
    }
  }

  Future<Map<String, dynamic>> cancelJoinRequest(int requestId) async {
    final userToken = await SecureStorageService.getToken();
    if (userToken == null) {
      return {'success': false, 'error': currentL10n.uiNotLoggedIn};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/team_join_requests/$requestId');
    try {
      final response = await _apiClient.delete(
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
        'error': body['error'] ?? currentL10n.uiCouldNotCancelTheRequest
      };
    } catch (e) {
      return {'success': false, 'error': currentL10n.uiNetworkError};
    }
  }
}
