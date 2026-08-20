// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
}
