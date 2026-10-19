# Estrategia de Internacionalización — Dungeon of English

> **Documento:** Julio 2026  
> **Propósito:** Convertir la plataforma en un sistema completamente multilenguaje, escalable y arquitectónicamente preparado para cualquier idioma actual o futuro.

---

## Sumario Ejecutivo

El sistema actual de internacionalización es **insuficiente** para los objetivos globales de la plataforma.

| Dimensión | Estado Actual |
|---|---|
| Cobertura de traducciones | Solo 2 de ~20 pantallas usan `t()` |
| Textos hardcodeados | ~100-120 strings sin traducir |
| Idiomas soportados | 3 (es, en, pt) — pt incompleto |
| Arquitectura | Archivo único, sin tooling, sin interpolación |
| Fallback | Muestra el key si falta traducción |
| Portugués | 31 keys faltantes |

**La arquitectura propuesta resuelve todos estos problemas** separando tres conceptos clave: idioma de UI, idioma de aprendizaje e idioma de conversación IA.

---

## PARTE 1 — Arquitectura Conceptual

### Los 3 Idiomas Independientes

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ARQUITECTURA MULTILENGUAJE                        │
│                                                                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │  IDIOMA UI        │  │  IDIOMA APRENDER │  │  IDIOMA IA        │  │
│  │  (Interface)      │  │  (Learning)      │  │  (Conversation)   │  │
│  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤  │
│  │ • Toda la UI      │  │ • Lecciones      │  │ • Respuestas NPC  │  │
│  │ • Botones         │  │ • Misiones       │  │ • Correcciones    │  │
│  │ • Menús           │  │ • Objetivos      │  │ • Explicaciones   │  │
│  │ • Notificaciones  │  │ • Logros         │  │ • Feedback IA     │  │
│  │ • Errores         │  │ • Vocabulary     │  │ • Speech DNA      │  │
│  │ • HUD             │  │ • Evaluación     │  │ • Coaching        │  │
│  │ • Tienda          │  │ • SRS            │  │                   │  │
│  │                   │  │                   │  │                   │  │
│  │  EJ: Español      │  │  EJ: Inglés       │  │  EJ: Inglés+Esp   │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  │
│                                                                      │
│  Los 3 son INDEPENDIENTES. Cualquier combinación es válida.         │
└─────────────────────────────────────────────────────────────────────┘
```

### Modelo de Datos

```dart
class UserLanguageSettings {
  String uiLanguage;      // 'es', 'en', 'pt', 'fr', 'de', 'ja', 'zh'...
  String learningLanguage; // 'en', 'fr', 'de', 'it', 'pt'...
  String? nativeLanguage;  // Same as uiLanguage by default
  bool aiExplanationsInNative; // true = explica en nativo, false = solo en target
}
```

### Flujo de Traducción

```
WIDGET
  │
  ├── Text hardcodeado? → ❌ Nunca. Siempre usar Tr.of(context, 'key')
  │
  ├── Texto de UI → t('key') → lookup en {uiLanguage}.json
  │
  ├── Texto de misión/lección → t('key') → lookup en {learningLanguage}.json
  │     (el contenido educativo se almacena traducido en DB)
  │
  └── Texto de IA → El prompt recibe {nativeLanguage, learningLanguage}
        → La IA decide en qué idioma responder
```

---

## PARTE 2 — Stack Tecnológico

### Comparativa de Alternativas

| Opción | Ventajas | Desventajas | Veredicto |
|---|---|---|---|
| **Flutter l10n** (.arb) | Nativo, tooling oficial, code generation | Requiere build, no tiene runtime loading dinámico | ✅ **Recomendado** para UI strings |
| **SLang** | Potente, plurales, contexto | Dependencia externa, overhead | ❌ Overkill para el alcance |
| **Custom (estado actual)** | Simple | Sin tooling, sin code gen, errores en runtime | ❌ Descartado |
| **Localizely / Crowdin** | Automatización, colaboración | Costo mensual | ✅ **Recomendado** para gestión |

### Arquitectura Final Recomendada

```
Capa 1: Flutter l10n (.arb) → UI strings traducidas
  • main.arb (es_MX), main_en.arb, main_pt.arb, main_fr.arb, etc.
  • Genera código Dart con tipos seguros (AppLocalizations.of(context)!.hello)
  • Soporta plurales, contexto, interpolación

