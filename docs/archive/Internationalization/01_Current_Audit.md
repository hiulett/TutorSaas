# Auditoría de Internacionalización — Estado Actual

> Fecha: 2026-08-02 · Alcance: pipeline i18n de la app Flutter **TutorSaas / Dungeon of English**
> Este documento recoge el estado **verificado** (no propuestas). Las líneas citadas corresponden al árbol `lib/` en el momento de la auditoría.

---

## 1. Arquitectura i18n en vigor

| Componente | Detalle |
|---|---|
| Mecanismo | Flutter **l10n** oficial (`l10n.yaml`, `pubspec.yaml: generate: true`) |
| Plantillas | `lib/l10n/app_en.arb` (origen), `lib/l10n/app_es.arb`, `lib/l10n/app_pt.arb` |
| Generación | `flutter gen-l10n` → `lib/l10n/app_localizations.dart` |
| Acceso | `AppLocalizations.of(context)!.clave` |
| Inyección | `MaterialApp.router` con `localizationsDelegates`, `supportedLocales` y `locale` en `lib/app/app.dart:23-27` |

El `locale` de la app se deriva **solo** de `userLanguageProvider.select((s) => s.uiLanguage)` (`lib/app/app.dart:13,25-27`). No participa el idioma del dispositivo en ningún momento del arranque.

---

## 2. Modelo de idiomas y providers

### 2.1 `UserLanguageSettings` — modelo moderno (`lib/core/i18n/language_settings.dart`)

```dart
UserLanguageSettings {        // líneas 5-31
  uiLanguage:         'es'    // por defecto fijo
  learningLanguage:   'en'    // por defecto fijo
  aiExplanationsInNative: true
}
```

- Serialización `toJson()` → claves `ui_language`, `learning_language`, `ai_explanations_native` (líneas 26-30).
- **`UserLanguageNotifier`** (`StateNotifier`), líneas 33-78:
  - `_load()` lee de `SharedPreferences` (claves `ui_language`, `learning_language`, `ai_explanations_native`); fallback a `'es'` / `'en'` / `true` (líneas 38-45).
  - `setUiLanguage` / `setLearningLanguage` escriben prefs, actualizan estado y llaman `_persistToSupabase()` (líneas 47-59).
  - `setAiExplanationsInNative` **no** persiste en Supabase (líneas 61-65).
  - `_persistToSupabase()` hace `upsert` a la tabla `user_settings` (líneas 67-77) en `try/catch` silencioso.
- `userLanguageProvider = StateNotifierProvider<UserLanguageNotifier, UserLanguageSettings>` (líneas 80-82).

### 2.2 `LocaleNotifier` — legado (`lib/core/i18n/locale_provider.dart`)

- `LocaleNotifier` (StateNotifier<String>), estado inicial `'es'`, lee de prefs la clave **`interface_language`** (líneas 6-17).
- `localeProvider`, `languageCodeProvider` y `t()` conviven aún en el código.
- **`t()` es un STUB**: devuelve la key sin traducir (`return key;`, líneas 44-47). No debe usarse para traducciones reales.
- El bloque de "sync con UserLanguageSettings" está **vacío** (`try {} catch (_) {}`, líneas 27-31).

### 2.3 Relación de fuentes de verdad

| Fuente | Claves | Uso real |
|---|---|---|
| `UserLanguageSettings` (prefs `ui_language`, etc.) | `es`/`en`/`pt` | Alimenta `MaterialApp.locale` |
| `LocaleNotifier` (prefs `interface_language`) | `es`/`en`/`pt` | Legado, en desuso |
| Supabase `user_settings` | `ui_language`, `learning_language`, `ai_explanations_native` | Solo escritura (upsert) |

---

## 3. Base de datos

- La tabla `user_settings` ya contiene `ui_language`, `learning_language`, `ai_explanations_native` (creadas en la migración `20260730_SQL_EDITOR_pendientes.sql`).
- **No existe** la columna `follow_device_language`.
- El arranque **no sincroniza**: los ajustes se persisten a Supabase, pero nunca se descargan al iniciar sesión. Si el usuario cambia de dispositivo, se pierden sus ajustes de idioma.

