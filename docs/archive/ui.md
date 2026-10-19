# Sistema de Diseño — Abyssal Interface (Isekai Manhwa System HUD)

## Identidad Visual

**Nombre:** Abyssal Interface — Sistema de interfaz inmersivo inspirado en manhwa/coreano de sistemas de juego, diseñado para transmitir una estética premium, futurista y educativa pero no infantil.

## Paleta de Colores

| Token | Hex | RGB | Uso |
|-------|-----|-----|-----|
| `voidBg` | `#05070E` | (5,7,14) | Fondo principal — El Vacío |
| `background` | `#11131B` | (17,19,27) | Superficies secundarias |
| `surface` | `#11131B` | (17,19,27) | Superficie base |
| `surfaceContainerLowest` | `#0B0E16` | (11,14,22) | Contenedores más profundos |
| `surfaceContainerLow` | `#191B23` | (25,27,35) | Contenedores bajos |
| `surfaceContainer` | `#1D1F27` | (29,31,39) | Contenedores medios |
| `surfaceContainerHigh` | `#272A32` | (39,42,50) | Contenedores altos |
| `surfaceContainerHighest` | `#32343D` | (50,52,61) | Contenedores máximos |
| **`manaCyan`** | **`#00E5FF`** | (0,229,255) | **Color primario — Mana Cyan** |
| `manaCyanDim` | `#00DAF3` | (0,218,243) | Mana Cyan atenuado |
| `manaCyanLight` | `#9CF0FF` | (156,240,255) | Mana Cyan claro |
| `manaCyanText` | `#C3F5FF` | (195,245,255) | Texto sobre cyan |
| **`royalGold`** | **`#FFC700`** | (255,199,0) | **Color secundario — Oro Real** |
| `royalGoldDim` | `#F5BF00` | (245,191,0) | Oro atenuado |
| `royalGoldLight` | `#FFDF94` | (255,223,148) | Oro claro |
| **`runeViolet`** | **`#9D4EDD`** | (157,78,221) | **Color terciario — Violeta Rúnico** |
| `runeVioletContainer` | `#E6C3FF` | (230,195,255) | Contenedor violeta |
| `crimsonRed` | `#FF1744` | (255,23,68) | Rojo carmesí (bosses) |
| `errorRed` | `#FFB4AB` | (255,180,171) | Errores |
| `emeraldGreen` | `#00E676` | (0,230,118) | Verde esmeralda (éxito) |
| `onBackground` | `#E1E2ED` | (225,226,237) | Texto principal |
| `onSurfaceVariant` | `#BAC9CC` | (186,201,204) | Texto secundario |
| `outline` | `#849396` | (132,147,150) | Bordes |

## Tipografía

| Estilo | Font | Peso | Tamaño | Tracking |
|--------|------|------|--------|----------|
| `displayLarge` | Space Grotesk | Bold (700) | 48px | -0.04em |
| `displayMedium` | Space Grotesk | SemiBold (600) | 32px | — |
| `displaySmall` | Space Grotesk | Medium (500) | 24px | — |
| `headlineLarge` | Space Grotesk | SemiBold (600) | 24px | — |
| `titleLarge` | Space Grotesk | Bold (700) | 20px | 0.05em |
| `bodyLarge` | Inter | Regular (400) | 18px | — |
| `bodyMedium` | Inter | Regular (400) | 16px | — |
| `bodySmall` | Inter | Regular (400) | 14px | — |
| `labelLarge` | JetBrains Mono | Bold (700) | 20px | 0.05em |
| `labelMedium` | JetBrains Mono | SemiBold (600) | 12px | 0.1em |
| `labelSmall` | JetBrains Mono | SemiBold (600) | 10px | 0.1em |

## Componentes del Sistema

### GlassCard
Contenedor translúcido base con `BackdropFilter` blur, borde con glow, sombra con color. `borderRadius: 4px` (máx 20px). Usar como base para cualquier contenedor flotante nuevo.

