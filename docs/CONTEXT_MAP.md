# Mapa de contexto — TutorSaas

> Índice de punteros. Abre **solo** el documento del módulo que necesites.
> No cargues `docs/archive/` ni `docs/estrategia_producto/` por defecto.

## Estado verificado del producto

- Auditoría vigente (25-oct-2026): `docs/product-audit/00-INDICE.md`
  - Arquitectura: `02-ARQUITECTURA-TECNICA.md`
  - Pantallas: `03-PANTALLAS-Y-NAVEGACION.md`
  - Pedagogía: `05-SISTEMA-PEDAGOGICO.md`
  - Gameplay/fórmulas: `06-GAMEPLAY-Y-GAMIFICACION.md`
  - IA/costes: `07-INTELIGENCIA-ARTIFICIAL.md`
  - Datos/RLS: `08-MODELO-DE-DATOS.md`
  - Riesgos: `16-RIESGOS-Y-PENDIENTES.md`
  - Trazabilidad: `19-MATRIZ-DE-TRAZABILIDAD.md`

## Contexto operativo

- Arquitectura resumida: `docs/ARCHITECTURE.md`
- Tablas y RLS: `docs/DATA_MODEL.md` (producción manda; el repo **no** reproduce el esquema)
- Entornos, secretos, funciones, cron: `docs/OPERATIONS.md`
- Build y publicación: `docs/RELEASE.md`
- Tests y red de regresión visual (goldens, guard de tokens): `docs/runbooks/QUALITY_TESTS.md`
- Estado de migraciones: `docs/runbooks/MIGRATION_STATUS.md`
- Decisiones de producto: `docs/PRODUCT.md`
- Correcciones a documentación antigua: `docs/HISTORY.md`

## Reglas duras (no renegociar)

- Android únicamente.
- Nunca `git checkout -- <archivo>` ni `git restore`.
- `.arb` solo con la herramienta de edición; después `flutter gen-l10n`.
- No tocar el pipeline de voz sin pedido explícito.
- No ejecutar `supabase db push`.
- Claves de IA solo como secretos de `llm-proxy`.

## Trampas conocidas

- `GlassCard` gana la arena de gestos: pasa `onTap:`, no envuelvas.
- La escritura de `xp/racha/minutos` desde el cliente la descarta `guard_language_profile`.
- Hay dos currículos (Dart y BD); el criterio de "completada" ya es único
  (P-38 fase 1, `LessonCompletion` + `lesson_completion_passed()`). Faltan el
  mapeo `lesson_key` y el corte del runtime: `docs/runbooks/CURRICULUM_ALIGNMENT.md`.
- El resumen de sesión muestra cifras fijas; la recompensa real viene de `apply_session_rewards`.

## Herramientas y rutas frecuentes

- Verificar datos reales: MCP `supabase` (solo lectura; nunca DDL).
- Compras/planes: MCP `revenuecat` y `play-console`.
- Comandos del repo: `/build`, `/test`, `/review`, `/db-check`.
- Goldens y guard de tokens: `docs/runbooks/QUALITY_TESTS.md`.
- Subagentes: `db-auditor`, `design-auditor`, `release-captain`, `acceptance`, `test-author`, `reviewer`.
