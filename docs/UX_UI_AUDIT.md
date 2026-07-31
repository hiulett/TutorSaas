# UX/UI Audit — "Dungeon of English" (TutorSaaS)

## Audit Date: 2026-07-27
## Auditors: Lead Product Designer, Senior UX/UI Designer (Mobile), Game UI Designer (RPG/JRPG/Isekai), Design System Architect, UX Researcher, Gamification Expert

---

# STEP 1: GOAL DESIGN ("Diseño Objetivo")

## 1.1 Product Vision
**"Dungeon of English"** — An English learning platform wrapped in an Isekai RPG experience. The user is a **Hunter** who descends into dungeon gates where English is the key to survival. The app must feel like a AAA mobile game, NOT an educational app.

**Inspirations:** Solo Leveling, Sword Art Online, DanMachi, Final Fantasy, Persona 5, Genshin Impact, Honkai Star Rail.

## 1.2 Visual Identity
- **Art Style:** Dark fantasy + sci-fi cyberpunk + manhwa webtoon aesthetic. High contrast, neon accents on void-black backgrounds. Cinematic, dramatic, intense.
- **Personality:** Epic, immersive, dark, mysterious, empowering. The UI is a "Hunter's HUD" — a tactical interface for a supernatural warrior.
- **Emotional Feel:** Excitement, urgency, curiosity, power fantasy. Every interaction should feel like a game mechanic activation.
- **Target Audience:** Young adults (18-35), gamers, anime/webtoon fans, language learners seeking a non-traditional approach.

## 1.3 Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| **Void Black** | `#05070E` | Main background |
| **Abyss Surface** | `#11131B` | Cards, containers |
| **Mana Cyan** | `#00E5FF` | Primary actions, active states, magic |
| **Rune Violet** | `#9D4EDD` | Magic, mystery, AI, special actions |
| **Royal Gold** | `#FFC700` | Legendary items, achievements, premium |
| **Crimson Red** | `#FF1744` | Danger, errors, boss fights, HP |
| **Emerald Green** | `#00E676` | Success, completion, healing |
| **On-Surface** | `#E1E2ED` | Primary text |
| **On-Surface Variant** | `#BAC9CC` | Secondary text |

**Color Semantics:** Red=danger/HP, Green=success/healing, Purple=magic/mystery, Cyan=mana/energy, Gold=legendary, Black=void/abyss.

## 1.4 Typography
- **Display/Headlines:** Space Grotesk (bold, tight tracking) — for titles, level numbers, dramatic text
- **Body:** Inter (clean, readable) — for descriptions, dialogue
- **UI/Labels/Code:** JetBrains Mono (monospace, technical feel) — for stats, system messages, buttons
- **Forbidden:** Script fonts, decorative fonts, Comic Sans, serif fonts for UI

## 1.5 Iconography
- **Style:** Line icons with rounded caps, monospace-outline style. Cyber/tech feel. Minimalist but sharp.
- **Sources:** Phosphor icons, Tabler icons, custom game-themed icons.
- **Forbidden:** Emojis as icons (🎙️, 📚, 🎯, 💼, etc.), FontAwesome, generic Material icons without customization, colored emoji in UI chrome.

## 1.6 Buttons
- Shape: Square/rectangular with 4px border radius (sharp, tactical). No pill shapes.
- Style: Outlined with neon border glow. Filled variant for primary CTA.
- States: Default (cyan border), Hover (brighter glow), Active/Pressed (inner glow), Disabled (dimmed, no glow).
- Text: JetBrains Mono, uppercase, letter-spaced.

## 1.7 Cards
- Glassmorphism with BackdropFilter blur. Dark translucent background (`#11131B` at ~94% opacity).
- Neon border glow (1px solid with colored shadow).
- Sharp corners (4px radius).
- No rounded corners >12px. No fully rounded cards.

## 1.8 Bars (XP, Mana, HP, Progress)
- **Segmented design:** Divided into 8-10 segments like a retro game HUD.
- Neon glow fill with subtle animation.
- Label in JetBrains Mono.
- Thin height (4-8px). Not thick or rounded.

## 1.9 Navigation
- **Bottom Navigation:** Floating HUD bar with neon top border. 4 tabs max. Icon + monospace label. Sharp corners.
- **Top Bar:** Minimalist. Back button (icon only), title (Space Grotesk bold), optional action.
- **Transitions:** Slide (right-to-left for forward, left-to-right for back). Fade for modals.

## 1.10 Images & Art
- **Mandate:** Anime/webtoon-style character art, illustrated backgrounds, fantasy environments.
- **Forbidden:** AI-generated generic profile faces (DiceBear avatars), stock photography, emoji, clip art, childish illustrations, Google Material icons used decoratively.

## 1.11 FORBIDDEN ELEMENTS (Kills the RPG Experience)
1. ✅ Stock/AI generic profile avatars (DiceBear, Gravatar, etc.)
2. ❌ Emojis as UI icons (🎙️, 📚, 🎯, 💼, ✈️, 🍳, etc.)
3. ❌ Unskinned Material components (ChoiceChip, FilterChip, OutlinedButton without theming)
4. ❌ Flat white/gray backgrounds
5. ❌ Educational terminology ("curso", "clase", "examen", "profesor", "lección" — use "dungeon", "gate", "boss", "monster", "quest", "mission", "scroll" instead)
6. ❌ Round/pill-shaped buttons
7. ❌ iOS-style bottom sheets with large top radius (24px+)
8. ❌ Flat cards without glassmorphism
9. ❌ Default Cupertino/Android switches without theming
10. ❌ Traditional form layouts (labeled fields stacked vertically)
11. ❌ Generic progress bars (LinearProgressIndicator default style)
12. ❌ Inconsistent border radius usage
13. ❌ Text in Spanish (app interface) for UI labels when they break immersion
14. ❌ Traditional dropdown selectors (DropdownButton) without RPG theming

---

# STEP 2 & 3: COMPLETE COMPONENT AUDIT

## 2.1 CORE THEME

