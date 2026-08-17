# AGENTS.md — TutorSaas / Dungeon of English

## Project Overview
Flutter mobile SaaS for conversational English learning wrapped in an Isekai/Webtoon "System HUD" RPG. Voice pipeline: record (AAC/m4a) → Groq Whisper STT (whisper-large-v3-turbo, language forced `en`) → DeepSeek LLM (SSE streaming, `deepseek-chat`) → flutter_tts (on-device, rate 0.48). Target pipeline latency <1.5s. Supabase BaaS (Postgres, Auth, RLS, Realtime).

## ⚠️ CRITICAL: Git Has a Single Commit
The repo has **one commit only** (`8c1ef25 Firtcomit`). **All feature work is uncommitted.**
- `git checkout -- <file>` or `git checkout -- '*.dart'` **reverts files to the initial commit**, destroying hours of work. This happened once already and caused a major regression.
- **Never use `git checkout`/`git restore` to "fix" or "revert" a Dart file.** Fix problems by editing, not restoring.
- `git status`/`git diff` do NOT reflect recent feature work on already-tracked files — many intended changes live only as uncommitted edits and new untracked files (`lib/features/economy/`, `lib/features/missions/`, `lib/l10n/`, etc.).

## Commands
```sh
flutter analyze                     # lint + typecheck (56 infos/warnings, 0 errors is the bar)
flutter test                        # unit tests in test/ (5 files)
flutter gen-l10n                    # regenerate lib/l10n/app_localizations* after editing any .arb
dart run build_runner build --delete-conflicting-outputs  # freezed / json_serializable codegen
flutter run -d <device>             # device run (e.g. RFCN80FYN6V)
```
- `flutter analyze` will show ~56 infos/warnings (deprecations, unused private widgets). 0 **errors** is the correctness bar; don't chase every info.
- After editing `lib/l10n/app_*.arb`, you **must** run `flutter gen-l10n` before the new keys resolve.

## Theme — Isekai / Webtoon / System HUD (Dark Only)
- **Current palette** (in `lib/core/theme/app_colors.dart`): `voidBg` #05070E, `manaCyan` #00E5FF, `royalGold` #FFC700, `runeViolet` #9D4EDD, `emeraldGreen` #00E676. Old palette (`#0B1326`, `#B76DFF`) is **deprecated** — do not reintroduce.
- No light mode. Border radius standard is **4px** (rounded corners >20px only for avatars/orbs).
- Floating containers use `GlassCard` (`lib/core/widgets/glass_card.dart`) — supports `borderColor`, `showRunicCorners`, `runicColor` for runic accents.
- Reusable RPG widgets in `lib/core/widgets/`: `SegmentedBar` (10-segment progress), `AnimatedCounter` (eased number), `FloatingReward` (floating "+XP"), `RpgAvatar`, `CyberManhwaBackground` (13 `CyberBgMode`s; don't add hardcoded hex backgrounds — use AppColors).

## Architecture
- **State:** flutter_riverpod — `StateNotifierProvider` for complex state, `FutureProvider.autoDispose` for async, `StateProvider` for simple. Invalidate providers after mutations. No BLoC/Redux/GetX/legacy Provider.
- **Routing:** go_router. New screens must be registered in `lib/app/router.dart`. Currently 12 routes; `/hunter-status`, `/oracle-test`, `/shop`, etc. are **planned but not yet wired**.
- **Dashboard** (`dashboard_screen.dart`) has 4 tabs: Dungeons (0), Guild (1 → pushes `/chat-rooms`), Status (2), Config (3).
- **Features (feature-first clean architecture):** `auth`, `chat_rooms` (voice rooms/guild hall), `conversation` (voice pipeline + Oracle NPC), `dashboard` (home/progress/profile/settings), `economy` (invocations, gems, streaks), `missions` (mission engine), `onboarding` (wizard, oracle test, placement), `subscription` (paywall/plans), `vocabulary` (SM-2 SRS).
- **Web admin:** `web_admin/` is a separate React/Vite app (Supabase JS client). Subscription prices/plans are editable there.

## Voice Pipeline (DO NOT ALTER)
1. record (AAC/m4a) → 2. Groq Whisper STT (`en` forced) → 3. DeepSeek SSE streaming → 4. flutter_tts (rate 0.48).
- Hold-to-Talk gesture via `record` package — **not** the native `speech_to_text` plugin (dependency exists but is unused for capture).
- Goal evaluation uses keyword matching (`isSatisfiedBy`); scenario-based conversations persist, free chats are ephemeral.

## i18n / Localization
- Flutter l10n (`l10n.yaml`, `pubspec.yaml: generate: true`). Templates: `lib/l10n/app_en.arb` (source), `app_es.arb`, `app_pt.arb`.
- Use generated `AppLocalizations.of(context)!.key`. The legacy `t()` helper in `lib/core/i18n/locale_provider.dart` is a **stub** (returns the key) — don't rely on it for real translations.
- `UserLanguageSettings` provider (`lib/core/i18n/language_settings.dart`) separates UI language / learning language / AI-explanation language.

## Database / Migrations
- Supabase migrations live in `supabase/migrations/`. Many feature migrations (oracle questions, mission engine, economy, chat moderation, pricing) exist as files but may **not be applied** to the live DB.
- RLS must be respected on all queries. Some DDL/writes may fail against the live project with "read-only transaction" — apply via the SQL Editor or a branch instead.

## Conventions
- Files `snake_case`; classes `PascalCase`; vars/functions `camelCase`; private `_camelCase`; providers end in `Provider`.
- `const` constructors wherever possible; avoid `setState` for business logic.
- All API calls wrapped in try-catch with `debugPrint`.
- Typography: `SpaceGrotesk` (headlines), `Inter` (body), `JetBrainsMono` (stats/labels) via google_fonts — do not introduce other families (e.g. `HankenGrotesk` was removed).

## ⚠️ Trabajo pendiente — limpieza de código muerto (no urgente, no rompe nada)
Se eliminaron pantallas (hunter-status, collections, fragments-exchange, battle-pass, guild-quest-board/detail, dungeon-map). Quedó **código muerto** por limpiar, verificado como sin consumidores (solo interfaz+impl):
- **8 métodos en `mission_repository`** (interfaz `domain/repositories/mission_repository.dart` + impl `data/repositories/mission_repository.dart`): `getSecretMissions`, `getActiveEmergencies`, `getRecentRewards`, `getGuildQuestPool`, `getCompletedGuildQuests`, `getGuildQuestById`, `getActiveGuildMissions`, `getActiveGlobalEvents`. ⚠️ Quitar SIEMPRE interfaz+impl a la vez (un `@override` huérfano = error `invalid_override`). Conservar `getActiveMissions` (uso interno), `getCompletedMissions`, `getWeeklyRaid`.
- **~90 claves l10n sin uso** en `lib/l10n/app_*.arb`: prefijos `battle_*`, `dungeon_*`, `fragments_*`, `collections_load_error`, `hunter_equip/skill_titles/cefr_xp/fluency/holographic/practice/points/str/luk/distribute/no_title/max_level`, y la mayoría `mission_*` del tablón/detalle. Listarlas comparando claves del ARB vs uso (`l10n.` / `AppLocalizations.of(context)?.` en lib fuera de `l10n/`). ⚠️ Editar ARB SOLO con la herramienta de edición (nunca scripts de consola: corrompen acentos/emojis). Después `flutter gen-l10n`.
- Ya limpiado: 10 providers huérfanos en `mission_providers.dart`, 2 métodos de battle pass en `economy_repository`, imports sin uso.

