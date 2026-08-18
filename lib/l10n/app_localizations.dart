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

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

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
