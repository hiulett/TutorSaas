# Estrategia de Traducción (ARB / l10n)

> Documento de proceso y convenciones. Complementa `01_Current_Audit.md`, `02_Architecture.md` y `03_Database_Changes.md`.
> No modifica código: define cómo mantener, generar y escalar las traducciones.

---

## 1. Ciclo de vida de un ARB

### 1.1 Ubicación y plantilla

| Elemento | Valor actual (verificado) |
|---|---|
| Directorio | `lib/l10n/` (`arb-dir` en `l10n.yaml`) |
| Plantilla (fuente) | `lib/l10n/app_en.arb` |
| Locales | `app_en.arb`, `app_es.arb`, `app_pt.arb` |
| Clase generada | `AppLocalizations` (`output-class` en `l10n.yaml`) |
| Generación | `flutter gen-l10n` |

### 1.2 Flujo de adición de una cadena

```
1. Añadir la clave SOLO a app_en.arb (fuente canónica)
        │
2. flutter gen-l10n   → regenera app_localizations.dart (+ getters tipados)
        │
3. Añadir la misma clave a app_es.arb y app_pt.arb
        │
4. flutter gen-l10n   → regenera (valida que las claves existan en todos los locales)
        │
5. Usar en UI:  AppLocalizations.of(context)!.miClave
```

**Regla de oro**: nunca añadir una clave a un ARB no-inglés sin que exista antes en `app_en.arb`; `gen-l10n` falla si hay claves faltantes en algún locale y las omite del set de traducción.

### 1.3 Nombrado de claves

Convención **por feature** (`<feature>_<elemento>[_<descripción>]`), snake_case, en minúsculas, sin espacios:

| Prefijo | Ámbito | Ejemplo actual |
|---|---|---|
| `dashboard_` | Home / tabbar | `dashboard_title`, `dungeons` |
| `settings_` | Ajustes | `settings`, `target_language`, `save_settings` |
| `onboarding_` | Wizard / Oracle | `onboarding_lang`, `onboarding_native_lang` |
| `conversation_` | Pantalla de voz | `conversation_title`, `conversation_voice_mode` |
| `room_` | Salas de voz | `room_live`, `room_leave`, `room_claim_slot` |
| `guild_` | Guild hall | `guild_hall`, `guild_create`, `guild_enter` |
| `status_` | Hunter status | `status_panel`, `status_attributes` |
| `error_` | Errores | `error_mic_permission`, `error_short_audio` |
| `mod_` | Moderación | `mod_ai`, `mod_creator` |

Reglas:
- **Una clave por concepto**, sin concatenar strings en UI (evitar `'$prefijo ' + key`).
- **`_desc`** para descripciones secundarias de una misma tarjeta/tile (ej. `mod_ai` / `mod_ai_desc`).
- **`_title`** para títulos de diálogos/sheets (ej. `tutorial_dialog_title`).
- **`_hint`** para `hintText`, **`_tooltip`** para `tooltip` (capa secundaria del inventario en `01_Current_Audit.md` §4.2).
- No usar IDs numéricos ni nombres genéricos (`t1`, `text`, `label`).

---

## 2. Plurales y género con ICU

`flutter gen-l10n` usa el paquete `intl` y **soporta ICU MessageFormat** cuando se declara el placeholder con metadatos `@`.

### 2.1 Plural (ICU)

```json
// app_en.arb
"streak_days": "{count} Day Streak",
"@streak_days": {
  "placeholders": {
    "count": {
      "type": "num",
      "format": "compact"
    }
  }
}
```

Con plurales explícitos (recomendado para calidad en es/pt):

```json
// app_en.arb
"conversations_remaining": "{count, plural, =0{No conversations remaining} one{1 conversation remaining} other{{count} conversations remaining}}",
"@conversations_remaining": {
  "placeholders": {
    "count": {
      "type": "num"
    }
  }
}

// app_es.arb — el mismo bloque, con reglas de plural de español (es: one/other)
"conversations_remaining": "{count, plural, =0{No quedan conversaciones} one{Queda 1 conversación} other{Quedan {count} conversaciones}}"
```

Reglas ICU por idioma:
- `en`: `=0, one, other`
- `es`/`pt`: `=0, one, other` (comportamiento similar; el singular/plural se elige por terminación → usar `one`/`other`)
- Idiomas eslavos (ru, pl, cs): `one, few, many, other` — no traducir los plurales de `en` literalmente; **escribir las reglas propias del locale**.

### 2.2 Select (género / contexto)

```json
"welcome_hunter": "{gender, select, male{WELCOME, HUNTER} female{WELCOME, HUNTRESS} other{WELCOME, HUNTER}}"
```

> El tipo `num` exige pasar un `num` (no `int` suelto a veces ambiguo) y el tipo `String` un string. Mantener los metadatos `@clave.placeholders` sincronizados en los 3 ARB.

### 2.3 Interpolación simple

```json
"xp_earned": "+{amount} XP",
"@xp_earned": {
  "placeholders": { "amount": { "type": "int" } }
}
```

