import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/missions/presentation/widgets/mission_parchment.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_models.dart';

void main() {
  const quest = GuildQuest(
    id: 'q1',
    questType: 'daily',
    title: 'Voice of the Guild',
    objectiveType: 'speak_minutes',
    targetValue: 10,
    xpReward: 60,
    gemReward: 10,
    gameRank: 'C',
    category: 'speaking',
  );

  group('QuestRarity.fromRank', () {
    test('mapea rangos a rarezas discretas', () {
      expect(QuestRarity.fromRank('E'), QuestRarity.common);
      expect(QuestRarity.fromRank('D'), QuestRarity.uncommon);
      expect(QuestRarity.fromRank('C'), QuestRarity.rare);
      expect(QuestRarity.fromRank('B'), QuestRarity.epic);
      expect(QuestRarity.fromRank('A'), QuestRarity.legendary);
      expect(QuestRarity.fromRank('S'), QuestRarity.guild);
      expect(QuestRarity.fromRank('SS'), QuestRarity.guild);
      expect(QuestRarity.fromRank('SSS'), QuestRarity.guild);
    });

    test('rango desconocido → común', () {
      expect(QuestRarity.fromRank(null), QuestRarity.common);
      expect(QuestRarity.fromRank('ZZ'), QuestRarity.common);
    });

    test('rareza editorial de BD tiene prioridad sobre el rango', () {
      expect(QuestRarity.fromRank('E', rarity: 'legendary'), QuestRarity.legendary);
      expect(QuestRarity.fromRank('SSS', rarity: 'common'), QuestRarity.common);
      expect(QuestRarity.fromRank('C', rarity: 'guild'), QuestRarity.guild);
    });

    test('rareza editorial inválida cae al rango', () {
      expect(QuestRarity.fromRank('A', rarity: 'zzz'), QuestRarity.legendary);
    });
  });

  group('questStatusFor', () {
    test('completada domina el estado', () {
      expect(
        questStatusFor(quest: quest, playerRank: 'E', isCompleted: true, isActive: false, isRecommended: false),
        QuestStatus.completed,
      );
    });

    test('activa → en progreso', () {
      expect(
        questStatusFor(quest: quest, playerRank: 'C', isCompleted: false, isActive: true, isRecommended: false),
        QuestStatus.inProgress,
      );
    });

    test('recomendada (rango == jugador) → recomendada', () {
      expect(
        questStatusFor(quest: quest, playerRank: 'C', isCompleted: false, isActive: false, isRecommended: true),
        QuestStatus.recommended,
      );
    });

    test('rango insuficiente → bloqueada', () {
      expect(
        questStatusFor(quest: quest, playerRank: 'E', isCompleted: false, isActive: false, isRecommended: false),
        QuestStatus.blocked,
      );
    });

    test('rango suficiente y disponible → disponible', () {
      expect(
        questStatusFor(quest: quest, playerRank: 'C', isCompleted: false, isActive: false, isRecommended: false),
        QuestStatus.available,
      );
    });
  });

  group('sortQuestSmart', () {
    const qRec = GuildQuest(id: 'rec', questType: 'daily', title: 'Rec', objectiveType: 'x', targetValue: 1, gameRank: 'C');
    const qOk = GuildQuest(id: 'ok', questType: 'weekly', title: 'Ok', objectiveType: 'x', targetValue: 1, gameRank: 'E');
    const qBlocked = GuildQuest(id: 'blk', questType: 'weekly', title: 'Blk', objectiveType: 'x', targetValue: 1, gameRank: 'S');

    test('recomendada primero, luego aceptable, bloqueada al final', () {
      final sorted = sortQuestSmart(
        quests: const [qBlocked, qOk, qRec],
        playerRank: 'C',
        recommendedRank: 'C',
      );
      expect(sorted.map((q) => q.id).toList(), ['rec', 'ok', 'blk']);
    });

    test('aceptables antes que bloqueadas sin recomendada', () {
      final sorted = sortQuestSmart(
        quests: const [qBlocked, qOk],
        playerRank: 'C',
        recommendedRank: 'A',
      );
      expect(sorted.map((q) => q.id).toList(), ['ok', 'blk']);
    });

    test('desempata por rango menor requerido', () {
      const qD = GuildQuest(id: 'd', questType: 'weekly', title: 'D', objectiveType: 'x', targetValue: 1, gameRank: 'D');
      const qE = GuildQuest(id: 'e', questType: 'weekly', title: 'E', objectiveType: 'x', targetValue: 1, gameRank: 'E');
      final sorted = sortQuestSmart(
        quests: const [qD, qE],
        playerRank: 'C',
        recommendedRank: 'A',
      );
      expect(sorted.map((q) => q.id).toList(), ['e', 'd']);
    });
  });
}
