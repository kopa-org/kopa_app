import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';

void main() {
  group('AppRouter.redirectPathFor', () {
    test('starts restored teamless users on login instead of onboarding', () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.home,
        authState: AuthState(
          status: AuthStatus.authenticated,
          user: _user(),
        ),
      );

      expect(redirect, AppRouter.login);
    });

    test('keeps explicit onboarding available for restored teamless users', () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.onboarding,
        authState: AuthState(
          status: AuthStatus.authenticated,
          user: _user(),
        ),
      );

      expect(redirect, isNull);
    });

    test('sends authenticated users with teams away from login', () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.login,
        authState: AuthState(
          status: AuthStatus.authenticated,
          user: _user(teamDetails: _team()),
        ),
      );

      expect(redirect, AppRouter.home);
    });
  });
}

UserDetails _user({TeamDetails? teamDetails}) {
  final now = DateTime(2026, 7, 28);
  return UserDetails(
    id: 1,
    name: 'Player',
    email: 'player@example.com',
    isTeamOwner: false,
    roleId: 2,
    createdAt: now,
    updatedAt: now,
    teamDetails: teamDetails,
  );
}

TeamDetails _team() {
  final now = DateTime(2026, 7, 28);
  return TeamDetails(
    id: 1,
    title: 'Kopa FC',
    createdAt: now,
    updatedAt: now,
  );
}
