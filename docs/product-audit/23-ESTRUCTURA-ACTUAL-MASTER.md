# 23 — Estructura real del sistema (medido sobre `master`)

> **Regla de esta medición:** nada de aquí sale de `docs/`. Todo está leído del
> árbol de **`master` (66a2362, 30-oct-2026)** con `git ls-tree`, `git grep` y
> `git show`. El *working tree* del checkout está en `fix/sentry-kotlin`
> (1ee3352, 26-oct) y **no es el sistema**: es una foto 160 commits más vieja.
>
> Reproducible con:
> `git ls-tree --name-only master:lib/features`, `git show master:lib/app/router.dart`,
> `git ls-tree -r --name-only master -- supabase/functions`,
> `git grep -n <patrón> master -- lib`.

---

## 0. El checkout no es el sistema

| | Working tree (`fix/sentry-kotlin`) | `master` (real) |
|---|---|---|
| Commit | 1ee3352 · 26-oct | 66a2362 · 30-oct |
| Archivos Dart en `lib/` | 140 | **244** |
| Features | 10 | **16** |
| Rutas | 14 | **21** |
| Edge Functions | 6 | **8** |
| Migraciones | 116 archivos | **215 archivos** |
| Archivos de test | 21 | **89** |
| `catch` vacíos | 68 | **0** |
| `docs/ARCHITECTURE.md` | existe | **no existe** (master tiene `architecture.md`) |

Los documentos que leí al principio (`AGENTS.md`, `ARCHITECTURE.md`,
`DATA_MODEL.md` del working tree) describen una app que ya no es esta. Los
`AGENTS.md`/docs de `master` sí están mantenidos, pero **también se quedan
cortos**: el `AGENTS.md` de master dice 20 rutas y 699 tests; el código tiene
21 rutas y 89 archivos de test.

---

## 1. Estructura de `lib/` en master

`lib/` = 244 archivos. Feature-first con capas (`data/`, `domain/`,
`presentation/`) y `core/` transversal.

| Bloque | Archivos | KB | Qué es |
|---|---|---|---|
| `features/dashboard` | 47 | 764 | Home, perfil, ajustes, progreso, catálogo de lecciones |
| `features/conversation` | 33 | 397 | Pipeline de voz, chat con tutor, evaluación, resumen |
| `core` | 39 | 162 | Tema, widgets, caché, servicios, i18n, constantes |
| `features/onboarding` | 21 | 222 | Wizard, test del Oráculo, mini-conversación |
| `features/economy` | 17 | 176 | Maná, oro, tienda, inventario, guardián |
| `features/missions` | 10 | 88 | Motor de misiones |
| `features/boss_exam` | 9 | 43 | **Nuevo**: examen de jefe por nivel |
| `features/notifications` | 9 | 39 | **Nuevo**: recordatorios locales |
| `features/listening` | 8 | 58 | **Nuevo**: ejercicios de escucha |
| `features/subscription` | 8 | 37 | Paywall, RevenueCat |
| `features/corrections` | 7 | 44 | **Nuevo**: corrección explícita por turno |
| `features/chat_rooms` | 6 | 163 | Gremio y salas de voz (LiveKit) |
| `features/auth` | 4 | 6 | Sesión Supabase, Google Sign-In |
| `features/home_widget` | 4 | 13 | **Nuevo**: widget de pantalla de inicio |
| `features/weekly_report` | 3 | 28 | **Nuevo**: informe semanal |
| `features/presence` | 3 | 4 | Presencia en salas |
| `features/vocabulary` | 3 | 30 | Repaso SRS |
| `l10n` | 8 | 757 | 3 ARB + generados |
| `app` | 4 | 26 | Router, splash, resolución de navegación |

**Lo que ha cambiado el producto desde la foto vieja:** se añadieron seis
features que no existían (`corrections`, `boss_exam`, `listening`,
`notifications`, `weekly_report`, `home_widget`). Eso mueve la app de "chat con
tutor + RPG" a un producto con **corrección explícita, examen de nivel, otra
modalidad (escucha), canal de retorno (notificaciones) y reporte semanal**.

---

## 2. Navegación real: 21 rutas

