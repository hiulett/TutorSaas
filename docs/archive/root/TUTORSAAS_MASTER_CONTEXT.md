# 📋 DOCUMENTO MAESTRO DE CONTEXTO — TutorSaas
> **Versión del documento:** 2.0.0 — Generado por análisis completo del codebase  
> **Fecha de auditoría:** 27 de Julio de 2026  
> **Estado del sistema:** Producción / En ejecución en dispositivos Android  
> **Plataformas activas:** Flutter Mobile (Android primario) + Web Admin Panel (React/Vite)

---

## 1. RESUMEN EJECUTIVO

**TutorSaas** es una plataforma SaaS de aprendizaje conversacional de idiomas potenciada por Inteligencia Artificial Generativa. Funciona como un **tutor personal de idiomas disponible 24/7**, que escucha la voz del usuario, transcribe el habla en tiempo real usando Groq Whisper, genera respuestas contextuales con DeepSeek LLM en streaming, y las reproduce con voz sintetizada localmente en menos de **~1 segundo de latencia total** (ida y vuelta).

### Problema que resuelve
La mayoría de los estudiantes de idiomas sufren la **"barrera del habla"**: comprenden gramática y lectura pero carecen de oportunidades reales de práctica conversacional. Las tutorías humanas son costosas ($40–$120/hora), poco flexibles en horario, y generan ansiedad social que bloquea el aprendizaje.

### Propuesta de valor única
- Conversación de voz inmersiva con IA empática en < 1 segundo de respuesta
- Corrección gramatical contextual y sin interrupciones del flujo
- Roleplay de escenarios de vida real (aeropuertos, restaurantes, entrevistas laborales)
- Análisis biométrico del habla (WPM, claridad fonética, huella de voz)
- Gamificación con XP, rachas, logros y misiones dinámicas
- Catálogo masivo de lecciones A1–C2 en inglés, francés, alemán e italiano

### Valor de negocio
Modelo Freemium B2C SaaS con suscripción mensual/anual recurrente. Target principal: estudiantes latinoamericanos de inglés con ambiciones profesionales. Expansión B2B corporativa proyectada para capacitación de equipos.

---

## 2. CONTEXTO DE NEGOCIO

### 2.1 Problema actual
- Tutorías humanas inaccesibles por costo y disponibilidad horaria
- Apps de idiomas existentes (Duolingo, Babbel) orientadas a vocabulario y gramática, **no a conversación real**
- Anxiety del habla: el estudiante estudia pero no practica hablar
- Falta de feedback inmediato y empático sobre errores gramaticales o de pronunciación

### 2.2 Oportunidad de mejora
- El mercado EdTech de IA generativa está en expansión exponencial (2024–2028)
- Modelos LLM ultra-rápidos (DeepSeek, Groq/Whisper) ya permiten latencias < 1s
- Los hispanohablantes representan ~500M de potenciales usuarios aprendiendo inglés
- Inexistencia de un producto conversacional de voz en tiempo real con la calidad propuesta

### 2.3 Objetivo funcional
Ofrecer un tutor IA de idiomas con experiencia tan inmersiva como hablar con un humano nativo, que además registre el progreso y corrija errores de forma empática y contextual.

### 2.4 Usuarios / Actores principales

| Actor | Descripción |
|-------|-------------|
| **Estudiante (Usuario Final)** | Usuario principal. Practica idiomas mediante conversación de voz o texto con la IA |
| **Administrador SaaS** | Gestiona el contenido de lecciones, usuarios, niveles CEFR y planes via Web Admin |
| **IA Tutor** | Actor no humano. Responde, corrige, enseña y evalúa en tiempo real |

### 2.5 Impacto esperado
- Reducción del costo de práctica conversacional de $40–$120/hora a <$20/mes
- Aumento de 3x en minutos de práctica semanal vs. apps tradicionales
- Mejora medible de fluidez (WPM) en 90 días de uso consistente

### 2.6 Alcance del negocio
**Lo que SÍ resuelve:**
- Práctica conversacional 1-a-1 con IA en voz y texto
- Corrección gramatical en tiempo real
- Roleplay de escenarios específicos (viajes, negocios, social)
- Seguimiento de progreso, vocabulario aprendido y estadísticas de habla
- Salas de voz grupales para práctica social

**Lo que NO resuelve (actualmente):**
- Corrección de pronunciación a nivel fonémico profundo (solo biometría básica)
- Modo 100% offline sin conexión a internet
- Clases en vivo con tutores humanos reales
- Soporte completo multilenguaje más allá de inglés, francés, alemán e italiano
- Certificación oficial CEFR

---

## 3. CONTEXTO FUNCIONAL

### 3.1 Casos de uso principales

| # | Caso de uso | Descripción |
|---|-------------|-------------|
| CU-01 | **Chat Libre ("Hablar Ahora")** | Conversación abierta con IA sobre cualquier tema; el usuario elige el tópico |
| CU-02 | **Lección por Escenario (Roleplay)** | Simulación de misión específica con objetivos, rol del IA y metas evaluadas |
| CU-03 | **Evaluación de Nivel (Level Exam)** | Examen conversacional para determinar el nivel CEFR inicial del usuario |
| CU-04 | **Salas de Voz Grupales** | Práctica colaborativa en salas de audio con otros usuarios |
| CU-05 | **Análisis Biométrico del Habla** | Revisión de velocidad de habla (WPM), claridad fonética y fonemas a mejorar |
| CU-06 | **Revisión de Vocabulario (SRS)** | Tarjetas de vocabulario con algoritmo SM-2 de repaso espaciado |
| CU-07 | **Actualización a Plan PRO (Paywall)** | Desbloqueo de lecciones avanzadas, análisis completo y salas privadas |

### 3.2 Flujo actual de una sesión conversacional
```
1. Usuario abre la app → WelcomeScreen (autenticación)
2. Si es nuevo usuario → OnboardingScreen (nivel CEFR + intereses)
3. Dashboard → Selecciona lección recomendada o chat libre
4. ConversationScreen se inicializa:
   a. Carga escenario de Supabase (si aplica)
   b. El IA tutor envía mensaje inicial
5. Bucle de conversación:
   a. [HOLD-TO-TALK] Usuario presiona y mantiene el botón de voz
   b. Record package graba audio AAC/m4a localmente
   c. Usuario suelta → Envía audio a Groq Whisper STT (~200ms)
   d. Texto transcrito → enviado a DeepSeek LLM como streaming SSE (~250ms TTFT)
   e. Motor de corrección en background evalúa metas de la misión
   f. Respuesta en streaming → reproducida vía flutter_tts (~300ms)
6. Usuario termina → /summary (SessionSummaryScreen)
7. Se invalidan providers → Dashboard se actualiza con nuevo progreso
```

