import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/pages/login_page.dart';
import 'package:kopa/pages/onboarding_page.dart';
import 'package:kopa/pages/register_page.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/tab/profile_tab.dart';
import 'package:kopa/page/profile/dbu_webview_page.dart';
import 'package:kopa/page/player_plus/player_plus_page.dart';
import 'package:kopa/page/statistics/statistics_page.dart';
import 'package:kopa/page/match/match_programme.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const match = '/match';
  static const statistics = '/statistics';
  static const playerPlus = '/player-plus';
  static const profile = '/profile';
  static const dbuWebview = '/dbu-webview';
  static const invite = '/invite';
  static const join = '/join';
  static const onboarding = '/onboarding';

  static GoRouter create({
    required AuthCubit authCubit,
    required OnboardingCubit onboardingCubit,
    required Listenable refreshListenable,
  }) {
    return GoRouter(
      initialLocation: home,
      refreshListenable: refreshListenable,
      observers: AppAnalytics.routeObservers,
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoggedIn = authState.status == AuthStatus.authenticated;
        final isLoggingIn = state.uri.path == login;
        final isRegistering = state.uri.path == register;
        final isInvite = state.uri.path == invite;
        final isJoin = state.uri.path == join;
        final isOnboarding = state.uri.path == onboarding;
        final hasTeam = authState.user?.teamDetails != null;

        if (!isLoggedIn &&
            !isLoggingIn &&
            !isRegistering &&
            !isInvite &&
            !isJoin) {
          return login;
        }
        if (isLoggedIn && (isLoggingIn || isRegistering)) {
          return home;
        }
        if (isLoggedIn &&
            !hasTeam &&
            !isOnboarding &&
            !isInvite &&
            !isJoin &&
            state.uri.path != dbuWebview) {
          return onboarding;
        }
        if (isLoggedIn && hasTeam && isOnboarding) return home;

        return null;
      },
      routes: [
        GoRoute(
          path: invite,
          builder: (context, state) {
            final token = state.uri.queryParameters['token'];
            if (token != null) {
              onboardingCubit.handleDeepLink(token);
            }
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: join,
          builder: (context, state) {
            final token = state.uri.queryParameters['team_token'];
            if (token != null) {
              onboardingCubit.handleDeepLink(token);
            }
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: dbuWebview,
          builder: (context, state) => const DbuWebviewPage(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: playerPlus,
          builder: (context, state) => const PlayerPlusPage(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            final theme = Theme.of(context);
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withValues(alpha: .1),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8),
                    child: GNav(
                      rippleColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      hoverColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      gap: 8,
                      activeColor: theme.colorScheme.primary,
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      color: theme.unselectedWidgetColor,
                      selectedIndex: navigationShell.currentIndex,
                      onTabChange: (index) {
                        AppAnalytics.logEvent(
                          'main_tab_selected',
                          parameters: {
                            'tab_name': _tabNameForIndex(index),
                          },
                        );
                        navigationShell.goBranch(index);
                      },
                      tabs: [
                        GButton(
                          icon: Icons.home,
                          leading: SvgPicture.asset(
                            'assets/logos/home-simple-door.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              navigationShell.currentIndex == 0
                                  ? theme.colorScheme.primary
                                  : theme.unselectedWidgetColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          text: 'Hjem',
                        ),
                        GButton(
                          icon: Icons.sports_soccer,
                          leading: SvgPicture.asset(
                            'assets/logos/soccer-ball.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              navigationShell.currentIndex == 1
                                  ? theme.colorScheme.primary
                                  : theme.unselectedWidgetColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          text: 'Kampe',
                        ),
                        GButton(
                          icon: Icons.bar_chart,
                          leading: SvgPicture.asset(
                            'assets/logos/graph-up.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              navigationShell.currentIndex == 2
                                  ? theme.colorScheme.primary
                                  : theme.unselectedWidgetColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          text: 'Statistik',
                        ),
                        GButton(
                          icon: Icons.person,
                          leading: SvgPicture.asset(
                            'assets/logos/piggy-bank.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              navigationShell.currentIndex == 3
                                  ? theme.colorScheme.primary
                                  : theme.unselectedWidgetColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          text: 'Profil',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: home,
                  builder: (context, state) => HomeTab(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: match,
                  builder: (context, state) => MatchProgrammePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: statistics,
                  builder: (context, state) => const StatisticsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: profile,
                  builder: (context, state) => const ProfileTab(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static String _tabNameForIndex(int index) {
    return switch (index) {
      0 => 'home',
      1 => 'matches',
      2 => 'statistics',
      3 => 'profile',
      _ => 'unknown',
    };
  }
}