`lib/app/router.dart`: `/splash`, `/`, `/onboarding`, `/mini-conversation`,
`/oracle-test`, `/home`, `/voice-room`, `/conversation`, `/summary`, `/paywall`,
`/profile-edit`, `/chat-rooms`, `/shop`, `/inventory`, `/dungeon-guardian`,
`/boss-result`, `/my-errors`, `/weekly-report`, `/listening`, `/missions`.

Nuevas respecto a lo documentado en el working tree: **`/mini-conversation`,
`/boss-result`, `/my-errors`, `/weekly-report`, `/listening`, `/missions`**.

---

## 3. Servidor

`supabase/functions/` en master: **8 funciones** —
`evaluate-placement` (nueva: calcula y persiste el CEFR en servidor),
`lesson-generator`, `livekit-token`, `llm-proxy`, `missions-cron`,
`reactivation-email` (nueva), `revenuecat-webhook`, `sync-entitlement`.

`supabase/migrations/`: **215 archivos** (la doc dice 116). El baseline medido
en producción el 29-oct (`docs/runbooks/SCHEMA_BASELINE.md`) da **84 tablas, 130
políticas RLS, 0 tablas sin RLS**.

---

## 4. Calidad medida (no declarada)

| Señal | Valor en master |
|---|---|
| Archivos de test | 89 (`test/`), incluye goldens, SSE, contrato de router, RPC HTTP, golden set de evaluación de metas |
| `catch (_) {}` | **0** (el working tree tenía 68) |
| `TODO/FIXME` en `lib/` | 5 |
| Stubs obvios | 1 (`generateTtsAudio(...) async => ''`) |
| CI | 5 jobs: Flutter (analyze `--no-fatal-infos` + test + cobertura), goldens baseline manual, Edge Functions (`deno check` + `deno test`), `web_admin` (lint+test+build), summary |
| Cobertura | se publica en el resumen del run (no hay umbral mínimo) |

**Lo que el CI no hace:** no compila el AAB ni el APK. Un error de Gradle,
assets o manifest pasa con el pipeline en verde.

---

## 5. Dónde se concentra el riesgo del código actual

| Archivo | Tamaño | Por qué importa |
|---|---|---|
| `lib/features/dashboard/data/models/lesson_catalog.dart` | **300 KB** | Catálogo literal inmutable; toda la Ruta y el desbloqueo dependen de él |
| `lib/features/conversation/presentation/providers/conversation_providers.dart` | **115 KB** | Orquesta voz, LLM, evaluación, economía y cierre de sesión en un solo notifier |
| `lib/features/conversation/presentation/screens/conversation_screen.dart` | **100 KB** | Pantalla más grande del producto |
| `lib/features/dashboard/presentation/screens/settings_screen.dart` | 61 KB | Ajustes con lógica de datos |
| `lib/features/chat_rooms/presentation/screens/voice_room_screen.dart` | 58 KB | Salas de voz + gremio |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | 50 KB | Wizard completo en un archivo |

Señales de design system a medio adoptar en master: `AppSpacing` se usa **4
veces**, `AppElevation` **1**, frente a **384** `GoogleFonts.*` y **52**
`SnackBar(` crudos. Accesibilidad: **9** `Semantics(` y **6** `Tooltip(` en toda
la app.

---

## 6. Documentación vs código

| Afirmación documentada | Código en master |
|---|---|
| 10 features (`AGENTS` del working tree) | 16 |
| 14 rutas | 21 |
| 75 tablas / 120 políticas | 84 / 130 (baseline 29-oct) |
| 116 migraciones | 215 archivos |
| 171 pruebas | 89 archivos; `AGENTS.md` de master dice **699 casos** |
| `docs/ARCHITECTURE.md` | no existe en master (`architecture.md`) |
| "Sin iOS" | se mantiene: no hay `ios/` |
| "0 warnings, 127 infos" | coherente con `flutter analyze --no-fatal-infos` del CI |

**Conclusión:** la documentación del working tree está muerta; la de master está
viva pero se queda corta en features, rutas y migraciones. Cualquier trabajo
debe partir del código y, como mucho, usar `AGENTS.md` de master como índice.

---

## 7. Qué implica para el backlog (estado de las 24 historias)

