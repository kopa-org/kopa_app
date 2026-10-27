// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingPlayer => 'Player';

  @override
  String get onboardingTeamLeader => 'Team leader';

  @override
  String get onboardingRoleChoiceDescription => 'Choose your role on the team.';

  @override
  String get onboardingRoleChoiceTitle => 'What is your role?';

  @override
  String get onboardingTeamChoiceDescription =>
      'Start a new team or find your existing team on Kopa.';

  @override
  String get onboardingTeamChoiceTitle => 'Create or join a team';

  @override
  String get matchDetailsLineupTab => 'Lineup';

  @override
  String get matchFabMotmLabel => 'MOTM';

  @override
  String get matchFabResultLabel => 'Result';

  @override
  String get matchFabExternalPlayerLabel => 'Add Ext Player';

  @override
  String get matchLineupWaiting => 'Waiting for lineup';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email address and we’ll send you a code to reset your password.';

  @override
  String get forgotPasswordCodeInstructions =>
      'Enter the 6-digit code we sent to your email.';

  @override
  String get forgotPasswordEmail => 'Email';

  @override
  String get forgotPasswordEmailRequired => 'Enter your email address.';

  @override
  String get forgotPasswordEmailInvalid => 'Enter a valid email address.';

  @override
  String get forgotPasswordCode => '6-digit code';

  @override
  String get forgotPasswordCodeLength => 'The code must contain 6 digits.';

  @override
  String get forgotPasswordResend => 'Send the code again';

  @override
  String get forgotPasswordVerify => 'Verify code';

  @override
  String get forgotPasswordSendCode => 'Send code';

  @override
  String get resetCodeSent =>
      'If the account exists, we’ve sent a code. Check your inbox.';

  @override
  String get resetRequestFailed =>
      'We couldn’t send the code right now. Please try again.';

  @override
  String get resetCodeInvalid =>
      'The code is invalid or has expired. Please try again.';

  @override
  String get resetPasswordTitle => 'Choose a new password';

  @override
  String get resetPasswordNewPassword => 'New password';

  @override
  String get resetPasswordConfirm => 'Confirm password';

  @override
  String get resetPasswordMinimumLength =>
      'The password must be at least 8 characters.';

  @override
  String get resetPasswordMismatch => 'The passwords do not match.';

  @override
  String get resetPasswordSave => 'Save password';

  @override
  String get resetPasswordFailed =>
      'We couldn’t change the password. The code may have expired. Please try again.';

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
  String get homeMatchCountdownLabel => 'Match in:';

  @override
  String get homeTrainingCountdownLabel => 'Training in:';

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
  String get onboardingCreateTeam => 'Create Team';

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
  String get matchDelete => 'Delete match';

  @override
  String get matchEventDelete => 'Delete event';

  @override
  String get matchEventReorderTooltip => 'Drag to change the order';

  @override
  String get matchEventReorderFailed =>
      'Could not save the event order. Please try again.';

  @override
  String get externalPlayerDelete => 'Delete external player';

  @override
  String get matchDeleteConfirmation => 'This cannot be undone.';

  @override
  String get matchDeleteFailed => 'Could not delete. Please try again.';

  @override
  String get externalPlayerDeleteInUse =>
      'This player is used in match events or MOTM. Remove those first.';

  @override
  String get matchPollLoadPlayersFailed =>
      'Could not load players for the poll. Please try again.';

  @override
  String get matchPollUnknownPlayer => 'Unknown player';

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
  String get matchPollErrorTitle => 'Error';

  @override
  String get eventCreateTitle => 'Create event';

  @override
  String get eventCreateMatch => 'Create match';

  @override
  String get eventCreateTraining => 'Create training';

  @override
  String get eventTypeMatch => 'Match';

  @override
  String get eventTypeTraining => 'Training';

  @override
  String get eventTraining => 'Training';

  @override
  String get eventTrainingCategory => 'Category';

  @override
  String get eventTrainingCategoryHint => 'E.g. passing, drills or defence';

  @override
  String get eventCreateChoose => 'What do you want to create?';

  @override
  String get eventOpenMatch => 'Open match';

  @override
  String get eventOpenTraining => 'Open training';

  @override
  String get eventDetailsMatch => 'Match details';

  @override
  String get eventDetailsTraining => 'Training details';

  @override
  String get eventTrainingTime => 'Training time';

  @override
  String get eventCreateTrainingLocationHint => 'E.g. training pitch';

  @override
  String get eventCreateTrainingMissingFields =>
      'Enter a location and choose a date and time.';

  @override
  String get eventCreateTrainingFailed => 'Could not create the training.';

  @override
  String get eventCreateMatchFailed => 'Could not create the match.';

  @override
  String get eventCreateFailed => 'The event could not be created.';

  @override
  String get eventRsvpFailed =>
      'Could not update your attendance. Please try again.';

  @override
  String get eventEditTraining => 'Edit training';

  @override
  String get eventEditTrainingAction => 'Edit training';

  @override
  String get eventDeleteTraining => 'Delete training';

  @override
  String get eventSaveTraining => 'Save';

  @override
  String get eventCreateAction => 'Create';

  @override
  String get eventSelectDateTime => 'Choose date and time';

  @override
  String get eventRepeatWeekly => 'Repeat weekly';

  @override
  String get eventRepeatWeekdays => 'Choose weekdays and times';

  @override
  String get eventRepeatUntil => 'Repeat until';

  @override
  String get eventRepeatUntilHint => 'Choose an end date';

  @override
  String get eventRepeatMissingWeekday =>
      'Choose at least one weekday for the repetition.';

  @override
  String get eventRepeatMissingEndDate =>
      'Choose when the repetition should stop.';

  @override
  String get eventRepeatEndBeforeStart =>
      'The end date must be on or after the start date.';

  @override
  String get eventRepeatTooMany =>
      'This creates too many trainings. Choose an earlier end date.';

  @override
  String get eventUpdateTrainingFailed =>
      'Could not save the training changes.';

  @override
  String get eventWeekdayMonday => 'Monday';

  @override
  String get eventWeekdayTuesday => 'Tuesday';

  @override
  String get eventWeekdayWednesday => 'Wednesday';

  @override
  String get eventWeekdayThursday => 'Thursday';

  @override
  String get eventWeekdayFriday => 'Friday';

  @override
  String get eventWeekdaySaturday => 'Saturday';

  @override
  String get eventWeekdaySunday => 'Sunday';

  @override
  String get matchPollNoParticipants =>
      'No participants are registered for this match. Update attendance to create a poll.';

  @override
  String get matchEventPlayer => 'Player';

  @override
  String get matchEventScorer => 'Goalscorer';

  @override
  String get matchEventPlayerIn => 'Player on';

  @override
  String get matchEventPlayerOut => 'Player off';

  @override
  String get matchEventShooter => 'Taker';

  @override
  String get matchEventAssist => 'Assist (optional)';

  @override
  String get matchEventChooseMinute => 'Choose minute (optional)';

  @override
  String get matchEventAddMinute => 'Add minute (optional)';

  @override
  String get matchEventChangeMinute => 'Change minute';

  @override
  String get matchEventWithoutMinute => 'Without minute';

  @override
  String get matchEventUseMinute => 'Use minute';

  @override
  String get matchEventYellowCard => 'Yellow card';

  @override
  String get matchEventRedCard => 'Red card';

  @override
  String get matchEventPenalty => 'Penalty kick';

  @override
  String get matchEventSaveFailed =>
      'Could not save the events. Please try again.';

  @override
  String get matchEventAddMore => 'Add more';

  @override
  String get matchEventSaveAndClose => 'Save and close';

  @override
  String get matchEventTimelineTitle => 'Match events';

  @override
  String get matchEventEmptyTitle => 'No events yet';

  @override
  String get matchEventEmptyDescription =>
      'Add goals, cards and substitutions. The minute is optional.';

  @override
  String get matchEventAddAction => '+ Add event';

  @override
  String matchEventAssistedBy(String playerName) {
    return 'Assisted by $playerName';
  }

  @override
  String matchEventPlayerOff(String playerName) {
    return 'Off: $playerName';
  }

  @override
  String get mobilePayBoxTitle => 'MobilePay Box';

  @override
  String get mobilePayBoxMissing => 'MobilePay Box missing';

  @override
  String get mobilePayBoxInstructions =>
      'Paste the payment link from Share in your MobilePay Box. The short Box code cannot open a payment link.';

  @override
  String get mobilePayBoxOwnerRequired =>
      'The team owner must add the MobilePay Box payment link first.';

  @override
  String get mobilePayBoxEdit => 'Edit MobilePay Box link';

  @override
  String get mobilePayBoxAdd => 'Add Box link';

  @override
  String get mobilePayBoxInvalid =>
      'Paste the full MobilePay Box payment link. A short code such as 5289PN is not enough.';

  @override
  String get mobilePayBoxSave => 'Save MobilePay Box';

  @override
  String get mobilePayBoxSaveFailed =>
      'Could not save MobilePay Box. Try again.';

  @override
  String get mobilePayOpenFailed =>
      'Could not open MobilePay. Check that the app is installed and try again.';

  @override
  String get mobilePayBoxLinkRequired =>
      'This Box has a short code instead of a payment link. Ask the team owner to edit the Box and paste its shared payment link.';

  @override
  String get mobilePayDeposit => 'Pay with MobilePay';

  @override
  String get mobilePayGoToBox => 'Go to MobilePay Box';

  @override
  String mobilePayAmount(int amount) {
    return 'Pay $amount kr. with MobilePay';
  }

  @override
  String get matchRsvpQuestion => 'Are you coming?';

  @override
  String get matchRsvpHint => 'Let your team know.';

  @override
  String get matchRsvpAwaitingResponse => 'Awaiting response';

  @override
  String get matchRsvpConfirmed => 'You are registered for the match';

  @override
  String get matchRsvpTrainingConfirmed => 'You are registered for training';

  @override
  String get matchRsvpDeclinedMessage => 'You have declined';

  @override
  String get matchRsvpCancel => 'Cancel attendance';

  @override
  String matchRsvpAttendeeCount(int count) {
    return '$count registered';
  }

  @override
  String get matchActionsMore => 'Match options';

  @override
  String get matchActionsEditResult => 'Edit match result';

  @override
  String get matchFabCreateMotmPoll => 'MOTM: create poll';

  @override
  String get matchFabEditMotmPoll => 'MOTM: edit poll';

  @override
  String get matchFabEnterResult => 'Enter match result';

  @override
  String get matchFabAddExternalPlayers => 'Add external players';

  @override
  String get onboardingPositionTitle => 'Choose your position';

  @override
  String get onboardingPositionDescription => 'Tap your position on the pitch';

  @override
  String get onboardingSearchDescription =>
      'Find your team before choosing your position.';

  @override
  String get onboardingSelectTeam => 'Select team';

  @override
  String get onboardingExit => 'Exit signup and log out';

  @override
  String get teamRoleEdit => 'Change team role';

  @override
  String get teamRoleSaveFailed => 'Could not change the role. Try again.';

  @override
  String get teamRoleLastLeader =>
      'Assign another team leader before switching to player.';

  @override
  String get teamSquadTitle => 'Squad';

  @override
  String get teamSquadEmpty => 'No players found.';

  @override
  String get teamSquadLoadFailed =>
      'Could not load the squad. Tap to try again.';

  @override
  String teamSquadCount(int count) {
    return '$count players in the squad';
  }

  @override
  String get fineBoxTitle => 'Fine box';

  @override
  String get fineBoxMyFines => 'My fines';

  @override
  String get fineBoxSegmentOverview => 'Overview';

  @override
  String get fineBoxSegmentFineTypes => 'Fine types';

  @override
  String get fineBoxSegmentFines => 'Fines';

  @override
  String get fineBoxHeroEyebrow => 'Team kitty';

  @override
  String get fineBoxCollected => 'Collected';

  @override
  String get fineBoxOutstanding => 'Outstanding';

  @override
  String fineBoxPaidPercent(int percent) {
    return '$percent% of all fines paid';
  }

  @override
  String get fineBoxGiveFine => 'Give fine';

  @override
  String get fineBoxGiveFineHint => 'To one or more players';

  @override
  String get fineBoxDeposit => 'Deposit';

  @override
  String get fineBoxPodiumTitle => 'Fine leaders';

  @override
  String get fineBoxPodiumEmpty =>
      'No outstanding fines. The squad has a clean sheet!';

  @override
  String get fineBoxRecentTitle => 'Latest fines';

  @override
  String get fineBoxRecentEmpty => 'No fines given yet.';

  @override
  String get fineBoxCreateFineType => 'Create fine type';

  @override
  String get fineBoxCatalogTitle => 'Fine catalog';

  @override
  String get fineBoxCatalogEmpty => 'No fine types yet. Create the first one.';

  @override
  String fineBoxCatalogCount(int count) {
    return '$count types';
  }

  @override
  String get fineBoxPersonalEyebrow => 'Your balance';

  @override
  String get fineBoxPersonalOwed => 'You owe the team';

  @override
  String get fineBoxDebtFreeTitle => 'Debt free!';

  @override
  String get fineBoxDebtFreeBody =>
      'You have no unpaid fines. Keep it that way.';

  @override
  String fineBoxUnpaidCount(int count) {
    return '$count unpaid';
  }

  @override
  String get fineBoxStatFines => 'Fines';

  @override
  String get fineBoxStatPaid => 'Paid';

  @override
  String get fineBoxUnpaidTitle => 'Unpaid fines';

  @override
  String get fineBoxSelectAll => 'Select all';

  @override
  String get fineBoxDeselectAll => 'Deselect all';

  @override
  String get fineBoxHistoryTitle => 'Previous fines';

  @override
  String get fineBoxPaidBadge => 'Paid';

  @override
  String fineBoxSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get fineBoxMarkCashPaid => 'Or mark as paid in cash';

  @override
  String get fineBoxMobilePayConnected => 'MobilePay Box connected';

  @override
  String get matchTasksTitle => 'Tasks';

  @override
  String get matchTasksNoAssignee => 'Nobody selected yet';

  @override
  String get matchTasksNextInLine => 'Next in line';

  @override
  String get matchTasksChosenByLeader => 'Chosen by team leader';

  @override
  String matchTasksUpNext(String names) {
    return 'Then: $names';
  }

  @override
  String get matchTasksOneOffBadge => 'This match only';

  @override
  String get matchTasksMarkDone => 'Done';

  @override
  String get matchTasksIDidIt => 'I did it';

  @override
  String matchTasksConfirmTitle(String task) {
    return 'Is $task done?';
  }

  @override
  String matchTasksConfirmRecurring(String name) {
    return '$name moves to the back of the queue.';
  }

  @override
  String matchTasksConfirmOneOff(String name) {
    return 'The task is marked as done by $name.';
  }

  @override
  String matchTasksCompletedBy(String name) {
    return 'Done by $name';
  }

  @override
  String get matchTasksAddOneOff => 'Add task for this match';

  @override
  String get matchTasksNameLabel => 'Task name';

  @override
  String get matchTasksOneOffNameHint => 'E.g. balls or water';

  @override
  String get matchTasksPickResponsible => 'Who is responsible?';

  @override
  String get matchTasksNobodyYet => 'Choose later';

  @override
  String get matchTasksSelectedTag => 'Selected';

  @override
  String get matchTasksNotSelected => 'Not selected';

  @override
  String get matchTasksChangeResponsible => 'Change responsible';

  @override
  String get matchTasksQueueTitle => 'Queue';

  @override
  String get matchTasksCreateConfirm => 'Create';

  @override
  String get matchTasksCancel => 'Cancel';

  @override
  String get matchTasksSave => 'Save';

  @override
  String get matchTasksDelete => 'Delete task';

  @override
  String matchTasksDeleteConfirm(String task) {
    return 'Delete $task? Its queue is deleted too.';
  }

  @override
  String matchTasksDeleteOneOffConfirm(String task) {
    return 'Delete $task from this match?';
  }

  @override
  String get matchTasksReset => 'Reset queue';

  @override
  String get matchTasksResetConfirm =>
      'Reset the queue to the order players joined the team?';

  @override
  String get matchTasksError =>
      'The task could not be updated. Please try again.';

  @override
  String get matchTasksEmptyLeader =>
      'No tasks yet. Create recurring tasks such as beer and laundry in the team settings.';

  @override
  String get matchTasksEmptyPlayer =>
      'No tasks yet. Add a task for this match, e.g. balls or water.';

  @override
  String get matchTasksManage => 'Recurring tasks';

  @override
  String get teamTasksTitle => 'Match tasks';

  @override
  String get teamTasksIntro =>
      'Recurring tasks rotate on every match. The player highest in the queue who is selected gets the task. Once it is done, that player moves to the back.';

  @override
  String get teamTasksEmpty =>
      'No recurring tasks yet. Create e.g. beer, laundry or the candy bag.';

  @override
  String get teamTasksCreate => 'New recurring task';

  @override
  String get teamTasksNameHint => 'E.g. beer or laundry';

  @override
  String get teamTasksRename => 'Rename';

  @override
  String get teamTasksQueueHint => 'Drag the handle to change the order.';

  @override
  String teamTasksPlayers(int count) {
    return '$count players in the queue';
  }
}
