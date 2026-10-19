# Auditoría Estratégica del Onboarding — Documento 08

# Plan de Implementación por Fases

> **Proyecto:** TutorSaas / Dungeon of English
> **Base:** docs 01–02 (problemas), 06 (personaje), 07 (DB) — sin modificar código
> **Principios:** i18n completo primero; persistencia junto al feature que la usa; QA al final.
> **Orden de fases:** F1 → F2 → F3 → F4 → F5 → F6 (secuencial; F4/F5 son una unidad lógica).

---

## Vista general

| Fase | Nombre | Objetivo | Problema que resuelve (doc 02) | Riesgo |
|---|---|---|---|---|
| F1 | i18n completo | Migrar textos hardcodeados → ARB | P1 (crítica) | Bajo |
| F2 | País único | Catálogo ISO completo, sin sugeridos | P2, P6 | Medio |
| F3 | Oráculo conversacional | Prompt adaptativo | P8 | Medio |
| F4 | 8 clases + avatares + tarjeta | Identidad RPG | P5, P7 | Medio-Alto |
| F5 | Persistencia completa | avatarIndex + clase en DB | P7 (cierre) | Medio |
| F6 | QA | analyze / test / build / gen-l10n | — | Bajo |

**Dependencia clave:** F4 y F5 deben aterrizar juntas en release (la UI sin persistencia
regresa el gap P7; la DB sin UI deja columnas muertas). La migración SQL puede aplicarse
antes (idempotente) sin riesgo.

---

## F1 — i18n completo

### Objetivo
0 textos hardcodeados en español del onboarding; 100% consumo de `AppLocalizations`.

### Pasos
1. **Inventario de strings hardcodeados** en:
   - `onboarding_screen.dart` — snackbars (`:95`, `:102`), cabeceras (`PAÍS DE ORIGEN` `:752`, `:757`), tarjeta héroe (`¡BIENVENIDO,` `:476`, `CAZADOR!` `:481`, `Tu aventura comienza ahora` `:547`, `ENTRAR AL REINO` `:555`), pasos de clasificación (`:937`, `:942`, `:974`, `:986`, `:1001`, `:1010`), switch de interfaz (`:707-717`), país (`:814`).
   - `character_creation_wizard.dart` — `CREA TU PERSONAJE` (`:70`), subtítulo (`:76-77`), `NOMBRE DEL CAZADOR` (`:85`), hint (`:91`), `AVATAR` (`:114`), `CLASE` (`:155`), botón (`:214`), **nombres/descripciones de clase** (`:38-40`).
2. **Añadir claves ARB** a `lib/l10n/app_en.arb` (source) y es/es + pt. Reutilizar claves ya existentes no consumidas: `onboarding_lang`, `onboarding_country`, `onboarding_target`, `onboarding_cefr`, `character_name`, `oracle_continue` (doc 01 §5).
3. **Migrar widgets** a `AppLocalizations.of(context)!.<clave>`. La lista de clases pasa a un catálogo con claves de traducción.
4. **Regenerar:** `flutter gen-l10n` (obligatorio tras editar ARB).
5. **Verificar:** `flutter analyze` 0 errores; `flutter gen-l10n` sin warnings de claves faltantes.

