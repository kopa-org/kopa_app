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
  String matchTasksConfirmTitle(String task) {
    return 'Is $task done?';
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

  @override
  String get teamRoleFineAdmin => 'Fine admin';

  @override
  String get teamRoleMakeFineAdmin => 'Make fine admin';

  @override
  String get teamRoleRemoveFineAdmin => 'Remove as fine admin';

  @override
  String get fineBoxWithdraw => 'Withdraw';

  @override
  String get fineBoxWithdrawTitle => 'Withdraw from the fine box';

  @override
  String fineBoxWithdrawIntro(int amount) {
    return 'Record how much you took from the box. There is $amount kr. in the box now.';
  }

  @override
  String get fineBoxWithdrawAmountHint => 'Amount';

  @override
  String get fineBoxWithdrawNoteHint => 'What was the money for? (optional)';

  @override
  String get fineBoxWithdrawSave => 'Record withdrawal';

  @override
  String get fineBoxWithdrawInvalidAmount => 'Enter an amount above 0 kr.';

  @override
  String get fineBoxWithdrawTooMuch =>
      'There is not that much money in the box.';

  @override
  String get fineBoxWithdrawFailed =>
      'Could not record the withdrawal. Try again.';

  @override
  String get fineBoxWithdrawalsTitle => 'Withdrawals';

  @override
  String get fineBoxWithdrawalNoNote => 'Withdrawal';

  @override
  String get fineBoxWithdrawalUnknownUser => 'Former player';

  @override
  String mobilePayPaidTitle(int amount) {
    return 'Have you paid $amount kr?';
  }

  @override
  String get mobilePayPaidBody =>
      'We can\'t see MobilePay payments in Kopa. If you say yes, the selected fines are marked as paid.';

  @override
  String get mobilePayPaidYes => 'Yes';

  @override
  String get mobilePayPaidNo => 'No';

  @override
  String get mobilePayPaidSaveFailed =>
      'Your payment could not be saved. Please try again.';

  @override
  String get fineBoxSeeAll => 'See all';

  @override
  String get fineBoxPlayersTitle => 'All players';

  @override
  String get fineBoxAllFinesTitle => 'All fines';

  @override
  String get fineBoxInBox => 'In the box';

  @override
  String get fineBoxAllPaid => 'All paid';

  @override
  String get fineBoxDeleteFine => 'Delete fine';

  @override
  String get fineBoxDeleteCancel => 'Cancel';

  @override
  String get fineBoxDeleteFailed => 'The fine could not be deleted. Try again.';

  @override
  String fineBoxPlayerFineCount(int count) {
    return '$count fines';
  }

  @override
  String fineBoxDeleteFineBody(String fine, String name) {
    return 'Delete $fine for $name? This cannot be undone.';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navMatches => 'Matches';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navSquad => 'Squad';

  @override
  String get navFineBox => 'Fine box';

  @override
  String get uiChooseDbuTeam => 'Choose DBU team';

  @override
  String get uiCancel => 'Cancel';

  @override
  String get uiCouldNotFetchTheInviteLink => 'Could not fetch the invite link.';

  @override
  String get uiLinkCopied => 'Link copied';

  @override
  String uiJoinOnKopa(Object a, Object b) {
    return 'Join $a on Kopa: $b';
  }

  @override
  String get uiCouldNotSaveThePositionTry =>
      'Could not save the position. Try again.';

  @override
  String get uiInviteYourTeam => 'Invite your team';

  @override
  String get uiCreateYourFootballTeamAndKeep =>
      'Create your football team and keep players, matches and statistics in one place.';

  @override
  String get uiShareTheLinkWithThePlayers =>
      'Share the link with the players so they can find the team.';

  @override
  String get uiContinueToKopa => 'Continue to Kopa';

  @override
  String get uiAssociation => 'Association';

  @override
  String get uiYourTeamName => 'Your team name';

  @override
  String uiYouChose(Object a, Object b) {
    return 'You chose: $a ($b)';
  }

  @override
  String get ui7ASide => '7-a-side';

  @override
  String get ui11ASide => '11-a-side';

  @override
  String get uiSearchResults => 'Search results';

  @override
  String uiTeamLeader(Object a) {
    return 'Team leader: $a';
  }

  @override
  String get uiTeamLeaderPending => 'Team leader: Pending';

  @override
  String uiMembers(Object a) {
    return '$a members';
  }

  @override
  String get uiTheInviteLinkCouldNotBe =>
      'The invite link could not be fetched.';

  @override
  String get uiCopyLink => 'Copy link';

  @override
  String get uiShareLink => 'Share link';

  @override
  String get uiBack => 'Back';

  @override
  String uiStepOf(Object a, Object b) {
    return 'Step $a of $b';
  }

  @override
  String get uiDbuConnected => 'DBU connected';

  @override
  String get uiTeamDataHasBeenImported => 'Team data has been imported';

  @override
  String get uiLogInThroughDbuToImport =>
      'Log in through DBU to import team data';

  @override
  String get uiYourTeam => 'your team';

  @override
  String get uiYourTeam2 => 'Your team';

  @override
  String get uiStep3Of5 => 'Step 3 of 5';

  @override
  String get uiWaitingForApproval => 'Waiting for approval';

  @override
  String uiYouHaveAskedToJoinYou(Object a) {
    return 'You have asked to join $a. You will be notified when the team leader has accepted your request.';
  }

  @override
  String get uiPending => 'Pending';

  @override
  String get uiCouldNotValidateTheInvitation =>
      'Could not validate the invitation';

  @override
  String get uiNetworkError => 'Network error';

  @override
  String get uiNotLoggedIn => 'Not logged in';

  @override
  String get uiCouldNotJoinTheTeam => 'Could not join the team';

  @override
  String get uiCouldNotFetchTheCode => 'Could not fetch the code';

  @override
  String get uiCouldNotRotateTheCode => 'Could not rotate the code';

  @override
  String get uiCouldNotCreateTheTeam => 'Could not create the team';

  @override
  String get uiCouldNotSearchForTeams => 'Could not search for teams';

  @override
  String get uiCouldNotSendTheRequest => 'Could not send the request';

  @override
  String get uiCouldNotFetchTheRequest => 'Could not fetch the request';

  @override
  String get uiCouldNotFetchTheRequests => 'Could not fetch the requests';

  @override
  String get uiCouldNotProcessTheRequest => 'Could not process the request';

  @override
  String get uiCouldNotCancelTheRequest => 'Could not cancel the request';

  @override
  String get uiInvalidInvitation => 'Invalid invitation';

  @override
  String get uiSomethingWentWrongPleaseTryAgain =>
      'Something went wrong. Please try again later.';

  @override
  String get uiNoUserFound => 'No user found.';

  @override
  String get uiPracticalInformation => 'Practical information';

  @override
  String get uiRegisteredPlayers => 'Registered players';

  @override
  String get uiDate => 'Date';

  @override
  String get uiTime => 'Time';

  @override
  String get uiLocation => 'Location';

  @override
  String get uiCountdown => 'Countdown';

  @override
  String get uiRegistrations => 'Registrations';

  @override
  String uiRegistered(Object a) {
    return '$a registered';
  }

  @override
  String get uiMeetingTime => 'Meeting time';

  @override
  String get uiYourSelection => 'Your selection';

  @override
  String get uiNotes => 'Notes';

  @override
  String get uiNoResponse => 'No response';

  @override
  String get uiDeclined => 'Declined';

  @override
  String uiAvailable(Object a) {
    return 'Available ($a)';
  }

  @override
  String uiSelected(Object a) {
    return 'Selected ($a)';
  }

  @override
  String uiNoResponse2(Object a) {
    return 'No response ($a)';
  }

  @override
  String uiDeclined2(Object a) {
    return 'Declined ($a)';
  }

  @override
  String get uiCouldNotUpdateTheApprovalTry =>
      'Could not update the approval. Try again.';

  @override
  String get uiCouldNotApproveEveryoneTryAgain =>
      'Could not approve everyone. Try again.';

  @override
  String get uiCouldNotChangeTheVisibilityTry =>
      'Could not change the visibility. Try again.';

  @override
  String get uiInProgressOrFinished => 'In progress or finished';

  @override
  String uiDaysHours(Object a, Object b) {
    return '$a days $b hours';
  }

  @override
  String uiReject(Object a) {
    return 'Reject $a';
  }

  @override
  String uiApprove(Object a) {
    return 'Approve $a';
  }

  @override
  String get uiApproved => 'Approved';

  @override
  String get uiRejected => 'Rejected';

  @override
  String uiEditChoiceFor(Object a) {
    return 'Edit choice for $a';
  }

  @override
  String get uiNoPlayersAreAwaitingApproval =>
      'No players are awaiting approval.';

  @override
  String get uiApproveAll => 'Approve all';

  @override
  String get uiNoPlayersHere => 'No players here.';

  @override
  String get uiCouldNotSaveTheLineupTry =>
      'Could not save the lineup. Try again.';

  @override
  String get uiChoosePlayer => 'Choose player';

  @override
  String get uiEditLineup => 'Edit lineup';

  @override
  String uiEditFormation(Object a) {
    return 'Edit formation ($a)';
  }

  @override
  String uiMovePlayerReleaseToPlace(Object a) {
    return 'Move player: Release to place $a';
  }

  @override
  String uiBenchPlayers(Object a) {
    return 'Bench ($a players)';
  }

  @override
  String get uiNoPlayersOnTheBench => 'No players on the bench';

  @override
  String get uiHoldAPlayerAndDragTo => 'Hold a player and drag to swap places';

  @override
  String get uiChooseFormation => 'Choose formation';

  @override
  String get uiChooseTheFormationThatSuitsYour =>
      'Choose the formation that suits your next match best';

  @override
  String uiFormation(Object a) {
    return 'Formation $a';
  }

  @override
  String get uiGk => 'GK';

  @override
  String get uiAm => 'AM';

  @override
  String get uiPl => 'PL';

  @override
  String get uiStandard7ASide => 'Standard 7-a-side';

  @override
  String get uiDefensiveBalance => 'Defensive balance';

  @override
  String get uiSymmetricControl => 'Symmetric control';

  @override
  String get uiAttackingWidth => 'Attacking width';

  @override
  String get uiClassicBalance => 'Classic balance';

  @override
  String get uiMidfieldControl => 'Midfield control';

  @override
  String get uiControlledPressing => 'Controlled pressing';

  @override
  String get uiCustomLineup => 'Custom lineup';

  @override
  String get uiSettings => 'Settings';

  @override
  String get uiImportMatchSchedule => 'Import match schedule';

  @override
  String get uiFetchingLink => 'Fetching link...';

  @override
  String get uiShareKopa => 'Share Kopa';

  @override
  String get uiTeamTools => 'Team tools';

  @override
  String get uiApproveNewPlayers => 'Approve new players';

  @override
  String get uiSyncingStandings => 'Syncing standings...';

  @override
  String get uiSyncStandingsFromDbu => 'Sync standings from DBU';

  @override
  String get uiDefaultMeetingTime => 'Default meeting time';

  @override
  String get uiSavingMeetingTime => 'Saving meeting time...';

  @override
  String get uiSaveMeetingTime => 'Save meeting time';

  @override
  String get uiLoggingOut => 'Logging out...';

  @override
  String get uiLogOut => 'Log out';

  @override
  String get uiCouldNotLogOut => 'Could not log out.';

  @override
  String get uiYouMustBeOnATeam => 'You must be on a team to share Kopa.';

  @override
  String get uiCouldNotShareKopa => 'Could not share Kopa.';

  @override
  String get uiOnlyTheTeamLeaderCanChange =>
      'Only the team leader can change the meeting time.';

  @override
  String uiTheDefaultMeetingTimeIsSet(Object a) {
    return 'The default meeting time is set to $a.';
  }

  @override
  String get uiNoDefault => 'No default';

  @override
  String uiMinBeforeKickoff(Object a) {
    return '$a min before kickoff';
  }

  @override
  String uiStandingsAndPoolTeamsAreSynced(Object a) {
    return 'Standings and pool teams are synced ($a teams).';
  }

  @override
  String uiFines(Object a) {
    return 'Fines - $a';
  }

  @override
  String get ui1HourAgo => '1 hour ago';

  @override
  String uiHoursAgo(Object a) {
    return '$a hours ago';
  }

  @override
  String get uiYesterday => 'Yesterday';

  @override
  String uiDaysAgo(Object a) {
    return '$a days ago';
  }

  @override
  String get uiUserNotLoggedIn => 'User not logged in';

  @override
  String get uiCouldNotFetchDashboardData => 'Could not fetch dashboard data';

  @override
  String get uiCalendar => 'Calendar';

  @override
  String get uiProfile => 'Profile';

  @override
  String get uiNoUpcomingMatch => 'No upcoming match';

  @override
  String get uiTheScheduleIsBeingUpdated => 'The schedule is being updated';

  @override
  String get uiTeam => 'Team';

  @override
  String get uiOpponent => 'Opponent';

  @override
  String get uiNoMatch => 'No match';

  @override
  String get uiNoMatchPlanned => 'No match planned';

  @override
  String get uiNoLocation => 'No location';

  @override
  String get uiMap => 'Map ›';

  @override
  String get uiLatestMatch => 'Latest match';

  @override
  String get uiStandings => 'Standings';

  @override
  String get uiStatistics => 'Statistics';

  @override
  String get uiRegistered2 => 'registered';

  @override
  String get uiANewSeasonHasStartedAnd =>
      'A new season has started and the match schedule has been imported.';

  @override
  String get uiTheMatchScheduleHasBeenUpdated =>
      'The match schedule has been updated.';

  @override
  String get uiStartNewSeason => 'Start new season?';

  @override
  String get uiUpdateCurrent => 'Update current';

  @override
  String get uiStartNewSeason2 => 'Start new season';

  @override
  String get uiMissingResults => 'Missing results';

  @override
  String get uiGoBack => 'Go back';

  @override
  String get uiStartAnyway => 'Start anyway';

  @override
  String get uiSpring => 'Spring';

  @override
  String get uiSummer => 'Summer';

  @override
  String get uiAutumn => 'Autumn';

  @override
  String get uiWinter => 'Winter';

  @override
  String get uiNoTeamSelected => 'No team selected.';

  @override
  String get uiTeamKeyFigures => 'Team key figures';

  @override
  String get uiTeamPointsAverage => 'Team points average';

  @override
  String get uiTeamForm => 'Team form';

  @override
  String get uiGoalsScored => 'Goals scored';

  @override
  String get uiGoalsConceded => 'Goals conceded';

  @override
  String get uiSeeTheFormTableStreaksAnd =>
      'See the form table, streaks and points.';

  @override
  String get uiYourStats => 'Your stats';

  @override
  String get uiForThisSeason => 'For this season.';

  @override
  String get uiVotes => 'Votes';

  @override
  String get uiNoDataYet => 'No data yet.';

  @override
  String get uiSomeResultsAreLockedSeePlayer =>
      'Some results are locked. See Player+ to unlock the full table.';

  @override
  String get uiTheSeasonSInternalCompetitionStarts =>
      'The season\'s internal competition starts here.';

  @override
  String get uiSeasonDuels => 'Season duels';

  @override
  String get uiBestPlayer => 'Best player';

  @override
  String get uiMostGoals => 'Most goals';

  @override
  String get uiMostAssists => 'Most assists';

  @override
  String get uiMostCards => 'Most cards';

  @override
  String get uiCards => 'Cards';

  @override
  String get uiFineKing => 'Fine king';

  @override
  String get uiInternalTables => 'Internal tables';

  @override
  String get uiSeasonCompetitionsForOverallMvpGoals =>
      'Season competitions for overall, MVP, goals, assists, cards and fines across the team.';

  @override
  String get uiLeagueComparison => 'League comparison';

  @override
  String get uiComparePlayersWithOtherTeamsIn =>
      'Compare players with other teams in the same league once DBU data is synced.';

  @override
  String get uiHiddenPatterns => 'Hidden patterns';

  @override
  String get uiFormCurvesStreaksAndSmallInternal =>
      'Form curves, streaks and small internal competitions based on your own match data.';

  @override
  String get uiTheTeamCompetitionBuiltAutomaticallyFrom =>
      'The team competition built automatically from your match data — goals, assists, streaks and bonuses.';

  @override
  String get uiCloseCalendar => 'Close calendar';

  @override
  String get uiPreviousMonth => 'Previous month';

  @override
  String get uiNextMonth => 'Next month';

  @override
  String uiCalendarDay(Object a) {
    return 'Calendar day $a';
  }

  @override
  String get uiCouldNotFetchPointDetails => 'Could not fetch point details.';

  @override
  String get uiPointsStory => 'Points story';

  @override
  String get uiNoPointsInTheSelectedPeriod =>
      'No points in the selected period.';

  @override
  String uiOnTheTeam(Object a) {
    return '#$a on the team';
  }

  @override
  String get uiStable => 'Stable';

  @override
  String get uiLatestRound => 'Latest round';

  @override
  String get uiToFirstPlace => 'To first place';

  @override
  String get uiLeading => 'Leading';

  @override
  String get uiMovement => 'Movement';

  @override
  String get uiTable => 'Table';

  @override
  String get uiSomethingWentWrong => 'Something went wrong.';

  @override
  String get uiNoPointsYetRecordMatchData =>
      'No points yet. Record match data to start the team competition.';

  @override
  String get uiRestOfTheTeam => 'Rest of the team';

  @override
  String get uiTheTeamCompetition => 'The team competition';

  @override
  String get uiWhoIsNinForm => 'Who is\nin form?';

  @override
  String get uiMatchDataStreaksAndBonusesIn =>
      'Match data, streaks and bonuses in one place.';

  @override
  String uiYouAreNoWith(Object a, Object b) {
    return 'You are no. $a with $b.';
  }

  @override
  String get uiChoosePosition => 'Choose position';

  @override
  String get uiAllPositions => 'All positions';

  @override
  String get uiWhichPositionDoYouPlay => 'Which position do you play?';

  @override
  String get uiYourPositionGivesThePointRules =>
      'Your position gives the point rules the right weight.';

  @override
  String uiPoints(Object a) {
    return '$a points';
  }

  @override
  String uiPoints2(Object a) {
    return 'points · $a';
  }

  @override
  String get uiCouldNotLogInAutomatically => 'Could not log in automatically.';

  @override
  String get uiRegistrationFailedTryAgain => 'Registration failed. Try again.';

  @override
  String get uiPleaseEnterYourName => 'Please enter your name';

  @override
  String get uiPleaseEnterYourEmail => 'Please enter your email';

  @override
  String get uiPleaseEnterAValidEmail => 'Please enter a valid email';

  @override
  String get uiPleaseEnterAPassword => 'Please enter a password';

  @override
  String get uiThePasswordMustBeAtLeast =>
      'The password must be at least 6 characters';

  @override
  String get uiCreateUser => 'Create user';

  @override
  String get uiName => 'Name';

  @override
  String get uiPassword => 'Password';

  @override
  String get uiCreateAccount => 'Create account';

  @override
  String get uiHomeTeam => 'Home team';

  @override
  String get uiEGSNderjyske => 'E.g. Sønderjyske';

  @override
  String get uiAwayTeam => 'Away team';

  @override
  String get uiEGAgf => 'E.g. AGF';

  @override
  String get uiEGSydbankPark => 'E.g. Sydbank Park';

  @override
  String get uiOptionalComments => 'Optional comments';

  @override
  String get uiFillInBothTeamsAndThe =>
      'Fill in both teams and the location, and choose a date.';

  @override
  String get uiTheFirstAndSecondTeamCannot =>
      'The first and second team cannot be the same.';

  @override
  String get uiAddPlayer => 'Add player';

  @override
  String get uiEGLarsLarsen => 'E.g. Lars Larsen';

  @override
  String get uiEGLarsExampleCom => 'E.g. lars@example.com';

  @override
  String get uiEnterThePlayerSName => 'Enter the player\'s name';

  @override
  String get uiEnterEmail => 'Enter email';

  @override
  String get uiEnterAValidEmail => 'Enter a valid email';

  @override
  String get uiPleaseEnterNameAndEmail => 'Please enter name and email.';

  @override
  String get uiThePlayerIsAlreadyInThe =>
      'The player is already in the squad. Enter another name and/or email.';

  @override
  String get uiNoStandingsAvailable => 'No standings available';

  @override
  String uiTeams(Object a) {
    return '$a teams';
  }

  @override
  String get uiLeague => 'League';

  @override
  String uiLeague2(Object a) {
    return 'League $a';
  }

  @override
  String get uiTheSeasonSInternalLeague => 'The season\'s internal league';

  @override
  String get uiYourOverallRanking => 'Your overall ranking';

  @override
  String get uiMvpCardsAndFines => 'MVP, cards and fines';

  @override
  String get uiTheSeasonDuel => 'The season duel';

  @override
  String get ui84Points => '84 points';

  @override
  String get ui79Points => '79 points';

  @override
  String get uiYou => 'You?';

  @override
  String get uiPoints3 => '? points';

  @override
  String get uiSeeTheCompetitions => 'See the competitions';

  @override
  String get uiOverallPlayerOfTheMatchGoals =>
      'Overall, player of the match, goals, assists, cards and fines in one internal season battle.';

  @override
  String get uiTitle => 'Title';

  @override
  String get uiEGArrivedLate => 'E.g. \"Arrived late\"';

  @override
  String get uiEG100 => 'E.g. 100';

  @override
  String get uiEnterATitleForTheFine => 'Enter a title for the fine type';

  @override
  String get uiEnterTheDefaultAmountForThe =>
      'Enter the default amount for the fine type';

  @override
  String get uiPleaseEnterATitleAndDefault =>
      'Please enter a title and default amount.';

  @override
  String get uiTheFineTypeAlreadyExistsPlease =>
      'The fine type already exists. Please enter another title.';

  @override
  String get uiRegistrationFailed => 'Registration failed';

  @override
  String get uiYouHaveJoinedTheTeam => 'You have joined the team!';

  @override
  String get uiBecomePartOf => 'Become part of';

  @override
  String get uiPleaseEnterYourPassword => 'Please enter your password';

  @override
  String get uiPasswordMustBeAtLeast6 =>
      'Password must be at least 6 characters';

  @override
  String get uiCreateAccount2 => 'CREATE ACCOUNT';

  @override
  String get uiLoginFailed => 'Login failed';

  @override
  String get uiLogIn => 'Log in';

  @override
  String get uiLogIn2 => 'LOG IN';

  @override
  String get uiDonTHaveAnAccountSign => 'Don\'t have an account? Sign up here';

  @override
  String get uiNo => 'No. -';

  @override
  String get uiMatchHistory => 'Match history';

  @override
  String get uiNoMatchesFound => 'No matches found.';

  @override
  String uiSeason(Object a) {
    return 'Season $a';
  }

  @override
  String get uiLineup => 'Lineup';

  @override
  String get uiHideLineupFromPlayers => 'Hide lineup from players';

  @override
  String get uiShowLineupToPlayers => 'Show lineup to players';

  @override
  String get uiNoBench => 'No bench';

  @override
  String get uiOnTheBench => 'On the bench:';

  @override
  String get uiGoalkeeper => 'Goalkeeper';

  @override
  String get uiDefence => 'Defence';

  @override
  String get uiMidfield => 'Midfield';

  @override
  String get uiAttack => 'Attack';

  @override
  String get uiNoEventsRecorded => 'No events recorded';

  @override
  String get uiYellowCards => 'Yellow cards';

  @override
  String get uiRedCards => 'Red cards';

  @override
  String get uiRegistered3 => 'Registered';

  @override
  String get uiNoRegisteredPlayersYet => 'No registered players yet.';

  @override
  String get uiNoEventsRecorded2 => 'No events recorded.';

  @override
  String get uiPoll => 'Poll';

  @override
  String get uiMatchRating => 'Match rating';

  @override
  String get uiMatchEvents => 'Match events';

  @override
  String get uiNoMatchEventsRecordedYet => 'No match events recorded yet.';

  @override
  String get ui3Months => '3 months';

  @override
  String get uiSeason2 => 'Season';

  @override
  String get uiAll => 'All';

  @override
  String get uiCentreBack => 'Centre back';

  @override
  String get uiBackWingback => 'Back / wingback';

  @override
  String get uiDefensiveMidfield => 'Defensive midfield';

  @override
  String get uiAttackingMidfield => 'Attacking midfield';

  @override
  String get uiWinger => 'Winger';

  @override
  String get uiStriker => 'Striker';

  @override
  String get uiStillToBePaid => 'Still to be paid';

  @override
  String get uiSelectedAmountToDeposit => 'Selected amount to deposit';

  @override
  String get uiFineType => 'Fine type';

  @override
  String get uiPleaseChooseAFineToPay => 'Please choose a fine to pay.';

  @override
  String get uiAmountToDeposit => 'Amount to deposit';

  @override
  String get uiPleaseEnterAnAmountGreaterThan =>
      'Please enter an amount greater than 0 kr.';

  @override
  String get uiCouldNotFetchTheDbuImport =>
      'Could not fetch the DBU import logic from the server.';

  @override
  String get uiDbuLogin => 'DBU login';

  @override
  String get uiSyncStandings => 'Sync standings';

  @override
  String get uiLoading => 'Loading';

  @override
  String get uiNoStatisticsAvailable => 'No statistics available';

  @override
  String get uiCouldNotProcessTheRequest2 => 'Could not process the request.';

  @override
  String get uiTeamRequests => 'Team requests';

  @override
  String uiAwaitingApproval(Object a) {
    return 'Awaiting approval ($a)';
  }

  @override
  String get uiNewRequest => 'New request';

  @override
  String uiRequested(Object a, Object b) {
    return 'Requested $a/$b';
  }

  @override
  String get uiAssignFines => 'Assign fines';

  @override
  String get uiNoFineTypesFound => 'No fine types found.';

  @override
  String get uiAddNoteOptional => 'Add note (optional)';

  @override
  String get uiNoFinesWereAssignedPleaseChoose =>
      'No fines were assigned. Please choose at least one player.';

  @override
  String get uiPolls => 'Polls';

  @override
  String get uiCouldNotFetchPolls => 'Could not fetch polls.';

  @override
  String get uiNoPollsFound => 'No polls found.';

  @override
  String uiVotes2(Object a) {
    return '$a votes';
  }

  @override
  String get uiUnknownMatch => 'Unknown match';

  @override
  String get uiTeamStats => 'Team stats';

  @override
  String get uiWon => 'Won';

  @override
  String get uiDrawn => 'Drawn';

  @override
  String get uiLost => 'Lost';

  @override
  String get uiGoalDifference => 'Goal difference';

  @override
  String get uiCouldNotCreateThePoll => 'Could not create the poll.';

  @override
  String get uiCastAtLeastOneVoteTo =>
      'Cast at least one vote to save the poll.';

  @override
  String get uiCouldNotSaveThePoll => 'Could not save the poll.';

  @override
  String get uiThereAreNoMatchesToCreate =>
      'There are no matches to create a poll for.';

  @override
  String get uiChooseAValidMatch => 'Choose a valid match.';

  @override
  String get uiAPollAlreadyExistsForThe =>
      'A poll already exists for the match. Choose another match.';

  @override
  String get uiCastAtLeastOneVoteTo2 =>
      'Cast at least one vote to create a poll.';

  @override
  String get uiKopaCouldNotStart => 'Kopa could not start.';

  @override
  String uiOpenMatch(Object a) {
    return 'Open match: $a';
  }

  @override
  String get uiFinished => 'Finished';

  @override
  String get uiBringYourTeamNtogether => 'Bring your team\ntogether';

  @override
  String get uiMyStats => 'My stats';

  @override
  String get uiCardsYR => 'Cards (Y/R)';

  @override
  String get uiShowFullTable => 'SHOW FULL TABLE';

  @override
  String get uiTheFineBox => 'THE FINE BOX';

  @override
  String get uiTotalFines => 'Total fines';

  @override
  String get uiNoRanking => 'No ranking';

  @override
  String get uiSomethingWentWrongDuringLoginTry =>
      'Something went wrong during login. Try again.';

  @override
  String get uiSomethingWentWrongDuringRegistrationTry =>
      'Something went wrong during registration. Try again.';

  @override
  String get uiAddNewPlayer => 'Add new player';

  @override
  String get uiCouldNotFetchSeasons => 'Could not fetch seasons';

  @override
  String get uiCouldNotStartANewSeason => 'Could not start a new season';

  @override
  String get uiUpdateRequired => 'Update required';

  @override
  String get uiANewVersionOfKopaIs =>
      'A new version of Kopa is available. Please update to continue.';

  @override
  String get uiUpdateNow => 'Update now';

  @override
  String get uiMatchSchedule => 'Match schedule';

  @override
  String get uiNoDataAvailable => 'No data available';

  @override
  String get uiWin => 'Win';

  @override
  String get uiDraw => 'Draw';

  @override
  String get uiLoss => 'Loss';

  @override
  String get uiLoginFailedPleaseCheckYourCredentials =>
      'Login failed. Please check your credentials.';

  @override
  String get uiRegistrationFailedPleaseTryAgain =>
      'Registration failed. Please try again.';

  @override
  String get uiOutstandingFines => 'Outstanding fines';

  @override
  String get uiTrainingAttendance => 'Training attendance';

  @override
  String get uiNotSelectedYet => 'Not selected yet';

  @override
  String uiVotes3(Object a) {
    return 'Votes: $a';
  }

  @override
  String get uiCouldNotFetchTheMatchSchedule =>
      'Could not fetch the match schedule.';

  @override
  String get uiFormLast5 => 'Form (last 5)';

  @override
  String get uiNotAssigned => 'Not assigned';

  @override
  String get uiCouldNotFetchInForm => 'Could not fetch In-form.';

  @override
  String uiTeamBadge(Object a) {
    return '$a team badge';
  }

  @override
  String get uiShield7 => 'Shield 7';

  @override
  String uiTeamLeaderNames(Object a) {
    return 'Team leader: $a';
  }

  @override
  String get uiLandingIntro =>
      'Get a full overview of your matches, lineups, fine box and team communication.';

  @override
  String get uiNewSeasonBody =>
      'There is already an active season. You can update the current match schedule or start a new season before importing the new DBU schedule. If results are missing from the active season, Kopa warns you before the season starts.';

  @override
  String uiMissingResultsBody(Object a, Object b) {
    return 'Results are missing for $a $b in the active season. You can still start a new season, but the old matches will be locked to the finished season without full results.';
  }

  @override
  String uiOneEvent(Object a) {
    return '$a event';
  }

  @override
  String uiManyEvents(Object a) {
    return '$a events';
  }

  @override
  String uiOneMatch(Object a) {
    return '$a match';
  }

  @override
  String uiManyMatches(Object a) {
    return '$a matches';
  }

  @override
  String get uiMatchSingular => 'match';

  @override
  String get uiMatchPlural => 'matches';

  @override
  String get uiWeekdayInitials => 'M,T,W,T,F,S,S';

  @override
  String get uiPositionLeftBack => 'Left back';

  @override
  String get uiPositionCentreBack => 'Centre back';

  @override
  String get uiPositionRightBack => 'Right back';

  @override
  String get uiPositionLeftMidfield => 'Left midfield';

  @override
  String get uiPositionCentralMidfield => 'Central midfield';

  @override
  String get uiPositionRightMidfield => 'Right midfield';

  @override
  String get uiPositionLeftWing => 'Left wing';

  @override
  String get uiPositionRightWing => 'Right wing';

  @override
  String get uiPositionShortGoalkeeper => 'GK';

  @override
  String get uiPositionShortLeftBack => 'LB';

  @override
  String get uiPositionShortRightBack => 'RB';

  @override
  String get uiPositionShortLeftMidfield => 'LM';

  @override
  String get uiPositionShortRightMidfield => 'RM';

  @override
  String get uiPositionShortLeftWing => 'LW';

  @override
  String get uiPositionShortRightWing => 'RW';

  @override
  String get uiPositionShortDefender => 'D';

  @override
  String get uiPositionShortWing => 'W';

  @override
  String get uiPositionShortForward => 'F';

  @override
  String get uiPointsLabel => 'points';

  @override
  String get uiPlayerPlusIntro =>
      'Who becomes the team\'s best player, who wins player of the match most often, and who ends up on top of the fun tables? Use this page as an overview of the Player+ universe.';

  @override
  String uiStartupFailedWithError(Object a) {
    return 'Kopa could not start.\n$a';
  }

  @override
  String get uiFindingNextSeason =>
      'Looking for the team\'s next season on DBU…';

  @override
  String get uiNextSeasonFoundTitle => 'Next season found';

  @override
  String get uiNextSeasonFoundBody =>
      'We found the team\'s next tournament on DBU, based on the season you just played. Choose it to start the new season and import its match schedule.';

  @override
  String uiNextSeasonMatches(int count, String date) {
    return '$count matches · first match $date';
  }

  @override
  String get uiFindOnDbuMyself => 'Find it on DBU myself';

  @override
  String get matchSeasonPickerTitle => 'Choose season';

  @override
  String get matchSeasonActive => 'Active';

  @override
  String get matchSeasonPreviousSeasons => 'Previous seasons';

  @override
  String get matchSeasonFinished => 'Finished season';

  @override
  String matchSeasonViewingRange(String range) {
    return 'Showing matches from $range';
  }

  @override
  String get matchSeasonBackToCurrent => 'Back to current';

  @override
  String matchSeasonStartedOn(String date) {
    return 'Started $date';
  }

  @override
  String matchSeasonSelectorLabel(String name) {
    return 'Season $name. Change season';
  }

  @override
  String get matchSeasonClose => 'Close';

  @override
  String get matchSeasonNoMatches => 'No matches in this season.';

  @override
  String get matchSeasonSummaryMatches => 'Matches';

  @override
  String get matchSeasonSummaryWon => 'Won';

  @override
  String get matchSeasonSummaryDrawn => 'Drawn';

  @override
  String get matchSeasonSummaryLost => 'Lost';

  @override
  String get resultLetterWin => 'W';

  @override
  String get resultLetterDraw => 'D';

  @override
  String get resultLetterLoss => 'L';

  @override
  String get statisticsInFormTitle => 'In-form';

  @override
  String get statisticsAssists => 'Assists';

  @override
  String get statisticsFormTitle => 'Form';

  @override
  String statisticsFormHint(int count) {
    return 'Last $count · newest on the right';
  }

  @override
  String get statisticsNoFormYet => 'No matches played yet.';

  @override
  String get inFormCategoryOffensive => 'Offensive';

  @override
  String get inFormCategoryDefensive => 'Defensive';

  @override
  String get inFormCategoryTeamResult => 'Team result';

  @override
  String get inFormCategoryDiscipline => 'Discipline';

  @override
  String get inFormCategoryParticipation => 'Participation & honours';

  @override
  String get inFormCategoryBonus => 'Streaks & bonuses';

  @override
  String get inFormCategoryOffensiveDescription =>
      'Goals, assists and other attacking actions.';

  @override
  String get inFormCategoryDefensiveDescription =>
      'Clean sheets, goals conceded and penalty saves.';

  @override
  String get inFormCategoryTeamResultDescription =>
      'Points for how the team did as a whole.';

  @override
  String get inFormCategoryDisciplineDescription =>
      'Cards and other disciplinary incidents.';

  @override
  String get inFormCategoryParticipationDescription =>
      'Playing, man of the match votes and awards.';

  @override
  String get inFormCategoryBonusDescription =>
      'Extra points for streaks, form runs and monthly or season awards.';

  @override
  String get inFormColumnPlayer => 'Player';

  @override
  String get inFormColumnLatest => 'Latest';

  @override
  String get inFormColumnToFirst => 'To #1';

  @override
  String get inFormColumnTotal => 'Pts';

  @override
  String get inFormPointsSystem => 'Points system';

  @override
  String get inFormPointsSystemIntro =>
      'Your points depend on the position you played. Defenders earn more for clean sheets, attackers for goals and assists.';

  @override
  String get inFormPointsSystemExtras =>
      'On top of this come streaks and form bonuses, plus monthly and season awards.';

  @override
  String get inFormMatches => 'Matches';

  @override
  String get inFormGoals => 'Goals';

  @override
  String get inFormAssists => 'Assists';

  @override
  String get inFormCards => 'Cards';

  @override
  String get inFormMotm => 'MOTM';

  @override
  String get inFormAverage => 'Avg.';

  @override
  String get inFormBonuses => 'Bonuses';

  @override
  String get inFormHome => 'Home';

  @override
  String get inFormAway => 'Away';

  @override
  String get inFormUnknownOpponent => 'Unknown opponent';

  @override
  String inFormPlayedAs(String position) {
    return 'Played as $position';
  }

  @override
  String get inFormPositionChanged => 'changed for this match';

  @override
  String get inFormEditMatch => 'Edit match data';

  @override
  String get inFormChangePosition => 'Change position';

  @override
  String get inFormMatchPosition => 'Position in this match';

  @override
  String get inFormMatchPositionHint =>
      'Played a different position than usual? Pick it here so your points match.';

  @override
  String get inFormUseProfilePosition => 'Normal position';

  @override
  String get inFormMatchDataPoints => 'Data points';

  @override
  String get inFormMatchDataPointsHint =>
      'Things the match timeline can\'t show. The decisive goal is worked out automatically, so only change it if it\'s wrong.';

  @override
  String get inFormOwnGoals => 'Own goals';

  @override
  String get inFormPenaltiesMissed => 'Missed penalties';

  @override
  String get inFormPenaltiesSaved => 'Saved penalties';

  @override
  String get inFormDecisiveGoals => 'Decisive goals';

  @override
  String get inFormSave => 'Save';

  @override
  String get inFormSaveFailed => 'Could not save. Please try again.';

  @override
  String get inFormSaved => 'Saved – points updated';

  @override
  String get inFormSeeHowPointsWork => 'How points work';

  @override
  String get inFormPointsSystemLoadFailed =>
      'Could not fetch the points system.';

  @override
  String get seasonOverEyebrow => 'Season over';

  @override
  String get seasonOverTitle => 'Good game, everyone!';

  @override
  String get seasonEmptyEyebrow => 'No matches yet';

  @override
  String get seasonEmptyTitle => 'Ready for kick-off';

  @override
  String get seasonRecapTitle => 'The season in numbers';

  @override
  String get seasonRecapMatches => 'Matches';

  @override
  String get seasonRecapRecord => 'W-D-L';

  @override
  String get seasonRecapGoals => 'Goals';

  @override
  String get seasonChecking => 'Looking for the next season on DBU…';

  @override
  String get seasonWaitingTitle => 'Waiting for the next season';

  @override
  String get seasonWaitingBody =>
      'DBU hasn\'t published your next tournament yet. We check every day and let you know as soon as it\'s ready.';

  @override
  String seasonLastChecked(String time) {
    return 'Last checked $time';
  }

  @override
  String get seasonCheckAgain => 'Check again';

  @override
  String get seasonImportAnyway => 'I know it\'s there, import anyway';

  @override
  String get seasonReadyBadge => 'New season ready';

  @override
  String get seasonReadyTitle => 'Your next season is on DBU';

  @override
  String seasonReadyMatches(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches · first $date',
      one: '1 match · first $date',
      zero: 'First match $date',
    );
    return '$_temp0';
  }

  @override
  String get seasonStartNew => 'Start new season';

  @override
  String get seasonNotThisOne => 'Not the right one? Find it on DBU';

  @override
  String get seasonManualTitle => 'Ready for a new season?';

  @override
  String get seasonManualBody =>
      'Import the match schedule from DBU to start the next season.';

  @override
  String get wrappedMissingResultEyebrow => 'The season is almost over';

  @override
  String get wrappedMissingResultTitle => 'One result is missing';

  @override
  String get wrappedMissingResultBody =>
      'Enter the result of the last match, then we can wrap up your season.';

  @override
  String wrappedMissingResultMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more matches are missing a result',
      one: '1 more match is missing a result',
    );
    return '$_temp0';
  }

  @override
  String get wrappedEnterResult => 'Enter result';

  @override
  String get wrappedMissingResultPlayerHint =>
      'The team leader enters the result, then your Season Wrapped is ready.';

  @override
  String get wrappedTeaserEyebrow => 'Season Wrapped';

  @override
  String get wrappedTeaserTitle => 'Your season is wrapped';

  @override
  String get wrappedTeaserBody =>
      'Top scorer, man of the match and your own season.';

  @override
  String get wrappedTeaserCta => 'Watch your Wrapped';

  @override
  String get wrappedSkip => 'Skip – go to the next season';

  @override
  String get wrappedWatchAgain => 'Watch your Season Wrapped again';

  @override
  String wrappedProgress(int current, int total) {
    return 'Season Wrapped · $current/$total';
  }

  @override
  String get wrappedClose => 'Close';

  @override
  String get wrappedCustomize => 'Customize Wrapped';

  @override
  String get wrappedPrevious => 'Previous slide';

  @override
  String get wrappedNext => 'Next slide';

  @override
  String get wrappedIntroTitle => 'Your season,\nwrapped\nup.';

  @override
  String wrappedIntroBody(int matches, int goals) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches matches',
      one: '1 match',
    );
    return '$_temp0. $goals goals. One team. Let\'s look back.';
  }

  @override
  String get wrappedTapToContinue => 'Tap to continue →';

  @override
  String get wrappedTeamEyebrow => 'The team in numbers';

  @override
  String wrappedTeamWinsLabel(int played) {
    return 'wins\nin $played matches';
  }

  @override
  String wrappedTeamDrawsLosses(int draws, int losses) {
    return '$draws draws · $losses losses';
  }

  @override
  String get wrappedGoalsFor => 'goals scored';

  @override
  String get wrappedGoalsAgainst => 'goals conceded';

  @override
  String get wrappedLastFive => 'Last matches';

  @override
  String get wrappedFormWin => 'W';

  @override
  String get wrappedFormDraw => 'D';

  @override
  String get wrappedFormLoss => 'L';

  @override
  String wrappedBestStreak(int count) {
    return 'Best run: $count wins in a row.';
  }

  @override
  String wrappedYouEyebrow(String name) {
    return 'Your season, $name';
  }

  @override
  String get wrappedMatchesPlayed => 'matches played';

  @override
  String get wrappedGoals => 'goals';

  @override
  String get wrappedAssists => 'assists';

  @override
  String get wrappedTraining => 'training';

  @override
  String get wrappedYouTopAttendance => 'Nobody played more matches than you.';

  @override
  String wrappedYouMoreMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Only $count players played more matches than you.',
      one: 'Only one player played more matches than you.',
    );
    return '$_temp0';
  }

  @override
  String get wrappedFormEyebrow => 'Kopa form';

  @override
  String get wrappedFormYouFinished => 'You finished';

  @override
  String wrappedFormOfPlayers(int count) {
    return 'of $count\nplayers';
  }

  @override
  String wrappedFormWinner(String name) {
    return '$name won Kopa form';
  }

  @override
  String get wrappedYouSuffix => '(you)';

  @override
  String get wrappedGoalsEyebrow => 'Top scorer';

  @override
  String wrappedGoalsLine(int goals, int percent) {
    return '$goals goals · $percent% of the team\'s goals';
  }

  @override
  String get wrappedAssistsEyebrow => 'Assist king';

  @override
  String wrappedAssistsLine(int count) {
    return '$count assists for teammates';
  }

  @override
  String get wrappedDuoTitle => 'Duo of the season';

  @override
  String wrappedDuoGoals(int count) {
    return '$count goals together';
  }

  @override
  String get wrappedMotmEyebrow => 'Man of the match';

  @override
  String wrappedMotmLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'voted best $count times by the team',
      one: 'voted best once by the team',
    );
    return '$_temp0';
  }

  @override
  String wrappedSeasonMatches(int count) {
    return 'The season\'s $count matches';
  }

  @override
  String get wrappedIronEyebrow => 'Iron man';

  @override
  String get wrappedIronAll => 'Played every single match.';

  @override
  String get wrappedIronMost => 'Played the most matches.';

  @override
  String get wrappedFinesEyebrow => 'Fine king';

  @override
  String get wrappedFinesLine => 'into the fine box this season';

  @override
  String wrappedFinesTotal(String amount) {
    return 'The team collected $amount in total.';
  }

  @override
  String get wrappedCardsEyebrow => 'Card king';

  @override
  String wrappedCardsLine(int yellow, int red) {
    return '$yellow yellow · $red red';
  }

  @override
  String get wrappedCardsFooter => 'The referee\'s best friend.';

  @override
  String get wrappedLanternEyebrow => 'The red lantern';

  @override
  String wrappedLanternLine(int rank, int count) {
    return 'no. $rank of $count in Kopa form';
  }

  @override
  String get wrappedLanternFooter =>
      'Someone has to keep the lantern lit. Next season is a new chance.';

  @override
  String get wrappedOutroTitle => 'Awards of the season';

  @override
  String get wrappedOutroYou => 'Your season';

  @override
  String wrappedOutroYouLine(int goals, int assists) {
    return '$goals goals · $assists assists';
  }

  @override
  String get wrappedShare => 'Share your Wrapped';

  @override
  String get wrappedShareText => 'Our season in Kopa';

  @override
  String get wrappedContinue => 'On to the next season';

  @override
  String get wrappedSettingsTitle => 'What goes in the Wrapped?';

  @override
  String get wrappedSettingsBody =>
      'We found the categories your team has data for. Switch off the ones you don\'t want.';

  @override
  String get wrappedSettingsSave => 'Save';

  @override
  String get wrappedSettingsError => 'Couldn\'t save. Try again.';

  @override
  String get wrappedSettingsNoData => 'Not enough data this season';

  @override
  String wrappedDetailForm(int count) {
    return '$count players with Kopa form points';
  }

  @override
  String wrappedDetailGoals(int count) {
    return '$count goals recorded';
  }

  @override
  String wrappedDetailAssists(int count) {
    return '$count assists recorded';
  }

  @override
  String wrappedDetailMotm(int count) {
    return 'Votes in $count matches';
  }

  @override
  String wrappedDetailIron(int count) {
    return 'Most matches: $count';
  }

  @override
  String wrappedDetailFines(String amount) {
    return '$amount in fines';
  }

  @override
  String wrappedDetailCards(int count) {
    return '$count cards recorded';
  }

  @override
  String get wrappedDetailLantern => 'Fun award · last in Kopa form';

  @override
  String get fineBoxMarkPaid => 'Mark as paid';

  @override
  String fineBoxMarkPaidBody(String fine, String name) {
    return 'Mark $fine for $name as paid? The amount goes into the fine box.';
  }

  @override
  String fineBoxMarkAllPaid(String amount) {
    return 'Mark all as paid ($amount)';
  }

  @override
  String fineBoxMarkAllPaidBody(String name, String amount) {
    return 'Mark all of $name\'s unpaid fines ($amount) as paid? The amount goes into the fine box.';
  }

  @override
  String get fineBoxMarkPaidFailed =>
      'The fine could not be marked as paid. Try again.';

  @override
  String get homeNextTraining => 'Next training';

  @override
  String get wrappedAssistsLeaders => 'Most assists';

  @override
  String get settingsSectionMatches => 'Matches';

  @override
  String get settingsSectionSeason => 'Season & DBU';

  @override
  String get settingsSectionTeam => 'Team';

  @override
  String get settingsSectionMe => 'Me';

  @override
  String get settingsInvitePlayers => 'Invite players';

  @override
  String settingsPendingBannerTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players are waiting',
      one: '1 player is waiting',
    );
    return '$_temp0';
  }

  @override
  String get settingsPendingBannerBody =>
      'Approve them so they can sign up for matches.';

  @override
  String get settingsJoinRequestsNone => 'No one is waiting right now';

  @override
  String settingsJoinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count waiting for approval',
      one: '1 waiting for approval',
    );
    return '$_temp0';
  }

  @override
  String get settingsTeamLogoTitle => 'Team logo';

  @override
  String get settingsTeamLogoSubtitle => 'Shape, colour and initials';

  @override
  String get settingsMatchDayTitle => 'Signup & match day';

  @override
  String get settingsMatchDayIntro => 'How matches work for the whole team.';

  @override
  String get settingsSignupQuestion => 'Who makes the squad?';

  @override
  String get settingsRsvpFirstComeDescription =>
      'Players who sign up are included automatically.';

  @override
  String get settingsRsvpLeaderDescription =>
      'Players sign up as available, and the team leader picks the squad from them.';

  @override
  String get settingsMeetingTimeSection => 'Meeting time';

  @override
  String get settingsMeetingTimeLabel => 'Meet before kickoff';

  @override
  String get settingsMeetingNone => 'None';

  @override
  String settingsMeetingMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String settingsMeetingPreview(String kickoff, String meeting) {
    return 'Kickoff $kickoff → meet at $meeting';
  }

  @override
  String get settingsMeetingPreviewNone =>
      'No default. You set the meeting time on each match.';

  @override
  String settingsMeetingSummary(int minutes) {
    return 'Meet $minutes min before';
  }

  @override
  String get settingsTasksSection => 'Match day tasks';

  @override
  String get settingsTasksSubtitle =>
      'Recurring tasks that rotate between players';

  @override
  String get settingsAutosaveHint => 'Changes are saved automatically';

  @override
  String get settingsSaving => 'Saving...';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsSaveFailed => 'Could not save. Try again.';

  @override
  String get settingsSeasonSubtitle => 'Match schedule and standings from DBU';

  @override
  String get settingsSeasonIntro =>
      'Fetch your team\'s matches and the pool standings from DBU.';

  @override
  String get settingsSeasonScheduleTitle => 'Match schedule';

  @override
  String get settingsSeasonScheduleBody =>
      'Import matches or start a new season.';

  @override
  String get settingsSeasonImportAction => 'Import';

  @override
  String get settingsSeasonStandingsTitle => 'Standings';

  @override
  String get settingsSeasonStandingsBody =>
      'Update the standings and teams in your pool.';

  @override
  String get settingsSeasonSyncAction => 'Sync';

  @override
  String get settingsSeasonDbuHint =>
      'You log in through DBU Kampklar, and Kopa fetches your team\'s data.';

  @override
  String get settingsSignupLimitSection => 'Squad spots';

  @override
  String get settingsSignupLimitToggle => 'Limit signups';

  @override
  String get settingsSignupLimitLabel => 'Spots per match';

  @override
  String settingsSignupLimitHelpOn(int count) {
    return 'When $count have signed up, the rest go on a waitlist and move up automatically if someone drops out.';
  }

  @override
  String get settingsSignupLimitHelpOff => 'Everyone who signs up is included.';

  @override
  String get settingsSignupLimitDecrease => 'Fewer spots';

  @override
  String get settingsSignupLimitIncrease => 'More spots';

  @override
  String settingsSignupLimitSummary(int count) {
    return 'max $count';
  }

  @override
  String matchWaitlistPosition(int position) {
    return 'Waitlist #$position';
  }

  @override
  String get settingsSeasonCurrentLabel => 'Current season';

  @override
  String get settingsSeasonNone => 'No active season';

  @override
  String settingsSeasonPoolTeams(int count) {
    return '$count teams';
  }

  @override
  String get settingsSeasonStatMatches => 'matches';

  @override
  String get settingsSeasonStatPlayed => 'played';

  @override
  String get settingsSeasonStatPosition => 'place';

  @override
  String settingsSeasonPositionValue(int position) {
    return '#$position';
  }

  @override
  String get settingsSeasonFetchSection => 'Fetch from DBU';

  @override
  String settingsSeasonScheduleMeta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches this season',
      one: '1 match this season',
    );
    return '$_temp0';
  }

  @override
  String get settingsSeasonScheduleEmpty => 'Not imported yet';

  @override
  String settingsSeasonStandingsUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get settingsSeasonStandingsNever => 'Not fetched yet';

  @override
  String get settingsSeasonChangeSection => 'Season change';

  @override
  String get settingsSeasonNextTitle => 'Start next season';

  @override
  String settingsSeasonNextReady(String label, int count) {
    return '$label is ready on DBU with $count matches.';
  }

  @override
  String get settingsSeasonNextWaiting =>
      'DBU has not published the next season yet. You can still start it manually.';

  @override
  String get settingsSeasonNextUnknown =>
      'Import the new season\'s match schedule once DBU has published it.';

  @override
  String get settingsSeasonNextButton => 'Start new season';

  @override
  String settingsSeasonNextReadyButton(String label) {
    return 'Start $label';
  }

  @override
  String get settingsSeasonOtherSources => 'Other sources';

  @override
  String get settingsSeasonCreateMatch => 'Create match manually';

  @override
  String get settingsSeasonCreateMatchSubtitle => 'Friendlies and cup matches';
}
