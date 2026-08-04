import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/pages/onboarding_page.dart';
import 'package:kopa/pages/register_page.dart';

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

    test('restores teamless users with a pending join request to onboarding',
        () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.home,
        authState: AuthState(
          status: AuthStatus.authenticated,
          user: _user(),
        ),
        onboardingState: OnboardingState(
          status: OnboardingStatus.waitingApproval,
          pendingJoinRequestId: 12,
        ),
      );

      expect(redirect, AppRouter.onboarding);
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

    test('keeps unauthenticated join links on the explicit join route', () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.join,
        authState: const AuthState(),
      );

      expect(redirect, isNull);
    });
  });

  group('AppRouter.inviteEntryPageFor', () {
    test('starts unauthenticated join links at signup', () {
      final page = AppRouter.inviteEntryPageFor(const AuthState());

      expect(page, isA<RegisterPage>());
    });

    test('starts authenticated join links at onboarding', () {
      final page = AppRouter.inviteEntryPageFor(AuthState(
        status: AuthStatus.authenticated,
        user: _user(),
      ));

      expect(page, isA<OnboardingPage>());
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
