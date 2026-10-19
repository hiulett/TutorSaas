# Backlog Priorizado — Internacionalización

> Fecha: 2026-08-02 · Consolidado de `02_Architecture.md`, `06_Migration_Report.md` y `07_Testing.md`.
> Prioridades: **P0** (bloqueante de primera impresión) → **P3** (pulido/cierre). La columna *Verificación* indica cómo se comprueba cada tarea.

---

## 1. Infraestructura de idioma (detección, sync, Settings)

| ID | Prioridad | Tarea | Impacto | Riesgo | Archivos | Verificación |
|---|---|---|---|---|---|---|
| INF-01 | P0 | Añadir `followDeviceLanguage` al modelo `UserLanguageSettings` (+ prefs y `toJson`) | Alto — habilita el override maestro de la UI | Medio — toca el estado canónico de idioma | `lib/core/i18n/language_settings.dart` | `flutter analyze` 0 errores; test unitario de `copyWith`/`toJson` |
| INF-02 | P0 | Crear `deviceLocaleProvider` (locale normalizado `es`/`en`/`pt` con fallback `es`) | Alto — base de la detección automática | Bajo — aislado y testeable con fake | `lib/core/i18n/` (nuevo) | Test unitario con `PlatformDispatcher` fake (§7.6.1) |
| INF-03 | P0 | Crear `effectiveUiLanguageProvider` (regla `followDeviceLanguage` × detección) y consumirlo en `MaterialApp.locale` | Alto — determina la UI efectiva | Medio — cambio en `lib/app/app.dart` afecta a toda la app | `lib/app/app.dart`, `lib/core/i18n/` | Matriz §7.3.3 en verde |
| INF-04 | P0 | Migración DB: columna `follow_device_language BOOLEAN NOT NULL DEFAULT true` en `user_settings` | Alto — persistencia remota del flag | Medio — DDL puede fallar en prod (read-only) | `supabase/migrations/` | `supabase` migración aplicada; política RLS de lectura |
| INF-05 | P0 | Sección "Language" en `settings_screen.dart` (interruptor + 2 selectores + interruptor explicaciones) | Alto — único punto de edición de idioma | Medio — UI nueva en pantalla grande | `lib/features/dashboard/presentation/screens/settings_screen.dart` | Checklist §7.5 pantalla Settings en 3 idiomas |
| INF-06 | P0 | Redirigir/eliminar el selector de idioma duplicado del perfil (`profile_edit_screen.dart:608-612`) | Medio — evita dos fuentes de edición | Bajo | `profile_edit_screen.dart` | Settings manda; perfil no edita idioma |
| INF-07 | P1 | `_syncFromSupabase()` en `UserLanguageNotifier` (pull descendente + primer registro idempotente) | Alto — sincronización entre dispositivos | Alto — lógica de arranque y conflictos | `lib/core/i18n/language_settings.dart` | QA sync §7.4 en verde |
| INF-08 | P1 | Extender `setAiExplanationsInNative` a Supabase (cierra brecha G8) | Medio — consistencia de persistencia | Bajo | `lib/core/i18n/language_settings.dart` | Upsert incluye `ai_explanations_native` |
| INF-09 | P1 | Migrar clave legacy `interface_language` → `ui_language` (lectura one-shot) | Medio — unifica fuentes de verdad | Medio — datos de usuarios existentes | `lib/core/i18n/locale_provider.dart`, `language_settings.dart` | Test unitario de migración one-shot |
| INF-10 | P2 | Retirar `LocaleNotifier` / `localeProvider` / `languageCodeProvider` / `t()` una vez sin referencias | Bajo — limpieza | Medio — si quedan referencias rompe build | `lib/core/i18n/locale_provider.dart` | `grep t(` y providers = 0; `flutter analyze` |

---

## 2. Migración de textos (lotes P0–P3)

> La verificación de cada lote incluye: `flutter gen-l10n`, `flutter analyze` 0 errores, `flutter test` verde y el checklist §7.5 de las pantallas del lote en 3 idiomas.

