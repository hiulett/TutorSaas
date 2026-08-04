# Informe de Migración — Textos Hardcodeados → ARB

> Fecha: 2026-08-02 · Complementa `01_Current_Audit.md` (inventario) y `02_Architecture.md` (arquitectura objetivo).
> Este documento NO modifica código: define el inventario de migración, la estrategia por archivo (clave ARB → reemplazo) y el plan de ejecución por lotes.

---

## 1. Resumen ejecutivo

- **~69 cadenas** `Text(...)` hardcodeadas repartidas en **20 archivos** (`01_Current_Audit.md` §4.1), más una **capa secundaria** de `labelText` / `hintText` / `title` / `subtitle` / `tooltip` (~74 apariciones, §4.2) y 17 títulos de lecciones en `lesson_catalog.dart` (contenido de datos, no UI).
- Mecanismo objetivo: **Flutter l10n oficial** — claves nuevas en `lib/l10n/app_en.arb` (origen), `app_es.arb`, `app_pt.arb`; acceso con `AppLocalizations.of(context)!.clave`; regeneración con `flutter gen-l10n`.
- Criterio de éxito por archivo: **cero literales de UI**; `flutter analyze` sin errores nuevos; traducción visible en los 3 idiomas.
- Estimación total: **~5,5 días hábiles** de trabajo concentrado en migración (excluye infraestructura de arquitectura y QA, que se planifican en `08_Task_List.md`).

---

## 2. Convención de claves ARB

La base actual usa claves planas en `snake_case` con prefijo de contexto (`welcome_title`, `chat_rooms`, `settings`, `save_settings`). Para las claves nuevas se mantiene el mismo estilo:

| Regla | Ejemplo |
|---|---|
| Minúsculas, `snake_case`, prefijo de feature | `chat_rooms_ai_training`, `profile_xp_total` |
| Sufijo descriptivo del texto | `_title`, `_empty`, `_error`, `_hint`, `_tooltip`, `_label` |
| Claves compartidas cuando el texto es idéntico en varias pantallas | `view_all` (perfil + progreso), `missions_claim` (tablero de misiones + battle pass) |
| Interpolación con placeholder `{nombre}` | `chat_rooms_prestige`: `'PRESTIGIO {level}'` |
| Preferir reutilizar claves existentes antes que duplicar | `cancel`, `back`, `close`, `app_name` ya existen |

Al añadir una clave: editarla en los 3 `.arb` y ejecutar `flutter gen-l10n` antes de que la clave resuelva.

---

## 3. Inventario de migración por archivo

> Formato: `archivo:línea` — `cadena actual` → `clave ARB propuesta` → reemplazo. Para cadenas con interpolación se indica el placeholder.

### 3.1 chat_rooms — `chat_rooms_screen.dart` (9 cadenas)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 212 | `'Idioma de Caza:'` | `chat_rooms_hunt_language` | `Text(AppLocalizations.of(context)!.chatRoomsHuntLanguage)` |
| 220 | `'Puntos de Experiencia:'` | `chat_rooms_xp_points` | `Text(AppLocalizations.of(context)!.chatRoomsXpPoints)` |
| 314 | `'ENTRENAMIENTO IA'` | `chat_rooms_ai_training` | `Text(AppLocalizations.of(context)!.chatRoomsAiTraining)` |
| 315 | `'MENTORÍA (RESONANCIA)'` | `chat_rooms_mentorship` | `Text(AppLocalizations.of(context)!.chatRoomsMentorship)` |
| 316 | `'EVENTO ESPECIAL'` | `chat_rooms_special_event` | `Text(AppLocalizations.of(context)!.chatRoomsSpecialEvent)` |
| 334 | `'CANCEL'` | reutilizar `cancel` *(existe)* | `Text(AppLocalizations.of(context)!.cancel)` |
| 362 | `'Error al crear sala: $e'` | `chat_rooms_error_create_room` `{error}` | `Text(AppLocalizations.of(context)!.chatRoomsErrorCreateRoom(e))` |
| 374 | `'INITIALIZE'` | `chat_rooms_initialize` | `Text(AppLocalizations.of(context)!.chatRoomsInitialize)` |
| 882 | `'PRESTIGIO $level'` | `chat_rooms_prestige` `{level}` | `Text(AppLocalizations.of(context)!.chatRoomsPrestige(level))` |

