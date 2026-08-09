import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/pages/onboarding_page.dart';
import 'package:kopa/pages/register_page.dart';

void main() {
  group('AppRouter.initialLocationFromPlatformRoute', () {
    test('normalizes cold-start shared team links from iOS universal links',
        () {
      final location = AppRouter.initialLocationFromPlatformRoute(
        'https://kopa.dk/join?team_token=abc123&team_id=7&team_title=Kopa%20FC',
      );

      expect(
        location,
        '/join?team_token=abc123&team_id=7&team_title=Kopa+FC',
      );
    });

    test('normalizes cold-start invite links from the custom iOS scheme', () {
      final location = AppRouter.initialLocationFromPlatformRoute(
        'kopa:///invite?token=invite-token&team_title=Kopa%20FC',
      );

      expect(location, '/invite?token=invite-token&team_title=Kopa+FC');
    });

    test('normalizes custom scheme links that put the route in the host', () {
      final location = AppRouter.initialLocationFromPlatformRoute(
        'kopa://join?team_token=abc123&team_title=Kopa%20FC',
      );

      expect(location, '/join?team_token=abc123&team_title=Kopa+FC');
    });

    test('ignores normal app launches', () {
      final location = AppRouter.initialLocationFromPlatformRoute('/');

      expect(location, isNull);
    });
  });

  group('AppRouter.redirectPathFor', () {
    test('starts restored teamless users on onboarding', () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.home,
        authState: AuthState(
          status: AuthStatus.authenticated,
          user: _user(),
        ),
      );

      expect(redirect, AppRouter.onboarding);
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

    test('uses backend waiting approval state when onboarding cubit is empty',
        () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.login,
        authState: AuthState(
          status: AuthStatus.authenticated,
          user: _user(
            onboardingState: const UserOnboardingState(
              status: 'waiting_approval',
              joinRequest: UserPendingJoinRequest(
                id: 12,
                status: 'pending',
                teamId: 7,
                teamTitle: 'Kopa FC',
              ),
            ),
          ),
        ),
        onboardingState: OnboardingState(),
      );

      expect(redirect, AppRouter.onboarding);
    });

    test('sends teamless users away from login to onboarding', () {
      final redirect = AppRouter.redirectPathFor(
        path: AppRouter.login,
        authState: AuthState(
          status: AuthStatus.authenticated,
          user: _user(
            onboardingState: const UserOnboardingState(
              status: 'needs_onboarding',
            ),
          ),
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

UserDetails _user({
  TeamDetails? teamDetails,
  UserOnboardingState? onboardingState,
}) {
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
    onboardingState: onboardingState,
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
