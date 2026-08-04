import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

enum OnboardingStatus {
  initial,
  loading,
  success,
  failure,
  validated,
  waitingApproval
}

class OnboardingState {
  final OnboardingStatus status;
  final String? inviteToken;
  final String? email;
  final String? name;
  final int? teamId;
  final String? teamTitle;
  final String? errorMessage;
  final String? joinToken; // Generic team join token for sharing
  final List<Map<String, dynamic>> searchResults;
  final int? pendingJoinRequestId;

  OnboardingState({
    this.status = OnboardingStatus.initial,
    this.inviteToken,
    this.email,
    this.name,
    this.teamId,
    this.teamTitle,
    this.errorMessage,
    this.joinToken,
    this.searchResults = const [],
    this.pendingJoinRequestId,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    Object? inviteToken = _unset,
    Object? email = _unset,
    Object? name = _unset,
    Object? teamId = _unset,
    Object? teamTitle = _unset,
    Object? errorMessage = _unset,
    Object? joinToken = _unset,
    List<Map<String, dynamic>>? searchResults,
    Object? pendingJoinRequestId = _unset,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      inviteToken:
          inviteToken == _unset ? this.inviteToken : inviteToken as String?,
      email: email == _unset ? this.email : email as String?,
      name: name == _unset ? this.name : name as String?,
      teamId: teamId == _unset ? this.teamId : teamId as int?,
      teamTitle: teamTitle == _unset ? this.teamTitle : teamTitle as String?,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      joinToken: joinToken == _unset ? this.joinToken : joinToken as String?,
      searchResults: searchResults ?? this.searchResults,
      pendingJoinRequestId: pendingJoinRequestId == _unset
          ? this.pendingJoinRequestId
          : pendingJoinRequestId as int?,
    );
  }
}

