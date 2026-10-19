# ADR-001: Feature-First Clean Architecture

## Estado
Aceptado

## Contexto
TutorSaas necesita una arquitectura que permita escalar el desarrollo con múltiples features (auth, conversación, dashboard, onboarding, vocabulario, etc.) manteniendo separación de responsabilidades, testabilidad y facilidad de navegación del código.

## Opciones Consideradas
1. **Clean Architecture tradicional** — Capas separadas por feature
2. **MVC (Model-View-Controller)** — Estándar de Flutter pero sin estructura clara
3. **Feature-first Clean Architecture** — Cada feature con sus propias capas data/domain/presentation
4. **Sin arquitectura definida** — Crecimiento orgánico

## Decisión
Se adopta **Feature-first Clean Architecture** con 3 capas por feature:
- `data/` — Repositorios concretos, DTOs, fuentes de datos (Supabase, APIs externas)
- `domain/` — Modelos de dominio (Freezed), interfaces de repositorio, casos de uso
- `presentation/` — Providers Riverpod, screens, widgets específicos

Además, un directorio `core/` compartido para:
- `constants/` — ApiConstants
- `services/` — AudioSfxService
- `theme/` — AppColors, AppTheme
- `utils/` — ErrorTracker, LatencyBenchmark, TextDiffUtils
- `widgets/` — GlassCard, SystemWindow, CyberManhwaBackground

## Consecuencias
**Positivas:**
- Cada feature es independiente y puede desarrollarse en paralelo
- Fácil localización de código por feature
- Capas claras facilitan testing unitario
- Reutilización de core components entre features
- Onboarding más rápido para nuevos desarrolladores

**Negativas:**
- Posible duplicación de código entre features (mitigado por core/)
- Overhead inicial de estructura de carpetas
- Mayor número de archivos

## Referencias
- [Clean Architecture (Robert C. Martin)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- Feature-first vs Layer-first: decisión pragmática por escalabilidad del equipo
