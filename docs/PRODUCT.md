# Producto

_Actualizado: 18-oct-2026._

---

## 1. Qué es

Práctica de **inglés oral** conversacional. El usuario habla con NPCs con IA
(Oráculo, tutor de misión, Maestre de Mesa) y la app mide progreso con lógica de
RPG. Desde P-30 (#115) también hay **comprensión auditiva** jugable (diálogo por
TTS + preguntas corregidas en servidor). Siguen sin existir lectura ni escritura
evaluadas (issue #43).

---

## 2. Planes

| Plan | Precio/mes | Maná/mes | Historial del informe | Notas |
|---|---|---|---|---|
| `plebeyo` | $0 | 3.000 (tope 200/día) | 1 semana | Gratis, estado por defecto |
| `noble` | $4.99 | 17.000 | 4 semanas | **Trial de 7 días** (Play + RevenueCat) |
| `realeza` | $9.99 | 20.500 | 52 semanas | Títulos/auras exclusivos |

- Los planes activos viven en `subscription_plans` y la app **solo pinta los
  `is_active = true`** (P-44 / #129). No hay lista de planes en el código.
- **DIVINO está retirado** desde la migración `20261030005704` (`is_active =
  false`); la fila se conserva porque `user_subscriptions` y `payments` la
  referencian. No hay usuarios con ese plan.
- La diferenciación es por **capacidad**, no solo por volumen de maná:
  semanas de historial en el informe semanal (`weekly_report_weeks`, aplicado
  en `get_weekly_report`) y cosméticos exclusivos (`cosmetic_catalog.min_plan`,
  aplicado en `purchase_cosmetic` / `craft_cosmetic`).
- Productos en Play: `dungeonsspeak_{noble|realeza}_{monthly|yearly}`. El
  mapeo de `sync-entitlement` / `revenuecat-webhook` sigue aceptando `divino`
  solo por compatibilidad histórica de SKUs ya publicados.
- RevenueCat: entitlement **`DungeonsSpeak Pro`**, offering `default`.
- El trial se configura en Play Console y RevenueCat; la app solo anuncia los
  días de `subscription_plans.trial_days` y deben coincidir con la tienda.
  Checklist: [runbooks/TRIAL_NOBLE_P45.md](runbooks/TRIAL_NOBLE_P45.md).
- El premium **no** vende ventajas de aprendizaje evaluado: las capacidades
  extra son de informe, historial y cosmética.

---

## 3. Monedas

| Recurso | Para qué | Se gana con | Se gasta en |
|---|---|---|---|
| **Maná** | Cada acción de IA (turno de Oráculo 15, cierre 30, mazmorra 12) | Plan mensual, pociones | Turnos de IA (servidor) |
| **Oro** | Cosméticos del inventario | Cierre de sesión (objetivos), bolsas de nivel | Tienda → ORO |
| **Gemas** | Cosméticos premium y freeze de racha | Misiones, recompensa diaria | Tienda → GEMAS |
| **Fragmentos** | Crafteo de cosméticos | Cierre de sesión (objetivos) | Tienda → FRAGMENTOS |
| **XP** | Nivel y rango | Sesiones, misiones | — |

Gemas y fragmentos volvieron a la UI en P-32 (#117) **con sumidero**: gemas en
freeze de racha (30, máx. 3) y cosméticos premium; fragmentos en recetas de
crafteo. El nivel de cazador (`1 + XP/1000`) desbloquea cosméticos del catálogo
y paga bolsas de oro. Detalle y consultas de medición en
[runbooks/ECONOMY_SINKS.md](runbooks/ECONOMY_SINKS.md). La venta directa de
maná sigue retirada y ninguna moneda compra ventajas de aprendizaje.

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
| oct-2026 | **P-32:** gemas y fragmentos vuelven con sumidero (freeze de racha, crafteo); el nivel de cazador desbloquea cosméticos y paga oro |
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

---

## 8. Maná: tope diario y turno de gracia (P-26, oct-2026)

**Decisión:** se mantiene el tope diario de **200 de maná** del plan gratuito
(≈16 turnos de mazmorra a 12 por turno) y se añade **un turno de gracia al día**.

- El turno de gracia solo se concede cuando `consume_mana` responde
  `daily_limit_reached` (plan gratuito). No aplica al saldo mensual agotado.
- Es idempotente por día (`user_subscriptions.mana_grace_date`) y lo reclama
  `llm-proxy` con service role (`claim_mana_grace`). El cliente no puede pedirlo.
- Motivo: el usuario puede **cerrar el intercambio en curso** en vez de quedarse
  bloqueado a mitad de una misión, sin abrir un consumo ilimitado.
- La UI avisa con 3 turnos o menos y muestra el coste del próximo turno.

**Revisión:** con los datos de `ai_usage_logs` (P-14) se reevalúa el 200 cuando
haya al menos dos semanas de uso real por parte de testers.
