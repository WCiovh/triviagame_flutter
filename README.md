# TriviaGame Flutter

Mobilna aplikacja quizowa **real-time multiplayer** zbudowana we Flutterze. Gracze rywalizują odpowiadając na pytania w czasie rzeczywistym poprzez połączenie SignalR z backendem ASP.NET Core.

## Funkcjonalności

- Tworzenie pokoju z wyborem kategorii pytań
- Dołączanie przez **unikalny 6-znakowy kod**, **skan kodu QR** lub **udostępnienie linku**
- Wyświetlanie kodu QR pokoju w lobby
- Widoczna kategoria gry dla wszystkich graczy w lobby
- Rozgrywka z pytaniami wielokrotnego wyboru i **lokalnym odliczaniem czasu (30s)**
- Automatyczne przejście do następnego pytania po upływie czasu
- **Ranking po każdym pytaniu** (wszystkich graczy)
- **Podium po zakończeniu gry** (top 3)
- **Zagraj ponownie** — host wybiera kategorię i restartuje grę, wszyscy wracają do lobby
- Obsługa rozłączenia hosta — gracze są automatycznie przenoszeni do menu
- Nick gracza zapamiętywany w sesji aplikacji
- Obsługa stanów: **ładowanie**, **błąd serwera**, **brak połączenia**
- Dialog potwierdzający wyjście z aplikacji

## Technologie

| Pakiet | Wersja | Zastosowanie |
|---|---|---|
| `go_router` | 17.2.2 | nawigacja deklaratywna |
| `signalr_netcore` | 1.3.5 | połączenie real-time z backendem |
| `http` | 1.2.0 | REST API (tworzenie/dołączanie do pokoju) |
| `qr_flutter` | 4.1.0 | generowanie kodu QR |
| `mobile_scanner` | 7.2.0 | skanowanie kodu QR kamerą |
| `share_plus` | 13.1.0 | udostępnianie kodu pokoju |
| `permission_handler` | 12.0.1 | uprawnienie do kamery |
| `connectivity_plus` | 7.1.1 | wykrywanie braku sieci |

## Struktura projektu

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          # URL backendu (SignalR hub + REST)
│   ├── services/
│   │   ├── game_hub_service.dart    # zarządzanie połączeniem SignalR i callbackami
│   │   ├── room_api_service.dart    # HTTP: tworzenie/dołączanie do pokoju, kategorie
│   │   ├── connectivity_service.dart
│   │   └── permission_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── app_router.dart              # definicja tras (GoRouter)
├── models/
│   ├── player_model.dart
│   └── question_model.dart
├── screens/
│   ├── splash/                      # ekran startowy
│   ├── home/                        # menu główne
│   ├── room/
│   │   ├── create_room_screen.dart  # tworzenie pokoju + wybór kategorii
│   │   ├── join_room_screen.dart    # dołączanie kodem lub QR
│   │   ├── lobby_screen.dart        # poczekalnia przed grą
│   │   └── qr_scanner_screen.dart  # skaner QR
│   ├── game/
│   │   └── game_screen.dart         # rozgrywka (pytania, timer, ranking rundy)
│   └── summary/
│       └── summary_screen.dart      # podium, wyniki, restart
└── widgets/
    ├── timer_widget.dart
    ├── leaderboard_widget.dart
    ├── error_widget.dart
    ├── loading_widget.dart
    ├── offline_widget.dart
    └── qr_widget.dart
```

## Uruchomienie

### Wymagania

- Flutter SDK `^3.11.5`
- Android SDK API 21+
- Działający backend (ASP.NET Core + SignalR)

### Instalacja

```bash
git clone https://github.com/WCiovh/triviagame_flutter
cd triviagame_flutter
flutter pub get
```

### Konfiguracja

Skopiuj plik przykładowy i uzupełnij adres backendu:

```bash
cp .env.json.example .env.json
```

Domyślna wartość `change-me-in-production` pasuje do lokalnego serwera uruchamianego bez nadpisania `Auth:ApiKey`.

### Uruchomienie

```bash
flutter run --dart-define-from-file=.env.json
```

## Uprawnienia

- **CAMERA** — skanowanie kodów QR

## Architektura SignalR

`GameHubService` utrzymuje jedno statyczne połączenie przez całą sesję gry (lobby → rozgrywka → podsumowanie → ponowne lobby). Każdy ekran rejestruje swoje callbacki w `initState` i sprząta je w `dispose` — z wyjątkiem przejść między ekranami, gdzie połączenie i callbacki są celowo zachowane, by uniknąć utraty zdarzeń w trakcie nawigacji.

## Autor

- **WCiovh** — frontend
