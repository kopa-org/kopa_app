import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform keeps text actions fully on screen', (tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme.copyWith(platform: platform),
        home: PageScaffold(
          title: 'Tildel bøder',
          trailing: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Text('Opret'),
            ),
          ],
          body: const SizedBox.expand(),
        ),
      ));

      final action = tester.getRect(find.text('Opret'));

      expect(action.right, lessThanOrEqualTo(344));
      expect(tester.takeException(), isNull);
    });
  }
}
