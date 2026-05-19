# 🎮 TriviaGame Flutter

Mobilna aplikacja quizowa typu **real-time multiplayer**, w której użytkownicy rywalizują odpowiadając na pytania w czasie rzeczywistym.

## 📱 Funkcjonalności

- Tworzenie i dołączanie do pokoju gry
- Dołączanie przez **unikalny kod**, **kod QR** lub **link**
- Rozgrywka z pytaniami i **odliczaniem czasu**
- **Ranking po każdym pytaniu** (top 5 graczy)
- **Podium** po zakończeniu gry (top 3)
- Obsługa stanów: **loading**, **error**, **offline**

## 🛠️ Technologie

- **Flutter** — framework mobilny
- **Dart** — język programowania
- **go_router** — nawigacja
- **qr_flutter** — generowanie kodów QR
- **mobile_scanner** — skanowanie kodów QR
- **share_plus** — udostępnianie kodu pokoju
- **permission_handler** — obsługa uprawnień
- **connectivity_plus** — obsługa stanu offline

## 📁 Struktura projektu
lib/
├── core/
│   ├── constants/       # stałe aplikacji
│   ├── services/        # serwisy (permissions, connectivity)
│   ├── theme/           # motyw aplikacji
│   └── utils/           # funkcje pomocnicze
├── models/              # modele danych
├── providers/           # state management
├── screens/
│   ├── splash/          # ekran startowy
│   ├── home/            # menu główne
│   ├── room/            # tworzenie i dołączanie do pokoju
│   ├── game/            # rozgrywka
│   └── summary/         # podium i podsumowanie
└── widgets/             # współdzielone komponenty UI

## 🚀 Uruchomienie

### Wymagania
- Flutter SDK >= 3.11.5
- Android SDK (API 21+)

### Instalacja

```bash
git clone https://github.com/WCiovh/triviagame_flutter
cd triviagame_flutter
flutter pub get
```

### Konfiguracja zmiennych środowiskowych

Skopiuj plik przykładowy i uzupełnij klucz API backendu:

```bash
cp .env.json.example .env.json
```

Domyślna wartość (`change-me-in-production`) pasuje do lokalnego serwera uruchamianego bez nadpisania `Auth:ApiKey`.

### Uruchomienie

```bash
flutter run --dart-define-from-file=.env.json
```

## 📋 Uprawnienia

Aplikacja wymaga następujących uprawnień:
- **CAMERA** — skanowanie kodów QR

## 👤 Autor

- **WCiovh** — frontend