| Historia | Estado real en master | Acción |
|---|---|---|
| W0-1 (árbol de trabajo, `.webp`) | Solo afecta al checkout local | Se resuelve al cambiar a master |
| W0-2 (mojibake) | **Vigente**: 51 líneas con doble codificación en `lib/` | Mantener |
| W0-3 (`claimDailyReward` → `add_gems`) | **Vigente**: sigue en `economy_repository_impl.dart:222` | Mantener |
| W0-4 (CI sin build) | **Vigente**: no hay job de AAB/APK | Mantener |
| W0-5 (consultas a producción) | Vigente | Mantener |
| W0-6 (tap muerto `GlassCard`) | **Vigente**: `voice_room_screen.dart:688-690` sigue envolviendo el `GlassCard` en un `GestureDetector`, y el `GlassCard` de master conserva su detector interno | Mantener |
| W0-7 (`saveMessage` secuencia) | **Ya no aplica**: `sequence_number` no existe en `lib/` | Cerrar |
| SEC-1 (guard de RLS) | Vigente como regresión | Mantener |
| SEC-2 (recompensas de misión) | Vigente (vector vivo) | Mantener |
| SEC-3 (`add_aura_xp`) | Vigente (`GRANT` a `authenticated`) | Mantener |
| SEC-4 (`guard_language_profile`) | Vigente (delete + insert) | Mantener |
| SEC-5 (maná/timeout) | **Vigente parcial**: no hay `AbortSignal`; `MANA_CHARGE_MODE` cae en `capability` | Mantener |
| SEC-6 (prompts en cliente) | Vigente: hay prompts también en la curación de vocabulario (`conversation_repository_impl.dart:642`) | Mantener |
| DAT-1 (staging/`db reset`) | Vigente | Mantener |
| DAT-2 (currículo único) | **Parcial**: ya existe `lesson_key` en `recommended_path.dart` | Reducir alcance |
| DAT-3 (vocabulario N+1) | **Hecho**: master usa `curate_session_vocabulary` (SECURITY DEFINER) con traducción real, no el diccionario de 21 palabras | Cerrar |
| DAT-4 (retención de contenido) | Vigente: `messages`/`conversations` sin política | Mantener |
| DAT-5 (contratos de API) | **Muy avanzado**: 89 tests incl. `conversation_repository_http_test` | Reducir alcance |
| APP-1 (`catch` mudos) | **Hecho**: 0 en master | Cerrar |
| APP-2 (i18n al 100 %) | **Hecho**: 1 292 claves en `en`, `es` y `pt`, 0 faltantes | Cerrar |
| APP-3 (design system) | Vigente: 384 `GoogleFonts`, 4 `AppSpacing`, 52 `SnackBar` | Mantener |
| APP-4 (accesibilidad) | Vigente: 9 `Semantics`, 6 `Tooltip` | Mantener |
| APP-5 (responsive/tests) | Re-verificar contra los 89 tests | Revisar |
| APP-6 (estados honestos) | Parcial: desaparecieron los datos falsos del dashboard | Reducir alcance |

---

## 8. Cómo funciona hoy el núcleo de aprendizaje

```
ConversationScreen
  mic (tap u hold-to-talk, umbral 300 ms, cancelación a 96 px)
    → startRecording (permiso + pre-chequeo de maná) → record AAC 16 kHz
    → stopRecording (≥100 bytes) → llm-proxy /transcribe (Groq, language=en)
    → TutorPromptBuilder.build(perfil + lección + metas + errores + banda CEFR)
    → llm-proxy /chat (deepseek-v4-flash, SSE, action_code) → SseChatDecoder
    → burbuja en streaming + flutter_tts (en-US, 0.48)
    → en segundo plano: messages, fluency, goal_eval, correction_turn
  cierre → endSession → close_session → recompensas
```

- **No hay `conversation_flow.dart`**: todo vive en `ConversationNotifier`
  (`conversation_providers.dart:95`), incluido el cierre de sesión.
- **Historial**: últimos 12 mensajes, `max_tokens: 200`, 3 reintentos.
- **Idioma**: nativo elegible (8 opciones); objetivo **fijo en inglés** en
  prompt, STT y TTS. El CEFR lo decide `evaluate-placement` en servidor.
- **Correcciones**: máximo 6 por sesión, gate de ≥5 palabras, nunca duplican
  `goal_eval`; se guardan en `corrections` con upsert idempotente y son
  **gratuitas** (`correction_turn` ∈ `FREE_ACTIONS`).
  `my_errors_screen` agrupa por tipo.
