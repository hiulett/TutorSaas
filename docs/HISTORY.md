# Historia y correcciones

Este documento explica qué son los archivos de `docs/archive/` y **qué
conclusiones antiguas ya no son ciertas**.

---

## 1. Por qué había 268 archivos

Entre julio y octubre de 2026 el proyecto acumuló documentación de varias
generaciones:

| Generación | Ejemplos | Estado |
|---|---|---|
| Planes por fase (`02_User_Experience/`, `05_Missions/`…) | README, Architecture, Database, Tasks, QA_Report | Obsoletos: describían un producto que cambió |
| Auditorías de UX (`UX-Audit/`, `UX_UI_AUDIT.md`, `VISUAL_EXPERIENCE_AUDIT.md`) | 42-90 KB cada una | Histórico |
| Rediseños de onboarding (5 carpetas distintas) | `Onboarding-*` | Reemplazados por el onboarding actual de 4 pasos |
| Estrategia (`UNIFIED_STRATEGY.md`, `PRODUCT_REDESIGN.md`, `ECONOMIC_MODEL.md`, `MONETIZATION_STRATEGY.md`) | 30-38 KB | Decisiones ya tomadas o descartadas |
| Informes generados (`graphify-out/`) | 306 KB | Salida de herramienta |
| Auditoría integral (`auditoria_producto/AUDITORIA_INTEGRAL.md`) | 113 KB, ~1.943 líneas | Base del backlog de GitHub |

Todo eso se movió a `docs/archive/`. **No se mantiene**: sirve como contexto,
no como referencia.

---

## 2. Correcciones a conclusiones antiguas

Al verificar la documentación contra el código (oct-2026) aparecieron varias
afirmaciones que ya no eran ciertas:

| Afirmación antigua | Realidad verificada |
|---|---|
| «Las conversaciones de lección no se guardan (id de texto contra UUID)» (#1) | `conversations.scenario_id` es **`varchar`**; se guardan. Producción tenía 17 mensajes en una lección |
| «El radar lee columnas que nadie escribe» (#25) | Cierto hasta oct-2026, pero el evaluador **ya devolvía** las 6 dimensiones; solo faltaba persistirlas |
| «Meta diaria e intereses no se usan» (#48) | El dashboard **ya filtraba** escenarios por intereses y meta desde `user_settings` |
| «`app_pt.arb` tiene 26 cadenas corruptas» (#49) | Solo 2 caracteres `U+FFFD`; el resto eran Ç/Ã/Ê válidas mal interpretadas al leer como Latin-1 |
| «El repo no tiene iOS configurado» (#21) | Cierto y **descartado**: el producto es Android únicamente |
| «Stripe es el flujo de pago» | Eliminado en oct-2026; todo va por Play Billing + RevenueCat |

Lección: la documentación envejece más rápido que el código. Los hechos de este
directorio se verificaron contra la base de datos y el código en la fecha
indicada al inicio de cada documento.

---

## 3. Cronología resumida

| Periodo | Hito |
|---|---|
| jul-2026 | Esquema inicial (75 tablas), pipeline de voz, onboarding de 5 pasos |
| ago-2026 | Gremio, misiones, economía, primer AAB (1.0.18+19) |
| sep-2026 | Auditoría integral → 72 issues en GitHub, oleadas de correcciones |
| oct-2026 | Webhook de RevenueCat arreglado, Stripe retirado, RLS endurecido, fuentes empaquetadas, documentación consolidada |

---

## 4. Dónde está cada cosa ahora

- Estado actual del producto: [PRODUCT.md](PRODUCT.md)
- Cómo está construido: [ARCHITECTURE.md](ARCHITECTURE.md)
- Datos y RLS: [DATA_MODEL.md](DATA_MODEL.md)
- Infraestructura: [OPERATIONS.md](OPERATIONS.md)
- Publicación: [RELEASE.md](RELEASE.md)
- Backlog vivo: issues de GitHub (`hiulett/TutorSaas`)
- Todo lo demás: [archive/](archive/)
