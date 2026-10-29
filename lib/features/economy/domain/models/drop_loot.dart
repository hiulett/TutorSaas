import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Rareza de un drop sorpresa (RPG-05).
enum DropRarity {
  comun(color: AppColors.onSurfaceVariant, xpMultiplier: 1.0),
  raro(color: AppColors.manaCyan, xpMultiplier: 1.5),
  epico(color: AppColors.runeViolet, xpMultiplier: 2.0),
  legendario(color: AppColors.royalGold, xpMultiplier: 3.0);

  const DropRarity({required this.color, required this.xpMultiplier});

  final Color color;
  final double xpMultiplier;
}

/// Recompensa de invocación obtenida al completar una interacción.
class DropLoot {
  final String title;
  final String emoji;
  final int xpBonus;
  final int goldBonus;
  final DropRarity rarity;

  const DropLoot({
    required this.title,
    required this.emoji,
    required this.xpBonus,
    this.goldBonus = 0,
    required this.rarity,
  });

  /// Construye el drop a partir de la respuesta de claim_session_drop.
  factory DropLoot.fromServer(Map<String, dynamic> data) {
    final rarity = switch ((data['rarity'] ?? 'comun').toString()) {
      'legendario' => DropRarity.legendario,
      'epico' => DropRarity.epico,
      'raro' => DropRarity.raro,
      _ => DropRarity.comun,
    };
    return DropLoot(
      title: 'Bolsa de oro',
      emoji: '\u{1F4B0}',
      xpBonus: (data['xp'] as num?)?.toInt() ?? 0,
      goldBonus: (data['gold'] as num?)?.toInt() ?? 0,
      rarity: rarity,
    );
  }

  static const int _baseXp = 15;

  static const List<(String, String)> _comun = [
    ('Fragmento de Maná', '🔹'),
    ('Esquirla de Piedra Rúnica', '🪨'),
  ];

  static const List<(String, String)> _raro = [
    ('Gema de Resonancia', '💠'),
    ('Pergamino del Viento', '📜'),
  ];

  static const List<(String, String)> _epico = [
    ('Núcleo Estelar', '🌟'),
    ('Llave del Archivo', '🗝️'),
  ];

  static const List<(String, String)> _legendario = [
    ('Corona del Vacío', '👑'),
    ('Aegis del Verbo', '🛡️'),
  ];

  /// Lanza un drop sorpresa con pesos: legendario 2%, épico 8%, raro 25%, común 65%.
  static DropLoot roll(Random rng) {
    final value = rng.nextInt(100);
    final rarity = switch (value) {
      < 2 => DropRarity.legendario,
      < 10 => DropRarity.epico,
      < 35 => DropRarity.raro,
      _ => DropRarity.comun,
    };

    final pool = switch (rarity) {
      DropRarity.comun => _comun,
      DropRarity.raro => _raro,
      DropRarity.epico => _epico,
      DropRarity.legendario => _legendario,
    };

    final (title, emoji) = pool[rng.nextInt(pool.length)];

    return DropLoot(
      title: title,
      emoji: emoji,
      xpBonus: (_baseXp * rarity.xpMultiplier).round(),
      rarity: rarity,
    );
  }

  static String rarityLabel(DropRarity rarity) => switch (rarity) {
    DropRarity.comun => 'COMÚN',
    DropRarity.raro => 'RARO',
    DropRarity.epico => 'ÉPICO',
    DropRarity.legendario => 'LEGENDARIO',
  };
}
