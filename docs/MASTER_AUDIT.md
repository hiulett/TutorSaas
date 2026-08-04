# MASTER_AUDIT.md — TutorSaas / Dungeon of English

> **Fuente única de verdad del proyecto.** Auditoría final consolidada post-Fases 2-12.
> Fecha: 2026-07-30 · Preparado para revisión por IA externa (ChatGPT) antes de definir las fases finales hacia producción.
> Método: toda conclusión basada en evidencia verificada en código, DB, assets y documentación. No se implementaron cambios.

---

## 1. Resumen Ejecutivo

**Dungeon of English** es una app móvil Flutter/Supabase de aprendizaje de inglés conversacional con temática RPG "Isekai/System HUD". El core (conversación por voz, misiones, economía, gremio) está **funcional y estable**: `flutter analyze` 0 errores, `flutter test` 13/13, build apk OK.

- **Fases 2-6**: completadas (27/27 tareas del backlog).
- **Fases 7-10**: Guild 8/8, IA 3/3, RPG (parcial), Microinteracciones 7/7.
- **Fase 11 QA**: veredicto **LISTO PARA BETA CERRADA**; bloqueadores de seguridad DB resueltos (QA-1/2/3).
- **Fase 12**: 9 documentos maestros sincronizados.

**Problema central detectado en esta auditoría:** inconsistencia visual entre pantallas con diseño nuevo (PlantillasHTML) y pantallas con diseño antiguo. **Esto es la prioridad máxima antes de beta pública.**

**Único bloqueador de seguridad restante:** API keys reales hardcodeadas en el repo (IA-01).

---

## 2. Estado General del Proyecto

| Dimensión | Estado | Evidencia |
|---|---|---|
| Compilación | ✅ OK | `flutter build apk --debug` |
| Análisis estático | ✅ 0 errores | `flutter analyze` (64 infos/warnings tolerados) |
| Tests | ✅ 13/13 | `flutter test` (2 archivos — insuficiente para producción) |
| DB live | ✅ Operativa | Proyecto `sipiumfdpvnszthykyog`, 46 tablas públicas |
| Seguridad DB | 🟡 Parcial | QA-1/2/3 aplicados; RLS anon restante en 54 políticas |
| Seguridad claves | ❌ IA-01 pendiente | API keys en repo |
| Veredicto QA | 🟡 Beta cerrada | `docs/11_QA/Final_Audit.md` |

---

## 3. Arquitectura Actual

### Stack
| Capa | Tecnología |
|---|---|
| Mobile | Flutter 3.29 / Dart 3.11 |
| Estado | flutter_riverpod (StateNotifierProvider / FutureProvider.autoDispose / StateProvider) |
| Routing | go_router (19 rutas) |
| Backend | Supabase (Postgres 15/17, Auth, RLS, Realtime) |
| STT | Groq Whisper `whisper-large-v3-turbo` (en forzado) |
| LLM | DeepSeek `deepseek-v4-flash` (chat SSE + evaluación de metas) |
| TTS | flutter_tts on-device (rate 0.48) — $0 |
| Código | freezed + json_serializable, dio, fl_chart, google_fonts |

### Estructura (feature-first clean architecture)
```
lib/
├── app/          (app.dart, router.dart)
├── core/         (theme, widgets, i18n, constants, services, utils)
├── features/     (auth, chat_rooms, conversation, dashboard, economy, missions, onboarding, subscription, vocabulary)
├── l10n/         (.arb en/es/pt + generado)
lib/core/widgets/  (13 widgets: GlassCard, SystemWindow, SegmentedBar, AnimatedCounter, FloatingReward, RunicButton, RpgAvatar, CyberManhwaBackground, QuestCard, ManaMeter, DraggableMonster, config_error, system_mana_disruption)
```

### Decisiones de arquitectura recientes (Fases 7-11)
- Mesas del gremio leídas de DB (anti N+1, sin hardcode).
- Modelo LLM unificado `deepseek-v4-flash`; ventana móvil en evaluación de metas.
- Items `mission_modifier` con `reward_multiplier` en misiones.
- Tokens de animación `AppMotion`.

### Deuda arquitectónica
- `dashboard_screen.dart` **2040 líneas** (refactor urgente).
- `conversation_screen.dart` 1221 líneas.
- `onboarding_screen.dart` 1409 líneas.
- Misiones usa repositorio concreto (sin interfaz abstracta) — inconsistente con economía/chat_rooms.

