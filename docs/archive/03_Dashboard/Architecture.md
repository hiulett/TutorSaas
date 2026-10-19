# Fase 3 — Architecture

> Arquitectura del módulo Dashboard.

## Módulos

```
lib/features/dashboard/
├── data/
│   ├── models/               # (hunter_catalog en data/models)
│   └── repositories/
├── domain/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── providers/dashboard_providers.dart   # userProfile, userProgress, dashboardRepository
    ├── screens/
    │   ├── dashboard_screen.dart            # 4 tabs
    │   ├── hunter_status_screen.dart        # /hunter-status
    │   ├── session_summary_screen.dart
    │   ├── profile_screen.dart
    │   ├── profile_edit_screen.dart
    │   └── settings_screen.dart
    └── widgets/                             # 9 widgets de dashboard
```

## Flujo de datos

```
DashboardScreen ──watch──► userProfileProvider / userProgressProvider ──► Supabase
    │
    ├─ tab ESTADO ──push──► /hunter-status ──load bio + progress──► parsear stats
    ├─ tab GUILD ──push──► /chat-rooms
    └─ tab CONFIG ──push──► /settings
HunterStatusScreen ──saveStats──► dashboardRepository.updateUserProfile(bio) ──invalidate──► providers
```

## Decisiones

- Feature-first; estado con Riverpod `FutureProvider.autoDispose` + `StateNotifierProvider`.
- Stats persistidos en `users.bio` con formato prefijo `[Stats|...]` (sin tabla dedicada).
- Reutiliza core widgets (`GlassCard`, `RpgAvatar`, `SegmentedBar`, `AnimatedCounter`).

## Gaps

1. GUILD/ESTADO/CONFIG son navegación por push, no contenido inline → la "unificación
   Dashboard+Guild" del plan requiere refactor del tab GUILD.
2. `orbitron` fuera de estándar tipográfico.