---

## 4. Inventario de textos hardcodeados

Cuantificación verificada: **~69 cadenas literales en widgets `Text(...)` repartidas en 20 archivos**, más una capa secundaria de `labelText` / `hintText` / `title` / `subtitle` / `tooltip` (~74 apariciones adicionales). Se desglosa por archivo con `archivo:línea`.

### 4.1 `Text(...)` con literal — 20 archivos / 69 cadenas

**chat_rooms / `chat_rooms_screen.dart` (9)**
- `chat_rooms_screen.dart:212` — `'Idioma de Caza:'`
- `chat_rooms_screen.dart:220` — `'Puntos de Experiencia:'`
- `chat_rooms_screen.dart:314` — `'ENTRENAMIENTO IA'`
- `chat_rooms_screen.dart:315` — `'MENTORÍA (RESONANCIA)'`
- `chat_rooms_screen.dart:316` — `'EVENTO ESPECIAL'`
- `chat_rooms_screen.dart:334` — `'CANCEL'`
- `chat_rooms_screen.dart:362` — `'Error al crear sala: $e'`
- `chat_rooms_screen.dart:374` — `'INITIALIZE'`
- `chat_rooms_screen.dart:882` — `'PRESTIGIO $level'`

**dashboard / `profile_screen.dart` (7)**
- `profile_screen.dart:220` — `'XP Total'`
- `profile_screen.dart:243` — `'Racha activa'`
- `profile_screen.dart:266` — `'Nivel CEFR'`
- `profile_screen.dart:376` — `'VER TODO'`
- `profile_screen.dart:447` — `'Error al cargar vocabulario'`
- `profile_screen.dart:555` — `'No hay vocabulario para mostrar'`
- `profile_screen.dart:615` — `'Cerrar'`

**dashboard / `profile_edit_screen.dart` (7)**
- `profile_edit_screen.dart:219` — `'CAMERA'`
- `profile_edit_screen.dart:238` — `'GALLERY'`
- `profile_edit_screen.dart:608` — `'SPANISH (ES)'`
- `profile_edit_screen.dart:609` — `'ENGLISH (EN)'`
- `profile_edit_screen.dart:610` — `'FRENCH (FR)'`
- `profile_edit_screen.dart:611` — `'GERMAN (DE)'`
- `profile_edit_screen.dart:612` — `'PORTUGUESE (PT)'`

**dashboard / `progress_tab_view.dart` (5)**
- `progress_tab_view.dart:274` — `'Puntos XP'`
- `progress_tab_view.dart:293` — `'Racha Activa'`
- `progress_tab_view.dart:312` — `'Nivel Activo'`
- `progress_tab_view.dart:453` — `'Repaso SRS'`
- `progress_tab_view.dart:464` — `'VER TODO'`

**missions / `mission_board_widget.dart` (4)**
- `mission_board_widget.dart:68` — `'ACEPTAR'`
- `mission_board_widget.dart:93` — `'SIN MISIONES ACTIVAS'`
- `mission_board_widget.dart:109` — `'GENERAR MISIONES'`
- `mission_board_widget.dart:143` — `'RECLAMAR'`

**vocabulary / `srs_flashcard_modal.dart` (4)**
- `srs_flashcard_modal.dart:146` — `'CLOSE'`
- `srs_flashcard_modal.dart:238` — `'HARD'`
- `srs_flashcard_modal.dart:250` — `'NORMAL'`
- `srs_flashcard_modal.dart:262` — `'EASY'`

**economy / `inventory_screen.dart` (4)**
- `inventory_screen.dart:125` — `'No se pudo cargar el inventario'`
- `inventory_screen.dart:134` — `'INVENTARIO VACÍO'`
- `inventory_screen.dart:138` — `'VISITA LA TIENDA →'`
- `inventory_screen.dart:244` — `'EQUIPADO'`

**chat_rooms / `voice_room_screen.dart` (3)**
- `voice_room_screen.dart:220` — `'No messages in this chamber yet.'`
- `voice_room_screen.dart:432` — `'LIVE'`
- `voice_room_screen.dart:882` — `'Error en sala: $err'`

