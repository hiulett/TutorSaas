# 12 — Calidad, rendimiento y mantenibilidad

> Medición: 25-oct-2026. Se ejecutaron `flutter test` y `flutter analyze`; ambos
> son de solo lectura.

---

## 1. Estado medido

| Comprobación | Resultado | Nota |
|---|---|---|
| `flutter analyze` | **0 errores, 35 warnings, 128 infos** (163 issues) | Sale con **código 1** |
| `flutter test` | **159 pruebas, todas en verde** | 20 archivos |
| Cobertura | No medida | No hay `coverage` configurado |
| CI | `flutter analyze` + `flutter test` en push/PR | **El job de analyze falla por el código de salida** |

La documentación previa dice "155 pruebas" y "36 warnings + 128 infos"
(`docs/ARCHITECTURE.md:136-137`); hoy son 159 y 35.

### Consecuencia del código de salida
`flutter analyze` devuelve 1 cuando hay cualquier issue. El workflow
`.github/workflows/ci.yml` ejecuta el comando sin `--no-fatal-warnings`, así que
**el pipeline queda rojo** con los 35 warnings actuales. No hay evidencia en el
repo de que se haya mitigado; verificar en GitHub Actions.

---

## 2. Pruebas existentes

| Archivo | Pruebas | Qué cubre |
|---|---|---|
| `mission_models_test.dart` | 24 | Modelos de misión |
| `aura_system_test.dart` | 19 | Fórmula del aura y desbloqueo |
| `oracle_conversation_test.dart` | 17 | Heurística CEFR del Oráculo |
| `lesson_unlock_service_test.dart` | 16 | Umbrales de desbloqueo |
| `economy_repository_helpers_test.dart` | 15 | Helpers de economía |
| `mission_progress_service_test.dart` | 14 | Progreso de misiones |
| `lesson_catalog_test.dart` | 11 | 140 lecciones, 20 por nivel, IDs únicos |
| `lesson_halo_test.dart` | 11 | Tiers de halo |
| `overflow_test.dart` | 5 | Overflow en pantallas pequeñas |
| `text_scale_test.dart` | 5 | Escalado de texto |
| `dashboard_repository_test.dart` | 4 | Repositorio del dashboard |
| `hunter_level_test.dart` | 4 | Curva XP→nivel |
| `srs_grade_test.dart` | 4 | Grados SM-2 |
| `guild_master_stream_test.dart` | 3 | Streaming del Maestre |
| `bundled_fonts_test.dart` | 2 | Fuentes empaquetadas |
| `l10n_encoding_test.dart` | 1 | Codificación ARB |
| `widget_test.dart` | 1 | Arranque sin sesión → Welcome |
| Golden (`glass_card`, `rpg_chips`, `segmented_bar`) | 3 | Widgets base |

### Qué **no** está cubierto

- Parser SSE del proxy y manejo de 429/500.
- `llm-proxy` y `lesson-generator` (ni tests de contrato ni de integración).
- Flujo completo de conversación (solo la heurística del Oráculo).
- Persistencia real (Supabase se mockea o no se toca).
- Compras/RevenueCat.
- Navegación (redirect), salvo el smoke test de arranque.
- Accesibilidad (semántica, contraste, lectores de pantalla).

---

## 3. Manejo de errores

Patrón dominante: `try { … } catch (e) { debugPrint(...) }` y, en muchos casos,
`catch (_) {}` sin mensaje. Ejemplos con impacto funcional:

| Archivo | Línea | Qué se silencia |
|---|---|---|
| `onboarding_screen.dart` | 242-263 | Falla al guardar clase/avatar/bio → onboarding "completado" con datos parciales |
| `dashboard_repository_impl.dart` | 386-388, 605-607, 727-729 | Errores de settings, práctica y vocabulario |
| `dashboard_repository_impl.dart` | 781-817 | `updateUserProfile` no comprueba error |
| `srs_flashcard_modal.dart` | 71 | Falla del RPC de repaso: el usuario ve la tarjeta como repasada |
| `lesson_generator_service.dart` | 18-24 | Falla de generación de refuerzo |
| `retention_analytics.dart` | 37-40 | Eventos perdidos |

