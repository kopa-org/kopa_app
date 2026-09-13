// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get homeAttendanceGoing => 'Du er tilmeldt';

  @override
  String get homeAttendanceDeclined => 'Afbud registreret';

  @override
  String get homeAttendanceQuestion => 'Kommer du?';

  @override
  String get homeAttendanceYes => 'Ja, jeg kommer';

  @override
  String get homeAttendanceNo => 'Nej';

  @override
  String get homeAttendanceSaving => 'Gemmer…';

  @override
  String get homeAttendanceChange => 'Ændr dit svar';

  @override
  String get matchDetailsDecisionTitle => 'Beslutning';

  @override
  String get matchDetailsDecisionPending =>
      'Du er tilmeldt, men din udtagelse afventer stadig.';

  @override
  String get matchDetailsRsvpDecline => 'Nej, kan ikke';

  @override
  String get matchDetailsRsvpAccept => 'Ja, jeg kommer';

  @override
  String get matchDetailsRsvpRegistered => 'Tilmeldt';

  @override
  String get matchDetailsRsvpDeclineAction => 'Meld afbud';

  @override
  String get matchDetailsRsvpDeclined => 'Ikke tilmeldt';

  @override
  String get matchScoreHome => 'Hjemme';

  @override
  String get matchScoreAway => 'Ude';

  @override
  String get matchScoreHelp => 'Indtast slutresultatet for hvert hold.';

  @override
  String get matchScoreSave => 'Gem resultat';

  @override
  String get matchScoreSaveFailed => 'Resultatet kunne ikke gemmes. Prøv igen.';

  @override
  String get commonGoTo => 'Gå til';

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
  String get onboardingDbuRecommendation =>
      'Det anbefles at synkronisere med DBU, for den bedste app oplevelse';

  @override
  String get onboardingContinue => 'Fortsæt';

  @override
  String get onboardingCreate => 'Opret';

  @override
  String get onboardingSearchHint => 'Søg efter et hold';

  @override
  String get onboardingRequestJoin => 'Anmod om adgang';

  @override
  String get onboardingWaitingTitle => 'Til Rådighed';

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

  @override
  String get matchEventChooseEvent => 'Vælg begivenhed';

  @override
  String get matchTimelineKickoff => 'Kampstart';

  @override
  String get matchTimelineHalftime => 'Pause';

  @override
  String get matchTimelineFullTime => 'Kamp slut';

  @override
  String get matchRegisterResult => 'Registrer kampens resultat';

  @override
  String get matchEnterResult => 'Indtast';

  @override
  String get matchScoreDialogTitle => 'Indtast resultat';

  @override
  String get matchResultReminderTitle => 'Indtast kampens resultat';

  @override
  String get matchResultReminderMessage =>
      'Der er gået 30 minutter siden kampstart. Indtast kampens slutresultat, så kampen bliver vist som spillet.';

  @override
  String get matchResultReminderAction => 'Indtast resultat';

  @override
  String get commonCancel => 'Annuller';

  @override
  String get maintenanceMessage =>
      'Kopa er under vedligeholdelse og vil snart være klar igen.';

  @override
  String get commonDelete => 'Slet';

  @override
  String get commonOk => 'OK';

  @override
  String get lineupVisibilityRevealMessage =>
      'Holdet får besked og kan se holdopstillingen.';

  @override
  String get lineupVisibilityRevealConfirm => 'OK, forstået';

  @override
  String get lineupVisibilityRevealCancel => 'Afbryd';

  @override
  String get lineupUnsavedChangesTitle => 'Du har ikke gemt holdopstillingen';

  @override
  String get lineupUnsavedChangesMessage =>
      'Vil du gemme dine ændringer, før du forlader siden?';

  @override
  String get lineupUnsavedChangesSave => 'Gem';

  @override
  String get lineupUnsavedChangesDiscard => 'Gem ikke';

  @override
  String get fineTypeDeleteIconLabel => 'Slet bødetype';

  @override
  String get fineTypeDeleteTitle => 'Slet bødetype?';

  @override
  String fineTypeDeleteMessage(String title) {
    return 'Slet $title fra bødekataloget?';
  }

  @override
  String get fineTypeDeleteFailureTitle => 'Kunne ikke slette bødetype';

  @override
  String get fineTypeDeleteInUseMessage =>
      'Denne bødetype bruges allerede af eksisterende bøder.';

  @override
  String get fineTypeDeleteFailureMessage => 'Noget gik galt. Prøv igen.';

  @override
  String get teamLogoEditButton => 'Ændre hold logo';

  @override
  String get teamLogoEditTitle => 'Ændre hold logo';

  @override
  String get teamLogoDesignTitle => 'Design dit holdlogo';

  @override
  String get teamLogoDesignSubtitle =>
      'Vælg en baggrundsfarve og form til jeres holdlogo';

  @override
  String get teamLogoBackgroundColor => 'Baggrundsfarve';

  @override
  String get teamLogoShape => 'Form';

  @override
  String get teamLogoPattern => 'Mønster';

  @override
  String get teamLogoSave => 'Gem logo';

  @override
  String get teamLogoSaving => 'Gemmer logo...';

  @override
  String get teamLogoSaveFailure => 'Kunne ikke gemme holdlogoet.';

  @override
  String get matchPollTitle => 'Kampens spiller';

  @override
  String get matchPollInstruction => 'Fordel stemmer med + og -';

  @override
  String matchPollTotalVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'I alt: $count stemmer',
      one: 'I alt: 1 stemme',
    );
    return '$_temp0';
  }

  @override
  String matchPollVoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmer',
      one: '1 stemme',
    );
    return '$_temp0';
  }

  @override
  String get matchPollEdit => 'Rediger afstemning';

  @override
  String get matchPollCreateTitle => 'Tilføj afstemning';

  @override
  String get matchPollEditTitle => 'Rediger afstemning';

  @override
  String get matchPollCreateAction => 'Opret afstemning';

  @override
  String get matchPollSaveAction => 'Gem ændringer';

  @override
  String get matchPollCreating => 'Opretter...';

  @override
  String get matchPollSaving => 'Gemmer...';

  @override
  String get matchPollUnknownPlayer => 'Ukendt spiller';

  @override
  String get matchPollErrorTitle => 'Fejl';
}