**conversation / `level_exam_screen.dart` (3)**
- `level_exam_screen.dart:431` — `'MUTE'`
- `level_exam_screen.dart:441` — `'CONCLUDE RAID'`
- `level_exam_screen.dart:503` — `'RETURN TO SANCTUARY'`

**conversation / `conversation_screen.dart` (3)**
- `conversation_screen.dart:196` — `'Metas del Escenario:'`
- `conversation_screen.dart:218` — `'Frases Clave Sugeridas (Useful Phrases):'`
- `conversation_screen.dart:482` — `'Fonemas recomendados a practicar:'`

**subscription / `paywall_screen.dart` (3)**
- `paywall_screen.dart:84` — `'Thank you for subscribing! Premium benefits unlocked.'`
- `paywall_screen.dart:94` — `'Purchase failure: $e'`
- `paywall_screen.dart:162` — `'Purchases successfully restored.'`

**dashboard / `session_summary_screen.dart` (3)**
- `session_summary_screen.dart:480` — `'VER VOCABULARIO'`
- `session_summary_screen.dart:483` — `'Vocabulario guardado en tu perfil.'`
- `session_summary_screen.dart:502` — `'LISTO'`

**economy / `nucleo_arcano_limit_screen.dart` (3)**
- `nucleo_arcano_limit_screen.dart:207` — `'RECARGAR +5'`
- `nucleo_arcano_limit_screen.dart:248` — `'IR PREMIUM'`
- `nucleo_arcano_limit_screen.dart:250` — `'Invocaciones Ilimitadas — Cazador de Élite'`

**dashboard / `recommended_lessons_hub.dart` (2)**
- `recommended_lessons_hub.dart:158` — `'Salas de Voz'`
- `recommended_lessons_hub.dart:471` — `'Ver Objetivos'`

**economy / `battle_pass_screen.dart` (2)**
- `battle_pass_screen.dart:102` — `'No se pudo cargar el Battle Pass'`
- `battle_pass_screen.dart:222` — `'RECLAMAR'`

**dashboard / charts/`practice_heatmap.dart` (2)**
- `practice_heatmap.dart:89` — `'Hace 4 semanas'`
- `practice_heatmap.dart:90` — `'Hoy'`

**dashboard / charts/`fluency_latency_chart.dart` (2)**
- `fluency_latency_chart.dart:51` — `'WPM'`
- `fluency_latency_chart.dart:55` — `'Latencia (s)'`

**economy / `collections_screen.dart` (1)**
- `collections_screen.dart:102` — `'No se pudieron cargar las colecciones'`

**dashboard / `next_recommended_lesson_hero.dart` (1)**
- `next_recommended_lesson_hero.dart:397` — `'Entendido'`

**conversation / `live_goals_tracker_bar.dart` (1)**
- `live_goals_tracker_bar.dart:145` — `'M${widget.index}'`

### 4.2 Capa secundaria — `labelText` / `hintText` / `title` / `subtitle` / `tooltip` (selección)

- `chat_rooms_screen.dart:186-187,245-246,260,278,306,752` — títulos/etiquetas de diálogos y formularios.
- `conversation_screen.dart:880` — `hintText: 'Escribe tu mensaje en inglés...'`.
- `voice_room_screen.dart:268,459` — `hintText: 'Type a message...'` y `tooltip: 'Salir de la sala'`.
- `daily_reward_modal.dart:65-66` — `'RECOMPENSA DIARIA'`, `'RACHA ACTUAL: $streak DÍAS'`.
- `oracle_conversation_screen.dart:229,581,589-590` — hint, tooltip, títulos de voz.
- `onboarding_screen.dart:773` — `hintText: 'Buscar país...'`.
- `hunter_hud_header.dart:205,210` — tooltips `'Notificaciones'`, `'Misiones'`.
- `hunter_status_screen.dart:219,227,235` — títulos de sección.
- `leaderboard_screen.dart:83`, `battle_pass_screen.dart:65`, `progress_tab_view.dart:109,114` — tooltips.
- `settings_screen.dart` — **23 títulos de opciones hardcodeados** (líneas 118-1118): secciones de ajustes y opciones de dificultad/compañero.
- `conversational_tactics_navigator.dart:48-49` — `'TACTICAL CONFIGURATION'`, `'SELECT CONVERSATIONAL FOCUS'`.
- `profile_edit_screen.dart:550,578` — `labelText: 'HUNTER FULL NAME'`, `'MEMOIR / OBJECTIVES'`.
- `app.dart:17` — `title: 'Dungeon of English'`.
- `lesson_catalog.dart:103-683` — 17 títulos de lecciones hardcodeados en el modelo de datos (datos, no UI; externalizables vía catálogo).

