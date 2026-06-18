# TriviaGame Flutter

Mobilna aplikacja quizowa **real-time multiplayer** zbudowana we Flutterze. Gracze rywalizują odpowiadając na pytania w czasie rzeczywistym poprzez połączenie SignalR z backendem ASP.NET Core.

## Funkcjonalności

- Tworzenie pokoju z wyborem kategorii pytań
- Dołączanie przez **unikalny 6-znakowy kod**, **skan kodu QR** lub **udostępnienie linku**
- **Fallback ręcznego wpisania kodu** gdy kamera jest niedostępna lub brak uprawnień
- Wyświetlanie kodu QR pokoju w lobby
- Widoczna kategoria gry dla wszystkich graczy w lobby
- Rozgrywka z pytaniami jednokrotnego wyboru i **lokalnym odliczaniem czasu (30s)**
- Automatyczne przejście do następnego pytania po upływie czasu
- **Ranking po każdym pytaniu** (wszystkich graczy)
- **Podium po zakończeniu gry** (top 3)
- **Zagraj ponownie** — host wybiera kategorię i restartuje grę, wszyscy wracają do lobby
- Obsługa rozłączenia hosta — gracze są automatycznie przenoszeni do menu
- Nick gracza zapamiętywany w sesji aplikacji
- Obsługa stanów: **ładowanie**, **błąd serwera**, **brak połączenia**
- Dialog potwierdzający wyjście z aplikacji
- **Codzienne powiadomienie push o 18:00** zachęcające do rozgrywki

## Technologie

| Pakiet                        | Wersja | Zastosowanie                               |
| ----------------------------- | ------ | ------------------------------------------ |
| `go_router`                   | 17.2.2 | nawigacja deklaratywna                     |
| `flutter_riverpod`            | 2.6.1  | zarządzanie stanem (Notifier/Provider)     |
| `signalr_netcore`             | 1.3.5  | połączenie real-time z backendem           |
| `http`                        | 1.2.0  | REST API (tworzenie/dołączanie do pokoju)  |
| `qr_flutter`                  | 4.1.0  | generowanie kodu QR                        |
| `mobile_scanner`              | 7.2.0  | skanowanie kodu QR kamerą                  |
| `share_plus`                  | 13.1.0 | udostępnianie kodu pokoju                  |
| `permission_handler`          | 12.0.1 | uprawnienie do kamery                      |
| `connectivity_plus`           | 7.1.1  | wykrywanie braku sieci                     |
| `flutter_local_notifications` | 18.0.1 | lokalne powiadomienia push                 |
| `timezone`                    | 0.9.4  | obsługa stref czasowych przy schedulowaniu |

## Struktura projektu

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart              # URL backendu (SignalR hub + REST)
│   ├── errors/
│   │   └── app_failure.dart             # sealed class błędów (Network/Server/NotFound/Unknown)
│   ├── services/
│   │   ├── game_hub_service.dart        # połączenie SignalR i callbacki (warstwa niskopoziomowa)
│   │   ├── room_api_service.dart        # HTTP: tworzenie/dołączanie do pokoju, kategorie
│   │   ├── connectivity_service.dart
│   │   ├── notification_service.dart    # lokalne powiadomienia push (scheduler)
│   │   └── permission_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── app_router.dart                  # definicja tras (GoRouter)
├── data/
│   ├── datasources/
│   │   └── room_remote_datasource.dart  # HTTP + mapowanie wyjątków na AppFailure
│   └── repositories/
│       ├── room_repository_impl.dart    # sprawdzenie połączenia + delegacja do datasource
│       └── game_hub_repository_impl.dart # delegacja do GameHubService
├── domain/
│   └── repositories/
│       ├── room_repository.dart         # abstrakcja HTTP (interfejs)
│       └── game_hub_repository.dart     # abstrakcja SignalR (interfejs)
├── models/
│   ├── player_model.dart
│   └── question_model.dart
├── providers/                           # warstwa stanu (Riverpod)
│   ├── repository_providers.dart        # singletony repozytoriów
│   ├── create_room_provider.dart        # logika tworzenia pokoju
│   ├── join_room_provider.dart          # logika dołączania do pokoju
│   ├── lobby_provider.dart              # stan lobby, callbacki SignalR
│   ├── game_provider.dart               # stan gry, timer, callbacki SignalR
│   └── summary_provider.dart            # stan podsumowania, restart gry
├── screens/
│   ├── splash/                          # ekran startowy
│   ├── home/                            # menu główne
│   ├── room/
│   │   ├── create_room_screen.dart      # tworzenie pokoju + wybór kategorii
│   │   ├── join_room_screen.dart        # dołączanie kodem lub QR
│   │   ├── lobby_screen.dart            # poczekalnia przed grą
│   │   └── qr_scanner_screen.dart       # skaner QR + fallback ręcznego kodu
│   ├── game/
│   │   └── game_screen.dart             # rozgrywka (pytania, timer, ranking rundy)
│   └── summary/
│       └── summary_screen.dart          # podium, wyniki, restart
└── widgets/
    ├── timer_widget.dart
    ├── leaderboard_widget.dart
    ├── error_widget.dart
    ├── loading_widget.dart
    ├── offline_widget.dart
    └── qr_widget.dart

