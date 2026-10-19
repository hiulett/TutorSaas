# Producto

_Actualizado: 18-oct-2026._

---

## 1. Qué es

Práctica de **inglés oral** conversacional. El usuario habla con NPCs con IA
(Oráculo, tutor de misión, Maestre de Mesa) y la app mide progreso con lógica de
RPG. El alcance evaluado es **conversación oral**: no hay lectura, escritura ni
comprensión auditiva formal (issue #43).

---

## 2. Planes

| Plan | Maná/mes | Notas |
|---|---|---|
| `plebeyo` | 3.000 | Gratis, es el estado por defecto |
| `noble` | 17.000 | Premium 1 |
| `realeza` | 20.500 | Premium 2 |
| `divino` | 25.500 | Premium 3 |

- Los planes activos viven en `subscription_plans` (sin precios: los pone la
  tienda).
- Productos en Play: `dungeonsspeak_{noble|realeza|divino}_{monthly|yearly}`.
- RevenueCat: entitlement **`DungeonsSpeak Pro`**, offering `default`.
- El premium **solo** añade maná y features de texto; no vende ventajas de
  juego (decisión de producto).

---

## 3. Monedas

| Recurso | Para qué | Se gana con |
|---|---|---|
| **Maná** | Cada acción de IA (turno de Oráculo 15, cierre 30, mazmorra 12) | Plan mensual, recompensas de sesión, pociones |
| **Oro** | Cosméticos e ítems del inventario | Misiones, rachas |
| **XP** | Nivel y rango | Sesiones, misiones |

Gemas y fragmentos se retiraron de la UI (siguen acumulándose en la base, sin
uso). La venta directa de maná está retirada.

> Las métricas de fluidez y pronunciación son **estimaciones** del modelo, no
> mediciones acústicas. Así se presentan en la interfaz.

---

## 4. Progresión

- **CEFR:** PRE-A1, A1, A2, B1, B2, C1, C2.
- **Rango de cazador:** F, E, D, C, B, A, S, SS, SSS.
- El nivel se fija en el **test del Oráculo** (conversación oral) y nunca baja
  en modo promoción.
- Catálogo de lecciones: **Dart** (`LessonCatalog`, fuente única) con 500
  escenarios sembrados en la base.

---

## 5. Onboarding (4 pasos)

1. Idioma nativo.
2. Idioma objetivo.
3. Evaluación oral con el Oráculo (o salto manual a PRE-A1).
4. Creación de personaje (nombre, clase, meta diaria, intereses).

El país se eliminó: no se leía en ningún sitio. La meta diaria y los intereses
sí se usan para filtrar y priorizar escenarios.

---

## 6. Decisiones tomadas

| Fecha | Decisión |
|---|---|
| 2026 | **Android únicamente** (iOS descartado, issue #21) |
| 2026 | Catálogo Dart como fuente única de lecciones |
| 2026 | Retirar venta de maná y el tab de MANÁ de la tienda |
| 2026 | Premium reducido a maná; sin ventajas de juego |
| 2026 | Retirar gemas y fragmentos de la UI |
| 2026 | Renombrar "Guardián" → "Santuario de Maná" |
| 2026 | Quitar el badge "Moderated by AI" |
| 2026 | Onboarding mixto: quitar campos muertos, conectar los útiles |
| oct-2026 | **Stripe eliminado**; todo el pago va por Play Billing + RevenueCat |
| oct-2026 | Webhook de RevenueCat como fuente de compras, con reconciliación en la app |

---

## 7. Modelo de negocio vigente

```
Play Billing → RevenueCat → webhook → Supabase → app
                              ↑
                    sync-entitlement al abrir sesión
```

- Precios: los de Play (localizados), nunca cadenas escritas a mano.
- Pruebas: license testers de Play (ver runbook).
- Sin Stripe, sin venta web.
