# 01 — UI Audit: Pantallas actuales vs PlantillaHtml

> Fase 0/1 · Auditoría de UI por pantalla · Fecha: 2026-07-30
> Criterio: `PlantillaHtml/` es la fuente oficial de diseño visual (21 plantillas, cada una con `DESIGN.md` + `code.html`).

## 1. Mapa de correspondencia Pantalla ↔ Plantilla

| Pantalla actual | Ruta | Plantilla oficial | Paridad visual |
|---|---|---|---|
| `WelcomeScreen` | `/` | `hunter_registration_license` / `system_initialization` | Parcial — falta identidad "license" de bienvenida |
| `OnboardingScreen` | `/onboarding` | `hunter_class_selection` + `level_exam_screen` | Parcial — wizard de clases no conectado |
| `DashboardScreen` (4 tabs) | `/home` | `hunter_control_center_dashboard` | **Baja** — el HUD central (mana gem, party, notifications, runas) no se corresponde |
| `VoiceRoomScreen` | `/voice-room` | `live_party_practice_room` | Parcial — layout de sala multiusuario básico |
| `ConversationScreen` | `/conversation` | `combat_system_english_battle` | Media — tiene boss/NPC + goals, falta estética de "battle HUD" |
| `SessionSummaryScreen` | `/summary` | `session_summary_screen` | Baja — faltan la composición "Quest Clear" y recompensas |
| `PaywallScreen` | `/paywall` | `s_rank_system_upgrade` | Baja — falta el upgrade/rank framing |
| `ProfileScreen` | `/profile` | `hunter_status_profile_system` | **Baja** — esta es la pantalla de "Estado del Cazador" que quedó pendiente |
| `SettingsScreen` | `/settings` | `system_configuration_screen` | Media — estructura de sistema presente |
| `ProfileEditScreen` | `/profile-edit` | `hunter_record_modification` | Media |
| `ChatRoomsScreen` | `/chat-rooms` | `social_hall_guild` | Media — lista de raid rooms básica |
| `LevelExamScreen` | `/level-exam` | `level_exam_screen` | Media — OCR del examen existe |

## 2. Plantillas SIN pantalla en la app (gaps)

| Plantilla | Pantalla requerida | Estado |
|---|---|---|
| `learning_dungeon_map_gateways` | Mapa/roadmap de mazmorras (selección de scenario) | **No existe** |
| `conversational_tactics_navigator` | Selector de topic/tácticas antes de la conversación | **No existe** |
| `grimoire_recalibration_srs` | Modal de repaso SRS (vocabulary SM-2) | **No existe** |
| `ai_mentor_chat_system` | Coach premium / mentor chat | **No existe** |
| `guild_room_creation` | Modal de creación de sala | **No existe** |
| `guild_evaluation` | Oracle test / evaluación de gremio | **No existe** (el screen untracked no está cableado) |
| `hunter_status_profile_system` | Pantalla "Estado del Cazador" detallada | **No existe** (planificada `/hunter-status`) |
| `system_mana_disruption_error` | Pantalla de error/sin red | **No existe** |
| `hunter_class_selection` | Selección de clase en wizard | Existe como untracked sin cablear |
| `session_summary_screen` | Summary con composición de recompensas | Existe pero visualmente bajo |

## 3. Evaluación global

- **12 rutas implementadas**, de las cuales ~10 tienen una plantilla de referencia; la paridad visual es **mayormente media/baja**.
- **10 plantillas** (~48%) no tienen pantalla o pantalla parcial en la app.
- Las brechas más críticas (core loop): mapa de mazmorras (`learning_dungeon_map_gateways`), topic navigator (`conversational_tactics_navigator`), y la pantalla de estado (`hunter_status_profile_system`) que ya estaba planificada.

## 4. Bugs de UI/UX conocidos

- `VoiceRoomScreen` crashea con `roomId` no-UUID (rooms default tipo `guild_table_1`).
- Tabs del dashboard: "ESTADO" y "CONFIG" no tienen contenido equivalente al HUD oficial.
- `OnboardingScreen` no conecta el wizard de creación de personaje / oracle test.

## 5. Verificación requerida antes de Fase 2

- [ ] Refrescar `graphify update .` para reflejar features untracked.
- [ ] Confirmar qué archivos Dart del estado "post-regresión" siguen siendo válidos (economy, missions, l10n, onboarding).
- [ ] Reconciliar `docs/UX_UI_AUDIT.md` previo con esta auditoría.