### 3.3 Flujo de texto alternativo
```
1. Usuario toca ícono de teclado → Se despliega keyboard drawer
2. Escribe texto → Toca enviar
3. Texto va directamente al LLM (sin pasar por Groq STT)
4. Respuesta en streaming igual que en modo voz
```

### 3.4 Reglas de negocio

| Código | Regla | Impacto |
|--------|-------|---------|
| RN-01 | La transcripción STT **siempre** usa `language: 'en'` forzado en Groq | Evita que el motor transcriba en español cuando el usuario mezcla idiomas |
| RN-02 | Las metas de la misión se evalúan por **coincidencia de keywords** en el texto del usuario | Si el usuario dice las palabras clave del objetivo, se marca como completado |
| RN-03 | El modo voz usa **record** (audio raw AAC), NO speech_to_text nativo | Solución al problema de VAD rígido del SO que cortaba al usuario durante pausas |
| RN-04 | Las conversaciones con `scenarioId` se **persisten en Supabase** | Las conversaciones libres (sin escenario) son efímeras, solo en memoria |
| RN-05 | Si el usuario ya tiene mensajes guardados en Supabase, se **reanuda** la conversación | No se re-crea ni se borra el historial al re-entrar a un escenario |
| RN-06 | Al cerrar ConversationScreen, se **invalidan** los providers del dashboard | El progreso se recalcula automáticamente tras cada sesión |
| RN-07 | El nivel CEFR del usuario determina **qué lecciones se recomiendan** | Solo se recomiendan lecciones del nivel actual o inferior |
| RN-08 | El corrector gramatical ajusta su **nivel de intrusividad** según `correction_style` del usuario | Opciones: `gentle`, `balanced`, `strict` |
| RN-09 | Un usuario nuevo recibe **datos mock/fallback** en el dashboard hasta completar el onboarding | Los valores por defecto son: XP=0, streak=0, level=A1 |
| RN-10 | Las API keys se inyectan via `--dart-define` en builds de producción | Los valores hardcoded son solo para desarrollo local |

### 3.5 Excepciones documentadas
- **Sin internet:** El STT falla graciosamente con `try-catch`. El usuario ve un estado de error, pero la app no crashea.
- **Cuota API Groq agotada:** El error HTTP llega al `catch` del provider y se muestra mensaje de error al usuario.
- **Supabase URL no configurada:** App muestra `ConfigurationErrorWidget` antes de lanzar la UI principal.
- **Escenario no encontrado en catálogo local:** Retorna `null` y la conversación inicia en modo libre.

### 3.6 Casos borde identificados
- Usuario habla en español cuando el sistema espera inglés → Groq transcribe en inglés (forzado), puede perder precisión
- Usuario con conectividad intermitente → Los mensajes pueden llegar duplicados o fuera de orden
- Conversación muy larga → Los tokens del contexto LLM pueden llegar al límite del modelo
- Escenario actualizado en Web Admin mientras el usuario está en ConversationScreen → El usuario no ve los cambios hasta la próxima sesión

### 3.7 Casos no contemplados actualmente
- Pronunciación incorrecta de palabras individuales (análisis fonémico granular)
- Traducción en tiempo real de respuestas del IA al español
- Compartir progreso en redes sociales
- Modo duo (dos estudiantes practicando juntos con mediación de IA)

---

## 4. CONTEXTO TÉCNICO

### 4.1 Arquitectura general

```
┌─────────────────────────────────────────────────────────┐
│              CAPA DE PRESENTACIÓN                        │
│   Flutter Mobile App (Android / iOS)                     │
│   React + Vite Web Admin Panel                          │
└──────────────────────┬──────────────────────────────────┘
                       │ Riverpod providers / Fetch API
┌──────────────────────▼──────────────────────────────────┐
│              CAPA DE DOMINIO (Clean Architecture)        │
│   Use Cases, Repositories (interfaces), Domain Models    │
│   ConversationNotifier, DashboardRepository, AuthProviders│
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┼──────────────────┐
        ▼              ▼                  ▼
┌──────────┐   ┌──────────────┐   ┌────────────────┐
│ Supabase │   │ Groq Cloud   │   │ DeepSeek AI    │
│ Postgres │   │ Whisper STT  │   │ LLM Streaming  │
│ Auth/RLS │   │ (Audio→Text) │   │ (SSE Chat)     │
└──────────┘   └──────────────┘   └────────────────┘
                       │
                       ▼
              ┌──────────────────┐
              │ flutter_tts      │
              │ (On-device TTS)  │
              └──────────────────┘
```

### 4.2 Stack tecnológico completo

| Capa | Tecnología | Versión |
|------|-----------|---------|
| **Mobile Framework** | Flutter + Dart | SDK 3.29.0 / Dart 3.11.5 |
| **Estado** | flutter_riverpod + hooks_riverpod | ^2.5.1 |
| **Navegación** | go_router | ^14.0.0 |
| **Backend** | Supabase (Postgres + Auth + RLS) | ^2.6.0 |
| **STT** | Groq Cloud API (whisper-large-v3-turbo) | — |
| **LLM** | DeepSeek Chat Completions (SSE) | deepseek-chat |
| **TTS** | flutter_tts (on-device) | ^4.0.0 |
| **Grabación** | record package (AAC/m4a) | ^4.4.4 |
| **Modelos** | freezed + json_serializable | ^2.5.2 / ^6.7.1 |
| **Networking** | dio (HTTP client) | ^5.4.0 |
| **WebSockets** | web_socket_channel | ^3.0.3 |
| **Charts** | fl_chart | ^0.68.0 |
| **Animaciones** | flutter_animate + lottie | ^4.5.0 / ^3.1.2 |
| **Admin Panel** | React + Vite | — |
| **Auth Social** | google_sign_in | ^6.2.1 |
| **Seguridad local** | flutter_secure_storage | ^9.0.0 |

### 4.3 Pipeline de voz e inferencia (latencia detallada)

```
Usuario habla    →    [record] Captura AAC    →    100ms
                 →    [Groq Whisper STT]      →    ~200ms
                 →    [DeepSeek LLM SSE]      →    ~250ms TTFT
                 →    [flutter_tts on-device] →    ~300ms
                                              TOTAL: ~850ms–1.1s
```

