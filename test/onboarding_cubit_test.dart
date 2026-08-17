import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/repository/onboarding_repository.dart';

void main() {
  test('joinTeamWithToken returns true and clears token on success', () async {
    final cubit = OnboardingCubit(_FakeOnboardingRepository(
      joinResult: {'success': true},
    ));

    cubit.emit(OnboardingState(inviteToken: 'invite-token'));

    final joined = await cubit.joinTeamWithToken();

    expect(joined, isTrue);
    expect(cubit.state.status, OnboardingStatus.success);
    expect(cubit.state.inviteToken, isNull);
  });

  test('joinTeamWithToken returns false and keeps token on failure', () async {
    final cubit = OnboardingCubit(_FakeOnboardingRepository(
      joinResult: {'success': false, 'error': 'Nope'},
    ));

    cubit.emit(OnboardingState(inviteToken: 'invite-token'));

    final joined = await cubit.joinTeamWithToken();

    expect(joined, isFalse);
    expect(cubit.state.status, OnboardingStatus.failure);
    expect(cubit.state.inviteToken, 'invite-token');
    expect(cubit.state.errorMessage, 'Nope');
  });

  test('restorePendingJoinRequest resumes waiting approval state', () async {
    final cubit = OnboardingCubit(_FakeOnboardingRepository(
      joinResult: {'success': true},
      currentJoinRequestResult: {
        'success': true,
        'join_request': {
          'id': 42,
          'status': 'pending',
          'team_id': 7,
          'team_title': 'Kopa FC',
          'leader_name': 'Owner',
        },
      },
    ));

    final restored = await cubit.restorePendingJoinRequest();

    expect(restored, isTrue);
    expect(cubit.state.status, OnboardingStatus.waitingApproval);
    expect(cubit.state.pendingJoinRequestId, 42);
    expect(cubit.state.teamId, 7);
    expect(cubit.state.teamTitle, 'Kopa FC');
    expect(cubit.state.teamLeaderName, 'Owner');
  });

  test('handleDeepLink stores validated team player count', () async {
    final cubit = OnboardingCubit(_FakeOnboardingRepository(
      joinResult: {'success': true},
      validateResult: {
        'valid': true,
        'team_id': 7,
        'team_title': 'Kopa FC',
        'player_count': 11,
      },
    ));

    await cubit.handleDeepLink('invite-token');

    expect(cubit.state.status, OnboardingStatus.validated);
    expect(cubit.state.teamId, 7);
    expect(cubit.state.teamPlayerCount, 11);
  });
}

class _FakeOnboardingRepository extends OnboardingRepository {
  final Map<String, dynamic> joinResult;
  final Map<String, dynamic> currentJoinRequestResult;
  final Map<String, dynamic> validateResult;

  _FakeOnboardingRepository({
    required this.joinResult,
    this.validateResult = const {'valid': false},
    this.currentJoinRequestResult = const {
      'success': true,
      'join_request': null,
    },
  });

  @override
  Future<Map<String, dynamic>> validateToken(String token) async =>
      validateResult;

  @override
  Future<Map<String, dynamic>> joinTeam(String token) async => joinResult;

  @override
  Future<Map<String, dynamic>> getCurrentJoinRequest() async =>
      currentJoinRequestResult;
}