Capa 2: Flutter i18n JSON dinámico → Contenido educativo
  • Archivos JSON cargados bajo demanda
  • Para misiones, habilidades, descripciones largas
  • Cache en memoria con invalidation

Capa 3: Supabase DB → Catálogos multilenguaje
  • Tablas con soporte de locale column
  • Para contenido generado por IA y contenido dinámico

Capa 4: SharedPreferences → Preferencias del usuario
  • ui_language, learning_language, ai_explanations_in_native
```

---

## PARTE 3 — Cambios en el Frontend

### Nuevo Provider: `UserLanguageSettings`

```dart
@freezed
class UserLanguageSettings {
  String uiLanguage;          // default: 'es'
  String learningLanguage;    // default: 'en'
  bool aiExplanationsInNative; // default: true
}

final userLanguageProvider = StateNotifierProvider<UserLanguageNotifier, UserLanguageSettings>(...);
```

### Conveniencia de Traducción

```dart
// UI Language (interfaz)
t(context, 'key') → AppLocalizations.of(context)!.key

// Learning Language (contenido educativo)
tl(context, 'key') → busca en el JSON del idioma que se aprende

// IA Prompt (para el sistema)
final promptLang = UserLanguageSettings(ui: 'es', learn: 'en', explainInNative: true);
```

### Pantallas a Modificar por Prioridad

| Prioridad | Pantalla | Hardcoded strings | Acción |
|---|---|---|---|
| 🔴 Alta | `settings_screen.dart` | ~30 | Migrar todos los textos a .arb |
| 🔴 Alta | `onboarding_screen.dart` | ~20 | Migrar + agregar selector de idioma UI y learning |
| 🔴 Alta | `chat_rooms_screen.dart` | ~10 | Migrar a .arb |
| 🟠 Media | `voice_room_screen.dart` | ~8 | Migrar a .arb |
| 🟠 Media | `conversation_screen.dart` | ~6 | Migrar a .arb |
| 🟠 Media | `conversation_providers.dart` | ~8 | Migrar mensajes de error |
| 🟡 Baja | `oracle_test_screen.dart` | ~8 | Migrar a .arb |
| 🟡 Baja | `nucleo_arcano_limit_screen.dart` | ~3 | Migrar a .arb |
| 🟢 Futuro | Otras pantallas con <5 strings | Restantes | Migrar progresivamente |

### Widget `Tr` (Nuevo)

```dart
class Tr extends StatelessWidget {
  final String key;
  final Map<String, String>? args; // para interpolación: {name: 'Juan'}
  final TextStyle? style;
  // ...
  @override
  Widget build(BuildContext context) {
    return Text(
      _interpolate(AppLocalizations.of(context)!.translate(key), args),
      style: style,
    );
  }
}

// Uso:
Tr('welcome_message', args: {'name': userName})
// → "Bienvenido, Juan" (es) / "Welcome, Juan" (en)
```

---

## PARTE 4 — Cambios en el Backend

### Servicios y Endpoints

| Servicio | Cambio requerido |
|---|---|
| **Prompts de IA** | Todos los prompts deben recibir `native_language` y `learning_language` como parámetros explícitos |
| **Conversaciones** | Guardar `ui_language` y `learning_language` en cada sesión |
| **Logros** | Nombres y descripciones deben ser localizados (clave + locale) |
| **Misiones** | Título y descripción deben soportar múltiples idiomas |
| **Notificaciones Push** | Enviar con placeholder de locale para que el dispositivo traduzca |

### Estructura de Prompts Rediseñada

```dart
// ANTES (hardcoded):
final systemPrompt = 'You are an AI Language Tutor. Always respond in English.';