### 4.4 Mapa de rutas de navegación

```
/                       → WelcomeScreen (Auth)
/onboarding             → OnboardingScreen (evaluación nivel + intereses)
/home                   → DashboardScreen (métricas, lecciones, progreso)
/conversation           → ConversationScreen (?scenarioId=&scenarioTitle=)
/level-exam             → LevelExamScreen (?level=A1)
/summary                → SessionSummaryScreen
/profile                → ProfileScreen
/profile-edit           → ProfileEditScreen
/settings               → SettingsScreen (nivel de corrección)
/paywall                → PaywallScreen (suscripción PRO)
/chat-rooms             → ChatRoomsScreen (lista de salas)
/voice-room             → VoiceRoomScreen (?roomId=)
```

### 4.5 Módulos del sistema

| Módulo | Ubicación | Responsabilidad |
|--------|-----------|----------------|
| **auth** | `lib/features/auth/` | Autenticación Supabase (email + Google), gestión de sesión |
| **conversation** | `lib/features/conversation/` | Motor de voz, STT→LLM→TTS, persistencia de mensajes |
| **dashboard** | `lib/features/dashboard/` | Dashboard, progreso, lecciones recomendadas, estadísticas |
| **onboarding** | `lib/features/onboarding/` | Flujo inicial de evaluación y configuración de nivel |
| **subscription** | `lib/features/subscription/` | Paywall, planes PRO, lógica de acceso premium |
| **chat_rooms** | `lib/features/chat_rooms/` | Salas de voz grupales en tiempo real |
| **vocabulary** | `lib/features/vocabulary/` | SRS flashcards, gestión de vocabulario aprendido |
| **core/theme** | `lib/core/theme/` | Design tokens, colores, tipografía (AppColors, AppTheme) |
| **core/widgets** | `lib/core/widgets/` | Componentes reutilizables (GlassCard, CyberBackground, Draggable Monster) |
| **core/constants** | `lib/core/constants/` | ApiConstants (URLs, claves API via dart-define) |
| **web_admin** | `web_admin/` | Panel de administración React para gestión de contenido |

### 4.6 Manejo de errores
- Cada llamada API está envuelta en `try-catch`
- Los providers Riverpod usan `AsyncValue` para manejar estados de carga/error
- `ConfigurationErrorWidget` se muestra si Supabase no está configurado al inicio
- `ErrorTracker.logError()` registra errores críticos con stack trace
- `LatencyBenchmark.runPipelineBenchmark()` corre al inicio como diagnóstico

### 4.7 Observabilidad y logging
- `ErrorTracker` (`lib/core/utils/error_tracker.dart`) — logging centralizado
- `LatencyBenchmark` (`lib/core/utils/latency_benchmark.dart`) — medición de tiempos del pipeline
- `logger: ^2.0.2` — logging estructurado
- `ai_usage_logs` en Supabase — registro de tokens usados, costo estimado y latencia por llamada

---

## 5. MODELO DE DATOS Y ENTIDADES

### 5.1 Diagrama de relaciones principales

```
auth.users (Supabase Auth)
    │
    ▼ trigger: handle_new_user()
public.users ──────────────────────────────────────────────────────┐
    │                                                               │
    ├── user_settings (1:1)           [corrección, personalidad]   │
    ├── user_language_profiles (1:N)  [nivel CEFR, XP, rachas]     │
    │       └── languages (FK)                                      │
    │       └── cefr_levels (FK)                                    │
    ├── conversations (1:N)                                         │
    │       └── messages (1:N)                                      │
    │       └── corrections (1:N)                                   │
    │       └── scenarios (FK)                                      │
    ├── daily_stats (1:N)             [minutos, XP por día]         │
    ├── weekly_stats (1:N)                                          │
    ├── user_vocabulary (N:N)         [con SM-2 ease_factor]        │
    │       └── vocabulary_items (FK)                               │
    ├── user_achievements (N:N)                                     │
    │       └── achievements (FK)                                   │
    ├── daily_challenges (1:N)                                      │
    ├── user_subscriptions (1:1)                                    │
    │       └── subscription_plans (FK)                             │
    ├── payments (1:N)                                              │
    ├── pronunciation_assessments (1:N)                             │
    └── ai_usage_logs (1:N)          [tokens, costo, latencia]    │
                                                                    │
scenarios ──────────────────────────────────────────────────────────┘
    └── scenario_objectives (1:N)
```

### 5.2 Tablas principales — atributos relevantes

#### `users`
| Campo | Tipo | Notas |
|-------|------|-------|
| `id` | UUID | FK = auth.users.id |
| `email` | VARCHAR(255) | Único, requerido |
| `display_name` | VARCHAR(100) | Público, editable |
| `avatar_url` | TEXT | URL de foto de perfil |
| `native_language` | VARCHAR(10) | Default `'es'` (español) |
| `timezone` | VARCHAR(50) | Default `'UTC'` |
| `is_active` | BOOLEAN | Para soft-delete |

#### `user_settings`
| Campo | Tipo | Notas |
|-------|------|-------|
| `correction_style` | VARCHAR(20) | `'gentle'`, `'balanced'`, `'strict'` |
| `tutor_personality` | VARCHAR(50) | Default `'friendly'` |
| `daily_goal_minutes` | INTEGER | Default 15 |
| `notifications_enabled` | BOOLEAN | Default true |

#### `user_language_profiles`
| Campo | Tipo | Notas |
|-------|------|-------|
| `language_id` | INTEGER | FK languages |
| `cefr_level_id` | INTEGER | FK cefr_levels |
| `xp_points` | INTEGER | Acumulado total |
| `current_streak` | INTEGER | Racha actual días |
| `longest_streak` | INTEGER | Racha histórica máxima |
| `total_minutes` | INTEGER | Minutos de práctica totales |

#### `conversations`
| Campo | Tipo | Notas |
|-------|------|-------|
| `scenario_id` | UUID | Puede ser NULL (conversación libre) |
| `status` | VARCHAR(20) | `'active'`, `'completed'`, `'abandoned'` |
| `fluency_score` | DECIMAL(5,2) | 0–100, calculado al cerrar |
| `xp_earned` | INTEGER | XP de la sesión |

#### `scenarios`
| Campo | Tipo | Notas |
|-------|------|-------|
| `language_id` | INTEGER | Idioma de la lección |
| `difficulty_level` | VARCHAR(5) | A1–C2 |
| `category` | VARCHAR(100) | `'business'`, `'travel'`, `'daily'`, etc. |
| `context` | TEXT | System prompt completo del escenario |

