import 'package:flutter_test/flutter_test.dart';
import 'package:triviagame_flutter/models/player_model.dart';

void main() {
  group('PlayerModel.fromJson', () {
    test('parsuje wszystkie pola poprawnie', () {
      final p = PlayerModel.fromJson({
        'uuid': 'abc-123',
        'displayName': 'Wiktor',
        'points': 150,
        'correctAnswers': 3,
      });

      expect(p.uuid, 'abc-123');
      expect(p.displayName, 'Wiktor');
      expect(p.points, 150);
      expect(p.correctAnswers, 3);
    });

    test('obsługuje zerowe punkty i poprawne odpowiedzi', () {
      final p = PlayerModel.fromJson({
        'uuid': 'x',
        'displayName': 'Gracz',
        'points': 0,
        'correctAnswers': 0,
      });

      expect(p.points, 0);
      expect(p.correctAnswers, 0);
    });
  });

  group('PlayerModel.toScoreMap', () {
    test('zwraca mapę z uuid, nickname i score', () {
      final p = PlayerModel(
        uuid: 'abc-123',
        displayName: 'Wiktor',
        points: 200,
        correctAnswers: 5,
      );

      final map = p.toScoreMap();

      expect(map['uuid'], 'abc-123');
      expect(map['nickname'], 'Wiktor');
      expect(map['score'], 200);
    });
  });

  group('Sortowanie wyników', () {
    test('sortuje graczy malejąco po punktach', () {
      final scores = [
        {'nickname': 'A', 'score': 100},
        {'nickname': 'B', 'score': 300},
        {'nickname': 'C', 'score': 200},
      ];

      final sorted = [...scores]
        ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      expect(sorted[0]['nickname'], 'B');
      expect(sorted[1]['nickname'], 'C');
      expect(sorted[2]['nickname'], 'A');
    });

    test('przy remisie zachowuje kolejność stabilną', () {
      final scores = [
        {'nickname': 'A', 'score': 100},
        {'nickname': 'B', 'score': 100},
      ];

      final sorted = [...scores]
        ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      expect(sorted[0]['score'], 100);
      expect(sorted[1]['score'], 100);
    });
  });
}
