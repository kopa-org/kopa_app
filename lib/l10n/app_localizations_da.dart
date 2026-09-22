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
  String get homeMatchCountdownLabel => 'Spilles om:';

  @override
  String get homeTrainingCountdownLabel => 'Træning om:';

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
  String get matchDetailsRsvpPendingSelection => 'Afventer holdlederens valg';

  @override
  String get teamRsvpSelectionModeLabel => 'Tilmeldingsmetode';

  @override
  String get teamRsvpSelectionModeDescription =>
      'Vælg om spillere automatisk er med, eller om holdlederen vælger blandt dem, der melder sig.';

  @override
  String get teamRsvpFirstComeOption => 'Først til mølle';

  @override
  String get teamRsvpLeaderOption => 'Holdlederen vælger';

  @override
  String get teamRsvpSelectionSave => 'Gem tilmeldingsmetode';

  @override
  String get teamRsvpSelectionSaving => 'Gemmer tilmeldingsmetode...';

  @override
  String get teamRsvpSelectionSaved => 'Tilmeldingsmetoden er gemt.';

  @override
  String get teamSettingsOwnerOnly =>
      'Kun en holdleder eller administrator kan ændre holdindstillinger.';

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
  String get matchDetailsMatchEvents => 'Kamp begivenheder';

  @override
  String get matchDetailsMatchEventsUnavailable =>
      'Kampbegivenheder bliver tilgængelige, når kampens resultat er indtastet.';

  @override
  String get externalPlayerTitle => 'Tilføj lånespiller';

  @override
  String get externalPlayerNameHint => 'Navn på spiller';

  @override
  String get externalPlayerAdd => 'Tilføj';

  @override
  String get externalPlayerCancel => 'Annuller';

  @override
  String get externalPlayerLabel => 'Lånespillere';

  @override
  String get externalPlayerCreateButton => 'Opret lånespiller';

  @override
  String get externalPlayerSubstitute => 'Lånespiller · På bænken';

  @override
  String get externalPlayerAddFailed =>
      'Lånespilleren kunne ikke tilføjes. Prøv igen.';

  @override
  String get matchDelete => 'Slet kamp';

  @override
  String get matchEventDelete => 'Slet hændelse';

  @override
  String get externalPlayerDelete => 'Slet lånespiller';

  @override
  String get matchDeleteConfirmation => 'Dette kan ikke fortrydes.';

  @override
  String get matchDeleteFailed => 'Kunne ikke slette. Prøv igen.';

  @override
  String get externalPlayerDeleteInUse =>
      'Lånespilleren bruges i kampbegivenheder eller MOTM. Fjern dem først.';

  @override
  String get matchPollLoadPlayersFailed =>
      'Kunne ikke hente spillere til afstemningen. Prøv igen.';

  @override
  String get matchPollUnknownPlayer => 'Ukendt spiller';

  @override
  String get matchTimelineKickoff => 'Kampstart';

  @override
  String get matchTimelineHalftime => 'Pause';

  @override
  String get matchTimelineFullTime => 'Kamp slut';

  @override
  String get matchTimelineGoal => 'Mål';

  @override
  String get matchTimelineSubstitution => 'Udskiftning';

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
  String get matchPollErrorTitle => 'Fejl';

  @override
  String get eventCreateTitle => 'Opret begivenhed';

  @override
  String get eventCreateMatch => 'Opret kamp';

  @override
  String get eventCreateTraining => 'Opret træning';

  @override
  String get eventTypeMatch => 'Kamp';

  @override
  String get eventTypeTraining => 'Træning';

  @override
  String get eventTraining => 'Træning';

  @override
  String get eventTrainingCategory => 'Kategori';

  @override
  String get eventTrainingCategoryHint => 'Fx pasninger, øvelser eller forsvar';

  @override
  String get eventCreateChoose => 'Hvad vil du oprette?';

  @override
  String get eventOpenMatch => 'Åbn kamp';

  @override
  String get eventOpenTraining => 'Åbn træning';

  @override
  String get eventDetailsMatch => 'Kampdetaljer';

  @override
  String get eventDetailsTraining => 'Træningsdetaljer';

  @override
  String get eventTrainingTime => 'Træningstid';

  @override
  String get eventCreateTrainingLocationHint => 'Fx træningsbanen';

  @override
  String get eventCreateTrainingMissingFields =>
      'Udfyld lokation og vælg dato og tid.';

  @override
  String get eventCreateTrainingFailed => 'Kunne ikke oprette træningen.';

  @override
  String get eventCreateMatchFailed => 'Kunne ikke oprette kampen.';

  @override
  String get eventCreateFailed => 'Begivenheden kunne ikke oprettes.';

  @override
  String get eventRsvpFailed =>
      'Kunne ikke opdatere din tilmelding. Prøv igen.';

  @override
  String get eventEditTraining => 'Rediger træning';

  @override
  String get eventEditTrainingAction => 'Rediger træning';

  @override
  String get eventDeleteTraining => 'Slet træning';

  @override
  String get eventSaveTraining => 'Gem';

  @override
  String get eventCreateAction => 'Opret';

  @override
  String get eventSelectDateTime => 'Vælg dato og tid';

  @override
  String get eventRepeatWeekly => 'Gentag hver uge';

  @override
  String get eventRepeatWeekdays => 'Vælg ugedage og tidspunkter';

  @override
  String get eventRepeatUntil => 'Gentag indtil';

  @override
  String get eventRepeatUntilHint => 'Vælg slutdato';

  @override
  String get eventRepeatMissingWeekday =>
      'Vælg mindst én ugedag for gentagelsen.';

  @override
  String get eventRepeatMissingEndDate =>
      'Vælg, hvornår gentagelsen skal stoppe.';

  @override
  String get eventRepeatEndBeforeStart =>
      'Slutdatoen skal være samme dag eller senere end startdatoen.';

  @override
  String get eventRepeatTooMany =>
      'Gentagelsen giver for mange træninger. Vælg en tidligere slutdato.';

  @override
  String get eventUpdateTrainingFailed =>
      'Kunne ikke gemme ændringerne til træningen.';

  @override
  String get eventWeekdayMonday => 'Mandag';

  @override
  String get eventWeekdayTuesday => 'Tirsdag';

  @override
  String get eventWeekdayWednesday => 'Onsdag';

  @override
  String get eventWeekdayThursday => 'Torsdag';

  @override
  String get eventWeekdayFriday => 'Fredag';

  @override
  String get eventWeekdaySaturday => 'Lørdag';

  @override
  String get eventWeekdaySunday => 'Søndag';
}