#### `cefr_levels`
| Campo | Tipo | Notas |
|-------|------|-------|
| `code` | VARCHAR(5) | `'A1'`, `'A2'`, `'B1'`, `'B2'`, `'C1'`, `'C2'` |
| `order_index` | INTEGER | 1–6 para ordenamiento |

### 5.3 Entidades del modelo local (Flutter)

#### `LessonData` (catálogo local)
```dart
- id: String                   // 'a1_greetings', 'b2_negotiation', etc.
- targetLanguageCode: String   // 'en', 'fr', 'de', 'it'
- title: String
- description: String
- level: String                // 'A1'–'C2'
- category: String             // 'social', 'business', 'travel', 'tech'
- interest: String
- difficulty: int              // 1–6
- mainObjective: String        // Objetivo principal de la misión
- scenarioContext: String      // System prompt context
- assistantRole: String        // Ej: "Hotel Receptionist"
- userRole: String             // Ej: "Guest checking in"
- initialAssistantMessage: String
- goals: List<ScenarioGoalItem>   // 5 metas por lección
- usefulPhrases: List<UsefulPhraseItem> // 10 frases útiles
```

#### `ConversationState` (Riverpod/Freezed)
```dart
- messages: List<ConversationMessage>
- isRecording: bool
- isProcessing: bool
- isPlaying: bool
- currentTranscribingText: String
- errorMessage: String?
- activeScenarioId: String?
- activeScenarioName: String?
- goalEvaluationResults: Map<String, bool>   // goal.id → achieved
```

#### `UserSettings` (Riverpod/Freezed)
```dart
- correctionLevel: String     // 'gentle', 'balanced', 'strict'
- tutorPersonality: String    // 'friendly', 'professional', 'motivational'
- dailyGoalMinutes: int       // 5, 10, 15, 20, 30
- notificationsEnabled: bool
```

### 5.4 Estados importantes

| Entidad | Estados |
|---------|---------|
| `ConversationState` | idle → recording → processing → playing → idle (ciclo continuo) |
| `Conversation.status` | `active` → `completed` / `abandoned` |
| `UserSubscription.status` | `active` / `cancelled` / `expired` |
| `ScenarioGoalItem.isCompleted` | `false` → `true` (irreversible en sesión) |

---

## 6. REGLAS Y DECISIONES DE NEGOCIO

### 6.1 Reglas explícitas (implementadas)

| Código | Regla | Archivo |
|--------|-------|---------|
| **RB-01** | El STT usa `whisper-large-v3-turbo` con `language: 'en'` forzado | `conversation_providers.dart` |
| **RB-02** | La evaluación de metas usa keyword matching sobre el texto del usuario | `lesson_catalog.dart:isSatisfiedBy()` |
| **RB-03** | El TTS usa tasa `rate: 0.48` para habla natural (no robótica) | `conversation_providers.dart` |
| **RB-04** | Conversaciones con scenarioId se persisten; sin scenarioId son efímeras | `conversation_providers.dart:initSession()` |
| **RB-05** | Al re-entrar a un escenario ya iniciado, se cargan mensajes históricos de Supabase | `conversation_providers.dart:loadConversationMessages()` |
| **RB-06** | Las stats del dashboard se recalculan al salir de ConversationScreen | `conversation_screen.dart:dispose()` |
| **RB-07** | El sistema intenta sincronizar el escenario desde Supabase al iniciar sesión | `conversation_providers.dart:initSession()` |
| **RB-08** | El catálogo de lecciones puede actualizarse dinámicamente con datos de Supabase | `LessonCatalog.updateCatalogFromMap()` |

### 6.2 Reglas implícitas (inferidas del código)
- Los usuarios sin autenticación reciben datos mock con valores por defecto
- Los errores de red en providers se capturan silenciosamente para no romper la UI
- El `GlassCard` se usa como componente visual de referencia para cualquier contenedor flotante nuevo
- Toda nueva feature debe envolver errores en try-catch para evitar pantallas rojas en producción
- Las claves API **no deben** hardcodearse en producción; se requiere `--dart-define`

### 6.3 Decisiones de diseño tomadas
1. **Groq en lugar de OpenAI STT**: 12x más barato, menor latencia. Decisión permanente salvo cambio de precios.
2. **flutter_tts en lugar de TTS en la nube**: Elimina latencia de red para síntesis de voz. Requiere voz del SO; no es clonable.
3. **record en lugar de speech_to_text**: El STT nativo del SO cortaba pausas de pensamiento (VAD rígido de 1.5–2s). record graba audio raw hasta que el usuario suelta el botón.
4. **Supabase en lugar de Firebase**: PostgreSQL estructurado, mejor para relaciones complejas, RLS más granular.
5. **DeepSeek en lugar de GPT-4**: Significativamente más económico para el volumen de tokens de conversaciones de voz largas.
6. **LessonCatalog como catálogo local + Supabase**: El catálogo local asegura que la app funcione sin red para navegar lecciones; Supabase se usa para persistencia y actualizaciones dinámicas.

### 6.4 Decisiones pendientes (abiertas)
- **PENDIENTE:** Definir la pasarela de pago real (RevenueCat mencionado en schema pero no implementado completamente)
- **PENDIENTE:** Estrategia de rotación y balanceo de API keys en producción
- **PENDIENTE:** Definir límites de uso en plan gratuito (minutos/día, conversaciones/semana)
- **PENDIENTE:** Definir si el modo C2 requiere diferente modelo LLM (más avanzado)
- **PENDIENTE:** Estrategia de caché offline para el catálogo de lecciones en `shared_preferences`
- **PENDIENTE:** Política de retención de datos de audio de usuarios

---

## 7. EXPERIENCIA DE USUARIO Y UI

### 7.1 Sistema de diseño

**Nombre:** Deep Space Glassmorphism  
**Paleta de colores:**

| Token | Hex | Uso |
|-------|-----|-----|
| `background` | `#0B1326` | Fondo principal (Deep Space Navy) |
| `surface` | `#171F33` | Tarjetas y contenedores |
| `primaryPurple` | `#B76DFF` | Acciones primarias, highlights de marca |
| `secondaryBlue` | `#0566D9` | Elementos de soporte |
| `tertiaryTeal` | `#00A392` | Éxito, confirmación, corrección correcta |
| `errorRed` | `#93000A` | Errores, correcciones gramaticales |
| `onBackground` | `#DAE2FD` | Texto principal |