### AppColors (`lib/core/theme/app_colors.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Color palette definition | ✅ Sí | Colors are well-defined with RPG naming (manaCyan, runeViolet, royalGold, etc.) |
| Dark background | ✅ Sí | voidBg #05070E, surface #11131B |
| Semantic system | ✅ Sí | Colors map to game concepts |
| **Missing colors** | ⚠ Parcial | No dedicated Boss Red (different from error), no HP bar color, no XP bar color, no rarity colors (common/uncommon/rare/epic/legendary) |

### AppTheme (`lib/core/theme/app_theme.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Dark theme only | ✅ Sí | ThemeMode.dark |
| Text theme | ✅ Sí | Space Grotesk + Inter + JetBrains Mono hierarchy |
| Font choices | ✅ Sí | Excellent selection |
| **Missing button theme** | ❌ No | No `elevatedButtonTheme`, `outlinedButtonTheme`, `textButtonTheme` defined. Buttons use inline styles everywhere. |
| **Missing input theme** | ❌ No | No `inputDecorationTheme`. TextFields styled manually each time. |
| **Missing switch theme** | ❌ No | Switches use inline styles. |
| **Missing card theme** | ❌ No | Cards manually styled everywhere. |
| **Missing bottom nav theme** | ❌ No | Bottom nav manually styled. |
| **Missing dialog theme** | ❌ No | Dialogs manually styled. |
| **Missing snackbar theme** | ❌ No | SnackBars manually styled. |
| **Missing chip theme** | ❌ No | Chips manually styled. |

---

## 2.2 CORE WIDGETS

### GlassCard (`lib/core/widgets/glass_card.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Glassmorphism effect | ✅ Sí | BackdropFilter blur |
| Neon border glow | ✅ Sí | BoxShadow with border color |
| Sharp corners (4px) | ✅ Sí | borderRadius: 4 |
| Dark translucent surface | ✅ Sí | |
| **Default border radius** | ⚠ Parcial | `borderRadius = 4.0` is good, but `borderRadius = 4.0` conflicts with Material default 12px. Good default. |
| **Shadow always present** | ⚠ Parcial | Always adds glow shadow even when not needed |

### SystemWindow (`lib/core/widgets/system_window.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Glassmorphism | ✅ Sí | |
| Runic accents | ✅ Sí | Animated corner decorations |
| Tactical UI feel | ✅ Sí | Great component |
| **Code quality** | ⚠ Parcial | RunicAccent is just a small square, not an actual rune symbol |

### SystemButton (`lib/core/widgets/system_window.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Tactical style | ✅ Sí | Sharp, outlined, monospace label |
| Color variants | ✅ Sí | Mana cyan, urgent violet, gold |
| **Uses OutlinedButton** | ⚠ Parcial | Still uses Material OutlinedButton without proper theme |
| **Icon size 16** | 🟢 Low | Good |

### ManaBar (`lib/core/widgets/system_window.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Segmented design | ✅ Sí | 10 segments |
| Neon glow border | ✅ Sí | |
| **Height 8px** | 🟢 Good | Proportional |

### ManaMeterWidget (`lib/core/widgets/mana_meter_widget.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Shows mana stat | ✅ Sí | |
| **🔴 CRITICAL: Uses emoji as icon** | ❌ No | `const Text('🔮', style: TextStyle(fontSize: 14))` — uses emoji instead of a custom icon |
| **🔴 CRITICAL: Uses emoji for mana symbol** | ❌ No | Crystal ball emoji as mana icon |
| **Rounded corners (16)** | ❌ No | borderRadius: 16 — pill shape, contradicts design system |
| **Uses Orbitron font** | ❌ No | Should be JetBrains Mono for UI labels |
| **Standard LinearProgressIndicator** | ⚠ Parcial | Not segmented, Material default style |

### SystemChatBubble (`lib/core/widgets/system_chat_bubble.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Dark themed | ✅ Sí | |
| Color-coded by role | ✅ Sí | User=cyan, AI=violet |
| **Font family hardcoded** | ⚠ Parcial | Uses string 'JetBrains Mono' instead of GoogleFonts.jetBrainsMono |

### CyberManhwaBackground (`lib/core/widgets/cyber_manhwa_background.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Animated particles | ✅ Sí | |
| Magic circles | ✅ Sí | Custom painter with rotation animation |
| Scanline CRT overlay | ✅ Sí | Nice retro touch |
| Level-based color themes | ✅ Sí | |
| Glow orbs | ✅ Sí | |
| **Excellent component** | ✅ Sí | This is the strongest visual asset in the app |

### DraggableMonsterWidget (`lib/core/widgets/draggable_monster_widget.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Full-screen expanded view | ✅ Sí | |
| Rotating magic pentagram | ✅ Sí | |
| Floating/bounce animation | ✅ Sí | |
| Speaking pulse animation | ✅ Sí | |
| **🔴 CRITICAL: DiceBear avatar** | ❌ No | Uses generic DiceBear bottts for monster avatars instead of illustrated monster art |
| **🔴 CRITICAL: Emoji in UI** | ❌ No | Uses `'🔥 JEFE GUARDIÁN'` and `'👾 MONSTRUO INSTRUCTOR'` with emojis |
| **🔴 CRITICAL: Emoji labels** | ❌ No | `'🎙️ Enseñando...'`, `'👾 En Vivo (Toca)'` |
| **🔴 CRITICAL: drag_indicator Material icon** | ❌ No | `Icons.drag_indicator_rounded` is generic Material icon |
| **Orbitron font** | ⚠ Parcial | Mixed font usage |
| **RedAccent hardcoded** | ⚠ Parcial | Uses `Colors.redAccent` instead of design system color |

---

## 2.3 AUTH SCREENS