---

## 4. Estado de cada módulo

| Módulo | Estado | Funcional | Incompleto / Bugs | Prioridad |
|---|---|---|---|---|
| **Login/Registro** | ✅ | Google sign-in, redirect onboarding/home | — | — |
| **Onboarding** | 🟡 | 9 pasos + wizard personaje + paywall dinámico | usa `hankenGrotesk` (18 refs); strings parcialmente en inglés | Media |
| **Perfil** | 🟡 | Ver/editar | usa `orbitron`+`hankenGrotesk` | Media |
| **Home/Dashboard** | 🟡 | HUD central, mapa, accesos rápidos, mission board | 6 refs `hankenGrotesk`; 2040 líneas | Media |
| **Misiones** | ✅ | Motor completo + rotación + board + modificadores | — | — |
| **Conversaciones** | ✅ | Oráculo, metas, tácticas, recompensas, ventana móvil | 2 refs `hankenGrotesk` | Baja |
| **Guild/Gran Salón** | ✅ | NPC, quest board, mesas DB, prestigio, práctica IA | moderación/audio reales simulados | Media |
| **NPC (Maestre)** | ✅ | Bienvenida + sugerencias CEFR | — | — |
| **Chat IA / Sala de voz** | 🟡 | Chat + práctica Oráculo | audio entre jugadores simulado; `orbitron` en mana_meter | Media |
| **Inventario/Items** | ✅ | Lista, equipar, filtrar, 13 items nuevos | — | — |
| **Economía** | ✅ | Gemas/oro/fragmentos, invocaciones, battle pass, daily rewards | `orbitron` en shop (1 ref) | Baja |
| **Recompensas** | ✅ | claim con multiplier, loot, daily | — | — |
| **Configuración** | ✅ | Settings | — | — |
| **Leaderboards** | 🟡 | League leaderboard | 3 refs `hankenGrotesk` | Baja |
| **Avatares/Cosméticos** | ✅ | RpgAvatar, equipar | — | — |
| **Logros** | 🟡 | Achievements grid | en dashboard | Baja |

---

## 5. Auditoría UI (prioridad máxima)

### 5.1 Mapa de estilos por pantalla (evidencia: refs a `orbitron`/`hankenGrotesk` = antiguo)

| Pantalla | Estilo | Antiguo | Nuevo | Mixto |
|---|---|---|---|---|
| WelcomeScreen | Mixto | parcial | parcial | ✅ |
| OnboardingScreen | **Antiguo** | ✅ (18 hanken) | — | — |
| OracleConversationScreen | Nuevo | — | ✅ | — |
| PlacementTestScreen | Nuevo | — | ✅ | — |
| DashboardScreen | **Antiguo** | ✅ (6 hanken) | HUD nuevo | ✅ |
| DungeonMapScreen | Nuevo | — | ✅ | — |
| HunterStatusScreen | Nuevo | — | ✅ | — |
| ProfileScreen | **Antiguo** | ✅ (2 orbitron+1 hanken) | — | ✅ |
| ProfileEditScreen | Mixto | parcial | parcial | ✅ |
| SessionSummaryScreen | **Antiguo** | ✅ (1 hanken) | — | — |
| SettingsScreen | Nuevo | — | ✅ | — |
| ConversationScreen | **Antiguo** | ✅ (2 hanken) | header nuevo | ✅ |
| LevelExamScreen | **Antiguo** | ✅ (4 orbitron) | — | — |
| ChatRoomsScreen (Salón) | Nuevo | — | ✅ | — |
| VoiceRoomScreen | **Antiguo** | ✅ (mana_meter orbitron) | parcial | ✅ |
| ShopScreen | **Antiguo** | ✅ (1 orbitron) | — | — |
| InventoryScreen | Nuevo | — | ✅ | — |
| BattlePassScreen | Nuevo | — | ✅ | — |
| PaywallScreen | 🟡 | por verificar | — | — |
| NucleoArcanoLimit | 🟡 | por verificar | — | — |
| SystemManaDisruption | **Antiguo** | ✅ (1 orbitron) | — | — |