### 3.2 dashboard — `profile_screen.dart` (7)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 220 | `'XP Total'` | `profile_xp_total` | `Text(AppLocalizations.of(context)!.profileXpTotal)` |
| 243 | `'Racha activa'` | `profile_active_streak` | `Text(AppLocalizations.of(context)!.profileActiveStreak)` |
| 266 | `'Nivel CEFR'` | `profile_cefr_level` | `Text(AppLocalizations.of(context)!.profileCefrLevel)` |
| 376 | `'VER TODO'` | `view_all` *(compartida)* | `Text(AppLocalizations.of(context)!.viewAll)` |
| 447 | `'Error al cargar vocabulario'` | `profile_error_loading_vocabulary` | `Text(AppLocalizations.of(context)!.profileErrorLoadingVocabulary)` |
| 555 | `'No hay vocabulario para mostrar'` | `profile_empty_vocabulary` | `Text(AppLocalizations.of(context)!.profileEmptyVocabulary)` |
| 615 | `'Cerrar'` | reutilizar `close` *(si existe, si no `profile_close`)* | `Text(AppLocalizations.of(context)!.close)` |

### 3.3 dashboard — `profile_edit_screen.dart` (7)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 219 | `'CAMERA'` | `profile_edit_camera` | `Text(AppLocalizations.of(context)!.profileEditCamera)` |
| 238 | `'GALLERY'` | `profile_edit_gallery` | `Text(AppLocalizations.of(context)!.profileEditGallery)` |
| 608 | `'SPANISH (ES)'` | `language_spanish` | `Text(AppLocalizations.of(context)!.languageSpanish)` |
| 609 | `'ENGLISH (EN)'` | `language_english` | `Text(AppLocalizations.of(context)!.languageEnglish)` |
| 610 | `'FRENCH (FR)'` | `language_french` | `Text(AppLocalizations.of(context)!.languageFrench)` |
| 611 | `'GERMAN (DE)'` | `language_german` | `Text(AppLocalizations.of(context)!.languageGerman)` |
| 612 | `'PORTUGUESE (PT)'` | `language_portuguese` | `Text(AppLocalizations.of(context)!.languagePortuguese)` |

> Nota: los selectores de idioma nativo/objetivo del perfil se **centralizan en Settings** según `02_Architecture.md` §5. Las claves `language_*` se reutilizan como etiquetas de idioma; el bloque selector de `:608-612` se redirige o elimina.

### 3.4 dashboard — `progress_tab_view.dart` (5)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 274 | `'Puntos XP'` | `progress_xp_points` | `Text(AppLocalizations.of(context)!.progressXpPoints)` |
| 293 | `'Racha Activa'` | `progress_active_streak` | `Text(AppLocalizations.of(context)!.progressActiveStreak)` |
| 312 | `'Nivel Activo'` | `progress_active_level` | `Text(AppLocalizations.of(context)!.progressActiveLevel)` |
| 453 | `'Repaso SRS'` | `progress_srs_review` | `Text(AppLocalizations.of(context)!.progressSrsReview)` |
| 464 | `'VER TODO'` | reutilizar `view_all` | `Text(AppLocalizations.of(context)!.viewAll)` |

### 3.5 missions — `mission_board_widget.dart` (4)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 68 | `'ACEPTAR'` | `missions_accept` | `Text(AppLocalizations.of(context)!.missionsAccept)` |
| 93 | `'SIN MISIONES ACTIVAS'` | `missions_empty` | `Text(AppLocalizations.of(context)!.missionsEmpty)` |
| 109 | `'GENERAR MISIONES'` | `missions_generate` | `Text(AppLocalizations.of(context)!.missionsGenerate)` |
| 143 | `'RECLAMAR'` | `missions_claim` *(compartida)* | `Text(AppLocalizations.of(context)!.missionsClaim)` |

