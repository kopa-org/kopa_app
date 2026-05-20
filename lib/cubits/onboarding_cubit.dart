import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/repository/onboarding_repository.dart';

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

  Future<void> handleDeepLink(String token) async {
    emit(state.copyWith(status: OnboardingStatus.loading, inviteToken: token));

    final result = await _repository.validateToken(token);

    if (result['valid'] == true) {
      emit(state.copyWith(
        status: OnboardingStatus.validated,
        email: result['email'],
        teamId: result['team_id'],
        teamTitle: result['team_title'],
      ));
    } else {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: result['error'] ?? 'Ugyldig invitation',
      ));
    }
  }

  Future<void> joinTeamWithToken() async {
    if (state.inviteToken == null) return;

    emit(state.copyWith(status: OnboardingStatus.loading));
    final result = await _repository.joinTeam(state.inviteToken!);

    if (result['success'] == true) {
      emit(state.copyWith(status: OnboardingStatus.success, inviteToken: null));
    } else {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: result['error'],
      ));
    }
  }

  Future<void> fetchTeamJoinToken(int teamId) async {
    final result = await _repository.getJoinToken(teamId);
    if (result.containsKey('token')) {
      emit(state.copyWith(joinToken: result['token']));
    }
  }

  Future<void> rotateTeamJoinToken(int teamId) async {
    final result = await _repository.rotateJoinToken(teamId);
    if (result.containsKey('token')) {
      emit(state.copyWith(joinToken: result['token']));
    }
  }

  Future<Map<String, dynamic>> sendEmailInvites(
      int teamId, List<String> emails) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    final result = await _repository.sendEmailInvites(teamId, emails);
    if (result.containsKey('sent')) {
      emit(state.copyWith(status: OnboardingStatus.validated)); // Reset status
      return result;
    } else {
      emit(state.copyWith(
          status: OnboardingStatus.failure, errorMessage: result['error']));
      return result;
    }
  }

  Future<bool> createTeam({
    required String title,
    String? dbuCalendarUrl,
    List<Map<String, dynamic>> matches = const [],
    List<Map<String, dynamic>> standings = const [],
    List<String> inviteEmails = const [],
  }) async {
    emit(state.copyWith(status: OnboardingStatus.loading, errorMessage: null));
    final result = await _repository.createTeam(
      title: title,
      dbuCalendarUrl: dbuCalendarUrl,
      matches: matches,
      standings: standings,
      inviteEmails: inviteEmails,
    );

    if (result['success'] == true) {
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
