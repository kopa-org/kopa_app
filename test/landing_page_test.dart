import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/pages/landing_page.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('landing actions route to register and login', (tester) async {
    final router = GoRouter(
      initialLocation: AppRouter.welcome,
      routes: [
        GoRoute(
          path: AppRouter.welcome,
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: AppRouter.register,
          builder: (context, state) => const _RouteMarker('register'),
        ),
        GoRoute(
          path: AppRouter.login,
          builder: (context, state) => const _RouteMarker('login'),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );

    expect(find.text('Saml dit hold\nét sted'), findsOneWidget);

    await tester.tap(find.text('Opret konto'));
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    expect(find.text('register'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Saml dit hold\nét sted'), findsOneWidget);

    await tester.tap(find.text('Log ind'));
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    expect(find.text('login'), findsOneWidget);
  });
}

class _RouteMarker extends StatelessWidget {
  final String label;

  const _RouteMarker(this.label);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(label));
  }
}
