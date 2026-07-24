import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/page/in_form/in_form_page.dart';
import 'package:kopa/page/match/match_programme.dart';
import 'package:kopa/page/player_plus/player_plus_page.dart';
import 'package:kopa/page/profile/dbu_webview_page.dart';
import 'package:kopa/page/team_fines/team_fines_page.dart';
import 'package:kopa/page/statistics/statistics_page.dart';
import 'package:kopa/pages/login_page.dart';
import 'package:kopa/pages/onboarding_page.dart';
import 'package:kopa/pages/register_page.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/tab/profile_tab.dart';
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
  static const fineBox = '/fine-box';
  static const dbuWebview = '/dbu-webview';
  static const invite = '/invite';
  static const join = '/join';
  static const onboarding = '/onboarding';

  static GoRouter create({
    required AuthCubit authCubit,
    required OnboardingCubit onboardingCubit,
    required AppFeatureFlags featureFlags,
    required Listenable refreshListenable,
  }) {
    final visibleMainTabs = _visibleMainTabs(featureFlags);
    final branchNavigatorKeys = List.generate(
        visibleMainTabs.length, (_) => GlobalKey<NavigatorState>());

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
          builder: (context, state) => DbuWebviewPage(
            operation: state.extra is DbuWebviewOperation
                ? state.extra! as DbuWebviewOperation
                : DbuWebviewOperation.fullImport,
          ),
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
        if (!featureFlags.showStatistics)
          GoRoute(
            path: statistics,
            builder: (context, state) => const StatisticsPage(),
          ),
        if (!featureFlags.showFineBox)
          GoRoute(
            path: fineBox,
            builder: (context, state) => const TeamFinesPage(),
          ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            final theme = Theme.of(context);
            final tabs = visibleMainTabs;
            void selectTab(int index) {
              final isCurrentTab = index == navigationShell.currentIndex;
              AppAnalytics.logEvent(
                'main_tab_selected',
                parameters: {
                  'tab_name': tabs[index].analyticsName,
                },
              );
              if (isCurrentTab) {
                branchNavigatorKeys[index]
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
                  tabs: [
                    for (final tab in tabs)
                      GlassTab(
                        icon: Icon(tab.cupertinoIcon),
                        activeIcon: Icon(tab.activeCupertinoIcon),
                        label: tab.label,
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
                            icon: tabs[i].materialIcon,
                            leading: tabs[i].assetPath == null
                                ? Icon(
                                    tabs[i].materialIcon,
                                    size: 24,
                                    color: navigationShell.currentIndex == i
                                        ? theme.colorScheme.primary
                                        : theme.unselectedWidgetColor,
                                  )
                                : SvgPicture.asset(
                                    tabs[i].assetPath!,
                                    width: 24,
                                    height: 24,
                                    colorFilter: ColorFilter.mode(
                                      navigationShell.currentIndex == i
                                          ? theme.colorScheme.primary
                                          : theme.unselectedWidgetColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                            text: tabs[i].label,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          branches: [
            for (int i = 0; i < visibleMainTabs.length; i++)
              StatefulShellBranch(
                navigatorKey: branchNavigatorKeys[i],
                routes: [
                  GoRoute(
                    path: visibleMainTabs[i].path,
                    builder: (context, state) => visibleMainTabs[i].page,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  static List<_MainTab> _visibleMainTabs(AppFeatureFlags featureFlags) {
    return [
      _MainTab.home,
      _MainTab.matches,
      if (featureFlags.showStatistics) _MainTab.statistics,
      _MainTab.squad,
      if (featureFlags.showFineBox) _MainTab.fineBox,
    ];
  }
}

enum _MainTab {
  home,
  matches,
  statistics,
  squad,
  fineBox;

  String get path {
    return switch (this) {
      _MainTab.home => AppRouter.home,
      _MainTab.matches => AppRouter.match,
      _MainTab.statistics => AppRouter.statistics,
      _MainTab.squad => AppRouter.profile,
      _MainTab.fineBox => AppRouter.fineBox,
    };
  }

  Widget get page {
    return switch (this) {
      _MainTab.home => HomeTab(),
      _MainTab.matches => MatchProgrammePage(),
      _MainTab.statistics => const StatisticsPage(),
      _MainTab.squad => const ProfileTab(),
      _MainTab.fineBox => const TeamFinesPage(showBackButton: false),
    };
  }

  IconData get materialIcon {
    return switch (this) {
      _MainTab.home => Icons.home,
      _MainTab.matches => Icons.sports_soccer,
      _MainTab.statistics => Icons.bar_chart,
      _MainTab.squad => Icons.groups_outlined,
      _MainTab.fineBox => CupertinoIcons.money_dollar_circle,
    };
  }

  IconData get cupertinoIcon {
    return switch (this) {
      _MainTab.home => CupertinoIcons.house,
      _MainTab.matches => CupertinoIcons.sportscourt,
      _MainTab.statistics => CupertinoIcons.chart_bar,
      _MainTab.squad => CupertinoIcons.group,
      _MainTab.fineBox => CupertinoIcons.money_dollar_circle,
    };
  }

  IconData get activeCupertinoIcon {
    return switch (this) {
      _MainTab.home => CupertinoIcons.house_fill,
      _MainTab.matches => CupertinoIcons.sportscourt_fill,
      _MainTab.statistics => CupertinoIcons.chart_bar_fill,
      _MainTab.squad => CupertinoIcons.group_solid,
      _MainTab.fineBox => CupertinoIcons.money_dollar_circle_fill,
    };
  }

  String? get assetPath {
    return switch (this) {
      _MainTab.home => 'assets/logos/home-simple-door.svg',
      _MainTab.matches => 'assets/logos/soccer-ball.svg',
      _MainTab.statistics => 'assets/logos/graph-up.svg',
      _MainTab.squad => null,
      _MainTab.fineBox => 'assets/logos/piggy-bank.svg',
    };
  }

  String get label {
    return switch (this) {
      _MainTab.home => 'Hjem',
      _MainTab.matches => 'Kampe',
      _MainTab.statistics => 'Statistik',
      _MainTab.squad => 'Truppen',
      _MainTab.fineBox => 'Bødekasse',
    };
  }

  String get analyticsName {
    return switch (this) {
      _MainTab.home => 'home',
      _MainTab.matches => 'matches',
      _MainTab.statistics => 'statistics',
      _MainTab.squad => 'squad',
      _MainTab.fineBox => 'fine_box',
    };
  }
}