const Object _unset = Object();

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingCubit(this._repository) : super(OnboardingState());

  Future<void> handleDeepLink(
    String token, {
    String? email,
    String? name,
    int? teamId,
    String? teamTitle,
  }) async {
    AppAnalytics.logEvent('onboarding_started');
    emit(state.copyWith(
      status: OnboardingStatus.loading,
      inviteToken: token,
      email: email,
      name: name,
      teamId: teamId,
      teamTitle: teamTitle,
    ));

    final result = await _repository.validateToken(token);

    if (result['valid'] == true) {
      emit(state.copyWith(
        status: OnboardingStatus.validated,
        email: result['email'] ?? email,
        name: result['name'] ?? name,
        teamId: result['team_id'] ?? teamId,
        teamTitle: result['team_title'] ?? teamTitle,
      ));
    } else {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: result['error'] ?? 'Ugyldig invitation',
      ));
    }
  }

  Future<bool> joinTeamWithToken() async {
    if (state.inviteToken == null) return false;

    emit(state.copyWith(status: OnboardingStatus.loading));
    final result = await _repository.joinTeam(state.inviteToken!);

    if (result['success'] == true) {
      AppAnalytics.logEvent('team_joined');
      emit(state.copyWith(status: OnboardingStatus.success, inviteToken: null));
      return true;
    } else {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: result['error'],
      ));
      return false;
    }
  }

  Future<String?> fetchTeamJoinToken(int teamId) async {
    final result = await _repository.getJoinToken(teamId);
    if (result.containsKey('token')) {
      final token = result['token'] as String;
      emit(state.copyWith(joinToken: token, errorMessage: null));
      return token;
    }
    emit(state.copyWith(errorMessage: result['error']));
    return null;
  }

  Future<void> rotateTeamJoinToken(int teamId) async {
    final result = await _repository.rotateJoinToken(teamId);
    if (result.containsKey('token')) {
      emit(state.copyWith(joinToken: result['token']));
    }
  }

  Future<Map<String, dynamic>> sendEmailInvites(
      int teamId, List<Map<String, String>> invites) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    final result = await _repository.sendEmailInvites(teamId, invites);
    if (result.containsKey('sent')) {
      AppAnalytics.logEvent(
        'email_invites_sent',
        parameters: {'invite_count': invites.length},
      );
      emit(state.copyWith(status: OnboardingStatus.validated)); // Reset status
      return result;
    } else {
      emit(state.copyWith(
          status: OnboardingStatus.failure, errorMessage: result['error']));
      return result;
    }
  }

  Future<Map<String, dynamic>> resendPendingInvites(int teamId) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    final result = await _repository.resendPendingInvites(teamId);
    if (result.containsKey('sent')) {
      emit(state.copyWith(status: OnboardingStatus.validated));
      return result;
    }

    emit(state.copyWith(
      status: OnboardingStatus.failure,
      errorMessage: result['error'],
    ));
    return result;
  }

  Future<bool> createTeam({
    required String title,
    String? dbuCalendarUrl,
    Map<String, dynamic>? dbuContext,
    List<Map<String, dynamic>> matches = const [],
    List<Map<String, dynamic>> standings = const [],
    List<Map<String, String>> inviteEmails = const [],
  }) async {
    emit(state.copyWith(status: OnboardingStatus.loading, errorMessage: null));
    final result = await _repository.createTeam(
      title: title,
      dbuCalendarUrl: dbuCalendarUrl,
      dbuContext: dbuContext,
      matches: matches,
      standings: standings,
      inviteEmails: inviteEmails,
    );

    if (result['success'] == true) {
      AppAnalytics.logEvent(
        'team_created',
        parameters: {
          'has_dbu_calendar': dbuCalendarUrl?.isNotEmpty == true ? 1 : 0,
          'match_count': matches.length,
          'invite_count': inviteEmails.length,
        },
      );
      emit(state.copyWith(status: OnboardingStatus.success));
      return true;
    }

    emit(state.copyWith(
      status: OnboardingStatus.failure,
      errorMessage: result['error'] ?? 'Kunne ikke oprette holdet',
    ));
    return false;
  }

  Future<void> searchTeams(String query) async {
    if (query.trim().length < 2) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    emit(state.copyWith(status: OnboardingStatus.loading, errorMessage: null));
    final result = await _repository.searchTeams(query.trim());
    final teams = (result['teams'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    emit(state.copyWith(
      status: result.containsKey('error')
          ? OnboardingStatus.failure
          : OnboardingStatus.initial,
      searchResults: teams,
      errorMessage: result['error'],
    ));
  }

  Future<bool> requestToJoinTeam(int teamId) async {
    emit(state.copyWith(status: OnboardingStatus.loading, errorMessage: null));
    final result = await _repository.requestToJoinTeam(teamId);
    if (result['success'] == true) {
      AppAnalytics.logEvent('team_join_requested');
      final request = result['join_request'] as Map<String, dynamic>?;
      emit(state.copyWith(
        status: OnboardingStatus.waitingApproval,
        pendingJoinRequestId: request?['id'],
      ));
      return true;
    }

    emit(state.copyWith(
      status: OnboardingStatus.failure,
      errorMessage: result['error'] ?? 'Kunne ikke sende anmodning',
    ));
    return false;
  }

  Future<bool> restorePendingJoinRequest() async {
    emit(state.copyWith(errorMessage: null));
    final result = await _repository.getCurrentJoinRequest();
    if (result['success'] != true) {
      emit(state.copyWith(errorMessage: result['error']));
      return false;
    }

    final request = result['join_request'] as Map<String, dynamic>?;
    if (request == null || request['status'] != 'pending') {
      emit(state.copyWith(pendingJoinRequestId: null));
      return false;
    }

    emit(state.copyWith(
      status: OnboardingStatus.waitingApproval,
      pendingJoinRequestId: request['id'],
      teamId: request['team_id'],
      teamTitle: request['team_title'],
    ));
    return true;
  }

  Future<void> cancelPendingJoinRequest() async {
    final requestId = state.pendingJoinRequestId;
    if (requestId == null) return;

    emit(state.copyWith(status: OnboardingStatus.loading, errorMessage: null));
    final result = await _repository.cancelJoinRequest(requestId);
    if (result['success'] == true) {
      emit(state.copyWith(
        status: OnboardingStatus.initial,
        pendingJoinRequestId: null,
      ));
    } else {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: result['error'] ?? 'Kunne ikke annullere anmodning',
      ));
    }
  }

  void clearOnboarding() {
    emit(OnboardingState());
  }
}