### WelcomeScreen (`lib/features/onboarding/presentation/screens/welcome_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Void background | ✅ Sí | |
| Animated particles | ✅ Sí | |
| Rune circles | ✅ Sí | |
| Glow orbs | ✅ Sí | |
| System window style | ✅ Sí | Border glow, runic accents |
| Monospace UI labels | ✅ Sí | |
| **🔴 CRITICAL: `Icons.translate` as brand logo** | ❌ No | Uses `Icons.translate` (generic Material icon) as the app logo/brand mark |
| **🔴 CRITICAL: Brand name "TUTORSAAS"** | ❌ No | Brand name should be "Dungeon of English" — "TutorSaaS" breaks immersion with SaaS terminology |
| **🔴 CRITICAL: Google Material Icon for brand** | ❌ No | `Icons.g_mobiledata_rounded` for Google login is unthemed |
| **🟠 HIGH: Generic OutlinedButton** | ❌ No | Register button uses plain OutlinedButton with no glow effect |
| **🟠 HIGH: Standard SnackBar** | ❌ No | SnackBar shown on error is vanilla Material |
| **Debug toggle exposed** | 🟡 Medium | `_DebugToggle` widget visible in production |

### Brand Header (`_BrandHeader` in welcome_screen.dart)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| **🔴 CRITICAL: `Icons.translate`** | ❌ No | Generic icon as brand logo |
| **🔴 CRITICAL: Text "TUTORSAAS"** | ❌ No | SaaS-style name, not "Dungeon of English" |
| **Version badge** | 🟢 OK | Nice detail |

---

## 2.4 ONBOARDING SCREENS

### OnboardingScreen (`lib/features/onboarding/presentation/screens/onboarding_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| RPG-themed step titles | ✅ Sí | "HUNTER REGISTRY", "AWAKENING LANGUAGE", "GATE SELECTION", "MISSION COMMITMENT", "SKILL TREE", "BOSS IDENTIFICATION" |
| **Great RPG naming** | ✅ Sí | Excellent thematic translation |
| **🟠 HIGH: Uses ElevatedButton** | ❌ No | `ElevatedButton` with `AppColors.manaCyan` background — no glow, no border animation |
| **🟠 HIGH: Uses DropdownButton** | ❌ No | Language/country selectors use Material DropdownButton without RPG theming |
| **🟠 HIGH: Uses Switch widget** | ❌ No | `Switch` widget unthemed |
| **🟠 HIGH: CircularProgressIndicator** | ❌ No | Default spinner on loading |
| **🟠 HIGH: Emoji for icons** | ❌ No | Uses `Icons.public`, `Icons.timer`, `Icons.star_rounded`, `Icons.auto_fix_high`, etc. — generic Material icons |
| **🟡 Medium: Page indicator dots** | ⚠ Parcial | Uses bars, not circles — good, but no animation |
| **🟢 OK: Selection cards** | ✅ Sí | Animated containers with border glow — decent |

### PlacementTestScreen (`lib/features/onboarding/presentation/screens/placement_test_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Dark background | ✅ Sí | |
| **🔴 CRITICAL: Emoji icons** | ❌ No | Uses `'💼'`, `'🎓'`, `'✈️'`, `'🎉'` for options |
| **🔴 CRITICAL: Spanish educational text** | ❌ No | Uses "¿Cuál es tu objetivo?" — breaks English-learning immersion, also uses educational terminology |
| **🟠 HIGH: ElevatedButton** | ❌ No | Default Material button styling |
| **🟠 HIGH: No CyberManhwaBackground** | ❌ No | Lacks the animated background from onboarding |
| **🟠 HIGH: Flat container decorations** | ❌ No | No glassmorphism on quiz options |
| **🟡 Medium: Back button** | ⚠ Parcial | Uses `Icons.arrow_back_ios_new_rounded` — acceptable but should be themed |

### HunterLicenseScreen (`lib/features/onboarding/presentation/screens/hunter_license_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| Scan line animation | ✅ Sí | |
| RPG-styled license card | ✅ Sí | Nice game-style identity card |
| Stat bars (segmented) | ✅ Sí | 8-segment stat bars |
| Monospace labels | ✅ Sí | |
| **🔴 CRITICAL: DiceBear avatar** | ❌ No | Uses DiceBear generic avatars |
| **🔴 CRITICAL: `Icons.person` fallback** | ❌ No | Generic Material icon |
| **🟠 HIGH: `Icons.login` for action button** | ❌ No | Generic icon for "ENTER HUNTER HEADQUARTERS" |

### SplashVideoScreen (`lib/features/onboarding/presentation/screens/splash_video_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Full-screen video | ✅ Sí | |
| **🟠 HIGH: Loading spinner** | ❌ No | Default `CircularProgressIndicator` |
| **🟡 Medium: Skip button** | ⚠ Parcial | Basic container, acceptable |

---

## 2.5 DASHBOARD

### DashboardScreen (`lib/features/dashboard/presentation/screens/dashboard_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| RPG-themed tabs | ✅ Sí | "DUNGEONS", "GUILD", "STATUS", "CONFIG" |
| Mana/XP bar in header | ✅ Sí | Segmented |
| CEFR badge gold bordered | ✅ Sí | |
| Urgent Quest card | ✅ Sí | Gold-bordered with runic accents |
| Level pill labels | ✅ Sí | Monospace |
| **🔴 CRITICAL: DiceBear avatar** | ❌ No | Uses DiceBear generic bottts avatars |
| **🔴 CRITICAL: Emoji in achievements** | ❌ No | Uses `'🥇'`, `'⚡'`, `'🗣️'`, `'🎯'` in achievement titles |
| **🔴 CRITICAL: Emoji in default data** | ❌ No | `'🇺🇸'` language emoji |
| **🔴 CRITICAL: `Icons.school_rounded` fallback** | ❌ No | Generic Material icon |
| **🟠 HIGH: Standard LinearProgressIndicator** | ❌ No | Not segmented, default style |
| **🟠 HIGH: Default SnackBar** | ❌ No | |
| **🟠 HIGH: Grid stat cards use GlassCard with inline styles** | ⚠ Parcial | Overuse of GlassCard where simpler components would work |
| **🟡 Medium: Achievement progress bars** | ⚠ Parcial | Standard LinearProgressIndicator |