**Tipografía:** `GoogleFonts.hankenGrotesk`  
**Efectos:** Blur de 20px en tarjetas `GlassCard`, glow orbs decorativos en fondos, `CyberManhwaBackground` como fondo animado  
**Iconografía:** `CupertinoIcons` + `MaterialIcons`  
**Animaciones:** `flutter_animate` para micro-animaciones, `lottie` para animaciones complejas, `shimmer` para estados de carga

### 7.2 Pantallas y su propósito

#### 1. `/` — WelcomeScreen
- **Propósito:** Punto de entrada. Auth con email/password o Google Sign-In
- **Elementos UI:** Logo animado, campo email, campo password, botón Google, toggle modo registro/login
- **Estado vacío:** N/A (siempre visible)
- **Estado de error:** "Email o contraseña incorrectos", "Error de conexión"
- **Acción primaria:** Iniciar sesión
- **Acción secundaria:** Registrarse / Recuperar contraseña

#### 2. `/onboarding` — OnboardingScreen
- **Propósito:** Configuración inicial: idioma a aprender, nivel CEFR autopercibido, intereses de práctica
- **Elementos UI:** Stepper multi-paso, selector de idioma (emojis banderas), selector de nivel CEFR (tarjetas descriptivas), checkboxes de intereses, botón "Comenzar"
- **Estado de carga:** Guardando perfil en Supabase
- **Acción primaria:** Continuar al siguiente paso

#### 3. `/home` — DashboardScreen (3 tabs)
- **Tab 0 — Inicio:** Saludo personalizado, XP + racha, lección recomendada hero, hub de lecciones recomendadas, historial de lecciones completadas, botón flotante "Hablar Ahora"
- **Tab 1 — Progreso:** Radar chart 5D (Fluidez/Vocabulario/Fonética/Gramática/Metas), heatmap de práctica 28 días, gráfico de tendencias de fluidez 14 días
- **Tab 2 — Hunter Status:** Gamificación avanzada (Daily Quests, League Leaderboard, rango de cazador)
- **Elementos comunes:** Bottom navigation, avatar + nombre usuario, badge nivel CEFR
- **Estado vacío:** Datos mock/fallback si no hay historial
- **Estado de carga:** Shimmer en todas las tarjetas

#### 4. `/conversation` — ConversationScreen
- **Propósito:** Pantalla principal de práctica. Integra voz, texto, misiones y correcciones
- **Elementos UI:**
  - Header con nombre del escenario + botón brújula 🧭 (Compass/Misiones)
  - Área de mensajes en burbujas (user izquierda, assistant derecha)
  - Barra inferior: botón "Hablar" (hold-to-talk), botón teclado, botón de tópicos
  - `LiveGoalsTrackerBar`: mini-barra con las metas evaluadas en tiempo real
  - `VoiceWaveformVisualizer`: animación de onda de audio al grabar
  - `DraggableMonsterWidget`: mascota IA interactiva y arrastrable
  - `ManaMeterWidget`: indicador de uso de sesión (mana)
  - Modal de misiones (Compass 🧭): lista de 5 metas + 10 frases útiles
  - Blind Listening mode: modo de solo escuchar (oculta el texto para focus)
  - Topics picker: lista scrollable de 20 tópicos temáticos
- **Estado de grabación:** Onda visualizada + fondo pulsante
- **Estado de procesamiento:** Spinner sutil
- **Estado de reproducción:** Icono de altavoz activo
- **Estado de error:** Snackbar con mensaje de error

#### 5. `/level-exam` — LevelExamScreen
- **Propósito:** Examen CEFR conversacional con IA para determinar nivel real del usuario
- **Parámetro:** `?level=A1` — evalúa el nivel especificado
- **Elementos UI:** Pantalla similar a ConversationScreen en modo examen

#### 6. `/summary` — SessionSummaryScreen
- **Propósito:** Resumen post-sesión con métricas de la conversación completada
- **Elementos UI:** Score de fluidez, palabras nuevas aprendidas, metas completadas, botones "Practicar de nuevo" / "Volver al dashboard"

#### 7. `/profile` — ProfileScreen
- **Propósito:** Perfil público del usuario con estadísticas y logros
- **Elementos UI:** Avatar, nombre, nivel CEFR, estadísticas (total minutos, racha, XP), lista de logros desbloqueados

#### 8. `/profile-edit` — ProfileEditScreen
- **Propósito:** Edición de datos del perfil (nombre, avatar, idioma nativo)
- **Elementos UI:** Campo nombre, selector avatar/foto, formulario de datos

#### 9. `/settings` — SettingsScreen
- **Propósito:** Configuración de preferencias de aprendizaje
- **Elementos UI:** Selector de nivel de corrección (gentle/balanced/strict), selector de personalidad del tutor, meta diaria de minutos, toggle de notificaciones

#### 10. `/paywall` — PaywallScreen
- **Propósito:** Presentación de planes PRO con call-to-action de suscripción
- **Elementos UI:** Comparativa Free vs PRO, precio mensual/anual, botón de compra, lista de features PRO

#### 11. `/chat-rooms` — ChatRoomsScreen
- **Propósito:** Lista de salas de voz grupales disponibles
- **Elementos UI:** Lista de salas activas con participantes, niveles y temas, botón crear sala

#### 12. `/voice-room` — VoiceRoomScreen
- **Propósito:** Sala de voz activa con múltiples participantes
- **Parámetro:** `?roomId=xyz`

### 7.3 Componentes reutilizables identificados

| Componente | Ubicación | Uso |
|-----------|-----------|-----|
| `GlassCard` | `core/widgets/glass_card.dart` | Contenedor translúcido base |
| `CyberManhwaBackground` | `core/widgets/cyber_manhwa_background.dart` | Fondo animado contextual |
| `DraggableMonsterWidget` | `core/widgets/draggable_monster_widget.dart` | Mascota IA flotante |
| `ManaMeterWidget` | `core/widgets/mana_meter_widget.dart` | Indicador de uso de sesión |
| `VoiceWaveformVisualizer` | `conversation/widgets/` | Visualizador de audio |
| `LiveGoalsTrackerBar` | `conversation/widgets/` | Tracker de metas en vivo |
| `NextRecommendedLessonHero` | `dashboard/widgets/` | Hero card de lección recomendada |
| `LearningPathRoadmap` | `dashboard/widgets/` | Mapa de ruta de aprendizaje |
| `SrsFlashcardModal` | `vocabulary/widgets/` | Modal de tarjetas SRS |
| `DailyQuestsWidget` | `dashboard/widgets/` | Misiones diarias |
| `LeagueLeaderboardWidget` | `dashboard/widgets/` | Tabla de clasificación |