---

## 3. Cómo añadir un nuevo idioma

Pasos **en orden**:

1. **Crear** `lib/l10n/app_<codigo>.arb` (código ISO-639-1, ej. `app_fr.arb`, `app_de.arb`) con `"@@locale": "fr"` y **todas** las claves de `app_en.arb` traducidas.
2. **Regenerar**: `flutter gen-l10n` → `AppLocalizations.supportedLocales` incluye automáticamente el nuevo locale (se deriva de los ARB presentes).
3. **Verificar** que `AppLocalizations.delegate` resuelve el locale (los delegates generados ya cubren todos los locales presentes en `supportedLocales`).
4. **Registrar el idioma en el selector de UI**: la lista de `supportedLocales` para la app es el array generado; el **selector de idioma** de Settings (`05_Flutter_Implementation.md` §4) es una lista explícita `['es','en','pt']` que hay que ampliar con el nuevo código. No hardcodear el selector con base en `supportedLocales` si se quiere control editorial sobre qué idiomas se exponen como *incompletos*.
5. **`flutter analyze`** para confirmar 0 errores.

### 3.1 `use-deferred-loading` y escalabilidad

`l10n.yaml` hoy usa `use-deferred-loading: false` (carga síncrona, adecuado para 3-5 idiomas). Para escalar a **decenas de idiomas**:

- Activar `use-deferred-loading: true` → cada locale se carga bajo demanda y se delega a `Future`/`SynchronousFuture`; reduce el coste de arranque y de memoria con ~15+ idiomas.
- Coste: los getters de `AppLocalizations` se vuelven `FutureOr`; hay que gestionar el estado de carga en el widget raíz (patrón en `05_Flutter_Implementation.md` §6).
- **Recomendación**: activarlo cuando se superen ~8 idiomas o cuando el app_size / memoria del arranque importe.

### 3.2 Otros archivos que registran locale

- **`intl`** para formatos (fechas/números): al añadir idioma, si se usa `DateFormat`/`NumberFormat` con `intl`, hay que inicializar `initializeDateFormatting('es')` o delegar a `AppLocalizations` (no se usa hoy para UI principal).
- **`pubspec.yaml`**: `flutter_localizations` ya provee los delegates de Material (`GlobalMaterialLocalizations`); el soporte de las locales se habilita vía `AppLocalizations.localizationsDelegates`. No requiere tocar `pubspec` al añadir un idioma ARB.

---

## 4. Herramientas recomendadas

| Herramienta | Uso | Nota |
|---|---|---|
| `flutter gen-l10n` | Generación obligatoria | Correr tras cada cambio de ARB; también `dart run build_runner` si se tocan modelos con codegen |
| **ARB Editor** (Visual Studio Code) | Edición visual de ARB con vista previa | Detecta claves huérfanas y placeholders |
| **Flutter Intl** (VS Code) | Atajos de sintaxis y comandos | Útil para el scaffolding de `app_XX.arb` |
| **Localizely / Crowdin / Lokalise** | Gestión de traducciones por equipos y traducción profesional | Recomendado cuando el equipo de traducción no es el equipo dev |
| `arb_utils` (Dart CLI) | Comparar ARB, encontrar claves faltantes/huérfanas | `dart run arb_utils:checkMissingTranslations` |
| **Crowdin/GlotPress CI** | Sincronización automática de ARB en CI | Ver sección 6 |

> El proyecto no tiene hoy una plataforma de gestión de traducciones; para 3 idiomas basta edición directa de ARB + `gen-l10n`.

---

## 5. Calidad de traducción

### 5.1 Criterios

1. **Contexto**: cada clave debe documentarse con `@clave.description` en `app_en.arb` (la plantilla es la que define el contexto; los demás locales heredan).
2. **Consistencia terminológica**: mantener un glosario (sección 7) para términos RPG: *Dungeon*, *Guild*, *Oracle*, *Rank*, *Boss*, *Hunter*, *Core*.
3. **Tono de marca**: la UI usa un tono "System HUD" (MAYÚSCULAS, sintetizado). Las traducciones deben preservar ese tono (ej. `login`: "LOG IN" / "INICIAR SESIÓN").
4. **Longitud**: los textos HUD se muestran en espacios pequeños (`JetBrainsMono`); evitar traducciones que desborden. Revisar con las claves más largas (`onboarding_*`).
5. **No usar traducción automática sin revisión** para idiomas finales: las cadenas hardcodeadas detectadas (~69 en UI) y los términos RPG no deben traducirse en frío.
6. **Placeholders**: nunca traducir el interior de `{...}`; mantener el orden de los placeholders igual que en la plantilla.

### 5.2 Auditoría de claves

