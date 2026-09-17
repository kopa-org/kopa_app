// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeAttendanceGoing => 'You\'re going';

  @override
  String get homeAttendanceDeclined => 'Not going';

  @override
  String get homeAttendanceQuestion => 'Are you coming?';

  @override
  String get homeAttendanceYes => 'Yes, I\'m coming';

  @override
  String get homeAttendanceNo => 'No';

  @override
  String get homeAttendanceSaving => 'Saving…';

  @override
  String get homeAttendanceChange => 'Change your response';

  @override
  String get matchDetailsDecisionTitle => 'Decision';

  @override
  String get matchDetailsDecisionPending =>
      'You are signed up, but your selection is still pending.';

  @override
  String get matchDetailsRsvpDecline => 'No, I can\'t';

  @override
  String get matchDetailsRsvpAccept => 'Yes, I\'m coming';

  @override
  String get matchDetailsRsvpRegistered => 'Registered';

  @override
  String get matchDetailsRsvpDeclineAction => 'Cancel attendance';

  @override
  String get matchDetailsRsvpDeclined => 'Not registered';

  @override
  String get matchDetailsRsvpPendingSelection =>
      'Waiting for the team leader\'s selection';

  @override
  String get teamRsvpSelectionModeLabel => 'Signup method';

  @override
  String get teamRsvpSelectionModeDescription =>
      'Choose whether players are automatically included or the team leader selects from the players who sign up.';

  @override
  String get teamRsvpFirstComeOption => 'First come, first served';

  @override
  String get teamRsvpLeaderOption => 'Team leader selects';

  @override
  String get teamRsvpSelectionSave => 'Save signup method';

  @override
  String get teamRsvpSelectionSaving => 'Saving signup method...';

  @override
  String get teamRsvpSelectionSaved => 'Signup method saved.';

  @override
  String get teamSettingsOwnerOnly =>
      'Only a team owner or admin can change team settings.';

  @override
  String get matchScoreHome => 'Home';

  @override
  String get matchScoreAway => 'Away';

  @override
  String get matchScoreHelp => 'Enter the final score for each team.';

  @override
  String get matchScoreSave => 'Save result';

  @override
  String get matchScoreSaveFailed =>
      'Could not save the result. Please try again.';

  @override
  String get commonGoTo => 'Go to';

  @override
  String get onboardingTitle => 'Join Kopa';

  @override
  String get onboardingCreateTeam => 'Create team';

  @override
  String get onboardingJoinTeam => 'Join team';

  @override
  String get onboardingTeamName => 'Team name';

  @override
  String get onboardingManual => 'Manual';

  @override
  String get onboardingDbu => 'DBU';

  @override
  String get onboardingDbuRecommendation =>
      'It is recommended to sync with DBU for the best app experience';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingCreate => 'Create';

  @override
  String get onboardingSearchHint => 'Search for a team';

  @override
  String get onboardingRequestJoin => 'Request to join';

  @override
  String get onboardingWaitingTitle => 'Waiting for approval';

  @override
  String get onboardingWaitingBody =>
      'Your request has been sent to the team admins.';

  @override
  String get onboardingCancel => 'Cancel';

  @override
  String get onboardingPlayers => 'Players';

  @override
  String get onboardingMatches => 'Matches';

  @override
  String get onboardingNoResults => 'No teams found';

  @override
  String get onboardingFailure => 'Something went wrong';

  @override
  String get matchEventChooseEvent => 'Choose event';

  @override
  String get matchDetailsMatchEvents => 'Match events';

  @override
  String get matchDetailsMatchEventsUnavailable =>
      'Match events will become available once the match result has been entered.';

  @override
  String get externalPlayerTitle => 'Add external player';

  @override
  String get externalPlayerNameHint => 'Player name';

  @override
  String get externalPlayerAdd => 'Add';

  @override
  String get externalPlayerCancel => 'Cancel';

  @override
  String get externalPlayerLabel => 'External players';

  @override
  String get externalPlayerCreateButton => 'Create external player';

  @override
  String get externalPlayerSubstitute => 'External player · On the bench';

  @override
  String get externalPlayerAddFailed =>
      'The external player could not be added. Please try again.';

  @override
  String get matchTimelineKickoff => 'Kick-off';

  @override
  String get matchTimelineHalftime => 'Half-time';

  @override
  String get matchTimelineFullTime => 'Full time';

  @override
  String get matchTimelineGoal => 'Goal';

  @override
  String get matchTimelineSubstitution => 'Substitution';

  @override
  String get matchRegisterResult => 'Register match result';

  @override
  String get matchEnterResult => 'Enter';

  @override
  String get matchScoreDialogTitle => 'Enter result';

  @override
  String get matchResultReminderTitle => 'Type match result';

  @override
  String get matchResultReminderMessage =>
      'It has been 30 minutes since kick-off. Enter the final result so the match is marked as played.';

  @override
  String get matchResultReminderAction => 'Type match result';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get maintenanceMessage =>
      'Kopa is under maintenance and will be back soon.';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonOk => 'OK';

  @override
  String get lineupVisibilityRevealMessage =>
      'The team will be notified and able to see the lineup.';

  @override
  String get lineupVisibilityRevealConfirm => 'OK, understood';

  @override
  String get lineupVisibilityRevealCancel => 'Cancel';

  @override
  String get lineupUnsavedChangesTitle => 'You forgot to save the lineup';

  @override
  String get lineupUnsavedChangesMessage =>
      'Would you like to save your changes before leaving?';

  @override
  String get lineupUnsavedChangesSave => 'Save';

  @override
  String get lineupUnsavedChangesDiscard => 'Don\'t save';

  @override
  String get fineTypeDeleteIconLabel => 'Delete fine type';

  @override
  String get fineTypeDeleteTitle => 'Delete fine type?';

  @override
  String fineTypeDeleteMessage(String title) {
    return 'Delete $title from the fine catalog?';
  }

  @override
  String get fineTypeDeleteFailureTitle => 'Could not delete fine type';

  @override
  String get fineTypeDeleteInUseMessage =>
      'This fine type is already used by existing fines.';

  @override
  String get fineTypeDeleteFailureMessage => 'Something went wrong. Try again.';

  @override
  String get teamLogoEditButton => 'Change team logo';

  @override
  String get teamLogoEditTitle => 'Change team logo';

  @override
  String get teamLogoDesignTitle => 'Design your team logo';

  @override
  String get teamLogoDesignSubtitle =>
      'Choose a background color and shape for your team logo';

  @override
  String get teamLogoBackgroundColor => 'Background color';

  @override
  String get teamLogoShape => 'Shape';

  @override
  String get teamLogoPattern => 'Pattern';

  @override
  String get teamLogoSave => 'Save logo';

  @override
  String get teamLogoSaving => 'Saving logo...';

  @override
  String get teamLogoSaveFailure => 'Could not save the team logo.';

  @override
  String get matchPollTitle => 'Player of the match';

  @override
  String get matchPollInstruction => 'Distribute votes with + and -';

  @override
  String matchPollTotalVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Total: $count votes',
      one: 'Total: 1 vote',
    );
    return '$_temp0';
  }

  @override
  String matchPollVoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get matchPollEdit => 'Edit poll';

  @override
  String get matchPollCreateTitle => 'Add poll';

  @override
  String get matchPollEditTitle => 'Edit poll';

  @override
  String get matchPollCreateAction => 'Create poll';

  @override
  String get matchPollSaveAction => 'Save changes';

  @override
  String get matchPollCreating => 'Creating...';

  @override
  String get matchPollSaving => 'Saving...';

  @override
  String get matchPollUnknownPlayer => 'Unknown player';

  @override
  String get matchPollErrorTitle => 'Error';
}
