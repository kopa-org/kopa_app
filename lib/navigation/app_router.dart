import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/pages/login_page.dart';
import 'package:kopa/pages/register_page.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/tab/profile_tab.dart';
import 'package:kopa/page/profile/dbu_webview_page.dart';
import 'package:kopa/page/statistics/statistics_page.dart';
import 'package:kopa/page/match/match_programme.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const match = '/match';
  static const statistics = '/statistics';
  static const profile = '/profile';
  static const dbuWebview = '/dbu-webview';

  static GoRouter create({
    required AuthCubit authCubit,
    required Listenable refreshListenable,
  }) {
    return GoRouter(
      initialLocation: home,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoggedIn = authState.status == AuthStatus.authenticated;
        final isLoggingIn = state.uri.path == login;
        final isRegistering = state.uri.path == register;

        if (!isLoggedIn && !isLoggingIn && !isRegistering) return login;
        if (isLoggedIn && (isLoggingIn || isRegistering)) return home;

        return null;
      },
      routes: [
        GoRoute(
          path: dbuWebview,
          builder: (context, state) => const DbuWebviewPage(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                    child: GNav(
                      rippleColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      hoverColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      gap: 8,
                      activeColor: theme.colorScheme.primary,
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      color: theme.unselectedWidgetColor,
                      selectedIndex: navigationShell.currentIndex,
                      onTabChange: (index) {
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
}