- **Huérfanas** (existen en ARB, no se usan en Dart): eliminables; hoy `app_en.arb` tiene claves no referenciadas (ver `btn_continue: "btn_continue"` que repite el nombre).
- **Faltantes** (se usan en Dart, no existen en ARB): son las cadenas hardcodeadas del inventario (`01_Current_Audit.md` §4) — **pendientes de externalizar**.
- Métrica objetivo: 100% de cobertura en `es`/`pt` frente a `en`, y 0 cadenas literales nuevas en `lib/` en PRs de UI.

---

## 6. Escalabilidad a decenas de idiomas

| Etapa | Acciones |
|---|---|
| 3-8 idiomas | Edición manual ARB + `gen-l10n`. Sin CI de traducción. |
| 8-15 idiomas | Activar `use-deferred-loading: true`. Integrar una plataforma (Crowdin/Lokalise) con sincronización de `app_en.arb` como fuente. |
| 15+ idiomas | Pipeline de traducción por fases: (1) TRADUCCIÓN AUTOMÁTICA, (2) revisión humana de términos RPG y textos críticos, (3) validación CI con `arb_utils` (check de claves faltantes), (4) prueba visual por idioma (goldens). |

Puntos de fallo típicos al escalar:
- **Plurales incorrectos** por copiar las reglas de `en` (sección 2.1).
- **Expansión de texto**: alemán/francés ~30% más largos → diseño con `Flexible`/`maxLines`, evitar botones con ancho fijo.
- **RTL** (árabe, hebreo): la app usa `ThemeMode.dark` con layouts `Row`/`Column` explícitos; habría que revisar `Directionality` y los iconos con chevron (`Icons.chevron_right`). Fuera de alcance hoy (idiomas actuales LTR).
- **Fallback** a `es`: si el idioma del dispositivo no está soportado, `MaterialApp` cae a la primera locale de `supportedLocales` (o la forzada en `locale:`); documentado en `02_Architecture.md` §2.

---

## 7. Diccionario de claves (prefijos por feature)

Estructura propuesta para mantener orden en `app_en.arb` (agrupar por bloque con comentarios, ya se hace parcialmente):

```json
{
  "@@locale": "en",

  /* --- Núcleo / comunes --- */
  "app_name", "loading", "error", "retry", "cancel", "save", "close",
  "back", "confirm", "delete", "search", "filter", "no_results", "see_all",

  /* --- Auth / Welcome --- */
  "login", "register", "continue_google", "login_google", "register_google",
  "login_google_error", "register_google_error",

  /* --- Dashboard / HUD --- */
  "dashboard_title", "dungeons", "guild", "status", "config", "player", "mp",
  "days_clear", "urgent_quest", "enter_gateway", "active_quests", "daily", "weekly",
  "hud_xp_total", "hud_vocabulary", "hud_level", "hud_streak",

  /* --- Settings / Language (nuevas) --- */
  "settings", "language_section", "follow_device_language", "follow_device_language_desc",
  "interface_language", "learning_language", "ai_explanations_native",

  /* --- Onboarding / Oracle --- */
  "onboarding_lang", "onboarding_native_lang", "onboarding_target", "onboarding_cefr",
  "onboarding_goal", "oracle_title", "oracle_assessment", "oracle_result",
  "onboarding_switch_interface_lang", "onboarding_switch_interface_desc",

  /* --- Conversación / Voz --- */
  "conversation_title", "conversation_input_hint", "conversation_voice_mode",
  "conversation_text_mode", "speak_now", "hold_speak", "boss_hp",
  "error_listening", "error_short_audio", "error_no_speech", "error_recording",

  /* --- Guild / Salas --- */
  "guild_hall", "live_coop", "initialize_room", "enter_raid", "hunters_active",
  "room_live", "room_mic", "room_leave", "room_chat", "room_audience", "room_hand",

  /* --- Progreso / Status --- */
  "status_panel", "status_attributes", "status_titles", "xp_points", "active_streak",
  "fluency", "latency", "wpm", "weekly_practice",

  /* --- Errores --- */
  "error_mic_permission", "error_groq_connection", "error_processing", "error_nucleo"
}
```

> Las claves `language_section`, `follow_device_language`, `follow_device_language_desc`, `interface_language`, `learning_language`, `ai_explanations_native` son las **nuevas** que exige la sección "Language" de Settings (ver `05_Flutter_Implementation.md` §4). Deben añadirse primero a `app_en.arb` y luego a `es`/`pt`.

---

## 8. Checklist de mantenimiento (PR de traducción)

- [ ] La clave existe en `app_en.arb` antes que en cualquier otro locale.
- [ ] `flutter gen-l10n` ejecutado y `app_localizations.dart` regenerado.
- [ ] Metadatos `@clave.placeholders` presentes para claves con `{placeholder}`.
- [ ] Plurales con reglas ICU propias del idioma (no copiadas de `en`).
- [ ] Los 3 locales (`en/es/pt`) tienen la misma clave.
- [ ] `flutter analyze` con 0 errores.
- [ ] Se revisaron visualmente los textos largos (sin desbordes en HUD).
- [ ] No se introdujo ninguna cadena literal nueva en `lib/` (regla anti-hardcoded).
