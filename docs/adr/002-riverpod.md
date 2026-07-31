# ADR-002: Riverpod para Gestión de Estado

## Estado
Aceptado

## Contexto
La aplicación Flutter necesita un sistema de gestión de estado que maneje:
- Estado complejo del pipeline de voz (recording→processing→playing)
- Data fetching asíncrono de Supabase
- Estado global de autenticación
- Preferencias de usuario
- Invalidación y refresco de datos

## Opciones Consideradas
1. **Riverpod** — `flutter_riverpod` + `hooks_riverpod` con `StateNotifierProvider`, `FutureProvider.autoDispose`, `StateProvider`
2. **Provider (legacy)** — El predecesor, sin `autoDispose` ni compilación segura
3. **BLoC** — Patrón event/state, boilerplate intensivo
4. **GetX** — Todo-en-uno, pero criticado por falta de estructura y testing difícil
5. **MobX** — Reactivo, pero requiere code generation y es verboso
6. **setState + InheritedWidget** — No escala para estado complejo

## Decisión
Se adopta **Riverpod** con los siguientes patrones:
- `StateNotifierProvider` para estado complejo (ConversationNotifier, UserSettingsNotifier)
- `FutureProvider.autoDispose` para data fetching asíncrono
- `StateProvider` para estado simple (booleanos, strings)
- Invalidación de providers después de mutaciones para refrescar UI

## Consecuencias
**Positivas:**
- Compilación segura (no runtime errors como Provider)
- `autoDispose` integrado para limpieza de recursos
- Providers globales sin necesidad de BuildContext
- Fácil testing (sobrescribir providers)
- Mejor rendimiento que BLoC para casos de uso simples
- Comunidad activa y buena integración con Flutter

**Negativas:**
- Curva de aprendizaje para patrones avanzados (family, .autoDispose)
- Code generation opcional pero recomendada (riverpod_generator)
- Menos adopción que BLoC en empresas grandes

## Referencias
- [Riverpod Documentation](https://riverpod.dev/)
- [flutter_riverpod pub.dev](https://pub.dev/packages/flutter_riverpod)