### 7.4 Patrones de navegación

```
WelcomeScreen
    → (si nuevo) OnboardingScreen → DashboardScreen
    → (si existente) DashboardScreen

DashboardScreen
    → LessonCard.tap → ConversationScreen(scenarioId)
    → "Hablar Ahora" → ConversationScreen(null)
    → ProfileButton → ProfileScreen → ProfileEditScreen
    → SettingsButton → SettingsScreen
    → PremiumBadge → PaywallScreen
    → ChatRooms → ChatRoomsScreen → VoiceRoomScreen

ConversationScreen
    → (al terminar) → SessionSummaryScreen → DashboardScreen
```

---

## 8. REQUERIMIENTOS PARA IA DE DISEÑO

### 8.1 Instrucciones para Stitch u otra IA de diseño

**Sistema de diseño base:**
- Tema: **Dark Mode obligatorio** (nunca light mode en esta app)
- Estética: **Deep Space Glassmorphism** — fondos oscuros navy con tarjetas de vidrio translúcido
- Fondo: `#0B1326` (navy profundo), superficies: `rgba(23, 31, 51, 0.85)` con `backdrop-filter: blur(20px)`
- Acentos: Electric Purple `#B76DFF`, Glacial Blue `#0566D9`, Neon Teal `#00A392`
- Bordes: `1px solid rgba(183, 109, 255, 0.3)` — sutilmente iluminados
- Texto: `#DAE2FD` (casi blanco con tono azulado)
- Tipografía: **Hanken Grotesk** (400/500/600/700) — sans-serif moderna y legible
- Iconos: Estilo flat/outlined con grosor de trazo fino

**Pantallas prioritarias para prototipado (en orden):**

1. **ConversationScreen** — La pantalla más crítica. Incluir:
   - Área de chat con burbujas de usuario (izquierda, azul/teal) y asistente (derecha, purple glass)
   - Botón central "Hablar" grande con estado pulsante y efecto de onda al grabar
   - Barra de metas en tiempo real (3–5 chips con checkmark y progress)
   - Header con título del escenario y botón brújula 🧭
   - Panel lateral deslizable de tópicos

2. **DashboardScreen** — Pantalla home. Incluir:
   - Saludo personalizado + streak + nivel CEFR en chips
   - Hero card de lección recomendada con imagen/ícono, nivel badge y botón "Iniciar"
   - Grilla de lecciones recomendadas (2–3 columnas)
   - Bottom navigation con 3 tabs (Inicio, Progreso, Hunter)

3. **SessionSummaryScreen** — Pantalla de resultados. Incluir:
   - Score circular grande de fluidez
   - Lista de metas completadas (checkmarks verdes)
   - Palabras nuevas aprendidas (chips de vocabulario)
   - Dos CTAs: "Repetir" y "Dashboard"

4. **PaywallScreen** — Conversión. Incluir:
   - Comparativa Free vs PRO en tabla visual
   - Precio en tipografía grande
   - CTA principal "Activar PRO" con efecto glow

**Jerarquía de información (prioridad visual):**
1. Acción principal actual (botón Hablar / botón CTA)
2. Contexto de la lección/escenario (título, objetivo)
3. Progreso en tiempo real (metas, XP, racha)
4. Historial y estadísticas (secundario, menor peso visual)

**Elementos consistentes entre pantallas:**
- Fondo `CyberManhwa` o gradient navy oscuro
- `GlassCard` como contenedor universal (border-radius: 16px, blur: 20px)
- Bottom navigation con 3 ítems en DashboardScreen
- Header con back button y título centrado en pantallas de detalle
- Glow orbs decorativos púrpura/teal en esquinas del fondo

**Tono visual:**
- Premium, futurista, gaming-tech pero educativo
- Inspirado en juegos como Duolingo (gamificación) pero con estética de manhwa/cyberpunk
- Sensación de "herramienta profesional" para adultos, no infantil

---

## 9. RIESGOS, DEPENDENCIAS Y LIMITACIONES

### 9.1 Riesgos de negocio

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|-----------|
| Agotamiento de cuota API Groq en producción | Media | Alto | Implementar balanceo y rotación de API keys; alertas por consumo |
| Cambio de precios de DeepSeek | Media | Alto | Preparar fallback a Groq LLaMA o GPT-4o mini |
| Competidor (Duolingo) lanza voz conversacional | Alta | Alto | Acelerar diferenciadores: biometría, avatares, B2B |
| Ingresos insuficientes para cubrir costos de API | Media | Crítico | Definir límites de uso en plan gratuito |

### 9.2 Riesgos técnicos

| Riesgo | Impacto | Estado |
|--------|---------|--------|
| API keys hardcodeadas en código fuente (visible en decompilación APK) | Crítico | **Sin resolver** |
| Sin rate limiting del lado del cliente (usuario puede abusar de APIs) | Alto | Partial (tabla `rate_limiting` en DB pero no aplicada en cliente) |
| Crecimiento de base de datos sin límites (mensajes, audio_logs) | Medio | Sin política definida |
| Escenarios duplicados en Supabase (migración ejecutada 2 veces) | Medio | Resuelto en PLAN_DE_IMPLEMENTACION |
| Tabla `achievements` vacía en producción | Medio | Resuelto en PLAN_DE_IMPLEMENTACION |
| Sin modo offline | Medio | Aceptado como limitación conocida |

### 9.3 Dependencias externas críticas

| Servicio | URL | Riesgo si falla |
|---------|-----|----------------|
| Supabase | `sipiumfdpvnszthykyog.supabase.co` | App no funciona (Auth + DB) |
| Groq Cloud | `api.groq.com/openai/v1/audio/transcriptions` | Sin STT de voz; solo modo texto |
| DeepSeek AI | `api.deepseek.com/v1/chat/completions` | Sin respuestas de IA |
| Google Fonts CDN | — | Tipografía fallback al sistema |
| Google Sign-In | — | Solo autenticación por email funciona |

### 9.4 Información faltante o pendiente de definición

