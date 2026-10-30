# Índice de Documentación — TutorSaas

> **Proyecto:** TutorSaas — Plataforma SaaS de Conversación e IA para Aprendizaje de Idiomas  
> **Versión:** 1.0.0  
> **Última actualización:** Julio 2026

---

## Documentación General

| Archivo | Descripción |
|---------|-------------|
| [Arquitectura](../ARCHITECTURE.md) | Arquitectura Feature-first Clean Architecture, capas data/domain/presentation, Riverpod, GoRouter, Supabase, pipeline de voz |
| [Negocio](business.md) | Contexto de negocio: Freemium SaaS, speech barrier, público objetivo, monetización, diferenciadores |
| [UI / Design System](ui.md) | Sistema de diseño "Abyssal Interface" (Isekai Manhwa System HUD), colores, tipografía, componentes, screens |
| [Base de Datos](database.md) | Esquema completo de Supabase: tablas, relaciones, políticas RLS, triggers |
| [Supabase](supabase.md) | Configuración de Supabase: URL, anon key, tabla de tablas, Realtime, Storage, Auth |
| [Convenciones](conventions.md) | Convenciones de código: naming, Riverpod patterns, error handling, imports |
| [Roadmap](roadmap.md) | Roadmap futuro: fases completadas, items pendientes |
| [Testing](testing.md) | Enfoque de testing: unit tests, widget tests, integration tests, benchmarks |
| [Deployment](deployment.md) | Deploy: flutter build, flavors, dart-define, CI/CD |

## Archivos de Documentación Pre-existentes

| Archivo | Descripción |
|---------|-------------|
| [Plan de Implementación](PLAN_DE_IMPLEMENTACION.md) | Plan detallado de corrección de inconsistencias (DB, frontend, recomendaciones) |
| [Arquitectura de Voz](voice_chat_architecture_and_alternatives.md) | Análisis de arquitectura de voz y alternativas STT |

## Decisiones de Arquitectura (ADRs)

| ADR | Título | Decisión |
|-----|--------|----------|
| [ADR-001](adr/001-clean-architecture.md) | Clean Architecture | Feature-first Clean Architecture con capas data/domain/presentation |
| [ADR-002](adr/002-riverpod.md) | Riverpod | Riverpod sobre Provider/BLoC/GetX para gestión de estado |
| [ADR-003](adr/003-supabase.md) | Supabase | Supabase sobre Firebase como BaaS |
| [ADR-004](adr/004-go-router.md) | GoRouter | GoRouter para navegación declarativa |
| [ADR-005](adr/005-design-system.md) | Abyssal Interface | Sistema de diseño Isekai Manhwa System HUD |
| [ADR-006](adr/006-voice-pipeline.md) | Voice Pipeline | Pipeline: record → Groq STT → DeepSeek LLM → flutter_tts TTS |
| [ADR-007](adr/007-gamification.md) | Gamificación | Sistema de gamificación: XP, streaks, logros, rangos, maná |
| [ADR-008](adr/008-supabase-schema.md) | Schema Supabase | Diseño integral del schema de base de datos |

## Documentos de Contexto

| Archivo | Descripción |
|---------|-------------|
| [CONTEXTO.md](root/contexto.md) | Documento maestro de contexto técnico y de negocio |
| [TUTORSAAS_MASTER_CONTEXT.md](root/TUTORSAAS_MASTER_CONTEXT.md) | Contexto maestro generado por análisis completo del codebase |
| [AGENTS.md](../../AGENTS.md) | Instrucciones para agentes de IA sobre el proyecto |
