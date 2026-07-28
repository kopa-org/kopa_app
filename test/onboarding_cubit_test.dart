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
}

class _FakeOnboardingRepository extends OnboardingRepository {
  final Map<String, dynamic> joinResult;

  _FakeOnboardingRepository({required this.joinResult});

  @override
  Future<Map<String, dynamic>> joinTeam(String token) async => joinResult;
}