- **Pendiente:** Implementación real de pagos (RevenueCat/Stripe referenciados en schema pero sin código en app)
- **Pendiente:** Flujo completo de notificaciones push
- **Pendiente:** Lógica de análisis fonémico profundo (tabla `pronunciation_assessments` existe pero no hay flujo de llenado)
- **Pendiente:** Leaderboard real multi-usuario (actualmente datos mock)
- **Pendiente:** Sistema de chat en tiempo real para salas grupales (WebSocket declarado pero lógica de negocio no documentada)
- **Pendiente:** Política de privacidad y manejo de grabaciones de voz
- **Pendiente:** Configuración de producción para Web Admin (actualmente sin auth de admin)

---

## 10. RECOMENDACIONES

### 10.1 Qué construir primero
1. **Mover las API keys a variables de entorno seguras** (riesgo crítico de seguridad)
2. **Implementar rate limiting del cliente** para evitar abuso de APIs en plan gratuito
3. **Completar el paywall** con pasarela de pagos real (RevenueCat)
4. **Definir límites del plan gratuito** (minutos/día, conversaciones/semana)
5. **Agregar análisis fonémico** real (diferenciador clave vs. competidores)

### 10.2 Qué documentar mejor
- El sistema prompt completo del LLM para cada nivel CEFR (actualmente embebido en `conversation_providers.dart`)
- Los criterios exactos de evaluación de metas por escenario
- La política de renovación de rachas diarias

### 10.3 Qué decisiones conviene cerrar pronto
- Proveedor de pagos (RevenueCat vs Stripe nativo)
- Política de uso del plan gratuito (límites concretos)
- Si el TTS debe ser on-device o migrar a ElevenLabs/Google Cloud para voz más natural

### 10.4 Qué partes conviene desacoplar
- El `LessonCatalog` local debe ser la única fuente de verdad O Supabase debe serlo; actualmente hay duplicación con riesgo de inconsistencia
- El sistema prompt del LLM debería estar en Supabase para modificación sin release de app

### 10.5 Qué partes conviene reutilizar
- `GlassCard` — cualquier nuevo componente de card debe usar este widget
- `CyberManhwaBackground` — no crear fondos nuevos, usar modos del enum existente
- El patrón `try-catch` con `AsyncValue` de Riverpod — replicar en todos los nuevos providers

### 10.6 Qué pantallas conviene prototipar primero
1. ConversationScreen (core de la propuesta de valor)
2. DashboardScreen Tab Progreso (diferenciador analytics)
3. SessionSummaryScreen (momento de satisfacción del usuario)
4. PaywallScreen (impacto directo en revenue)

### 10.7 Qué convertir en especificación para otra IA
- El catálogo de lecciones por nivel CEFR (→ especificación estructurada para que otra IA genere más lecciones)
- El sistema prompt del tutor IA por nivel (→ especificación para fine-tuning o prompt engineering)
- Las metas de cada escenario (→ especificación para generar nuevos escenarios automáticamente)

---

## 11. GLOSARIO

| Término | Definición |
|---------|-----------|
| **CEFR** | Marco Común Europeo de Referencia para las Lenguas. Escala: A1 (principiante) → C2 (maestría) |
| **STT** | Speech-to-Text. Conversión de audio de voz a texto transcrito |
| **TTS** | Text-to-Speech. Síntesis de voz a partir de texto |
| **LLM** | Large Language Model. Modelo de IA que genera texto (DeepSeek en este caso) |
| **SSE** | Server-Sent Events. Protocolo para streaming de respuestas del LLM |
| **VAD** | Voice Activity Detection. Detección automática de fin de habla por silencio |
| **WPM** | Words Per Minute. Velocidad de habla medida en palabras por minuto |
| **SRS** | Spaced Repetition System. Algoritmo SM-2 para repaso óptimo de vocabulario |
| **XP** | Experience Points. Puntos de experiencia del sistema de gamificación |
| **Groq Cloud** | Proveedor de inferencia ultra-rápida de LLMs y Whisper STT |
| **DeepSeek** | Modelo LLM open-source de alto rendimiento y bajo costo |
| **Supabase** | Backend-as-a-Service con Postgres, Auth y Realtime |
| **RLS** | Row Level Security. Políticas de seguridad a nivel de fila en Postgres |
| **Riverpod** | Framework de gestión de estado reactivo para Flutter |
| **Freezed** | Generador de código para clases inmutables en Dart |
| **GlassCard** | Componente base de UI del design system con efecto glassmorphism |
| **Roleplay** | Juego de rol conversacional: el usuario asume un papel y practica una situación |
| **Speech DNA** | Nombre interno del análisis biométrico del habla (WPM, claridad fonética) |
| **Hunter Status** | Tab de gamificación avanzada en el dashboard (rango de cazador) |
| **Compass 🧭** | Modal de misiones en ConversationScreen que muestra las 5 metas de la lección |
| **Hold-to-Talk** | Modo de grabación que captura audio mientras el usuario mantiene presionado el botón |
| **Web Admin** | Panel de administración React/Vite para gestión de contenido de la plataforma |
| **correction_style** | Nivel de intrusividad del corrector: `gentle`, `balanced`, `strict` |
| **LessonCatalog** | Catálogo estático local de lecciones con toda la estructura de escenarios |
| **ScenarioGoalItem** | Meta individual de un escenario con keywords de evaluación y frase ejemplo |
| **UsefulPhraseItem** | Frase útil bilingüe (inglés/español) para el escenario activo |
| **Freemium** | Modelo de negocio con capa gratuita limitada y capa PRO de pago |
| **TTFT** | Time To First Token. Latencia hasta el primer token de respuesta del LLM |

---

## 12. FUENTE DE VERDAD PARA FUTURAS IAs

### Lo que DEBE saber cualquier IA antes de continuar este proyecto:

1. **El proyecto es Flutter** (Dart 3.11.5 / Flutter 3.29.0). Todo el código mobile está en `lib/`. El admin web es React en `web_admin/`.
2. **El design system se llama "Deep Space Glassmorphism"**: fondo `#0B1326`, tarjetas `GlassCard`, acento principal `#B76DFF`. NO crear UI con otros estilos.
3. **La gestión de estado es Riverpod**: `StateNotifierProvider`, `FutureProvider.autoDispose`, `StateProvider`. No usar `setState()` para lógica de negocio.
4. **El catálogo de lecciones está en dos lugares**: `LessonCatalog` (local, Dart) y tabla `scenarios` (Supabase). La app intenta sincronizar al iniciar sesión.
5. **El pipeline de voz es**: record → Groq STT → DeepSeek LLM → flutter_tts. No alterar este flujo sin razón crítica.
6. **Las metas se evalúan por keyword matching**, no por IA. La función `isSatisfiedBy(userText)` en `ScenarioGoalItem` hace búsqueda de substrings.
7. **Las API keys están en `ApiConstants`** y deben inyectarse via `--dart-define` en producción. Los valores default son para desarrollo local únicamente.
8. **Cada pantalla importante tiene un Provider Riverpod** que maneja su estado. Revisar `dashboard_providers.dart`, `conversation_providers.dart`, `auth_providers.dart`.
9. **El sistema de logros (`achievements`)** existe en la DB pero el seed puede no haberse ejecutado. Verificar con `SELECT COUNT(*) FROM achievements`.
10. **El Web Admin** (React/Vite en `web_admin/src/pages/`) tiene 6 páginas: Overview, Lessons, CEFR Levels, Users, Subscription Plans, AI Settings.

