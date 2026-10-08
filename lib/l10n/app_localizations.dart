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

  /// No description provided for @onboardingPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get onboardingPlayer;

  /// No description provided for @onboardingTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Team leader'**
  String get onboardingTeamLeader;

  /// No description provided for @onboardingRoleChoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your role on the team.'**
  String get onboardingRoleChoiceDescription;

  /// No description provided for @onboardingRoleChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your role?'**
  String get onboardingRoleChoiceTitle;

  /// No description provided for @onboardingTeamChoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a new team or find your existing team on Kopa.'**
  String get onboardingTeamChoiceDescription;

  /// No description provided for @onboardingTeamChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Create or join a team'**
  String get onboardingTeamChoiceTitle;

  /// No description provided for @matchDetailsLineupTab.
  ///
  /// In en, this message translates to:
  /// **'Lineup'**
  String get matchDetailsLineupTab;

  /// No description provided for @matchFabMotmLabel.
  ///
  /// In en, this message translates to:
  /// **'MOTM'**
  String get matchFabMotmLabel;

  /// No description provided for @matchFabResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get matchFabResultLabel;

  /// No description provided for @matchFabExternalPlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Ext Player'**
  String get matchFabExternalPlayerLabel;

  /// No description provided for @matchLineupWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for lineup'**
  String get matchLineupWaiting;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we’ll send you a code to reset your password.'**
  String get forgotPasswordInstructions;

  /// No description provided for @forgotPasswordCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to your email.'**
  String get forgotPasswordCodeInstructions;

  /// No description provided for @forgotPasswordEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmail;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get forgotPasswordEmailInvalid;

  /// No description provided for @forgotPasswordCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get forgotPasswordCode;

  /// No description provided for @forgotPasswordCodeLength.
  ///
  /// In en, this message translates to:
  /// **'The code must contain 6 digits.'**
  String get forgotPasswordCodeLength;

  /// No description provided for @forgotPasswordResend.
  ///
  /// In en, this message translates to:
  /// **'Send the code again'**
  String get forgotPasswordResend;

  /// No description provided for @forgotPasswordVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get forgotPasswordVerify;

  /// No description provided for @forgotPasswordSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotPasswordSendCode;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'If the account exists, we’ve sent a code. Check your inbox.'**
  String get resetCodeSent;

  /// No description provided for @resetRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t send the code right now. Please try again.'**
  String get resetRequestFailed;

  /// No description provided for @resetCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'The code is invalid or has expired. Please try again.'**
  String get resetCodeInvalid;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetPasswordNewPassword;

  /// No description provided for @resetPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get resetPasswordConfirm;

  /// No description provided for @resetPasswordMinimumLength.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters.'**
  String get resetPasswordMinimumLength;

  /// No description provided for @resetPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get resetPasswordMismatch;

  /// No description provided for @resetPasswordSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get resetPasswordSave;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t change the password. The code may have expired. Please try again.'**
  String get resetPasswordFailed;

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

  /// No description provided for @homeMatchCountdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Match in:'**
  String get homeMatchCountdownLabel;

  /// No description provided for @homeTrainingCountdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Training in:'**
  String get homeTrainingCountdownLabel;

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
  /// **'Create Team'**
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

  /// No description provided for @matchEventReorderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Drag to change the order'**
  String get matchEventReorderTooltip;

  /// No description provided for @matchEventReorderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the event order. Please try again.'**
  String get matchEventReorderFailed;

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

  /// No description provided for @eventEditTraining.
  ///
  /// In en, this message translates to:
  /// **'Edit training'**
  String get eventEditTraining;

  /// No description provided for @eventEditTrainingAction.
  ///
  /// In en, this message translates to:
  /// **'Edit training'**
  String get eventEditTrainingAction;

  /// No description provided for @eventDeleteTraining.
  ///
  /// In en, this message translates to:
  /// **'Delete training'**
  String get eventDeleteTraining;

  /// No description provided for @eventSaveTraining.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get eventSaveTraining;

  /// No description provided for @eventCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get eventCreateAction;

  /// No description provided for @eventSelectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Choose date and time'**
  String get eventSelectDateTime;

  /// No description provided for @eventRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeat weekly'**
  String get eventRepeatWeekly;

  /// No description provided for @eventRepeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Choose weekdays and times'**
  String get eventRepeatWeekdays;

  /// No description provided for @eventRepeatUntil.
  ///
  /// In en, this message translates to:
  /// **'Repeat until'**
  String get eventRepeatUntil;

  /// No description provided for @eventRepeatUntilHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an end date'**
  String get eventRepeatUntilHint;

  /// No description provided for @eventRepeatMissingWeekday.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one weekday for the repetition.'**
  String get eventRepeatMissingWeekday;

  /// No description provided for @eventRepeatMissingEndDate.
  ///
  /// In en, this message translates to:
  /// **'Choose when the repetition should stop.'**
  String get eventRepeatMissingEndDate;

  /// No description provided for @eventRepeatEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end date must be on or after the start date.'**
  String get eventRepeatEndBeforeStart;

  /// No description provided for @eventRepeatTooMany.
  ///
  /// In en, this message translates to:
  /// **'This creates too many trainings. Choose an earlier end date.'**
  String get eventRepeatTooMany;

  /// No description provided for @eventUpdateTrainingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the training changes.'**
  String get eventUpdateTrainingFailed;

  /// No description provided for @eventWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get eventWeekdayMonday;

  /// No description provided for @eventWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get eventWeekdayTuesday;

  /// No description provided for @eventWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get eventWeekdayWednesday;

  /// No description provided for @eventWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get eventWeekdayThursday;

  /// No description provided for @eventWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get eventWeekdayFriday;

  /// No description provided for @eventWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get eventWeekdaySaturday;

  /// No description provided for @eventWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get eventWeekdaySunday;

  /// No description provided for @matchPollNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants are registered for this match. Update attendance to create a poll.'**
  String get matchPollNoParticipants;

  /// No description provided for @matchEventPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get matchEventPlayer;

  /// No description provided for @matchEventScorer.
  ///
  /// In en, this message translates to:
  /// **'Goalscorer'**
  String get matchEventScorer;

  /// No description provided for @matchEventPlayerIn.
  ///
  /// In en, this message translates to:
  /// **'Player on'**
  String get matchEventPlayerIn;

  /// No description provided for @matchEventPlayerOut.
  ///
  /// In en, this message translates to:
  /// **'Player off'**
  String get matchEventPlayerOut;

  /// No description provided for @matchEventShooter.
  ///
  /// In en, this message translates to:
  /// **'Taker'**
  String get matchEventShooter;

  /// No description provided for @matchEventAssist.
  ///
  /// In en, this message translates to:
  /// **'Assist (optional)'**
  String get matchEventAssist;

  /// No description provided for @matchEventChooseMinute.
  ///
  /// In en, this message translates to:
  /// **'Choose minute (optional)'**
  String get matchEventChooseMinute;

  /// No description provided for @matchEventAddMinute.
  ///
  /// In en, this message translates to:
  /// **'Add minute (optional)'**
  String get matchEventAddMinute;

  /// No description provided for @matchEventChangeMinute.
  ///
  /// In en, this message translates to:
  /// **'Change minute'**
  String get matchEventChangeMinute;

  /// No description provided for @matchEventWithoutMinute.
  ///
  /// In en, this message translates to:
  /// **'Without minute'**
  String get matchEventWithoutMinute;

  /// No description provided for @matchEventUseMinute.
  ///
  /// In en, this message translates to:
  /// **'Use minute'**
  String get matchEventUseMinute;

  /// No description provided for @matchEventYellowCard.
  ///
  /// In en, this message translates to:
  /// **'Yellow card'**
  String get matchEventYellowCard;

  /// No description provided for @matchEventRedCard.
  ///
  /// In en, this message translates to:
  /// **'Red card'**
  String get matchEventRedCard;

  /// No description provided for @matchEventPenalty.
  ///
  /// In en, this message translates to:
  /// **'Penalty kick'**
  String get matchEventPenalty;

  /// No description provided for @matchEventSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the events. Please try again.'**
  String get matchEventSaveFailed;

  /// No description provided for @matchEventAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get matchEventAddMore;

  /// No description provided for @matchEventSaveAndClose.
  ///
  /// In en, this message translates to:
  /// **'Save and close'**
  String get matchEventSaveAndClose;

  /// No description provided for @matchEventTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Match events'**
  String get matchEventTimelineTitle;

  /// No description provided for @matchEventEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get matchEventEmptyTitle;

  /// No description provided for @matchEventEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add goals, cards and substitutions. The minute is optional.'**
  String get matchEventEmptyDescription;

  /// No description provided for @matchEventAddAction.
  ///
  /// In en, this message translates to:
  /// **'+ Add event'**
  String get matchEventAddAction;

  /// No description provided for @matchEventAssistedBy.
  ///
  /// In en, this message translates to:
  /// **'Assisted by {playerName}'**
  String matchEventAssistedBy(String playerName);

  /// No description provided for @matchEventPlayerOff.
  ///
  /// In en, this message translates to:
  /// **'Off: {playerName}'**
  String matchEventPlayerOff(String playerName);

  /// No description provided for @mobilePayBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'MobilePay Box'**
  String get mobilePayBoxTitle;

  /// No description provided for @mobilePayBoxMissing.
  ///
  /// In en, this message translates to:
  /// **'MobilePay Box missing'**
  String get mobilePayBoxMissing;

  /// No description provided for @mobilePayBoxInstructions.
  ///
  /// In en, this message translates to:
  /// **'Paste the payment link from Share in your MobilePay Box. The short Box code cannot open a payment link.'**
  String get mobilePayBoxInstructions;

  /// No description provided for @mobilePayBoxOwnerRequired.
  ///
  /// In en, this message translates to:
  /// **'The team owner must add the MobilePay Box payment link first.'**
  String get mobilePayBoxOwnerRequired;

  /// No description provided for @mobilePayBoxEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit MobilePay Box link'**
  String get mobilePayBoxEdit;

  /// No description provided for @mobilePayBoxAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Box link'**
  String get mobilePayBoxAdd;

  /// No description provided for @mobilePayBoxInvalid.
  ///
  /// In en, this message translates to:
  /// **'Paste the full MobilePay Box payment link. A short code such as 5289PN is not enough.'**
  String get mobilePayBoxInvalid;

  /// No description provided for @mobilePayBoxSave.
  ///
  /// In en, this message translates to:
  /// **'Save MobilePay Box'**
  String get mobilePayBoxSave;

  /// No description provided for @mobilePayBoxSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save MobilePay Box. Try again.'**
  String get mobilePayBoxSaveFailed;

  /// No description provided for @mobilePayOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open MobilePay. Check that the app is installed and try again.'**
  String get mobilePayOpenFailed;

  /// No description provided for @mobilePayBoxLinkRequired.
  ///
  /// In en, this message translates to:
  /// **'This Box has a short code instead of a payment link. Ask the team owner to edit the Box and paste its shared payment link.'**
  String get mobilePayBoxLinkRequired;

  /// No description provided for @mobilePayDeposit.
  ///
  /// In en, this message translates to:
  /// **'Pay with MobilePay'**
  String get mobilePayDeposit;

  /// No description provided for @mobilePayGoToBox.
  ///
  /// In en, this message translates to:
  /// **'Go to MobilePay Box'**
  String get mobilePayGoToBox;

  /// No description provided for @mobilePayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} kr. with MobilePay'**
  String mobilePayAmount(int amount);

  /// No description provided for @matchRsvpQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you coming?'**
  String get matchRsvpQuestion;

  /// No description provided for @matchRsvpHint.
  ///
  /// In en, this message translates to:
  /// **'Let your team know.'**
  String get matchRsvpHint;

  /// No description provided for @matchRsvpAwaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Awaiting response'**
  String get matchRsvpAwaitingResponse;

  /// No description provided for @matchRsvpConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You are registered for the match'**
  String get matchRsvpConfirmed;

  /// No description provided for @matchRsvpTrainingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You are registered for training'**
  String get matchRsvpTrainingConfirmed;

  /// No description provided for @matchRsvpDeclinedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have declined'**
  String get matchRsvpDeclinedMessage;

  /// No description provided for @matchRsvpCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel attendance'**
  String get matchRsvpCancel;

  /// No description provided for @matchRsvpAttendeeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} registered'**
  String matchRsvpAttendeeCount(int count);

  /// No description provided for @matchActionsMore.
  ///
  /// In en, this message translates to:
  /// **'Match options'**
  String get matchActionsMore;

  /// No description provided for @matchActionsEditResult.
  ///
  /// In en, this message translates to:
  /// **'Edit match result'**
  String get matchActionsEditResult;

  /// No description provided for @matchFabCreateMotmPoll.
  ///
  /// In en, this message translates to:
  /// **'MOTM: create poll'**
  String get matchFabCreateMotmPoll;

  /// No description provided for @matchFabEditMotmPoll.
  ///
  /// In en, this message translates to:
  /// **'MOTM: edit poll'**
  String get matchFabEditMotmPoll;

  /// No description provided for @matchFabEnterResult.
  ///
  /// In en, this message translates to:
  /// **'Enter match result'**
  String get matchFabEnterResult;

  /// No description provided for @matchFabAddExternalPlayers.
  ///
  /// In en, this message translates to:
  /// **'Add external players'**
  String get matchFabAddExternalPlayers;

  /// No description provided for @onboardingPositionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your position'**
  String get onboardingPositionTitle;

  /// No description provided for @onboardingPositionDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap your position on the pitch'**
  String get onboardingPositionDescription;

  /// No description provided for @onboardingSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Find your team before choosing your position.'**
  String get onboardingSearchDescription;

  /// No description provided for @onboardingSelectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select team'**
  String get onboardingSelectTeam;

  /// No description provided for @onboardingExit.
  ///
  /// In en, this message translates to:
  /// **'Exit signup and log out'**
  String get onboardingExit;

  /// No description provided for @teamRoleEdit.
  ///
  /// In en, this message translates to:
  /// **'Change team role'**
  String get teamRoleEdit;

  /// No description provided for @teamRoleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change the role. Try again.'**
  String get teamRoleSaveFailed;

  /// No description provided for @teamRoleLastLeader.
  ///
  /// In en, this message translates to:
  /// **'Assign another team leader before switching to player.'**
  String get teamRoleLastLeader;

  /// No description provided for @teamSquadTitle.
  ///
  /// In en, this message translates to:
  /// **'Squad'**
  String get teamSquadTitle;

  /// No description provided for @teamSquadEmpty.
  ///
  /// In en, this message translates to:
  /// **'No players found.'**
  String get teamSquadEmpty;

  /// No description provided for @teamSquadLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the squad. Tap to try again.'**
  String get teamSquadLoadFailed;

  /// No description provided for @teamSquadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} players in the squad'**
  String teamSquadCount(int count);
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