test/
├── mocks/
│   ├── mock_room_repository.dart        # konfigurowalny mock HTTP
│   └── mock_game_hub_repository.dart    # mock no-op SignalR
├── models/
│   ├── player_model_test.dart
│   └── question_model_test.dart
├── screens/
│   ├── create_room_screen_test.dart     # 5 testów widgetów
│   └── join_room_screen_test.dart       # 5 testów widgetów
└── widget_test.dart                     # SplashScreen
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
- **POST_NOTIFICATIONS** — lokalne powiadomienia push (Android 13+, starsze wersje nie wymagają zgody)
- **RECEIVE_BOOT_COMPLETED** — przywrócenie zaplanowanych powiadomień po restarcie urządzenia

## Architektura stanu (Riverpod)

Logika biznesowa jest oddzielona od warstwy UI za pomocą `flutter_riverpod`. Każdy ekran ze stanem ma odpowiadający mu `AutoDisposeNotifier` w katalogu `providers/`, który przechowuje dane i obsługuje operacje (wywołania API, callbacki SignalR, timer). Ekrany są `ConsumerStatefulWidget` i obserwują stan przez `ref.watch` / `ref.listen` — nawigacja wywoływana jest z ekranu po zmianie stanu (np. `gameStartData != null` → przejście do `/game`).

Notifiery nie komunikują się bezpośrednio z serwisami — korzystają z abstrakcji repozytoriów wstrzykiwanych przez Riverpod (`ref.read(roomRepositoryProvider)`), co umożliwia podmianę implementacji na mocki w testach.

## Warstwa danych

Aplikacja stosuje wzorzec **Repository + DataSource**:

- **DataSource** (`data/datasources/`) — jedyne miejsce znające konkretny serwis HTTP. Łapie wyjątki i mapuje je na typy `AppFailure`.
- **Repository** (`domain/repositories/`) — abstrakcyjny interfejs używany przez notifiery. Implementacja (`data/repositories/`) dodaje sprawdzenie połączenia przed wywołaniem datasource i rzuca `NetworkFailure` gdy brak sieci.
- **AppFailure** (`core/errors/`) — sealed class z typami: `NetworkFailure`, `ServerFailure`, `NotFoundFailure`, `UnknownFailure`. Notifiery łapią konkretne typy i ustawiają odpowiedni stan UI.

## Architektura SignalR

`GameHubService` utrzymuje jedno statyczne połączenie przez całą sesję gry (lobby → rozgrywka → podsumowanie → ponowne lobby). Dostęp do niego odbywa się przez `GameHubRepository` — interfejs wstrzykiwany do notifierów przez Riverpod. Callbacki SignalR są rejestrowane w Notifierach (nie w ekranach) i aktualizują stan, który ekrany obserwują przez `ref.listen`. Połączenie jest zamykane przez `AutoDisposeNotifier.onDispose` — z wyjątkiem przejść między ekranami, gdzie połączenie jest celowo zachowane.

## Testy

Testy widgetów w katalogu `test/screens/` używają `ProviderScope` z nadpisanymi providerami repozytoriów, co pozwala na izolowane testowanie ekranów bez rzeczywistych wywołań HTTP ani SignalR. Mocki w `test/mocks/` implementują interfejsy domenowe i pozwalają konfigurować zachowanie (sukces, `ServerFailure`, `NetworkFailure`).

## Autor

- **WCiovh**