### SessionSummaryScreen (`lib/features/dashboard/presentation/screens/session_summary_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Dark background with glow orbs | ✅ Sí | |
| Neon progress arc painter | ✅ Sí | Custom circular gauge |
| GlassCard usage | ✅ Sí | |
| **🔴 CRITICAL: OutlinedButton.icon with Material styling** | ❌ No | "VER VOCABULARIO" button |
| **🔴 CRITICAL: ElevatedButton.icon** | ❌ No | "LISTO" button — both buttons have default Material shape |
| **🟠 HIGH: Back button** | ⚠ Parcial | `Icons.arrow_back_rounded` with `ClipOval` — wrong shape for the design system |
| **🟠 HIGH: Uses `t('key')` for some text** | ⚠ Parcial | Inconsistent i18n patterns |
| **🟡 Medium: "SESIÓN COMPLETADA!" badge** | ⚠ Parcial | Acceptable styling |

### ProfileScreen (`lib/features/dashboard/presentation/screens/profile_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard usage | ✅ Sí | |
| **🔴 CRITICAL: Emoji in header** | ❌ No | `const Text('📊', style: TextStyle(fontSize: 22))` — emoji as icon |
| **🔴 CRITICAL: DiceBear avatar** | ❌ No | |
| **🔴 CRITICAL: ElevatedButton "VENTANA DE ESTADO"** | ❌ No | Unskinned Material ElevatedButton |
| **🔴 CRITICAL: Back button ClipOval** | ❌ No | Round back button contradicts design system |
| **🟠 HIGH: Emoji in "Aprendiendo"** | ❌ No | `'🇺🇸'` flag emoji |
| **🟠 HIGH: Navigation bar inconsistency** | ❌ No | Bottom nav completely different from dashboard tabs |
| **🟠 HIGH: GlassCard inside nav bar** | ❌ No | GlassCard with `opacity: 0.08` — different approach from dashboard |
| **🟠 HIGH: AlertDialog for vocabulary** | ❌ No | Uses vanilla AlertDialog with RoundedRectangleBorder |

### Profile Edit Screen (`lib/features/dashboard/presentation/screens/profile_edit_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Dark themed | ✅ Sí | |
| Avatar with edit overlay | ✅ Sí | |
| **🔴 CRITICAL: FORM layout** | ❌ No | This is the most "educational app" screen in the entire app. Stacked form labels, TextFormField, standard form pattern. Breaks ALL RPG immersion. |
| **🔴 CRITICAL: TextFormField** | ❌ No | Generic Material text input |
| **🔴 CRITICAL: OutlineInputBorder** | ❌ No | Default Material input borders |
| **🔴 CRITICAL: DropdownButton** | ❌ No | Generic native language selector |
| **🔴 CRITICAL: ElevatedButton "Guardar Cambios"** | ❌ No | Standard button |
| **🔴 CRITICAL: SnackBar with emoji** | ❌ No | `'📸'`, `'🎉'` emojis in SnackBars |
| **🔴 CRITICAL: CircularProgressIndicator** | ❌ No | |
| **🔴 CRITICAL: Educational labels** | ❌ No | "Nombre de Usuario / Nombre Completo", "Sobre mí", "Idioma Nativo" — feels like a school app |
| **🟠 HIGH: ImagePicker bottom sheet** | ❌ No | Traditional iOS-style bottom sheet with 24px radius |
| **🟠 HIGH: Default Divider** | ❌ No | |
| **🟡 Medium: Glow orbs present** | ✅ Sí | Attempt at thematic consistency |

### SettingsScreen (`lib/features/dashboard/presentation/screens/settings_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| GlassCard tiles | ✅ Sí | |
| **🔴 CRITICAL: ChoiceChip for CEFR** | ❌ No | Unskinned Material ChoiceChip |
| **🔴 CRITICAL: Switch widgets** | ❌ No | Default Material switches |
| **🔴 CRITICAL: DropdownButtonFormField** | ❌ No | In create room dialog |
| **🔴 CRITICAL: ElevatedButton "Guardar Ajustes"** | ❌ No | |
| **🔴 CRITICAL: Section titles in Spanish** | ❌ No | "Idioma y Nivel de Aprendizaje", "Ajustes", etc. |
| **🟠 HIGH: showTimePicker** | ❌ No | Default time picker |
| **🟠 HIGH: showModalBottomSheet radius 24** | ❌ No | Rounded top corners contradict design system |
| **🟠 HIGH: AlertDialog** | ❌ No | For reset confirmation |
| **🟠 HIGH: Educational terminology** | ❌ No | "Tutorial", "Ajustes", "Meta Diaria" |
| **🟡 Medium: Divider widget** | ❌ No | Default Divider |

---

## 2.6 DASHBOARD WIDGETS

### NextRecommendedLessonHero (`lib/features/dashboard/presentation/widgets/next_recommended_lesson_hero.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard | ✅ Sí | |
| RPG labels | ✅ Sí | "SIGUIENTE PASO • ETAPA B1" |
| **🟠 HIGH: ElevatedButton "Iniciar Lección de Voz Ahora"** | ❌ No | Should be SystemButton |
| **🟠 HIGH: "Iniciar Lección" text** | ❌ No | "Lección" is educational terminology — should be "Misión" or "Gate" |
| **🟡 Medium: Icon Material icons** | ⚠ Parcial | Acceptable but not custom |

### AI Pick Hero Card (`lib/features/dashboard/presentation/widgets/ai_pick_hero_card.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard | ✅ Sí | |
| RPG-themed badge | ✅ Sí | "AI PICK DEL DÍA" with violet accent |
| Match percentage | ✅ Sí | |
| **🟠 HIGH: ElevatedButton "Ver Vista Previa"** | ❌ No | |
| **🟡 Medium: Material icons** | ⚠ Parcial | |

### RecommendedLessonsHub (`lib/features/dashboard/presentation/widgets/recommended_lessons_hub.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard lesson cards | ✅ Sí | |
| RPG labels | ✅ Sí | "NIVEL B1", "⚡ 98% Match" |
| **🔴 CRITICAL: ChoiceChip for categories** | ❌ No | Unskinned Material ChoiceChip |
| **🔴 CRITICAL: FilterChip for CEFR** | ❌ No | Unskinned Material FilterChip |
| **🔴 CRITICAL: TextField search** | ❌ No | Default search field with OutlineInputBorder |
| **🔴 CRITICAL: Emoji in category icons** | ❌ No | `'🌟'`, `'💻'`, `'💼'`, `'✈️'`, `'☕'`, `'🍳'` — all emojis |
| **🟠 HIGH: ElevatedButton "Salas de Voz"** | ❌ No | |
| **🟠 HIGH: ElevatedButton "Hablar" / "Repasar"** | ❌ No | |
| **🟠 HIGH: OutlinedButton "Ver Objetivos"** | ❌ No | |