### 5.2 Componentes con estilo antiguo (a migrar)
- `draggable_monster_widget.dart` (orbitron+hanken)
- `mana_meter_widget.dart` (orbitron)
- `system_mana_disruption_screen.dart` (orbitron)
- `status_window_modal.dart` (5 orbitron)
- Widgets de dashboard: `ai_pick_hero_card`, `daily_quests_widget`, `league_leaderboard_widget`, `lesson_preview_sheet`, `next_recommended_lesson_hero`, `recommended_lessons_hub` (todos con hankenGrotesk)

### 5.3 Componentes migrados al nuevo diseño
`GlassCard`, `SystemWindow`, `SegmentedBar`, `AnimatedCounter`, `FloatingReward`, `RunicButton`, `CyberManhwaBackground`, `QuestCard`.

---

## 6. Auditoría UX

### Fortalezas
- Onboarding completo + Oracle conversacional para evaluación CEFR.
- Gran Salón con NPC, quest board y prestigio (lobby vivo).
- Microinteracciones tokenizadas (AppMotion) con feedback visual en metas/misiones/nivel.

### Fricciones detectadas
1. **Doble limitación de uso**: cuota de minutos mensual (30/mes free) + núcleo arcano diario (invocaciones). Confuso para el usuario.
2. **Strings inconsistentes**: onboarding/salón parcialmente en inglés, app mayormente en español → i18n incompleto en onboarding (títulos sí, descripciones no).
3. **Audio del gremio simulado** (`Random()` marca "hablando") → falsa sensación de vida.
4. Sin feedback auditivo/sonido SFX en logros (el `audio_sfx_service.dart` existe pero no se usa extensivamente).
5. Accesibilidad: `AppMotion.reduceMotion` existe, pero no todas las animaciones lo respetan (el glow rúnico de GlassCard es loop infinito).

---

## 7. Auditoría RPG

| Aspecto | Estado | Notas |
|---|---|---|
| Progresión | ✅ | XP/CEFR/racha/nivel/battle pass |
| Economía | ✅ | gemas/oro/fragmentos/invocaciones, balance por nivel |
| Guild | ✅ | NPC, quest board, mesas, prestigio |
| Misiones | ✅ | 6 tipos + modificadores (reward_multiplier) |
| Inventario/Objetos | 🟡 | 13 items nuevos; colecciones/trofeos pendientes (DC-02/03) |
| Coleccionables | ❌ | Sin sistema de colección |
| Dificultad/Balance | 🟡 | Modificadores de misión sin UI (MM-04) |
| Inmersión | 🟡 | Simulación de habla/moderación en el gremio resta credibilidad |

---

## 8. Auditoría Guild

- **Gran Salón** (Fase 7): completo — NPC, quest board, mesas DB reales (room_type), prestigio, práctica IA.
- **Pendientes**: moderación IA real (hoy tips fijos), audio real entre jugadores (hoy simulado), tipos de mesa mentorship/event/training sin uso activo, colecciones de gremio/trofeos.
- **DB**: `chat_rooms`, `participants`, `messages`, `guild_quest_pool`, `guild_collaborative_missions`, `guild_battle_pass` — operativas.

---

## 9. Auditoría IA

| Aspecto | Estado | Evidencia |
|---|---|---|
| Costos | ✅ optimizado | IA-02 (flash en eval), IA-03 (ventana 12 msgs) |
| TTS | ✅ $0 | flutter_tts on-device |
| STT | ✅ | Groq whisper-large-v3-turbo |
| Prompt engineering | ✅ | role context por escenario + instrucciones de corrección |
| Contexto | ✅ | ventana móvil |
| Caché | ❌ | sin caché de respuestas (IA-06) |
| Memoria | 🟡 | escenarios persisten; chats libres efímeros |
| Embeddings | ❌ | no usados |
| Escalabilidad | ✅ | rotación diaria via SQL fn + edge function local + lazy |
| **Claves** | ✅ | IA-01 resuelto: claves fuera del repo, proxy por Edge Function |

---

## 10. Auditoría Base de Datos