### 3.6 vocabulary — `srs_flashcard_modal.dart` (4)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 146 | `'CLOSE'` | `srs_close` | `Text(AppLocalizations.of(context)!.srsClose)` |
| 238 | `'HARD'` | `srs_hard` | `Text(AppLocalizations.of(context)!.srsHard)` |
| 250 | `'NORMAL'` | `srs_normal` | `Text(AppLocalizations.of(context)!.srsNormal)` |
| 262 | `'EASY'` | `srs_easy` | `Text(AppLocalizations.of(context)!.srsEasy)` |

### 3.7 economy — `inventory_screen.dart` (4)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 125 | `'No se pudo cargar el inventario'` | `inventory_error_load` | `Text(AppLocalizations.of(context)!.inventoryErrorLoad)` |
| 134 | `'INVENTARIO VACÍO'` | `inventory_empty` | `Text(AppLocalizations.of(context)!.inventoryEmpty)` |
| 138 | `'VISITA LA TIENDA →'` | `inventory_visit_shop` | `Text(AppLocalizations.of(context)!.inventoryVisitShop)` |
| 244 | `'EQUIPADO'` | `inventory_equipped` | `Text(AppLocalizations.of(context)!.inventoryEquipped)` |

### 3.8 chat_rooms — `voice_room_screen.dart` (3)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 220 | `'No messages in this chamber yet.'` | `voice_room_empty` | `Text(AppLocalizations.of(context)!.voiceRoomEmpty)` |
| 432 | `'LIVE'` | `voice_room_live` | `Text(AppLocalizations.of(context)!.voiceRoomLive)` |
| 882 | `'Error en sala: $err'` | `voice_room_error` `{error}` | `Text(AppLocalizations.of(context)!.voiceRoomError(err))` |

### 3.9 conversation — `level_exam_screen.dart` (3)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 431 | `'MUTE'` | `level_exam_mute` | `Text(AppLocalizations.of(context)!.levelExamMute)` |
| 441 | `'CONCLUDE RAID'` | `level_exam_conclude_raid` | `Text(AppLocalizations.of(context)!.levelExamConcludeRaid)` |
| 503 | `'RETURN TO SANCTUARY'` | `level_exam_return_sanctuary` | `Text(AppLocalizations.of(context)!.levelExamReturnSanctuary)` |

### 3.10 conversation — `conversation_screen.dart` (3)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 196 | `'Metas del Escenario:'` | `conversation_scenario_goals` | `Text(AppLocalizations.of(context)!.conversationScenarioGoals)` |
| 218 | `'Frases Clave Sugeridas (Useful Phrases):'` | `conversation_useful_phrases` | `Text(AppLocalizations.of(context)!.conversationUsefulPhrases)` |
| 482 | `'Fonemas recomendados a practicar:'` | `conversation_recommended_phonemes` | `Text(AppLocalizations.of(context)!.conversationRecommendedPhonemes)` |

### 3.11 subscription — `paywall_screen.dart` (3)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 84 | `'Thank you for subscribing! Premium benefits unlocked.'` | `paywall_success_message` | `Text(AppLocalizations.of(context)!.paywallSuccessMessage)` |
| 94 | `'Purchase failure: $e'` | `paywall_error_purchase` `{error}` | `Text(AppLocalizations.of(context)!.paywallErrorPurchase(e))` |
| 162 | `'Purchases successfully restored.'` | `paywall_restored` | `Text(AppLocalizations.of(context)!.paywallRestored)` |

### 3.12 dashboard — `session_summary_screen.dart` (3)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 480 | `'VER VOCABULARIO'` | `session_summary_view_vocabulary` | `Text(AppLocalizations.of(context)!.sessionSummaryViewVocabulary)` |
| 483 | `'Vocabulario guardado en tu perfil.'` | `session_summary_vocab_saved` | `Text(AppLocalizations.of(context)!.sessionSummaryVocabSaved)` |
| 502 | `'LISTO'` | `session_summary_done` | `Text(AppLocalizations.of(context)!.sessionSummaryDone)` |

### 3.13 economy — `nucleo_arcano_limit_screen.dart` (3)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 207 | `'RECARGAR +5'` | `nucleo_recharge_5` | `Text(AppLocalizations.of(context)!.nucleoRecharge5)` |
| 248 | `'IR PREMIUM'` | `nucleo_go_premium` | `Text(AppLocalizations.of(context)!.nucleoGoPremium)` |
| 250 | `'Invocaciones Ilimitadas — Cazador de Élite'` | `nucleo_unlimited_invocations` | `Text(AppLocalizations.of(context)!.nucleoUnlimitedInvocations)` |

