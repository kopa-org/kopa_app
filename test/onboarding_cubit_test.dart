import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/model/team_logo_design.dart';

void main() {
  for (final leader in [true, false]) {
    test('chosen role $leader reaches create, invite and request APIs',
        () async {
      final repository =
          _FakeOnboardingRepository(joinResult: {'success': true});
      final cubit = OnboardingCubit(repository);
      addTearDown(cubit.close);
      cubit.selectTeamRole(isTeamLeader: leader);
      expect(cubit.state.isTeamLeader, leader);
      expect(await cubit.createTeam(title: 'Role FC', playerCount: 7), isTrue);
      expect(repository.createdAsLeader, leader);
      cubit.emit(cubit.state.copyWith(inviteToken: 'invite'));
      expect(await cubit.joinTeamWithToken(), isTrue);
      expect(repository.joinedAsLeader, leader);
      expect(await cubit.requestToJoinTeam(42), isTrue);
      expect(repository.requestedAsLeader, leader);
    });
  }
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
  bool? createdAsLeader;
  bool? joinedAsLeader;
  bool? requestedAsLeader;
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
  Future<Map<String, dynamic>> joinTeam(String token,
      {bool isTeamLeader = false}) async {
    joinedAsLeader = isTeamLeader;
    return joinResult;
  }

  @override
  Future<Map<String, dynamic>> createTeam({
    required String title,
    required int playerCount,
    bool isTeamLeader = true,
    TeamLogoDesign? logoDesign,
    Map<String, dynamic>? dbuContext,
    List<Map<String, dynamic>> standings = const [],
  }) async {
    createdAsLeader = isTeamLeader;
    return {
      'success': true,
      'team': {'id': 42, 'title': title}
    };
  }

  @override
  Future<Map<String, dynamic>> requestToJoinTeam(int teamId,
      {bool isTeamLeader = false}) async {
    requestedAsLeader = isTeamLeader;
    return {
      'success': true,
      'join_request': {'id': 1, 'is_team_leader': isTeamLeader}
    };
  }

  @override
  Future<Map<String, dynamic>> getCurrentJoinRequest() async =>
      currentJoinRequestResult;
}
