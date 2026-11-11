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

  /// No description provided for @fineBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Fine box'**
  String get fineBoxTitle;

  /// No description provided for @fineBoxMyFines.
  ///
  /// In en, this message translates to:
  /// **'My fines'**
  String get fineBoxMyFines;

  /// No description provided for @fineBoxSegmentOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get fineBoxSegmentOverview;

  /// No description provided for @fineBoxSegmentFineTypes.
  ///
  /// In en, this message translates to:
  /// **'Fine types'**
  String get fineBoxSegmentFineTypes;

  /// No description provided for @fineBoxSegmentFines.
  ///
  /// In en, this message translates to:
  /// **'Fines'**
  String get fineBoxSegmentFines;

  /// No description provided for @fineBoxHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Team kitty'**
  String get fineBoxHeroEyebrow;

  /// No description provided for @fineBoxCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get fineBoxCollected;

  /// No description provided for @fineBoxOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get fineBoxOutstanding;

  /// No description provided for @fineBoxPaidPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of all fines paid'**
  String fineBoxPaidPercent(int percent);

  /// No description provided for @fineBoxGiveFine.
  ///
  /// In en, this message translates to:
  /// **'Give fine'**
  String get fineBoxGiveFine;

  /// No description provided for @fineBoxGiveFineHint.
  ///
  /// In en, this message translates to:
  /// **'To one or more players'**
  String get fineBoxGiveFineHint;

  /// No description provided for @fineBoxDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get fineBoxDeposit;

  /// No description provided for @fineBoxPodiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Fine leaders'**
  String get fineBoxPodiumTitle;

  /// No description provided for @fineBoxPodiumEmpty.
  ///
  /// In en, this message translates to:
  /// **'No outstanding fines. The squad has a clean sheet!'**
  String get fineBoxPodiumEmpty;

  /// No description provided for @fineBoxRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest fines'**
  String get fineBoxRecentTitle;

  /// No description provided for @fineBoxRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fines given yet.'**
  String get fineBoxRecentEmpty;

  /// No description provided for @fineBoxCreateFineType.
  ///
  /// In en, this message translates to:
  /// **'Create fine type'**
  String get fineBoxCreateFineType;

  /// No description provided for @fineBoxCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Fine catalog'**
  String get fineBoxCatalogTitle;

  /// No description provided for @fineBoxCatalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fine types yet. Create the first one.'**
  String get fineBoxCatalogEmpty;

  /// No description provided for @fineBoxCatalogCount.
  ///
  /// In en, this message translates to:
  /// **'{count} types'**
  String fineBoxCatalogCount(int count);

  /// No description provided for @fineBoxPersonalEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get fineBoxPersonalEyebrow;

  /// No description provided for @fineBoxPersonalOwed.
  ///
  /// In en, this message translates to:
  /// **'You owe the team'**
  String get fineBoxPersonalOwed;

  /// No description provided for @fineBoxDebtFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Debt free!'**
  String get fineBoxDebtFreeTitle;

  /// No description provided for @fineBoxDebtFreeBody.
  ///
  /// In en, this message translates to:
  /// **'You have no unpaid fines. Keep it that way.'**
  String get fineBoxDebtFreeBody;

  /// No description provided for @fineBoxUnpaidCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unpaid'**
  String fineBoxUnpaidCount(int count);

  /// No description provided for @fineBoxStatFines.
  ///
  /// In en, this message translates to:
  /// **'Fines'**
  String get fineBoxStatFines;

  /// No description provided for @fineBoxStatPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get fineBoxStatPaid;

  /// No description provided for @fineBoxUnpaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpaid fines'**
  String get fineBoxUnpaidTitle;

  /// No description provided for @fineBoxSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get fineBoxSelectAll;

  /// No description provided for @fineBoxDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get fineBoxDeselectAll;

  /// No description provided for @fineBoxHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Previous fines'**
  String get fineBoxHistoryTitle;

  /// No description provided for @fineBoxPaidBadge.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get fineBoxPaidBadge;

  /// No description provided for @fineBoxSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String fineBoxSelectedCount(int count);

  /// No description provided for @fineBoxMarkCashPaid.
  ///
  /// In en, this message translates to:
  /// **'Or mark as paid in cash'**
  String get fineBoxMarkCashPaid;

  /// No description provided for @fineBoxMobilePayConnected.
  ///
  /// In en, this message translates to:
  /// **'MobilePay Box connected'**
  String get fineBoxMobilePayConnected;

  /// No description provided for @matchTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get matchTasksTitle;

  /// No description provided for @matchTasksNoAssignee.
  ///
  /// In en, this message translates to:
  /// **'Nobody selected yet'**
  String get matchTasksNoAssignee;

  /// No description provided for @matchTasksNextInLine.
  ///
  /// In en, this message translates to:
  /// **'Next in line'**
  String get matchTasksNextInLine;

  /// No description provided for @matchTasksChosenByLeader.
  ///
  /// In en, this message translates to:
  /// **'Chosen by team leader'**
  String get matchTasksChosenByLeader;

  /// No description provided for @matchTasksUpNext.
  ///
  /// In en, this message translates to:
  /// **'Then: {names}'**
  String matchTasksUpNext(String names);

  /// No description provided for @matchTasksOneOffBadge.
  ///
  /// In en, this message translates to:
  /// **'This match only'**
  String get matchTasksOneOffBadge;

  /// No description provided for @matchTasksMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get matchTasksMarkDone;

  /// No description provided for @matchTasksConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Is {task} done?'**
  String matchTasksConfirmTitle(String task);

  /// No description provided for @matchTasksCompletedBy.
  ///
  /// In en, this message translates to:
  /// **'Done by {name}'**
  String matchTasksCompletedBy(String name);

  /// No description provided for @matchTasksAddOneOff.
  ///
  /// In en, this message translates to:
  /// **'Add task for this match'**
  String get matchTasksAddOneOff;

  /// No description provided for @matchTasksNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get matchTasksNameLabel;

  /// No description provided for @matchTasksOneOffNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. balls or water'**
  String get matchTasksOneOffNameHint;

  /// No description provided for @matchTasksPickResponsible.
  ///
  /// In en, this message translates to:
  /// **'Who is responsible?'**
  String get matchTasksPickResponsible;

  /// No description provided for @matchTasksNobodyYet.
  ///
  /// In en, this message translates to:
  /// **'Choose later'**
  String get matchTasksNobodyYet;

  /// No description provided for @matchTasksSelectedTag.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get matchTasksSelectedTag;

  /// No description provided for @matchTasksNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get matchTasksNotSelected;

  /// No description provided for @matchTasksChangeResponsible.
  ///
  /// In en, this message translates to:
  /// **'Change responsible'**
  String get matchTasksChangeResponsible;

  /// No description provided for @matchTasksQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get matchTasksQueueTitle;

  /// No description provided for @matchTasksCreateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get matchTasksCreateConfirm;

  /// No description provided for @matchTasksCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get matchTasksCancel;

  /// No description provided for @matchTasksSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get matchTasksSave;

  /// No description provided for @matchTasksDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get matchTasksDelete;

  /// No description provided for @matchTasksDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {task}? Its queue is deleted too.'**
  String matchTasksDeleteConfirm(String task);

  /// No description provided for @matchTasksDeleteOneOffConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {task} from this match?'**
  String matchTasksDeleteOneOffConfirm(String task);

  /// No description provided for @matchTasksReset.
  ///
  /// In en, this message translates to:
  /// **'Reset queue'**
  String get matchTasksReset;

  /// No description provided for @matchTasksResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset the queue to the order players joined the team?'**
  String get matchTasksResetConfirm;

  /// No description provided for @matchTasksError.
  ///
  /// In en, this message translates to:
  /// **'The task could not be updated. Please try again.'**
  String get matchTasksError;

  /// No description provided for @matchTasksEmptyLeader.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Create recurring tasks such as beer and laundry in the team settings.'**
  String get matchTasksEmptyLeader;

  /// No description provided for @matchTasksEmptyPlayer.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add a task for this match, e.g. balls or water.'**
  String get matchTasksEmptyPlayer;

  /// No description provided for @matchTasksManage.
  ///
  /// In en, this message translates to:
  /// **'Recurring tasks'**
  String get matchTasksManage;

  /// No description provided for @teamTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Match tasks'**
  String get teamTasksTitle;

  /// No description provided for @teamTasksIntro.
  ///
  /// In en, this message translates to:
  /// **'Recurring tasks rotate on every match. The player highest in the queue who is selected gets the task. Once it is done, that player moves to the back.'**
  String get teamTasksIntro;

  /// No description provided for @teamTasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recurring tasks yet. Create e.g. beer, laundry or the candy bag.'**
  String get teamTasksEmpty;

  /// No description provided for @teamTasksCreate.
  ///
  /// In en, this message translates to:
  /// **'New recurring task'**
  String get teamTasksCreate;

  /// No description provided for @teamTasksNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. beer or laundry'**
  String get teamTasksNameHint;

  /// No description provided for @teamTasksRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get teamTasksRename;

  /// No description provided for @teamTasksQueueHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to change the order.'**
  String get teamTasksQueueHint;

  /// No description provided for @teamTasksPlayers.
  ///
  /// In en, this message translates to:
  /// **'{count} players in the queue'**
  String teamTasksPlayers(int count);

  /// No description provided for @teamRoleFineAdmin.
  ///
  /// In en, this message translates to:
  /// **'Fine admin'**
  String get teamRoleFineAdmin;

  /// No description provided for @teamRoleMakeFineAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make fine admin'**
  String get teamRoleMakeFineAdmin;

  /// No description provided for @teamRoleRemoveFineAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove as fine admin'**
  String get teamRoleRemoveFineAdmin;

  /// No description provided for @fineBoxWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get fineBoxWithdraw;

  /// No description provided for @fineBoxWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw from the fine box'**
  String get fineBoxWithdrawTitle;

  /// No description provided for @fineBoxWithdrawIntro.
  ///
  /// In en, this message translates to:
  /// **'Record how much you took from the box. There is {amount} kr. in the box now.'**
  String fineBoxWithdrawIntro(int amount);

  /// No description provided for @fineBoxWithdrawAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fineBoxWithdrawAmountHint;

  /// No description provided for @fineBoxWithdrawNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What was the money for? (optional)'**
  String get fineBoxWithdrawNoteHint;

  /// No description provided for @fineBoxWithdrawSave.
  ///
  /// In en, this message translates to:
  /// **'Record withdrawal'**
  String get fineBoxWithdrawSave;

  /// No description provided for @fineBoxWithdrawInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0 kr.'**
  String get fineBoxWithdrawInvalidAmount;

  /// No description provided for @fineBoxWithdrawTooMuch.
  ///
  /// In en, this message translates to:
  /// **'There is not that much money in the box.'**
  String get fineBoxWithdrawTooMuch;

  /// No description provided for @fineBoxWithdrawFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not record the withdrawal. Try again.'**
  String get fineBoxWithdrawFailed;

  /// No description provided for @fineBoxWithdrawalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get fineBoxWithdrawalsTitle;

  /// No description provided for @fineBoxWithdrawalNoNote.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get fineBoxWithdrawalNoNote;

  /// No description provided for @fineBoxWithdrawalUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Former player'**
  String get fineBoxWithdrawalUnknownUser;

  /// No description provided for @mobilePayPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Have you paid {amount} kr?'**
  String mobilePayPaidTitle(int amount);

  /// No description provided for @mobilePayPaidBody.
  ///
  /// In en, this message translates to:
  /// **'We can\'t see MobilePay payments in Kopa. If you say yes, the selected fines are marked as paid.'**
  String get mobilePayPaidBody;

  /// No description provided for @mobilePayPaidYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get mobilePayPaidYes;

  /// No description provided for @mobilePayPaidNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get mobilePayPaidNo;

  /// No description provided for @mobilePayPaidSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Your payment could not be saved. Please try again.'**
  String get mobilePayPaidSaveFailed;

  /// No description provided for @fineBoxSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get fineBoxSeeAll;

  /// No description provided for @fineBoxPlayersTitle.
  ///
  /// In en, this message translates to:
  /// **'All players'**
  String get fineBoxPlayersTitle;

  /// No description provided for @fineBoxAllFinesTitle.
  ///
  /// In en, this message translates to:
  /// **'All fines'**
  String get fineBoxAllFinesTitle;

  /// No description provided for @fineBoxInBox.
  ///
  /// In en, this message translates to:
  /// **'In the box'**
  String get fineBoxInBox;

  /// No description provided for @fineBoxAllPaid.
  ///
  /// In en, this message translates to:
  /// **'All paid'**
  String get fineBoxAllPaid;

  /// No description provided for @fineBoxDeleteFine.
  ///
  /// In en, this message translates to:
  /// **'Delete fine'**
  String get fineBoxDeleteFine;

  /// No description provided for @fineBoxDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get fineBoxDeleteCancel;

  /// No description provided for @fineBoxDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'The fine could not be deleted. Try again.'**
  String get fineBoxDeleteFailed;

  /// No description provided for @fineBoxPlayerFineCount.
  ///
  /// In en, this message translates to:
  /// **'{count} fines'**
  String fineBoxPlayerFineCount(int count);

  /// No description provided for @fineBoxDeleteFineBody.
  ///
  /// In en, this message translates to:
  /// **'Delete {fine} for {name}? This cannot be undone.'**
  String fineBoxDeleteFineBody(String fine, String name);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navSquad.
  ///
  /// In en, this message translates to:
  /// **'Squad'**
  String get navSquad;

  /// No description provided for @navFineBox.
  ///
  /// In en, this message translates to:
  /// **'Fine box'**
  String get navFineBox;

  /// No description provided for @uiChooseDbuTeam.
  ///
  /// In en, this message translates to:
  /// **'Choose DBU team'**
  String get uiChooseDbuTeam;

  /// No description provided for @uiCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get uiCancel;

  /// No description provided for @uiCouldNotFetchTheInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the invite link.'**
  String get uiCouldNotFetchTheInviteLink;

  /// No description provided for @uiLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get uiLinkCopied;

  /// No description provided for @uiJoinOnKopa.
  ///
  /// In en, this message translates to:
  /// **'Join {a} on Kopa: {b}'**
  String uiJoinOnKopa(Object a, Object b);

  /// No description provided for @uiCouldNotSaveThePositionTry.
  ///
  /// In en, this message translates to:
  /// **'Could not save the position. Try again.'**
  String get uiCouldNotSaveThePositionTry;

  /// No description provided for @uiInviteYourTeam.
  ///
  /// In en, this message translates to:
  /// **'Invite your team'**
  String get uiInviteYourTeam;

  /// No description provided for @uiCreateYourFootballTeamAndKeep.
  ///
  /// In en, this message translates to:
  /// **'Create your football team and keep players, matches and statistics in one place.'**
  String get uiCreateYourFootballTeamAndKeep;

  /// No description provided for @uiShareTheLinkWithThePlayers.
  ///
  /// In en, this message translates to:
  /// **'Share the link with the players so they can find the team.'**
  String get uiShareTheLinkWithThePlayers;

  /// No description provided for @uiContinueToKopa.
  ///
  /// In en, this message translates to:
  /// **'Continue to Kopa'**
  String get uiContinueToKopa;

  /// No description provided for @uiAssociation.
  ///
  /// In en, this message translates to:
  /// **'Association'**
  String get uiAssociation;

  /// No description provided for @uiYourTeamName.
  ///
  /// In en, this message translates to:
  /// **'Your team name'**
  String get uiYourTeamName;

  /// No description provided for @uiYouChose.
  ///
  /// In en, this message translates to:
  /// **'You chose: {a} ({b})'**
  String uiYouChose(Object a, Object b);

  /// No description provided for @ui7ASide.
  ///
  /// In en, this message translates to:
  /// **'7-a-side'**
  String get ui7ASide;

  /// No description provided for @ui11ASide.
  ///
  /// In en, this message translates to:
  /// **'11-a-side'**
  String get ui11ASide;

  /// No description provided for @uiSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get uiSearchResults;

  /// No description provided for @uiTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Team leader: {a}'**
  String uiTeamLeader(Object a);

  /// No description provided for @uiTeamLeaderPending.
  ///
  /// In en, this message translates to:
  /// **'Team leader: Pending'**
  String get uiTeamLeaderPending;

  /// No description provided for @uiMembers.
  ///
  /// In en, this message translates to:
  /// **'{a} members'**
  String uiMembers(Object a);

  /// No description provided for @uiTheInviteLinkCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'The invite link could not be fetched.'**
  String get uiTheInviteLinkCouldNotBe;

  /// No description provided for @uiCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get uiCopyLink;

  /// No description provided for @uiShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get uiShareLink;

  /// No description provided for @uiBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get uiBack;

  /// No description provided for @uiStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {a} of {b}'**
  String uiStepOf(Object a, Object b);

  /// No description provided for @uiDbuConnected.
  ///
  /// In en, this message translates to:
  /// **'DBU connected'**
  String get uiDbuConnected;

  /// No description provided for @uiTeamDataHasBeenImported.
  ///
  /// In en, this message translates to:
  /// **'Team data has been imported'**
  String get uiTeamDataHasBeenImported;

  /// No description provided for @uiLogInThroughDbuToImport.
  ///
  /// In en, this message translates to:
  /// **'Log in through DBU to import team data'**
  String get uiLogInThroughDbuToImport;

  /// No description provided for @uiYourTeam.
  ///
  /// In en, this message translates to:
  /// **'your team'**
  String get uiYourTeam;

  /// No description provided for @uiYourTeam2.
  ///
  /// In en, this message translates to:
  /// **'Your team'**
  String get uiYourTeam2;

  /// No description provided for @uiStep3Of5.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 5'**
  String get uiStep3Of5;

  /// No description provided for @uiWaitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get uiWaitingForApproval;

  /// No description provided for @uiYouHaveAskedToJoinYou.
  ///
  /// In en, this message translates to:
  /// **'You have asked to join {a}. You will be notified when the team leader has accepted your request.'**
  String uiYouHaveAskedToJoinYou(Object a);

  /// No description provided for @uiPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get uiPending;

  /// No description provided for @uiCouldNotValidateTheInvitation.
  ///
  /// In en, this message translates to:
  /// **'Could not validate the invitation'**
  String get uiCouldNotValidateTheInvitation;

  /// No description provided for @uiNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get uiNetworkError;

  /// No description provided for @uiNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get uiNotLoggedIn;

  /// No description provided for @uiCouldNotJoinTheTeam.
  ///
  /// In en, this message translates to:
  /// **'Could not join the team'**
  String get uiCouldNotJoinTheTeam;

  /// No description provided for @uiCouldNotFetchTheCode.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the code'**
  String get uiCouldNotFetchTheCode;

  /// No description provided for @uiCouldNotRotateTheCode.
  ///
  /// In en, this message translates to:
  /// **'Could not rotate the code'**
  String get uiCouldNotRotateTheCode;

  /// No description provided for @uiCouldNotCreateTheTeam.
  ///
  /// In en, this message translates to:
  /// **'Could not create the team'**
  String get uiCouldNotCreateTheTeam;

  /// No description provided for @uiCouldNotSearchForTeams.
  ///
  /// In en, this message translates to:
  /// **'Could not search for teams'**
  String get uiCouldNotSearchForTeams;

  /// No description provided for @uiCouldNotSendTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not send the request'**
  String get uiCouldNotSendTheRequest;

  /// No description provided for @uiCouldNotFetchTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the request'**
  String get uiCouldNotFetchTheRequest;

  /// No description provided for @uiCouldNotFetchTheRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the requests'**
  String get uiCouldNotFetchTheRequests;

  /// No description provided for @uiCouldNotProcessTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not process the request'**
  String get uiCouldNotProcessTheRequest;

  /// No description provided for @uiCouldNotCancelTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel the request'**
  String get uiCouldNotCancelTheRequest;

  /// No description provided for @uiInvalidInvitation.
  ///
  /// In en, this message translates to:
  /// **'Invalid invitation'**
  String get uiInvalidInvitation;

  /// No description provided for @uiSomethingWentWrongPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get uiSomethingWentWrongPleaseTryAgain;

  /// No description provided for @uiNoUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found.'**
  String get uiNoUserFound;

  /// No description provided for @uiPracticalInformation.
  ///
  /// In en, this message translates to:
  /// **'Practical information'**
  String get uiPracticalInformation;

  /// No description provided for @uiRegisteredPlayers.
  ///
  /// In en, this message translates to:
  /// **'Registered players'**
  String get uiRegisteredPlayers;

  /// No description provided for @uiDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get uiDate;

  /// No description provided for @uiTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get uiTime;

  /// No description provided for @uiLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get uiLocation;

  /// No description provided for @uiCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get uiCountdown;

  /// No description provided for @uiRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Registrations'**
  String get uiRegistrations;

  /// No description provided for @uiRegistered.
  ///
  /// In en, this message translates to:
  /// **'{a} registered'**
  String uiRegistered(Object a);

  /// No description provided for @uiMeetingTime.
  ///
  /// In en, this message translates to:
  /// **'Meeting time'**
  String get uiMeetingTime;

  /// No description provided for @uiYourSelection.
  ///
  /// In en, this message translates to:
  /// **'Your selection'**
  String get uiYourSelection;

  /// No description provided for @uiNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get uiNotes;

  /// No description provided for @uiNoResponse.
  ///
  /// In en, this message translates to:
  /// **'No response'**
  String get uiNoResponse;

  /// No description provided for @uiDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get uiDeclined;

  /// No description provided for @uiAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available ({a})'**
  String uiAvailable(Object a);

  /// No description provided for @uiSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected ({a})'**
  String uiSelected(Object a);

  /// No description provided for @uiNoResponse2.
  ///
  /// In en, this message translates to:
  /// **'No response ({a})'**
  String uiNoResponse2(Object a);

  /// No description provided for @uiDeclined2.
  ///
  /// In en, this message translates to:
  /// **'Declined ({a})'**
  String uiDeclined2(Object a);

  /// No description provided for @uiCouldNotUpdateTheApprovalTry.
  ///
  /// In en, this message translates to:
  /// **'Could not update the approval. Try again.'**
  String get uiCouldNotUpdateTheApprovalTry;

  /// No description provided for @uiCouldNotApproveEveryoneTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not approve everyone. Try again.'**
  String get uiCouldNotApproveEveryoneTryAgain;

  /// No description provided for @uiCouldNotChangeTheVisibilityTry.
  ///
  /// In en, this message translates to:
  /// **'Could not change the visibility. Try again.'**
  String get uiCouldNotChangeTheVisibilityTry;

  /// No description provided for @uiInProgressOrFinished.
  ///
  /// In en, this message translates to:
  /// **'In progress or finished'**
  String get uiInProgressOrFinished;

  /// No description provided for @uiDaysHours.
  ///
  /// In en, this message translates to:
  /// **'{a} days {b} hours'**
  String uiDaysHours(Object a, Object b);

  /// No description provided for @uiReject.
  ///
  /// In en, this message translates to:
  /// **'Reject {a}'**
  String uiReject(Object a);

  /// No description provided for @uiApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve {a}'**
  String uiApprove(Object a);

  /// No description provided for @uiApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get uiApproved;

  /// No description provided for @uiRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get uiRejected;

  /// No description provided for @uiEditChoiceFor.
  ///
  /// In en, this message translates to:
  /// **'Edit choice for {a}'**
  String uiEditChoiceFor(Object a);

  /// No description provided for @uiNoPlayersAreAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'No players are awaiting approval.'**
  String get uiNoPlayersAreAwaitingApproval;

  /// No description provided for @uiApproveAll.
  ///
  /// In en, this message translates to:
  /// **'Approve all'**
  String get uiApproveAll;

  /// No description provided for @uiNoPlayersHere.
  ///
  /// In en, this message translates to:
  /// **'No players here.'**
  String get uiNoPlayersHere;

  /// No description provided for @uiCouldNotSaveTheLineupTry.
  ///
  /// In en, this message translates to:
  /// **'Could not save the lineup. Try again.'**
  String get uiCouldNotSaveTheLineupTry;

  /// No description provided for @uiChoosePlayer.
  ///
  /// In en, this message translates to:
  /// **'Choose player'**
  String get uiChoosePlayer;

  /// No description provided for @uiEditLineup.
  ///
  /// In en, this message translates to:
  /// **'Edit lineup'**
  String get uiEditLineup;

  /// No description provided for @uiEditFormation.
  ///
  /// In en, this message translates to:
  /// **'Edit formation ({a})'**
  String uiEditFormation(Object a);

  /// No description provided for @uiMovePlayerReleaseToPlace.
  ///
  /// In en, this message translates to:
  /// **'Move player: Release to place {a}'**
  String uiMovePlayerReleaseToPlace(Object a);

  /// No description provided for @uiBenchPlayers.
  ///
  /// In en, this message translates to:
  /// **'Bench ({a} players)'**
  String uiBenchPlayers(Object a);

  /// No description provided for @uiNoPlayersOnTheBench.
  ///
  /// In en, this message translates to:
  /// **'No players on the bench'**
  String get uiNoPlayersOnTheBench;

  /// No description provided for @uiHoldAPlayerAndDragTo.
  ///
  /// In en, this message translates to:
  /// **'Hold a player and drag to swap places'**
  String get uiHoldAPlayerAndDragTo;

  /// No description provided for @uiChooseFormation.
  ///
  /// In en, this message translates to:
  /// **'Choose formation'**
  String get uiChooseFormation;

  /// No description provided for @uiChooseTheFormationThatSuitsYour.
  ///
  /// In en, this message translates to:
  /// **'Choose the formation that suits your next match best'**
  String get uiChooseTheFormationThatSuitsYour;

  /// No description provided for @uiFormation.
  ///
  /// In en, this message translates to:
  /// **'Formation {a}'**
  String uiFormation(Object a);

  /// No description provided for @uiGk.
  ///
  /// In en, this message translates to:
  /// **'GK'**
  String get uiGk;

  /// No description provided for @uiAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get uiAm;

  /// No description provided for @uiPl.
  ///
  /// In en, this message translates to:
  /// **'PL'**
  String get uiPl;

  /// No description provided for @uiStandard7ASide.
  ///
  /// In en, this message translates to:
  /// **'Standard 7-a-side'**
  String get uiStandard7ASide;

  /// No description provided for @uiDefensiveBalance.
  ///
  /// In en, this message translates to:
  /// **'Defensive balance'**
  String get uiDefensiveBalance;

  /// No description provided for @uiSymmetricControl.
  ///
  /// In en, this message translates to:
  /// **'Symmetric control'**
  String get uiSymmetricControl;

  /// No description provided for @uiAttackingWidth.
  ///
  /// In en, this message translates to:
  /// **'Attacking width'**
  String get uiAttackingWidth;

  /// No description provided for @uiClassicBalance.
  ///
  /// In en, this message translates to:
  /// **'Classic balance'**
  String get uiClassicBalance;

  /// No description provided for @uiMidfieldControl.
  ///
  /// In en, this message translates to:
  /// **'Midfield control'**
  String get uiMidfieldControl;

  /// No description provided for @uiControlledPressing.
  ///
  /// In en, this message translates to:
  /// **'Controlled pressing'**
  String get uiControlledPressing;

  /// No description provided for @uiCustomLineup.
  ///
  /// In en, this message translates to:
  /// **'Custom lineup'**
  String get uiCustomLineup;

  /// No description provided for @uiSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get uiSettings;

  /// No description provided for @uiImportMatchSchedule.
  ///
  /// In en, this message translates to:
  /// **'Import match schedule'**
  String get uiImportMatchSchedule;

  /// No description provided for @uiFetchingLink.
  ///
  /// In en, this message translates to:
  /// **'Fetching link...'**
  String get uiFetchingLink;

  /// No description provided for @uiShareKopa.
  ///
  /// In en, this message translates to:
  /// **'Share Kopa'**
  String get uiShareKopa;

  /// No description provided for @uiTeamTools.
  ///
  /// In en, this message translates to:
  /// **'Team tools'**
  String get uiTeamTools;

  /// No description provided for @uiApproveNewPlayers.
  ///
  /// In en, this message translates to:
  /// **'Approve new players'**
  String get uiApproveNewPlayers;

  /// No description provided for @uiSyncingStandings.
  ///
  /// In en, this message translates to:
  /// **'Syncing standings...'**
  String get uiSyncingStandings;

  /// No description provided for @uiSyncStandingsFromDbu.
  ///
  /// In en, this message translates to:
  /// **'Sync standings from DBU'**
  String get uiSyncStandingsFromDbu;

  /// No description provided for @uiDefaultMeetingTime.
  ///
  /// In en, this message translates to:
  /// **'Default meeting time'**
  String get uiDefaultMeetingTime;

  /// No description provided for @uiSavingMeetingTime.
  ///
  /// In en, this message translates to:
  /// **'Saving meeting time...'**
  String get uiSavingMeetingTime;

  /// No description provided for @uiSaveMeetingTime.
  ///
  /// In en, this message translates to:
  /// **'Save meeting time'**
  String get uiSaveMeetingTime;

  /// No description provided for @uiLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get uiLoggingOut;

  /// No description provided for @uiLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get uiLogOut;

  /// No description provided for @uiCouldNotLogOut.
  ///
  /// In en, this message translates to:
  /// **'Could not log out.'**
  String get uiCouldNotLogOut;

  /// No description provided for @uiYouMustBeOnATeam.
  ///
  /// In en, this message translates to:
  /// **'You must be on a team to share Kopa.'**
  String get uiYouMustBeOnATeam;

  /// No description provided for @uiCouldNotShareKopa.
  ///
  /// In en, this message translates to:
  /// **'Could not share Kopa.'**
  String get uiCouldNotShareKopa;

  /// No description provided for @uiOnlyTheTeamLeaderCanChange.
  ///
  /// In en, this message translates to:
  /// **'Only the team leader can change the meeting time.'**
  String get uiOnlyTheTeamLeaderCanChange;

  /// No description provided for @uiTheDefaultMeetingTimeIsSet.
  ///
  /// In en, this message translates to:
  /// **'The default meeting time is set to {a}.'**
  String uiTheDefaultMeetingTimeIsSet(Object a);

  /// No description provided for @uiNoDefault.
  ///
  /// In en, this message translates to:
  /// **'No default'**
  String get uiNoDefault;

  /// No description provided for @uiMinBeforeKickoff.
  ///
  /// In en, this message translates to:
  /// **'{a} min before kickoff'**
  String uiMinBeforeKickoff(Object a);

  /// No description provided for @uiStandingsAndPoolTeamsAreSynced.
  ///
  /// In en, this message translates to:
  /// **'Standings and pool teams are synced ({a} teams).'**
  String uiStandingsAndPoolTeamsAreSynced(Object a);

  /// No description provided for @uiFines.
  ///
  /// In en, this message translates to:
  /// **'Fines - {a}'**
  String uiFines(Object a);

  /// No description provided for @ui1HourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get ui1HourAgo;

  /// No description provided for @uiHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{a} hours ago'**
  String uiHoursAgo(Object a);

  /// No description provided for @uiYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get uiYesterday;

  /// No description provided for @uiDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{a} days ago'**
  String uiDaysAgo(Object a);

  /// No description provided for @uiUserNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get uiUserNotLoggedIn;

  /// No description provided for @uiCouldNotFetchDashboardData.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch dashboard data'**
  String get uiCouldNotFetchDashboardData;

  /// No description provided for @uiCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get uiCalendar;

  /// No description provided for @uiProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get uiProfile;

  /// No description provided for @uiNoUpcomingMatch.
  ///
  /// In en, this message translates to:
  /// **'No upcoming match'**
  String get uiNoUpcomingMatch;

  /// No description provided for @uiTheScheduleIsBeingUpdated.
  ///
  /// In en, this message translates to:
  /// **'The schedule is being updated'**
  String get uiTheScheduleIsBeingUpdated;

  /// No description provided for @uiTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get uiTeam;

  /// No description provided for @uiOpponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get uiOpponent;

  /// No description provided for @uiNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get uiNoMatch;

  /// No description provided for @uiNoMatchPlanned.
  ///
  /// In en, this message translates to:
  /// **'No match planned'**
  String get uiNoMatchPlanned;

  /// No description provided for @uiNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get uiNoLocation;

  /// No description provided for @uiMap.
  ///
  /// In en, this message translates to:
  /// **'Map ›'**
  String get uiMap;

  /// No description provided for @uiLatestMatch.
  ///
  /// In en, this message translates to:
  /// **'Latest match'**
  String get uiLatestMatch;

  /// No description provided for @uiStandings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get uiStandings;

  /// No description provided for @uiStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get uiStatistics;

  /// No description provided for @uiRegistered2.
  ///
  /// In en, this message translates to:
  /// **'registered'**
  String get uiRegistered2;

  /// No description provided for @uiANewSeasonHasStartedAnd.
  ///
  /// In en, this message translates to:
  /// **'A new season has started and the match schedule has been imported.'**
  String get uiANewSeasonHasStartedAnd;

  /// No description provided for @uiTheMatchScheduleHasBeenUpdated.
  ///
  /// In en, this message translates to:
  /// **'The match schedule has been updated.'**
  String get uiTheMatchScheduleHasBeenUpdated;

  /// No description provided for @uiStartNewSeason.
  ///
  /// In en, this message translates to:
  /// **'Start new season?'**
  String get uiStartNewSeason;

  /// No description provided for @uiUpdateCurrent.
  ///
  /// In en, this message translates to:
  /// **'Update current'**
  String get uiUpdateCurrent;

  /// No description provided for @uiStartNewSeason2.
  ///
  /// In en, this message translates to:
  /// **'Start new season'**
  String get uiStartNewSeason2;

  /// No description provided for @uiMissingResults.
  ///
  /// In en, this message translates to:
  /// **'Missing results'**
  String get uiMissingResults;

  /// No description provided for @uiGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get uiGoBack;

  /// No description provided for @uiStartAnyway.
  ///
  /// In en, this message translates to:
  /// **'Start anyway'**
  String get uiStartAnyway;

  /// No description provided for @uiSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get uiSpring;

  /// No description provided for @uiSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get uiSummer;

  /// No description provided for @uiAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get uiAutumn;

  /// No description provided for @uiWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get uiWinter;

  /// No description provided for @uiNoTeamSelected.
  ///
  /// In en, this message translates to:
  /// **'No team selected.'**
  String get uiNoTeamSelected;

  /// No description provided for @uiTeamKeyFigures.
  ///
  /// In en, this message translates to:
  /// **'Team key figures'**
  String get uiTeamKeyFigures;

  /// No description provided for @uiTeamPointsAverage.
  ///
  /// In en, this message translates to:
  /// **'Team points average'**
  String get uiTeamPointsAverage;

  /// No description provided for @uiTeamForm.
  ///
  /// In en, this message translates to:
  /// **'Team form'**
  String get uiTeamForm;

  /// No description provided for @uiGoalsScored.
  ///
  /// In en, this message translates to:
  /// **'Goals scored'**
  String get uiGoalsScored;

  /// No description provided for @uiGoalsConceded.
  ///
  /// In en, this message translates to:
  /// **'Goals conceded'**
  String get uiGoalsConceded;

  /// No description provided for @uiSeeTheFormTableStreaksAnd.
  ///
  /// In en, this message translates to:
  /// **'See the form table, streaks and points.'**
  String get uiSeeTheFormTableStreaksAnd;

  /// No description provided for @uiYourStats.
  ///
  /// In en, this message translates to:
  /// **'Your stats'**
  String get uiYourStats;

  /// No description provided for @uiForThisSeason.
  ///
  /// In en, this message translates to:
  /// **'For this season.'**
  String get uiForThisSeason;

  /// No description provided for @uiVotes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get uiVotes;

  /// No description provided for @uiNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet.'**
  String get uiNoDataYet;

  /// No description provided for @uiSomeResultsAreLockedSeePlayer.
  ///
  /// In en, this message translates to:
  /// **'Some results are locked. See Player+ to unlock the full table.'**
  String get uiSomeResultsAreLockedSeePlayer;

  /// No description provided for @uiTheSeasonSInternalCompetitionStarts.
  ///
  /// In en, this message translates to:
  /// **'The season\'s internal competition starts here.'**
  String get uiTheSeasonSInternalCompetitionStarts;

  /// No description provided for @uiSeasonDuels.
  ///
  /// In en, this message translates to:
  /// **'Season duels'**
  String get uiSeasonDuels;

  /// No description provided for @uiBestPlayer.
  ///
  /// In en, this message translates to:
  /// **'Best player'**
  String get uiBestPlayer;

  /// No description provided for @uiMostGoals.
  ///
  /// In en, this message translates to:
  /// **'Most goals'**
  String get uiMostGoals;

  /// No description provided for @uiMostAssists.
  ///
  /// In en, this message translates to:
  /// **'Most assists'**
  String get uiMostAssists;

  /// No description provided for @uiMostCards.
  ///
  /// In en, this message translates to:
  /// **'Most cards'**
  String get uiMostCards;

  /// No description provided for @uiCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get uiCards;

  /// No description provided for @uiFineKing.
  ///
  /// In en, this message translates to:
  /// **'Fine king'**
  String get uiFineKing;

  /// No description provided for @uiInternalTables.
  ///
  /// In en, this message translates to:
  /// **'Internal tables'**
  String get uiInternalTables;

  /// No description provided for @uiSeasonCompetitionsForOverallMvpGoals.
  ///
  /// In en, this message translates to:
  /// **'Season competitions for overall, MVP, goals, assists, cards and fines across the team.'**
  String get uiSeasonCompetitionsForOverallMvpGoals;

  /// No description provided for @uiLeagueComparison.
  ///
  /// In en, this message translates to:
  /// **'League comparison'**
  String get uiLeagueComparison;

  /// No description provided for @uiComparePlayersWithOtherTeamsIn.
  ///
  /// In en, this message translates to:
  /// **'Compare players with other teams in the same league once DBU data is synced.'**
  String get uiComparePlayersWithOtherTeamsIn;

  /// No description provided for @uiHiddenPatterns.
  ///
  /// In en, this message translates to:
  /// **'Hidden patterns'**
  String get uiHiddenPatterns;

  /// No description provided for @uiFormCurvesStreaksAndSmallInternal.
  ///
  /// In en, this message translates to:
  /// **'Form curves, streaks and small internal competitions based on your own match data.'**
  String get uiFormCurvesStreaksAndSmallInternal;

  /// No description provided for @uiTheTeamCompetitionBuiltAutomaticallyFrom.
  ///
  /// In en, this message translates to:
  /// **'The team competition built automatically from your match data — goals, assists, streaks and bonuses.'**
  String get uiTheTeamCompetitionBuiltAutomaticallyFrom;

  /// No description provided for @uiCloseCalendar.
  ///
  /// In en, this message translates to:
  /// **'Close calendar'**
  String get uiCloseCalendar;

  /// No description provided for @uiPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get uiPreviousMonth;

  /// No description provided for @uiNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get uiNextMonth;

  /// No description provided for @uiCalendarDay.
  ///
  /// In en, this message translates to:
  /// **'Calendar day {a}'**
  String uiCalendarDay(Object a);

  /// No description provided for @uiCouldNotFetchPointDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch point details.'**
  String get uiCouldNotFetchPointDetails;

  /// No description provided for @uiPointsStory.
  ///
  /// In en, this message translates to:
  /// **'Points story'**
  String get uiPointsStory;

  /// No description provided for @uiNoPointsInTheSelectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'No points in the selected period.'**
  String get uiNoPointsInTheSelectedPeriod;

  /// No description provided for @uiOnTheTeam.
  ///
  /// In en, this message translates to:
  /// **'#{a} on the team'**
  String uiOnTheTeam(Object a);

  /// No description provided for @uiStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get uiStable;

  /// No description provided for @uiLatestRound.
  ///
  /// In en, this message translates to:
  /// **'Latest round'**
  String get uiLatestRound;

  /// No description provided for @uiToFirstPlace.
  ///
  /// In en, this message translates to:
  /// **'To first place'**
  String get uiToFirstPlace;

  /// No description provided for @uiLeading.
  ///
  /// In en, this message translates to:
  /// **'Leading'**
  String get uiLeading;

  /// No description provided for @uiMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get uiMovement;

  /// No description provided for @uiTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get uiTable;

  /// No description provided for @uiSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get uiSomethingWentWrong;

  /// No description provided for @uiNoPointsYetRecordMatchData.
  ///
  /// In en, this message translates to:
  /// **'No points yet. Record match data to start the team competition.'**
  String get uiNoPointsYetRecordMatchData;

  /// No description provided for @uiRestOfTheTeam.
  ///
  /// In en, this message translates to:
  /// **'Rest of the team'**
  String get uiRestOfTheTeam;

  /// No description provided for @uiTheTeamCompetition.
  ///
  /// In en, this message translates to:
  /// **'The team competition'**
  String get uiTheTeamCompetition;

  /// No description provided for @uiWhoIsNinForm.
  ///
  /// In en, this message translates to:
  /// **'Who is\nin form?'**
  String get uiWhoIsNinForm;

  /// No description provided for @uiMatchDataStreaksAndBonusesIn.
  ///
  /// In en, this message translates to:
  /// **'Match data, streaks and bonuses in one place.'**
  String get uiMatchDataStreaksAndBonusesIn;

  /// No description provided for @uiYouAreNoWith.
  ///
  /// In en, this message translates to:
  /// **'You are no. {a} with {b}.'**
  String uiYouAreNoWith(Object a, Object b);

  /// No description provided for @uiChoosePosition.
  ///
  /// In en, this message translates to:
  /// **'Choose position'**
  String get uiChoosePosition;

  /// No description provided for @uiAllPositions.
  ///
  /// In en, this message translates to:
  /// **'All positions'**
  String get uiAllPositions;

  /// No description provided for @uiWhichPositionDoYouPlay.
  ///
  /// In en, this message translates to:
  /// **'Which position do you play?'**
  String get uiWhichPositionDoYouPlay;

  /// No description provided for @uiYourPositionGivesThePointRules.
  ///
  /// In en, this message translates to:
  /// **'Your position gives the point rules the right weight.'**
  String get uiYourPositionGivesThePointRules;

  /// No description provided for @uiPoints.
  ///
  /// In en, this message translates to:
  /// **'{a} points'**
  String uiPoints(Object a);

  /// No description provided for @uiPoints2.
  ///
  /// In en, this message translates to:
  /// **'points · {a}'**
  String uiPoints2(Object a);

  /// No description provided for @uiCouldNotLogInAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Could not log in automatically.'**
  String get uiCouldNotLogInAutomatically;

  /// No description provided for @uiRegistrationFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Try again.'**
  String get uiRegistrationFailedTryAgain;

  /// No description provided for @uiPleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get uiPleaseEnterYourName;

  /// No description provided for @uiPleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get uiPleaseEnterYourEmail;

  /// No description provided for @uiPleaseEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get uiPleaseEnterAValidEmail;

  /// No description provided for @uiPleaseEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get uiPleaseEnterAPassword;

  /// No description provided for @uiThePasswordMustBeAtLeast.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 6 characters'**
  String get uiThePasswordMustBeAtLeast;

  /// No description provided for @uiCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get uiCreateUser;

  /// No description provided for @uiName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get uiName;

  /// No description provided for @uiPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get uiPassword;

  /// No description provided for @uiCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get uiCreateAccount;

  /// No description provided for @uiHomeTeam.
  ///
  /// In en, this message translates to:
  /// **'Home team'**
  String get uiHomeTeam;

  /// No description provided for @uiEGSNderjyske.
  ///
  /// In en, this message translates to:
  /// **'E.g. Sønderjyske'**
  String get uiEGSNderjyske;

  /// No description provided for @uiAwayTeam.
  ///
  /// In en, this message translates to:
  /// **'Away team'**
  String get uiAwayTeam;

  /// No description provided for @uiEGAgf.
  ///
  /// In en, this message translates to:
  /// **'E.g. AGF'**
  String get uiEGAgf;

  /// No description provided for @uiEGSydbankPark.
  ///
  /// In en, this message translates to:
  /// **'E.g. Sydbank Park'**
  String get uiEGSydbankPark;

  /// No description provided for @uiOptionalComments.
  ///
  /// In en, this message translates to:
  /// **'Optional comments'**
  String get uiOptionalComments;

  /// No description provided for @uiFillInBothTeamsAndThe.
  ///
  /// In en, this message translates to:
  /// **'Fill in both teams and the location, and choose a date.'**
  String get uiFillInBothTeamsAndThe;

  /// No description provided for @uiTheFirstAndSecondTeamCannot.
  ///
  /// In en, this message translates to:
  /// **'The first and second team cannot be the same.'**
  String get uiTheFirstAndSecondTeamCannot;

  /// No description provided for @uiAddPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get uiAddPlayer;

  /// No description provided for @uiEGLarsLarsen.
  ///
  /// In en, this message translates to:
  /// **'E.g. Lars Larsen'**
  String get uiEGLarsLarsen;

  /// No description provided for @uiEGLarsExampleCom.
  ///
  /// In en, this message translates to:
  /// **'E.g. lars@example.com'**
  String get uiEGLarsExampleCom;

  /// No description provided for @uiEnterThePlayerSName.
  ///
  /// In en, this message translates to:
  /// **'Enter the player\'s name'**
  String get uiEnterThePlayerSName;

  /// No description provided for @uiEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get uiEnterEmail;

  /// No description provided for @uiEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get uiEnterAValidEmail;

  /// No description provided for @uiPleaseEnterNameAndEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter name and email.'**
  String get uiPleaseEnterNameAndEmail;

  /// No description provided for @uiThePlayerIsAlreadyInThe.
  ///
  /// In en, this message translates to:
  /// **'The player is already in the squad. Enter another name and/or email.'**
  String get uiThePlayerIsAlreadyInThe;

  /// No description provided for @uiNoStandingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No standings available'**
  String get uiNoStandingsAvailable;

  /// No description provided for @uiTeams.
  ///
  /// In en, this message translates to:
  /// **'{a} teams'**
  String uiTeams(Object a);

  /// No description provided for @uiLeague.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get uiLeague;

  /// No description provided for @uiLeague2.
  ///
  /// In en, this message translates to:
  /// **'League {a}'**
  String uiLeague2(Object a);

  /// No description provided for @uiTheSeasonSInternalLeague.
  ///
  /// In en, this message translates to:
  /// **'The season\'s internal league'**
  String get uiTheSeasonSInternalLeague;

  /// No description provided for @uiYourOverallRanking.
  ///
  /// In en, this message translates to:
  /// **'Your overall ranking'**
  String get uiYourOverallRanking;

  /// No description provided for @uiMvpCardsAndFines.
  ///
  /// In en, this message translates to:
  /// **'MVP, cards and fines'**
  String get uiMvpCardsAndFines;

  /// No description provided for @uiTheSeasonDuel.
  ///
  /// In en, this message translates to:
  /// **'The season duel'**
  String get uiTheSeasonDuel;

  /// No description provided for @ui84Points.
  ///
  /// In en, this message translates to:
  /// **'84 points'**
  String get ui84Points;

  /// No description provided for @ui79Points.
  ///
  /// In en, this message translates to:
  /// **'79 points'**
  String get ui79Points;

  /// No description provided for @uiYou.
  ///
  /// In en, this message translates to:
  /// **'You?'**
  String get uiYou;

  /// No description provided for @uiPoints3.
  ///
  /// In en, this message translates to:
  /// **'? points'**
  String get uiPoints3;

  /// No description provided for @uiSeeTheCompetitions.
  ///
  /// In en, this message translates to:
  /// **'See the competitions'**
  String get uiSeeTheCompetitions;

  /// No description provided for @uiOverallPlayerOfTheMatchGoals.
  ///
  /// In en, this message translates to:
  /// **'Overall, player of the match, goals, assists, cards and fines in one internal season battle.'**
  String get uiOverallPlayerOfTheMatchGoals;

  /// No description provided for @uiTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get uiTitle;

  /// No description provided for @uiEGArrivedLate.
  ///
  /// In en, this message translates to:
  /// **'E.g. \"Arrived late\"'**
  String get uiEGArrivedLate;

  /// No description provided for @uiEG100.
  ///
  /// In en, this message translates to:
  /// **'E.g. 100'**
  String get uiEG100;

  /// No description provided for @uiEnterATitleForTheFine.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for the fine type'**
  String get uiEnterATitleForTheFine;

  /// No description provided for @uiEnterTheDefaultAmountForThe.
  ///
  /// In en, this message translates to:
  /// **'Enter the default amount for the fine type'**
  String get uiEnterTheDefaultAmountForThe;

  /// No description provided for @uiPleaseEnterATitleAndDefault.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title and default amount.'**
  String get uiPleaseEnterATitleAndDefault;

  /// No description provided for @uiTheFineTypeAlreadyExistsPlease.
  ///
  /// In en, this message translates to:
  /// **'The fine type already exists. Please enter another title.'**
  String get uiTheFineTypeAlreadyExistsPlease;

  /// No description provided for @uiRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get uiRegistrationFailed;

  /// No description provided for @uiYouHaveJoinedTheTeam.
  ///
  /// In en, this message translates to:
  /// **'You have joined the team!'**
  String get uiYouHaveJoinedTheTeam;

  /// No description provided for @uiBecomePartOf.
  ///
  /// In en, this message translates to:
  /// **'Become part of'**
  String get uiBecomePartOf;

  /// No description provided for @uiPleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get uiPleaseEnterYourPassword;

  /// No description provided for @uiPasswordMustBeAtLeast6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get uiPasswordMustBeAtLeast6;

  /// No description provided for @uiCreateAccount2.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get uiCreateAccount2;

  /// No description provided for @uiLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get uiLoginFailed;

  /// No description provided for @uiLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get uiLogIn;

  /// No description provided for @uiLogIn2.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get uiLogIn2;

  /// No description provided for @uiDonTHaveAnAccountSign.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up here'**
  String get uiDonTHaveAnAccountSign;

  /// No description provided for @uiNo.
  ///
  /// In en, this message translates to:
  /// **'No. -'**
  String get uiNo;

  /// No description provided for @uiMatchHistory.
  ///
  /// In en, this message translates to:
  /// **'Match history'**
  String get uiMatchHistory;

  /// No description provided for @uiNoMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found.'**
  String get uiNoMatchesFound;

  /// No description provided for @uiSeason.
  ///
  /// In en, this message translates to:
  /// **'Season {a}'**
  String uiSeason(Object a);

  /// No description provided for @uiLineup.
  ///
  /// In en, this message translates to:
  /// **'Lineup'**
  String get uiLineup;

  /// No description provided for @uiHideLineupFromPlayers.
  ///
  /// In en, this message translates to:
  /// **'Hide lineup from players'**
  String get uiHideLineupFromPlayers;

  /// No description provided for @uiShowLineupToPlayers.
  ///
  /// In en, this message translates to:
  /// **'Show lineup to players'**
  String get uiShowLineupToPlayers;

  /// No description provided for @uiNoBench.
  ///
  /// In en, this message translates to:
  /// **'No bench'**
  String get uiNoBench;

  /// No description provided for @uiOnTheBench.
  ///
  /// In en, this message translates to:
  /// **'On the bench:'**
  String get uiOnTheBench;

  /// No description provided for @uiGoalkeeper.
  ///
  /// In en, this message translates to:
  /// **'Goalkeeper'**
  String get uiGoalkeeper;

  /// No description provided for @uiDefence.
  ///
  /// In en, this message translates to:
  /// **'Defence'**
  String get uiDefence;

  /// No description provided for @uiMidfield.
  ///
  /// In en, this message translates to:
  /// **'Midfield'**
  String get uiMidfield;

  /// No description provided for @uiAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get uiAttack;

  /// No description provided for @uiNoEventsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No events recorded'**
  String get uiNoEventsRecorded;

  /// No description provided for @uiYellowCards.
  ///
  /// In en, this message translates to:
  /// **'Yellow cards'**
  String get uiYellowCards;

  /// No description provided for @uiRedCards.
  ///
  /// In en, this message translates to:
  /// **'Red cards'**
  String get uiRedCards;

  /// No description provided for @uiRegistered3.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get uiRegistered3;

  /// No description provided for @uiNoRegisteredPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No registered players yet.'**
  String get uiNoRegisteredPlayersYet;

  /// No description provided for @uiNoEventsRecorded2.
  ///
  /// In en, this message translates to:
  /// **'No events recorded.'**
  String get uiNoEventsRecorded2;

  /// No description provided for @uiPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get uiPoll;

  /// No description provided for @uiMatchRating.
  ///
  /// In en, this message translates to:
  /// **'Match rating'**
  String get uiMatchRating;

  /// No description provided for @uiMatchEvents.
  ///
  /// In en, this message translates to:
  /// **'Match events'**
  String get uiMatchEvents;

  /// No description provided for @uiNoMatchEventsRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No match events recorded yet.'**
  String get uiNoMatchEventsRecordedYet;

  /// No description provided for @ui3Months.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get ui3Months;

  /// No description provided for @uiSeason2.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get uiSeason2;

  /// No description provided for @uiAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get uiAll;

  /// No description provided for @uiCentreBack.
  ///
  /// In en, this message translates to:
  /// **'Centre back'**
  String get uiCentreBack;

  /// No description provided for @uiBackWingback.
  ///
  /// In en, this message translates to:
  /// **'Back / wingback'**
  String get uiBackWingback;

  /// No description provided for @uiDefensiveMidfield.
  ///
  /// In en, this message translates to:
  /// **'Defensive midfield'**
  String get uiDefensiveMidfield;

  /// No description provided for @uiAttackingMidfield.
  ///
  /// In en, this message translates to:
  /// **'Attacking midfield'**
  String get uiAttackingMidfield;

  /// No description provided for @uiWinger.
  ///
  /// In en, this message translates to:
  /// **'Winger'**
  String get uiWinger;

  /// No description provided for @uiStriker.
  ///
  /// In en, this message translates to:
  /// **'Striker'**
  String get uiStriker;

  /// No description provided for @uiStillToBePaid.
  ///
  /// In en, this message translates to:
  /// **'Still to be paid'**
  String get uiStillToBePaid;

  /// No description provided for @uiSelectedAmountToDeposit.
  ///
  /// In en, this message translates to:
  /// **'Selected amount to deposit'**
  String get uiSelectedAmountToDeposit;

  /// No description provided for @uiFineType.
  ///
  /// In en, this message translates to:
  /// **'Fine type'**
  String get uiFineType;

  /// No description provided for @uiPleaseChooseAFineToPay.
  ///
  /// In en, this message translates to:
  /// **'Please choose a fine to pay.'**
  String get uiPleaseChooseAFineToPay;

  /// No description provided for @uiAmountToDeposit.
  ///
  /// In en, this message translates to:
  /// **'Amount to deposit'**
  String get uiAmountToDeposit;

  /// No description provided for @uiPleaseEnterAnAmountGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount greater than 0 kr.'**
  String get uiPleaseEnterAnAmountGreaterThan;

  /// No description provided for @uiCouldNotFetchTheDbuImport.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the DBU import logic from the server.'**
  String get uiCouldNotFetchTheDbuImport;

  /// No description provided for @uiDbuLogin.
  ///
  /// In en, this message translates to:
  /// **'DBU login'**
  String get uiDbuLogin;

  /// No description provided for @uiSyncStandings.
  ///
  /// In en, this message translates to:
  /// **'Sync standings'**
  String get uiSyncStandings;

  /// No description provided for @uiLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get uiLoading;

  /// No description provided for @uiNoStatisticsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get uiNoStatisticsAvailable;

  /// No description provided for @uiCouldNotProcessTheRequest2.
  ///
  /// In en, this message translates to:
  /// **'Could not process the request.'**
  String get uiCouldNotProcessTheRequest2;

  /// No description provided for @uiTeamRequests.
  ///
  /// In en, this message translates to:
  /// **'Team requests'**
  String get uiTeamRequests;

  /// No description provided for @uiAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval ({a})'**
  String uiAwaitingApproval(Object a);

  /// No description provided for @uiNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get uiNewRequest;

  /// No description provided for @uiRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested {a}/{b}'**
  String uiRequested(Object a, Object b);

  /// No description provided for @uiAssignFines.
  ///
  /// In en, this message translates to:
  /// **'Assign fines'**
  String get uiAssignFines;

  /// No description provided for @uiNoFineTypesFound.
  ///
  /// In en, this message translates to:
  /// **'No fine types found.'**
  String get uiNoFineTypesFound;

  /// No description provided for @uiAddNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add note (optional)'**
  String get uiAddNoteOptional;

  /// No description provided for @uiNoFinesWereAssignedPleaseChoose.
  ///
  /// In en, this message translates to:
  /// **'No fines were assigned. Please choose at least one player.'**
  String get uiNoFinesWereAssignedPleaseChoose;

  /// No description provided for @uiPolls.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get uiPolls;

  /// No description provided for @uiCouldNotFetchPolls.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch polls.'**
  String get uiCouldNotFetchPolls;

  /// No description provided for @uiNoPollsFound.
  ///
  /// In en, this message translates to:
  /// **'No polls found.'**
  String get uiNoPollsFound;

  /// No description provided for @uiVotes2.
  ///
  /// In en, this message translates to:
  /// **'{a} votes'**
  String uiVotes2(Object a);

  /// No description provided for @uiUnknownMatch.
  ///
  /// In en, this message translates to:
  /// **'Unknown match'**
  String get uiUnknownMatch;

  /// No description provided for @uiTeamStats.
  ///
  /// In en, this message translates to:
  /// **'Team stats'**
  String get uiTeamStats;

  /// No description provided for @uiWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get uiWon;

  /// No description provided for @uiDrawn.
  ///
  /// In en, this message translates to:
  /// **'Drawn'**
  String get uiDrawn;

  /// No description provided for @uiLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get uiLost;

  /// No description provided for @uiGoalDifference.
  ///
  /// In en, this message translates to:
  /// **'Goal difference'**
  String get uiGoalDifference;

  /// No description provided for @uiCouldNotCreateThePoll.
  ///
  /// In en, this message translates to:
  /// **'Could not create the poll.'**
  String get uiCouldNotCreateThePoll;

  /// No description provided for @uiCastAtLeastOneVoteTo.
  ///
  /// In en, this message translates to:
  /// **'Cast at least one vote to save the poll.'**
  String get uiCastAtLeastOneVoteTo;

  /// No description provided for @uiCouldNotSaveThePoll.
  ///
  /// In en, this message translates to:
  /// **'Could not save the poll.'**
  String get uiCouldNotSaveThePoll;

  /// No description provided for @uiThereAreNoMatchesToCreate.
  ///
  /// In en, this message translates to:
  /// **'There are no matches to create a poll for.'**
  String get uiThereAreNoMatchesToCreate;

  /// No description provided for @uiChooseAValidMatch.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid match.'**
  String get uiChooseAValidMatch;

  /// No description provided for @uiAPollAlreadyExistsForThe.
  ///
  /// In en, this message translates to:
  /// **'A poll already exists for the match. Choose another match.'**
  String get uiAPollAlreadyExistsForThe;

  /// No description provided for @uiCastAtLeastOneVoteTo2.
  ///
  /// In en, this message translates to:
  /// **'Cast at least one vote to create a poll.'**
  String get uiCastAtLeastOneVoteTo2;

  /// No description provided for @uiKopaCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Kopa could not start.'**
  String get uiKopaCouldNotStart;

  /// No description provided for @uiOpenMatch.
  ///
  /// In en, this message translates to:
  /// **'Open match: {a}'**
  String uiOpenMatch(Object a);

  /// No description provided for @uiFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get uiFinished;

  /// No description provided for @uiBringYourTeamNtogether.
  ///
  /// In en, this message translates to:
  /// **'Bring your team\ntogether'**
  String get uiBringYourTeamNtogether;

  /// No description provided for @uiMyStats.
  ///
  /// In en, this message translates to:
  /// **'My stats'**
  String get uiMyStats;

  /// No description provided for @uiCardsYR.
  ///
  /// In en, this message translates to:
  /// **'Cards (Y/R)'**
  String get uiCardsYR;

  /// No description provided for @uiShowFullTable.
  ///
  /// In en, this message translates to:
  /// **'SHOW FULL TABLE'**
  String get uiShowFullTable;

  /// No description provided for @uiTheFineBox.
  ///
  /// In en, this message translates to:
  /// **'THE FINE BOX'**
  String get uiTheFineBox;

  /// No description provided for @uiTotalFines.
  ///
  /// In en, this message translates to:
  /// **'Total fines'**
  String get uiTotalFines;

  /// No description provided for @uiNoRanking.
  ///
  /// In en, this message translates to:
  /// **'No ranking'**
  String get uiNoRanking;

  /// No description provided for @uiSomethingWentWrongDuringLoginTry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong during login. Try again.'**
  String get uiSomethingWentWrongDuringLoginTry;

  /// No description provided for @uiSomethingWentWrongDuringRegistrationTry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong during registration. Try again.'**
  String get uiSomethingWentWrongDuringRegistrationTry;

  /// No description provided for @uiAddNewPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add new player'**
  String get uiAddNewPlayer;

  /// No description provided for @uiCouldNotFetchSeasons.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch seasons'**
  String get uiCouldNotFetchSeasons;

  /// No description provided for @uiCouldNotStartANewSeason.
  ///
  /// In en, this message translates to:
  /// **'Could not start a new season'**
  String get uiCouldNotStartANewSeason;

  /// No description provided for @uiUpdateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get uiUpdateRequired;

  /// No description provided for @uiANewVersionOfKopaIs.
  ///
  /// In en, this message translates to:
  /// **'A new version of Kopa is available. Please update to continue.'**
  String get uiANewVersionOfKopaIs;

  /// No description provided for @uiUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get uiUpdateNow;

  /// No description provided for @uiMatchSchedule.
  ///
  /// In en, this message translates to:
  /// **'Match schedule'**
  String get uiMatchSchedule;

  /// No description provided for @uiNoDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get uiNoDataAvailable;

  /// No description provided for @uiWin.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get uiWin;

  /// No description provided for @uiDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get uiDraw;

  /// No description provided for @uiLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get uiLoss;

  /// No description provided for @uiLoginFailedPleaseCheckYourCredentials.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get uiLoginFailedPleaseCheckYourCredentials;

  /// No description provided for @uiRegistrationFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get uiRegistrationFailedPleaseTryAgain;

  /// No description provided for @uiOutstandingFines.
  ///
  /// In en, this message translates to:
  /// **'Outstanding fines'**
  String get uiOutstandingFines;

  /// No description provided for @uiTrainingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Training attendance'**
  String get uiTrainingAttendance;

  /// No description provided for @uiNotSelectedYet.
  ///
  /// In en, this message translates to:
  /// **'Not selected yet'**
  String get uiNotSelectedYet;

  /// No description provided for @uiVotes3.
  ///
  /// In en, this message translates to:
  /// **'Votes: {a}'**
  String uiVotes3(Object a);

  /// No description provided for @uiCouldNotFetchTheMatchSchedule.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the match schedule.'**
  String get uiCouldNotFetchTheMatchSchedule;

  /// No description provided for @uiFormLast5.
  ///
  /// In en, this message translates to:
  /// **'Form (last 5)'**
  String get uiFormLast5;

  /// No description provided for @uiNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get uiNotAssigned;

  /// No description provided for @uiCouldNotFetchInForm.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch In-form.'**
  String get uiCouldNotFetchInForm;

  /// No description provided for @uiTeamBadge.
  ///
  /// In en, this message translates to:
  /// **'{a} team badge'**
  String uiTeamBadge(Object a);

  /// No description provided for @uiShield7.
  ///
  /// In en, this message translates to:
  /// **'Shield 7'**
  String get uiShield7;

  /// No description provided for @uiTeamLeaderNames.
  ///
  /// In en, this message translates to:
  /// **'Team leader: {a}'**
  String uiTeamLeaderNames(Object a);

  /// No description provided for @uiLandingIntro.
  ///
  /// In en, this message translates to:
  /// **'Get a full overview of your matches, lineups, fine box and team communication.'**
  String get uiLandingIntro;

  /// No description provided for @uiNewSeasonBody.
  ///
  /// In en, this message translates to:
  /// **'There is already an active season. You can update the current match schedule or start a new season before importing the new DBU schedule. If results are missing from the active season, Kopa warns you before the season starts.'**
  String get uiNewSeasonBody;

  /// No description provided for @uiMissingResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Results are missing for {a} {b} in the active season. You can still start a new season, but the old matches will be locked to the finished season without full results.'**
  String uiMissingResultsBody(Object a, Object b);

  /// No description provided for @uiOneEvent.
  ///
  /// In en, this message translates to:
  /// **'{a} event'**
  String uiOneEvent(Object a);

  /// No description provided for @uiManyEvents.
  ///
  /// In en, this message translates to:
  /// **'{a} events'**
  String uiManyEvents(Object a);

  /// No description provided for @uiOneMatch.
  ///
  /// In en, this message translates to:
  /// **'{a} match'**
  String uiOneMatch(Object a);

  /// No description provided for @uiManyMatches.
  ///
  /// In en, this message translates to:
  /// **'{a} matches'**
  String uiManyMatches(Object a);

  /// No description provided for @uiMatchSingular.
  ///
  /// In en, this message translates to:
  /// **'match'**
  String get uiMatchSingular;

  /// No description provided for @uiMatchPlural.
  ///
  /// In en, this message translates to:
  /// **'matches'**
  String get uiMatchPlural;

  /// No description provided for @uiWeekdayInitials.
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get uiWeekdayInitials;

  /// No description provided for @uiPositionLeftBack.
  ///
  /// In en, this message translates to:
  /// **'Left back'**
  String get uiPositionLeftBack;

  /// No description provided for @uiPositionCentreBack.
  ///
  /// In en, this message translates to:
  /// **'Centre back'**
  String get uiPositionCentreBack;

  /// No description provided for @uiPositionRightBack.
  ///
  /// In en, this message translates to:
  /// **'Right back'**
  String get uiPositionRightBack;

  /// No description provided for @uiPositionLeftMidfield.
  ///
  /// In en, this message translates to:
  /// **'Left midfield'**
  String get uiPositionLeftMidfield;

  /// No description provided for @uiPositionCentralMidfield.
  ///
  /// In en, this message translates to:
  /// **'Central midfield'**
  String get uiPositionCentralMidfield;

  /// No description provided for @uiPositionRightMidfield.
  ///
  /// In en, this message translates to:
  /// **'Right midfield'**
  String get uiPositionRightMidfield;

  /// No description provided for @uiPositionLeftWing.
  ///
  /// In en, this message translates to:
  /// **'Left wing'**
  String get uiPositionLeftWing;

  /// No description provided for @uiPositionRightWing.
  ///
  /// In en, this message translates to:
  /// **'Right wing'**
  String get uiPositionRightWing;

  /// No description provided for @uiPositionShortGoalkeeper.
  ///
  /// In en, this message translates to:
  /// **'GK'**
  String get uiPositionShortGoalkeeper;

  /// No description provided for @uiPositionShortLeftBack.
  ///
  /// In en, this message translates to:
  /// **'LB'**
  String get uiPositionShortLeftBack;

  /// No description provided for @uiPositionShortRightBack.
  ///
  /// In en, this message translates to:
  /// **'RB'**
  String get uiPositionShortRightBack;

  /// No description provided for @uiPositionShortLeftMidfield.
  ///
  /// In en, this message translates to:
  /// **'LM'**
  String get uiPositionShortLeftMidfield;

  /// No description provided for @uiPositionShortRightMidfield.
  ///
  /// In en, this message translates to:
  /// **'RM'**
  String get uiPositionShortRightMidfield;

  /// No description provided for @uiPositionShortLeftWing.
  ///
  /// In en, this message translates to:
  /// **'LW'**
  String get uiPositionShortLeftWing;

  /// No description provided for @uiPositionShortRightWing.
  ///
  /// In en, this message translates to:
  /// **'RW'**
  String get uiPositionShortRightWing;

  /// No description provided for @uiPositionShortDefender.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get uiPositionShortDefender;

  /// No description provided for @uiPositionShortWing.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get uiPositionShortWing;

  /// No description provided for @uiPositionShortForward.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get uiPositionShortForward;

  /// No description provided for @uiPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get uiPointsLabel;

  /// No description provided for @uiPlayerPlusIntro.
  ///
  /// In en, this message translates to:
  /// **'Who becomes the team\'s best player, who wins player of the match most often, and who ends up on top of the fun tables? Use this page as an overview of the Player+ universe.'**
  String get uiPlayerPlusIntro;

  /// No description provided for @uiStartupFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Kopa could not start.\n{a}'**
  String uiStartupFailedWithError(Object a);

  /// No description provided for @uiFindingNextSeason.
  ///
  /// In en, this message translates to:
  /// **'Looking for the team\'s next season on DBU…'**
  String get uiFindingNextSeason;

  /// No description provided for @uiNextSeasonFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Next season found'**
  String get uiNextSeasonFoundTitle;

  /// No description provided for @uiNextSeasonFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We found the team\'s next tournament on DBU, based on the season you just played. Choose it to start the new season and import its match schedule.'**
  String get uiNextSeasonFoundBody;

  /// No description provided for @uiNextSeasonMatches.
  ///
  /// In en, this message translates to:
  /// **'{count} matches · first match {date}'**
  String uiNextSeasonMatches(int count, String date);

  /// No description provided for @uiFindOnDbuMyself.
  ///
  /// In en, this message translates to:
  /// **'Find it on DBU myself'**
  String get uiFindOnDbuMyself;

  /// No description provided for @matchSeasonPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose season'**
  String get matchSeasonPickerTitle;

  /// No description provided for @matchSeasonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get matchSeasonActive;

  /// No description provided for @matchSeasonPreviousSeasons.
  ///
  /// In en, this message translates to:
  /// **'Previous seasons'**
  String get matchSeasonPreviousSeasons;

  /// No description provided for @matchSeasonFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished season'**
  String get matchSeasonFinished;

  /// No description provided for @matchSeasonViewingRange.
  ///
  /// In en, this message translates to:
  /// **'Showing matches from {range}'**
  String matchSeasonViewingRange(String range);

  /// No description provided for @matchSeasonBackToCurrent.
  ///
  /// In en, this message translates to:
  /// **'Back to current'**
  String get matchSeasonBackToCurrent;

  /// No description provided for @matchSeasonStartedOn.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String matchSeasonStartedOn(String date);

  /// No description provided for @matchSeasonSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Season {name}. Change season'**
  String matchSeasonSelectorLabel(String name);

  /// No description provided for @matchSeasonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get matchSeasonClose;

  /// No description provided for @matchSeasonNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches in this season.'**
  String get matchSeasonNoMatches;

  /// No description provided for @matchSeasonSummaryMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchSeasonSummaryMatches;

  /// No description provided for @matchSeasonSummaryWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get matchSeasonSummaryWon;

  /// No description provided for @matchSeasonSummaryDrawn.
  ///
  /// In en, this message translates to:
  /// **'Drawn'**
  String get matchSeasonSummaryDrawn;

  /// No description provided for @matchSeasonSummaryLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get matchSeasonSummaryLost;

  /// No description provided for @resultLetterWin.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get resultLetterWin;

  /// No description provided for @resultLetterDraw.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get resultLetterDraw;

  /// No description provided for @resultLetterLoss.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get resultLetterLoss;

  /// No description provided for @statisticsInFormTitle.
  ///
  /// In en, this message translates to:
  /// **'In-form'**
  String get statisticsInFormTitle;

  /// No description provided for @statisticsAssists.
  ///
  /// In en, this message translates to:
  /// **'Assists'**
  String get statisticsAssists;

  /// No description provided for @statisticsFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get statisticsFormTitle;

  /// No description provided for @statisticsFormHint.
  ///
  /// In en, this message translates to:
  /// **'Last {count} · newest on the right'**
  String statisticsFormHint(int count);

  /// No description provided for @statisticsNoFormYet.
  ///
  /// In en, this message translates to:
  /// **'No matches played yet.'**
  String get statisticsNoFormYet;

  /// No description provided for @inFormCategoryOffensive.
  ///
  /// In en, this message translates to:
  /// **'Offensive'**
  String get inFormCategoryOffensive;

  /// No description provided for @inFormCategoryDefensive.
  ///
  /// In en, this message translates to:
  /// **'Defensive'**
  String get inFormCategoryDefensive;

  /// No description provided for @inFormCategoryTeamResult.
  ///
  /// In en, this message translates to:
  /// **'Team result'**
  String get inFormCategoryTeamResult;

  /// No description provided for @inFormCategoryDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get inFormCategoryDiscipline;

  /// No description provided for @inFormCategoryParticipation.
  ///
  /// In en, this message translates to:
  /// **'Participation & honours'**
  String get inFormCategoryParticipation;

  /// No description provided for @inFormCategoryBonus.
  ///
  /// In en, this message translates to:
  /// **'Streaks & bonuses'**
  String get inFormCategoryBonus;

  /// No description provided for @inFormCategoryOffensiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Goals, assists and other attacking actions.'**
  String get inFormCategoryOffensiveDescription;

  /// No description provided for @inFormCategoryDefensiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Clean sheets, goals conceded and penalty saves.'**
  String get inFormCategoryDefensiveDescription;

  /// No description provided for @inFormCategoryTeamResultDescription.
  ///
  /// In en, this message translates to:
  /// **'Points for how the team did as a whole.'**
  String get inFormCategoryTeamResultDescription;

  /// No description provided for @inFormCategoryDisciplineDescription.
  ///
  /// In en, this message translates to:
  /// **'Cards and other disciplinary incidents.'**
  String get inFormCategoryDisciplineDescription;

  /// No description provided for @inFormCategoryParticipationDescription.
  ///
  /// In en, this message translates to:
  /// **'Playing, man of the match votes and awards.'**
  String get inFormCategoryParticipationDescription;

  /// No description provided for @inFormCategoryBonusDescription.
  ///
  /// In en, this message translates to:
  /// **'Extra points for streaks, form runs and monthly or season awards.'**
  String get inFormCategoryBonusDescription;

  /// No description provided for @inFormColumnPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get inFormColumnPlayer;

  /// No description provided for @inFormColumnLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get inFormColumnLatest;

  /// No description provided for @inFormColumnToFirst.
  ///
  /// In en, this message translates to:
  /// **'To #1'**
  String get inFormColumnToFirst;

  /// No description provided for @inFormColumnTotal.
  ///
  /// In en, this message translates to:
  /// **'Pts'**
  String get inFormColumnTotal;

  /// No description provided for @inFormPointsSystem.
  ///
  /// In en, this message translates to:
  /// **'Points system'**
  String get inFormPointsSystem;

  /// No description provided for @inFormPointsSystemIntro.
  ///
  /// In en, this message translates to:
  /// **'Your points depend on the position you played. Defenders earn more for clean sheets, attackers for goals and assists.'**
  String get inFormPointsSystemIntro;

  /// No description provided for @inFormPointsSystemExtras.
  ///
  /// In en, this message translates to:
  /// **'On top of this come streaks and form bonuses, plus monthly and season awards.'**
  String get inFormPointsSystemExtras;

  /// No description provided for @inFormMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get inFormMatches;

  /// No description provided for @inFormGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get inFormGoals;

  /// No description provided for @inFormAssists.
  ///
  /// In en, this message translates to:
  /// **'Assists'**
  String get inFormAssists;

  /// No description provided for @inFormCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get inFormCards;

  /// No description provided for @inFormMotm.
  ///
  /// In en, this message translates to:
  /// **'MOTM'**
  String get inFormMotm;

  /// No description provided for @inFormAverage.
  ///
  /// In en, this message translates to:
  /// **'Avg.'**
  String get inFormAverage;

  /// No description provided for @inFormBonuses.
  ///
  /// In en, this message translates to:
  /// **'Bonuses'**
  String get inFormBonuses;

  /// No description provided for @inFormHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get inFormHome;

  /// No description provided for @inFormAway.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get inFormAway;

  /// No description provided for @inFormUnknownOpponent.
  ///
  /// In en, this message translates to:
  /// **'Unknown opponent'**
  String get inFormUnknownOpponent;

  /// No description provided for @inFormPlayedAs.
  ///
  /// In en, this message translates to:
  /// **'Played as {position}'**
  String inFormPlayedAs(String position);

  /// No description provided for @inFormPositionChanged.
  ///
  /// In en, this message translates to:
  /// **'changed for this match'**
  String get inFormPositionChanged;

  /// No description provided for @inFormEditMatch.
  ///
  /// In en, this message translates to:
  /// **'Edit match data'**
  String get inFormEditMatch;

  /// No description provided for @inFormChangePosition.
  ///
  /// In en, this message translates to:
  /// **'Change position'**
  String get inFormChangePosition;

  /// No description provided for @inFormMatchPosition.
  ///
  /// In en, this message translates to:
  /// **'Position in this match'**
  String get inFormMatchPosition;

  /// No description provided for @inFormMatchPositionHint.
  ///
  /// In en, this message translates to:
  /// **'Played a different position than usual? Pick it here so your points match.'**
  String get inFormMatchPositionHint;

  /// No description provided for @inFormUseProfilePosition.
  ///
  /// In en, this message translates to:
  /// **'Normal position'**
  String get inFormUseProfilePosition;

  /// No description provided for @inFormMatchDataPoints.
  ///
  /// In en, this message translates to:
  /// **'Data points'**
  String get inFormMatchDataPoints;

  /// No description provided for @inFormMatchDataPointsHint.
  ///
  /// In en, this message translates to:
  /// **'Things the match timeline can\'t show. The decisive goal is worked out automatically, so only change it if it\'s wrong.'**
  String get inFormMatchDataPointsHint;

  /// No description provided for @inFormOwnGoals.
  ///
  /// In en, this message translates to:
  /// **'Own goals'**
  String get inFormOwnGoals;

  /// No description provided for @inFormPenaltiesMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed penalties'**
  String get inFormPenaltiesMissed;

  /// No description provided for @inFormPenaltiesSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved penalties'**
  String get inFormPenaltiesSaved;

  /// No description provided for @inFormDecisiveGoals.
  ///
  /// In en, this message translates to:
  /// **'Decisive goals'**
  String get inFormDecisiveGoals;

  /// No description provided for @inFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get inFormSave;

  /// No description provided for @inFormSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get inFormSaveFailed;

  /// No description provided for @inFormSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved – points updated'**
  String get inFormSaved;

  /// No description provided for @inFormSeeHowPointsWork.
  ///
  /// In en, this message translates to:
  /// **'How points work'**
  String get inFormSeeHowPointsWork;

  /// No description provided for @inFormPointsSystemLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the points system.'**
  String get inFormPointsSystemLoadFailed;

  /// No description provided for @seasonOverEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Season over'**
  String get seasonOverEyebrow;

  /// No description provided for @seasonOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Good game, everyone!'**
  String get seasonOverTitle;

  /// No description provided for @seasonEmptyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get seasonEmptyEyebrow;

  /// No description provided for @seasonEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for kick-off'**
  String get seasonEmptyTitle;

  /// No description provided for @seasonRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'The season in numbers'**
  String get seasonRecapTitle;

  /// No description provided for @seasonRecapMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get seasonRecapMatches;

  /// No description provided for @seasonRecapRecord.
  ///
  /// In en, this message translates to:
  /// **'W-D-L'**
  String get seasonRecapRecord;

  /// No description provided for @seasonRecapGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get seasonRecapGoals;

  /// No description provided for @seasonChecking.
  ///
  /// In en, this message translates to:
  /// **'Looking for the next season on DBU…'**
  String get seasonChecking;

  /// No description provided for @seasonWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the next season'**
  String get seasonWaitingTitle;

  /// No description provided for @seasonWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'DBU hasn\'t published your next tournament yet. We check every day and let you know as soon as it\'s ready.'**
  String get seasonWaitingBody;

  /// No description provided for @seasonLastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked {time}'**
  String seasonLastChecked(String time);

  /// No description provided for @seasonCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get seasonCheckAgain;

  /// No description provided for @seasonImportAnyway.
  ///
  /// In en, this message translates to:
  /// **'I know it\'s there, import anyway'**
  String get seasonImportAnyway;

  /// No description provided for @seasonReadyBadge.
  ///
  /// In en, this message translates to:
  /// **'New season ready'**
  String get seasonReadyBadge;

  /// No description provided for @seasonReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next season is on DBU'**
  String get seasonReadyTitle;

  /// No description provided for @seasonReadyMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{First match {date}} =1{1 match · first {date}} other{{count} matches · first {date}}}'**
  String seasonReadyMatches(int count, String date);

  /// No description provided for @seasonStartNew.
  ///
  /// In en, this message translates to:
  /// **'Start new season'**
  String get seasonStartNew;

  /// No description provided for @seasonNotThisOne.
  ///
  /// In en, this message translates to:
  /// **'Not the right one? Find it on DBU'**
  String get seasonNotThisOne;

  /// No description provided for @seasonManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for a new season?'**
  String get seasonManualTitle;

  /// No description provided for @seasonManualBody.
  ///
  /// In en, this message translates to:
  /// **'Import the match schedule from DBU to start the next season.'**
  String get seasonManualBody;

  /// No description provided for @wrappedMissingResultEyebrow.
  ///
  /// In en, this message translates to:
  /// **'The season is almost over'**
  String get wrappedMissingResultEyebrow;

  /// No description provided for @wrappedMissingResultTitle.
  ///
  /// In en, this message translates to:
  /// **'One result is missing'**
  String get wrappedMissingResultTitle;

  /// No description provided for @wrappedMissingResultBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the result of the last match, then we can wrap up your season.'**
  String get wrappedMissingResultBody;

  /// No description provided for @wrappedMissingResultMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more match is missing a result} other{{count} more matches are missing a result}}'**
  String wrappedMissingResultMore(int count);

  /// No description provided for @wrappedEnterResult.
  ///
  /// In en, this message translates to:
  /// **'Enter result'**
  String get wrappedEnterResult;

  /// No description provided for @wrappedMissingResultPlayerHint.
  ///
  /// In en, this message translates to:
  /// **'The team leader enters the result, then your Season Wrapped is ready.'**
  String get wrappedMissingResultPlayerHint;

  /// No description provided for @wrappedTeaserEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Season Wrapped'**
  String get wrappedTeaserEyebrow;

  /// No description provided for @wrappedTeaserTitle.
  ///
  /// In en, this message translates to:
  /// **'Your season is wrapped'**
  String get wrappedTeaserTitle;

  /// No description provided for @wrappedTeaserBody.
  ///
  /// In en, this message translates to:
  /// **'Top scorer, man of the match and your own season.'**
  String get wrappedTeaserBody;

  /// No description provided for @wrappedTeaserCta.
  ///
  /// In en, this message translates to:
  /// **'Watch your Wrapped'**
  String get wrappedTeaserCta;

  /// No description provided for @wrappedSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip – go to the next season'**
  String get wrappedSkip;

  /// No description provided for @wrappedWatchAgain.
  ///
  /// In en, this message translates to:
  /// **'Watch your Season Wrapped again'**
  String get wrappedWatchAgain;

  /// No description provided for @wrappedProgress.
  ///
  /// In en, this message translates to:
  /// **'Season Wrapped · {current}/{total}'**
  String wrappedProgress(int current, int total);

  /// No description provided for @wrappedClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get wrappedClose;

  /// No description provided for @wrappedCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize Wrapped'**
  String get wrappedCustomize;

  /// No description provided for @wrappedPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous slide'**
  String get wrappedPrevious;

  /// No description provided for @wrappedNext.
  ///
  /// In en, this message translates to:
  /// **'Next slide'**
  String get wrappedNext;

  /// No description provided for @wrappedIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your season,\nwrapped\nup.'**
  String get wrappedIntroTitle;

  /// No description provided for @wrappedIntroBody.
  ///
  /// In en, this message translates to:
  /// **'{matches, plural, =1{1 match} other{{matches} matches}}. {goals} goals. One team. Let\'s look back.'**
  String wrappedIntroBody(int matches, int goals);

  /// No description provided for @wrappedTapToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue →'**
  String get wrappedTapToContinue;

  /// No description provided for @wrappedTeamEyebrow.
  ///
  /// In en, this message translates to:
  /// **'The team in numbers'**
  String get wrappedTeamEyebrow;

  /// No description provided for @wrappedTeamWinsLabel.
  ///
  /// In en, this message translates to:
  /// **'wins\nin {played} matches'**
  String wrappedTeamWinsLabel(int played);

  /// No description provided for @wrappedTeamDrawsLosses.
  ///
  /// In en, this message translates to:
  /// **'{draws} draws · {losses} losses'**
  String wrappedTeamDrawsLosses(int draws, int losses);

  /// No description provided for @wrappedGoalsFor.
  ///
  /// In en, this message translates to:
  /// **'goals scored'**
  String get wrappedGoalsFor;

  /// No description provided for @wrappedGoalsAgainst.
  ///
  /// In en, this message translates to:
  /// **'goals conceded'**
  String get wrappedGoalsAgainst;

  /// No description provided for @wrappedLastFive.
  ///
  /// In en, this message translates to:
  /// **'Last matches'**
  String get wrappedLastFive;

  /// No description provided for @wrappedFormWin.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wrappedFormWin;

  /// No description provided for @wrappedFormDraw.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get wrappedFormDraw;

  /// No description provided for @wrappedFormLoss.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get wrappedFormLoss;

  /// No description provided for @wrappedBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best run: {count} wins in a row.'**
  String wrappedBestStreak(int count);

  /// No description provided for @wrappedYouEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your season, {name}'**
  String wrappedYouEyebrow(String name);

  /// No description provided for @wrappedMatchesPlayed.
  ///
  /// In en, this message translates to:
  /// **'matches played'**
  String get wrappedMatchesPlayed;

  /// No description provided for @wrappedGoals.
  ///
  /// In en, this message translates to:
  /// **'goals'**
  String get wrappedGoals;

  /// No description provided for @wrappedAssists.
  ///
  /// In en, this message translates to:
  /// **'assists'**
  String get wrappedAssists;

  /// No description provided for @wrappedTraining.
  ///
  /// In en, this message translates to:
  /// **'training'**
  String get wrappedTraining;

  /// No description provided for @wrappedYouTopAttendance.
  ///
  /// In en, this message translates to:
  /// **'Nobody played more matches than you.'**
  String get wrappedYouTopAttendance;

  /// No description provided for @wrappedYouMoreMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Only one player played more matches than you.} other{Only {count} players played more matches than you.}}'**
  String wrappedYouMoreMatches(int count);

  /// No description provided for @wrappedFormEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Kopa form'**
  String get wrappedFormEyebrow;

  /// No description provided for @wrappedFormYouFinished.
  ///
  /// In en, this message translates to:
  /// **'You finished'**
  String get wrappedFormYouFinished;

  /// No description provided for @wrappedFormOfPlayers.
  ///
  /// In en, this message translates to:
  /// **'of {count}\nplayers'**
  String wrappedFormOfPlayers(int count);

  /// No description provided for @wrappedFormWinner.
  ///
  /// In en, this message translates to:
  /// **'{name} won Kopa form'**
  String wrappedFormWinner(String name);

  /// No description provided for @wrappedYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get wrappedYouSuffix;

  /// No description provided for @wrappedGoalsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Top scorer'**
  String get wrappedGoalsEyebrow;

  /// No description provided for @wrappedGoalsLine.
  ///
  /// In en, this message translates to:
  /// **'{goals} goals · {percent}% of the team\'s goals'**
  String wrappedGoalsLine(int goals, int percent);

  /// No description provided for @wrappedAssistsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Assist king'**
  String get wrappedAssistsEyebrow;

  /// No description provided for @wrappedAssistsLine.
  ///
  /// In en, this message translates to:
  /// **'{count} assists for teammates'**
  String wrappedAssistsLine(int count);

  /// No description provided for @wrappedDuoTitle.
  ///
  /// In en, this message translates to:
  /// **'Duo of the season'**
  String get wrappedDuoTitle;

  /// No description provided for @wrappedDuoGoals.
  ///
  /// In en, this message translates to:
  /// **'{count} goals together'**
  String wrappedDuoGoals(int count);

  /// No description provided for @wrappedMotmEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Man of the match'**
  String get wrappedMotmEyebrow;

  /// No description provided for @wrappedMotmLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{voted best once by the team} other{voted best {count} times by the team}}'**
  String wrappedMotmLine(int count);

  /// No description provided for @wrappedSeasonMatches.
  ///
  /// In en, this message translates to:
  /// **'The season\'s {count} matches'**
  String wrappedSeasonMatches(int count);

  /// No description provided for @wrappedIronEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Iron man'**
  String get wrappedIronEyebrow;

  /// No description provided for @wrappedIronAll.
  ///
  /// In en, this message translates to:
  /// **'Played every single match.'**
  String get wrappedIronAll;

  /// No description provided for @wrappedIronMost.
  ///
  /// In en, this message translates to:
  /// **'Played the most matches.'**
  String get wrappedIronMost;

  /// No description provided for @wrappedFinesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Fine king'**
  String get wrappedFinesEyebrow;

  /// No description provided for @wrappedFinesLine.
  ///
  /// In en, this message translates to:
  /// **'into the fine box this season'**
  String get wrappedFinesLine;

  /// No description provided for @wrappedFinesTotal.
  ///
  /// In en, this message translates to:
  /// **'The team collected {amount} in total.'**
  String wrappedFinesTotal(String amount);

  /// No description provided for @wrappedCardsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Card king'**
  String get wrappedCardsEyebrow;

  /// No description provided for @wrappedCardsLine.
  ///
  /// In en, this message translates to:
  /// **'{yellow} yellow · {red} red'**
  String wrappedCardsLine(int yellow, int red);

  /// No description provided for @wrappedCardsFooter.
  ///
  /// In en, this message translates to:
  /// **'The referee\'s best friend.'**
  String get wrappedCardsFooter;

  /// No description provided for @wrappedLanternEyebrow.
  ///
  /// In en, this message translates to:
  /// **'The red lantern'**
  String get wrappedLanternEyebrow;

  /// No description provided for @wrappedLanternLine.
  ///
  /// In en, this message translates to:
  /// **'no. {rank} of {count} in Kopa form'**
  String wrappedLanternLine(int rank, int count);

  /// No description provided for @wrappedLanternFooter.
  ///
  /// In en, this message translates to:
  /// **'Someone has to keep the lantern lit. Next season is a new chance.'**
  String get wrappedLanternFooter;

  /// No description provided for @wrappedOutroTitle.
  ///
  /// In en, this message translates to:
  /// **'Awards of the season'**
  String get wrappedOutroTitle;

  /// No description provided for @wrappedOutroYou.
  ///
  /// In en, this message translates to:
  /// **'Your season'**
  String get wrappedOutroYou;

  /// No description provided for @wrappedOutroYouLine.
  ///
  /// In en, this message translates to:
  /// **'{goals} goals · {assists} assists'**
  String wrappedOutroYouLine(int goals, int assists);

  /// No description provided for @wrappedShare.
  ///
  /// In en, this message translates to:
  /// **'Share your Wrapped'**
  String get wrappedShare;

  /// No description provided for @wrappedShareText.
  ///
  /// In en, this message translates to:
  /// **'Our season in Kopa'**
  String get wrappedShareText;

  /// No description provided for @wrappedContinue.
  ///
  /// In en, this message translates to:
  /// **'On to the next season'**
  String get wrappedContinue;

  /// No description provided for @wrappedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'What goes in the Wrapped?'**
  String get wrappedSettingsTitle;

  /// No description provided for @wrappedSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'We found the categories your team has data for. Switch off the ones you don\'t want.'**
  String get wrappedSettingsBody;

  /// No description provided for @wrappedSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get wrappedSettingsSave;

  /// No description provided for @wrappedSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get wrappedSettingsError;

  /// No description provided for @wrappedSettingsNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data this season'**
  String get wrappedSettingsNoData;

  /// No description provided for @wrappedDetailForm.
  ///
  /// In en, this message translates to:
  /// **'{count} players with Kopa form points'**
  String wrappedDetailForm(int count);

  /// No description provided for @wrappedDetailGoals.
  ///
  /// In en, this message translates to:
  /// **'{count} goals recorded'**
  String wrappedDetailGoals(int count);

  /// No description provided for @wrappedDetailAssists.
  ///
  /// In en, this message translates to:
  /// **'{count} assists recorded'**
  String wrappedDetailAssists(int count);

  /// No description provided for @wrappedDetailMotm.
  ///
  /// In en, this message translates to:
  /// **'Votes in {count} matches'**
  String wrappedDetailMotm(int count);

  /// No description provided for @wrappedDetailIron.
  ///
  /// In en, this message translates to:
  /// **'Most matches: {count}'**
  String wrappedDetailIron(int count);

  /// No description provided for @wrappedDetailFines.
  ///
  /// In en, this message translates to:
  /// **'{amount} in fines'**
  String wrappedDetailFines(String amount);

  /// No description provided for @wrappedDetailCards.
  ///
  /// In en, this message translates to:
  /// **'{count} cards recorded'**
  String wrappedDetailCards(int count);

  /// No description provided for @wrappedDetailLantern.
  ///
  /// In en, this message translates to:
  /// **'Fun award · last in Kopa form'**
  String get wrappedDetailLantern;

  /// No description provided for @fineBoxMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get fineBoxMarkPaid;

  /// No description provided for @fineBoxMarkPaidBody.
  ///
  /// In en, this message translates to:
  /// **'Mark {fine} for {name} as paid? The amount goes into the fine box.'**
  String fineBoxMarkPaidBody(String fine, String name);

  /// No description provided for @fineBoxMarkAllPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark all as paid ({amount})'**
  String fineBoxMarkAllPaid(String amount);

  /// No description provided for @fineBoxMarkAllPaidBody.
  ///
  /// In en, this message translates to:
  /// **'Mark all of {name}\'s unpaid fines ({amount}) as paid? The amount goes into the fine box.'**
  String fineBoxMarkAllPaidBody(String name, String amount);

  /// No description provided for @fineBoxMarkPaidFailed.
  ///
  /// In en, this message translates to:
  /// **'The fine could not be marked as paid. Try again.'**
  String get fineBoxMarkPaidFailed;

  /// No description provided for @homeNextTraining.
  ///
  /// In en, this message translates to:
  /// **'Next training'**
  String get homeNextTraining;

  /// No description provided for @wrappedAssistsLeaders.
  ///
  /// In en, this message translates to:
  /// **'Most assists'**
  String get wrappedAssistsLeaders;

  /// No description provided for @settingsSectionMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get settingsSectionMatches;

  /// No description provided for @settingsSectionSeason.
  ///
  /// In en, this message translates to:
  /// **'Season & DBU'**
  String get settingsSectionSeason;

  /// No description provided for @settingsSectionTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get settingsSectionTeam;

  /// No description provided for @settingsSectionMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get settingsSectionMe;

  /// No description provided for @settingsInvitePlayers.
  ///
  /// In en, this message translates to:
  /// **'Invite players'**
  String get settingsInvitePlayers;

  /// No description provided for @settingsPendingBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 player is waiting} other{{count} players are waiting}}'**
  String settingsPendingBannerTitle(int count);

  /// No description provided for @settingsPendingBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Approve them so they can sign up for matches.'**
  String get settingsPendingBannerBody;

  /// No description provided for @settingsJoinRequestsNone.
  ///
  /// In en, this message translates to:
  /// **'No one is waiting right now'**
  String get settingsJoinRequestsNone;

  /// No description provided for @settingsJoinRequestsPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 waiting for approval} other{{count} waiting for approval}}'**
  String settingsJoinRequestsPending(int count);

  /// No description provided for @settingsTeamLogoTitle.
  ///
  /// In en, this message translates to:
  /// **'Team logo'**
  String get settingsTeamLogoTitle;

  /// No description provided for @settingsTeamLogoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shape, colour and initials'**
  String get settingsTeamLogoSubtitle;

  /// No description provided for @settingsMatchDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Signup & match day'**
  String get settingsMatchDayTitle;

  /// No description provided for @settingsMatchDayIntro.
  ///
  /// In en, this message translates to:
  /// **'How matches work for the whole team.'**
  String get settingsMatchDayIntro;

  /// No description provided for @settingsSignupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Who makes the squad?'**
  String get settingsSignupQuestion;

  /// No description provided for @settingsRsvpFirstComeDescription.
  ///
  /// In en, this message translates to:
  /// **'Players who sign up are included automatically.'**
  String get settingsRsvpFirstComeDescription;

  /// No description provided for @settingsRsvpLeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'Players sign up as available, and the team leader picks the squad from them.'**
  String get settingsRsvpLeaderDescription;

  /// No description provided for @settingsMeetingTimeSection.
  ///
  /// In en, this message translates to:
  /// **'Meeting time'**
  String get settingsMeetingTimeSection;

  /// No description provided for @settingsMeetingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meet before kickoff'**
  String get settingsMeetingTimeLabel;

  /// No description provided for @settingsMeetingNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsMeetingNone;

  /// No description provided for @settingsMeetingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String settingsMeetingMinutes(int minutes);

  /// No description provided for @settingsMeetingPreview.
  ///
  /// In en, this message translates to:
  /// **'Kickoff {kickoff} → meet at {meeting}'**
  String settingsMeetingPreview(String kickoff, String meeting);

  /// No description provided for @settingsMeetingPreviewNone.
  ///
  /// In en, this message translates to:
  /// **'No default. You set the meeting time on each match.'**
  String get settingsMeetingPreviewNone;

  /// No description provided for @settingsMeetingSummary.
  ///
  /// In en, this message translates to:
  /// **'Meet {minutes} min before'**
  String settingsMeetingSummary(int minutes);

  /// No description provided for @settingsTasksSection.
  ///
  /// In en, this message translates to:
  /// **'Match day tasks'**
  String get settingsTasksSection;

  /// No description provided for @settingsTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring tasks that rotate between players'**
  String get settingsTasksSubtitle;

  /// No description provided for @settingsAutosaveHint.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved automatically'**
  String get settingsAutosaveHint;

  /// No description provided for @settingsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get settingsSaving;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsSaved;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get settingsSaveFailed;

  /// No description provided for @settingsSeasonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match schedule and standings from DBU'**
  String get settingsSeasonSubtitle;

  /// No description provided for @settingsSeasonIntro.
  ///
  /// In en, this message translates to:
  /// **'Fetch your team\'s matches and the pool standings from DBU.'**
  String get settingsSeasonIntro;

  /// No description provided for @settingsSeasonScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Match schedule'**
  String get settingsSeasonScheduleTitle;

  /// No description provided for @settingsSeasonScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'Import matches or start a new season.'**
  String get settingsSeasonScheduleBody;

  /// No description provided for @settingsSeasonImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsSeasonImportAction;

  /// No description provided for @settingsSeasonStandingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get settingsSeasonStandingsTitle;

  /// No description provided for @settingsSeasonStandingsBody.
  ///
  /// In en, this message translates to:
  /// **'Update the standings and teams in your pool.'**
  String get settingsSeasonStandingsBody;

  /// No description provided for @settingsSeasonSyncAction.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSeasonSyncAction;

  /// No description provided for @settingsSeasonDbuHint.
  ///
  /// In en, this message translates to:
  /// **'You log in through DBU Kampklar, and Kopa fetches your team\'s data.'**
  String get settingsSeasonDbuHint;

  /// No description provided for @settingsSignupLimitSection.
  ///
  /// In en, this message translates to:
  /// **'Squad spots'**
  String get settingsSignupLimitSection;

  /// No description provided for @settingsSignupLimitToggle.
  ///
  /// In en, this message translates to:
  /// **'Limit signups'**
  String get settingsSignupLimitToggle;

  /// No description provided for @settingsSignupLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Spots per match'**
  String get settingsSignupLimitLabel;

  /// No description provided for @settingsSignupLimitHelpOn.
  ///
  /// In en, this message translates to:
  /// **'When {count} have signed up, the rest go on a waitlist and move up automatically if someone drops out.'**
  String settingsSignupLimitHelpOn(int count);

  /// No description provided for @settingsSignupLimitHelpOff.
  ///
  /// In en, this message translates to:
  /// **'Everyone who signs up is included.'**
  String get settingsSignupLimitHelpOff;

  /// No description provided for @settingsSignupLimitDecrease.
  ///
  /// In en, this message translates to:
  /// **'Fewer spots'**
  String get settingsSignupLimitDecrease;

  /// No description provided for @settingsSignupLimitIncrease.
  ///
  /// In en, this message translates to:
  /// **'More spots'**
  String get settingsSignupLimitIncrease;

  /// No description provided for @settingsSignupLimitSummary.
  ///
  /// In en, this message translates to:
  /// **'max {count}'**
  String settingsSignupLimitSummary(int count);

  /// No description provided for @matchWaitlistPosition.
  ///
  /// In en, this message translates to:
  /// **'Waitlist #{position}'**
  String matchWaitlistPosition(int position);

  /// No description provided for @settingsSeasonCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current season'**
  String get settingsSeasonCurrentLabel;

  /// No description provided for @settingsSeasonNone.
  ///
  /// In en, this message translates to:
  /// **'No active season'**
  String get settingsSeasonNone;

  /// No description provided for @settingsSeasonPoolTeams.
  ///
  /// In en, this message translates to:
  /// **'{count} teams'**
  String settingsSeasonPoolTeams(int count);

  /// No description provided for @settingsSeasonStatMatches.
  ///
  /// In en, this message translates to:
  /// **'matches'**
  String get settingsSeasonStatMatches;

  /// No description provided for @settingsSeasonStatPlayed.
  ///
  /// In en, this message translates to:
  /// **'played'**
  String get settingsSeasonStatPlayed;

  /// No description provided for @settingsSeasonStatPosition.
  ///
  /// In en, this message translates to:
  /// **'place'**
  String get settingsSeasonStatPosition;

  /// No description provided for @settingsSeasonPositionValue.
  ///
  /// In en, this message translates to:
  /// **'#{position}'**
  String settingsSeasonPositionValue(int position);

  /// No description provided for @settingsSeasonFetchSection.
  ///
  /// In en, this message translates to:
  /// **'Fetch from DBU'**
  String get settingsSeasonFetchSection;

  /// No description provided for @settingsSeasonScheduleMeta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match this season} other{{count} matches this season}}'**
  String settingsSeasonScheduleMeta(int count);

  /// No description provided for @settingsSeasonScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not imported yet'**
  String get settingsSeasonScheduleEmpty;

  /// No description provided for @settingsSeasonStandingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String settingsSeasonStandingsUpdated(String date);

  /// No description provided for @settingsSeasonStandingsNever.
  ///
  /// In en, this message translates to:
  /// **'Not fetched yet'**
  String get settingsSeasonStandingsNever;

  /// No description provided for @settingsSeasonChangeSection.
  ///
  /// In en, this message translates to:
  /// **'Season change'**
  String get settingsSeasonChangeSection;

  /// No description provided for @settingsSeasonNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Start next season'**
  String get settingsSeasonNextTitle;

  /// No description provided for @settingsSeasonNextReady.
  ///
  /// In en, this message translates to:
  /// **'{label} is ready on DBU with {count} matches.'**
  String settingsSeasonNextReady(String label, int count);

  /// No description provided for @settingsSeasonNextWaiting.
  ///
  /// In en, this message translates to:
  /// **'DBU has not published the next season yet. You can still start it manually.'**
  String get settingsSeasonNextWaiting;

  /// No description provided for @settingsSeasonNextUnknown.
  ///
  /// In en, this message translates to:
  /// **'Import the new season\'s match schedule once DBU has published it.'**
  String get settingsSeasonNextUnknown;

  /// No description provided for @settingsSeasonNextButton.
  ///
  /// In en, this message translates to:
  /// **'Start new season'**
  String get settingsSeasonNextButton;

  /// No description provided for @settingsSeasonNextReadyButton.
  ///
  /// In en, this message translates to:
  /// **'Start {label}'**
  String settingsSeasonNextReadyButton(String label);

  /// No description provided for @settingsSeasonOtherSources.
  ///
  /// In en, this message translates to:
  /// **'Other sources'**
  String get settingsSeasonOtherSources;

  /// No description provided for @settingsSeasonCreateMatch.
  ///
  /// In en, this message translates to:
  /// **'Create match manually'**
  String get settingsSeasonCreateMatch;

  /// No description provided for @settingsSeasonCreateMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friendlies and cup matches'**
  String get settingsSeasonCreateMatchSubtitle;

  /// No description provided for @homeProfilePendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Profile, {count, plural, =1{1 player waiting for approval} other{{count} players waiting for approval}}'**
  String homeProfilePendingRequests(int count);
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
