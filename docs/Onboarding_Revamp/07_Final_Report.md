# 07 — Informe Final — Onboarding Revamp

> Proyecto: TutorSaas / Dungeon of English · Fecha: 2026-07-31
> Estado: ✅ Implementado y validado (0 errores analyze · 73/73 tests · build APK OK)

---

## 1. Resumen ejecutivo

El onboarding fue rediseñado para separar decisiones, preparar la clasificación automática por IA y unificar la estética Isekai / Webtoon / System HUD. No se eliminó funcionalidad: se reorganizó, se modernizó y se preparó el sistema para la clasificación por voz con IA.

## 2. Hallazgos del análisis (auditoría 01)

1. Página 1 del onboarding mezclaba 4 decisiones (idioma nativo + país + switch + idioma objetivo).
2. Selección manual de nivel CEFR (contradice la clasificación por IA).
3. La evaluación del Oráculo usaba heurística de longitud de palabras escritas (NO voz ni IA).
4. Existía `/oracle-quiz` (opción múltiple) huérfano, sin referencia en el flujo.
5. No existía mapeo CEFR ↔ rango del juego (E..SSS) ni persistencia de fortalezas/debilidades/explicación.
6. `avatarIndex` se recogía pero no se persistía; `savePlacementResult` solo guardaba cefrLevel + quizScore.

## 3. Cambios implementados

### 3.1 Estructura del flujo (5 pasos separados) — `onboarding_screen.dart` (728→~820 líneas)
- **Paso 0 "Idioma del Despertar"**: solo idioma nativo + switch de interfaz.
- **Paso 1 "País de Origen"**: chips sugeridos (US/MX/BR) + dropdown con catálogo completo.
- **Paso 2 "Idioma a Aprender"**: idioma objetivo separado.
- **Paso 3 "Clasificación del Oráculo"**: sin niveles manuales — explicación + botón "INICIAR EVALUACIÓN" → `/oracle-test`. Opcional (default A1 si se omite).
- **Paso 4 "Creación del Personaje"**: wizard RPG.
- `_nextPage()` con validaciones por paso; `_completeOnboardingAndPurchase()` con default A1 y persistencia de `game_rank`.

### 3.2 Evaluación por IA — capa de datos (nueva)
- **`lib/core/ai/placement_ai.dart`**: `PlacementAiEvaluator.evaluatePlacement(respuestas)` — prompt DeepSeek estilo Oráculo, salida JSON estricta (cefr_level, game_rank, scores, strengths, weaknesses, explanation, recommended_focus), parse defensivo con fallback a heurística.
- **`lib/features/onboarding/domain/models/cefr_rank.dart`**: mapeo CEFR↔rango (A1→E, A2→D, B1→C, B2→B, C1→A, C2→S/SS/SSS) + descripciones.
- **`placement_result.dart`** (freezed): 6 campos nuevos opcionales (gameRank, scores, strengths, weaknesses, explanation, recommendedFocus). Codegen regenerado.

### 3.3 Oráculo conversacional — `oracle_conversation_screen.dart`
- `_finish()` llama a `PlacementAiEvaluator`; si falla, usa heurística.
- Persistencia extra: `_persistAiDetails` upsert en `user_language_profiles` (game_rank, placement_scores/strengths/weaknesses JSONB, placement_explanation, recommended_focus, assessed_at) — tolerante a migración no aplicada.
- Devuelve resultado al flujo: `Navigator.pop(placementResult)` con fallback a `/home`.
- Muestra resultado en pantalla (CEFR + rango + explicación) antes de navegar.
- Botón de envío → `RunicButton`.

### 3.4 Personaje RPG — `character_creation_wizard.dart`
- Tarjetas de clase con borde rúnico + glow + check + animación de entrada (AppMotion, respeta reduce-motion).
- Avatares como orbes con anillo de selección (`AppRadius.circleBorder`).
- Botón → `RunicButton`; nombre con estilo System HUD.
- Eliminado código muerto (`_pulseController`). API intacta.

### 3.5 Notificaciones elegantes — `lib/core/widgets/system_snack.dart` (nuevo)
- Helper `SystemSnack.show` con tipos semánticos (success/error/warning/info/reward).
- Fondo `surfaceContainerHigh` + borde de acento semántico (sin colores planos brillantes).
- **28 SnackBars migrados** en 14 archivos (voice_room, conversation, hunter_status, profile_edit, settings, learning_path_roadmap, progress_tab_view, battle_pass, fragments_exchange, inventory, shop, nucleo_arcano, onboarding, placement_test).

### 3.6 Migración SQL — `supabase/migrations/20260731_onboarding_revamp.sql`
- Columnas nuevas en `user_language_profiles`: `game_rank`, `placement_scores`, `placement_strengths`, `placement_weaknesses`, `placement_explanation`, `placement_recommended_focus`, `placement_assessed_at`. Idempotente.

## 4. Verificación

| Check | Resultado |
|-------|-----------|
| `flutter analyze` | 0 errores (146 infos pre-existentes) ✅ |
| `flutter test` | 73/73 ✅ |
| `flutter build apk --debug` | OK ✅ |
| `dart run build_runner` | 554 outputs OK ✅ |
| Lógica de negocio | intacta (solo se reorganizó contenedor visual y se añadió evaluación IA) |

## 5. Riesgos y pendientes

- **Migración SQL pendiente de aplicar** en SQL Editor (la app degrada con gracia si no está).
- **`/oracle-quiz`** (placement_test) sigue existiendo como ruta pero sin entrada en el nuevo flujo — decisión de producto: mantenerlo como herramienta de QA o retirar la ruta.
- La evaluación por voz real (hold-to-talk en el oráculo) usa el pipeline existente; el `TextField` sigue disponible como fallback. La integración completa de STT por voz en el oráculo puede ser iteración siguiente (reutilizar `transcribeAudio` de ConversationRepository).
- **`avatarIndex`** sigue sin persistirse (el perfil usa avatarUrl = clase). Pendiente menor.

## 6. Resultado esperado (logrado)

- ✅ Onboarding con estructura clara: idioma / país / objetivo / clasificación / personaje separados.
- ✅ Clasificación por IA con rango del juego persistido.
- ✅ Personaje con estética RPG moderna.
- ✅ Notificaciones elegantes y consistentes.
- ✅ Documentación completa en `Docs/Onboarding_Revamp/` (7 documentos).
