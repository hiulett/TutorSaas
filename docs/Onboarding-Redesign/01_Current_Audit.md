# Auditoría Estratégica del Onboarding — Documento 01

# Estado Actual del Onboarding

> **Proyecto:** TutorSaas / Dungeon of English (Flutter)
> **Alcance:** `lib/features/onboarding/` + navegación + persistencia + voz
> **Método:** Hallazgos verificados contra `file:line` (sin re-análisis de código)
> **Fecha:** 2026-08-02

---

## 1. Resumen ejecutivo

El onboarding actual es un **formulario de 5 pasos en un `PageView`** que recopila datos del usuario (idioma nativo, país, idioma objetivo, evaluación IA opcional y creación de personaje). Funcionalmente completo y persistente, pero arquitectónicamente rígido:

- 3 de 5 pasos dependen de **listas hardcodeadas** en el propio widget (`onboarding_screen.dart`).
- Los textos están **mezclados** entre l10n y strings en español en línea.
- El único paso "narrativo" (la evaluación Oráculo) está **desconectado** visualmente del resto: es un push a otra ruta con pantalla distinta.
- La transición a la identidad (creación de personaje) ocurre **después** de la evaluación, sin hilo narrativo que la justifique.

El resultado percibido por el jugador es el de **llenar un formulario con estética RPG**, no el de **despertar dentro de una misión**.

---

## 2. Flujo de navegación (pipeline global)

```
router.dart (redirect → Navigation Decision Engine)
   └─ SplashScreen
       └─ WelcomeScreen
           └─ /onboarding  →  OnboardingScreen (5 pasos)
               ├─ Paso 0  Nativo
               ├─ Paso 1  País
               ├─ Paso 2  Objetivo
               ├─ Paso 3  Clasificación (→ push /oracle-test, retorno)
               └─ Paso 4  Personaje (CharacterCreationWizard)
                   └─ _completeOnboardingAndPurchase()  →  guarda → /home
```

**Evidencia:**
- Router centralizado con `redirect` y `refreshListenable` que re-evalúa según sesión o modo dev: `lib/app/router.dart:42`, `lib/app/router.dart:179`.
- Ruta `/onboarding` registrada y excluida del redirect: `lib/app/router.dart:47`, `lib/app/router.dart:72`.
- El flujo real de decisión de pantalla inicial vive en el Navigation Decision Engine: `lib/app/navigation_resolver.dart:59` (expone `devModeProvider = devAlwaysShowOnboardingProvider`).

---

## 3. Los 5 pasos en detalle

### 3.1 Paso 0 — Idioma nativo
- Lista **hardcodeada** de 8 idiomas (`es/en/fr/de/pt/it/zh/ja`): `lib/features/onboarding/presentation/screens/onboarding_screen.dart:55-64`.
- Campo con valor por defecto `es` (español): `onboarding_screen.dart:39`.
- Validación: si está vacío muestra snackbar en español hardcodeado: `onboarding_screen.dart:94-98`.

### 3.2 Paso 1 — País de origen
- Lista **hardcodeada** de 11 países (`MX/CO/ES/US/AR/CL/PE/BR/FR/DE/IT`): `onboarding_screen.dart:66-78`.
- Países sugeridos también hardcodeados (`US/MX/BR/CN/IN`): `onboarding_screen.dart:742`.
- Texto de cabecera hardcodeado en español: `PAÍS DE ORIGEN`, `onboarding_screen.dart:752`; descripción `onboarding_screen.dart:757`.
- País se persiste al final en `users.country_code`: `onboarding_screen.dart:192-196`.

### 3.3 Paso 2 — Idioma objetivo
- Lista **hardcodeada** de 4 idiomas (`en/fr/de/it`) con descripciones de marketing: `onboarding_screen.dart:80-85`.
- **Sin opción para otros idiomas de gran demanda** (p.ej. portugués como objetivo, mandarín, japonés). El paso de nativo tiene 8 idiomas pero el de objetivo solo 4.
- Valor por defecto `en`: `onboarding_screen.dart:38`.
- Validación con snackbar en español: `onboarding_screen.dart:101-106`.

