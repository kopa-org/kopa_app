import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/theme/spacing.dart';

void main() {
  testWidgets('uses the shared Home card radius', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeBentoCard(child: SizedBox.shrink()),
        ),
      ),
    );

    expect(HomeBentoCard.cardRadius, Spacing.borderRadiusLarge);
    expect(
      tester.widget<KopaCard>(find.byType(KopaCard)).borderRadius,
      HomeBentoCard.cardRadius,
    );
  });
}
