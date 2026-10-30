# Índice de la documentación

> Inventario completo de la documentación del repositorio: qué es cada archivo,
> si sigue siendo **vigente** o es **histórico**, cuál es su **fuente de verdad**
> y cuándo se verificó por última vez.
>
> **Última verificación global: 29-oct-2026** (worktree limpio sobre
> `origin/master` `995e958`). Las cifras de la §2 las medí yo en esa sesión; no
> están heredadas de otro documento.

---

## 1. Cómo usar este índice

1. Empieza por [CONTEXT_MAP.md](CONTEXT_MAP.md) si solo quieres punteros.
2. Si vas a **afirmar algo sobre el esquema, los datos o el estado del
   producto**, comprueba la columna «fuente de verdad» y repite la medición: la
   documentación envejece más rápido que el código.
3. `docs/archive/` y `docs/estrategia_producto/` **no** son referencia de
   hechos: son contexto histórico y propuestas.

Estados que se usan en las tablas:

| Estado | Significado |
|---|---|
| **Vigente** | Describe el producto actual y se corrige cuando cambia |
| **Vigente (foto fechada)** | Correcto en su fecha; sus cifras caducan y no se reescriben |
| **Histórico** | No se mantiene; puede contradecir el presente |
| **Propuesta** | Decisión o diseño no implementado todavía |

---

## 2. Cifras medidas (29-oct-2026)

Todas salen de un comando ejecutado en esta sesión. El comando está en la
columna «cómo se mide».

| Dato | Valor | Cómo se mide |
|---|---|---|
| Versión | `1.0.21+22` | `pubspec.yaml: version` |
| Pruebas | **702 en verde, 0 saltadas** | `flutter test` |
| Analyzer | **0 errores · 0 warnings · 126 infos** | `flutter analyze` |
| Pruebas de `test/golden` | 16 | `flutter test test/golden` |
| Rutas registradas | **20** | `lib/app/router.dart` (ocurrencias de `path:`) |
| Features | **16** | `lib/features/*` (directorios) |
| Lecciones en el catálogo Dart | 140 (20 × 7 niveles) | `lesson_catalog.dart` |
| Claves i18n | **1.287** en `en`/`es`/`pt` (paridad) | `app_en.arb` sin claves `@` |
| Dependencias | 25 runtime · 5 dev | `pubspec.yaml` |
| Tablas en `public` | **89** | `information_schema.tables` (BASE TABLE) |
| Vistas | **14** | `information_schema.views` |
| Funciones en `public` | **98** | `pg_proc` (`prokind='f'`) |
| Políticas RLS | **134** sobre **84** tablas | `pg_policies` |
| Tablas sin RLS | 0 | `pg_tables.rowsecurity` |
| Triggers | 36 | `pg_trigger` (no internos) |
| Jobs de `pg_cron` | 3 | `cron.job` |
| Buckets de Storage | 1 | `storage.buckets` |
| Migraciones aplicadas | **106** | `supabase_migrations.schema_migrations` |
| Archivos `.sql` en `supabase/migrations/` (raíz) | **172** | `ls` |
| — con prefijo de 14 dígitos | 97 | regex `^\d{14}_` |
| — sin prefijo (el CLI los ignora) | 75 | 172 − 97 |
| — en subcarpetas (`archive/`, `audit/`) | 40 | `ls -R` |
| Aplicadas **con** archivo en el repo | 67 | comparación versión ↔ nombre de archivo |
| Aplicadas **sin** archivo | 39 | 106 − 67 |
| Archivos con prefijo **no** aplicados | 30 | comparación nombre ↔ versión |
| Elementos de `docs/` + raíz | 308 `.md` en `docs/` (252 en `archive/`) + `AGENTS.md` + `README.md` | `ls` |
| Issues de GitHub | 152 (40 abiertos · 112 cerrados) | `gh issue list` |
| Edge Functions desplegadas | 8 | `supabase functions list` |
| Planes activos | `plebeyo`, `noble`, `realeza` (`divino` inactivo) | `subscription_plans` |
| Escenarios sembrados | 500 | `count(*) scenarios` |
| Pistas de Play | internal `1.0.18+19` · alpha `1.0.19+20` · beta/production vacías | Play Developer API |

---

## 3. Documentos vigentes (`docs/`, raíz y `AGENTS.md`/`README.md`)

