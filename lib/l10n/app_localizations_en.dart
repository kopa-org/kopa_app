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
  String get matchTimelineKickoff => 'Kick-off';

  @override
  String get matchTimelineHalftime => 'Half-time';

  @override
  String get matchTimelineFullTime => 'Full time';

  @override
  String get matchRegisterResult => 'Register match result';

  @override
  String get matchEnterResult => 'Enter';

  @override
  String get matchScoreDialogTitle => 'Enter result';

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