### Archivos
- `lib/l10n/app_en.arb`, `app_es.arb`, `app_pt.arb`
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`

### Verificación
- Cambiar idioma de app a `pt` y recorrer las 5 páginas + tarjeta héroe: 0 texto en español.
- `flutter gen-l10n` regenera sin errores.

### Riesgos
- Claves con placeholders (`${_selectedNativeLanguageCode.toUpperCase()}` en `:713`) requieren sintaxis de interpolación ARB `{var}` + `@clave`.
- Descripciones de clase largas pueden desbordar la tarjeta en `pt`/`es` → reservar altura fija (doc 04 §2.1).

---

## F2 — País único (catálogo ISO completo)

### Objetivo
Un solo selector de país con todos los países ISO-3166; eliminar sugeridos y el dropdown limitado a 11.

### Pasos
1. **Catálogo de países:** crear `lib/features/onboarding/data/country_catalog.dart` (o asset JSON) con los 249 códigos ISO-3166-alpha2 + nombre localizado por idioma (es/en/pt). Fuente: datos estándar verificados (no generar de memoria).
2. **UI:** reemplazar chips sugeridos + `DropdownButton` (`onboarding_screen.dart:740-854`) por un campo de búsqueda + lista (`SearchAnchor`/`Autocomplete` nativo de Material, sin dependencias nuevas) o dropdown completo con `items` paginados.
3. **Persistencia:** mantener `_selectedCountryCode` → `users.country_code` (`onboarding_screen.dart:192-196`), sin cambios de contrato.
4. **i18n:** `country_name` en catálogo localizado (no en ARB de 249 claves — mejor data en JSON por idioma).

### Archivos
- `lib/features/onboarding/data/country_catalog.dart` (nuevo)
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `assets/data/countries_es.json` (o `en/pt`)

### Verificación
- País "Zimbabwe" y "Åland Islands" seleccionables y persistidos en `users.country_code`.
- `flutter analyze` 0 errores.

### Riesgos
- 249 ítems en `DropdownButton` son pesados → usar lista virtualizada (el `Dropdown` nativo con items largos degrada rendimiento).
- Nombres localizados (esp. `pt`) requieren 3 JSON o 1 con mapas por locale — evitar código repetido.

---

## F3 — Oráculo conversacional mejorado (prompt adaptativo)

### Objetivo
Adaptar la evaluación conversacional al perfil del jugador y a su avance dentro de la conversación (no solo longitud de palabras).

### Pasos
1. **Auditar prompt actual** del Oráculo (`oracle_conversation_screen.dart`, DeepSeek SSE) y la heurística `_computeLevel` (longitud de palabras: `oracle_conversation_screen.dart:78-87`).
2. **Prompt adaptativo:** incluir en el system prompt del LLM: idioma nativo, idioma objetivo, clase elegida (estilo de aprendizaje, doc 06 §2), objetivo (`career`/conversacional) e instrucciones de dificultad progresiva (mover el nivel hacia arriba solo si el jugador responde bien).
3. **Feedback en vivo:** mostrar al jugador pistas del nivel detectado (sin dar la puntuación hasta el final) — conecta narrativamente (P8).
4. **Persistir** resultado vía `_persistAiDetails` (sin cambios: `oracle_conversation_screen.dart:363-398`) más el nuevo `character_class` (integración con F5).

### Archivos
- `lib/features/onboarding/presentation/screens/oracle_conversation_screen.dart`
- (opcional) `lib/features/onboarding/domain/services/oracle_prompt_builder.dart`

### Verificación
- Conversación de 8+ turnos: el nivel estimado sube/baja de forma coherente con la dificultad de las respuestas.
- `flutter analyze` 0 errores; `flutter test` sin regresión en el pipeline de voz.

### Riesgos
- **No alterar el pipeline de voz** (AGENTS.md: record → Groq Whisper → DeepSeek → flutter_tts es inmutable). Solo se cambia el **prompt** del LLM y la UX.
- Prompt adaptativo puede volverse no-determinista → mantener fallback a la heurística actual si el LLM no responde con estructura esperada.

---

## F4 — 8 clases + avatares Stitch + tarjeta de aventurero premium

### Objetivo
Implementar el doc 06: 8 clases con elemento/aura, avatares Stitch y tarjeta coleccionable.

### Pasos
1. **Catálogo de clases:** `lib/features/onboarding/domain/models/hunter_class.dart` (id, icono, color token, elemento, aura, claves l10n de nombre/desc) + mapeo legacy `rogue→assassin` (doc 06 §2.2).
2. **Extender `AppColors`:** tokens para clases nuevas (`necromancer` para evitar colisión con `mage`).
3. **Wizard:** listar 8 clases; avatares pasan de iconos Material a `assets/images/avatars/player_<i>.webp` con fallback Material (doc 06 §3.3).
4. **Assets Stitch:** generar y guardar los ~14–16 retratos + prompts versionados (doc 06 §3, §5).
5. **Tarjeta de héroe:** reescribir `_buildHeroWelcomeScreen` (`onboarding_screen.dart:432-569`) → carta 3:4 con imagen principal, avatar orbe, clase, Lv., rango, elemento, aura (doc 06 §4).
6. **Ajustar `_heroClassIcon`/`_heroClassName`/`_heroClassColor`** (`onboarding_screen.dart:393-427`) o moverlos al catálogo.

### Archivos
- `lib/features/onboarding/domain/models/hunter_class.dart` (nuevo)
- `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/core/theme/app_colors.dart`
- `assets/images/avatars/*.webp` (nuevos) + `pubspec.yaml`
- `docs/Onboarding-Redesign/stitch_prompts.md` (nuevo)

### Verificación
- Seleccionar las 8 clases: colores/elementos/auras distintos y consistentes.
- Tarjeta de héroe renderiza imagen Stitch + aura; en modo offline cae al fallback Material.
- `flutter analyze` 0 errores; `flutter run` en dispositivo (RFCN80FYN6V) revisando layout en pantalla ≤ 360 dp.

### Riesgos
- **Assets:** consistencia visual (doc 06 §3.4); un retrato roto degrada todo el set.
- Tarjeta 3:4 con 6+ campos puede apretar en móvil → scroll o layout adaptativo.
- `rogue` legacy debe seguir renderizando (fallback) aunque se mapee a `assassin`.

---

## F5 — Persistencia completa + migración DB

### Objetivo
Cerrar el gap P7: persistir `avatar_index` y `character_class` (y elemento/aura) y dejar `avatar_url` para la imagen real.

### Pasos
1. **Migración SQL** (doc 07 §4) → `supabase/migrations/2026XXXX_character_identity.sql`; aplicar en rama de desarrollo / SQL Editor (idempotente).
2. **Contrato Dart:** ampliar `OnboardingRepository.saveOnboardingData` con `characterClass`, `avatarIndex`, `element`, `aura` (opcionales para no romper llamadas existentes).
3. **Repo:** escribir las 4 columnas en el upsert de `user_language_profiles` (`onboarding_repository_impl.dart:98-119`).
4. **OnboardingScreen:** pasar `data.playerClass` y `data.avatarIndex` (`onboarding_screen.dart:170-182`); `updateUserProfile` ya no recibe `avatar_url=clase` (`:207-213`).
5. **Lectura en dashboard:** `RpgAvatar`/`hunter_hud_header.dart:42` leen `avatar_url` real (imagen) con fallback a clase.

### Archivos
- `supabase/migrations/2026XXXX_character_identity.sql` (nuevo)
- `lib/features/onboarding/domain/repositories/onboarding_repository.dart`
- `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart`
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`
- `lib/core/widgets/rpg_avatar.dart`

### Verificación
- Tras completar onboarding, `SELECT character_class, avatar_index, character_element, character_aura FROM user_language_profiles` devuelve los valores elegidos.
- Backfill `rogue→assassin` aplicado una sola vez (idempotente).
- `supabase get_advisors` (security) sin nuevos hallazgos tras la migración.

### Riesgos
- DDL contra el proyecto live puede fallar ("read-only transaction") → aplicar vía SQL Editor o rama (AGENTS.md).
- Cambiar `avatar_url` de "clase" a "imagen" puede romper pantallas que aún leen la clase → mantener fallback por clase en `RpgAvatar` (doc 06 §3.3).
- El upsert usa `onConflict: 'user_id, language_id'` — la migración debe coexistir con ese conflicto (backfill con la misma PK).

---

## F6 — QA (analyze / test / build / gen-l10n)

### Objetivo
Puerta de calidad final antes de release.

### Pasos
1. `flutter gen-l10n` (tras F1, re-verificar tras F4 por nuevas claves de clase).
2. `flutter analyze` → **0 errores** (56 infos/warnings previos aceptados, AGENTS.md).
3. `flutter test` (5 archivos en `test/`) — añadir tests del catálogo de clases (mapeo `rogue→assassin`) y del catálogo de países si procede.
4. `flutter run -d RFCN80FYN6V` — smoke test del flujo completo: onboarding (5 pasos + oráculo + tarjeta) → dashboard → perfil (avatar/clase correctos).
5. Regresión de pantallas que leen `avatar_url` como clase (`profile_edit_screen.dart:640-643`, `hunter_hud_header.dart:42`, `progress_tab_view.dart:30`).
6. `dart run build_runner build --delete-conflicting-outputs` si se añadieron modelos freezed.

### Archivos
- `test/` (nuevos tests de catálogo)
- Verificación en `lib/features/dashboard/**`

### Verificación
- `flutter analyze`: 0 errores. `flutter test`: todo verde.
- Smoke test en dispositivo con modo dev (`devAlwaysShowOnboardingProvider`, `onboarding_providers.dart:13`) para repetir onboarding.

### Riesgos
- Falta de cobertura de tests en el flujo de onboarding actual (mínima) → no añadir tests UI frágiles; priorizar tests de unidades puras (catálogos, CefrRank).
- Cambios de assets pueden no empaquetarse si `pubspec.yaml` no incluye la carpeta nueva.

---

## Resumen de dependencias y orden

```
F1 (i18n) ──► F2 (país) ──► F3 (oráculo) ──► F4 (personaje UI) ──► F5 (persistencia) ──► F6 (QA)
```

- F1 y F2 son independientes entre sí y desbloquean el resto (todo el texto nuevo de F3/F4
  debe ir ya por ARB).
- F3 puede avanzar en paralelo con F4 si hay recursos (no comparten archivos críticos).
- F4 sin F5 reintroduce el gap P7 → se entregan en la misma release.
- F6 es la puerta única de salida a producción.

---

## 10. Cambios implementados (2026-07-31)

> Validado: 0 errores analyze � 73/73 tests � build APK OK.

### F1 � i18n completo
- A�adidas 10 claves nuevas a los 3 ARB (en/es/pt): onb_validate_native, onb_validate_target, login_google_error, egister_google_error, oracle_no_voice, oracle_listening, oracle_processing, oracle_skip, oracle_complete.
- Migrados strings hardcodeados en: welcome_screen.dart (2 errores Google), onboarding_screen.dart (2 validaciones), oracle_conversation_screen.dart (oracle_title, oracle_no_voice, oracle_listening/processing, oracle_complete/skip).
- lutter gen-l10n regenerado.

### F2 � Pa�s �nico
- Eliminados los chips de pa�ses sugeridos (US/MX/BR/CN/IN) de la p�gina de pa�s.
- El autocomplete con CountryCatalog (cat�logo ISO completo) queda como �nica selecci�n.

### F3 � Or�culo conversacional mejorado
- Prompt del sistema (placement_ai.dart) redise�ado: personalidad m�stica del Or�culo + evaluaci�n de **10 dimensiones** (listening, speaking, pronunciation, vocabulary, grammar, sentence_structure, confidence, fluency, response_time, naturalness).
- _scoreKeys actualizado a las 10 dimensiones.

### F4 � Personaje (verificado ya implementado)
- HunterClass.catalog ya tiene las 8 clases (warrior, mage, assassin, knight, archer, summoner, paladin, necromancer) con iconos, colores y elementos; el wizard las muestra en grid 2�2 con estilo r�nico (GlassCard + runic corners + glow). Sin cambios necesarios.
- Avatares Stitch: pendientes de que el usuario proporcione los assets.

### F5 � Persistencia completa
- onboarding_screen.dart: captura _selectedAvatarIndex del wizard y lo persiste junto con character_class en user_language_profiles.
- Migraci�n SQL 20260731_onboarding_character.sql (character_class, avatar_index) � pendiente de aplicar en SQL Editor.

### F6 � QA
- lutter analyze 0 errores � lutter test 73/73 � lutter build apk --debug OK.
- L�gica de auth/onboarding/supabase/dashboard intacta.
