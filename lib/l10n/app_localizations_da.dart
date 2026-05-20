// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get onboardingTitle => 'Kom i gang med Kopa';

  @override
  String get onboardingCreateTeam => 'Opret hold';

  @override
  String get onboardingJoinTeam => 'Find hold';

  @override
  String get onboardingTeamName => 'Holdnavn';

  @override
  String get onboardingManual => 'Manuelt';

  @override
  String get onboardingDbu => 'DBU';

  @override
  String get onboardingContinue => 'Fortsæt';

  @override
  String get onboardingCreate => 'Opret';

  @override
  String get onboardingSearchHint => 'Søg efter et hold';

  @override
  String get onboardingRequestJoin => 'Anmod om adgang';

  @override
  String get onboardingWaitingTitle => 'Afventer godkendelse';

  @override
  String get onboardingWaitingBody =>
      'Din anmodning er sendt til holdets administratorer.';

  @override
  String get onboardingCancel => 'Annuller';

  @override
  String get onboardingPlayers => 'Spillere';

  @override
  String get onboardingMatches => 'Kampe';

  @override
  String get onboardingNoResults => 'Ingen hold fundet';

  @override
  String get onboardingFailure => 'Noget gik galt';
}
