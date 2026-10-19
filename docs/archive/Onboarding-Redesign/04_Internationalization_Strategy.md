# Estrategia de Internacionalización (i18n) — Documento 04

> **Proyecto:** TutorSaas / Dungeon of English (Flutter)
> **Alcance:** i18n global del onboarding y de la app (UI + idioma objetivo)
> **Método:** Datos verificados contra `lib/l10n/`, `lib/core/i18n/`, `lib/features/onboarding/` (`file:line`)
> **Estado:** Propuesta de estrategia (sin modificación de código)
> **Fecha:** 2026-08-02

---

## 1. Resumen ejecutivo

El proyecto ya usa **Flutter l10n con ARB** como base (3 idiomas: `en`, `es`, `pt`), que es el estándar oficial de Flutter. El problema no es el framework de i18n, sino su **incompletitud**: una parte grande de los textos del onboarding sigue **hardcodeada en español**, lo que hace que en `pt` y `en` se mezclen idiomas dentro de la misma pantalla.

Esta estrategia:

1. **Mantiene Flutter l10n + ARB** como arquitectura (no propone migrar a `intl` manual ni a otro framework).
2. Define los **idiomas de UI** para v1: `en`, `es`, `pt` (3 ARB), con hoja de ruta para ampliar.
3. Define los **idiomas objetivo de aprendizaje**: v1 = solo inglés; v2 = español y francés.
4. Cataloga el **inventario de textos hardcodeados** y propone el plan de migración.
5. Explica el **flujo para añadir un idioma sin tocar código** (añadir `app_XX.arb` + `flutter gen-l10n`).
6. Previene la **deriva i18n** con convenciones y checklists.

---

## 2. Arquitectura recomendada (mantener Flutter l10n + ARB)

### 2.1 Por qué se mantiene la arquitectura actual

| Criterio | Evaluación |
|---|---|
| Estándar oficial de Flutter | ✅ `flutter gen-l10n` genera código tipado (`AppLocalizations`) nativamente |
| Type safety | ✅ Clases generadas con getters por clave; errores de compilación si una clave falta |
| Herramientas de terceros | ✅ `arb` es el formato interoperable (Google Localizations, Crowdin, Lokalise, Weblate, gitlocalize) |
| Costo de cambio | Nulo (ya está implementado: `lib/l10n/app_*.arb`, `l10n.yaml`) |
| Inferencia de locales | ✅ `flutter_localizations` + `AppLocalizations.delegate` |
| Deferred loading | Soportado (`use-deferred-loading: true`), opcional para reducir bundle inicial |

**Decisión:** no introducir un framework de i18n alternativo. El riesgo real está en la **disciplina de consumo** (usar `AppLocalizations.of(context)!` en todas partes), no en la tecnología.

### 2.2 Estado de configuración verificado

- `l10n.yaml` → `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-class: AppLocalizations`. (`C:\WorkSpace\TutorSaas\l10n.yaml`)
- ARB presentes: `app_en.arb` (template), `app_es.arb`, `app_pt.arb`. (`lib/l10n/`)
- Generados: `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_es.dart`, `app_localizations_pt.dart`. (`lib/l10n/`)
- Uso correcto en pantallas: `AppLocalizations.of(context)!` en `onboarding_screen.dart:19,254,612,858` y `welcome_screen.dart:9`.
- Helper legado `t()` en `lib/core/i18n/locale_provider.dart:44-47` es un **stub** que devuelve la clave (`return key;`). No debe usarse como fuente real de traducción.

### 2.3 Estructura ARB recomendada (v1)

```
lib/l10n/
  app_en.arb        # Template (fuente canónica, con @metadata y descripciones)
  app_es.arb        # Español (es)
  app_pt.arb        # Portugués (pt-BR → código 'pt' según flujo actual)
  app_fr.arb        # [Fase 2] Francés
  app_de.arb        # [Fase 3] Alemán (si el mercado lo valida)
```

