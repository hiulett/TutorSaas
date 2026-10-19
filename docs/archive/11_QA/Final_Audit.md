# Fase 11 — QA · Auditoría Final (tarea 43)

> Informe ejecutivo consolidado. Basado en verificación real (2026-07-30).

## 1. Estado general

**El proyecto es funcional y estable en desarrollo.** Fases 2-10 implementadas:
- 27/27 tareas del backlog original (Fases 2-6) completadas.
- Fase 7 (Guild) 8/8, Fase 8 (IA) 3/3, Fase 9 (RPG) parcial con base sólida, Fase 10 (Micro) 7/7.
- `flutter analyze` 0 errores · `flutter test` 13/13 · build apk OK.

## 2. Fortalezas
- **Pipeline de voz optimizado**: TTS on-device ($0), STT/LLM con costos reducidos (IA-02/IA-03), latencia objetivo <1.5s.
- **Economía sostenible**: free 30min/mes ≈ $0.02-0.05/mes/usuario de costo real.
- **Diseño system**: paleta Isekai consistente, tokens de animación (AppMotion), widgets reutilizables (GlassCard, RunicButton, SegmentedBar).
- **Guild vivo**: NPC, quest board, mesas reales desde DB, prestigio visible.
- **Arquitectura**: feature-first, Riverpod, RLS por usuario en la mayoría de tablas.

## 3. Debilidades y riesgos
| Riesgo | Severidad |
|---|---|
| Seguridad DB: RLS anon en 54 políticas + `system_ai_settings` legible + SECURITY DEFINER expuestas (QA-1..4) | **ALTA** |
| `conversation_repository_impl` tiene API key hardcodeada + fallback `'sk-592...'` (IA-01 pendiente) | **ALTA** |
| Deuda técnica: dashboard_screen 2040 líneas, onboarding con hankenGrotesk | Media |
| Migraciones del 30-jul aplicadas manualmente (no versionadas en schema_migrations) | Media |
| 2 pantallas sin test dedicado (conversación, misiones) | Media |

## 4. Checklist de producción
| Requisito | Estado |
|---|---|
| Compila en release | ✅ debug OK; release no verificado |
| Tests unitarios | ✅ 13/13 (solo 2 archivos — insuficiente para producción) |
| Seguridad de RLS/claves | ❌ Pendiente (QA-1..4, IA-01) |
| API keys fuera del repo | ❌ Pendiente (IA-01) |
| Migraciones versionadas | ⚠️ Manual |
| Crash-free / observabilidad | ⚠️ ErrorTracker existe, sin Crashlytics/Sentry activo |
| Modo release probado en dispositivo real | ⚠️ No documentado |

## 5. Veredicto

**🟡 LISTO PARA BETA CERRADA — NO para beta pública ni producción.**

Justificación:
- **Funcionalidad core completa y estable** (conversación por voz, misiones, economía, gremio) → suficiente para un grupo pequeño de probadores.
- **Bloqueadores de lanzamiento público** (seguridad): RLS anon generalizado, `system_ai_settings` expuesta, API keys en repo, funciones SECURITY DEFINER expuestas. Estos deben resolverse antes de exponer a usuarios reales.
- **Para producción**: además, falta versión release verificada, cobertura de tests ampliada, y migraciones versionadas.

### Camino a beta pública (orden recomendado)
1. ✅ QA-1: RLS `system_ai_settings` solo admins. (aplicado)
2. ⬜ IA-01: mover API keys a dart-define + rotar las expuestas. (P0 — único bloqueador de seguridad restante)
3. ✅ QA-2/QA-3: vocabulary_items INSERT + revocar EXECUTE de funciones internas. (aplicados)
4. ⬜ QA-5: reescribir RLS a `(select auth.uid())` (generado). (P1)
5. ⬜ Versionar migraciones pendientes en Supabase. (P1)
6. ⬜ Ampliar tests (conversación, misiones, economía). (P2)
7. ⬜ QA-6/QA-7: índices. (P2)

> **Estado 2026-07-30**: QA-1/2/3 aplicados y verificados. El único bloqueador de seguridad pendiente para beta pública es **IA-01** (API keys en el repo).
