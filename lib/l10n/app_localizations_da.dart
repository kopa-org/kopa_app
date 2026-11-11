// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get onboardingPlayer => 'Spiller';

  @override
  String get onboardingTeamLeader => 'Holdleder';

  @override
  String get onboardingRoleChoiceDescription => 'Vælg din rolle på holdet.';

  @override
  String get onboardingRoleChoiceTitle => 'Hvad er din rolle?';

  @override
  String get onboardingTeamChoiceDescription =>
      'Opret et nyt hold, eller find dit eksisterende hold på Kopa.';

  @override
  String get onboardingTeamChoiceTitle => 'Opret eller tilmeld dig et hold';

  @override
  String get matchDetailsLineupTab => 'Opstilling';

  @override
  String get matchFabExternalPlayerLabel => 'Tilføj ekst. spiller';

  @override
  String get matchLineupWaiting => 'Venter på holdopstilling';

  @override
  String get loginForgotPassword => 'Glemt adgangskode?';

  @override
  String get forgotPasswordTitle => 'Glemt adgangskode';

  @override
  String get forgotPasswordInstructions =>
      'Skriv din e-mailadresse, så sender vi dig en kode til at nulstille din adgangskode.';

  @override
  String get forgotPasswordCodeInstructions =>
      'Indtast den 6-cifrede kode, vi har sendt til din e-mail.';

  @override
  String get forgotPasswordEmail => 'E-mail';

  @override
  String get forgotPasswordEmailRequired => 'Indtast din e-mailadresse.';

  @override
  String get forgotPasswordEmailInvalid => 'Indtast en gyldig e-mailadresse.';

  @override
  String get forgotPasswordCode => '6-cifret kode';

  @override
  String get forgotPasswordCodeLength => 'Koden skal være 6 cifre.';

  @override
  String get forgotPasswordResend => 'Send koden igen';

  @override
  String get forgotPasswordVerify => 'Bekræft kode';

  @override
  String get forgotPasswordSendCode => 'Send kode';

  @override
  String get resetCodeSent =>
      'Hvis kontoen findes, har vi sendt en kode. Tjek din indbakke.';

  @override
  String get resetRequestFailed =>
      'Koden kunne ikke sendes lige nu. Prøv igen.';

  @override
  String get resetCodeInvalid => 'Koden er ugyldig eller udløbet. Prøv igen.';

  @override
  String get resetPasswordTitle => 'Vælg en ny adgangskode';

  @override
  String get resetPasswordNewPassword => 'Ny adgangskode';

  @override
  String get resetPasswordConfirm => 'Bekræft adgangskode';

  @override
  String get resetPasswordMinimumLength =>
      'Adgangskoden skal være mindst 8 tegn.';

  @override
  String get resetPasswordMismatch => 'Adgangskoderne er ikke ens.';

  @override
  String get resetPasswordSave => 'Gem adgangskode';

  @override
  String get resetPasswordFailed =>
      'Adgangskoden kunne ikke ændres. Koden kan være udløbet. Prøv igen.';

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
  String get onboardingJoinTeam => 'Tilmeld hold';

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
  String get matchEventReorderTooltip => 'Træk for at ændre rækkefølgen';

  @override
  String get matchEventReorderFailed =>
      'Rækkefølgen kunne ikke gemmes. Prøv igen.';

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

  @override
  String get matchPollNoParticipants =>
      'Ingen deltagere registreret til kampen. Opdatér tilmeldingerne for at oprette en afstemning.';

  @override
  String get matchEventPlayer => 'Spiller';

  @override
  String get matchEventScorer => 'Målscorer';

  @override
  String get matchEventPlayerIn => 'Spiller ind';

  @override
  String get matchEventPlayerOut => 'Spiller ud';

  @override
  String get matchEventShooter => 'Skytte';

  @override
  String get matchEventAssist => 'Assist (valgfrit)';

  @override
  String get matchEventChooseMinute => 'Vælg minut (valgfrit)';

  @override
  String get matchEventAddMinute => 'Tilføj minut (valgfrit)';

  @override
  String get matchEventChangeMinute => 'Ret minut';

  @override
  String get matchEventWithoutMinute => 'Uden minut';

  @override
  String get matchEventUseMinute => 'Brug minut';

  @override
  String get matchEventYellowCard => 'Gult kort';

  @override
  String get matchEventRedCard => 'Rødt kort';

  @override
  String get matchEventPenalty => 'Straffespark';

  @override
  String get matchEventSaveFailed =>
      'Hændelserne kunne ikke gemmes. Prøv igen.';

  @override
  String get matchEventAddMore => 'Tilføj mere';

  @override
  String get matchEventSaveAndClose => 'Gem og afslut';

  @override
  String get matchEventTimelineTitle => 'Kampforløb';

  @override
  String get matchEventEmptyTitle => 'Ingen hændelser endnu';

  @override
  String get matchEventEmptyDescription =>
      'Tilføj mål, kort og udskiftninger. Minut er valgfrit.';

  @override
  String get matchEventAddAction => '+ Tilføj hændelse';

  @override
  String matchEventAssistedBy(String playerName) {
    return 'Assisteret af $playerName';
  }

  @override
  String matchEventPlayerOff(String playerName) {
    return 'Ud: $playerName';
  }

  @override
  String get mobilePayBoxTitle => 'MobilePay Box';

  @override
  String get mobilePayBoxMissing => 'MobilePay Box mangler';

  @override
  String get mobilePayBoxInstructions =>
      'Indsæt betalingslinket fra Del i din MobilePay Box. Det korte Box-nummer kan ikke åbne et betalingslink.';

  @override
  String get mobilePayBoxOwnerRequired =>
      'Holdlederen skal først tilføje betalingslinket til holdets MobilePay Box.';

  @override
  String get mobilePayBoxEdit => 'Rediger MobilePay Box-link';

  @override
  String get mobilePayBoxAdd => 'Tilføj Box-link';

  @override
  String get mobilePayBoxInvalid =>
      'Indsæt det fulde betalingslink til MobilePay Box. Et kort nummer som 5289PN er ikke nok.';

  @override
  String get mobilePayBoxSave => 'Gem MobilePay Box';

  @override
  String get mobilePayBoxSaveFailed =>
      'MobilePay Box kunne ikke gemmes. Prøv igen.';

  @override
  String get mobilePayOpenFailed =>
      'MobilePay kunne ikke åbnes. Kontrollér, at appen er installeret, og prøv igen.';

  @override
  String get mobilePayBoxLinkRequired =>
      'Denne Box har et kort nummer i stedet for et betalingslink. Bed holdlederen om at redigere Boxen og indsætte det delte betalingslink.';

  @override
  String get mobilePayDeposit => 'Indbetal med MobilePay';

  @override
  String get mobilePayGoToBox => 'Gå til MobilePay Box';

  @override
  String mobilePayAmount(int amount) {
    return 'Betal $amount kr. med MobilePay';
  }

  @override
  String get matchRsvpQuestion => 'Kommer du?';

  @override
  String get matchRsvpHint => 'Giv holdet besked.';

  @override
  String get matchRsvpAwaitingResponse => 'Afventer svar';

  @override
  String get matchRsvpConfirmed => 'Du er tilmeldt kampen';

  @override
  String get matchRsvpTrainingConfirmed => 'Du er tilmeldt træningen';

  @override
  String get matchRsvpDeclinedMessage => 'Du har meldt afbud';

  @override
  String get matchRsvpCancel => 'Meld afbud';

  @override
  String matchRsvpAttendeeCount(int count) {
    return '$count tilmeldte';
  }

  @override
  String get matchActionsMore => 'Kampindstillinger';

  @override
  String get matchActionsEditResult => 'Rediger kampresultat';

  @override
  String get matchFabEnterResult => 'Indtast kampresultat';

  @override
  String get matchFabAddExternalPlayers => 'Tilføj eksterne spillere';

  @override
  String get onboardingPositionTitle => 'Vælg din position';

  @override
  String get onboardingPositionDescription => 'Tryk på din position på banen';

  @override
  String get onboardingSearchDescription =>
      'Find dit hold, før du vælger din position.';

  @override
  String get onboardingSelectTeam => 'Vælg hold';

  @override
  String get onboardingExit => 'Forlad tilmelding og log ud';

  @override
  String get teamRoleEdit => 'Skift rolle på holdet';

  @override
  String get teamRoleSaveFailed => 'Kunne ikke ændre rollen. Prøv igen.';

  @override
  String get teamRoleLastLeader =>
      'Udpeg en anden holdleder, før du skifter til spiller.';

  @override
  String get teamSquadTitle => 'Truppen';

  @override
  String get teamSquadEmpty => 'Ingen spillere fundet.';

  @override
  String get teamSquadLoadFailed =>
      'Kunne ikke hente truppen. Tryk for at prøve igen.';

  @override
  String teamSquadCount(int count) {
    return '$count spillere i truppen';
  }

  @override
  String get fineBoxTitle => 'Bødekassen';

  @override
  String get fineBoxMyFines => 'Mine bøder';

  @override
  String get fineBoxSegmentOverview => 'Overblik';

  @override
  String get fineBoxSegmentFineTypes => 'Bødetyper';

  @override
  String get fineBoxSegmentFines => 'Bøder';

  @override
  String get fineBoxHeroEyebrow => 'Holdets kasse';

  @override
  String get fineBoxCollected => 'Indsamlet';

  @override
  String get fineBoxOutstanding => 'Mangler';

  @override
  String fineBoxPaidPercent(int percent) {
    return '$percent% af alle bøder er betalt';
  }

  @override
  String get fineBoxGiveFine => 'Giv bøde';

  @override
  String get fineBoxGiveFineHint => 'Til en eller flere';

  @override
  String get fineBoxDeposit => 'Indbetal';

  @override
  String get fineBoxPodiumTitle => 'Bødetoppen';

  @override
  String get fineBoxPodiumEmpty =>
      'Ingen udestående bøder. Holdet holder buret rent!';

  @override
  String get fineBoxRecentTitle => 'Seneste bøder';

  @override
  String get fineBoxRecentEmpty => 'Ingen bøder tildelt endnu.';

  @override
  String get fineBoxCreateFineType => 'Opret bødetype';

  @override
  String get fineBoxCatalogTitle => 'Bødekatalog';

  @override
  String get fineBoxCatalogEmpty => 'Ingen bødetyper endnu. Opret den første.';

  @override
  String fineBoxCatalogCount(int count) {
    return '$count typer';
  }

  @override
  String get fineBoxPersonalEyebrow => 'Din saldo';

  @override
  String get fineBoxPersonalOwed => 'Du skylder holdet';

  @override
  String get fineBoxDebtFreeTitle => 'Gældfri!';

  @override
  String get fineBoxDebtFreeBody =>
      'Du har ingen ubetalte bøder. Bliv ved sådan.';

  @override
  String fineBoxUnpaidCount(int count) {
    return '$count ubetalte';
  }

  @override
  String get fineBoxStatFines => 'Bøder';

  @override
  String get fineBoxStatPaid => 'Betalt';

  @override
  String get fineBoxUnpaidTitle => 'Ubetalte bøder';

  @override
  String get fineBoxSelectAll => 'Vælg alle';

  @override
  String get fineBoxDeselectAll => 'Fravælg alle';

  @override
  String get fineBoxHistoryTitle => 'Tidligere bøder';

  @override
  String get fineBoxPaidBadge => 'Betalt';

  @override
  String fineBoxSelectedCount(int count) {
    return '$count valgt';
  }

  @override
  String get fineBoxMarkCashPaid => 'Eller markér som kontant betalt';

  @override
  String get fineBoxMobilePayConnected => 'MobilePay Box tilknyttet';

  @override
  String get matchTasksTitle => 'Opgaver';

  @override
  String get matchTasksNoAssignee => 'Ingen udtaget endnu';

  @override
  String get matchTasksNextInLine => 'Næste i køen';

  @override
  String get matchTasksChosenByLeader => 'Valgt af holdleder';

  @override
  String matchTasksUpNext(String names) {
    return 'Derefter: $names';
  }

  @override
  String get matchTasksOneOffBadge => 'Kun denne kamp';

  @override
  String get matchTasksMarkDone => 'Udført';

  @override
  String matchTasksConfirmTitle(String task) {
    return 'Er $task klaret?';
  }

  @override
  String matchTasksCompletedBy(String name) {
    return 'Udført af $name';
  }

  @override
  String get matchTasksAddOneOff => 'Tilføj opgave til kampen';

  @override
  String get matchTasksNameLabel => 'Opgavens navn';

  @override
  String get matchTasksOneOffNameHint => 'Fx bolde eller vand';

  @override
  String get matchTasksPickResponsible => 'Hvem er ansvarlig?';

  @override
  String get matchTasksNobodyYet => 'Vælg senere';

  @override
  String get matchTasksSelectedTag => 'Udtaget';

  @override
  String get matchTasksNotSelected => 'Ikke udtaget';

  @override
  String get matchTasksChangeResponsible => 'Skift ansvarlig';

  @override
  String get matchTasksQueueTitle => 'Køen';

  @override
  String get matchTasksCreateConfirm => 'Opret';

  @override
  String get matchTasksCancel => 'Annuller';

  @override
  String get matchTasksSave => 'Gem';

  @override
  String get matchTasksDelete => 'Slet opgave';

  @override
  String matchTasksDeleteConfirm(String task) {
    return 'Slet $task? Køen bliver også slettet.';
  }

  @override
  String matchTasksDeleteOneOffConfirm(String task) {
    return 'Slet $task fra kampen?';
  }

  @override
  String get matchTasksReset => 'Nulstil kø';

  @override
  String get matchTasksResetConfirm =>
      'Nulstil køen til den rækkefølge spillerne kom på holdet?';

  @override
  String get matchTasksError => 'Opgaven kunne ikke opdateres. Prøv igen.';

  @override
  String get matchTasksEmptyLeader =>
      'Ingen opgaver endnu. Opret faste opgaver som øl og vasketøj under holdindstillingerne.';

  @override
  String get matchTasksEmptyPlayer =>
      'Ingen opgaver endnu. Tilføj en opgave til kampen, fx bolde eller vand.';

  @override
  String get matchTasksManage => 'Faste opgaver';

  @override
  String get teamTasksTitle => 'Opgaver til kampe';

  @override
  String get teamTasksIntro =>
      'Faste opgaver går på skift ved hver kamp. Den øverste spiller i køen, der er udtaget, får opgaven. Når den er klaret, rykker spilleren bagerst.';

  @override
  String get teamTasksEmpty =>
      'Ingen faste opgaver endnu. Opret fx øl, vasketøj eller godteposen.';

  @override
  String get teamTasksCreate => 'Ny fast opgave';

  @override
  String get teamTasksNameHint => 'Fx øl eller vasketøj';

  @override
  String get teamTasksRename => 'Omdøb';

  @override
  String get teamTasksQueueHint => 'Træk i håndtaget for at ændre rækkefølgen.';

  @override
  String teamTasksPlayers(int count) {
    return '$count spillere i køen';
  }

  @override
  String get teamRoleFineAdmin => 'Bødeansvarlig';

  @override
  String get teamRoleMakeFineAdmin => 'Gør til bødeansvarlig';

  @override
  String get teamRoleRemoveFineAdmin => 'Fjern som bødeansvarlig';

  @override
  String get fineBoxWithdraw => 'Hæv';

  @override
  String get fineBoxWithdrawTitle => 'Hæv fra bødekassen';

  @override
  String fineBoxWithdrawIntro(int amount) {
    return 'Registrér hvor meget du har taget fra kassen. Der er $amount kr. i kassen nu.';
  }

  @override
  String get fineBoxWithdrawAmountHint => 'Beløb';

  @override
  String get fineBoxWithdrawNoteHint => 'Hvad gik pengene til? (valgfrit)';

  @override
  String get fineBoxWithdrawSave => 'Registrér hævning';

  @override
  String get fineBoxWithdrawInvalidAmount =>
      'Indtast et beløb større end 0 kr.';

  @override
  String get fineBoxWithdrawTooMuch => 'Der er ikke så mange penge i kassen.';

  @override
  String get fineBoxWithdrawFailed =>
      'Kunne ikke registrere hævningen. Prøv igen.';

  @override
  String get fineBoxWithdrawalsTitle => 'Hævet fra kassen';

  @override
  String get fineBoxWithdrawalNoNote => 'Hævning';

  @override
  String get fineBoxWithdrawalUnknownUser => 'Tidligere spiller';

  @override
  String mobilePayPaidTitle(int amount) {
    return 'Har du betalt $amount kr.?';
  }

  @override
  String get mobilePayPaidBody =>
      'Vi kan ikke se MobilePay-betalinger i Kopa. Svarer du ja, bliver de valgte bøder markeret som betalt.';

  @override
  String get mobilePayPaidYes => 'Ja';

  @override
  String get mobilePayPaidNo => 'Nej';

  @override
  String get mobilePayPaidSaveFailed =>
      'Din betaling kunne ikke gemmes. Prøv igen.';

  @override
  String get fineBoxSeeAll => 'Se alle';

  @override
  String get fineBoxPlayersTitle => 'Alle spillere';

  @override
  String get fineBoxAllFinesTitle => 'Alle bøder';

  @override
  String get fineBoxInBox => 'I kassen';

  @override
  String get fineBoxAllPaid => 'Alt betalt';

  @override
  String get fineBoxDeleteFine => 'Slet bøde';

  @override
  String get fineBoxDeleteCancel => 'Annuller';

  @override
  String get fineBoxDeleteFailed => 'Bøden kunne ikke slettes. Prøv igen.';

  @override
  String fineBoxPlayerFineCount(int count) {
    return '$count bøder';
  }

  @override
  String fineBoxDeleteFineBody(String fine, String name) {
    return 'Vil du slette $fine til $name? Det kan ikke fortrydes.';
  }

  @override
  String get navHome => 'Hjem';

  @override
  String get navMatches => 'Kampe';

  @override
  String get navStatistics => 'Statistik';

  @override
  String get navSquad => 'Truppen';

  @override
  String get navFineBox => 'Bødekasse';

  @override
  String get uiChooseDbuTeam => 'Vælg DBU-hold';

  @override
  String get uiCancel => 'Annullér';

  @override
  String get uiCouldNotFetchTheInviteLink =>
      'Kunne ikke hente invitationslink.';

  @override
  String get uiLinkCopied => 'Link kopieret';

  @override
  String uiJoinOnKopa(Object a, Object b) {
    return 'Join $a på Kopa: $b';
  }

  @override
  String get uiCouldNotSaveThePositionTry =>
      'Kunne ikke gemme positionen. Prøv igen.';

  @override
  String get uiInviteYourTeam => 'Inviter dit hold';

  @override
  String get uiCreateYourFootballTeamAndKeep =>
      'Opret dit fodboldhold og saml spillere, kampe og statistikker ét sted.';

  @override
  String get uiShareTheLinkWithThePlayers =>
      'Del linket med spillerne, så de kan finde holdet.';

  @override
  String get uiContinueToKopa => 'Fortsæt til Kopa';

  @override
  String get uiAssociation => 'Forbund';

  @override
  String get uiYourTeamName => 'Dit holdnavn';

  @override
  String uiYouChose(Object a, Object b) {
    return 'Du valgte: $a ($b)';
  }

  @override
  String get ui7ASide => '7-mand';

  @override
  String get ui11ASide => '11-mand';

  @override
  String get uiSearchResults => 'Søgeresultater';

  @override
  String uiTeamLeader(Object a) {
    return 'Holdleder: $a';
  }

  @override
  String get uiTeamLeaderPending => 'Holdleder: Afventer';

  @override
  String uiMembers(Object a) {
    return '$a medlemmer';
  }

  @override
  String get uiTheInviteLinkCouldNotBe =>
      'Invitationslinket kunne ikke hentes.';

  @override
  String get uiCopyLink => 'Kopier link';

  @override
  String get uiShareLink => 'Del link';

  @override
  String get uiBack => 'Tilbage';

  @override
  String uiStepOf(Object a, Object b) {
    return 'Trin $a af $b';
  }

  @override
  String get uiDbuConnected => 'DBU forbundet';

  @override
  String get uiTeamDataHasBeenImported => 'Holddata er importeret';

  @override
  String get uiLogInThroughDbuToImport =>
      'Log ind via DBU for at importere holddata';

  @override
  String get uiYourTeam => 'dit hold';

  @override
  String get uiYourTeam2 => 'Dit hold';

  @override
  String get uiStep3Of5 => 'Trin 3 af 5';

  @override
  String get uiWaitingForApproval => 'Venter på accept';

  @override
  String uiYouHaveAskedToJoinYou(Object a) {
    return 'Du har ansøgt om at blive en del af $a. Du får besked, når holdlederen har accepteret din anmodning.';
  }

  @override
  String get uiPending => 'Afventer';

  @override
  String get uiCouldNotValidateTheInvitation =>
      'Kunne ikke validere invitation';

  @override
  String get uiNetworkError => 'Netværksfejl';

  @override
  String get uiNotLoggedIn => 'Ikke logget ind';

  @override
  String get uiCouldNotJoinTheTeam => 'Kunne ikke tilmelde holdet';

  @override
  String get uiCouldNotFetchTheCode => 'Kunne ikke hente kode';

  @override
  String get uiCouldNotRotateTheCode => 'Kunne ikke rotere kode';

  @override
  String get uiCouldNotCreateTheTeam => 'Kunne ikke oprette holdet';

  @override
  String get uiCouldNotSearchForTeams => 'Kunne ikke søge efter hold';

  @override
  String get uiCouldNotSendTheRequest => 'Kunne ikke sende anmodning';

  @override
  String get uiCouldNotFetchTheRequest => 'Kunne ikke hente anmodning';

  @override
  String get uiCouldNotFetchTheRequests => 'Kunne ikke hente anmodninger';

  @override
  String get uiCouldNotProcessTheRequest => 'Kunne ikke behandle anmodning';

  @override
  String get uiCouldNotCancelTheRequest => 'Kunne ikke annullere anmodning';

  @override
  String get uiInvalidInvitation => 'Ugyldig invitation';

  @override
  String get uiSomethingWentWrongPleaseTryAgain =>
      'Der skete en fejl. Prøv venligst igen senere.';

  @override
  String get uiNoUserFound => 'Ingen bruger fundet.';

  @override
  String get uiPracticalInformation => 'Praktisk information';

  @override
  String get uiRegisteredPlayers => 'Tilmeldte spillere';

  @override
  String get uiDate => 'Dato';

  @override
  String get uiTime => 'Tidspunkt';

  @override
  String get uiLocation => 'Lokation';

  @override
  String get uiCountdown => 'Countdown';

  @override
  String get uiRegistrations => 'Tilmeldinger';

  @override
  String uiRegistered(Object a) {
    return '$a tilmeldte';
  }

  @override
  String get uiMeetingTime => 'Mødetid';

  @override
  String get uiYourSelection => 'Din udtagelse';

  @override
  String get uiNotes => 'Noter';

  @override
  String get uiNoResponse => 'Mangler svar';

  @override
  String get uiDeclined => 'Frameldt';

  @override
  String uiAvailable(Object a) {
    return 'Til Rådighed ($a)';
  }

  @override
  String uiSelected(Object a) {
    return 'Udtaget ($a)';
  }

  @override
  String uiNoResponse2(Object a) {
    return 'Mangler svar ($a)';
  }

  @override
  String uiDeclined2(Object a) {
    return 'Frameldte ($a)';
  }

  @override
  String get uiCouldNotUpdateTheApprovalTry =>
      'Kunne ikke opdatere godkendelsen. Prøv igen.';

  @override
  String get uiCouldNotApproveEveryoneTryAgain =>
      'Kunne ikke godkende alle. Prøv igen.';

  @override
  String get uiCouldNotChangeTheVisibilityTry =>
      'Kunne ikke ændre synligheden. Prøv igen.';

  @override
  String get uiInProgressOrFinished => 'I gang eller afsluttet';

  @override
  String uiDaysHours(Object a, Object b) {
    return '$a dage $b timer';
  }

  @override
  String uiReject(Object a) {
    return 'Afvis $a';
  }

  @override
  String uiApprove(Object a) {
    return 'Godkend $a';
  }

  @override
  String get uiApproved => 'Godkendt';

  @override
  String get uiRejected => 'Afvist';

  @override
  String uiEditChoiceFor(Object a) {
    return 'Rediger valg for $a';
  }

  @override
  String get uiNoPlayersAreAwaitingApproval =>
      'Ingen spillere afventer godkendelse.';

  @override
  String get uiApproveAll => 'Godkend alle';

  @override
  String get uiNoPlayersHere => 'Ingen spillere her.';

  @override
  String get uiCouldNotSaveTheLineupTry =>
      'Kunne ikke gemme holdopstillingen. Prøv igen.';

  @override
  String get uiChoosePlayer => 'Vælg spiller';

  @override
  String get uiEditLineup => 'Rediger Holdopstilling';

  @override
  String uiEditFormation(Object a) {
    return 'Rediger formation ($a)';
  }

  @override
  String uiMovePlayerReleaseToPlace(Object a) {
    return 'Flyt spiller: Slip for at placere $a';
  }

  @override
  String uiBenchPlayers(Object a) {
    return 'Bænken ($a spillere)';
  }

  @override
  String get uiNoPlayersOnTheBench => 'Ingen spillere på bænken';

  @override
  String get uiHoldAPlayerAndDragTo =>
      'Hold på en spiller og træk for at bytte plads';

  @override
  String get uiChooseFormation => 'Vælg formation';

  @override
  String get uiChooseTheFormationThatSuitsYour =>
      'Vælg formationen der passer bedst til jeres næste kamp';

  @override
  String uiFormation(Object a) {
    return 'Formation $a';
  }

  @override
  String get uiGk => 'MM';

  @override
  String get uiAm => 'OM';

  @override
  String get uiPl => 'SP';

  @override
  String get uiStandard7ASide => 'Standard 7-mands';

  @override
  String get uiDefensiveBalance => 'Defensiv balance';

  @override
  String get uiSymmetricControl => 'Symmetrisk kontrol';

  @override
  String get uiAttackingWidth => 'Offensiv bredde';

  @override
  String get uiClassicBalance => 'Klassisk balance';

  @override
  String get uiMidfieldControl => 'Midtbanekontrol';

  @override
  String get uiControlledPressing => 'Kontrolleret pres';

  @override
  String get uiCustomLineup => 'Tilpasset opstilling';

  @override
  String get uiSettings => 'Indstillinger';

  @override
  String get uiImportMatchSchedule => 'Importér kampprogram';

  @override
  String get uiFetchingLink => 'Henter link...';

  @override
  String get uiShareKopa => 'Del Kopa';

  @override
  String get uiTeamTools => 'Holdværktøjer';

  @override
  String get uiApproveNewPlayers => 'Godkend nye spillere';

  @override
  String get uiSyncingStandings => 'Synkroniserer stilling...';

  @override
  String get uiSyncStandingsFromDbu => 'Synkroniser stilling fra DBU';

  @override
  String get uiDefaultMeetingTime => 'Standard mødetid';

  @override
  String get uiSavingMeetingTime => 'Gemmer mødetid...';

  @override
  String get uiSaveMeetingTime => 'Gem mødetid';

  @override
  String get uiLoggingOut => 'Logger ud...';

  @override
  String get uiLogOut => 'Log ud';

  @override
  String get uiCouldNotLogOut => 'Kunne ikke logge ud.';

  @override
  String get uiYouMustBeOnATeam => 'Du skal være på et hold for at dele Kopa.';

  @override
  String get uiCouldNotShareKopa => 'Kunne ikke dele Kopa.';

  @override
  String get uiOnlyTheTeamLeaderCanChange =>
      'Kun holdlederen kan ændre mødetid.';

  @override
  String uiTheDefaultMeetingTimeIsSet(Object a) {
    return 'Standard mødetid er sat til $a.';
  }

  @override
  String get uiNoDefault => 'Ingen standard';

  @override
  String uiMinBeforeKickoff(Object a) {
    return '$a min før kampstart';
  }

  @override
  String uiStandingsAndPoolTeamsAreSynced(Object a) {
    return 'Stilling og puljehold er synkroniseret ($a hold).';
  }

  @override
  String uiFines(Object a) {
    return 'Bøder - $a';
  }

  @override
  String get ui1HourAgo => '1 time siden';

  @override
  String uiHoursAgo(Object a) {
    return '$a timer siden';
  }

  @override
  String get uiYesterday => 'I går';

  @override
  String uiDaysAgo(Object a) {
    return '$a dage siden';
  }

  @override
  String get uiUserNotLoggedIn => 'Bruger ikke logget ind';

  @override
  String get uiCouldNotFetchDashboardData => 'Kunne ikke hente dashboard data';

  @override
  String get uiCalendar => 'Kalender';

  @override
  String get uiProfile => 'Profil';

  @override
  String get uiNoUpcomingMatch => 'Ingen kommende kamp';

  @override
  String get uiTheScheduleIsBeingUpdated => 'Planen opdateres';

  @override
  String get uiTeam => 'Hold';

  @override
  String get uiOpponent => 'Modstander';

  @override
  String get uiNoMatch => 'Ingen kamp';

  @override
  String get uiNoMatchPlanned => 'Ingen kamp planlagt';

  @override
  String get uiNoLocation => 'Ingen lokation';

  @override
  String get uiMap => 'Kort ›';

  @override
  String get uiLatestMatch => 'Seneste kamp';

  @override
  String get uiStandings => 'Stilling';

  @override
  String get uiStatistics => 'Statistikker';

  @override
  String get uiRegistered2 => 'tilmeldt';

  @override
  String get uiANewSeasonHasStartedAnd =>
      'Ny sæson er startet, og kampprogrammet er importeret.';

  @override
  String get uiTheMatchScheduleHasBeenUpdated => 'Kampprogrammet er opdateret.';

  @override
  String get uiStartNewSeason => 'Start ny sæson?';

  @override
  String get uiUpdateCurrent => 'Opdater nuværende';

  @override
  String get uiStartNewSeason2 => 'Start ny sæson';

  @override
  String get uiMissingResults => 'Mangler resultater';

  @override
  String get uiGoBack => 'Gå tilbage';

  @override
  String get uiStartAnyway => 'Start alligevel';

  @override
  String get uiSpring => 'Forår';

  @override
  String get uiSummer => 'Sommer';

  @override
  String get uiAutumn => 'Efterår';

  @override
  String get uiWinter => 'Vinter';

  @override
  String get uiNoTeamSelected => 'Ingen hold valgt.';

  @override
  String get uiTeamKeyFigures => 'Holdets nøgletal';

  @override
  String get uiTeamPointsAverage => 'Holdets pointsnit';

  @override
  String get uiTeamForm => 'Holdets form';

  @override
  String get uiGoalsScored => 'Mål scoret';

  @override
  String get uiGoalsConceded => 'Mål lukket ind';

  @override
  String get uiSeeTheFormTableStreaksAnd =>
      'Se formranglisten, streaks og point.';

  @override
  String get uiYourStats => 'Dine stats';

  @override
  String get uiForThisSeason => 'For denne sæson.';

  @override
  String get uiVotes => 'Stemmer';

  @override
  String get uiNoDataYet => 'Ingen data endnu.';

  @override
  String get uiSomeResultsAreLockedSeePlayer =>
      'Nogle resultater er låst. Se Player+ for at låse hele ranglisten op.';

  @override
  String get uiTheSeasonSInternalCompetitionStarts =>
      'Sæsonens interne konkurrence starter her.';

  @override
  String get uiSeasonDuels => 'Sæsondueller';

  @override
  String get uiBestPlayer => 'Bedste spiller';

  @override
  String get uiMostGoals => 'Flest mål';

  @override
  String get uiMostAssists => 'Flest assists';

  @override
  String get uiMostCards => 'Flest kort';

  @override
  String get uiCards => 'Kort';

  @override
  String get uiFineKing => 'Bødekongen';

  @override
  String get uiInternalTables => 'Interne ranglister';

  @override
  String get uiSeasonCompetitionsForOverallMvpGoals =>
      'Sæsonkonkurrencer for overall, MVP, mål, assists, kort og bøder på tværs af holdet.';

  @override
  String get uiLeagueComparison => 'Serie-sammenligning';

  @override
  String get uiComparePlayersWithOtherTeamsIn =>
      'Sammenlign spillere mod andre hold i samme række, når DBU data er synkroniseret.';

  @override
  String get uiHiddenPatterns => 'Skjulte mønstre';

  @override
  String get uiFormCurvesStreaksAndSmallInternal =>
      'Formkurver, streaks og små interne konkurrencer baseret på jeres egne kampdata.';

  @override
  String get uiTheTeamCompetitionBuiltAutomaticallyFrom =>
      'Holdkonkurrencen bygget automatisk ud fra jeres kampdata — mål, assists, streaks og bonusser.';

  @override
  String get uiCloseCalendar => 'Luk kalender';

  @override
  String get uiPreviousMonth => 'Forrige måned';

  @override
  String get uiNextMonth => 'Næste måned';

  @override
  String uiCalendarDay(Object a) {
    return 'Kalenderdag $a';
  }

  @override
  String get uiCouldNotFetchPointDetails => 'Kunne ikke hente pointdetaljer.';

  @override
  String get uiPointsStory => 'Pointfortælling';

  @override
  String get uiNoPointsInTheSelectedPeriod =>
      'Ingen point i den valgte periode.';

  @override
  String uiOnTheTeam(Object a) {
    return '#$a på holdet';
  }

  @override
  String get uiStable => 'Stabil';

  @override
  String get uiLatestRound => 'Seneste runde';

  @override
  String get uiToFirstPlace => 'Til førsteplads';

  @override
  String get uiLeading => 'Fører';

  @override
  String get uiMovement => 'Bevægelse';

  @override
  String get uiTable => 'Rangliste';

  @override
  String get uiSomethingWentWrong => 'Der skete en fejl.';

  @override
  String get uiNoPointsYetRecordMatchData =>
      'Ingen point endnu. Registrer kampdata for at starte holdkonkurrencen.';

  @override
  String get uiRestOfTheTeam => 'Resten af holdet';

  @override
  String get uiTheTeamCompetition => 'Holdkonkurrencen';

  @override
  String get uiWhoIsNinForm => 'Hvem er\ni form?';

  @override
  String get uiMatchDataStreaksAndBonusesIn =>
      'Kampdata, streaks og bonusser samlet ét sted.';

  @override
  String uiYouAreNoWith(Object a, Object b) {
    return 'Du er nr. $a med $b.';
  }

  @override
  String get uiChoosePosition => 'Vælg position';

  @override
  String get uiAllPositions => 'Alle positioner';

  @override
  String get uiWhichPositionDoYouPlay => 'Hvilken position spiller du?';

  @override
  String get uiYourPositionGivesThePointRules =>
      'Din position giver pointreglerne den rigtige vægt.';

  @override
  String uiPoints(Object a) {
    return '$a point';
  }

  @override
  String uiPoints2(Object a) {
    return 'point · $a';
  }

  @override
  String get uiCouldNotLogInAutomatically => 'Kunne ikke logge ind automatisk.';

  @override
  String get uiRegistrationFailedTryAgain =>
      'Registering mislykkedes. Prøv igen.';

  @override
  String get uiPleaseEnterYourName => 'Indtast venligst dit navn';

  @override
  String get uiPleaseEnterYourEmail => 'Indtast venligst din email';

  @override
  String get uiPleaseEnterAValidEmail => 'Indtast venligst en gyldig email';

  @override
  String get uiPleaseEnterAPassword => 'Indtast venligst en adgangskode';

  @override
  String get uiThePasswordMustBeAtLeast =>
      'Adgangskoden skal være mindst 6 tegn';

  @override
  String get uiCreateUser => 'Opret bruger';

  @override
  String get uiName => 'Navn';

  @override
  String get uiPassword => 'Adgangskode';

  @override
  String get uiCreateAccount => 'Opret konto';

  @override
  String get uiHomeTeam => 'Hjemmehold';

  @override
  String get uiEGSNderjyske => 'Fx Sønderjyske';

  @override
  String get uiAwayTeam => 'Udehold';

  @override
  String get uiEGAgf => 'Fx AGF';

  @override
  String get uiEGSydbankPark => 'Fx Sydbank Park';

  @override
  String get uiOptionalComments => 'Evt. kommentarer';

  @override
  String get uiFillInBothTeamsAndThe =>
      'Udfyld begge hold, lokation og vælg dato.';

  @override
  String get uiTheFirstAndSecondTeamCannot =>
      'Første og andet hold må ikke være ens.';

  @override
  String get uiAddPlayer => 'Tilføj spiller';

  @override
  String get uiEGLarsLarsen => 'F.eks. Lars Larsen';

  @override
  String get uiEGLarsExampleCom => 'F.eks. lars@example.com';

  @override
  String get uiEnterThePlayerSName => 'Indtast navn på spiller';

  @override
  String get uiEnterEmail => 'Indtast e-mail';

  @override
  String get uiEnterAValidEmail => 'Indtast en gyldig e-mail';

  @override
  String get uiPleaseEnterNameAndEmail => 'Indtast venligst navn og e-mail.';

  @override
  String get uiThePlayerIsAlreadyInThe =>
      'Spilleren eksisterer allerede i truppen. Angiv et andet navn og/eller e-mail.';

  @override
  String get uiNoStandingsAvailable => 'Ingen stilling tilgængelig';

  @override
  String uiTeams(Object a) {
    return '$a hold';
  }

  @override
  String get uiLeague => 'Serie';

  @override
  String uiLeague2(Object a) {
    return 'Serie $a';
  }

  @override
  String get uiTheSeasonSInternalLeague => 'Sæsonens interne liga';

  @override
  String get uiYourOverallRanking => 'Din overall placering';

  @override
  String get uiMvpCardsAndFines => 'MVP, kort og bøder';

  @override
  String get uiTheSeasonDuel => 'Sæsonduellen';

  @override
  String get ui84Points => '84 point';

  @override
  String get ui79Points => '79 point';

  @override
  String get uiYou => 'Dig?';

  @override
  String get uiPoints3 => '? point';

  @override
  String get uiSeeTheCompetitions => 'Se konkurrencerne';

  @override
  String get uiOverallPlayerOfTheMatchGoals =>
      'Overall, kampens spiller, mål, assists, kort og bøder i én intern sæsonkamp.';

  @override
  String get uiTitle => 'Titel';

  @override
  String get uiEGArrivedLate => 'F.eks. \"Kommet for sent\"';

  @override
  String get uiEG100 => 'F.eks. 100';

  @override
  String get uiEnterATitleForTheFine => 'Indtast titel på bødetype';

  @override
  String get uiEnterTheDefaultAmountForThe =>
      'Indtast standardbeløb for bødetypen';

  @override
  String get uiPleaseEnterATitleAndDefault =>
      'Indtast venligst titel og standardbeløb.';

  @override
  String get uiTheFineTypeAlreadyExistsPlease =>
      'Bødetype eksisterer allerede. Indtast venligst en anden titel.';

  @override
  String get uiRegistrationFailed => 'Registrering mislykkedes';

  @override
  String get uiYouHaveJoinedTheTeam => 'Du er nu tilmeldt holdet!';

  @override
  String get uiBecomePartOf => 'Bliv en del af';

  @override
  String get uiPleaseEnterYourPassword => 'Indtast venligst din adgangskode';

  @override
  String get uiPasswordMustBeAtLeast6 => 'Adgangskoden skal være mindst 6 tegn';

  @override
  String get uiCreateAccount2 => 'OPRET KONTO';

  @override
  String get uiLoginFailed => 'Login mislykkedes';

  @override
  String get uiLogIn => 'Log ind';

  @override
  String get uiLogIn2 => 'LOG IND';

  @override
  String get uiDonTHaveAnAccountSign =>
      'Har du ikke en bruger? Tilmeld dig her';

  @override
  String get uiNo => 'Nr. -';

  @override
  String get uiMatchHistory => 'Kamphistorik';

  @override
  String get uiNoMatchesFound => 'Ingen kampe fundet.';

  @override
  String uiSeason(Object a) {
    return 'Sæson $a';
  }

  @override
  String get uiLineup => 'Holdopstilling';

  @override
  String get uiHideLineupFromPlayers => 'Skjul holdopstilling for spillere';

  @override
  String get uiShowLineupToPlayers => 'Vis holdopstilling for spillere';

  @override
  String get uiNoBench => 'Ingen bænk';

  @override
  String get uiOnTheBench => 'På bænken:';

  @override
  String get uiGoalkeeper => 'Målmand';

  @override
  String get uiDefence => 'Forsvar';

  @override
  String get uiMidfield => 'Midtbane';

  @override
  String get uiAttack => 'Angreb';

  @override
  String get uiNoEventsRecorded => 'Ingen hændelser registreret';

  @override
  String get uiYellowCards => 'Gule kort';

  @override
  String get uiRedCards => 'Røde kort';

  @override
  String get uiRegistered3 => 'Tilmeldte';

  @override
  String get uiNoRegisteredPlayersYet => 'Ingen tilmeldte spillere endnu.';

  @override
  String get uiNoEventsRecorded2 => 'Ingen begivenheder registreret.';

  @override
  String get uiPoll => 'Afstemning';

  @override
  String get uiMatchRating => 'Kamprating';

  @override
  String get uiMatchEvents => 'Kampbegivenheder';

  @override
  String get uiNoMatchEventsRecordedYet =>
      'Ingen kampbegivenheder registreret endnu.';

  @override
  String get ui3Months => '3 måneder';

  @override
  String get uiSeason2 => 'Sæson';

  @override
  String get uiAll => 'Alle';

  @override
  String get uiCentreBack => 'Stopper';

  @override
  String get uiBackWingback => 'Back / wingback';

  @override
  String get uiDefensiveMidfield => 'Defensiv midtbane';

  @override
  String get uiAttackingMidfield => 'Offensiv midtbane';

  @override
  String get uiWinger => 'Wing';

  @override
  String get uiStriker => 'Angriber';

  @override
  String get uiStillToBePaid => 'Mangler at blive betalt';

  @override
  String get uiSelectedAmountToDeposit => 'Valgt beløb til indbetaling';

  @override
  String get uiFineType => 'Bødetype';

  @override
  String get uiPleaseChooseAFineToPay => 'Vælg venligst en bøde at indbetale.';

  @override
  String get uiAmountToDeposit => 'Beløb til indbetaling';

  @override
  String get uiPleaseEnterAnAmountGreaterThan =>
      'Indtast venligst et beløb større end 0 kr.';

  @override
  String get uiCouldNotFetchTheDbuImport =>
      'Kunne ikke hente DBU-importlogik fra serveren.';

  @override
  String get uiDbuLogin => 'DBU Login';

  @override
  String get uiSyncStandings => 'Synkroniser stilling';

  @override
  String get uiLoading => 'Indlæser';

  @override
  String get uiNoStatisticsAvailable => 'Ingen statistik tilgængelig';

  @override
  String get uiCouldNotProcessTheRequest2 => 'Kunne ikke behandle anmodning.';

  @override
  String get uiTeamRequests => 'Holdanmodninger';

  @override
  String uiAwaitingApproval(Object a) {
    return 'Afventer godkendelse ($a)';
  }

  @override
  String get uiNewRequest => 'Ny anmodning';

  @override
  String uiRequested(Object a, Object b) {
    return 'Anmodet $a/$b';
  }

  @override
  String get uiAssignFines => 'Tildel bøder';

  @override
  String get uiNoFineTypesFound => 'Ingen bødetyper fundet.';

  @override
  String get uiAddNoteOptional => 'Tilføj note (valgfri)';

  @override
  String get uiNoFinesWereAssignedPleaseChoose =>
      'Ingen bøder er tildelt. Vælg venligst mindst én spiller.';

  @override
  String get uiPolls => 'Afstemninger';

  @override
  String get uiCouldNotFetchPolls => 'Kunne ikke hente afstemninger.';

  @override
  String get uiNoPollsFound => 'Ingen afstemninger fundet.';

  @override
  String uiVotes2(Object a) {
    return '$a stemmer';
  }

  @override
  String get uiUnknownMatch => 'Ukendt kamp';

  @override
  String get uiTeamStats => 'Holdets stats';

  @override
  String get uiWon => 'Vundne';

  @override
  String get uiDrawn => 'Uafgjorte';

  @override
  String get uiLost => 'Tabte';

  @override
  String get uiGoalDifference => 'Målforskel';

  @override
  String get uiCouldNotCreateThePoll => 'Kunne ikke oprette afstemningen.';

  @override
  String get uiCastAtLeastOneVoteTo =>
      'Afgiv mindst én stemme for at gemme afstemningen.';

  @override
  String get uiCouldNotSaveThePoll => 'Kunne ikke gemme afstemningen.';

  @override
  String get uiThereAreNoMatchesToCreate =>
      'Der er ingen kampe at oprette en afstemning for.';

  @override
  String get uiChooseAValidMatch => 'Vælg en gyldig kamp.';

  @override
  String get uiAPollAlreadyExistsForThe =>
      'Afstemning til kampen eksisterer allerede. Vælg en anden kamp.';

  @override
  String get uiCastAtLeastOneVoteTo2 =>
      'Afgiv mindst én stemme for at oprette en afstemning.';

  @override
  String get uiKopaCouldNotStart => 'Kopa kunne ikke starte.';

  @override
  String uiOpenMatch(Object a) {
    return 'Åbn kamp: $a';
  }

  @override
  String get uiFinished => 'Færdig';

  @override
  String get uiBringYourTeamNtogether => 'Saml dit hold\nét sted';

  @override
  String get uiMyStats => 'Mine Stats';

  @override
  String get uiCardsYR => 'Kort (G/R)';

  @override
  String get uiShowFullTable => 'VIS FULD TABEL';

  @override
  String get uiTheFineBox => 'BØDEKASSEN';

  @override
  String get uiTotalFines => 'Samlet bøder';

  @override
  String get uiNoRanking => 'Ingen placering';

  @override
  String get uiSomethingWentWrongDuringLoginTry =>
      'Der skete en fejl under login. Prøv igen.';

  @override
  String get uiSomethingWentWrongDuringRegistrationTry =>
      'Der skete en fejl under registering. Prøv igen.';

  @override
  String get uiAddNewPlayer => 'Tilføj ny spiller';

  @override
  String get uiCouldNotFetchSeasons => 'Kunne ikke hente sæsoner';

  @override
  String get uiCouldNotStartANewSeason => 'Kunne ikke starte ny sæson';

  @override
  String get uiUpdateRequired => 'Opdatering påkrævet';

  @override
  String get uiANewVersionOfKopaIs =>
      'En ny version af Kopa er tilgængelig. Opdater venligst for at fortsætte din holdoplevelse.';

  @override
  String get uiUpdateNow => 'Opdater nu';

  @override
  String get uiMatchSchedule => 'Kampprogram';

  @override
  String get uiNoDataAvailable => 'Ingen data tilgængelig';

  @override
  String get uiWin => 'Sejr';

  @override
  String get uiDraw => 'Uafgjort';

  @override
  String get uiLoss => 'Tabt';

  @override
  String get uiLoginFailedPleaseCheckYourCredentials =>
      'Login mislykkedes. Tjek dine oplysninger.';

  @override
  String get uiRegistrationFailedPleaseTryAgain =>
      'Registrering mislykkedes. Prøv igen.';

  @override
  String get uiOutstandingFines => 'Udestående Bøder';

  @override
  String get uiTrainingAttendance => 'Træningsfremmøde';

  @override
  String get uiNotSelectedYet => 'Ikke valgt endnu';

  @override
  String uiVotes3(Object a) {
    return 'Stemmer: $a';
  }

  @override
  String get uiCouldNotFetchTheMatchSchedule =>
      'Kunne ikke hente kampprogrammet.';

  @override
  String get uiFormLast5 => 'Form (Seneste 5)';

  @override
  String get uiNotAssigned => 'Ikke tildelt';

  @override
  String get uiCouldNotFetchInForm => 'Kunne ikke hente In-form.';

  @override
  String uiTeamBadge(Object a) {
    return '$a holdmærke';
  }

  @override
  String get uiShield7 => 'Skjold 7';

  @override
  String uiTeamLeaderNames(Object a) {
    return 'Holdleder: $a';
  }

  @override
  String get uiLandingIntro =>
      'Få fuldt overblik over dine kampe, holdopstillinger, bødekasse og kommunikation på holdet.';

  @override
  String get uiNewSeasonBody =>
      'Der er allerede en aktiv sæson. Du kan opdatere det nuværende kampprogram, eller starte en ny sæson før den nye DBU-plan importeres. Hvis der mangler resultater fra den aktive sæson, advarer Kopa dig før sæsonen startes.';

  @override
  String uiMissingResultsBody(Object a, Object b) {
    return 'Der mangler resultater på $a $b i den aktive sæson. Du kan stadig starte en ny sæson, men de gamle kampe vil være låst til den afsluttede sæson uden fulde resultater.';
  }

  @override
  String uiOneEvent(Object a) {
    return '$a hændelse';
  }

  @override
  String uiManyEvents(Object a) {
    return '$a hændelser';
  }

  @override
  String uiOneMatch(Object a) {
    return '$a kamp';
  }

  @override
  String uiManyMatches(Object a) {
    return '$a kampe';
  }

  @override
  String get uiMatchSingular => 'kamp';

  @override
  String get uiMatchPlural => 'kampe';

  @override
  String get uiWeekdayInitials => 'M,T,O,T,F,L,S';

  @override
  String get uiPositionLeftBack => 'Venstre back';

  @override
  String get uiPositionCentreBack => 'Centerback';

  @override
  String get uiPositionRightBack => 'Højre back';

  @override
  String get uiPositionLeftMidfield => 'Venstre midtbane';

  @override
  String get uiPositionCentralMidfield => 'Central midtbane';

  @override
  String get uiPositionRightMidfield => 'Højre midtbane';

  @override
  String get uiPositionLeftWing => 'Venstre wing';

  @override
  String get uiPositionRightWing => 'Højre wing';

  @override
  String get uiPositionShortGoalkeeper => 'MV';

  @override
  String get uiPositionShortLeftBack => 'VB';

  @override
  String get uiPositionShortRightBack => 'HB';

  @override
  String get uiPositionShortLeftMidfield => 'VM';

  @override
  String get uiPositionShortRightMidfield => 'HM';

  @override
  String get uiPositionShortLeftWing => 'VW';

  @override
  String get uiPositionShortRightWing => 'HW';

  @override
  String get uiPositionShortDefender => 'F';

  @override
  String get uiPositionShortWing => 'K';

  @override
  String get uiPositionShortForward => 'A';

  @override
  String get uiPointsLabel => 'point';

  @override
  String get uiPlayerPlusIntro =>
      'Hvem bliver holdets bedste spiller, hvem tager flest kampens spiller, og hvem ender øverst i de sjove lister? Brug siden som overblik over Player+ universet.';

  @override
  String uiStartupFailedWithError(Object a) {
    return 'Kopa kunne ikke starte.\n$a';
  }

  @override
  String get uiFindingNextSeason => 'Finder holdets næste sæson på DBU…';

  @override
  String get uiNextSeasonFoundTitle => 'Næste sæson fundet';

  @override
  String get uiNextSeasonFoundBody =>
      'Vi har fundet holdets næste turnering på DBU ud fra den sæson, I lige har spillet. Vælg den for at starte den nye sæson og importere kampprogrammet.';

  @override
  String uiNextSeasonMatches(int count, String date) {
    return '$count kampe · første kamp $date';
  }

  @override
  String get uiFindOnDbuMyself => 'Find den selv på DBU';

  @override
  String get matchSeasonPickerTitle => 'Vælg sæson';

  @override
  String get matchSeasonActive => 'Aktiv';

  @override
  String get matchSeasonPreviousSeasons => 'Tidligere sæsoner';

  @override
  String get matchSeasonFinished => 'Afsluttet sæson';

  @override
  String matchSeasonViewingRange(String range) {
    return 'Du ser kampe fra $range';
  }

  @override
  String get matchSeasonBackToCurrent => 'Til nuværende';

  @override
  String matchSeasonStartedOn(String date) {
    return 'Startet $date';
  }

  @override
  String matchSeasonSelectorLabel(String name) {
    return 'Sæson $name. Skift sæson';
  }

  @override
  String get matchSeasonClose => 'Luk';

  @override
  String get matchSeasonNoMatches => 'Ingen kampe i denne sæson.';

  @override
  String get matchSeasonSummaryMatches => 'Kampe';

  @override
  String get matchSeasonSummaryWon => 'Vundet';

  @override
  String get matchSeasonSummaryDrawn => 'Uafgjort';

  @override
  String get matchSeasonSummaryLost => 'Tabt';

  @override
  String get resultLetterWin => 'V';

  @override
  String get resultLetterDraw => 'U';

  @override
  String get resultLetterLoss => 'T';

  @override
  String get statisticsInFormTitle => 'In-form';

  @override
  String get statisticsAssists => 'Assists';

  @override
  String get statisticsFormTitle => 'Form';

  @override
  String statisticsFormHint(int count) {
    return 'Seneste $count · nyeste til højre';
  }

  @override
  String get statisticsNoFormYet => 'Ingen spillede kampe endnu.';

  @override
  String get inFormCategoryOffensive => 'Offensiv';

  @override
  String get inFormCategoryDefensive => 'Defensiv';

  @override
  String get inFormCategoryTeamResult => 'Holdresultat';

  @override
  String get inFormCategoryDiscipline => 'Disciplin';

  @override
  String get inFormCategoryParticipation => 'Deltagelse og hæder';

  @override
  String get inFormCategoryBonus => 'Streaks og bonusser';

  @override
  String get inFormCategoryOffensiveDescription =>
      'Mål, assists og andre offensive aktioner.';

  @override
  String get inFormCategoryDefensiveDescription =>
      'Clean sheets, mål imod og reddede straffespark.';

  @override
  String get inFormCategoryTeamResultDescription =>
      'Point for holdets samlede præstation.';

  @override
  String get inFormCategoryDisciplineDescription =>
      'Kort og andre disciplinære hændelser.';

  @override
  String get inFormCategoryParticipationDescription =>
      'Spillede kampe, stemmer og kåringer som kampens spiller.';

  @override
  String get inFormCategoryBonusDescription =>
      'Ekstra point for streaks, formperioder og måneds- eller sæsonpriser.';

  @override
  String get inFormColumnPlayer => 'Spiller';

  @override
  String get inFormColumnLatest => 'Seneste';

  @override
  String get inFormColumnToFirst => 'Til nr. 1';

  @override
  String get inFormColumnTotal => 'Point';

  @override
  String get inFormPointsSystem => 'Pointsystem';

  @override
  String get inFormPointsSystemIntro =>
      'Dine point afhænger af den position, du spillede. Forsvarsspillere får mest for clean sheets, angribere for mål og assists.';

  @override
  String get inFormPointsSystemExtras =>
      'Oveni kommer streaks og formbonusser samt måneds- og sæsonpriser.';

  @override
  String get inFormMatches => 'Kampe';

  @override
  String get inFormGoals => 'Mål';

  @override
  String get inFormAssists => 'Assists';

  @override
  String get inFormCards => 'Kort';

  @override
  String get inFormMotm => 'MOTM';

  @override
  String get inFormAverage => 'Snit';

  @override
  String get inFormBonuses => 'Bonusser';

  @override
  String get inFormHome => 'Hjemme';

  @override
  String get inFormAway => 'Ude';

  @override
  String get inFormUnknownOpponent => 'Ukendt modstander';

  @override
  String inFormPlayedAs(String position) {
    return 'Spillede som $position';
  }

  @override
  String get inFormPositionChanged => 'ændret for denne kamp';

  @override
  String get inFormEditMatch => 'Ret kampdata';

  @override
  String get inFormChangePosition => 'Skift position';

  @override
  String get inFormMatchPosition => 'Position i kampen';

  @override
  String get inFormMatchPositionHint =>
      'Spillede du en anden position end normalt? Vælg den her, så dine point passer.';

  @override
  String get inFormUseProfilePosition => 'Normal position';

  @override
  String get inFormMatchDataPoints => 'Datapunkter';

  @override
  String get inFormMatchDataPointsHint =>
      'Det, som kampforløbet ikke kan vise. Afgørende mål beregnes automatisk, så ret det kun, hvis det er forkert.';

  @override
  String get inFormOwnGoals => 'Selvmål';

  @override
  String get inFormPenaltiesMissed => 'Brændte straffespark';

  @override
  String get inFormPenaltiesSaved => 'Reddede straffespark';

  @override
  String get inFormDecisiveGoals => 'Afgørende mål';

  @override
  String get inFormSave => 'Gem';

  @override
  String get inFormSaveFailed => 'Kunne ikke gemme. Prøv igen.';

  @override
  String get inFormSaved => 'Gemt – pointene er opdateret';

  @override
  String get inFormSeeHowPointsWork => 'Sådan får du point';

  @override
  String get inFormPointsSystemLoadFailed => 'Kunne ikke hente pointsystemet.';

  @override
  String get seasonOverEyebrow => 'Sæsonen er slut';

  @override
  String get seasonOverTitle => 'Tak for kampen!';

  @override
  String get seasonEmptyEyebrow => 'Ingen kampe endnu';

  @override
  String get seasonEmptyTitle => 'Klar til kickoff';

  @override
  String get seasonRecapTitle => 'Sæsonen i tal';

  @override
  String get seasonRecapMatches => 'Kampe';

  @override
  String get seasonRecapRecord => 'V-U-T';

  @override
  String get seasonRecapGoals => 'Mål';

  @override
  String get seasonChecking => 'Kigger efter næste sæson på DBU…';

  @override
  String get seasonWaitingTitle => 'Venter på næste sæson';

  @override
  String get seasonWaitingBody =>
      'DBU har endnu ikke offentliggjort jeres næste turnering. Vi tjekker hver dag og giver besked, så snart den er klar.';

  @override
  String seasonLastChecked(String time) {
    return 'Sidst tjekket $time';
  }

  @override
  String get seasonCheckAgain => 'Tjek igen';

  @override
  String get seasonImportAnyway => 'Jeg ved, den er der – importér alligevel';

  @override
  String get seasonReadyBadge => 'Ny sæson klar';

  @override
  String get seasonReadyTitle => 'Jeres næste sæson er på DBU';

  @override
  String seasonReadyMatches(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kampe · første $date',
      one: '1 kamp · første $date',
      zero: 'Første kamp $date',
    );
    return '$_temp0';
  }

  @override
  String get seasonStartNew => 'Start ny sæson';

  @override
  String get seasonNotThisOne => 'Ikke den rigtige? Find den på DBU';

  @override
  String get seasonManualTitle => 'Klar til en ny sæson?';

  @override
  String get seasonManualBody =>
      'Importér kampprogrammet fra DBU for at starte næste sæson.';

  @override
  String get wrappedMissingResultEyebrow => 'Sæsonen er næsten slut';

  @override
  String get wrappedMissingResultTitle => 'Der mangler et resultat';

  @override
  String get wrappedMissingResultBody =>
      'Indtast resultatet af sidste kamp, så kan vi pakke jeres sæson ind.';

  @override
  String wrappedMissingResultMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kampe mere mangler resultat',
      one: '1 kamp mere mangler resultat',
    );
    return '$_temp0';
  }

  @override
  String get wrappedEnterResult => 'Indtast resultat';

  @override
  String get wrappedMissingResultPlayerHint =>
      'Holdlederen indtaster resultatet, så er jeres Season Wrapped klar.';

  @override
  String get wrappedTeaserEyebrow => 'Season Wrapped';

  @override
  String get wrappedTeaserTitle => 'Jeres sæson er pakket ind';

  @override
  String get wrappedTeaserBody =>
      'Målkongen, kampens spiller og din egen sæson.';

  @override
  String get wrappedTeaserCta => 'Se jeres Wrapped';

  @override
  String get wrappedSkip => 'Spring over – gå til næste sæson';

  @override
  String get wrappedWatchAgain => 'Se jeres Season Wrapped igen';

  @override
  String wrappedProgress(int current, int total) {
    return 'Season Wrapped · $current/$total';
  }

  @override
  String get wrappedClose => 'Luk';

  @override
  String get wrappedCustomize => 'Tilpas Wrapped';

  @override
  String get wrappedPrevious => 'Forrige slide';

  @override
  String get wrappedNext => 'Næste slide';

  @override
  String get wrappedIntroTitle => 'Sæsonen,\npakket\nind.';

  @override
  String wrappedIntroBody(int matches, int goals) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches kampe',
      one: '1 kamp',
    );
    return '$_temp0. $goals mål. Et hold. Lad os se tilbage.';
  }

  @override
  String get wrappedTapToContinue => 'Tryk for at fortsætte →';

  @override
  String get wrappedTeamEyebrow => 'Holdet i tal';

  @override
  String wrappedTeamWinsLabel(int played) {
    return 'sejre\ni $played kampe';
  }

  @override
  String wrappedTeamDrawsLosses(int draws, int losses) {
    return '$draws uafgjorte · $losses nederlag';
  }

  @override
  String get wrappedGoalsFor => 'mål scoret';

  @override
  String get wrappedGoalsAgainst => 'mål imod';

  @override
  String get wrappedLastFive => 'Sidste kampe';

  @override
  String get wrappedFormWin => 'V';

  @override
  String get wrappedFormDraw => 'U';

  @override
  String get wrappedFormLoss => 'T';

  @override
  String wrappedBestStreak(int count) {
    return 'Bedste stime: $count sejre i træk.';
  }

  @override
  String wrappedYouEyebrow(String name) {
    return 'Din sæson, $name';
  }

  @override
  String get wrappedMatchesPlayed => 'kampe spillet';

  @override
  String get wrappedGoals => 'mål';

  @override
  String get wrappedAssists => 'assists';

  @override
  String get wrappedTraining => 'træning';

  @override
  String get wrappedYouTopAttendance => 'Ingen var med i flere kampe end dig.';

  @override
  String wrappedYouMoreMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kun $count spillere var med i flere kampe end dig.',
      one: 'Kun én spiller var med i flere kampe end dig.',
    );
    return '$_temp0';
  }

  @override
  String get wrappedFormEyebrow => 'Kopa-form';

  @override
  String get wrappedFormYouFinished => 'Du sluttede som';

  @override
  String wrappedFormOfPlayers(int count) {
    return 'af $count\nspillere';
  }

  @override
  String wrappedFormWinner(String name) {
    return '$name vandt Kopa-form';
  }

  @override
  String get wrappedYouSuffix => '(dig)';

  @override
  String get wrappedGoalsEyebrow => 'Målkongen';

  @override
  String wrappedGoalsLine(int goals, int percent) {
    return '$goals mål · $percent% af holdets mål';
  }

  @override
  String get wrappedAssistsEyebrow => 'Assistkongen';

  @override
  String wrappedAssistsLine(int count) {
    return '$count oplæg til holdkammeraterne';
  }

  @override
  String get wrappedDuoTitle => 'Sæsonens makkerpar';

  @override
  String wrappedDuoGoals(int count) {
    return '$count mål sammen';
  }

  @override
  String get wrappedMotmEyebrow => 'Kampens spiller';

  @override
  String wrappedMotmLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kåret $count gange af holdet',
      one: 'kåret 1 gang af holdet',
    );
    return '$_temp0';
  }

  @override
  String wrappedSeasonMatches(int count) {
    return 'Sæsonens $count kampe';
  }

  @override
  String get wrappedIronEyebrow => 'Jernmanden';

  @override
  String get wrappedIronAll => 'Med i hver eneste kamp.';

  @override
  String get wrappedIronMost => 'Med i flest kampe.';

  @override
  String get wrappedFinesEyebrow => 'Bødekongen';

  @override
  String get wrappedFinesLine => 'i bødekassen denne sæson';

  @override
  String wrappedFinesTotal(String amount) {
    return 'Holdet samlede $amount ind i alt.';
  }

  @override
  String get wrappedCardsEyebrow => 'Kortkongen';

  @override
  String wrappedCardsLine(int yellow, int red) {
    String _temp0 = intl.Intl.pluralLogic(
      yellow,
      locale: localeName,
      other: '$yellow gule',
      one: '1 gult',
    );
    String _temp1 = intl.Intl.pluralLogic(
      red,
      locale: localeName,
      other: '$red røde',
      one: '1 rødt',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get wrappedCardsFooter => 'Dommerens bedste ven.';

  @override
  String get wrappedLanternEyebrow => 'Den røde lanterne';

  @override
  String wrappedLanternLine(int rank, int count) {
    return 'nr. $rank af $count i Kopa-form';
  }

  @override
  String get wrappedLanternFooter =>
      'Nogen skal holde lanternen tændt. Næste sæson er en ny chance.';

  @override
  String get wrappedOutroTitle => 'Sæsonens priser';

  @override
  String get wrappedOutroYou => 'Din sæson';

  @override
  String wrappedOutroYouLine(int goals, int assists) {
    return '$goals mål · $assists assists';
  }

  @override
  String get wrappedShare => 'Del jeres Wrapped';

  @override
  String get wrappedShareText => 'Vores sæson i Kopa';

  @override
  String get wrappedContinue => 'Videre til næste sæson';

  @override
  String get wrappedSettingsTitle => 'Hvad skal med i Wrapped?';

  @override
  String get wrappedSettingsBody =>
      'Vi har fundet de kategorier, holdet har data til. Slå dem fra, I ikke vil have med.';

  @override
  String get wrappedSettingsSave => 'Gem';

  @override
  String get wrappedSettingsError => 'Kunne ikke gemme. Prøv igen.';

  @override
  String get wrappedSettingsNoData => 'Ikke nok data i denne sæson';

  @override
  String wrappedDetailForm(int count) {
    return '$count spillere med Kopa-form-point';
  }

  @override
  String wrappedDetailGoals(int count) {
    return '$count mål registreret';
  }

  @override
  String wrappedDetailAssists(int count) {
    return '$count assists registreret';
  }

  @override
  String wrappedDetailMotm(int count) {
    return 'Der er stemt i $count kampe';
  }

  @override
  String wrappedDetailIron(int count) {
    return 'Flest kampe: $count';
  }

  @override
  String wrappedDetailFines(String amount) {
    return '$amount i bøder';
  }

  @override
  String wrappedDetailCards(int count) {
    return '$count kort registreret';
  }

  @override
  String get wrappedDetailLantern => 'Sjov pris · sidst i Kopa-form';

  @override
  String get fineBoxMarkPaid => 'Markér som betalt';

  @override
  String fineBoxMarkPaidBody(String fine, String name) {
    return 'Markér $fine for $name som betalt? Beløbet lægges i bødekassen.';
  }

  @override
  String fineBoxMarkAllPaid(String amount) {
    return 'Markér alle som betalt ($amount)';
  }

  @override
  String fineBoxMarkAllPaidBody(String name, String amount) {
    return 'Markér alle ${name}s ubetalte bøder ($amount) som betalt? Beløbet lægges i bødekassen.';
  }

  @override
  String get fineBoxMarkPaidFailed =>
      'Bøden kunne ikke markeres som betalt. Prøv igen.';

  @override
  String get homeNextTraining => 'Næste træning';

  @override
  String get wrappedAssistsLeaders => 'Flest oplæg';

  @override
  String get settingsSectionMatches => 'Kampe';

  @override
  String get settingsSectionSeason => 'Sæson & DBU';

  @override
  String get settingsSectionTeam => 'Hold';

  @override
  String get settingsSectionMe => 'Mig';

  @override
  String get settingsInvitePlayers => 'Inviter spillere';

  @override
  String settingsPendingBannerTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spillere venter',
      one: '1 spiller venter',
    );
    return '$_temp0';
  }

  @override
  String get settingsPendingBannerBody =>
      'Godkend dem, så de kan melde sig til kampe.';

  @override
  String get settingsJoinRequestsNone => 'Ingen venter lige nu';

  @override
  String settingsJoinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count venter på godkendelse',
      one: '1 venter på godkendelse',
    );
    return '$_temp0';
  }

  @override
  String get settingsTeamLogoTitle => 'Holdlogo';

  @override
  String get settingsTeamLogoSubtitle => 'Form, farve og initialer';

  @override
  String get settingsMatchDayTitle => 'Tilmelding & kampdag';

  @override
  String get settingsMatchDayIntro => 'Sådan fungerer kampene for hele holdet.';

  @override
  String get settingsSignupQuestion => 'Hvem kommer med til kampen?';

  @override
  String get settingsRsvpFirstComeDescription =>
      'Spillere der melder sig til, kommer automatisk med.';

  @override
  String get settingsRsvpLeaderDescription =>
      'Spillerne melder sig klar, og holdlederen udvælger truppen blandt dem.';

  @override
  String get settingsMeetingTimeSection => 'Mødetid';

  @override
  String get settingsMeetingTimeLabel => 'Mød op før kampstart';

  @override
  String get settingsMeetingNone => 'Ingen';

  @override
  String settingsMeetingMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String settingsMeetingPreview(String kickoff, String meeting) {
    return 'Kampstart kl. $kickoff → mødetid kl. $meeting';
  }

  @override
  String get settingsMeetingPreviewNone =>
      'Ingen standard. Du sætter mødetiden på hver kamp.';

  @override
  String settingsMeetingSummary(int minutes) {
    return 'Mødetid $minutes min før';
  }

  @override
  String get settingsTasksSection => 'Opgaver på kampdagen';

  @override
  String get settingsTasksSubtitle => 'Faste opgaver der går på omgang';

  @override
  String get settingsAutosaveHint => 'Ændringer gemmes automatisk';

  @override
  String get settingsSaving => 'Gemmer...';

  @override
  String get settingsSaved => 'Gemt';

  @override
  String get settingsSaveFailed => 'Kunne ikke gemme. Prøv igen.';

  @override
  String get settingsSeasonSubtitle => 'Kampprogram og stilling fra DBU';

  @override
  String get settingsSeasonIntro =>
      'Hent holdets kampe og puljens stilling fra DBU.';

  @override
  String get settingsSeasonScheduleTitle => 'Kampprogram';

  @override
  String get settingsSeasonScheduleBody =>
      'Importér kampe eller start en ny sæson.';

  @override
  String get settingsSeasonImportAction => 'Importér';

  @override
  String get settingsSeasonStandingsTitle => 'Stilling';

  @override
  String get settingsSeasonStandingsBody =>
      'Opdatér stillingen og holdene i puljen.';

  @override
  String get settingsSeasonSyncAction => 'Synkronisér';

  @override
  String get settingsSeasonDbuHint =>
      'Du logger ind via DBU Kampklar, og Kopa henter dit holds data.';

  @override
  String get settingsSignupLimitSection => 'Pladser';

  @override
  String get settingsSignupLimitToggle => 'Begræns antal tilmeldte';

  @override
  String get settingsSignupLimitLabel => 'Pladser pr. kamp';

  @override
  String settingsSignupLimitHelpOn(int count) {
    return 'Når $count har meldt sig til, kommer resten på venteliste og rykker automatisk op, hvis nogen melder fra.';
  }

  @override
  String get settingsSignupLimitHelpOff =>
      'Alle der melder sig til, kommer med.';

  @override
  String get settingsSignupLimitDecrease => 'Færre pladser';

  @override
  String get settingsSignupLimitIncrease => 'Flere pladser';

  @override
  String settingsSignupLimitSummary(int count) {
    return 'maks $count';
  }

  @override
  String matchWaitlistPosition(int position) {
    return 'Venteliste #$position';
  }

  @override
  String get settingsSeasonCurrentLabel => 'Aktuel sæson';

  @override
  String get settingsSeasonNone => 'Ingen aktiv sæson';

  @override
  String settingsSeasonPoolTeams(int count) {
    return '$count hold';
  }

  @override
  String get settingsSeasonStatMatches => 'kampe';

  @override
  String get settingsSeasonStatPlayed => 'spillet';

  @override
  String get settingsSeasonStatPosition => 'plads';

  @override
  String settingsSeasonPositionValue(int position) {
    return '$position.';
  }

  @override
  String get settingsSeasonFetchSection => 'Hent fra DBU';

  @override
  String settingsSeasonScheduleMeta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kampe i sæsonen',
      one: '1 kamp i sæsonen',
    );
    return '$_temp0';
  }

  @override
  String get settingsSeasonScheduleEmpty => 'Ikke importeret endnu';

  @override
  String settingsSeasonStandingsUpdated(String date) {
    return 'Opdateret $date';
  }

  @override
  String get settingsSeasonStandingsNever => 'Ikke hentet endnu';

  @override
  String get settingsSeasonChangeSection => 'Sæsonskifte';

  @override
  String get settingsSeasonNextTitle => 'Start næste sæson';

  @override
  String settingsSeasonNextReady(String label, int count) {
    return '$label er klar på DBU med $count kampe.';
  }

  @override
  String get settingsSeasonNextWaiting =>
      'DBU har ikke offentliggjort næste sæson endnu. Du kan stadig starte den manuelt.';

  @override
  String get settingsSeasonNextUnknown =>
      'Importér den nye sæsons kampprogram, når DBU har offentliggjort det.';

  @override
  String get settingsSeasonNextButton => 'Start ny sæson';

  @override
  String settingsSeasonNextReadyButton(String label) {
    return 'Start $label';
  }

  @override
  String get settingsSeasonOtherSources => 'Andre kilder';

  @override
  String get settingsSeasonCreateMatch => 'Opret kamp manuelt';

  @override
  String get settingsSeasonCreateMatchSubtitle => 'Træningskampe og pokalkampe';

  @override
  String homeProfilePendingRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spillere venter på godkendelse',
      one: '1 spiller venter på godkendelse',
    );
    return 'Profil, $_temp0';
  }
}