// DESPUÉS (parametrizado):
final systemPrompt = '''
  You are an AI Language Tutor for {nativeLanguage} speakers learning {learningLanguage}.
  - UI Language: {uiLanguage}
  - Learning Language: {learningLanguage}
  - Always respond primarily in {learningLanguage}
  - Grammar explanations should be in {nativeLanguage}
  - Correction language: AI mode ({aiExplanationsInNative} ? native : target)
  - Keep responses appropriate for CEFR level {cefrLevel}
''';
```

---

## PARTE 5 — Cambios en la Base de Datos

### Tablas Afectadas

| Tabla | Columna actual | Nueva estrategia |
|---|---|---|
| `scenarios` | `title`, `description`, `main_objective`, `assistant_role`, `user_role` | Mover a tabla de localización |
| `achievements` | `title`, `description` | Mover a tabla de localización |
| `oracle_questions` | `question_text` | Agregar `language_code` (ya existe) |
| `guild_quest_pool` | `title`, `description` | Agregar soporte multilenguaje |
| `cosmetic_catalog` | `name`, `description` | Agregar soporte multilenguaje |
| `subscription_plans` | `name`, `description`, `features` | Mover a tabla de localización |

### Modelo de Localización en DB

```sql
-- Estrategia: Tabla de traducciones genérica
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(100) NOT NULL,  -- 'scenario', 'achievement', 'quest', etc.
    entity_id VARCHAR(100) NOT NULL,    -- ID del registro original
    locale VARCHAR(10) NOT NULL,        -- 'en', 'es', 'pt', 'fr', 'de', etc.
    field_name VARCHAR(100) NOT NULL,   -- 'title', 'description', etc.
    value TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(entity_type, entity_id, locale, field_name)
);
```

```sql
-- O alternativamente: columnas por locale (más simple pero menos escalable)
ALTER TABLE scenarios ADD COLUMN title_es TEXT;
ALTER TABLE scenarios ADD COLUMN title_en TEXT;
ALTER TABLE scenarios ADD COLUMN title_pt TEXT;
ALTER TABLE scenarios ADD COLUMN title_fr TEXT;
ALTER TABLE scenarios ADD COLUMN title_de TEXT;
ALTER TABLE scenarios ADD COLUMN title_it TEXT;
ALTER TABLE scenarios ADD COLUMN title_ja TEXT;
ALTER TABLE scenarios ADD COLUMN title_zh TEXT;
-- ... misma operacion para description, main_objective, etc.
```

**Recomendación:** Usar tabla de traducciones (`translations`) para contenido educativo (escalable, no requiere migración por cada idioma nuevo). Usar columnas por locale solo para tablas pequeñas y estáticas (cosmetic_catalog, subscription_plans).

### Migración de Datos Existente

```sql
-- Mover datos actuales de scenarios a la tabla de traducciones
INSERT INTO translations (entity_type, entity_id, locale, field_name, value)
SELECT 'scenario', id, 'es', 'title', title FROM scenarios WHERE title IS NOT NULL;

INSERT INTO translations (entity_type, entity_id, locale, field_name, value)
SELECT 'scenario', id, 'en', 'title', title FROM scenarios WHERE title IS NOT NULL;

-- Similar para description, main_objective, etc.
```

---

## PARTE 6 — Sistema de IA Rediseñado

### Estructura de Prompt Universal

```
You are an AI Language Tutor.

USER PROFILE:
- Native language: {native_language} (e.g., Spanish)
- Learning language: {learning_language} (e.g., English)
- CEFR Level: {cefr_level}
- UI Language: {ui_language}

RULES:
1. Always respond primarily in {learning_language}.
2. When the user makes a mistake, explain the correction in:
   - {native_language} if correction_style is 'detailed' or 'balanced'
   - {learning_language} if correction_style is 'immersion'
3. Keep vocabulary and grammar complexity appropriate for CEFR level {cefr_level}.
4. If the user writes in {native_language}, gently remind them to use {learning_language}.
5. For open-ended questions, suggest phrases in {learning_language}.

