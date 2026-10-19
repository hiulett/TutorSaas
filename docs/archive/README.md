# Archivo de documentación

Aquí vive la documentación **histórica** del proyecto: auditorías, planes de
diseño, rediseños y estrategias escritas entre julio y octubre de 2026.

**No se mantiene.** No la uses como referencia de cómo funciona el proyecto
hoy; para eso están los documentos de `docs/`:

| Documento vigente | Contenido |
|---|---|
| `../ARCHITECTURE.md` | Capas, features, rutas, pipeline de voz |
| `../DATA_MODEL.md` | Tablas, RLS, RPC, migraciones |
| `../OPERATIONS.md` | Entornos, secretos, funciones, cron |
| `../RELEASE.md` | Build, firma, publicación |
| `../PRODUCT.md` | Planes, moneda, CEGR, decisiones |
| `../HISTORY.md` | Qué cambió y qué conclusiones antiguas eran falsas |
| `../runbooks/` | Procedimientos operativos |

---

## Organización

| Carpeta | Qué contiene |
|---|---|
| `root/` | Estrategia y análisis que estaban en la raíz (`UNIFIED_STRATEGY.md`, `ECONOMIC_MODEL.md`, `PRODUCT_REDESIGN.md`, `TUTORSAAS_MASTER_CONTEXT.md`, `contexto.md`…) |
| `auditoria_producto/` | `AUDITORIA_INTEGRAL.md` (113 KB) — origen del backlog de GitHub |
| `02_User_Experience/` … `11_QA/` | Planes por fase del producto original |
| `UX-Audit/`, `UX_Audits/`, `UX_UI_Audit_InformationArchitecture/` | Auditorías de UX de varias iteraciones |
| `Onboarding-*/`, `Onboarding_Revamp/` | Cinco rediseños distintos del onboarding |
| `guild-mission-board/`, `Guild-Quest-Redesign/` | Diseño del tablón del gremio |
| `LessonCurriculumAudit/`, `MissionProgressAudit/`, `Navigation-Audit/` | Auditorías puntuales |
| `schema/` | Inventario del esquema previo |
| `release/` | Checklist de release anterior (superado por `../RELEASE.md`) |
| `supabase/` | Notas de despliegue de funciones |
| `graphify/` | Informes generados por la herramienta graphify |
| `PlantillaHtml/` | Maquetas HTML de referencia visual |

---

## Advertencia

Varias afirmaciones de estos documentos **ya no son ciertas**. Las correcciones
conocidas están listadas en [../HISTORY.md](../HISTORY.md#2-correcciones-a-conclusiones-antiguas).

Si necesitas recuperar algo concreto, busca aquí; si vas a trabajar en el
código, empieza por los documentos vigentes.