- 46 tablas públicas, RLS activo.
- **95 hallazgos de performance** (Supabase Advisors): 21 FK sin índice, 17 índices sin uso, 55 RLS initplan, 1 índice duplicado (`ai_usage_logs`), 1 política duplicada (`subscription_plans`).
- **81 hallazgos de seguridad**: 54 RLS anon, 24 SECURITY DEFINER expuestas, `system_ai_settings` legible, leaked-password off.
- **Resuelto (QA-1/2/3)**: system_ai_settings → service_role; vocabulary_items validado; REVOKE EXECUTE de funciones internas (PUBLIC+anon) con regrant selectivo a authenticated.
- **Pendiente**: QA-5 (RLS `(select auth.uid())`), QA-6/7 (índices), migraciones no versionadas (aplicadas manualmente).

---

## 11. Auditoría Performance (app)

| Área | Estado | Notas |
|---|---|---|
| FPS/render | 🟡 | glow rúnico loop infinito en cada GlassCard (AN-07) |
| Memoria | 🟡 | dashboard 2040 líneas → rebuilds amplios |
| Animaciones | ✅ | tokenizadas, respetan reduce-motion parcialmente |
| Consultas | ✅ | getRooms anti N+1; evaluateGoals ventana móvil |
| IA latencia | ✅ | objetivo <1.5s |
| Batería | 🟡 | loops ambientales (glow, pulse) continuos |

---

## 12. Auditoría de Seguridad

| Ítem | Estado |
|---|---|
| RLS por usuario | ✅ mayoría de tablas (`auth.uid() = user_id`) |
| RLS anon | ⚠️ 54 políticas accesibles a anon (pendiente revisión) |
| system_ai_settings | ✅ QA-1 (service_role) |
| vocabulary_items | ✅ QA-2 (validado) |
| Funciones SECURITY DEFINER | ✅ QA-3 (PUBLIC+anon revocados, regrant selectivo) |
| **API keys en repo** | ❌ **IA-01 pendiente** (DeepSeek + Groq + fallback) |
| Leaked-password protection | ❌ deshabilitada (QA-4) |
| Crashlytics/Sentry | ⚠️ solo ErrorTracker local |

---

## 13. Auditoría de Monetización

- 4 planes en `subscription_plans` (free $0 / monthly $1.99 / annual $14.99 / lifetime $29.99) con límites de audio IA.
- MO-A/MO-B aplicados: lifetime 1200min, Battle Pass en monthly/lifetime.
- Free: 30min/mes ≈ $0.02-0.05/mes/usuario de costo real — **sostenible**.
- Tienda de energía (invocaciones +5/+20, pergaminos) + battle pass + daily rewards.
- **Pendiente**: modal de energía agotada con CTA recargar/premium (MO-C/D).

---

## 14. Auditoría de Escalabilidad

- Arquitectura feature-first + Riverpod: escalable.
- Supabase con RLS por usuario: escalable con índices.
- Costos IA contenidos por plan (minutos) y núcleo diario.
- **Riesgos**: dashboard monolítico (2040 líneas), N+1 residuales en otras consultas, migraciones manuales, pruebas insuficientes.

---

## 15. Auditoría Completa del Diseño

**El problema central:** coexistencia de 2 lenguajes visuales.

- **Diseño nuevo (estándar PlantillasHTML)**: paleta Isekai (AppColors), SpaceGrotesk/Inter/JetBrainsMono, GlassCard, radio 4px, HUD segmentado, microinteracciones. Usado en: Gran Salón, HUD, mapa mazmorras, HunterStatus, inventario, battle pass, oracle, dungeon map, settings.
- **Diseño antiguo**: `orbitron`/`hankenGrotesk`, hex hardcodeados, layout pre-migración. Persiste en: onboarding (18 hanken), dashboard (6), profile, session summary, level exam (4 orbitron), conversation (2), shop (orbitron), widgets de dashboard, mana_meter, status_window_modal, system_mana_disruption, draggable_monster.

**17 archivos con estilo antiguo detectados** (evidencia: grep `orbitron`/`hankenGrotesk`).

---

## 16. Análisis de las Plantillas HTML (estándar oficial)

21 plantillas en `PlantillaHtml/`:

