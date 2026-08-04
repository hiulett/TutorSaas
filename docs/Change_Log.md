# Change_Log — TutorSaas / Dungeon of English

> Registro de cambios global. Actualizado: 2026-07-30.

## 2026-07-30 — Implementación Fases 2–6 (segunda parte del día)

### Backlog y seguimiento
- Creados `docs/BACKLOG.md` (27 tareas) y `docs/TASK_BOARD.md` (seguimiento visual).

### DB live (aplicada por el usuario vía SQL Editor)
- RPCs: `add_xp`, `add_gems`, `spend_gems`, `increment_pergaminos_max`.
- Columnas: `user_settings.ui_language/learning_language/ai_explanations_native`.
- Mission Engine: 8 tablas + 29 plantillas.

### Fase 2 — User Experience
- `app.dart`: ConsumerWidget + l10n reactivo (T-100).
- Onboarding persiste idioma (T-101); `country_code` (T-104); Oracle conversacional (T-103).
- Scripts SQL editor: idioma, country_code.

### Fase 3 — Dashboard
- `HunterHudHeader` (mana gem, XP, título, racha); `DungeonMapScreen` (gateways CEFR);
  HunterStatus refinado (SegmentedBar/AnimatedCounter); accesos rápidos.

### Fase 4 — Conversations
- Header Oráculo (rango SSS) + SegmentedBar 10 segmentos; `LiveGoalsTrackerBar` con barra;
  `FloatingReward` en metas; selector de tácticas conectado.

### Fase 5 — Missions
- Modelos GuildMission/GlobalEvent; repo gremio+eventos+progresión parcial; MissionBoard en dashboard;
  rotación (fn SQL + edge function local + lazy).

### Fase 6 — Economy
- Fix `claimDailyReward`; inventario; battle pass; daily rewards modal; oro/fragmentos (RPC add_fragments);
  loot en conversaciones; invocaciones↔IA; balance por nivel + catálogo.

### Transversal
- Fix `overflow_test` (pump fijo) → **13/13 tests**.
- Fix voice room: `_isLocalRoom` para slugs no-UUID.

### Verificación final
- `flutter analyze` 0 errores (60 infos/warnings tolerados) · `flutter test` 13/13 · `flutter build apk --debug` OK.

## 2026-07-30 (primera parte del día)
- Auditorías Fase 0/1 (`docs/00…06`), docs por fase (5×10), docs globales, BACKLOG + TASK_BOARD.

