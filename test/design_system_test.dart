import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:kopa/theme/design_system_preview.dart';

void main() {
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets(
      'long actions wrap at large text sizes and preserve disabled state',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var taps = 0;
    Future<void> show({bool enabled = true, bool loading = false}) =>
        tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
                body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Button(
                  buttonText: 'Tilmeld dig kampen med dit hold',
                  width: double.infinity,
                  icon: Icons.check,
                  onPressed: () => taps++,
                  enabled: enabled,
                  loading: loading,
                ),
              ),
            )),
          ),
        );
    await show();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48));
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
    await show(enabled: false);
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
    await show(loading: true);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
  });

  testWidgets('solid action colors can use the grass token', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Button(
            buttonText: 'Opret lånespiller',
            backgroundColor: AppColors.light.grass,
            foregroundColor: AppColors.light.white,
            onPressed: () {},
          ),
        ),
      ),
    );

    final style = tester.widget<FilledButton>(find.byType(FilledButton)).style!;
    expect(style.backgroundColor?.resolve({}), AppColors.light.grass);
    expect(style.foregroundColor?.resolve({}), AppColors.light.white);
  });

  testWidgets('cards remain tappable after surface consolidation',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
          body: KopaCard(onTap: () => taps++, child: const Text('Team'))),
    ));
    await tester.tap(find.text('Team'));
    expect(taps, 1);
  });

  test('semantic text pairs have at least 4.5:1 contrast', () {
    const colors = AppColors.light;
    final pairs = [
      (colors.dirt, colors.lightGrass),
      (colors.textSecondary, colors.background),
      (colors.textSecondary, colors.surface),
      (colors.successForeground, colors.successSurface),
      (colors.warningForeground, colors.warningSurface),
      (colors.errorForeground, colors.errorSurface),
      (colors.infoForeground, colors.infoSurface),
    ];
    for (final (foreground, background) in pairs) {
      final a = foreground.computeLuminance();
      final b = background.computeLuminance();
      final ratio = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('design system reference rendering', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DesignSystemPreview());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
        find.byType(Scaffold), matchesGoldenFile('goldens/design_system.png'));
  });
}
