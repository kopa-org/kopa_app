import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/match/match_score_sheet.dart';
import 'package:kopa/theme/app_theme.dart';

@Preview(name: 'Enter match result', group: 'Matches', size: Size(390, 600))
Widget matchScoreSheetPreview() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: Align(
        alignment: Alignment.bottomCenter,
        child: MatchScoreSheet(
            homeTeam: 'Kopa FC',
            awayTeam: 'Frederiksberg BK',
            homeScore: 2,
            awayScore: 1,
            onSave: (home, away) async {}),
      )),
    );