### LearningPathRoadmap (`lib/features/dashboard/presentation/widgets/learning_path_roadmap.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Vertical timeline style | ✅ Sí | |
| GlassCard nodes | ✅ Sí | |
| RPG terminology | ✅ Sí | "Etapa A1 • Módulo 1" |
| Level selector chips | ✅ Sí | Animated containers |
| **🟠 HIGH: Standard LinearProgressIndicator** | ❌ No | For stage progress |
| **🟠 HIGH: Material Icon play/lock/check** | ❌ No | `Icons.check_rounded`, `Icons.play_arrow_rounded`, `Icons.lock_rounded` |
| **🟡 Medium: Star rating system** | ⚠ Parcial | Uses Material star icons |

### DailyQuestsWidget (`lib/features/dashboard/presentation/widgets/daily_quests_widget.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard | ✅ Sí | |
| **🔴 CRITICAL: Emoji as quest icons** | ❌ No | `'🎙️'`, `'📚'`, `'🎯'` — all emojis |
| **🟠 HIGH: ElevatedButton for claim** | ❌ No | |
| **🟠 HIGH: Standard LinearProgressIndicator** | ❌ No | |
| **🟠 HIGH: Material `Icons.task_alt_rounded`** | ❌ No | |

### LeagueLeaderboardWidget (`lib/features/dashboard/presentation/widgets/league_leaderboard_widget.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard | ✅ Sí | |
| **🔴 CRITICAL: DiceBear avatars** | ❌ No | `api.dicebear.com` for leaderboard |
| **🟠 HIGH: Material star icons** | ❌ No | `Icons.star_rounded`, `Icons.emoji_events_rounded` |
| **🟡 Medium: Divider** | ❌ No | Default Divider |

### CompletedLessonsHistoryList (`lib/features/dashboard/presentation/widgets/completed_lessons_history_list.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard | ✅ Sí | |
| **🟠 HIGH: Material icons** | ❌ No | `Icons.task_alt_rounded`, `Icons.star_rounded` |
| **🟡 Medium: TextButton "VER MÁS"** | ⚠ Parcial | Default TextButton |

### StatusWindowModal (`lib/features/dashboard/presentation/widgets/status_window_modal.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| RPG-themed attribute list | ✅ Sí | "Precisión Gramatical", "Latencia de Respuesta", etc. |
| Title inventory system | ✅ Sí | "INVENTARIO DE TÍTULOS LEGENDARIOS" |
| Segmented stat bars | ✅ Sí | |
| **🟠 HIGH: ElevatedButton "Equipar"** | ❌ No | |
| **🟠 HIGH: Standard LinearProgressIndicator** | ❌ No | For attributes |
| **🟠 HIGH: Modal uses `Navigator.pop`** | ⚠ Parcial | Should be animated |

---

## 2.7 CONVERSATION

### ConversationScreen (`lib/features/conversation/presentation/screens/conversation_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| Draggable monster overlay | ✅ Sí | |
| Waveform visualizer | ✅ Sí | |
| Progress bar | ✅ Sí | Color-coded |
| Live goals tracker | ✅ Sí | |
| Mana meter | ✅ Sí | |
| **🔴 CRITICAL: Tutor bubble uses rounded corners (20px)** | ❌ No | `borderRadius: Radius.circular(20)` — contradicts 4px design system |
| **🔴 CRITICAL: User bubble rounded** | ❌ No | `Radius.circular(20)` too |
| **🔴 CRITICAL: Emoji in topic bar** | ❌ No | `'💼'`, `'✈️'`, `'🍔'`, `'🎵'`, `'⚽'`, `'🧠'` — 20 emojis as topic icons |
| **🔴 CRITICAL: Emoji in mode toggles** | ❌ No | `'🙈'`, `'👁️'`, `'⌨️'`, `'🎙️'` for blind listening, keyboard mode |
| **🔴 CRITICAL: Floating mic button is WHITE circle** | ❌ No | White circular FAB — breaks all dark RPG aesthetics. Looks like a generic iOS call button. |
| **🔴 CRITICAL: DraggableSheet radius 28** | ❌ No | For mission modal — round corners |
| **🔴 CRITICAL: DraggableSheet color #0F172A** | ❌ No | Wrong color (not voidBg or surface) |
| **🟠 HIGH: IconButton back** | ⚠ Parcial | Generic arrow |
| **🟠 HIGH: LinearProgressIndicator** | ❌ No | Default style for progress |
| **🟠 HIGH: TextField in keyboard mode** | ❌ No | Default input |
| **🟡 Medium: Bottom control bar** | ⚠ Parcial | Interesting but unrefined |

### VoiceWaveformVisualizer (`lib/features/conversation/presentation/widgets/voice_waveform_visualizer.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Animated bars | ✅ Sí | |
| Color changes by speaker | ✅ Sí | |
| **Good component** | ✅ Sí | |

### LiveGoalsTrackerBar (`lib/features/conversation/presentation/widgets/live_goals_tracker_bar.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| Functional | ✅ Sí | |
| **🔴 CRITICAL: Constant color `#10B981` hardcoded** | ❌ No | Not using design system color |
| **🟠 HIGH: Round chips (10px radius)** | ❌ No | borderRadius: 10 |

---

## 2.8 CHAT ROOMS

### ChatRoomsScreen (`lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground (guild hall) | ✅ Sí | |
| RPG-themed labels | ✅ Sí | "El Gran Hall del Gremio", "Mesas de Discusión" |
| GlassCard for rooms | ✅ Sí | |
| **🔴 CRITICAL: ElevatedButton "Establecer Mesa"** | ❌ No | |
| **🔴 CRITICAL: ElevatedButton "Unirme"** | ❌ No | |
| **🔴 CRITICAL: ChoiceChip category selector** | ❌ No | Unskinned |
| **🔴 CRITICAL: Emoji "🏰" in header** | ❌ No | |
| **🔴 CRITICAL: DropdownButtonFormField** | ❌ No | In create room dialog |
| **🔴 CRITICAL: TextField in dialog** | ❌ No | Default input |
| **🟠 HIGH: AppBar** | ❌ No | Uses Material AppBar |
| **🟠 HIGH: Rounded Button "Unirme" (radius 10)** | ❌ No | |

