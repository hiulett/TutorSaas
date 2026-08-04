# Fase 7 — Guild · Implementation_Plan

> Plan de tareas atómicas del Guild. Fuente de verdad: `docs/07_Guild/Analysis.md`.

## Contexto
El Guild es actualmente una lista de salas de voz con moderación y habla simuladas. Objetivo: convertirlo en el lobby principal de la experiencia RPG (MMORPG), con propósito por mesa, quest board, NPC y economía visible.

## Tareas (orden de ejecución)

### G-A · Seed de mesas en DB + columna `room_type` — P0
- **Objetivo:** eliminar las 4 mesas hardcodeadas (`guild_table_1..4`) migrándolas a `chat_rooms` con seed SQL.
- **DB:** `ALTER TABLE chat_rooms ADD COLUMN room_type VARCHAR(20) DEFAULT 'discussion'` + INSERT de 4 mesas (Taberna del Aprendiz, Mesa Redonda, Consejo Supremo, Cámara del Archimago) con `is_active=true`.
- **Aceptación:** `getRooms` ya no contiene `guild_table_*` hardcodeados.
- **Riesgo:** bajo · **Rollback:** migración reversible.

### G-B · Refactor `getRooms` (leer de DB, sin hardcode, filtrar is_active) — P0
- **Objetivo:** `getRooms` lee SOLO de `chat_rooms` con `is_active=true`, evita N+1 (una query con counts por participante agregado).
- **Aceptación:** las mesas default aparecen desde DB; sala cerrada no aparece.
- **Dependencias:** G-A · **Riesgo:** medio.

### G-C · Guild Quest Board en el Gran Salón — P1
- **Objetivo:** widget que consume `guild_quest_pool` (seed existente) + `guild_collaborative_missions` (repo T-400) con filtros por tipo y progreso.
- **Aceptación:** el salón muestra misiones diarias/semanales/colaborativas con barra de progreso.
- **Dependencias:** — · **Riesgo:** bajo.

### G-D · i18n + tipografía del Gran Salón — P1
- **Objetivo:** strings del salón → `AppLocalizations`; `orbitron` → `spaceGrotesk`.
- **Aceptación:** analyze 0 errores; sin strings hardcoded críticos en el salón.
- **Riesgo:** bajo.

### G-E · Modo práctica IA en sala (Oráculo) — P1
- **Objetivo:** al entrar como oyente, poder "hablar con el Oráculo" dentro de la mesa usando el pipeline de voz existente (T-506 ya limita invocaciones).
- **Aceptación:** en la sala, botón "HABLAR CON EL ORÁCULO" inicia conversación IA.
- **Dependencias:** T-506 · **Riesgo:** alto (integra con conversación).

### G-F · NPC Maestre de Mesa — P1
- **Objetivo:** banner del NPC que da bienvenida al salón y sugiere mesas según CEFR del jugador.
- **Aceptación:** el salón muestra un NPC con sugerencias personalizadas.
- **Riesgo:** bajo.

### G-G · HUD de prestigio del gremio — P2
- **Objetivo:** mostrar `guild_battle_pass` (T-502) + reputación en el encabezado del salón.
- **Dependencias:** T-502 · **Riesgo:** bajo.

### G-H · Categorías desde DB + paginación — P2
- **Objetivo:** categorías dinámicas (`SELECT DISTINCT category`) y paginación/`limit` en `getRooms`.
- **Riesgo:** medio.

## Orden recomendado
G-A → G-B → G-D (rápidas, desbloquean el resto) → G-C → G-F → G-E → G-G → G-H.

## Criterios de terminación de la Fase 7
- `flutter analyze` 0 errores · `flutter test` verde · build apk OK.
- Gran Salón con mesas reales desde DB, quest board, NPC y economía visible.
- Sin mesas hardcodeadas ni habla/modernación simuladas.
