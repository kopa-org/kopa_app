import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/page/in_form/in_form_page.dart';
import 'package:kopa/page/match/match_programme.dart';
import 'package:kopa/page/player_plus/player_plus_page.dart';
import 'package:kopa/page/profile/dbu_webview_page.dart';
import 'package:kopa/page/statistics/statistics_page.dart';
import 'package:kopa/pages/login_page.dart';
import 'package:kopa/pages/onboarding_page.dart';
import 'package:kopa/pages/register_page.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/tab/profile_tab.dart';
import 'package:kopa/tab/settings_tab.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

abstract final class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const match = '/match';
  static const statistics = '/statistics';
  static const playerPlus = '/player-plus';
  static const playerPlusInForm = '/player-plus/in-form';
  static const profile = '/profile';
  static const settings = '/settings';
  static const dbuWebview = '/dbu-webview';
  static const invite = '/invite';
  static const join = '/join';
  static const onboarding = '/onboarding';

  static final List<GlobalKey<NavigatorState>> _branchNavigatorKeys =
      List.generate(5, (_) => GlobalKey<NavigatorState>());

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
          path: '$playerPlus/in-form',
          builder: (context, state) => const InFormPage(),
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
            const tabs = [
              (Icons.home, 'Hjem', 'assets/logos/home-simple-door.svg'),
              (Icons.sports_soccer, 'Kampe', 'assets/logos/soccer-ball.svg'),
              (Icons.bar_chart, 'Statistik', 'assets/logos/graph-up.svg'),
              (Icons.person, 'Profil', 'assets/logos/piggy-bank.svg'),
              (
                CupertinoIcons.gear_alt,
                'Settings',
                'assets/logos/settings-gear.svg'
              ),
            ];
            void selectTab(int index) {
              final isCurrentTab = index == navigationShell.currentIndex;
              AppAnalytics.logEvent(
                'main_tab_selected',
                parameters: {
                  'tab_name': _tabNameForIndex(index),
                },
              );
              if (isCurrentTab) {
                _branchNavigatorKeys[index]
                    .currentState
                    ?.popUntil((route) => route.isFirst);
              }
              navigationShell.goBranch(
                index,
                initialLocation: isCurrentTab,
              );
            }

            if (theme.platform == TargetPlatform.iOS) {
              return Scaffold(
                extendBody: true,
                body: navigationShell,
                bottomNavigationBar: GlassTabBar.bottom(
                  selectedIndex: navigationShell.currentIndex,
                  onTabSelected: selectTab,
                  selectedIconColor: theme.colorScheme.primary,
                  selectedLabelColor: theme.colorScheme.primary,
                  unselectedIconColor: theme.unselectedWidgetColor,
                  unselectedLabelColor: theme.unselectedWidgetColor,
                  indicatorColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  tabs: const [
                    GlassTab(
                      icon: Icon(CupertinoIcons.house),
                      activeIcon: Icon(CupertinoIcons.house_fill),
                      label: 'Hjem',
                    ),
                    GlassTab(
                      icon: Icon(CupertinoIcons.sportscourt),
                      activeIcon: Icon(CupertinoIcons.sportscourt_fill),
                      label: 'Kampe',
                    ),
                    GlassTab(
                      icon: Icon(CupertinoIcons.chart_bar),
                      activeIcon: Icon(CupertinoIcons.chart_bar_fill),
                      label: 'Statistik',
                    ),
                    GlassTab(
                      icon: Icon(CupertinoIcons.person),
                      activeIcon: Icon(CupertinoIcons.person_fill),
                      label: 'Profil',
                    ),
                    GlassTab(
                      icon: Icon(CupertinoIcons.gear),
                      activeIcon: Icon(CupertinoIcons.gear_solid),
                      label: 'Settings',
                    ),
                  ],
                ),
              );
            }

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
                      horizontal: 8.0,
                      vertical: 8,
                    ),
                    child: GNav(
                      rippleColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      hoverColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      gap: 8,
                      activeColor: theme.colorScheme.primary,
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      color: theme.unselectedWidgetColor,
                      selectedIndex: navigationShell.currentIndex,
                      onTabChange: selectTab,
                      tabs: [
                        for (int i = 0; i < tabs.length; i++)
                          GButton(
                            icon: tabs[i].$1,
                            leading: SvgPicture.asset(
                              tabs[i].$3,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                navigationShell.currentIndex == i
                                    ? theme.colorScheme.primary
                                    : theme.unselectedWidgetColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            text: tabs[i].$2,
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
              navigatorKey: _branchNavigatorKeys[0],
              routes: [
                GoRoute(
                  path: home,
                  builder: (context, state) => HomeTab(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _branchNavigatorKeys[1],
              routes: [
                GoRoute(
                  path: match,
                  builder: (context, state) => MatchProgrammePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _branchNavigatorKeys[2],
              routes: [
                GoRoute(
                  path: statistics,
                  builder: (context, state) => const StatisticsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _branchNavigatorKeys[3],
              routes: [
                GoRoute(
                  path: profile,
                  builder: (context, state) => const ProfileTab(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _branchNavigatorKeys[4],
              routes: [
                GoRoute(
                  path: settings,
                  builder: (context, state) => const SettingsTab(),
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
      4 => 'settings',
      _ => 'unknown',
    };
  }
}