### VoiceRoomScreen (`lib/features/chat_rooms/presentation/screens/voice_room_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| RPG-themed speaker grid | ✅ Sí | 6-slot stage with AI moderator |
| Audience area ("Gradas") | ✅ Sí | |
| Floating control bar | ✅ Sí | |
| **🔴 CRITICAL: Emoji in live indicator** | ❌ No | `'🔴'` |
| **🔴 CRITICAL: Emoji in speaking status** | ❌ No | `'🔊 Hablando...'`, `'🎙️ En vivo'` |
| **🔴 CRITICAL: Emoji in hand-raise button** | ❌ No | `'✋'` |
| **🔴 CRITICAL: CircleAvatar for speaker** | ❌ No | `CircleAvatar(radius: 24)` — no avatar images, just initials |
| **🔴 CRITICAL: ElevatedButton for hand-raise** | ❌ No | |
| **🔴 CRITICAL: IconButton for mic/call** | ❌ No | |
| **🔴 CRITICAL: GlassCard with opacity 0.08/0.03** | ⚠ Parcial | Inconsistent opacity usage |
| **🟠 HIGH: TextField in chat** | ❌ No | Default input |
| **🟠 HIGH: SnackBar for interactions** | ❌ No | |
| **🟠 HIGH: Round border radius on indicator** | ❌ No | `borderRadius: BorderRadius.circular(8)` |

---

## 2.9 SUBSCRIPTION

### PaywallScreen (`lib/features/subscription/presentation/screens/paywall_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground | ✅ Sí | |
| RPG-themed plan names | ✅ Sí | "Frasco de Maná Arcano", "Esfera del Cazador de Élite", "Pase del Monarca Absoluto" |
| Feature list | ✅ Sí | RPG-styled features |
| **🔴 CRITICAL: ElevatedButton "Suscribirse Ahora"** | ❌ No | |
| **🔴 CRITICAL: Emoji in plan titles** | ❌ No | `'🔮'`, `'⚡'`, `'👑'` |
| **🔴 CRITICAL: Emoji in features list** | ❌ No | `'🔮'`, `'📜'`, `'🍻'`, `'🎙️'`, `'🐉'` |
| **🟠 HIGH: IconButton close** | ⚠ Parcial | `Icons.close_rounded` |
| **🟠 HIGH: CircularProgressIndicator** | ❌ No | |
| **🟠 HIGH: TextButton "RESTAURAR"** | ⚠ Parcial | Acceptable but should be SystemButton |

---

## 2.10 VOCABULARY (SRS)

### SrsFlashcardModal (`lib/features/vocabulary/presentation/widgets/srs_flashcard_modal.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| GlassCard for cards | ✅ Sí | |
| **🔴 CRITICAL: Bottom sheet radius 28** | ❌ No | Round corners |
| **🔴 CRITICAL: Bottom sheet color #0F172A** | ❌ No | Wrong color |
| **🔴 CRITICAL: OutlinedButton for "Difícil"** | ❌ No | |
| **🔴 CRITICAL: ElevatedButton for "Fácil"** | ❌ No | |
| **🔴 CRITICAL: Emoji in buttons** | ❌ No | `'😅'`, `'⚖️'`, `'😊'` |
| **🟠 HIGH: Icon stars for completion** | ❌ No | `Icons.stars_rounded` |
| **🟠 HIGH: AnimatedSwitcher** | ⚠ Parcial | Acceptable animation |

---

## 2.11 LEVEL EXAM

### LevelExamScreen (`lib/features/conversation/presentation/screens/level_exam_screen.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| CyberManhwaBackground (boss arena) | ✅ Sí | |
| Boss avatar display | ✅ Sí | |
| Timer | ✅ Sí | |
| DiceBear boss avatars | ❌ No | Uses generic DiceBear for bosses |
| **🔴 CRITICAL: FloatingActionButton** | ❌ No | Material FAB — completely breaks RPG aesthetic |
| **🔴 CRITICAL: FloatingActionButton.large** | ❌ No | Even worse — large Material FAB |
| **🔴 CRITICAL: CircleAvatar radius 110** | ❌ No | CircleAvatar for boss |
| **🔴 CRITICAL: ElevatedButton "Volver al Santuario"** | ❌ No | |
| **🔴 CRITICAL: Hardcoded Colors.redAccent** | ❌ No | Multiple places |
| **🟠 HIGH: GlassCard in results** | ⚠ Parcial | Acceptable |
| **🟠 HIGH: Emoji in result text** | ❌ No | `'🎉'`, `'🚨'` |

---

## 2.12 OTHER

### ConfigurationErrorWidget (`lib/core/widgets/configuration_error_widget.dart`)
| Aspect | Compliance | Notes |
|--------|-----------|-------|
| **🔴 CRITICAL: `Icons.settings_suggest_rounded`** | ❌ No | Material icon |
| **🟡 Medium: Dark themed** | ✅ Sí | At least it's dark |

---

# STEP 4: CRITICAL NON-COMPLIANCE ANALYSIS

## Category A: Emoji as UI Icons — 🔴 CRITICAL (35+ instances)

**What breaks:** The app uses emojis everywhere as icons, badges, and decorative elements. Emojis are not designed for UI — they render differently across platforms, have inconsistent styling, and look unprofessional. They scream "prototype" or "educational app for children."

**Examples:**
- `'🎙️'` for voice, `'📚'` for vocabulary, `'🎯'` for goals, `'💼'` for business
- `'🏰'` for guild hall, `'🔮'` for mana, `'👑'` for premium
- `'🌟'`, `'💻'`, `'✈️'`, `'☕'`, `'🍳'` for categories in lessons hub
- 20 different emojis in the topic bar during conversation