### Lo que NO debe asumir:
- ❌ No asumir que la app tiene pagos implementados (RevenueCat está en el schema pero no integrado en el cliente)
- ❌ No asumir que el leaderboard tiene datos reales de otros usuarios (actualmente mock)
- ❌ No asumir que la tabla `pronunciation_assessments` tiene datos (no hay flujo de llenado implementado)
- ❌ No asumir que el Web Admin tiene autenticación de administrador (acceso directo sin login)
- ❌ No asumir que `daily_fluency_stats` tiene datos si el usuario es nuevo
- ❌ No asumir que todos los niveles CEFR (A1–C2) están poblados en DB sin ejecutar las migraciones de corrección

### Lo que depende de negocio (no cambiar sin aprobación):
- Los límites del plan gratuito (no definidos aún)
- El precio del plan PRO
- La política de privacidad de grabaciones de voz
- Los idiomas prioritarios a soportar

### Lo que depende de arquitectura (no cambiar sin análisis):
- La elección de Groq para STT (implica latencia, costo y calidad)
- La elección de DeepSeek para LLM (implica capacidades del modelo y costo)
- La estructura de `ConversationState` (cambios rompen el flujo de mensajes)
- El patrón de persistencia en Supabase para conversaciones con scenarioId

### Lo que depende de UX/UI:
- La posición y comportamiento del botón de grabación
- El diseño del modal de misiones (Compass)
- La experiencia del paywall

### Preguntas que una IA debe hacer antes de generar código:
1. ¿El cambio afecta la latencia del pipeline de voz? (< 1s es crítico)
2. ¿El cambio modifica `ConversationState`? → Verificar que `ConversationNotifier` lo maneje
3. ¿El cambio agrega una nueva pantalla? → Registrar la ruta en `router.dart`
4. ¿El cambio agrega datos a Supabase? → Verificar que la política RLS permita el acceso
5. ¿El cambio usa nuevas API keys o servicios externos? → Documentar en `ApiConstants`
6. ¿El cambio agrega una lección? → Agregar en `LessonCatalog.catalog` con todos los campos requeridos y 5 goals con keywords
7. ¿El cambio modifica el design system? → Solo modificar `AppColors` o `AppTheme`, no estilos hardcoded

---

## RESUMEN PARA IA FUTURA

> Este bloque es de lectura rápida para que cualquier IA pueda orientarse en < 2 minutos.

**¿Qué es el sistema?**  
TutorSaas es una app mobile Flutter (Android/iOS) de aprendizaje conversacional de idiomas con IA. El usuario habla (o escribe) en inglés, un modelo de IA le responde y corrige sus errores en tiempo real, con latencia total < 1 segundo. También tiene un panel de administración web (React) para gestión de contenido.

**¿Qué problema resuelve?**  
La "barrera del habla" en el aprendizaje de idiomas: falta de práctica conversacional asequible, flexible y sin juicio social. Sustituye a los tutores humanos costosos con un tutor IA empático, disponible 24/7.

**¿Qué arquitectura usa?**  
Clean Architecture con Riverpod (estado), go_router (navegación), Supabase (BaaS: DB Postgres + Auth + RLS), Groq Cloud Whisper (STT), DeepSeek Chat (LLM SSE streaming), flutter_tts (TTS on-device). Design system: Deep Space Glassmorphism con fondo `#0B1326` y acentos `#B76DFF`.

**¿Qué reglas son críticas?**  
1. Pipeline de voz: record → Groq → DeepSeek → TTS. No romper la cadena.  
2. Latencia total DEBE ser < 1 segundo.  
3. El botón de voz es Hold-to-Talk (NO speech_to_text nativo del SO).  
4. Las metas se evalúan por keyword matching sobre el texto del usuario.  
5. Las API keys se inyectan via `--dart-define`, nunca hardcodeadas en producción.  
6. Todo componente nuevo de UI usa `GlassCard` como base y el pallete de `AppColors`.

**¿Qué integraciones existen?**  
- Supabase: `sipiumfdpvnszthykyog.supabase.co` (DB, Auth, RLS)  
- Groq Cloud: `api.groq.com/openai/v1/audio/transcriptions` (Whisper STT)  
- DeepSeek: `api.deepseek.com/v1/chat/completions` (LLM conversacional)  
- Google Sign-In (OAuth social)  
- flutter_tts (TTS on-device, sin API externa)

**¿Qué pantallas o módulos UI son clave?**  
1. `ConversationScreen` — core de la experiencia, 1129 líneas  
2. `DashboardScreen` — home, 3 tabs, 1990 líneas  
3. `WelcomeScreen` — auth entry point  
4. `OnboardingScreen` — configuración inicial  
5. `SessionSummaryScreen` — post-sesión  
6. `PaywallScreen` — conversión a PRO

**¿Qué riesgos y dependencias hay?**  
- Riesgo crítico: API keys hardcodeadas en código fuente (seguridad)  
- Riesgo alto: sin rate limiting cliente-side (abuso de APIs en plan gratuito)  
- Riesgo alto: sin pasarela de pagos implementada (RevenueCat en schema, no en código)  
- Dependencia total de Groq y DeepSeek: si fallan, la app no funciona  
- Deuda técnica: tabla `achievements` puede estar vacía en producción; migraciones de niveles CEFR deben ejecutarse

**¿Qué cosas no deben asumirse?**  
- Que los pagos funcionan (no implementados en cliente)  
- Que el leaderboard tiene datos reales (mock)  
- Que todos los niveles CEFR están en la DB (requiere migración manual)  
- Que el Web Admin tiene autenticación (acceso directo, sin login)  
- Que la tabla `pronunciation_assessments` tiene datos (sin flujo de llenado)
