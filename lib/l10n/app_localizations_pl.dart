// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appSubtitle => 'Real-time multiplayer quiz';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get cancel => 'Anuluj';

  @override
  String get close => 'Zamknij';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get host => 'Host';

  @override
  String points(int score) {
    return '$score pkt';
  }

  @override
  String get exitAppTitle => 'Wyjść z aplikacji?';

  @override
  String get createRoom => 'Utwórz pokój';

  @override
  String get joinRoom => 'Dołącz do pokoju';

  @override
  String get whatsYourName => 'Jak masz na imię?';

  @override
  String get nicknameVisible => 'Twój nick będzie widoczny dla innych graczy.';

  @override
  String get nickLabel => 'Nick';

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get anyCategory => 'Dowolna kategoria';

  @override
  String get creatingRoom => 'Tworzenie pokoju...';

  @override
  String get enterNickname => 'Podaj swój nick!';

  @override
  String get roomCodeMustBe6 => 'Kod pokoju musi mieć 6 znaków!';

  @override
  String get joinGame => 'Dołącz do gry';

  @override
  String get enterNicknameAndCode => 'Podaj nick i kod pokoju aby dołączyć.';

  @override
  String get roomCodeLabel => 'Kod pokoju';

  @override
  String get enterNicknameFirst => 'Najpierw podaj nick!';

  @override
  String get scanQrCode => 'Skanuj kod QR';

  @override
  String get joiningRoom => 'Dołączanie do pokoju...';

  @override
  String get join => 'Dołącz';

  @override
  String get hostClosedRoom => 'Host zamknął pokój.';

  @override
  String get connectionFailed =>
      'Nie udało się połączyć z serwerem. Sprawdź połączenie.';

  @override
  String get startGameFailed => 'Nie udało się rozpocząć gry.';

  @override
  String get codeCopied => 'Kod skopiowany!';

  @override
  String shareRoomText(String roomCode) {
    return 'Dołącz do mojego pokoju TriviaGame!\nKod: $roomCode';
  }

  @override
  String get closeRoomTitle => 'Zamknąć pokój?';

  @override
  String get closeRoomContent => 'Wszyscy gracze zostaną rozłączeni.';

  @override
  String get lobby => 'Lobby';

  @override
  String get connectingToRoom => 'Łączenie z pokojem...';

  @override
  String get tapToCopy => 'Dotknij aby skopiować';

  @override
  String get roomQrCode => 'Kod QR pokoju';

  @override
  String get showQr => 'Pokaż QR';

  @override
  String get share => 'Udostępnij';

  @override
  String playersCount(int count) {
    return 'Gracze ($count)';
  }

  @override
  String get waitingForHost => 'Czekam na hosta...';

  @override
  String get startGame => 'Rozpocznij grę';

  @override
  String get leaveRoom => 'Opuść pokój';

  @override
  String get leaveGameTitle => 'Opuścić grę?';

  @override
  String get leaveGameContent => 'Twój postęp zostanie utracony.';

  @override
  String questionProgress(int current, int total) {
    return 'Pytanie $current/$total';
  }

  @override
  String roomLabel(String roomCode) {
    return 'Pokój: $roomCode';
  }

  @override
  String get timeUp => 'Czas minął!';

  @override
  String get waitingForOtherPlayers => 'Czekam na pozostałych graczy...';

  @override
  String get didNotAnswer => 'Nie odpowiedziałeś';

  @override
  String get yourAnswer => 'Twoja odpowiedź';

  @override
  String get correctAnswer => 'Poprawna odpowiedź';

  @override
  String get submitAnswerFailed => 'Nie udało się wysłać odpowiedzi.';

  @override
  String get nextQuestion => 'Następne pytanie';

  @override
  String get gameOver => 'Koniec gry!';

  @override
  String get podium => '🏆 Podium';

  @override
  String get backToMenu => 'Powrót do menu';

  @override
  String get categoryForNextGame => 'Kategoria na następną grę';

  @override
  String get playAgain => 'Zagraj ponownie';

  @override
  String get waitingForHostLong => 'Oczekuję na hosta...';

  @override
  String get noPermissions => 'Brak uprawnień';

  @override
  String get cameraPermissionNeeded =>
      'Aplikacja potrzebuje dostępu do kamery aby skanować kody QR.';

  @override
  String get openSettings => 'Otwórz ustawienia';

  @override
  String get pointCameraAtQr => 'Skieruj kamerę na kod QR pokoju';

  @override
  String get somethingWentWrong => 'Coś poszło nie tak';

  @override
  String get noConnection => 'Brak połączenia';

  @override
  String get checkInternetConnection =>
      'Sprawdź połączenie z internetem i spróbuj ponownie.';

  @override
  String get ranking => 'Ranking';
}