**What to do:** Replace ALL emojis with custom-designed line icons from a consistent icon set (Phosphor, Tabler, or custom game icons). Create a dedicated icon component.

## Category B: DiceBear Generic Avatars — 🔴 CRITICAL (10+ instances)

**What breaks:** DiceBear bottts/avatars are instantly recognizable as placeholder/default avatars. They destroy the fantasy world illusion. The user's profile, monster NPCs, bosses, and leaderboard entries all use the same generic style.

**What to do:** Replace with illustrated character art. For the user: customizable anime-style avatar. For monsters/bosses: unique illustrated creature art. For leaderboard: game-styled nameplates without real avatars.

## Category C: Unskinned Material Components — 🔴 CRITICAL (20+ instances)

**What breaks:** ElevatedButton, OutlinedButton, ChoiceChip, FilterChip, Switch, DropdownButton, TextFormField, AlertDialog, FloatingActionButton, CircularProgressIndicator, LinearProgressIndicator, SnackBar — all used with minimal or no theming. This is the #1 cause of "educational app" feel.

**What to do:** Define comprehensive component themes in AppTheme. Never use default Material components without custom styling.

## Category D: Rounded Corners Inconsistency — 🟠 HIGH

**What breaks:** The design system specifies 4px radius, but components use: 4px (cards), 8px (some badges), 10px (goal chips), 12px (some containers), 16px (mana meter), 20px (chat bubbles), 24px (bottom sheet default), 28px (SRS modal). This visual inconsistency signals lack of polish.

## Category E: Spanish UI Labels & Educational Terminology — 🟠 HIGH

**What breaks:** Multiple screens use Spanish labels like "Ajustes", "Guardar Cambios", "Idioma Nativo", "Nombre de Usuario". Even in Spanish mode, these sound like a school app. The RPG-themed titles are good (HUNTER REGISTRY, GATE SELECTION) but many screens default to educational jargon.

---

# STEP 5 & 6: FINAL MATRIX

| Screen | Component | Status | Priority | Action |
|--------|-----------|--------|----------|--------|
| **Welcome** | `Icons.translate` brand logo | ❌ No | 🔴 CRITICAL | Replace with custom game logo |
| **Welcome** | "TUTORSAAS" brand name | ❌ No | 🔴 CRITICAL | Rename to "DUNGEON OF ENGLISH" |
| **Welcome** | Google login icon | ❌ No | 🔴 CRITICAL | Custom styled Google button |
| **All screens** | Emoji icons (35+ instances) | ❌ No | 🔴 CRITICAL | Replace all with custom icons |
| **All screens** | DiceBear avatars (10+) | ❌ No | 🔴 CRITICAL | Illustrated character art |
| **Dashboard** | Avatar in header | ❌ No | 🔴 CRITICAL | Custom avatar component |
| **Dashboard** | Achievement emojis 🥇⚡🗣️🎯 | ❌ No | 🔴 CRITICAL | Icon replacements |
| **Dashboard** | Emoji 🇺🇸 for language | ❌ No | 🔴 CRITICAL | Text-based flag display |
| **Profile** | Emoji 📊 in header | ❌ No | 🔴 CRITICAL | Icon replacement |
| **Profile** | DiceBear avatar | ❌ No | 🔴 CRITICAL | Illustrated avatar |
| **Profile Edit** | ENTIRE FORM LAYOUT | ❌ No | 🔴 CRITICAL | Redesign as RPG stat sheet |
| **Profile Edit** | TextFormField | ❌ No | 🔴 CRITICAL | Custom RPG input fields |
| **Profile Edit** | DropdownButton | ❌ No | 🔴 CRITICAL | Custom selectors |
| **Settings** | ChoiceChip for CEFR | ❌ No | 🔴 CRITICAL | Custom segment control |
| **Settings** | Switch widgets | ❌ No | 🔴 CRITICAL | RPG-themed toggle |
| **Settings** | Spanish section titles | ❌ No | 🔴 CRITICAL | RPG naming |
| **Conversation** | Chat bubble radius 20px | ❌ No | 🔴 CRITICAL | Change to 4px |
| **Conversation** | Emoji topics (20 emojis) | ❌ No | 🔴 CRITICAL | Topic icons |
| **Conversation** | White mic FAB circle | ❌ No | 🔴 CRITICAL | Themed mana-core button |
| **Conversation** | Rounded bottom sheets | ❌ No | 🔴 CRITICAL | Flat sheets |
| **Level Exam** | FloatingActionButton | ❌ No | 🔴 CRITICAL | Custom action buttons |
| **Level Exam** | CircleAvatar for boss | ❌ No | 🔴 CRITICAL | Full boss illustration |
| **Chat Rooms** | DropdownButtonFormField | ❌ No | 🔴 CRITICAL | Custom |
| **Chat Rooms** | ChoiceChip categories | ❌ No | 🔴 CRITICAL | Custom |
| **Chat Rooms** | ElevatedButton everywhere | ❌ No | 🔴 CRITICAL | SystemButton |
| **Paywall** | Emoji in plan names 🔮⚡👑 | ❌ No | 🔴 CRITICAL | Icon replacements |
| **SRS Flashcards** | Bottom sheet radius 28 | ❌ No | 🔴 CRITICAL | Flat sheet |
| **SRS Flashcards** | Emoji in buttons 😅⚖️😊 | ❌ No | 🔴 CRITICAL | Text only |
| **All screens** | ElevatedButton (20+ uses) | ❌ No | 🔴 CRITICAL | SystemButton |
| **All screens** | OutlinedButton (10+ uses) | ❌ No | 🔴 CRITICAL | SystemButton |
| **All screens** | LinearProgressIndicator | ❌ No | 🟠 HIGH | Custom segmented bars |
| **All screens** | CircularProgressIndicator | ❌ No | 🟠 HIGH | Custom spinner |
| **All screens** | SnackBar default | ❌ No | 🟠 HIGH | Custom toast |
| **Dashboard** | Bottom nav | ✅ Sí | 🟡 MEDIUM | Refine transitions |
| **Dashboard** | Mana bar in header | ✅ Sí | 🟡 MEDIUM | Add animation |
| **CyberBg** | Particles + magic circle | ✅ Sí | 🟢 LOW | Minor refinements |
| **GlassCard** | Glassmorphism | ✅ Sí | 🟢 LOW | Animation on hover |
| **SystemButton** | Button design | ✅ Sí | 🟢 LOW | Haptic feedback |
| **ManaBar** | Segmented design | ✅ Sí | 🟢 LOW | Pulse animation |
| **Waveform** | Audio visualizer | ✅ Sí | 🟢 LOW | Color transitions |

