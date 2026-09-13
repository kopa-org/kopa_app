import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/dialog/lineup_visibility_confirmation_dialog.dart';
import 'package:kopa/l10n/app_localizations.dart';

void main() {
  testWidgets('confirming lineup reveal returns true', (tester) async {
    bool? result;

    await tester.pumpWidget(
      _DialogHarness(
        onResult: (value) => result = value,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('show-dialog')));
    await tester.pumpAndSettle();

    expect(
      find.text('Holdet får besked og kan se holdopstillingen.'),
      findsOneWidget,
    );
    expect(find.text('OK, forstået'), findsOneWidget);
    expect(find.text('Afbryd'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('lineup-visibility-reveal-confirm')),
    );
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('cancelling lineup reveal returns false', (tester) async {
    bool? result;

    await tester.pumpWidget(
      _DialogHarness(
        onResult: (value) => result = value,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('show-dialog')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('lineup-visibility-reveal-cancel')),
    );
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}

class _DialogHarness extends StatelessWidget {
  final ValueChanged<bool> onResult;

  const _DialogHarness({required this.onResult});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const ValueKey('show-dialog'),
            onPressed: () async {
              final result = await showCupertinoDialog<bool>(
                context: context,
                builder: (_) => const LineupVisibilityConfirmationDialog(),
              );
              onResult(result ?? false);
            },
            child: const Text('Show dialog'),
          ),
        ),
      ),
    );
  }
}
