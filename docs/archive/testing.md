# Testing — TutorSaas

## Enfoque General

Testing piramidal con énfasis en:
- Tests unitarios para lógica de negocio (modelos, providers, repositorios)
- Widget tests para componentes críticos de UI
- Benchmarks de latencia para el pipeline de voz
- Tests de integración limitados (dependencias externas)

## Tests Actuales

### `test/latency_benchmark_test.dart`
Test de benchmark que verifica el pipeline de voz completo con métricas simuladas:
- Verifica 5 pasos: Audio Capture, STT, LLM TTFT, TTS, Total Roundtrip
- Valida que cada paso retorna éxito
- Verifica latencia total < 1350ms

### `test/widget_test.dart`
Widget test básico del proyecto.

### `test/overflow_test.dart`
Test de overflow para verificar comportamiento de layout.

## Framework

- **Test runner:** `flutter_test` (framework estándar de Flutter)
- **Mocking:** No hay mocking framework definido aún
- **Cobertura:** Sin métricas de cobertura configuradas

## Comandos

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar test específico
flutter test test/latency_benchmark_test.dart

# Ejecutar con coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Áreas Críticas para Testing

### Pipeline de Voz (Prioridad Máxima)
- Tiempo de cada etapa del pipeline
- Manejo de errores en STT (Groq falla)
- Manejo de errores en LLM (DeepSeek timeout)
- TTS sin conexión
- Hold-to-Talk gestos

### Providers Riverpod
- ConversationNotifier: estados idle→recording→processing→playing
- DashboardRepository: filtrado por language_id y nivel
- Auth providers: login, registro, Google OAuth

### Modelos Freezed
- ConversationState: serialización/deserialización
- UserSettings: valores por defecto, fromJson/toJson
- LessonData: catálogo completo, getLessonById

### Navegación
- GoRouter: todas las rutas registradas
- Parámetros de query: scenarioId, scenarioTitle, level

## Tests Pendientes

- [ ] **LessonCatalog tests** — getLessonById con null, ids válidos, catálogo completo
- [ ] **DashboardRepository tests** — filtrado por language_id con mocks de Supabase
- [ ] **ConversationNotifier tests** — ciclo de estados, manejo de errores
- [ ] **Widget tests** — GlassCard, SystemWindow, SystemChatBubble
- [ ] **Integration tests** — flujo completo onboarding→dashboard→conversation→summary