> Nota: los títulos del catálogo (`lesson_catalog.dart`) son contenido, no textos de UI; se listan aparte porque la externalización depende de la estrategia de datos, no solo del ARB.

---

## 5. Brechas detectadas

| # | Brecha | Evidencia |
|---|---|---|
| G1 | **Sin detección automática del idioma del dispositivo** al primer inicio. `UserLanguageNotifier._load()` fija `'es'` como fallback (líneas 41-44) sin consultar `PlatformDispatcher.instance.locale`; `MaterialApp.locale` solo mira `uiLanguage` (`app.dart:13,25-27`). | `language_settings.dart:38-45` · `app.dart:25-27` |
| G2 | **No existe `followDeviceLanguage`** ni en el modelo (`UserLanguageSettings`, líneas 5-31), ni en prefs, ni en la tabla `user_settings`. | `language_settings.dart:5-31` |
| G3 | **No hay sincronización de idioma al arrancar desde Supabase**: `_persistToSupabase()` solo escribe (upsert); no hay `select`/`fetch` de `user_settings` al iniciar sesión ni al construir el notifier. | `language_settings.dart:67-77` |
| G4 | **Dos fuentes de verdad divergentes**: `LocaleNotifier` (clave `interface_language`) vs `UserLanguageSettings` (clave `ui_language`). El bloque de sync está vacío (`locale_provider.dart:27-31`). | `locale_provider.dart:13-31` |
| G5 | **`t()` es un stub** que devuelve la key; si quedan llamadas reales producen texto plano de claves en pantalla. | `locale_provider.dart:44-47` |
| G6 | **~69 textos de UI hardcodeados en 20 archivos** (más capa secundaria de hints/tooltips/títulos). Sin esto no es posible una app multilingüe completa. | Sección 4 |
| G7 | **No existe sección "Idioma/Language" en Settings**: los idiomas de idioma nativo/objetivo se editan en perfil (`profile_edit_screen.dart:608-612`), y `settings_screen.dart` no expone los 3 ajustes de idioma ni el interruptor de `followDeviceLanguage`. | `settings_screen.dart` |
| G8 | `setAiExplanationsInNative` **no persiste a Supabase** (a diferencia de los otros dos setters). Inconsistencia de persistencia. | `language_settings.dart:61-65` |

---

## 6. Onboarding (aclaración)

- El paso 1 del onboarding pregunta por el **idioma nativo** (correcto: es el idioma de aprendizaje, `learningLanguage`).
- **No existe** una pregunta de "idioma de interfaz" en el onboarding; la UI debería resolverse por **detección automática del dispositivo** en el primer inicio. Cualquier plan que pida "eliminar la pregunta de idioma de interfaz" se está refiriendo a una pantalla que nunca existió — se garantiza vía detección (brecha G1) + override manual (G2).

---

## 7. Resumen ejecutivo

- Arquitectura de base correcta (l10n oficial + 3 ARB + provider moderno), pero incompleta: **faltan la detección automática, el flag `followDeviceLanguage`, la sincronización descendente desde Supabase y la unificación con el `LocaleNotifier` legado**.
- El inventario de hardcoded (~69 en UI + capa secundaria) bloquea la completitud multilingüe.
- El plan objetivo se desarrolla en `docs/Internationalization/02_Architecture.md`.