| Plantilla | Uso / pantalla de referencia |
|---|---|
| abyssal_interface | **Design system base** (paleta, tokens) |
| hunter_control_center_dashboard | Dashboard/HUD |
| hunter_status_profile_system | Estado del cazador |
| learning_dungeon_map_gateways | Mapa de mazmorras |
| combat_system_english_battle | Conversación/Boss |
| conversational_tactics_navigator | Selector de tácticas |
| live_party_practice_room | Sala de voz |
| social_hall_guild | Gran Salón |
| guild_room_creation | Crear mesa |
| guild_evaluation | Oracle test |
| ai_mentor_chat_system | Coach premium |
| grimoire_recalibration_srs | Repaso SRS |
| level_exam_screen | Examen por nivel |
| session_summary_screen | Resumen de sesión |
| hunter_class_selection | Selección de clase |
| hunter_registration_license | Bienvenida/licencia |
| hunter_record_modification | Editar perfil |
| system_configuration_screen | Configuración |
| system_initialization | Carga/init |
| system_mana_disruption_error | Error/sin red |
| s_rank_system_upgrade | Paywall/upgrade |

### Design system extraído (estándar)
- **Paleta**: voidBg #05070E, manaCyan #00E5FF, royalGold #FFC700, runeViolet #9D4EDD, emeraldGreen #00E676.
- **Tipografía**: SpaceGrotesk (headlines), Inter (cuerpo), JetBrainsMono (stats/HUD).
- **Geometría**: radio 4px (>>20 solo orbes); grid 4px.
- **Superficies**: GlassCard opacidad 0.94, borde 1px cyan, glow; esquinas rúnicas.
- **Componentes**: barras segmentadas, ventanas de sistema con header mono, recompensas flotantes, botones con acento + glow, HUD con ranas/gemas.

---

## 17. Plan Maestro de Migración Visual

### Principio
Unificar TODA la app al lenguaje PlantillasHTML. Eliminar `orbitron` y `hankenGrotesk` por completo; centralizar tokens.

### Orden recomendado
1. **P0 — Base**: eliminar usos de `orbitron`/`hankenGrotesk` en widgets core (`mana_meter`, `status_window_modal`, `system_mana_disruption`, `draggable_monster`). Crear `QuestCard`/`StatTile`/`RunicButton` como estándar.
2. **P1 — Pantallas con diseño antiguo**: onboarding (18 refs), dashboard (6), profile, session_summary, level_exam (4), conversation (2), shop, voice_room → reemplazar familias de fuente + hex hardcodeados por tokens.
3. **P1 — Widgets de dashboard**: `ai_pick_hero_card`, `daily_quests_widget`, `league_leaderboard_widget`, `lesson_preview_sheet`, `next_recommended_lesson_hero`, `recommended_lessons_hub` → SpaceGrotesk/Inter.
4. **P2 — Hardenizar**: eliminar hex hardcodeados fuera de AppColors; añadir `app_spacing.dart`; migrar onboarding a i18n completo.

### Tokens a centralizar
`AppColors` (existe), `AppMotion` (existe), `AppSpacing` (crear), `AppTypography` (crear wrapper de google_fonts).

### Widgets a crear/eliminar
- **Crear**: `AppSpacing`, `AppTypography`, `StatTile`, `QuestCard` estandarizado.
- **Eliminar/refactorizar**: `status_window_modal` (reemplazado por `SystemWindow`), `mana_meter_widget` (refactor a tokens), `draggable_monster_widget` (revisar), `configuration_error_widget` (revisar).

---

## 18. Deuda Técnica

| Ítem | Severidad |
|---|---|
| dashboard_screen 2040 líneas | Alta |
| onboarding_screen 1409 líneas + hankenGrotesk 18 refs | Alta |
| conversation_screen 1221 líneas | Media |
| API keys hardcodeadas (IA-01) | Alta (seguridad) |
| RLS anon en 54 políticas (QA-5) | Media |
| Índices FK faltantes (21) + sin uso (17) + duplicado | Media |
| Tests insuficientes (2 archivos) | Media |
| Migraciones manuales sin versionar | Media |
| Strings hardcoded onboarding | Media |
| Misiones sin interfaz abstracta | Baja |

---

## 19. Riesgos

| Riesgo | Severidad | Mitigación |
|---|---|---|
| API keys en repo → abuso/costo | **Alta** | IA-01: mover a dart-define + rotar |
| Inconsistencia visual | Alta | Plan de migración (sección 17) |
| Costo IA sin tope duro por usuario | Media | ya hay cuota minutos + energía |
| Migraciones no versionadas | Media | versionar en schema_migrations |
| Simulación de audio gremio | Media | roadmap: audio real |
| Falta de tests | Media | ampliar cobertura |

