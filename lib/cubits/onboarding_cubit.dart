import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/repository/onboarding_repository.dart';

enum OnboardingStatus { initial, loading, success, failure, validated }

class OnboardingState {
  final OnboardingStatus status;
  final String? inviteToken;
  final String? email;
  final int? teamId;
  final String? teamTitle;
  final String? errorMessage;
  final String? joinToken; // Generic team join token for sharing

  OnboardingState({
    this.status = OnboardingStatus.initial,
    this.inviteToken,
    this.email,
    this.teamId,
    this.teamTitle,
    this.errorMessage,
    this.joinToken,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? inviteToken,
    String? email,
    int? teamId,
    String? teamTitle,
    String? errorMessage,
    String? joinToken,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      inviteToken: inviteToken ?? this.inviteToken,
      email: email ?? this.email,
      teamId: teamId ?? this.teamId,
      teamTitle: teamTitle ?? this.teamTitle,
      errorMessage: errorMessage ?? this.errorMessage,
      joinToken: joinToken ?? this.joinToken,
    );
  }
}

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

  Future<Map<String, dynamic>> sendEmailInvites(int teamId, List<String> emails) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    final result = await _repository.sendEmailInvites(teamId, emails);
    if (result.containsKey('sent')) {
      emit(state.copyWith(status: OnboardingStatus.validated)); // Reset status
      return result;
    } else {
      emit(state.copyWith(status: OnboardingStatus.failure, errorMessage: result['error']));
      return result;
    }
  }

  void clearOnboarding() {
    emit(OnboardingState());
  }
}
