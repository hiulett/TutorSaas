# Fase 6 — Architecture

> Arquitectura del módulo de Economía.

## Módulos

```
lib/features/economy/
├── data/repositories/economy_repository_impl.dart    # 355 líneas
├── domain/repositories/economy_repository.dart        # interfaz (13 métodos)
└── presentation/
    ├── providers/economy_providers.dart               # 5 providers
    ├── screens/shop_screen.dart                       # /shop (301 líneas)
    └── widgets/nucleo_arcano_limit_screen.dart
```

## Diseño desacoplado

- **UI → Providers → EconomyRepository (interfaz) → EconomyRepositoryImpl → Supabase.**
- La UI nunca toca Supabase directamente; la economía es consumible por missions/conversation.
- RPCs: `add_gems`, `spend_gems`, `increment_pergaminos_max`.

## Flujo

```
Daily state: getDailyState → useInvocation/canInvoke → límite + bonus por racha
Streak:      getStreak → updateStreak (diff días) → recompensa escalonada
Tienda:      purchaseItem → spendGems → insert player_inventory
Inventario:  getInventory → toggleEquip
```

## Decisiones

- Clean architecture con interfaz abstracta (`EconomyRepository`) — único módulo económico
  con esta disciplina completa.
- Estado con `FutureProvider.autoDispose`.
- RLS por usuario (`auth.uid()`) en inventario/estado/rachas/battle pass/pergaminos;
  lectura autenticada en catálogo/pool.

## Gaps

1. `guild_battle_pass` sin capa de acceso.
2. Oro (`total_gold`) sin lógica.
3. `claimDailyReward` tiene bug (Future como valor en update).