---

# STEP 7: EXECUTIVE REPORT

## 7.1 RPG Identity Score

**Current RPG Identity Match: ~35%**

The app has strong **conceptual** RPG alignment (terminology, colors, background animations, sound design ideas) but weak **visual execution** (Material defaults, emoji abuse, generic avatars, form patterns).

## 7.2 Educational App Residue: ~65%

Despite the RPG wrapper, 65% of the UI still reads as "educational app with a dark theme." The main offenders:
1. Form-based screens (Profile Edit)
2. Default Material components everywhere
3. Emoji instead of designed icons
4. Spanish educational labels
5. Standard layout patterns (list views, stacked fields)
6. Stock avatar placeholders

## 7.3 Top 20 Problems to Fix (Priority Order)

| # | Problem | Impact | Effort |
|---|---------|--------|--------|
| 1 | Replace all emoji icons with custom icon set | 🔴 Critical | High |
| 2 | Eliminate DiceBear avatars | 🔴 Critical | High |
| 3 | Theme ALL Material components (buttons, inputs, chips, switches) | 🔴 Critical | Medium |
| 4 | Redesign Profile Edit as RPG stat/inventory screen | 🔴 Critical | Medium |
| 5 | Replace ElevatedButton/OutlinedButton with SystemButton | 🔴 Critical | Low |
| 6 | Fix chat bubble radius (20px → 4px) | 🔴 Critical | Low |
| 7 | Replace white mic FAB with dark neon mana-core button | 🔴 Critical | Low |
| 8 | Replace FloatingActionButton in Level Exam | 🔴 Critical | Low |
| 9 | Un-round all bottom sheets (28px/24px → 4px or 0px) | 🟠 High | Low |
| 10 | Replace ALL LinearProgressIndicator with custom segmented bars | 🟠 High | Medium |
| 11 | Replace ALL CircularProgressIndicator with custom spinners | 🟠 High | Low |
| 12 | Replace DropdownButton/DropdownButtonFormField with custom selectors | 🟠 High | Medium |
| 13 | Replace ChoiceChip/FilterChip with custom segment controls | 🟠 High | Medium |
| 14 | Replace default SnackBar with custom toast/notification | 🟠 High | Low |
| 15 | Replace Switch widgets with RPG-themed toggles | 🟠 High | Low |
| 16 | Rename "TUTORSAAS" to "DUNGEON OF ENGLISH" in welcome screen | 🔴 Critical | Low |
| 17 | Replace `Icons.translate` with custom game logo | 🔴 Critical | Medium |
| 18 | Redesign entire SettingsScreen section layout (remove form feeling) | 🟠 High | Medium |
| 19 | Replace AlertDialog with custom RPG modal | 🟠 High | Medium |
| 20 | Add comprehensive theme definitions to AppTheme | 🔴 Critical | Medium |

## 7.4 Recommended First Actions (Maximum Visual Impact)

1. **Define complete component theme** in `app_theme.dart` (button, input, card, switch, chip, dialog, snackbar themes) — this fixes 50% of the visual issues at once
2. **Create a custom icon set** — replace all emojis and generic Material icons with game-styled line icons
3. **Replace profile avatars** with illustrated character system
4. **Redesign Profile Edit** as a Hunter Stats screen (game-style stat allocation, not a form)
5. **Replace all ElevatedButtons** with SystemButton globally
6. **Fix all border radii** to be consistent (4px everywhere)

## 7.5 Components to Reuse

- ✅ **CyberManhwaBackground** — Excellent, keep and refine
- ✅ **GlassCard** — Good, minor refinements
- ✅ **SystemWindow** — Good, keep
- ✅ **SystemButton** — Good, expand usage
- ✅ **ManaBar** — Good, use more widely
- ✅ **SystemChatBubble** — Good, but fix radius
- ✅ **VoiceWaveformVisualizer** — Good, keep
- ✅ **DraggableMonsterWidget** — Concept excellent, replace avatar source
- ✅ **StatusWindowModal** — Good concept, refine
- ✅ **HunterLicenseScreen** — Excellent, keep
- ✅ **NeonProgressPainter** — Good, use more

## 7.6 Components to Rebuild from Scratch

- ❌ **Profile Edit Screen** — Complete rebuild as RPG stat screen
- ❌ **All emoji-based icons** — New icon system
- ❌ **Avatar system** — Custom illustrated avatars
- ❌ **Settings Screen layout** — RPG-styled settings
- ❌ **All bottom sheets** — Flat-style RPG panels
- ❌ **Chat bubbles** — Fix radius, add RPG styling
- ❌ **Level Exam FABs** — Replace with RPG action buttons
- ❌ **SRS Flashcard Modal** — Fix sheet style
- ❌ **Placement Test screen** — RPG restyle

## 7.7 Design Debt Summary

| Category | Count | Severity |
|----------|-------|----------|
| 🔴 Critical issues | 35+ | Blocks product identity |
| 🟠 High issues | 25+ | Reduces immersion |
| 🟡 Medium issues | 15+ | Visual inconsistencies |
| 🟢 Low issues | 10+ | Polish items |
| ✅ Compliant components | ~20 | Foundation to build on |

---

**Final Verdict:** The app has a solid RPG **conceptual framework** but needs a comprehensive **visual execution pass** to fully realize the Isekai Hunter experience. The current state reads as "educational app in a dark theme with RPG labels" rather than "AAA mobile game for language learning." A focused redesign of component styling, iconography, avatar system, and form patterns would bring the RPG identity to ~85%+.

**Estimated Effort for Full Compliance:** 4-6 weeks for a senior Flutter UI engineer working full-time.