### 3.14 dashboard — `recommended_lessons_hub.dart` (2)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 158 | `'Salas de Voz'` | `recommended_voice_rooms` | `Text(AppLocalizations.of(context)!.recommendedVoiceRooms)` |
| 471 | `'Ver Objetivos'` | `recommended_view_goals` | `Text(AppLocalizations.of(context)!.recommendedViewGoals)` |

### 3.15 economy — `battle_pass_screen.dart` (2)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 102 | `'No se pudo cargar el Battle Pass'` | `battle_pass_error_load` | `Text(AppLocalizations.of(context)!.battlePassErrorLoad)` |
| 222 | `'RECLAMAR'` | reutilizar `missions_claim` | `Text(AppLocalizations.of(context)!.missionsClaim)` |

### 3.16 dashboard — charts/`practice_heatmap.dart` (2)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 89 | `'Hace 4 semanas'` | `heatmap_four_weeks_ago` | `Text(AppLocalizations.of(context)!.heatmapFourWeeksAgo)` |
| 90 | `'Hoy'` | `heatmap_today` | `Text(AppLocalizations.of(context)!.heatmapToday)` |

### 3.17 dashboard — charts/`fluency_latency_chart.dart` (2)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 51 | `'WPM'` | `chart_wpm` | `Text(AppLocalizations.of(context)!.chartWpm)` |
| 55 | `'Latencia (s)'` | `chart_latency_seconds` | `Text(AppLocalizations.of(context)!.chartLatencySeconds)` |

### 3.18 economy — `collections_screen.dart` (1)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 102 | `'No se pudieron cargar las colecciones'` | `collections_error_load` | `Text(AppLocalizations.of(context)!.collectionsErrorLoad)` |

### 3.19 dashboard — `next_recommended_lesson_hero.dart` (1)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 397 | `'Entendido'` | `common_got_it` | `Text(AppLocalizations.of(context)!.commonGotIt)` |

### 3.20 conversation — `live_goals_tracker_bar.dart` (1)

| Línea | Cadena actual | Clave propuesta | Reemplazo |
|---|---|---|---|
| 145 | `'M${widget.index}'` | `live_goals_marker` `{index}` | `Text(AppLocalizations.of(context)!.liveGoalsMarker(index))` |

### 3.21 Capa secundaria — `labelText` / `hintText` / `title` / `subtitle` / `tooltip`

| Ubicación | Cadena / tipo | Clave propuesta |
|---|---|---|
| `app.dart:17` | `title: 'Dungeon of English'` | reutilizar `app_name` *(existe)* |
| `onboarding_screen.dart:773` | `hintText: 'Buscar país...'` | `onboarding_search_country` |
| `oracle_conversation_screen.dart:229,581,589-590` | hint, tooltip, títulos de voz | `oracle_*` (p.ej. `oracle_voice_hint`, `oracle_exit_tooltip`) |
| `settings_screen.dart:118-1118` | **23 títulos de opciones hardcodeados** | `settings_*` (una clave por sección/opción) |
| `conversation_screen.dart:880` | `hintText: 'Escribe tu mensaje en inglés...'` | `conversation_message_hint` |
| `voice_room_screen.dart:268,459` | `hintText: 'Type a message...'`, `tooltip: 'Salir de la sala'` | `voice_room_message_hint`, `voice_room_exit_tooltip` |
| `daily_reward_modal.dart:65-66` | `'RECOMPENSA DIARIA'`, `'RACHA ACTUAL: $streak DÍAS'` | `daily_reward_title`, `daily_reward_streak` `{streak}` |
| `hunter_hud_header.dart:205,210` | tooltips `'Notificaciones'`, `'Misiones'` | `hud_notifications`, `hud_missions` |
| `hunter_status_screen.dart:219,227,235` | títulos de sección | `hunter_status_*` |
| `leaderboard_screen.dart:83` | tooltip | `leaderboard_tooltip` |
| `conversational_tactics_navigator.dart:48-49` | `'TACTICAL CONFIGURATION'`, `'SELECT CONVERSATIONAL FOCUS'` | `tactics_configuration_title`, `tactics_select_focus` |
| `profile_edit_screen.dart:550,578` | `labelText: 'HUNTER FULL NAME'`, `'MEMOIR / OBJECTIVES'` | `profile_edit_hunter_name`, `profile_edit_memoir` |
| `lesson_catalog.dart:103-683` | 17 títulos de lecciones (contenido de datos) | **Estrategia de datos, no ARB** (P3) |