- **Examen de jefe**: no sustituye al Oráculo; reutiliza `ConversationScreen`
  con `mode=promotion`, 8 turnos / 12 min, 5 respuestas, rúbrica de 6
  dimensiones, decisión y cooldown de 12 h en servidor, checkpoint cada 10
  lecciones.
- **Listening**: 3 ejercicios sembrados (A1, A2, B1), TTS propio, corrección
  local = regla del servidor, submit por RPC, visible en la Ruta.
- **Onboarding**: nativo → objetivo → Oráculo → personaje; después
  `/mini-conversation` (2 turnos, A1-A2, `guild_chat` gratis, sin persistencia,
  marca en SharedPreferences).

### Los 8 riesgos del núcleo (todos verificados)

| # | Riesgo | Evidencia |
|---|---|---|
| 1 | **Evidencia del jefe desalineada**: el cliente exige 5 respuestas; el servidor exige 5 respuestas **y 25 palabras**. Con respuestas cortas el examen queda abierto con error | `boss_exam_rules.dart:34` vs `llm-proxy/index.ts:63,337` |
| 2 | **`mode` no manda en el servidor**: las reglas de jefe se activan por `placement_assessed_at`. Un usuario ya evaluado que entra por «ORÁCULO» cae en reglas de jefe sin HUD ni pantalla de resultado | `index.ts:298-301,332`; `dashboard_screen.dart:506` |
| 3 | **Gate duplicado y divergente**: si `boss_exam_status` falla, la tarjeta usa «80 % de lecciones»; el servidor exige metas + minutos + racha + cooldown → tarjeta tappable que el servidor rechaza | `boss_exam_card.dart:41` vs `20261029210612:113,130` |
| 4 | **Chip de corrección mal anclado**: en la ruta `goal_eval` se llama sin `messageText` y la persistencia va en background con el flag liberado antes; el chip puede apuntar al mensaje siguiente | `conversation_providers.dart:2081` vs `:2216`, `:1849` |
| 5 | **Integridad de `corrections`**: las escribe el cliente (RLS insert own) y alimentan `user_recurring_errors`, que entra al prompt del tutor. Un cliente manipulado inyecta su propio historial | `corrections_repository.dart:58`; `tutor_prompt_builder.dart:108` |
| 6 | **Listening solo cubre A1/A2/B1**: PRE-A1, B2, C1 y C2 no ven tarjeta; `loadProgress` devuelve vacío al fallar → 0/0 silencioso | `listening_repository.dart:35,107` |
| 7 | **«Prueba de valor de 60 s» no existe**: la mini-conversación son 2 turnos con timeout de 20 s, y solo aparece al completar el onboarding, no a usuarios existentes | `mini_conversation_script.dart:23`; `mini_conversation_providers.dart:190` |
| 8 | **`BossExamRules.decide` no se usa**: el espejo local del veredicto solo vive en tests; no hay fallback si el servidor no manda decisión | `boss_exam_rules.dart:40-69` |

**Docs contra código (tercera tanda):** `architecture.md:95` describe
`llm-proxy /stt` y el código llama `/transcribe`; `architecture.md:57` promete
«prueba de valor de 60 s» que no existe; `GOAL_EVALUATION.md` dice «una sola
llamada `goal_eval`» cuando P-29-b añade hasta 6 `correction_turn`; `AGENTS.md`
dice 699 tests y el conteo estático da ~715.

---

## 9. Servidor: quién escribe cada cosa (verificado en migraciones de master)

**Costes de maná** (`20260813_mana_aura_redesign.sql:465-469`,
`20260818_01:195-201`): `dungeon_turn` 12 · `free_chat_turn` 8 · `oracle_turn`
15 · `oracle_eval` 30 · `lesson_generation` 100. Gratis: `goal_eval`,
`carisma_eval`, `guild_chat`, `stt_transcribe` y `correction_turn`.

**El cobro vive en el proxy**, antes del modelo (`llm-proxy/index.ts:445`), con
`consume_mana` por `service_role`; sin saldo → `402 no_mana`. El cliente ya no
cobra (`consumeMana` sobrevive sin llamadores).

