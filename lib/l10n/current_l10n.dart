import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kopa/l10n/app_localizations.dart';

/// Replaces the device language in tests.
@visibleForTesting
Locale? debugCurrentL10nLocale;

/// Translations for code without a [BuildContext], such as cubits and
/// repositories. Widgets should use `AppLocalizations.of(context)!`.
///
/// Picks the first device language the app supports, like the app's own
/// locale resolution, and falls back to Danish.
AppLocalizations get currentL10n {
  final deviceLocales = debugCurrentL10nLocale != null
      ? [debugCurrentL10nLocale!]
      : PlatformDispatcher.instance.locales;
  for (final locale in deviceLocales) {
    if (AppLocalizations.delegate.isSupported(locale)) {
      return lookupAppLocalizations(Locale(locale.languageCode));
    }
  }
  return lookupAppLocalizations(const Locale('da'));
}
