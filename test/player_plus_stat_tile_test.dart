import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/card/player_plus_stat_tile.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('uses custom background color without a border', (tester) async {
    const backgroundColor = Color(0xFFEAF6F0);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          body: PlayerPlusStatTile(
            data: PlayerPlusStatTileData(
              title: 'Mål',
              value: '12',
              rank: 2,
              icon: Icons.sports_score,
              accentColor: Colors.blue,
              backgroundColor: backgroundColor,
            ),
          ),
        ),
      ),
    );

    final tileDecorations = tester
        .widgetList<Container>(find.byType(Container))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>();

    expect(
      tileDecorations,
      anyElement(
        isA<BoxDecoration>()
            .having((decoration) => decoration.color, 'color', backgroundColor)
            .having(
              (decoration) => decoration.border,
              'border',
              isNull,
            ),
      ),
    );
  });

  testWidgets('does not show buy prompt when locked tile is tapped',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          body: PlayerPlusStatTile(
            locked: true,
            data: PlayerPlusStatTileData(
              title: 'Mål',
              value: '12',
              rank: 2,
              icon: Icons.sports_score,
              accentColor: Colors.blue,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mål'));
    await tester.pumpAndSettle();

    expect(find.text('Player+ påkrævet'), findsNothing);
    expect(find.text('Køb Player+'), findsNothing);
  });
}