| Recurso | Quién puede escribirlo hoy |
|---|---|
| Maná | RPC `consume_mana` (`authenticated` **y** `service_role`), `refund_failed_turn` (`authenticated`), gracia/reembolso (`service_role`) |
| Oro | `INSERT`/`DELETE` directo de `user_language_profiles`; el `UPDATE` lo bloquea el guard. RPC: `close_session`, `claim_mission_reward`, `claim_session_drop` |
| XP | Igual que oro |
| Aura | `INSERT`/`DELETE` del perfil **y** `add_aura_xp` con parámetros del cliente (`20260813:299,443`) |
| Racha | `player_streaks` directo desde el cliente (solo `streak_freezes` tiene tope) y RPC `register_practice` |
| Plan | Nadie: solo `sync_entitlement` y el webhook (`service_role`) |

**Los cinco agujeros vivos** (detalle en SEC-2/4/5 del backlog):

1. **El perfil es autoeditable** (`profiles_self` es `FOR ALL` y el guard solo
   cubre `UPDATE`): `DELETE` + `INSERT` fija saldos, racha y CEFR. Es el agujero
   maestro; invalida los otros.
2. **Misiones**: el cliente inserta `xp_reward`/`gem_reward`/`reward_multiplier`
   y `advance_my_missions` acepta delta libre.
3. **Drop de sesión**: `claim_session_drop` acepta un id inventado y objetivos
   declarados.
4. **Reembolsos**: `refund_failed_turn` devuelve el coste de cualquier débito de
   los últimos 5 min con un `ref_id` que elige el cliente.
5. **Modo de cobro**: `MANA_CHARGE_MODE` cae en `capability` (el cliente decide
   si se le cobra).

**Superficie de servidor:** 8 Edge Functions, 3 jobs de cron
(`rotate-daily-missions` 00:05, `clean-old-logs` 03:15,
`purge-stale-participants` cada minuto), 174 archivos `.sql`, sin
`supabase/config.toml`. Sentry está inerte sin `SENTRY_DSN`.

**Docs contra código (segunda tanda):**

| Documento | Afirma | Código |
|---|---|---|
| `docs/OPERATIONS.md:62` | `MANA_CHARGE_MODE` es `all` por defecto | Cae en `capability` (`validation.ts:36-44`); el mismo doc se contradice en `:216-222` |
| `docs/DATA_MODEL.md:140` y `architecture.md:119` | se escribe en `retention_events` | Esa tabla no existe; el cliente escribe `analytics_events` (`retention_analytics.dart:35`) |
| `AGENTS.md:77` vs `DATA_MODEL.md:5` | 88/134/92/101 vs 89/134/98 | El repo tiene 174 `.sql`; ninguna cifra es reproducible |
| `AGENTS.md:81` | «la app solo lee `user_subscriptions` y `payments`» | Cierto, pero escribe `user_language_profiles`, `player_streaks`, `mission_instances` y `user_scenario_goals` |

---

## 10. Qué haría distinto a partir de aquí

1. **Trabajar sobre master.** El checkout actual no debe recibir código nuevo.
2. **Re-derivar el backlog con esta tabla**: 4 historias se cierran (W0-7,
   APP-1, APP-2 y DAT-3) y 3 reducen alcance (DAT-2, DAT-5, APP-6). El resto
   sigue vivo.
3. **Un solo criterio de verdad**: `AGENTS.md` de master como índice, pero
   nunca como fuente de números.
4. **Añadir al CI el build del AAB** (W0-4): hoy es el único agujero que
   permite publicar una release rota con el pipeline en verde.
5. **Tres historias nuevas** que el núcleo de aprendizaje exige y que el backlog
   actual no cubre:
   - **EXAM-1** · Examen de jefe con una sola fuente de verdad (riesgos 1, 2, 3
     y 8): cliente y servidor con la misma evidencia, `mode` respetado en
     servidor, gate único y fallback local del veredicto.
   - **COR-1** · Correcciones ancladas al turno correcto e íntegras (riesgos 4 y
     5): `turn_ref` del servidor, el chip no se cruza de turno y `corrections`
     no es escribible por el cliente si alimenta el prompt.
   - **PRD-9** · Cobertura y promesa de las modalidades nuevas (riesgos 6 y 7):
     listening para todos los niveles o decisión de recortarlo, y decidir si la
     mini-conversación es «prueba de valor» (60 s) o 2 turnos.