SCENARIO CONTEXT:
{scenario_context}
```

### Tabla de Combinaciones de Idioma

| UI | Aprende | Explicaciones IA | Prompt generado |
|---|---|---|---|
| es | en | en español | `Native:es, Learn:en, Explain:es` |
| en | en | en inglés | `Native:en, Learn:en, Explain:en` |
| pt | en | en portugués | `Native:pt, Learn:en, Explain:pt` |
| fr | en | en francés | `Native:fr, Learn:en, Explain:fr` |
| es | fr | en español | `Native:es, Learn:fr, Explain:es` |
| ja | en | en japonés | `Native:ja, Learn:en, Explain:ja` |
| zh | en | en chino | `Native:zh, Learn:en, Explain:zh` |
| ar | en | en árabe | `Native:ar, Learn:en, Explain:ar` |
| de | en | en alemán | `Native:de, Learn:en, Explain:de` |
| it | en | en italiano | `Native:it, Learn:en, Explain:it` |

---

## PARTE 7 — Soporte RTL

### Pantallas que Requieren Adaptación RTL

| Pantalla | Componente RTL crítico |
|---|---|
| Conversation | Burbujas: orador a la derecha, tutor a la izquierda (invertir en RTL) |
| Guild Hall | Cards: contenido alineado a la derecha |
| Settings | Toggles, sliders: invertir dirección |
| Onboarding | Steps: progreso debe ir de derecha a izquierda |
| Tienda | Grid de items: orden de derecha a izquierda |
| Status Screen | Barras de progreso: deben llenarse de derecha a izquierda |
| Chat Rooms | Lista de salas: alineación derecha |

### Implementación

```dart
// Flutter ya soporta RTL nativamente con Directionality.
// Solo asegurar que:
// 1. MaterialApp tenga supportedLocales con las variantes RTL
// 2. Los widgets personalizados usen TextDirection

MaterialApp(
  supportedLocales: [
    const Locale('es', 'MX'),
    const Locale('en', 'US'),
    const Locale('pt', 'BR'),
    const Locale('fr', 'FR'),
    const Locale('de', 'DE'),
    const Locale('ar', 'SA'), // RTL
    const Locale('he', 'IL'), // RTL
    const Locale('ja', 'JP'),
    const Locale('zh', 'CN'),
  ],
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  localeResolutionCallback: (locale, supportedLocales) {
    // Resolver automáticamente
  },
);
```

---

## PARTE 8 — Archivos .arb (Flutter l10n)

### Estructura Propuesta

```
lib/
  l10n/
    app_es.arb        → UI strings en español
    app_en.arb        → UI strings en inglés
    app_pt.arb        → UI strings en portugués
    app_fr.arb        → UI strings en francés
    app_de.arb        → UI strings en alemán
