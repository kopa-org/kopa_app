import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/l10n/current_l10n.dart';

Map<String, dynamic> _arb(String language) => jsonDecode(
      File('lib/l10n/app_$language.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

Set<String> _placeholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  test('Danish and English define the same texts and placeholders', () {
    final english = _arb('en');
    final danish = _arb('da');
    final keys = english.keys.where((key) => !key.startsWith('@')).toSet();

    expect(danish.keys.where((key) => !key.startsWith('@')).toSet(), keys);
    for (final key in keys) {
      final value = english[key] as String;
      if (value.contains('plural,')) continue;
      expect(
        _placeholders(danish[key] as String),
        _placeholders(value),
        reason: key,
      );
    }
  });

  test('code without a context follows a supported device language', () {
    debugCurrentL10nLocale = const Locale('en');
    expect(currentL10n.localeName, 'en');
    debugCurrentL10nLocale = const Locale('de');
    expect(currentL10n.localeName, 'da');
  });

  testWidgets('dates follow the language', (tester) async {
    await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
    await GlobalMaterialLocalizations.delegate.load(const Locale('da'));
    final date = DateTime(2026, 6, 13);

    debugCurrentL10nLocale = const Locale('en');
    expect(DateHelper.getFormattedMatchDate(date), 'Saturday 13 June');
    expect(DateHelper.getMonthName(date), 'June');
    expect(DateHelper.getFormattedLongDate(date), '13 June 2026');

    debugCurrentL10nLocale = const Locale('da');
    expect(DateHelper.getFormattedMatchDate(date), 'Lørdag 13. juni');
    expect(DateHelper.getMonthName(date), 'Juni');
    expect(DateHelper.getFormattedLongDate(date), '13. juni 2026');
  });

  test('every weekday has an initial', () {
    for (final locale in AppLocalizations.supportedLocales) {
      debugCurrentL10nLocale = locale;
      expect(currentL10n.uiWeekdayInitials.split(','), hasLength(7));
    }
  });
}
