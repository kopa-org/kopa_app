import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/pages/login_page.dart';
import 'package:kopa/pages/register_page.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/tab/profile_tab.dart';

abstract final class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const profile = '/profile';

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
          path: login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) => navigationShell.goBranch(index),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
                ],
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
