import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'imperative match notification route returns to the tab shell',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return Scaffold(body: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const _HomePage(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/match/details/:matchId',
            builder: (context, state) => _MatchDetailsPage(
              matchId: state.pathParameters['matchId']!,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      expect(find.text('Home'), findsOneWidget);

      final routeResult = router.push<void>('/match/details/42');
      await tester.pumpAndSettle();
      expect(find.text('Match 42'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('notification-match-back')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      await routeResult;
    },
  );
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Home'));
  }
}

class _MatchDetailsPage extends StatelessWidget {
  final String matchId;

  const _MatchDetailsPage({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IconButton(
            key: const ValueKey('notification-match-back'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          Text('Match $matchId'),
        ],
      ),
    );
  }
}