| Documento | Propósito | Estado | Fuente de verdad | Verificado |
|---|---|---|---|---|
| [`AGENTS.md`](../AGENTS.md) | Reglas para agentes: comandos, arquitectura, trampas, BD | Vigente | código + producción | 29-oct-2026 |
| [`README.md`](../README.md) | Presentación, stack, arranque rápido, mapa de docs | Vigente | `pubspec.yaml` + código | 29-oct-2026 |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Capas, features, rutas, estado, pipeline de voz, tema, i18n | Vigente | `lib/app/router.dart`, `lib/features/`, `supabase/functions/llm-proxy` | 29-oct-2026 |
| [DATA_MODEL.md](DATA_MODEL.md) | Tablas por dominio, RLS, RPC, contrato de compensaciones, migraciones | Vigente | producción (`information_schema`, `pg_policies`, `pg_proc`, `schema_migrations`) | 29-oct-2026 |
| [OPERATIONS.md](OPERATIONS.md) | Entornos, Edge Functions, secretos, coste de IA, cron, webhook, CI | Vigente | `supabase functions list`, `cron.job`, `.github/workflows/`, `llm-proxy` | 29-oct-2026 |
| [PRODUCT.md](PRODUCT.md) | Planes, monedas, progresión, onboarding, decisiones | Vigente | `subscription_plans` + RevenueCat/Play | 29-oct-2026 (planes) |
| [RELEASE.md](RELEASE.md) | Versión, build, firma, Google Sign-In, publicación, pistas | Vigente | `pubspec.yaml`, `android/`, Play Developer API | 29-oct-2026 |
| [HISTORY.md](HISTORY.md) | Qué conclusiones antiguas ya no son ciertas | Vigente | este índice + código | 29-oct-2026 |
| [CONTEXT_MAP.md](CONTEXT_MAP.md) | Índice de punteros para no cargar todo | Vigente | este índice | 29-oct-2026 |
| [CONTEXTO_ACTUAL.md](CONTEXTO_ACTUAL.md) | Traspaso de sesión: estado, trabajo abierto, cómo continuar | Vigente | este índice + GitHub | 29-oct-2026 |
| [PROPUESTA-P44-P48.md](PROPUESTA-P44-P48.md) | Propuestas P-44…P-48 con datos de producción | Propuesta (P-44/P-45 ya aplicados) | `subscription_plans`, `ai_action_costs`, `ai_usage_logs` | 29-oct-2026 |
| **[INDICE-DOCUMENTACION.md](INDICE-DOCUMENTACION.md)** | Este archivo | Vigente | — | 29-oct-2026 |

---

## 4. Runbooks (`docs/runbooks/`)