Reglas de calidad para el template `app_en.arb`:
- Toda clave incluye `@key` con `description` (mejora traducibilidad y es requerido por herramientas).
- Claves agrupadas por feature con prefijo (p. ej. `onboarding_`, `oracle_`, `character_`, `room_`, `hud_`).
- **Idiomas destino:** no importar valores de template; siempre traducir.
- No dejar claves vacías en un ARB sin la entrada `@key` correspondiente (o `flutter gen-l10n` advertirá).

### 2.4 ICU messages para plurales / select

El formato ARB soporta **ICU MessageFormat** (placeholders, plurales, select). Se recomienda usarlo desde ahora para los textos que dependen de conteo, en lugar de concatenar cadenas:

- **Plurales** (`{count, plural, ...}`): útiles para frases como "X conversaciones restantes" (`conversations_remaining`, ya en ARB), días de racha, XP, etc.
- **Select** (`{gender, select, ...}`): útil si el Oráculo se refiere al jugador con género o clase.

Ejemplo de clave con plural (patrón a adoptar):

```jsonc
// app_en.arb
"streak_days": "{count, plural, =1{1 Day Streak} other{{count} Day Streak}}",
"@streak_days": {
  "description": "Streak counter with pluralization",
  "placeholders": { "count": { "type": "int" } }
}
```

> Nota: en el template (en) el placeholder `{count}` debe aparecer en la forma plural (`{count, plural,...}`) o gen-l10n no generará los métodos con parámetro correctamente para `int`/`num`.

### 2.5 Gestión del flujo UI (dos fuentes de verdad, hoy)

Existen **dos providers** que controlan el idioma, hoy desincronizados:

- `localeProvider` / `languageCodeProvider` (`lib/core/i18n/locale_provider.dart`) — legado, solo `es/en/pt`.
- `userLanguageProvider` (`lib/core/i18n/language_settings.dart`) — nuevo, con `uiLanguage`, `learningLanguage`, `aiExplanationsInNative` (persiste en `SharedPreferences` + `user_settings`).

**Recomendación:** consolidar la lectura del idioma de UI en `userLanguageProvider` como fuente única, y que `localeProvider` delegue en él (evolucionando el stub de `t()`). Esto evita dos fuentes de verdad y hace predecible qué idioma renderiza `MaterialApp.locale`.

---

## 3. Análisis de mercado — ¿cuántos idiomas de UI en v1?

### 3.1 Justificación del alcance de UI

Los costos por idioma de UI son: (a) traducción + revisión del ARB, (b) ajustes de diseño por texto más largo (mayor impacto en UI en minúsculas con `UPPERCASE` HUD y `JetBrainsMono`), (c) mantenimiento continuo de nuevas claves. Cada idioma extra también **diluye la atención de QA**.

| Idioma UI | Usuarios potenciales que lo hablan | Costo mantenimiento ARB | Prioridad v1 |
|---|---|---|---|
| `en` (template) | Mercado global + UI por defecto de la app (hoy el switch de onboarding lo confirma: "Cambia los menús y botones a `XX` en lugar de **inglés**") | Bajo (ya existe) | **P0 — obligatorio** |
| `es` | Latam + España (mercado objetivo actual: países MX/CO/ES/AR/CL/PE en `onboarding_screen.dart:66-78`) | Bajo (ya existe) | **P0 — obligatorio** |
| `pt` | Brasil (`BR` presente en países; único país lusófono de la lista) | Bajo (ya existe, pero incompleto en consumo) | **P0 — obligatorio** |
| `fr` | Francia + África francófona; Francia ya aparece como país y como idioma objetivo | Medio | P1 — Fase 2 |
| `de`, `it` | Alemania/Italia (en listas de nativos y objetivos) | Medio | P2 — validar con datos de adquisición |
| `zh`, `ja` | China/Japón (solo en lista de nativos) | Alto (RTL no aplica, pero diseño muy distinto; soporte TTS distinto) | P2 — solo si se valida |