### SystemWindow
Ventana del sistema con bordes con glow, runas decorativas animadas en las esquinas, y fondo semitransparente (`surface` con alpha 0.94). Usar para paneles modales y ventanas de estado.

### SystemButton
Botón del sistema con borde de color (cyan/gold/violet), tipografía JetBrains Mono, icono opcional. Variantes: `gold` (acciones premium), `urgent` (acciones críticas, fondo violeta).

### ManaBar
Barra de progreso segmentada (10 segmentos) con color configurable, label y subtitle. Estilo cyberpunk con borde fino.

### ManaMeterWidget (deprecated → usar ManaBar)
Indicador de maná con icono, valor numérico, barra de progreso y contador de uso en sesión.

### SystemChatBubble
Burbuja de chat con border izquierdo/derecho según role (`user` = cyan derecha, `assistant` = violeta izquierda). Tipografía: JetBrains Mono para el role label, Inter 16px para el texto.

### CyberManhwaBackground
Fondo animado de capas múltiples:
1. Dark base void `#04060C`
2. Imagen de fondo dinámica según modo/level (bosque, ruinas, viento, portal, boss arena)
3. Viñeta oscura + scanlines
4. Círculo mágico animado rotatorio con pentagrama CustomPaint
5. Partículas de maná flotantes

Modos: `dynamicLevel`, `onboardingStep0-7`, `dashboardGate`, `guildHall`, `guildTable`, `hunterStatus`.

### DraggableMonsterWidget
Mascota IA arrastrable con dos estados:
- **Colapsado:** Pill flotante con avatar, nombre, estado (enseñando/vivo), glow pulsante
- **Expandido:** Overlay fullscreen con pentagrama rotatorio, glow, animación de respiración y onda al hablar

## Screens y Rutas

| # | Ruta | Screen | Archivo Template |
|---|------|--------|------------------|
| 1 | `/` | WelcomeScreen | `auth/presentation/screens/welcome_screen.dart` |
| 2 | `/onboarding` | OnboardingScreen | `onboarding/presentation/screens/onboarding_screen.dart` |
| 3 | `/home` | DashboardScreen | `dashboard/presentation/screens/dashboard_screen.dart` |
| 4 | `/conversation` | ConversationScreen | `conversation/presentation/screens/conversation_screen.dart` |
| 5 | `/summary` | SessionSummaryScreen | `dashboard/presentation/screens/session_summary_screen.dart` |
| 6 | `/level-exam` | LevelExamScreen | `conversation/presentation/screens/level_exam_screen.dart` |
| 7 | `/paywall` | PaywallScreen | `subscription/presentation/screens/paywall_screen.dart` |
| 8 | `/profile` | ProfileScreen | `dashboard/presentation/screens/profile_screen.dart` |
| 9 | `/profile-edit` | ProfileEditScreen | `dashboard/presentation/screens/profile_edit_screen.dart` |
| 10 | `/settings` | SettingsScreen | `dashboard/presentation/screens/settings_screen.dart` |
| 11 | `/chat-rooms` | ChatRoomsScreen | `chat_rooms/presentation/screens/chat_rooms_screen.dart` |
| 12 | `/voice-room` | VoiceRoomScreen | `chat_rooms/presentation/screens/voice_room_screen.dart` |

### DashboardScreen — 3 Tabs
- **Inicio:** Saludo, XP+streak, lección hero, grid de lecciones, FAB "Hablar Ahora"
- **Progreso:** Radar chart 5D, heatmap 28 días, tendencias 14 días
- **Hunter Status:** Daily Quests, Leaderboard, rango de cazador

## Reglas de UI

- **Dark mode obligatorio** — nunca light mode
- **No rounded corners >20px** — máximo 20px, por defecto 4px
- **Todos los contenedores flotantes** deben usar `GlassCard` como base
- **Nuevos widgets** deben extender `GlassCard` para contenedores flotantes
- **Nuevas screens** deben registrarse en `router.dart`
- **Paleta de colores** definida exclusivamente en `AppColors`
- **Tipografía** definida en `AppTheme` usando Google Fonts (Space Grotesk, Inter, JetBrains Mono)
