import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/current_l10n.dart';

/// Runs tests in Danish, the app's primary language, unless a test sets
/// its own locale.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final platformDispatcher =
      TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;

  setUp(() {
    debugCurrentL10nLocale = const Locale('da');
    platformDispatcher.localeTestValue = const Locale('da');
    platformDispatcher.localesTestValue = const [Locale('da')];
  });
  await testMain();
}
