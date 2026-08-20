import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/avatar/team_avatar.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/model/team_logo_design.dart';

void main() {
  testWidgets('uses the selected logo shape for the avatar shell', (
    tester,
  ) async {
    for (final shape in TeamLogoShape.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: TeamBadgeLabel(
              teamName: 'Kopa FC',
              teamId: 1,
              logoDesign: TeamLogoDesign(shape: shape),
            ),
          ),
        ),
      );

      final shapeDecorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((decoratedBox) => decoratedBox.decoration)
          .whereType<ShapeDecoration>()
          .toList();

      expect(shapeDecorations, hasLength(1));
      expect(
        shapeDecorations.single.shape,
        TeamLogoShapeBorder(shape),
      );
      expect(find.byType(ClipPath), findsOneWidget);
    }
  });
}
