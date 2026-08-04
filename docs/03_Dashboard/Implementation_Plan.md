# Fase 3 — Implementation_Plan

> Plan de implementación (PRIORIZADO). Sin implementación realizada aún — documentación.

## Objetivo

Dashboard definitivo según `hunter_control_center_dashboard`: HUD, stats, navegación,
accesos rápidos e indicadores visuales, unificando Dashboard + Guild.

## Pasos

### 3.1 HUD central (P0)
1. Encabezado HUD: mana gem / MP, XP y nivel CEFR, título equipado, notificaciones.
2. Reutilizar `ManaMeterWidget`, `SegmentedBar`, `AnimatedCounter`, `RpgAvatar`.
3. Indicadores visuales (glow, runas) mediante `GlassCard` con `showRunicCorners`.

### 3.2 Unificación Dashboard + Guild (P0)
1. Tab GUILD con contenido inline (social hall: raid rooms, gremio) en lugar de solo empujar ruta.
2. Mantener acceso profundo a `/chat-rooms`.

### 3.3 Hunter Status refinado (P1)
1. Reemplazar `GoogleFonts.orbitron` por la tipografía estándar.
2. Añadir `SegmentedBar` a stats y rangos; animar con `AnimatedCounter`.

### 3.4 Accesos rápidos e indicadores (P1)
1. Quick access a `/shop`, `/oracle-test`, `/level-exam`, `/settings`.
2. Badges/indicadores de recompensas y misiones activas.

### 3.5 QA del leaderboard (P1)
1. Corregir `overflow_test.dart` (pumpAndSettle timeout).

## Criterios de terminación

- `flutter analyze` 0 errores; `flutter test` verde.
- Paridad visual con `hunter_control_center_dashboard` y `hunter_status_profile_system`.
- Navegación Dashboard ↔ Guild ↔ Status ↔ Config fluida.
