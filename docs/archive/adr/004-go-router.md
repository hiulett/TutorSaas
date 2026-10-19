# ADR-004: GoRouter para Navegación

## Estado
Aceptado

## Contexto
TutorSaas necesita un sistema de navegación que soporte:
- 12 rutas con parámetros opcionales (scenarioId, scenarioTitle, roomId, level)
- Navegación declarativa basada en URI
- Deep linking para notificaciones push (futuro)
- Redirección condicional (autenticación)
- Transiciones entre pantallas

## Opciones Consideradas
1. **GoRouter** — Router declarativo de Flutter, soporte oficial, deep linking
2. **Navigator 2.0 (Router API)** — Control total pero mucho boilerplate
3. **Navigator 1.0 (pushNamed)** — Simple pero sin deep linking nativo
4. **Beamer** — Basado en Router API, más flexible que GoRouter
5. **auto_route** — Code generation, anotaciones

## Decisión
Se adopta **GoRouter** con configuración declarativa centralizada en `lib/app/router.dart`.

## Consecuencias
**Positivas:**
- Configuración centralizada (12 rutas en un archivo)
- URI-based con parámetros de query para datos opcionales
- Soporte nativo de `MaterialApp.router`
- Deep linking out-of-the-box
- Redirección basada en estado de autenticación
- Transiciones personalizables

**Negativas:**
- Sin code generation (a diferencia de auto_route)
- Menos flexible que Router API para casos avanzados
- Dependencia del package externo

## Rutas Definidas
| Ruta | Screen | Parámetros |
|------|--------|-----------|
| `/` | WelcomeScreen | — |
| `/onboarding` | OnboardingScreen | — |
| `/home` | DashboardScreen | — |
| `/conversation` | ConversationScreen | scenarioId, scenarioTitle |
| `/summary` | SessionSummaryScreen | — |
| `/level-exam` | LevelExamScreen | level |
| `/paywall` | PaywallScreen | — |
| `/profile` | ProfileScreen | — |
| `/profile-edit` | ProfileEditScreen | — |
| `/settings` | SettingsScreen | — |
| `/chat-rooms` | ChatRoomsScreen | — |
| `/voice-room` | VoiceRoomScreen | roomId |

## Referencias
- [GoRouter Documentation](https://pub.dev/packages/go_router)