---

## 4. Estrategia de migración por archivo (pasos)

Para cada archivo del lote:

1. **Barrido**: localizar con grep todos los literales de UI del archivo (incluir `Text(`, `labelText:`, `hintText:`, `tooltip:`, `title:`).
2. **Crear claves**: añadir la clave a `app_en.arb`, `app_es.arb`, `app_pt.arb` (usar el valor actual como traducción base; corregir capitalización/plurales).
3. **Regenerar**: `flutter gen-l10n` (las claves no resuelven hasta regenerar).
4. **Reemplazar**: sustituir cada literal por `AppLocalizations.of(context)!.clave`, pasando argumentos nombrados en las cadenas interpoladas.
5. **Validar**: `flutter analyze` (0 errores; no perseguir infos/warnings) y `flutter test`.
6. **Verificar visualmente**: cambiar idioma a `es` / `en` / `pt` y revisar la pantalla afectada.

Reglas transversales:

- **No duplicar claves semánticamente iguales** (`cancel`, `close`, `back`, `view_all`, `missions_claim`, `app_name`).
- **Interpolación**: `'... $e'` → ARB `'... {error}'` y llamada `...clave(e)`.
- **Mayúsculas de botones**: si solo difiere la caja (`CANCEL` vs `cancel`), decidir por pantalla; si se conserva la mayúscula, indicarlo en la clave (p.ej. `chat_rooms_initialize`) en lugar de aplicar `textTransform`.
- **Contenido de datos** (`lesson_catalog.dart`): NO externalizar vía ARB; definir estrategia de catálogo localizado (JSON por idioma o columna en BD) en P3.

---

## 5. Plan de ejecución por lotes

### Lote P0 — Fundación de idioma (onboarding + settings + welcome + shell)

**Objetivo**: dejar el pipeline ARB validado de extremo a extremo y los textos de "primera impresión" listos. Es el lote más pequeño en volumen pero el de mayor exposición.

| Archivo | Trabajo |
|---|---|
| `lib/app/app.dart` | `title` → `app_name` |
| `settings_screen.dart` | 23 títulos de opciones → `settings_*` (crear sección "Language" según `02_Architecture.md` §5 al pasar por aquí) |
| `onboarding_screen.dart` | `hintText: 'Buscar país...'` → `onboarding_search_country` |
| `welcome_screen.dart` | Verificación de restos hardcodeados |
| `oracle_conversation_screen.dart` | hint/tooltip/títulos → `oracle_*` |
| Claves base | Definir `view_all`, `common_got_it`, `language_*` para reutilizar en lotes posteriores |

**Entregable**: el usuario ve onboarding/settings/welcome traducidos en `es`/`en`/`pt`. Valida el ciclo ARB completo.

### Lote P1 — Dashboard + Perfil

| Archivo | Cadenas |
|---|---|
| `progress_tab_view.dart` | 5 |
| `profile_screen.dart` | 7 |
| `profile_edit_screen.dart` | 7 (+ 2 `labelText` secundarios) |
| `session_summary_screen.dart` | 3 |
| `recommended_lessons_hub.dart` | 2 |
| `next_recommended_lesson_hero.dart` | 1 |
| `practice_heatmap.dart` | 2 |
| `fluency_latency_chart.dart` | 2 |
| `hunter_hud_header.dart` | 2 tooltips |
| `hunter_status_screen.dart` | 3 títulos |
| `leaderboard_screen.dart` | 1 tooltip |
| **Total P1** | **29 `Text(...)` + ~8 secundarias** |

### Lote P2 — Chat Rooms + Conversación + Economía