**Recomendación v1: 3 idiomas de UI (`en`, `es`, `pt`).** La infraestructura ya está; el trabajo es **completar el consumo** (ver §5), no añadir más ARB. Añadir más idiomas antes de completar la cobertura actual solo multiplica el problema de textos en español que se verán en todos los idiomas.

### 3.2 Monetización y tamaño de mercado

- El mercado de aprendizaje de inglés como segundo idioma es el más grande del mundo (hablantes de español y portugués están entre los grupos con mayor motivación de aprendizaje).
- Modelo Free/Pro por suscripción (paywall post-sesión): cada idioma de UI adicional que no añade usuarios **no justifica su costo**. Por eso la decisión v1 es *cubrir* no *ampliar*.
- La monetización depende más del **idioma objetivo** (inglés) que del idioma de UI: el ARB de UI es un habilitador de conversión, no el producto.

---

## 4. Idiomas objetivo de aprendizaje (lo que se enseña)

La app **enseña idiomas** (`target_language`). Hoy el selector de objetivo ofrece `en/fr/de/it` (`onboarding_screen.dart:80-85`), pero el pipeline de voz solo está preparado de verdad para **inglés**:

- STT forzado a `language: 'en'` (Groq Whisper `whisper-large-v3-turbo`) — `conversation_repository_impl.dart:56-57`.
- TTS configurado a `en-US` — `voice_service.dart:128`.
- Preguntas del Oráculo y fallback **en inglés** — `oracle_providers.dart:24-59`, `oracle_conversation_screen.dart:851-859`.
- CEFR es una escala pensada para el inglés (los 6 niveles A1–C2).

### 4.1 Recomendación por fases

| Fase | Idiomas objetivo | Justificación |
|---|---|---|
| **v1** | **Solo `en`** | El pipeline completo (STT/TTS/Oráculo/CEFR) está calibrado para inglés. Ofrecer `fr/de/it` hoy es vender algo que no funciona en voz. |
| **v2** | `es` y `fr` como objetivo | Son los dos grupos más grandes de hablantes aprendiendo inglés; el mismo TTS/STT de inglés sirve, y solo cambia la UI/instrucciones del tutor (que se explican en el idioma nativo del usuario, no en el objetivo). |

> La recomendación de "español como objetivo en v2" se refiere a **hablantes de español aprendiendo inglés**, no a enseñar español. Enseñar español/francés como idioma objetivo requeriría un pipeline STT/TTS propio (Groq Whisper sí soporta multiidioma, pero el TTS de `flutter_tts` y las preguntas del Oráculo tendrían que localizarse por objetivo) — fuera de alcance v1.

### 4.2 Modelo de 3 idiomas (recomendación a nivel producto)

`UserLanguageSettings` ya modela correctamente la separación:

1. **`uiLanguage`** — idioma de la interfaz (`en`/`es`/`pt`). Renderiza la app.
2. **`learningLanguage`** — idioma objetivo (`en` en v1). Usado por el pipeline de voz y las preguntas del Oráculo.
3. **`aiExplanationsInNative`** — si las explicaciones/feedback del tutor IA van en el idioma nativo o en el objetivo. (El Oráculo debería respetarlo: sus textos de evaluación narrativos en `explanation` podrían traducirse al nativo si el usuario lo pide.)

---

## 5. Inventario de textos hardcodeados y plan de migración

### 5.1 Inventario verificado (onboarding + vecinos)