---

## 20. Recomendaciones

1. **Antes que nada**: resolver IA-01 (claves) y aplicar el Plan Maestro de Migración Visual (sección 17).
2. **Seguridad**: QA-4 (leaked-password), revisar 54 políticas RLS anon.
3. **Performance**: QA-5 (RLS initplan), QA-6/7 (índices), dividir dashboard.
4. **Producto**: MM-04 (UI de modificadores de misión), MO-C/D (modal energía), audio/moderación reales en gremio.
5. **Calidad**: ampliar tests, activar Crashlytics/Sentry, verificar release en dispositivo real.

---

## 21. Roadmap Final

### 🔴 Prioridad Crítica (impide lanzamiento)
- IA-01: API keys fuera del repo + rotación.
- Plan Maestro de Migración Visual (uniformidad).

### 🟠 Prioridad Alta (antes de beta pública)
- QA-4 leaked-password · revisión RLS anon (QA-5).
- MM-04 UI de modificadores · MO-C/D modal energía.
- Dividir dashboard_screen.
- Tests de conversación/misiones/economía.

### 🟡 Prioridad Media (mejoras)
- QA-6/7 índices · versionar migraciones.
- Colecciones/trofeos (DC-02/03) · mostrar cosméticos equipados (DC-04).
- Audio/moderación real en gremio.
- Caché de respuestas IA (IA-06).

### 🟢 Prioridad Baja (ideas futuras)
- Coach premium (`ai_mentor_chat_system`), SRS review (`grimoire_recalibration_srs`).
- Mentorías/eventos como tipos de mesa.
- Notificaciones push.

---

## 22. Checklist para Beta Cerrada

- [x] Build debug OK · analyze 0 errores · tests 13/13.
- [x] QA-1/2/3 seguridad DB aplicados.
- [x] Gran Salón, misiones, economía, conversación funcionales.
- [ ] IA-01: claves fuera del repo.
- [ ] Migración visual de pantallas con diseño antiguo (al menos onboarding + dashboard).
- [ ] Strings de onboarding en español vía i18n.
- [ ] Build release probado en dispositivo real.
- [ ] Crashlytics/Sentry activos.

---

## 23. Checklist para Beta Pública

- [ ] IA-01 resuelto (bloqueador).
- [ ] Plan Maestro de Migración Visual aplicado (0 refs orbitron/hankenGrotesk).
- [ ] Revisión RLS anon (QA-5) + leaked-password (QA-4).
- [ ] Migraciones versionadas en Supabase.
- [ ] Tests ampliados (≥10 archivos, cobertura de core).
- [ ] Audio/moderación de gremio reales o claramente etiquetados como demo.
- [ ] Terminología free/premium clara (sin doble fricción).

---

## 24. Checklist para Producción

- [ ] Release optimizado (tree-shaking, split per ABI, tamaño apk).
- [ ] Observabilidad completa (Sentry/Crashlytics + analytics de funnel).
- [ ] Costos IA monitoreados (dashboards por usuario/plan).
- [ ] Backup/restore + políticas de retención de datos.
- [ ] Cumplimiento (términos, privacidad, GDPR/CCPA).
- [ ] Escalado de índice y monitoreo de RLS/initplan.
- [ ] Pruebas de carga del pipeline de voz (STT/LLM).

---

## 25. Conclusión Ejecutiva

Dungeon of English tiene un **core sólido y diferenciado**: conversación por voz con IA, progresión RPG, economía sostenible y un gremio vivo. Las fases 2-12 entregaron funcionalidad, optimización de costos, microinteracciones y seguridad DB.

**El proyecto está listo para beta cerrada** pero requiere dos acciones antes de beta pública:
1. **IA-01** (seguridad de claves) — bloqueador de seguridad.
2. **Plan Maestro de Migración Visual** — eliminar la mezcla de estilos (17 archivos con diseño antiguo) y unificar al estándar PlantillasHTML.

Con esos dos puntos resueltos, más el endurecimiento de tests y RLS, el proyecto queda en condiciones de beta pública y, posteriormente, producción.

---

*Documento generado con evidencia verificada el 2026-07-30. Incertezas señaladas explícitamente (pantallas no auditadas al detalle: paywall, nucleo_arcano_limit, level_exam visual completo).*
