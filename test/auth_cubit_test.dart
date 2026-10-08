import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final cleanupError in <Exception?>[
    null,
    Exception('Failed to unregister push token'),
    TimeoutException('Push token request timed out'),
  ]) {
    test('logout clears the session with push cleanup result: $cleanupError',
        () async {
      FlutterSecureStorage.setMockInitialValues({
        'token': 'test-session',
        'pushToken': 'test-push-token',
        'hasAuthenticatedBefore': 'true',
        'name': 'Player',
      });
      var cleanupAttempted = false;
      final cubit = AuthCubit(
        authRepository: ApiAuthRepository(),
        unregisterPushToken: () async {
          // Remote cleanup must run before deleting its auth credentials.
          expect(await SecureStorageService.getToken(), 'test-session');
          cleanupAttempted = true;
          if (cleanupError != null) throw cleanupError;
        },
      )..updateUser(_user());
      addTearDown(cubit.close);

      await cubit.logout();

      expect(cleanupAttempted, isTrue);
      expect(await SecureStorageService.getToken(), isNull);
      expect(await SecureStorageService.getPushToken(), isNull);
      expect(await SecureStorageService.getUserInfo(), isNull);
      expect(await SecureStorageService.hasAuthenticatedBefore(), isTrue);
      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
      expect(
        AppRouter.redirectPathFor(
          path: '/profile/settings',
          authState: cubit.state,
        ),
        AppRouter.login,
      );
    });
  }

  test('logout reports a local session cleanup failure without signing out',
      () async {
    final user = _user();
    final cubit = AuthCubit(
      authRepository: _FakeAuthRepository(failLogout: true),
      unregisterPushToken: () async {},
    )..updateUser(user);
    addTearDown(cubit.close);

    await expectLater(cubit.logout(), throwsStateError);

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, same(user));
  });

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
  final bool failLogout;

  _FakeAuthRepository({this.failLogout = false});

  @override
  Future<UserDetails?> getCurrentUser() async => null;

  @override
  Future<bool> login(String email, String password) async => false;

  @override
  Future<void> logout() async {
    if (failLogout) throw StateError('Local session cleanup failed');
  }

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async =>
      false;
}