| ID | Prioridad | Tarea | Impacto | Riesgo | Archivos | Verificación |
|---|---|---|---|---|---|---|
| MIG-01 | P0 | Fundación de idioma: `app.dart` title, `settings_screen` (23 títulos → `settings_*`), `onboarding_screen` hint, `welcome_screen`, `oracle_conversation_screen`; crear claves base (`view_all`, `common_got_it`, `language_*`) | Alto — primera impresión y claves reutilizables | Bajo | `app.dart`, `settings_screen.dart`, `onboarding_screen.dart`, `welcome_screen.dart`, `oracle_conversation_screen.dart` | Checklist §7.5 (Welcome/Onboarding/Settings) + barrido grep |
| MIG-02 | P1 | Dashboard + Perfil (29 textos + secundarias) | Alto — pantallas más visitadas | Medio — plurales/fórmulas | `progress_tab_view.dart`, `profile_screen.dart`, `profile_edit_screen.dart`, `session_summary_screen.dart`, `recommended_lessons_hub.dart`, `next_recommended_lesson_hero.dart`, `practice_heatmap.dart`, `fluency_latency_chart.dart`, `hunter_hud_header.dart`, `hunter_status_screen.dart`, `leaderboard_screen.dart` | Barrido grep de los 11 archivos; checklist P1 |
| MIG-03 | P2 | Chat Rooms + Conversación + Economía (33 textos + secundarias) | Alto — volumen mayor, errores con interpolación | Alto — cadenas en inglés mezcladas, placeholders | `chat_rooms_screen.dart`, `voice_room_screen.dart`, `conversation_screen.dart`, `level_exam_screen.dart`, `live_goals_tracker_bar.dart`, `mission_board_widget.dart`, `inventory_screen.dart`, `nucleo_arcano_limit_screen.dart`, `battle_pass_screen.dart`, `collections_screen.dart`, `daily_reward_modal.dart`, `conversational_tactics_navigator.dart` | Barrido grep; checklist P2 (Guild/Voice/Conversación/Economía) |
| MIG-04 | P3 | Resto: `srs_flashcard_modal.dart` (4), `paywall_screen.dart` (3) | Medio | Bajo | `srs_flashcard_modal.dart`, `paywall_screen.dart` | Barrido grep; checklist P3 |
| MIG-05 | P3 | Estrategia de datos para `lesson_catalog.dart` (17 títulos de lecciones) | Medio — contenido localizado | Alto — decisión de modelo de datos | `lesson_catalog.dart` (o JSON/columna BD) | Verificación de catálogo en `es`/`en`/`pt` |
| MIG-06 | P3 | Barrido global de cierre: `grep` de `Text(`, `labelText:`, `hintText:`, `tooltip:`, `title:`, `t(` en `lib/` | Alto — garantiza completitud | Bajo | `lib/features/`, `lib/core/` | 0 literales en archivos migrados; 0 llamadas a `t(` |

---

## 3. Calidad y pruebas

| ID | Prioridad | Tarea | Impacto | Riesgo | Archivos | Verificación |
|---|---|---|---|---|---|---|
| QA-01 | P0 | Script de paridad de claves entre `app_en.arb`, `app_es.arb`, `app_pt.arb` | Alto — evita claves faltantes por idioma | Bajo | test/ + ARB | Test unitario de paridad pasa |
| QA-02 | P1 | Test unitario `UserLanguageNotifier` (carga, fallback, persistencia 4 campos, pull idempotente) | Alto — estado canónico | Medio | test/ | `flutter test` |
| QA-03 | P1 | Test unitario `effectiveUiLanguageProvider` con `deviceLocaleProvider` fake (matriz §7.3.3) | Alto — regla de detección | Medio | test/ | `flutter test` |
| QA-04 | P2 | QA funcional manual completo (checklist §7.5 en 3 idiomas + §7.2–7.4) | Alto — aceptación de usuario | Medio | — (manual) | Checklist firmado + sin claves en texto plano |
| QA-05 | P2 | Prueba de sync entre 2 dispositivos (push + pull + conflictos + sin conexión) | Alto | Alto | — (manual, 2 devices) | §7.4 en verde |
| QA-06 | P2 | Barrido automatizable en CI (`grep`) para detectar regresiones de hardcoded | Medio | Bajo | CI workflow | Fallo de CI si aparecen literales nuevos |

---

## 4. Orden recomendado de ejecución

```
Fase A — Fundación (P0): INF-01 → INF-02 → INF-03 → INF-04 → MIG-01 → INF-05 → INF-06 → QA-01
Fase B — Dashboard + Perfil (P1): INF-07 → INF-08 → INF-09 → MIG-02 → QA-02 → QA-03
Fase C — Chat/Conv/Economía (P2): MIG-03 → QA-04 → QA-05 → QA-06
Fase D — Cierre (P3): MIG-04 → MIG-05 → INF-10 → MIG-06 → 09_Final_Report.md
```

---

## 5. Criterios de definición de terminado (DoD) global

- [ ] Todos los items P0 y P1 cerrados.
- [ ] `flutter analyze` 0 errores y `flutter test` verde en cada fase.
- [ ] Cero literales de UI en los 20 archivos del inventario (barrido §MIG-06).
- [ ] `followDeviceLanguage` funcional y persistido (local + Supabase).
- [ ] Sincronización entre dispositivos verificada (QA-05).
- [ ] Checklist de pantallas firmado en `es`/`en`/`pt` (QA-04).
- [ ] `docs/Internationalization/09_Final_Report.md` completado.