### 3.4 Paso 3 — Clasificación IA (Oráculo) — opcional
- `_startOracleEvaluation()` hace `context.push('/oracle-test')`: `onboarding_screen.dart:143-158`.
- Al regresar escribe `cefrLevel` y `gameRank` y avanza a la página 4: `onboarding_screen.dart:146-152`.
- **Es omitible**: si no se evalúa, se parte de CEFR `A1` por defecto: `onboarding_screen.dart:166-168`.
- La pantalla destino es `OracleConversationScreen` (chat de voz): ruta `/oracle-test` registrada en `lib/app/router.dart:7` (import de `oracle_conversation_screen.dart`).

### 3.5 Paso 4 — Personaje
- `CharacterCreationWizard`: 3 clases hardcodeadas (warrior=«Berserker», mage=«Mago Arcano», rogue=«Pícaro`) con iconos/descripciones en español: `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart:37-41`.
- 6 avatares hardcodeados con iconos de Material + colores de tema: `character_creation_wizard.dart:43-50`.
- Texto `NOMBRE DEL CAZADOR` hardcodeado en español: `character_creation_wizard.dart:85`.

---

## 4. Persistencia

`saveOnboardingData` persiste de forma **transaccional por bloques** (cada tabla en su propio try-catch):

| Tabla | Qué guarda | Evidencia |
|---|---|---|
| `public.users` | upsert del perfil (`id`, email, display_name, native_language) | `onboarding_repository_impl.dart:30-40` |
| `languages` | lookup o insert del idioma objetivo (code, name, native_name, flag_emoji) | `onboarding_repository_impl.dart:43-60` |
| `user_language_profiles` | perfil de aprendizaje (CEFR, daily goal, interests, correction style, tutor personality, learning style, obstacle) | llamado desde `onboarding_screen.dart:170-182` |
| `user_settings` | switch de idioma de UI a nativo | `onboarding_screen.dart:184-190` |
| `user_progress` | rank/XP inicial si hay `gameRank` | `onboarding_screen.dart:198-199` |

Firma del método: `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart:10-23`.
Tipo de target user: `user.id` o fallback `guest_<timestamp>`: `onboarding_screen.dart:163-164`.

**Observación estratégica:** la persistencia es robusta y tolerante a fallos (bloques con catch), pero el "estado del personaje" (clase, avatar, nombre) **no se observa en los parámetros de `saveOnboardingData`** — la identidad creada en el paso 4 queda en el widget sin persistir (ver gap funcional en doc 02).

---

## 5. i18n — estado parcial

- 3 ARB de template: `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, `lib/l10n/app_pt.arb`.
- Se usa `AppLocalizations.of(context)` en el screen: import en `onboarding_screen.dart:19`.
- Sin embargo, **una parte grande de los textos del onboarding siguen hardcodeados en español**:
  - Snackbars de validación: `onboarding_screen.dart:95`, `onboarding_screen.dart:102`.
  - Cabeceras de paso: `PAÍS DE ORIGEN` (`:752`), textos descriptivos (`:757`).
  - Tarjeta héroe de bienvenida: `¡BIENVENIDO,` / `CAZADOR!` (`:476`, `:481`).
  - Wizard de personaje: nombres de clases y descripciones (`character_creation_wizard.dart:37-41`), `NOMBRE DEL CAZADOR` (`:85`).

**Consecuencia:** en `pt` y `en`, los pasos 1 y 4 (y partes de 0/2) muestran español. Los textos l10n existentes del onboarding (p.ej. `onboarding_country` = "REGISTRO DE CAZADOR", `character_name` = "NOMBRE DEL CAZADOR", `oracle_continue` = "RECIBIR CARNET DE CAZADOR") ya están en los ARB (`lib/l10n/app_es.arb:113`, `:164`, `:174`) pero **no se consumen** en las pantallas — duplicación entre l10n y hardcode.

---

## 6. Pipeline de voz (paso Oráculo)

- `VoiceService` ejecuta la cadena completa: **record (AAC/m4a) → Groq Whisper STT (`en` forzado) → DeepSeek SSE streaming → flutter_tts (rate 0.48)**.
- `PlacementAiEvaluator` (DeepSeek) evalúa y devuelve **CEFR + game_rank (E–SSS)**; el resultado alimenta `_selectedCefrCode` y `_gameRank` en `onboarding_screen.dart:148-151`.
- El pipeline de voz es **inmutable por decisión de arquitectura** (ver AGENTS.md): no se debe alterar en el rediseño, solo reenmarcar su UX.

**Implicación narrativa:** este es el único momento "vivo" del onboarding — el jugador habla y el mundo responde con un rango. Es el ancla natural para el gancho de historia del prólogo.

---

## 7. Modo dev

- `devAlwaysShowOnboardingProvider` (`StateNotifierProvider<DevAlwaysShowOnboardingNotifier, bool>`) con persistencia en `SharedPreferences`: `lib/features/onboarding/presentation/providers/onboarding_providers.dart:13`.
- Exposición al router a través del Navigation Decision Engine: `lib/app/navigation_resolver.dart:59`.
- Toggle disponible en Settings: `lib/features/dashboard/presentation/screens/settings_screen.dart:1196`, `:1238`.

Útil para QA continuo del flujo completo (reforzar para el rediseño: permitir "reproducir prólogo" en cada iteración).

---

## 8. Diagrama de dependencias del flujo

```
                    ┌───────────────────────────────┐
                    │    router.dart (redirect)     │
                    └──────────────┬────────────────┘
                                   ▼
                    ┌───────────────────────────────┐
                    │        OnboardingScreen       │  (1021 líneas)
                    │  PageView 5 pasos             │
                    └────┬──────┬──────┬────────────┘
                         │      │      │
        push('/oracle-test')    │      │
                         │      │      │
        ┌────────────────┴─┐    │      └────► CharacterCreationWizard
        │OracleConversation│    │            (3 clases + 6 avatares)
        │Screen (VoiceService)│  │
        └──────────────────┘    │
                                ▼
                    ┌───────────────────────────────┐
                    │  _completeOnboardingAndPurchase│
                    │  OnboardingRepositoryImpl      │
                    │  users / languages / profiles  │
                    │  settings / progress           │
                    └───────────────┬────────────────┘
                                    ▼
                                /home
```

---

## 9. Datos duros para el plan

| Métrica | Valor |
|---|---|
| Líneas totales de `onboarding_screen.dart` | 1.021 |
| Pasos del PageView | 5 |
| Listas hardcodeadas (nativo / país / objetivo / sugeridos) | 4 (8 / 11 / 4 / 5 ítems) |
| Clases de personaje hardcodeadas | 3 |
| Avatares hardcodeados | 6 |
| ARB disponibles | 3 (en/es/pt) |
| Textos del onboarding hardcodeados en español (muestra) | ≥ 6 (snackbars, cabeceras, tarjeta héroe, wizard) |
| Tablas persistidas | 5 |
| Pipeline de voz | record → Groq STT → DeepSeek → flutter_tts |
| Modo dev para repetir onboarding | `devAlwaysShowOnboardingProvider` |

---

## 10. Conclusión de estado

El onboarding es un **MVP funcional con capa visual RPG**, no un onboarding de juego. Toda la "magia" está concentrada en el paso Oráculo (voz + IA); el resto son formularios. El rediseño (docs 02 y 03) debe:

1. Convertir la recopilación de datos en **narrativa de prólogo**.
2. Mover las listas hardcodeadas a **config/API + catálogo por idioma**.
3. **Completar i18n** de los textos pendientes.
4. Envolver la evaluación Oráculo como **acto central de la historia** (no como paso de formulario).
5. Persistir la **identidad del personaje** (gap funcional).
