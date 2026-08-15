import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('tab scaffold owns title actions and back button policy',
      (tester) async {
    var actionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.android,
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: PageScaffold.tab(
          title: 'Kampe',
          trailing: [
            IconButton(
              key: const ValueKey('tab-action'),
              onPressed: () => actionPressed = true,
              icon: const Icon(Icons.add),
            ),
          ],
          body: const Text('Indhold'),
        ),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Kampe'), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.text('Indhold'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-action')));
    await tester.pump();

    expect(actionPressed, isTrue);
  });

  testWidgets('tab scaffold applies the same policy on iOS', (tester) async {
    var actionPressed = false;
    var fabPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.iOS,
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: PageScaffold.tab(
          title: 'Kopa',
          titleWidget: const Icon(
            Icons.shield_outlined,
            key: ValueKey('custom-tab-title'),
          ),
          trailing: [
            IconButton(
              key: const ValueKey('ios-tab-action'),
              onPressed: () => actionPressed = true,
              icon: const Icon(Icons.settings),
            ),
          ],
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('ios-fab'),
            onPressed: () => fabPressed = true,
            child: const Icon(Icons.add),
          ),
          body: const Text('Indhold'),
        ),
      ),
    );

    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byKey(const ValueKey('custom-tab-title')), findsOneWidget);
    expect(find.text('Kopa'), findsNothing);
    expect(find.byIcon(CupertinoIcons.back), findsNothing);
    expect(find.text('Indhold'), findsOneWidget);
    expect(find.byKey(const ValueKey('ios-fab')), findsOneWidget);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Indhold')))
          .style
          .decoration,
      TextDecoration.none,
    );

    await tester.tap(find.byKey(const ValueKey('ios-tab-action')));
    await tester.pump();

    expect(actionPressed, isTrue);

    await tester.tap(find.byKey(const ValueKey('ios-fab')));
    await tester.pump();

    expect(fabPressed, isTrue);
  });

  testWidgets('tab scaffold removes an empty top bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.android,
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: const PageScaffold.tab(
          title: 'Statistik',
          body: Text('Indhold'),
        ),
      ),
    );

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Statistik'), findsNothing);
    expect(find.text('Indhold'), findsOneWidget);
  });
}