**A) `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (1021 líneas)**

| Línea | Texto hardcodeado (ES) | Clave ARB propuesta | Prioridad |
|---|---|---|---|
| `:95` | "Selecciona tu idioma nativo para continuar." (snackbar) | `onboarding_err_native_required` | P0 |
| `:102` | "Selecciona el idioma que deseas aprender." (snackbar) | `onboarding_err_target_required` | P0 |
| `:212` | bio `'[Stats\|...] ¡Hola! Soy un cazador aventurero.'` | `profile_default_bio` | P1 |
| `:378` | `'INICIAR EVALUACIÓN'` (botón, y en `:1001`) | `oracle_start` | P0 |
| `:476-481` | `'¡BIENVENIDO,'` / `'CAZADOR!'` | `hero_welcome_title` / `hero_welcome_title_accent` | P0 |
| `:547` | `'Tu aventura comienza ahora.'` | `hero_adventure_begins` | P0 |
| `:555` | `'ENTRAR AL REINO'` | `hero_enter_realm` | P0 |
| `:527-529` | `'CEFR'` / `'RANGO'` (pills) | `hud_cefr` / `hud_rank` | P1 |
| `:624` | "Personalizaremos tu viaje de aprendizaje según tu idioma materno." | `onboarding_lang_desc` | P0 |
| `:634` | `'Native Language'` | `onboarding_native_language` | P0 |
| `:707` | `'Switch App Interface Language'` | `onboarding_switch_ui` | P0 |
| `:713` | `'Cambia los menús y botones...'` | `onboarding_switch_ui_desc` | P0 |
| `:752` | `'PAÍS DE ORIGEN'` | `onboarding_country` (ya existe en ARB = "REGISTRO DE CAZADOR", usar/ajustar) | P0 |
| `:757` | "Dinos de dónde vienes para adaptar la pronunciación y las expresiones." | `onboarding_country_desc` | P0 |
| `:765` | `'Country of Origin'` | `onboarding_country_of_origin` | P0 |
| `:814` | "¿No está tu país? Búscalo en el catálogo completo." | `onboarding_country_hint` | P1 |
| `:870` | "¿Qué idioma quieres dominar?" | `onboarding_target_desc` | P0 |
| `:937` | `'EL ORÁCULO TE CLASIFICARÁ'` | `oracle_will_classify` | P0 |
| `:942` | "El Oráculo analizará tu dominio del idioma..." | `oracle_classify_desc` | P0 |
| `:974` | `'EVALUACIÓN CONVERSACIONAL POR VOZ'` | `oracle_voice_assessment` | P0 |
| `:986` | "Habla con el Oráculo y serás evaluado en pronunciación, vocabulario, gramática, comprensión y fluidez..." | `oracle_voice_assessment_desc` | P0 |
| `:1010` | "La evaluación es opcional: si la omites, comenzarás en el rango inicial (A1)." | `oracle_optional_hint` | P0 |

**B) `lib/features/onboarding/presentation/screens/oracle_conversation_screen.dart` (861 líneas)**

| Línea | Texto hardcodeado (ES) | Clave ARB propuesta | Prioridad |
|---|---|---|---|
| `:34-50` | Episodios narrativos del Oráculo (nombres + líneas) | `oracle_episode_*` (5 claves × 2) | P1 |
| `:146` | "No se pudo acceder al micrófono..." | `error_mic_permission` (ya existe) / `oracle_err_mic` | P0 |
| `:172` | "No se detectó voz en el audio..." | `error_no_speech` (ya existe) | P0 |
| `:212` | `'RESPUESTA POR TEXTO'` | `oracle_text_answer` | P0 |
| `:229` | "Escribe tu respuesta en inglés…" | `oracle_text_hint` | P0 |
| `:253` | `'ENVIAR RESPUESTA'` | `oracle_send` | P0 |
| `:291` | "El vacío retrocede. Nivel X desbloqueado." (fallback) | `oracle_victory_line` | P0 |
| `:473` | `'EL ORÁCULO'` | `oracle_title` (ya existe = "EL ORÁCULO DEL GREMIO") | P0 |
| `:517` | `'EPISODIO X · <name>'` | `oracle_episode_label` | P1 |
| `:580` | `'Repetir pregunta'` (tooltip) | `oracle_replay` | P1 |
| `:588` | `'RESPONDE CON TU VOZ'` | `oracle_respond` (ya existe) | P0 |
| `:589` | `'MANTÉN PULSADO PARA HABLAR · SUELTA PARA ENVIAR'` | `oracle_hold_hint` | P0 |
| `:598` | `'RESPUESTAS: X · NIVEL ESTIMADO: Y'` | `oracle_progress_line` | P1 |
| `:621` | "El vacío retrocede. Nivel X desbloqueado." | `oracle_victory_line` | P0 |
| `:652` | `'NIVEL CEFR: X · RANGO: Y'` | `oracle_result_rank` | P0 |
| `:668` | `'FORTALEZAS: ...'` | `oracle_strengths` (ya existe = "FORTALEZAS") | P1 |
| `:685` | `'COMPLETAR EVALUACIÓN'` / `'SALTAR PREGUNTA'` | `oracle_complete` / `oracle_skip` | P0 |
| `:775-778` | "PROCESANDO CON GROQ IA…" / "ESCUCHANDO… SUELTA PARA ENVIAR" / "MANTÉN PARA HABLAR" | `oracle_processing` / `oracle_listening` / `oracle_hold_speak` | P0 |
| `:804-806` | Semantics de accesibilidad (ES) | `oracle_semantics_*` | P1 |
| `:827` | `'RESPONDER POR TEXTO'` | `oracle_text_answer` | P0 |

**C) `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`**

| Línea | Texto hardcodeado (ES) | Clave ARB propuesta | Prioridad |
|---|---|---|---|
| `:38` | clase `warrior` — nombre "Berserker" + descripción | `character_class_warrior` / `character_class_warrior_desc` | P0 |
| `:39` | clase `mage` — "Mago Arcano" + descripción | `character_class_mage` / `character_class_mage_desc` | P0 |
| `:40` | clase `rogue` — "Pícaro" + descripción | `character_class_rogue` / `character_class_rogue_desc` | P0 |
| `:70` | `'CREA TU PERSONAJE'` | `character_create_title` | P0 |
| `:77` | "Antes de comenzar tu aventura, necesitamos saber quién eres." | `character_create_desc` | P0 |
| `:85` | `'NOMBRE DEL CAZADOR'` | `character_name` (ya existe) | P0 |
| `:91` | "Tu nombre aventurero..." | `character_name_hint` (ya existe) | P0 |
| `:114` | `'AVATAR'` | `character_avatar` (ya existe) | P0 |
| `:155` | `'CLASE'` | `character_class` (ya existe) | P0 |
| `:214` | `'EL ORÁCULO TE ESPERA'` | `character_oracle_awaits` | P0 |

**D) `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart`** (no-UI pero afecta contenido)

- `:140` `pedagogicalSummary` y `:141` `tutorInstructions` con cadenas en español insertadas en `user_ai_profiles`. No son UI renderizada, pero **definen el comportamiento del tutor IA**. Recomendación: construirlos con plantillas deterministas (el prompt del tutor se arma en servidor/constante), no con español inline.

### 5.2 Plan de migración por lotes

- **Lote 1 (P0, hazlo primero):** todas las filas marcadas P0. Son ~30 claves nuevas/mapeos. Resultado: onboarding 100% localizado en `en/es/pt`.
- **Lote 2 (P1):** episodios narrativos, tooltips, semantics, progress lines, texto de clase de personaje descripciones (si no van en lote 1).
- **Lote 3 (P2):** arreglar duplicación — claves ya existentes en ARB (`onboarding_country`, `character_name`, `oracle_title`, `oracle_continue`, `oracle_strengths`, `error_mic_permission`, `error_no_speech`) que hoy **no se consumen** (`01_Current_Audit.md:108`). Usar las existentes antes de crear nuevas.
- **Gates:** tras cada lote → `flutter gen-l10n` + `flutter analyze` (0 errores) + revisión visual en los 3 locales.

---

## 6. Cómo añadir un idioma sin tocar código

El flujo es puramente de datos/config + codegen:

1. **Crear** `lib/l10n/app_XX.arb` con `"@@locale": "XX"` y todas las claves del template traducidas.
   - Para variantes de país (p. ej. `pt-BR`) usar `"@@locale": "pt-BR"` si se quiere diferenciar; hoy el proyecto usa `pt` plano (ver `locale_provider.dart:20`).
2. **(Opcional) agregar** `@key` metadata solo en el template `app_en.arb`; los otros ARB solo llevan claves y valores.
3. **Ejecutar** `flutter gen-l10n` → genera `app_localizations_xx.dart` y actualiza `app_localizations.dart` con el nuevo `AppLocalizations.xx` delegate.
4. **Registrar el locale** en `supportedLocales` del `MaterialApp` (único punto de código necesario: `Locale('xx')` + `AppLocalizations.xx`), y en `localeProvider` (`language_settings.dart` si aplica).
5. **Verificar** cobertura con `flutter gen-l10n` (emite warning por claves faltantes) y `flutter analyze`.

> Si `use-deferred-loading` se activara, cada idioma se carga bajo demanda (`AppLocalizations.xx.load()`), reduciendo el tamaño del bundle base — recomendado cuando se superen ~6 idiomas.

**Catálogo centralizado de países/idiomas:** las listas hardcodeadas de `onboarding_screen.dart:55-85` (nativos, países, objetivos) deben migrar a un **catálogo configurable** (tabla `languages`/`countries` o asset JSON), con el nombre nativo mostrado **en su propio idioma** ("Español", "Français", "中文") y traducible vía ARB cuando sea nombre común. Eso evita duplicar la lógica de nombre en `onboarding_repository_impl.dart:158-183` (`_getLanguageName`, `_getNativeLanguageName`, `_getLanguageEmoji`).

---

## 7. Prevención de deriva i18n (convenciones)

1. **Regla de oro:** ningún `Text(...)` con string literal "humana" en widgets; solo `AppLocalizations.of(context)!.clave`. Los strings técnicos (keys de clase, códigos, ids) pueden ser constantes.
2. **Snackbars/errores/semantics:** también se localizan (son la UX que el usuario ve). Inventario `01_Current_Audit.md:100-108` lo evidencia.
3. **No usar el helper `t()`** como fuente de traducción (es stub, `locale_provider.dart:44-47`).
4. **Un solo provider de idioma de UI:** delegar `localeProvider` en `userLanguageProvider.uiLanguage`.
5. **CI gate:** opcional pero recomendado — un script que compare claves de `app_en.arb` vs cada ARB y falle si hay claves faltantes antes del merge.
6. **Narrativa del Oráculo:** los textos narrativos (`_oracleEpisodes`, `explanation` del evaluador) deben generarse **por idioma de explicación** (ver §8 del doc 05) y no traducirse literalmente por IA sin revisión, porque cargan el tono RPG.
7. **Después de editar cualquier `.arb`** → ejecutar `flutter gen-l10n` (regla de AGENTS.md).

---

## 8. Resumen de decisiones

| Tema | Decisión v1 |
|---|---|
| Framework de i18n | Mantener **Flutter l10n + ARB** (estándar) |
| Idiomas de UI | **3: `en`, `es`, `pt`** (completar cobertura antes de ampliar) |
| Idiomas objetivo (enseñanza) | **Solo `en`** (pipeline de voz calibrado); v2 `es`/`fr` hablantes de esos idiomas aprendiendo inglés |
| Plurals/select | Adoptar **ICU MessageFormat** en ARB |
| Fuente única de idioma UI | `userLanguageProvider` (`UserLanguageSettings`) |
| Textos hardcodeados | Migración por lotes P0/P1/P2 (inventario §5) |
| Añadir idioma | `app_XX.arb` + `gen-l10n` + registro de locale (sin tocar pantallas) |
| OTA futuro | `use-deferred-loading` cuando haya >6 idiomas o se requiera OTA |
