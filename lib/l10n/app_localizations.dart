import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

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
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Real-time multiplayer quiz'**
  String get appSubtitle;

  /// No description provided for @yes.
  ///
  /// In pl, this message translates to:
  /// **'Tak'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get close;

  /// No description provided for @tryAgain.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get tryAgain;

  /// No description provided for @host.
  ///
  /// In pl, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @points.
  ///
  /// In pl, this message translates to:
  /// **'{score} pkt'**
  String points(int score);

  /// No description provided for @exitAppTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wyjść z aplikacji?'**
  String get exitAppTitle;

  /// No description provided for @createRoom.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz pokój'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz do pokoju'**
  String get joinRoom;

  /// No description provided for @whatsYourName.
  ///
  /// In pl, this message translates to:
  /// **'Jak masz na imię?'**
  String get whatsYourName;

  /// No description provided for @nicknameVisible.
  ///
  /// In pl, this message translates to:
  /// **'Twój nick będzie widoczny dla innych graczy.'**
  String get nicknameVisible;

  /// No description provided for @nickLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nick'**
  String get nickLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get categoryLabel;

  /// No description provided for @anyCategory.
  ///
  /// In pl, this message translates to:
  /// **'Dowolna kategoria'**
  String get anyCategory;

  /// No description provided for @creatingRoom.
  ///
  /// In pl, this message translates to:
  /// **'Tworzenie pokoju...'**
  String get creatingRoom;

  /// No description provided for @enterNickname.
  ///
  /// In pl, this message translates to:
  /// **'Podaj swój nick!'**
  String get enterNickname;

  /// No description provided for @roomCodeMustBe6.
  ///
  /// In pl, this message translates to:
  /// **'Kod pokoju musi mieć 6 znaków!'**
  String get roomCodeMustBe6;

  /// No description provided for @joinGame.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz do gry'**
  String get joinGame;

  /// No description provided for @enterNicknameAndCode.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nick i kod pokoju aby dołączyć.'**
  String get enterNicknameAndCode;

  /// No description provided for @roomCodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod pokoju'**
  String get roomCodeLabel;

  /// No description provided for @enterNicknameFirst.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw podaj nick!'**
  String get enterNicknameFirst;

  /// No description provided for @scanQrCode.
  ///
  /// In pl, this message translates to:
  /// **'Skanuj kod QR'**
  String get scanQrCode;

  /// No description provided for @joiningRoom.
  ///
  /// In pl, this message translates to:
  /// **'Dołączanie do pokoju...'**
  String get joiningRoom;

  /// No description provided for @join.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz'**
  String get join;

  /// No description provided for @hostClosedRoom.
  ///
  /// In pl, this message translates to:
  /// **'Host zamknął pokój.'**
  String get hostClosedRoom;

  /// No description provided for @connectionFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się połączyć z serwerem. Sprawdź połączenie.'**
  String get connectionFailed;

  /// No description provided for @startGameFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się rozpocząć gry.'**
  String get startGameFailed;

  /// No description provided for @codeCopied.
  ///
  /// In pl, this message translates to:
  /// **'Kod skopiowany!'**
  String get codeCopied;

  /// No description provided for @shareRoomText.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz do mojego pokoju TriviaGame!\nKod: {roomCode}'**
  String shareRoomText(String roomCode);

  /// No description provided for @closeRoomTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zamknąć pokój?'**
  String get closeRoomTitle;

  /// No description provided for @closeRoomContent.
  ///
  /// In pl, this message translates to:
  /// **'Wszyscy gracze zostaną rozłączeni.'**
  String get closeRoomContent;

  /// No description provided for @lobby.
  ///
  /// In pl, this message translates to:
  /// **'Lobby'**
  String get lobby;

  /// No description provided for @connectingToRoom.
  ///
  /// In pl, this message translates to:
  /// **'Łączenie z pokojem...'**
  String get connectingToRoom;

  /// No description provided for @tapToCopy.
  ///
  /// In pl, this message translates to:
  /// **'Dotknij aby skopiować'**
  String get tapToCopy;

  /// No description provided for @roomQrCode.
  ///
  /// In pl, this message translates to:
  /// **'Kod QR pokoju'**
  String get roomQrCode;

  /// No description provided for @showQr.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż QR'**
  String get showQr;

  /// No description provided for @share.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get share;

  /// No description provided for @playersCount.
  ///
  /// In pl, this message translates to:
  /// **'Gracze ({count})'**
  String playersCount(int count);

  /// No description provided for @waitingForHost.
  ///
  /// In pl, this message translates to:
  /// **'Czekam na hosta...'**
  String get waitingForHost;

  /// No description provided for @startGame.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij grę'**
  String get startGame;

  /// No description provided for @leaveRoom.
  ///
  /// In pl, this message translates to:
  /// **'Opuść pokój'**
  String get leaveRoom;

  /// No description provided for @leaveGameTitle.
  ///
  /// In pl, this message translates to:
  /// **'Opuścić grę?'**
  String get leaveGameTitle;

  /// No description provided for @leaveGameContent.
  ///
  /// In pl, this message translates to:
  /// **'Twój postęp zostanie utracony.'**
  String get leaveGameContent;

  /// No description provided for @questionProgress.
  ///
  /// In pl, this message translates to:
  /// **'Pytanie {current}/{total}'**
  String questionProgress(int current, int total);

  /// No description provided for @roomLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pokój: {roomCode}'**
  String roomLabel(String roomCode);

  /// No description provided for @timeUp.
  ///
  /// In pl, this message translates to:
  /// **'Czas minął!'**
  String get timeUp;

  /// No description provided for @waitingForOtherPlayers.
  ///
  /// In pl, this message translates to:
  /// **'Czekam na pozostałych graczy...'**
  String get waitingForOtherPlayers;

  /// No description provided for @didNotAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Nie odpowiedziałeś'**
  String get didNotAnswer;

  /// No description provided for @yourAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Twoja odpowiedź'**
  String get yourAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Poprawna odpowiedź'**
  String get correctAnswer;

  /// No description provided for @submitAnswerFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wysłać odpowiedzi.'**
  String get submitAnswerFailed;

  /// No description provided for @nextQuestion.
  ///
  /// In pl, this message translates to:
  /// **'Następne pytanie'**
  String get nextQuestion;

  /// No description provided for @gameOver.
  ///
  /// In pl, this message translates to:
  /// **'Koniec gry!'**
  String get gameOver;

  /// No description provided for @podium.
  ///
  /// In pl, this message translates to:
  /// **'🏆 Podium'**
  String get podium;

  /// No description provided for @backToMenu.
  ///
  /// In pl, this message translates to:
  /// **'Powrót do menu'**
  String get backToMenu;

  /// No description provided for @categoryForNextGame.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria na następną grę'**
  String get categoryForNextGame;

  /// No description provided for @playAgain.
  ///
  /// In pl, this message translates to:
  /// **'Zagraj ponownie'**
  String get playAgain;

  /// No description provided for @waitingForHostLong.
  ///
  /// In pl, this message translates to:
  /// **'Oczekuję na hosta...'**
  String get waitingForHostLong;

  /// No description provided for @noPermissions.
  ///
  /// In pl, this message translates to:
  /// **'Brak uprawnień'**
  String get noPermissions;

  /// No description provided for @cameraPermissionNeeded.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja potrzebuje dostępu do kamery aby skanować kody QR.'**
  String get cameraPermissionNeeded;

  /// No description provided for @openSettings.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz ustawienia'**
  String get openSettings;

  /// No description provided for @pointCameraAtQr.
  ///
  /// In pl, this message translates to:
  /// **'Skieruj kamerę na kod QR pokoju'**
  String get pointCameraAtQr;

  /// No description provided for @somethingWentWrong.
  ///
  /// In pl, this message translates to:
  /// **'Coś poszło nie tak'**
  String get somethingWentWrong;

  /// No description provided for @noConnection.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia'**
  String get noConnection;

  /// No description provided for @checkInternetConnection.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź połączenie z internetem i spróbuj ponownie.'**
  String get checkInternetConnection;

  /// No description provided for @ranking.
  ///
  /// In pl, this message translates to:
  /// **'Ranking'**
  String get ranking;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
