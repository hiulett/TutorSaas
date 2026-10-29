import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/boss_exam/domain/services/level_checkpoint.dart';
import 'package:tutorsaas/features/weekly_report/domain/models/weekly_report.dart';

/// P-43 (#128): informe semanal calculado en servidor y mini-chequeo del nivel.
void main() {
  group('WeeklyReport', () {
    test('una semana vacía no inventa ceros de progreso', () {
      final report = WeeklyReport.fromMap(const {
        'week_offset': 0,
        'start_date': '2026-10-26',
        'end_date': '2026-11-01',
        'has_data': false,
        'new_words': 0,
        'minutes': 0,
        'level': 'A1',
        'level_assessed': false,
      });

      expect(report.hasData, isFalse);
      expect(report.minutesDelta, isNull);
      expect(report.newWordsDelta, isNull);
      expect(report.correctionsDelta, isNull);
      expect(report.minutesPerPracticeDay, isNull);
      // Un CEFR por defecto sin evaluar no se presenta como nivel.
      expect(report.levelLabel, isNull);
      expect(report.startDate, DateTime(2026, 10, 26));
    });

    test('una respuesta vacía queda sin datos y sin nivel', () {
      final report = WeeklyReport.fromMap(const {});

      expect(report.hasData, isFalse);
      expect(report.levelLabel, isNull);
      expect(report.level, isNull);
      expect(report.newWords, 0);
      expect(report.weekOffset, 0);
    });

    test('calcula deltas y media por día practicado', () {
      final report = WeeklyReport.fromMap(const {
        'week_offset': 1,
        'start_date': '2026-10-19',
        'end_date': '2026-10-25',
        'has_data': true,
        'new_words': 12,
        'words_reviewed': 30,
        'words_mastered': 4,
        'corrections': 7,
        'top_error_type': 'grammar',
        'lessons_completed': 3,
        'minutes': 90,
        'sessions': 5,
        'practice_days': 3,
        'level': 'B1',
        'level_name': 'Intermedio',
        'level_assessed': true,
        'game_rank': 'C',
        'previous': {
          'new_words': 8,
          'corrections': 9,
          'lessons_completed': 2,
          'minutes': 60,
        },
      });

      expect(report.hasData, isTrue);
      expect(report.levelLabel, 'B1 · Intermedio');
      expect(report.gameRank, 'C');
      expect(report.topErrorType, 'grammar');
      expect(report.newWordsDelta, 4);
      expect(report.correctionsDelta, -2);
      expect(report.minutesDelta, 30);
      expect(report.minutesPerPracticeDay, 30.0);
      expect(report.previous.lessonsCompleted, 2);
    });

    test('sin nombre de nivel usa solo el código', () {
      final report = WeeklyReport.fromMap(const {
        'has_data': true,
        'level': 'A2',
        'level_assessed': true,
      });

      expect(report.levelLabel, 'A2');
    });

    test('nivel evaluado sin código no muestra etiqueta', () {
      final report = WeeklyReport.fromMap(const {
        'level_assessed': true,
        'level_name': 'Intermedio',
      });

      expect(report.levelLabel, isNull);
    });
  });

  group('LevelCheckpoint', () {
    test('el aviso salta a las 10 lecciones, no antes', () {
      expect(LevelCheckpoint.isDue(0), isFalse);
      expect(LevelCheckpoint.isDue(9), isFalse);
      expect(LevelCheckpoint.isDue(10), isTrue);
      expect(LevelCheckpoint.isDue(15), isTrue);
    });

    test('remaining cuenta lo que falta para el próximo chequeo', () {
      expect(LevelCheckpoint.remaining(0), 10);
      expect(LevelCheckpoint.remaining(3), 7);
      expect(LevelCheckpoint.remaining(10), 0);
      expect(LevelCheckpoint.remaining(24), 0);
    });

    test('progreso se mueve entre 0 y 1 sin desbordar', () {
      expect(LevelCheckpoint.progress(0), 0.0);
      expect(LevelCheckpoint.progress(5), closeTo(0.5, 0.001));
      expect(LevelCheckpoint.progress(10), 1.0);
      expect(LevelCheckpoint.progress(99), 1.0);
      expect(LevelCheckpoint.progress(-3), 0.0);
    });
  });
}
