import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('en')
  ];

  /// No description provided for @homeAttendanceGoing.
  ///
  /// In en, this message translates to:
  /// **'You\'re going'**
  String get homeAttendanceGoing;

  /// No description provided for @homeAttendanceDeclined.
  ///
  /// In en, this message translates to:
  /// **'Not going'**
  String get homeAttendanceDeclined;

  /// No description provided for @homeAttendanceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you coming?'**
  String get homeAttendanceQuestion;

  /// No description provided for @homeAttendanceYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m coming'**
  String get homeAttendanceYes;

  /// No description provided for @homeAttendanceNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get homeAttendanceNo;

  /// No description provided for @homeAttendanceSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get homeAttendanceSaving;

  /// No description provided for @homeAttendanceChange.
  ///
  /// In en, this message translates to:
  /// **'Change your response'**
  String get homeAttendanceChange;

  /// No description provided for @matchDetailsDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get matchDetailsDecisionTitle;

  /// No description provided for @matchDetailsDecisionPending.
  ///
  /// In en, this message translates to:
  /// **'You are signed up, but your selection is still pending.'**
  String get matchDetailsDecisionPending;

  /// No description provided for @matchDetailsRsvpDecline.
  ///
  /// In en, this message translates to:
  /// **'No, I can\'t'**
  String get matchDetailsRsvpDecline;

  /// No description provided for @matchDetailsRsvpAccept.
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m coming'**
  String get matchDetailsRsvpAccept;

  /// No description provided for @matchDetailsRsvpRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get matchDetailsRsvpRegistered;

  /// No description provided for @matchDetailsRsvpDeclineAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel attendance'**
  String get matchDetailsRsvpDeclineAction;

  /// No description provided for @matchDetailsRsvpDeclined.
  ///
  /// In en, this message translates to:
  /// **'Not registered'**
  String get matchDetailsRsvpDeclined;

  /// No description provided for @matchDetailsRsvpPendingSelection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the team leader\'s selection'**
  String get matchDetailsRsvpPendingSelection;

  /// No description provided for @teamRsvpSelectionModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Signup method'**
  String get teamRsvpSelectionModeLabel;

  /// No description provided for @teamRsvpSelectionModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose whether players are automatically included or the team leader selects from the players who sign up.'**
  String get teamRsvpSelectionModeDescription;

  /// No description provided for @teamRsvpFirstComeOption.
  ///
  /// In en, this message translates to:
  /// **'First come, first served'**
  String get teamRsvpFirstComeOption;

  /// No description provided for @teamRsvpLeaderOption.
  ///
  /// In en, this message translates to:
  /// **'Team leader selects'**
  String get teamRsvpLeaderOption;

  /// No description provided for @teamRsvpSelectionSave.
  ///
  /// In en, this message translates to:
  /// **'Save signup method'**
  String get teamRsvpSelectionSave;

  /// No description provided for @teamRsvpSelectionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving signup method...'**
  String get teamRsvpSelectionSaving;

  /// No description provided for @teamRsvpSelectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Signup method saved.'**
  String get teamRsvpSelectionSaved;

  /// No description provided for @teamSettingsOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only a team owner or admin can change team settings.'**
  String get teamSettingsOwnerOnly;

  /// No description provided for @matchScoreHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get matchScoreHome;

  /// No description provided for @matchScoreAway.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get matchScoreAway;

  /// No description provided for @matchScoreHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the final score for each team.'**
  String get matchScoreHelp;

  /// No description provided for @matchScoreSave.
  ///
  /// In en, this message translates to:
  /// **'Save result'**
  String get matchScoreSave;

  /// No description provided for @matchScoreSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the result. Please try again.'**
  String get matchScoreSaveFailed;

  /// No description provided for @commonGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get commonGoTo;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Kopa'**
  String get onboardingTitle;

  /// No description provided for @onboardingCreateTeam.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get onboardingCreateTeam;

  /// No description provided for @onboardingJoinTeam.
  ///
  /// In en, this message translates to:
  /// **'Join team'**
  String get onboardingJoinTeam;

  /// No description provided for @onboardingTeamName.
  ///
  /// In en, this message translates to:
  /// **'Team name'**
  String get onboardingTeamName;

  /// No description provided for @onboardingManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get onboardingManual;

  /// No description provided for @onboardingDbu.
  ///
  /// In en, this message translates to:
  /// **'DBU'**
  String get onboardingDbu;

  /// No description provided for @onboardingDbuRecommendation.
  ///
  /// In en, this message translates to:
  /// **'It is recommended to sync with DBU for the best app experience'**
  String get onboardingDbuRecommendation;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get onboardingCreate;

  /// No description provided for @onboardingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a team'**
  String get onboardingSearchHint;

  /// No description provided for @onboardingRequestJoin.
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get onboardingRequestJoin;

  /// No description provided for @onboardingWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get onboardingWaitingTitle;

  /// No description provided for @onboardingWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to the team admins.'**
  String get onboardingWaitingBody;

  /// No description provided for @onboardingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get onboardingCancel;

  /// No description provided for @onboardingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get onboardingPlayers;

  /// No description provided for @onboardingMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get onboardingMatches;

  /// No description provided for @onboardingNoResults.
  ///
  /// In en, this message translates to:
  /// **'No teams found'**
  String get onboardingNoResults;

  /// No description provided for @onboardingFailure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get onboardingFailure;

  /// No description provided for @matchEventChooseEvent.
  ///
  /// In en, this message translates to:
  /// **'Choose event'**
  String get matchEventChooseEvent;

  /// No description provided for @matchDetailsMatchEvents.
  ///
  /// In en, this message translates to:
  /// **'Match events'**
  String get matchDetailsMatchEvents;

  /// No description provided for @matchDetailsMatchEventsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Match events will become available once the match result has been entered.'**
  String get matchDetailsMatchEventsUnavailable;

  /// No description provided for @externalPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add external player'**
  String get externalPlayerTitle;

  /// No description provided for @externalPlayerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get externalPlayerNameHint;

  /// No description provided for @externalPlayerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get externalPlayerAdd;

  /// No description provided for @externalPlayerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get externalPlayerCancel;

  /// No description provided for @externalPlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'External players'**
  String get externalPlayerLabel;

  /// No description provided for @externalPlayerCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create external player'**
  String get externalPlayerCreateButton;

  /// No description provided for @externalPlayerSubstitute.
  ///
  /// In en, this message translates to:
  /// **'External player · On the bench'**
  String get externalPlayerSubstitute;

  /// No description provided for @externalPlayerAddFailed.
  ///
  /// In en, this message translates to:
  /// **'The external player could not be added. Please try again.'**
  String get externalPlayerAddFailed;

  /// No description provided for @matchDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete match'**
  String get matchDelete;

  /// No description provided for @matchEventDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get matchEventDelete;

  /// No description provided for @externalPlayerDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete external player'**
  String get externalPlayerDelete;

  /// No description provided for @matchDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get matchDeleteConfirmation;

  /// No description provided for @matchDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Please try again.'**
  String get matchDeleteFailed;

  /// No description provided for @externalPlayerDeleteInUse.
  ///
  /// In en, this message translates to:
  /// **'This player is used in match events or MOTM. Remove those first.'**
  String get externalPlayerDeleteInUse;

  /// No description provided for @matchPollLoadPlayersFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load players for the poll. Please try again.'**
  String get matchPollLoadPlayersFailed;

  /// No description provided for @matchPollUnknownPlayer.
  ///
  /// In en, this message translates to:
  /// **'Unknown player'**
  String get matchPollUnknownPlayer;

  /// No description provided for @matchTimelineKickoff.
  ///
  /// In en, this message translates to:
  /// **'Kick-off'**
  String get matchTimelineKickoff;

  /// No description provided for @matchTimelineHalftime.
  ///
  /// In en, this message translates to:
  /// **'Half-time'**
  String get matchTimelineHalftime;

  /// No description provided for @matchTimelineFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full time'**
  String get matchTimelineFullTime;

  /// No description provided for @matchTimelineGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get matchTimelineGoal;

  /// No description provided for @matchTimelineSubstitution.
  ///
  /// In en, this message translates to:
  /// **'Substitution'**
  String get matchTimelineSubstitution;

  /// No description provided for @matchRegisterResult.
  ///
  /// In en, this message translates to:
  /// **'Register match result'**
  String get matchRegisterResult;

  /// No description provided for @matchEnterResult.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get matchEnterResult;

  /// No description provided for @matchScoreDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter result'**
  String get matchScoreDialogTitle;

  /// No description provided for @matchResultReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Type match result'**
  String get matchResultReminderTitle;

  /// No description provided for @matchResultReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'It has been 30 minutes since kick-off. Enter the final result so the match is marked as played.'**
  String get matchResultReminderMessage;

  /// No description provided for @matchResultReminderAction.
  ///
  /// In en, this message translates to:
  /// **'Type match result'**
  String get matchResultReminderAction;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @maintenanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Kopa is under maintenance and will be back soon.'**
  String get maintenanceMessage;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @lineupVisibilityRevealMessage.
  ///
  /// In en, this message translates to:
  /// **'The team will be notified and able to see the lineup.'**
  String get lineupVisibilityRevealMessage;

  /// No description provided for @lineupVisibilityRevealConfirm.
  ///
  /// In en, this message translates to:
  /// **'OK, understood'**
  String get lineupVisibilityRevealConfirm;

  /// No description provided for @lineupVisibilityRevealCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get lineupVisibilityRevealCancel;

  /// No description provided for @lineupUnsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'You forgot to save the lineup'**
  String get lineupUnsavedChangesTitle;

  /// No description provided for @lineupUnsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you like to save your changes before leaving?'**
  String get lineupUnsavedChangesMessage;

  /// No description provided for @lineupUnsavedChangesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get lineupUnsavedChangesSave;

  /// No description provided for @lineupUnsavedChangesDiscard.
  ///
  /// In en, this message translates to:
  /// **'Don\'t save'**
  String get lineupUnsavedChangesDiscard;

  /// No description provided for @fineTypeDeleteIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete fine type'**
  String get fineTypeDeleteIconLabel;

  /// No description provided for @fineTypeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete fine type?'**
  String get fineTypeDeleteTitle;

  /// No description provided for @fineTypeDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {title} from the fine catalog?'**
  String fineTypeDeleteMessage(String title);

  /// No description provided for @fineTypeDeleteFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not delete fine type'**
  String get fineTypeDeleteFailureTitle;

  /// No description provided for @fineTypeDeleteInUseMessage.
  ///
  /// In en, this message translates to:
  /// **'This fine type is already used by existing fines.'**
  String get fineTypeDeleteInUseMessage;

  /// No description provided for @fineTypeDeleteFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get fineTypeDeleteFailureMessage;

  /// No description provided for @teamLogoEditButton.
  ///
  /// In en, this message translates to:
  /// **'Change team logo'**
  String get teamLogoEditButton;

  /// No description provided for @teamLogoEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Change team logo'**
  String get teamLogoEditTitle;

  /// No description provided for @teamLogoDesignTitle.
  ///
  /// In en, this message translates to:
  /// **'Design your team logo'**
  String get teamLogoDesignTitle;

  /// No description provided for @teamLogoDesignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a background color and shape for your team logo'**
  String get teamLogoDesignSubtitle;

  /// No description provided for @teamLogoBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get teamLogoBackgroundColor;

  /// No description provided for @teamLogoShape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get teamLogoShape;

  /// No description provided for @teamLogoPattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get teamLogoPattern;

  /// No description provided for @teamLogoSave.
  ///
  /// In en, this message translates to:
  /// **'Save logo'**
  String get teamLogoSave;

  /// No description provided for @teamLogoSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving logo...'**
  String get teamLogoSaving;

  /// No description provided for @teamLogoSaveFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not save the team logo.'**
  String get teamLogoSaveFailure;

  /// No description provided for @matchPollTitle.
  ///
  /// In en, this message translates to:
  /// **'Player of the match'**
  String get matchPollTitle;

  /// No description provided for @matchPollInstruction.
  ///
  /// In en, this message translates to:
  /// **'Distribute votes with + and -'**
  String get matchPollInstruction;

  /// No description provided for @matchPollTotalVotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Total: 1 vote} other {Total: {count} votes}}'**
  String matchPollTotalVotes(int count);

  /// No description provided for @matchPollVoteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 vote} other {{count} votes}}'**
  String matchPollVoteCount(int count);

  /// No description provided for @matchPollEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit poll'**
  String get matchPollEdit;

  /// No description provided for @matchPollCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add poll'**
  String get matchPollCreateTitle;

  /// No description provided for @matchPollEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit poll'**
  String get matchPollEditTitle;

  /// No description provided for @matchPollCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create poll'**
  String get matchPollCreateAction;

  /// No description provided for @matchPollSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get matchPollSaveAction;

  /// No description provided for @matchPollCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get matchPollCreating;

  /// No description provided for @matchPollSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get matchPollSaving;

  /// No description provided for @matchPollErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get matchPollErrorTitle;

  /// No description provided for @eventCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get eventCreateTitle;

  /// No description provided for @eventCreateMatch.
  ///
  /// In en, this message translates to:
  /// **'Create match'**
  String get eventCreateMatch;

  /// No description provided for @eventCreateTraining.
  ///
  /// In en, this message translates to:
  /// **'Create training'**
  String get eventCreateTraining;

  /// No description provided for @eventTypeMatch.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get eventTypeMatch;

  /// No description provided for @eventTypeTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get eventTypeTraining;

  /// No description provided for @eventTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get eventTraining;

  /// No description provided for @eventTrainingCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get eventTrainingCategory;

  /// No description provided for @eventTrainingCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. passing, drills or defence'**
  String get eventTrainingCategoryHint;

  /// No description provided for @eventCreateChoose.
  ///
  /// In en, this message translates to:
  /// **'What do you want to create?'**
  String get eventCreateChoose;

  /// No description provided for @eventOpenMatch.
  ///
  /// In en, this message translates to:
  /// **'Open match'**
  String get eventOpenMatch;

  /// No description provided for @eventOpenTraining.
  ///
  /// In en, this message translates to:
  /// **'Open training'**
  String get eventOpenTraining;

  /// No description provided for @eventDetailsMatch.
  ///
  /// In en, this message translates to:
  /// **'Match details'**
  String get eventDetailsMatch;

  /// No description provided for @eventDetailsTraining.
  ///
  /// In en, this message translates to:
  /// **'Training details'**
  String get eventDetailsTraining;

  /// No description provided for @eventTrainingTime.
  ///
  /// In en, this message translates to:
  /// **'Training time'**
  String get eventTrainingTime;

  /// No description provided for @eventCreateTrainingLocationHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. training pitch'**
  String get eventCreateTrainingLocationHint;

  /// No description provided for @eventCreateTrainingMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Enter a location and choose a date and time.'**
  String get eventCreateTrainingMissingFields;

  /// No description provided for @eventCreateTrainingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the training.'**
  String get eventCreateTrainingFailed;

  /// No description provided for @eventCreateMatchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the match.'**
  String get eventCreateMatchFailed;

  /// No description provided for @eventCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'The event could not be created.'**
  String get eventCreateFailed;

  /// No description provided for @eventRsvpFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your attendance. Please try again.'**
  String get eventRsvpFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
