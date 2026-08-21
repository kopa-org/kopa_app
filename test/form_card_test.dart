import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/page/statistics/widgets/form_card.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('keeps played form results left aligned', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: const Scaffold(
          body: FormCard(lastFiveMatchesForm: [1, -1]),
        ),
      ),
    );

    final winCenter = tester.getCenter(find.text('V'));
    final lossCenter = tester.getCenter(find.text('T'));

    expect(lossCenter.dx, greaterThan(winCenter.dx));
    expect(lossCenter.dx - winCenter.dx, lessThan(100));
  });
}
