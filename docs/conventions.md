# Convenciones de Código — TutorSaas

## Naming

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| **Archivos** | `snake_case` | `conversation_screen.dart`, `api_constants.dart` |
| **Clases** | `PascalCase` | `ConversationScreen`, `AppColors`, `GlassCard` |
| **Funciones/Variables** | `camelCase` | `getLessonById()`, `currentMana` |
| **Privado** | `_camelCase` | `_processTranscription()`, `_particles` |
| **Providers** | `camelCase` + `Provider` suffix | `conversationProvider`, `userSettingsProvider` |
| **Constantes** | `camelCase` | `manaCyan`, `supabaseUrl` |
| **Widgets State** | `_ClassState` | `_SystemWindowState`, `_DashboardScreenState` |
| **Archivos de test** | `*_test.dart` | `latency_benchmark_test.dart` |

## Dart/Flutter

- Usar `const` constructors siempre que sea posible
- NO usar `setState` para lógica de negocio — usar Riverpod providers
- Todas las llamadas API envueltas en `try-catch` con `debugPrint` logging
- Usar `AsyncValue` para estados loading/error en providers
- Nuevos widgets: extender `GlassCard` para contenedores flotantes
- Nuevas screens: registrar ruta en `router.dart`

## Riverpod Patterns

| Tipo de Provider | Cuándo Usarlo | Ejemplos |
|-----------------|---------------|----------|
| `StateNotifierProvider` | Estado complejo con lógica de negocio | `ConversationNotifier`, `UserSettingsNotifier` |
| `FutureProvider.autoDispose` | Data fetching asíncrono | Perfiles, lecciones, stats |
| `StateProvider` | Estado simple (boolean, string) | Toggle modo, pestaña activa |

**Reglas:**
- Invalidar providers después de mutaciones para refrescar UI automáticamente
- Providers auto-dispose para limpiar recursos cuando no se usan
- StateNotifierProvider inyecta repositorios via constructor

## Estructura de Archivos

Cada feature sigue Clean Architecture con 3 capas:
```
feature/
  data/
    repositories/       # Implementaciones concretas
    models/             # DTOs
  domain/
    models/             # Freezed models
    repositories/       # Interfaces (abstract)
  presentation/
    providers/          # Riverpod providers
    screens/            # Widgets de pantalla completa
    widgets/            # Widgets específicos del feature
```

## Imports

Orden de imports:
1. `dart:` imports
2. `package:` imports (externos)
3. `package:` imports (internos del proyecto)
4. Imports relativos

Cada grupo separado por línea en blanco.

## Modelos con Freezed

Todos los modelos de dominio usan `freezed` + `json_serializable`:
```dart
@freezed
class ConversationState with _$ConversationState {
  const factory ConversationState({
    @Default([]) List<ConversationMessage> messages,
    @Default(false) bool isRecording,
  }) = _ConversationState;

  factory ConversationState.fromJson(Map<String, dynamic> json) =>
      _$ConversationStateFromJson(json);
}
```

## Manejo de Errores

```dart
try {
  final result = await repository.someMethod();
} catch (e, stack) {
  debugPrint('Error en someMethod: $e');
  ErrorTracker.logError('someMethod failed: $e', stackTrace: stack);
  // Mostrar error al usuario via AsyncValue.error o snackbar
}
```

## Voice Pipeline (NO ALTERAR)

Pipeline fijo: `record AAC/m4a → Groq Whisper STT (language:'en') → DeepSeek SSE streaming → flutter_tts (rate:0.48)`

- **Hold-to-Talk** (NO `speech_to_text` nativo)
- **Goal evaluation**: keyword matching via `isSatisfiedBy()`
- **Persistencia**: solo conversaciones con `scenarioId`; chats libres efímeros

## Git

- Commits en español descriptivo
- Mensajes concisos que expliquen el cambio
- Branches con nombre descriptivo

## Testing

- Tests unitarios en `test/`
- Benchmark de latencia en `test/latency_benchmark_test.dart`
- Mantener cobertura en pipeline de voz

## API Keys

- Nunca hardcodear en producción
- Inyectar via `--dart-define` o `--dart-define-from-file=config.json`
- Valores default en `ApiConstants` solo para desarrollo local

## Theme

- **Dark mode exclusivamente** — no implementar light mode
- **Colores**: definidos en `AppColors` — no usar colores hardcodeados
- **Tipografía**: definida en `AppTheme` usando Google Fonts
- **borderRadius máximo**: 20px (default 4px)
