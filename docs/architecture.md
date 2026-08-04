# Arquitectura de TutorSaas

## Stack Tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| **Mobile Framework** | Flutter + Dart | SDK 3.29.0 / Dart 3.11.5 |
| **Estado** | flutter_riverpod + hooks_riverpod | ^2.5.1 |
| **Navegación** | go_router | ^14.0.0 |
| **Backend** | Supabase (Postgres + Auth + RLS + Realtime) | ^2.6.0 |
| **STT** | Groq Cloud API (whisper-large-v3-turbo) | — |
| **LLM** | DeepSeek Chat Completions (SSE streaming) | deepseek-chat |
| **TTS** | flutter_tts (on-device, rate 0.48) | ^4.0.0 |
| **Grabación** | record package (AAC/m4a, Hold-to-Talk) | ^4.4.4 |
| **Modelos** | freezed + json_serializable | ^2.5.2 |
| **HTTP** | dio | ^5.4.0 |
| **Charts** | fl_chart | ^0.68.0 |
| **Animaciones** | flutter_animate + lottie | ^4.5.0 / ^3.1.2 |

## Feature-First Clean Architecture

```
lib/
  main.dart                          # Entry point, Supabase init, benchmark
  app/
    app.dart                         # MaterialApp.router
    router.dart                      # GoRouter (12 rutas)
  core/
    constants/                       # ApiConstants (URLs, keys via dart-define)
    services/                        # AudioSfxService
    theme/                           # AppColors, AppTheme
    utils/                           # ErrorTracker, LatencyBenchmark, TextDiffUtils
    widgets/                         # GlassCard, CyberManhwaBackground, SystemWindow, etc.
  features/
    auth/                            # Login/register, Google OAuth
      data/
      domain/
      presentation/
    chat_rooms/                      # Group voice rooms (WebSocket)
      data/
      domain/
      presentation/
    conversation/                    # Core voice pipeline + chat
      data/
      domain/
      presentation/
    dashboard/                       # Home, progress, profile, settings, summary
      data/
      domain/
      presentation/
    onboarding/                      # 8-step wizard, placement test
      data/
      domain/
      presentation/
    subscription/                    # Paywall, plans
      data/
      domain/
      presentation/
    vocabulary/                      # SRS flashcards (SM-2)
      presentation/
  web_admin/                         # React/Vite admin panel (separate)
```

## Capas por Feature

Cada feature se organiza en 3 capas:

1. **data/** — Repositorios concretos, fuentes de datos (Supabase, APIs externas), DTOs
2. **domain/** — Modelos de dominio (Freezed), interfaces de repositorio, casos de uso
3. **presentation/** — Providers Riverpod, screens, widgets específicos

## Estado con Riverpod

| Tipo de Provider | Uso | Ejemplo |
|-----------------|-----|---------|
| `StateNotifierProvider` | Estado complejo con lógica de negocio | ConversationNotifier, UserSettingsNotifier |
| `FutureProvider.autoDispose` | Data fetching asíncrono | Perfil de usuario, lecciones recomendadas |
| `StateProvider` | Estado simple (booleanos, strings) | Toggle de modo, selección de pestaña |

## Navegación con GoRouter

12 rutas declarativas en `lib/app/router.dart`:

| Ruta | Screen | Parámetros |
|------|--------|-----------|
| `/` | WelcomeScreen | — |
| `/onboarding` | OnboardingScreen | — |
| `/home` | DashboardScreen | — |
| `/conversation` | ConversationScreen | `scenarioId`, `scenarioTitle` |
| `/summary` | SessionSummaryScreen | — |
| `/level-exam` | LevelExamScreen | `level` |
| `/paywall` | PaywallScreen | — |
| `/profile` | ProfileScreen | — |
| `/profile-edit` | ProfileEditScreen | — |
| `/settings` | SettingsScreen | — |
| `/chat-rooms` | ChatRoomsScreen | — |
| `/voice-room` | VoiceRoomScreen | `roomId` |

## Pipeline de Voz

```
Usuario habla → record AAC/m4a (Hold-to-Talk) → Groq Whisper STT (language:'en')
  → DeepSeek LLM (SSE streaming) → flutter_tts (rate:0.48) → Usuario escucha
  ────────────────────────────────────────────────────────────────────
  Latencia total: ~850ms–1.1s
```

Pipeline detallado:

| Paso | Tecnología | Latencia Estimada |
|------|-----------|-------------------|
| 1. Captura de audio | `record` package (AAC/m4a, 16kHz) | ~100ms |
| 2. STT | Groq Whisper-large-v3-turbo | ~200ms |
| 3. LLM | DeepSeek Chat (SSE streaming) | ~250ms TTFT |
| 4. TTS | flutter_tts on-device (rate:0.48) | ~300ms |

## Backend Supabase

- **Base de Datos:** PostgreSQL gestionado con RLS (Row Level Security)
- **Autenticación:** Email/Password + Google OAuth
- **Realtime:** WebSockets para salas de voz grupales y actualizaciones en vivo
- **Storage:** Buckets para assets de avatares y contenido de lecciones
- **Triggers:** `handle_new_user()` sincroniza `auth.users → public.users` + `user_settings` al registro

## Diagrama de Flujo de Datos

```
Cliente Flutter
  → State (Riverpod)
    → Domain (Use Cases & Repositories)
      → Data Sources:
        → Supabase (Postgres, Auth, RLS)
        → Groq Cloud (STT Whisper)
        → DeepSeek (LLM Streaming)
        → flutter_tts (TTS local)
```

## Web Admin Panel

Panel separado en React/Vite en `web_admin/` con 6 páginas:
- Overview, Lessons, CEFR Levels, Users, Subscription Plans, AI Settings

---

## Estado actual (Fases 2-11, 2026-07-30)

### Features implementadas
| Feature | Ruta/lib | Estado |
|---|---|---|
| Onboarding + Oracle conversacional | eatures/onboarding/ | ? Fase 2 |
| Dashboard + HUD + Mapa mazmorras | eatures/dashboard/ | ? Fase 3 |
| Conversaci�n (Or�culo, metas, t�cticas) | eatures/conversation/ | ? Fase 4 |
| Motor de misiones + quest boards | eatures/missions/ | ? Fases 5/7 |
| Econom�a (gems, oro, fragmentos, items) | eatures/economy/ | ? Fase 6/9 |
| Guild (sal�n, mesas, NPC, prestigio) | eatures/chat_rooms/ | ? Fase 7 |
| l10n + i18n | core/i18n/, l10n/ | ? Fase 2 |

### Nuevos m�dulos core
- core/theme/app_motion.dart � tokens de animaci�n (Fase 10).
- core/widgets/runic_button.dart � bot�n con micro-interacci�n (Fase 10).
- core/widgets/{system_window,segmented_bar,animated_counter,floating_reward}.dart.

### Decisiones de arquitectura (Fases 7-10)
- Mesas del gremio le�das de DB (sin hardcode, anti N+1) � G-A/G-B.
- Modelo LLM unificado deepseek-v4-flash (IA-02); ventana m�vil en evaluaci�n de metas (IA-03).
- Items con mission_modifier modifican misiones (eward_multiplier) � MM-01..03.
- Animaciones tokenizadas v�a AppMotion (AN-A..G).