**No hay** pantalla de error global, ni reintento con backoff en el cliente (solo
2 intentos fijos a 2 s en el repositorio de conversación), ni estados vacíos
explicativos más allá de placeholders.

---

## 4. Logging y observabilidad

- `debugPrint` en todas las capas (se elimina en release).
- `ErrorTracker.init()` se llama en `main`, pero `logError`/`logEvent` solo hacen
  `debugPrint`: **no hay crash reporting**.
- No hay Sentry/Firebase Crashlytics (0 dependencias).
- `api_request_logs` guarda `invoke_llm`/`invoke_llm_error` sin tokens.
- `analytics_events`: 8 tipos de evento (doc 17).

---

## 5. Rendimiento (análisis estático)

| Punto | Riesgo | Evidencia |
|---|---|---|
| `getUserAchievements` | Hace 5-6 consultas encadenadas (perfiles, conversaciones, todos los mensajes del usuario, vocabulario, catálogo, desbloqueos) y **upserts dentro del bucle** de logros | `dashboard_repository_impl.dart:248-363` |
| `getRecommendedLessons` | 4 consultas secuenciales + orden en cliente | `:73-245` |
| `syncEarnedTitles` | Recalcula métricas con 5 consultas cada vez | `:914-961` |
| `sync-entitlement` | Se invoca al crear el provider premium (autoDispose) | `subscription_providers.dart:43-63` |
| `messages` | `sequence_number` calculado con `MAX+1` por mensaje (carrera potencial) | `repo:429-452` |
| Liderboard | Consulta global sin paginación ni índice específico | `get_leaderboard` |
| Historial de chat | Se envían 24 mensajes completos en cada turno (coste de tokens) | `conversation_providers.dart:1057` |
| Arranque | Splash fijo 800 ms + warm-up de red | `splash_screen.dart:65-70` |

No se midió tiempo de arranque, FPS ni memoria (requiere dispositivo).

---

## 6. Mantenibilidad

| Indicador | Valor |
|---|---|
| Archivos Dart (sin generados) | ~200 |
| Archivo más grande | `lesson_catalog.dart` (4.600+ líneas de datos) |
| Widgets > 1.000 líneas | `conversation_screen.dart` (1.462), `settings_screen.dart` (1.361), `chat_rooms_screen.dart` (1.227), `voice_room_screen.dart` (1.171), `onboarding_screen.dart` (966) |
| Dependencias sin uso | 13 |
| Código muerto señalado por el analyzer | ~10 warnings de `dead_code` |
| Duplicación de lógica | CEFR→rango en 3 sitios; two "completada"; dos rachas; dos barras de maná |
| Documentación vs código | Deriva confirmada en al menos 8 puntos (docs 02, 05, 08, 10) |

### Deuda estructural concreta

1. **Dos fuentes de currículo** (Dart y BD) sin sincronización.
2. **Lógica de negocio en repositorios** (estrellas, racha, progreso) en lugar de
   dominio/servidor.
3. **Estado derivado recalculado** en varios providers sin caché.
4. **Configuración duplicada** (`system_ai_settings` vs constantes del proxy;
   precios en BD vs RevenueCat).
5. **Pantallas monolíticas** que mezclan layout, lógica y acceso a datos.

---

## 7. Accesibilidad e i18n

- 951 claves en `app_en.arb` y paridad en es/pt (test de codificación en verde).
- Textos hardcodeados mezclados ES/EN persisten en `settings_screen.dart` y
  `profile_edit_screen.dart`.
- Sin `Semantics` explícitos ni tests de lectores de pantalla.
- Contraste: no auditado visualmente; la paleta es oscura con acentos saturados.
- Escalado de texto: cubierto por `text_scale_test.dart` (1.5×) en varias
  pantallas.

---

## 8. Conclusión de calidad

El proyecto tiene una **base de tests mejor que la media** para una app de este
tamaño, pero cubre **lógica pura**, no integraciones. Los riesgos de calidad no
están en la cobertura de fórmulas, sino en:

1. la **ausencia de observabilidad** (errores y costes),
2. los **silencios** (`catch (_) {}`) que ocultan fallos reales,
3. la **deriva** entre documentación, repo y producción,
4. y el **pipeline en rojo** por warnings.