| Documento | Propósito | Estado | Fuente de verdad | Verificado |
|---|---|---|---|---|
| [CURRICULUM_ALIGNMENT.md](runbooks/CURRICULUM_ALIGNMENT.md) | Doble currículo (Dart ↔ BD), `lesson_key` pendiente (P-38) | Vigente | `lesson_catalog.dart`, `scenarios`, vistas `curriculum_*` | 29-oct-2026 |
| [ECONOMY_SINKS.md](runbooks/ECONOMY_SINKS.md) | Sumideros de oro/gemas/fragmentos y cómo medirlos (P-32) | Vigente | `currency_ledger`, `craft_cosmetic`, `level_rewards` | 29-oct-2026 |
| [GOAL_EVALUATION.md](runbooks/GOAL_EVALUATION.md) | Cómo se interpreta `goal_eval` y cómo se mide (P-39) | Vigente | `llm-proxy`, `GoalEvaluationGate` | 29-oct-2026 |
| [MIGRATION_STATUS.md](runbooks/MIGRATION_STATUS.md) | Deriva repo ↔ historial de migraciones y plan de baseline | Vigente | `schema_migrations` + `ls` | 29-oct-2026 |
| [P40_PERSONALIZACION.md](runbooks/P40_PERSONALIZACION.md) | Qué campo de personalización se lee de verdad (P-40) | Vigente | `user_settings`, `user_ai_profiles`, `corrections` | 30-oct-2026 |
| [PURCHASE_TESTING.md](runbooks/PURCHASE_TESTING.md) | Matriz de pruebas de compra (Play + RevenueCat) | Vigente | Play Console + RevenueCat | 29-oct-2026 |
| [QUALITY_TESTS.md](runbooks/QUALITY_TESTS.md) | Red de tests, regla de pixel-goldens, baseline | Vigente | `flutter test`, `test/golden/`, `ci.yml` | 29-oct-2026 |
| [REACTIVATION_EMAIL.md](runbooks/REACTIVATION_EMAIL.md) | Email de reactivación y baja sin login (#107) | Vigente | `reactivation-email`, `reactivation_emails`, `cron.job` | 29-oct-2026 |
| [REMEDIAL_LESSON_METRICS.md](runbooks/REMEDIAL_LESSON_METRICS.md) | Medición de lecciones de refuerzo (P-42) | Vigente | `lesson_progress`, `lesson-generator` | 29-oct-2026 |
| [SCHEMA_BASELINE.md](runbooks/SCHEMA_BASELINE.md) | Foto del esquema para comparar entornos | Vigente | producción (consultas incluidas) | 29-oct-2026 |
| [TRIAL_NOBLE_P45.md](runbooks/TRIAL_NOBLE_P45.md) | Trial de 7 días en NOBLE: Play + RevenueCat | Vigente | Play Console + RevenueCat | 29-oct-2026 |

---

## 5. Auditoría integral (`docs/product-audit/`)

Los 20 documentos son una **foto fechada del 25-oct-2026**. No se reescriben:
su valor es la evidencia de ese día. La §3 de
[00-INDICE.md](product-audit/00-INDICE.md) se actualizó con las cifras medidas
el 29-oct y marca cuáles caducaron.

| Documento | Propósito | Estado |
|---|---|---|
| [00-INDICE.md](product-audit/00-INDICE.md) | Índice, cifras clave, resumen ejecutivo, cobertura | Vigente (foto fechada) |
| [01-VISION-DEL-PRODUCTO.md](product-audit/01-VISION-DEL-PRODUCTO.md) | Qué promete el producto y qué no cumple | Vigente (foto fechada) |
| [02-ARQUITECTURA-TECNICA.md](product-audit/02-ARQUITECTURA-TECNICA.md) | Stack, capas, servicios, diagramas | Vigente (foto fechada) |
| [03-PANTALLAS-Y-NAVEGACION.md](product-audit/03-PANTALLAS-Y-NAVEGACION.md) | Pantallas, rutas y navegación | Vigente (foto fechada) |
| [04-EXPERIENCIA-DEL-USUARIO.md](product-audit/04-EXPERIENCIA-DEL-USUARIO.md) | Ciclo de vida y fricciones | Vigente (foto fechada) |
| [05-SISTEMA-PEDAGOGICO.md](product-audit/05-SISTEMA-PEDAGOGICO.md) | Currículo, niveles, evaluación, SRS | Vigente (foto fechada) |
| [06-GAMEPLAY-Y-GAMIFICACION.md](product-audit/06-GAMEPLAY-Y-GAMIFICACION.md) | Bucle, recursos, fórmulas, misiones | Vigente (foto fechada) |
| [07-INTELIGENCIA-ARTIFICIAL.md](product-audit/07-INTELIGENCIA-ARTIFICIAL.md) | Proveedores, prompts, costes | Vigente (foto fechada) |
| [08-MODELO-DE-DATOS.md](product-audit/08-MODELO-DE-DATOS.md) | Tablas, RLS, RPC, ER | Vigente (foto fechada) |
| [09-AUTENTICACION-Y-PERFILES.md](product-audit/09-AUTENTICACION-Y-PERFILES.md) | Login, sesión, perfiles | Vigente (foto fechada) |
| [10-MONETIZACION-Y-PAGOS.md](product-audit/10-MONETIZACION-Y-PAGOS.md) | Planes, RevenueCat, premium | Vigente (foto fechada) |
| [11-RETENCION-Y-NOTIFICACIONES.md](product-audit/11-RETENCION-Y-NOTIFICACIONES.md) | Canales de retorno | Vigente (foto fechada) |
| [12-CALIDAD-Y-MANTENIBILIDAD.md](product-audit/12-CALIDAD-Y-MANTENIBILIDAD.md) | Tests, analyzer, deuda | Vigente (foto fechada) |
| [13-CATALOGO-DE-FUNCIONALIDADES.md](product-audit/13-CATALOGO-DE-FUNCIONALIDADES.md) | Matriz de capacidades con estado | Vigente (foto fechada) |
| [14-FLUJOS-DE-DATOS.md](product-audit/14-FLUJOS-DE-DATOS.md) | Qué se escribe en cada acción | Vigente (foto fechada) |
| [15-EVALUACION-PRELIMINAR-DEL-PRODUCTO.md](product-audit/15-EVALUACION-PRELIMINAR-DEL-PRODUCTO.md) | Interpretación: engagement, retención | Vigente (foto fechada) |
| [16-RIESGOS-Y-PENDIENTES.md](product-audit/16-RIESGOS-Y-PENDIENTES.md) | Riesgos priorizados | Vigente (foto fechada) |
| [17-METRICAS-Y-ANALITICA.md](product-audit/17-METRICAS-Y-ANALITICA.md) | Instrumentación y brechas | Vigente (foto fechada) |
| [18-INVENTARIO-TECNICO.md](product-audit/18-INVENTARIO-TECNICO.md) | Archivos, endpoints, RPC, dependencias | Vigente (foto fechada) |
| [19-MATRIZ-DE-TRAZABILIDAD.md](product-audit/19-MATRIZ-DE-TRAZABILIDAD.md) | Hallazgos con `archivo:línea` | Vigente (foto fechada) |
| [20-MEJORAS-PROPUESTAS.md](product-audit/20-MEJORAS-PROPUESTAS.md) | Propuestas de mejora | Vigente (foto fechada) |

---

## 6. Estrategia (`docs/estrategia_producto/`)

14 documentos de **fase 2 (oct-2026)**: diagnóstico, diseño propuesto, negocio,
roadmap y decisiones pendientes. Son **propuestas**, no hechos: no se usan para
afirmar cómo funciona el producto hoy. Solo
[01_DIAGNOSTICO_ESTRATEGICO.md](estrategia_producto/01_DIAGNOSTICO_ESTRATEGICO.md)
se verificó contra código y BD (18-oct-2026), y esa verificación está caducada.

| Documento | Propósito | Estado |
|---|---|---|
| [00_VISION_Y_ESTRATEGIA.md](estrategia_producto/00_VISION_Y_ESTRATEGIA.md) | Visión y estrategia de fase 2 | Propuesta |
| [01_DIAGNOSTICO_ESTRATEGICO.md](estrategia_producto/01_DIAGNOSTICO_ESTRATEGICO.md) | Diagnóstico verificado (18-oct) | Histórico (foto fechada) |
| [02_GAME_DESIGN_PROPUESTO.md](estrategia_producto/02_GAME_DESIGN_PROPUESTO.md) | Game design propuesto | Propuesta |
| [03_SISTEMA_DE_APRENDIZAJE_PROPUESTO.md](estrategia_producto/03_SISTEMA_DE_APRENDIZAJE_PROPUESTO.md) | Sistema de aprendizaje propuesto | Propuesta |
| [04_UX_UI_PROPUESTO.md](estrategia_producto/04_UX_UI_PROPUESTO.md) | UX/UI propuesto | Propuesta |
| [05_IA_Y_OPTIMIZACION_DE_COSTES.md](estrategia_producto/05_IA_Y_OPTIMIZACION_DE_COSTES.md) | IA y costes | Propuesta |
| [06_MODELO_DE_NEGOCIO.md](estrategia_producto/06_MODELO_DE_NEGOCIO.md) | Modelo de negocio | Propuesta |
| [07_ROADMAP_PRIORIZADO.md](estrategia_producto/07_ROADMAP_PRIORIZADO.md) | Roadmap priorizado | Propuesta |
| [08_MVP_ESTRATEGICO.md](estrategia_producto/08_MVP_ESTRATEGICO.md) | MVP estratégico | Propuesta |
| [09_METRICAS_Y_EXPERIMENTOS.md](estrategia_producto/09_METRICAS_Y_EXPERIMENTOS.md) | Métricas y experimentos | Propuesta |
| [10_PLAN_DE_VALIDACION.md](estrategia_producto/10_PLAN_DE_VALIDACION.md) | Validación con usuarios | Propuesta |
| [11_DECISIONES_PENDIENTES.md](estrategia_producto/11_DECISIONES_PENDIENTES.md) | Decisiones del propietario | Propuesta |
| [12_PLAN_DE_IMPLEMENTACION.md](estrategia_producto/12_PLAN_DE_IMPLEMENTACION.md) | Plan de implementación | Propuesta |
| [13_RESUMEN_PARA_EL_PROPIETARIO.md](estrategia_producto/13_RESUMEN_PARA_EL_PROPIETARIO.md) | Resumen en lenguaje llano | Propuesta |

---

## 7. Archivo histórico (`docs/archive/`)

**252 archivos. No se mantiene y puede contradecir el presente.** Sirve como
contexto: planes por fase (jul-2026), auditorías UX (42–90 KB), rediseños de
onboarding, estrategia inicial y auditorías de producto anteriores. Lo que sigue
siendo cierto de esa época está resumido en [HISTORY.md](HISTORY.md).

Subcarpetas relevantes:

| Carpeta | Qué contiene |
|---|---|
| `archive/00_Project_Status.md` … `archive/06_Design_Migration_Plan.md` | Planes por fase del producto (jul-2026) |
| `archive/02_User_Experience/`, `03_Dashboard/`, `04_Conversations/`, `05_Missions/`, `06_Economy/`, `07_Guild/`, `08_AI/`, `09_RPG/`, `10_Animations/`, `11_QA/` | Documentación por módulo de la generación anterior (10 archivos cada una) |
| `archive/UX-Audit/`, `archive/UX_Audits/`, `archive/UX_UI_Audit_InformationArchitecture/` | Auditorías de UX/UI y propuestas de rediseño |
| `archive/auditoria_producto/` | Auditoría integral anterior (113 KB), base del backlog de GitHub |
| `archive/root/` | Estrategia de julio-2026 (`UNIFIED_STRATEGY`, `ECONOMIC_MODEL`, `PRODUCT_REDESIGN`, `MONETIZATION_STRATEGY`, `MISSION_ENGINE`, `I18N_STRATEGY`, `GUILD_HALL_*`, `VISUAL_EXPERIENCE_AUDIT`, `TUTORSAAS_MASTER_CONTEXT`, `contexto.md`) |
| `archive/supabase/` | Guías de despliegue de secretos de Edge Functions |
| `archive/adr/`, `archive/schema/`, `archive/release/` | Decisiones, esquema y notas de release antiguas |

> Los 11 documentos de estrategia de julio-2026 estaban **duplicados** en la
> raíz del repositorio (copias idénticas de `archive/root/`). Se han eliminado
> las copias de la raíz: la raíz solo conserva `AGENTS.md` y `README.md`.

---

## 8. Deuda documental

Afirmaciones que **siguen sin ser ciertas** o que no se pueden comprobar desde
este entorno. Se resuelven con el issue indicado.

| # | Deuda | Dónde | Cómo se resuelve |
|---|---|---|---|
| D-1 | Las cifras de los documentos 01–20 de la auditoría son del 25-oct (77 tablas, 122 políticas, 58 funciones, 14 rutas, 10 features, 159 tests, 951 claves i18n) y ya no coinciden con producción | `docs/product-audit/01…20` | Re-auditar el capítulo afectado cuando se cierre el épico #137; hoy manda la §2 de este índice |
| D-2 | `docs/estrategia_producto/01_DIAGNOSTICO_ESTRATEGICO.md` se verificó el 18-oct y cita cifras anteriores a P-38/P-40/P-44 | `docs/estrategia_producto/01` | Re-verificar si se retoma el roadmap; no bloquea código |
| D-3 | El tamaño del AAB (104,2 MB) no se puede comprobar sin `flutter build appbundle --release` (requiere keystore y ~10 min) | `docs/RELEASE.md` §1 | Medirlo en la próxima release (#51) |
| D-4 | La cobertura de tests que publica el CI no se ha consultado en esta sesión | `docs/runbooks/QUALITY_TESTS.md` §1 | Leer el último run de `ci.yml` (P-18) |
| D-5 | El número de claves i18n crece con cada PR de producto; el índice lo fija en 1.287 y hay que re-medirlo al cerrar release | este índice §2 | `ConvertFrom-Json` sobre `app_en.arb` |
| D-6 | 39 migraciones aplicadas no tienen archivo en el repo y 30 archivos con prefijo no están aplicados: el repo sigue sin reproducir el esquema | `docs/runbooks/MIGRATION_STATUS.md` | Baseline con `supabase db dump` (#101) |

---

## 9. Cómo mantener este índice

1. Si creas un documento en `docs/`, añádelo a la tabla de su carpeta con
   propósito, estado, fuente de verdad y fecha.
2. Si mueves algo a `docs/archive/`, márcalo aquí como histórico y anota la
   corrección en [HISTORY.md](HISTORY.md).
3. Al cerrar una release, re-mide la §2 y actualiza solo las filas que hayan
   cambiado; no copies cifras de otros documentos.