| Archivo | Cadenas |
|---|---|
| `chat_rooms_screen.dart` | 9 (+ títulos de diálogo secundarios) |
| `voice_room_screen.dart` | 3 (+ hint + tooltip) |
| `conversation_screen.dart` | 3 (+ hint) |
| `level_exam_screen.dart` | 3 |
| `live_goals_tracker_bar.dart` | 1 |
| `mission_board_widget.dart` | 4 |
| `inventory_screen.dart` | 4 |
| `nucleo_arcano_limit_screen.dart` | 3 |
| `battle_pass_screen.dart` | 2 |
| `collections_screen.dart` | 1 |
| `daily_reward_modal.dart` | 2 |
| `conversational_tactics_navigator.dart` | 2 |
| **Total P2** | **33 `Text(...)` + ~10 secundarias** |

### Lote P3 — Resto (suscripción, vocabulario, contenido) + cierre

| Archivo | Cadenas |
|---|---|
| `srs_flashcard_modal.dart` | 4 |
| `paywall_screen.dart` | 3 |
| `lesson_catalog.dart` | 17 títulos → **estrategia de datos** (JSON localizado o columna en BD), no ARB |
| Cierre | Barrido global `grep` de literales restantes; revisar `lib/core/widgets/` y `lib/core/i18n/`; QA |

**Total P3**: **7 `Text(...)` + estrategia de datos**.

### Resumen de volumen por lote

| Lote | `Text(...)` | Secundarias | Riesgo principal |
|---|---|---|---|
| P0 | 0 directos (23 títulos Settings + hints) | ~30 | Alta exposición de primera impresión; bajo riesgo técnico |
| P1 | 29 | ~8 | Fórmulas/estadísticas con plurales |
| P2 | 33 | ~10 | Interpolación en errores; textos en inglés mezclados |
| P3 | 7 | 17 datos | Decisión de modelo de datos para el catálogo |
| **Total** | **69** | ~65 + 17 datos | — |

---

## 6. Estimación

Base: ~15–25 min por cadena (crear clave ×3 idiomas + reemplazo + gen-l10n + verificación). Se aplica factor de integración por archivo y verificación visual.

| Lote | Volumen | Estimación |
|---|---|---|
| P0 | ~30 cadenas + claves base | **1 día** |
| P1 | 29 + 8 | **1,5 días** |
| P2 | 33 + 10 | **2 días** |
| P3 | 7 + estrategia de datos + cierre | **1 día** |
| **Total migración** | 69 + ~65 + datos | **~5,5 días hábiles** |

> Fuera de alcance aquí (ver `08_Task_List.md`): infraestructura de idioma (detección, `followDeviceLanguage`, sync Supabase) y QA automatizado.

---

## 7. Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| `t()` legacy devuelve la key si queda alguna llamada real | Textos rotos en pantalla | Barrido final de `t(` en el cierre (P3); `02_Architecture.md` §4.5 planifica su retirada |
| Duplicación de claves (dos archivos con el mismo texto) | Inflado de ARB, mantenimiento | Convención §2 + revisión de claves compartidas por lote |
| Interpolación mal tipada (`$e` → `{error}`) | Fallo de compilación del método generado | Revisión en el paso 4 de cada archivo; `flutter analyze` por archivo |
| Regeneración olvidada tras editar `.arb` | Claves sin resolver | Paso 3 obligatorio por archivo (checklist §4) |
| Plurales/fórmulas (Racha, Días) | Traducciones incorrectas en `pt` | Usar placeholders con argumentos nombrados y verificar en `pt` |
| Catálogo de lecciones asume ARB | Acoplamiento erróneo | Mantenerlo como estrategia de datos (P3), documentado en `01_Current_Audit.md` §4.2 nota |

---

## 8. Criterios de aceptación

- [ ] Cero literales de UI en los 20 archivos del inventario (verificable por `grep`).
- [ ] `flutter analyze` con **0 errores** (infos/warnings existentes no se persiguen).
- [ ] `flutter test` en verde.
- [ ] Las claves nuevas existen en `app_en.arb`, `app_es.arb`, `app_pt.arb` (paridad de claves comprobable por script).
- [ ] Cambio de idioma desde Settings refleja las pantallas migradas en `es`/`en`/`pt`.
- [ ] `docs/Internationalization/09_Final_Report.md` rellenado al completar.
