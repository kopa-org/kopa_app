import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repositories/auth_repository.dart';

void main() {
  test('updateUser keeps authentication and replaces the current user', () {
    final cubit = AuthCubit(authRepository: _FakeAuthRepository());
    final user = _user(position: 'striker');

    cubit.updateUser(user);

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, same(user));
    expect(cubit.state.user?.position, 'striker');
  });
}

UserDetails _user({String? position}) {
  final now = DateTime(2026, 6, 12);
  return UserDetails(
    id: 1,
    name: 'Player',
    email: 'player@example.com',
    isTeamOwner: false,
    roleId: 2,
    position: position,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserDetails?> getCurrentUser() async => null;

  @override
  Future<bool> login(String email, String password) async => false;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async =>
      false;
}