```

### Ejemplo de archivo .arb

```json
{
  "@@locale": "es",
  "@@info": "Traducciones al español - Dungeon of English",

  "welcome_title": "Aprende hablando",
  "@welcome_title": {
    "description": "Título de la pantalla de bienvenida"
  },

  "xp_earned": "+{amount} XP",
  "@xp_earned": {
    "description": "Recompensa de XP obtenida",
    "placeholders": {
      "amount": { "type": "int" }
    }
  },

  "conversations_remaining": "{count} {count, plural, one{conversación} other{conversaciones}} restantes",
  "@conversations_remaining": {
    "description": "Invocaciones restantes del Oráculo",
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

### Cobertura de Keys por Pantalla

| Pantalla | Keys nuevas | Archivo .arb section |
|---|---|---|
| **Global (HUD, navegación)** | 20 | `nav_*`, `hud_*` |
| **Welcome** | 10 | `welcome_*` |
| **Onboarding** | 30 | `onboarding_*` |
| **Character Creation** | 15 | `character_*` |
| **Oracle Test** | 15 | `oracle_*` |
| **Dashboard** | 25 | `dashboard_*` |
| **Conversation** | 25 | `conversation_*` |
| **Guild Hall** | 20 | `guild_*` |
| **Voice Room** | 20 | `voice_*` |
| **Hunter Status** | 15 | `status_*` |
| **Shop/Paywall** | 15 | `shop_*` |
| **Settings** | 30 | `settings_*` |
| **Errors/System** | 20 | `error_*`, `system_*` |
| **Notifications** | 10 | `notif_*` |
| **Total nuevas keys** | **~270** | |

---

## PARTE 9 — Cache y Rendimiento

### Estrategia de Carga de Traducciones

```
INICIO DE APP
    │
    ▼
┌─────────────────────┐
│ SharedPreferences   │ ← ui_language, learning_language
│ (síncrono, inmediato)│
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ .arb bundle         │ ← Flutter l10n (carga nativa)
│ (incluido en app)    │
│ • Carga instantánea  │
│ • Sin red            │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ JSON dinámico       │ ← Contenido educativo (bajo demanda)
│ (desde Supabase o CDN│
│ • Cache en memoria   │
│ • TTL: 1 hora        │
│ • Invalidación manual │
└─────────────────────┘
```

### Bundles por Idioma

```
l10n/
  app_en.arb       → 3KB (incluido en app bundle)
  app_es.arb       → 3KB (incluido)
  app_pt.arb       → 3KB (incluido)
  app_fr.arb       → 3KB (incluido, descargable)
  app_de.arb       → 3KB (incluido, descargable)
  app_ja.arb       → 3KB (descargable bajo demanda)
  app_zh.arb       → 3KB (descargable bajo demanda)

Idiomas principales (es, en, pt): Siempre en bundle.
Idiomas secundarios (fr, de): Incluidos en bundle por cercanía.
Idiomas terciarios (ja, zh, ar): Descargables bajo demanda.
```

---

## PARTE 10 — Plan de Pruebas

### Pruebas por Tipo

| Tipo | Qué probar | Cobertura |
|---|---|---|
| **Funcional** | Cada `t()` devuelve string correcto para cada locale | 100% de keys |
| **Funcional** | Cambio de idioma en caliente sin perder estado | Todas las pantallas |
| **Funcional** | Los 3 idiomas (UI, aprender, IA) son independientes | Combinaciones |
| **Visual** | Texto no se desborda de contenedores | Alemán, japonés |
| **Visual** | RTL: alineación correcta | Árabe, hebreo |
| **Visual** | Caracteres especiales se renderizan | Chino, japonés, coreano |
| **Rendimiento** | Tiempo de carga de idioma <100ms | Todos los idiomas |
| **IA** | Prompt recibe idiomas correctos | 10 combinaciones |
| **IA** | IA no usa idioma incorrecto | 10 combinaciones |
| **Contenido** | Todas las keys existen en todos los idiomas | 270 keys x N idiomas |

### Automatización

```dart
// Test de cobertura: verificar que toda key en uso existe en todos los .arb
void testTranslationCoverage() {
  final usedKeys = extractUsedKeysFromCodebase();
  for (final locale in ['en', 'es', 'pt', 'fr', 'de']) {
    final translations = loadArb(locale);
    for (final key in usedKeys) {
      assert(translations.containsKey(key), 'Missing key $key in $locale');
    }
  }
}
```

---

## PARTE 11 — Roadmap de Implementación

### Fase 1: Arquitectura (Semana 1-2)

| Tarea | Esfuerzo | Dependencias |
|---|---|---|
| Configurar Flutter l10n (.arb) | 1 día | Ninguna |
| Crear archivos .arb para es, en, pt | 3 días | .arb config |
| Migrar ~50 keys existentes de `app_translations.dart` | 1 día | .arb files |
| Crear `UserLanguageSettings` provider | 1 día | Ninguna |
| Crear widget `Tr` con interpolación | 1 día | Ninguna |
| Agregar selector de idioma UI en onboarding | 2 días | Provider + .arb |

### Fase 2: Frontend (Semana 3-4)

| Tarea | Esfuerzo | Prioridad |
|---|---|---|
| Migrar settings_screen.dart (~30 strings) | 1 día | 🔴 Alta |
| Migrar onboarding_screen.dart (~20 strings) | 1 día | 🔴 Alta |
| Migrar chat_rooms_screen.dart (~10 strings) | 4h | 🔴 Alta |
| Migrar voice_room_screen.dart (~8 strings) | 3h | 🟠 Media |
| Migrar conversation_screen.dart (~6 strings) | 2h | 🟠 Media |
| Migrar conversation_providers.dart (~8 strings) | 2h | 🟠 Media |
| Migrar oracle_test_screen.dart (~8 strings) | 2h | 🟡 Baja |
| Migrar nucleo_arcano_limit_screen.dart (~3 strings) | 1h | 🟡 Baja |
| Migrar character_creation_wizard.dart (~4 strings) | 1h | 🟡 Baja |
| Migrar hunter_license_screen.dart (~5 strings) | 1h | 🟡 Baja |
| Migrar dashboard restante (~3 strings) | 1h | 🟡 Baja |
| Migrar profile_screen, profile_edit, session_summary (~8 strings) | 2h | 🟡 Baja |

### Fase 3: Backend e IA (Semana 5)

| Tarea | Esfuerzo |
|---|---|
| Rediseñar prompts con `native_language` y `learning_language` | 1 día |
| Agregar `ui_language` y `learning_language` a sesiones de conversación | 1 día |
| Actualizar `conversation_providers.dart` para pasar ambos idiomas | 2 días |
| Actualizar `conversation_repository_impl.dart` para enviar idiomas | 1 día |

### Fase 4: Base de Datos (Semana 6)

| Tarea | Esfuerzo |
|---|---|
| Crear tabla `translations` | 1 día |
| Migrar datos existentes de scenarios a translations | 1 día |
| Migrar achievements, guild_quest_pool, cosmetic_catalog | 2 días |
| Migrar subscription_plans y oracle_questions | 1 día |
| Crear RPC functions para consultas por locale | 1 día |

### Fase 5: Migración de Contenido (Semana 7)

| Tarea | Esfuerzo |
|---|---|
| Agregar contenido en portugués (completar 31 keys faltantes) | 1 día |
| Agregar contenido en francés (nuevo) | 3 días |
| Agregar contenido en alemán (nuevo) | 3 días |
| Configurar Crowdin / Localizely para traducción colaborativa | 1 día |

### Fase 6: Pruebas (Semana 8)

| Tarea | Esfuerzo |
|---|---|
| Test de cobertura: 100% keys en todos los idiomas | 1 día |
| Test visual: overflow, RTL, caracteres especiales | 2 días |
| Test de IA: 10 combinaciones de idioma | 1 día |
| Test de rendimiento: cambio de idioma <100ms | 1 día |
| Test de regresión: todas las pantallas | 2 días |

### Fase 7: Nuevos Idiomas (Semana 9+)

| Tarea | Esfuerzo |
|---|---|
| Agregar japonés | 2 días |
| Agregar chino simplificado | 2 días |
| Agregar coreano | 2 días |
| Agregar árabe (RTL) | 3 días |
| Agregar hindi | 2 días |

---

## PARTE 12 — Cómo Agregar un Nuevo Idioma (Guía)

### Proceso para agregar, ej: Francés

```yaml
1. Crear archivo: lib/l10n/app_fr.arb
   - Copiar app_en.arb como plantilla
   - Traducir todos los valores
   
2. Registrar en pubspec.yaml:
   flutter:
     generate: true
   
3. Registrar en MaterialApp:
   supportedLocales: [
     ...,
     const Locale('fr', 'FR'),
   ]

4. Agregar en UserLanguageSettings:
   - Soporte para 'fr' en el provider

5. (Opcional) Agregar a la DB:
   - Traducciones para scenarios y achievements en tabla translations
   - Prompt de IA incluye 'fr'

6. SIN modificar:
   - Ninguna pantalla
   - Ningún widget
   - Ninguna lógica de negocio
   - Ningún prompt base (solo recibe parámetros)
```

---

## Resumen del Impacto Total

| Capa | Cambios | Archivos afectados |
|---|---|---|
| **Frontend** | Migrar ~120 hardcoded strings a .arb + agregar provider | ~20 archivos |
| **Backend** | Rediseñar prompts, agregar idiomas a sesiones | 3 archivos |
| **DB** | Nueva tabla translations + migración de datos | 6 tablas |
| **IA** | Prompts parametrizados nativo/aprender | 2 archivos |
| **Nuevos** | .arb files, Tr widget, UserLanguageSettings provider | ~10 archivos |

### Esfuerzo Total Estimado

| Fase | Duración | Personas |
|---|---|---|
| F1: Arquitectura | 1 semana | 1 senior |
| F2: Frontend | 2 semanas | 1 senior + 1 mid |
| F3: Backend+IA | 1 semana | 1 senior |
| F4: DB | 1 semana | 1 senior |
| F5: Contenido | 1 semana | 1 traductor por idioma |
| F6: Pruebas | 1 semana | 1 QA |
| **Total** | **~7 semanas** | 2-3 personas |

### Regla de Oro

> *Cada vez que un desarrollador escribe un string visible en la UI, debe usar el sistema de traducción. No hay excepciones. No hay "esto es temporal" ni "solo esta pantalla".*
