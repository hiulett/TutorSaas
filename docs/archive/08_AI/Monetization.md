# Fase 8 — IA · Monetización IA (tarea 31)

> Fuente de verdad: `/docs`. Diseño basado en planes reales en DB + infraestructura de costos (2026-07-30).

## 1. Estado actual de monetización

4 planes ya en DB (free $0 / monthly $1.99 / annual $14.99 / lifetime $29.99) con:
- Límites de audio IA mensual (30/300/1200/600 min).
- Features en `subscription_plans.features` (JSONB).
- Paywall dinámico en onboarding (`onboarding_screen.dart` `_buildPaywallScreenPage`) que lee planes de DB.
- `user_subscriptions` + RPCs `check_ai_audio_quota`/`track_ai_audio_time`.

**Ya existe la base de monetización.** El reto es que sea "justa y aporte valor" (objetivo del prompt).

## 2. Análisis de la propuesta de valor

### Problemas detectados
| ID | Problema | Impacto |
|---|---|---|
| MO-01 | **`monthly_audio_minutes_limit` de lifetime (600) < annual (1200)**: incoherente | El lifetime debería ser el máximo |
| MO-02 | **Doble fricción**: núcleo arcano diario (20) + cuota mensual de minutos — el free siente ambos | Confusión sobre qué limita el uso |
| MO-03 | **Battle Pass solo en annual**: monthly no lo incluye, pese a ser el "más económico" | Menos incentivo de prestigio en el plan principal |
| MO-04 | **Sin microtransacciones de recarga de energía** más allá de la tienda (`consumible_invocacion5/20`) | El núcleo arcano agotado no tiene CTA directo a recarga |

### Oportunidades
| ID | Oportunidad | Valor |
|---|---|---|
| MO-05 | **Recarga de energía en el momento justo** (modal agotado → comprar invocaciones) | Conversión impulsiva justa |
| MO-06 | **Paquetes de fragmentos/gemas** como moneda secundaria | Monetización sin tocar la experiencia |
| MO-07 | **Battle Pass premium separado** (pase por temporada) | Ingreso recurrente adicional |

## 3. Diseño de monetización IA propuesto

### A. Planes (ajustes mínimos, coherentes con lo existente)
| Plan | Precio | Audio/mes | Diferenciador IA |
|---|---|---|---|
| Free | $0 | 30 min | Core loop + energía diaria limitada |
| Monthly | $1.99 | 300 min | **Conversaciones ilimitadas + Battle Pass incluido** (corregir MO-03) |
| Annual | $14.99 | 1200 min | Todo monthly + cosméticos exclusivos + soporte |
| Lifetime | $29.99 | **1200 min** (corregir MO-01) | Todo annual + expansiones futuras |

### B. Microtransacciones (energía, en la tienda existente)
| Item | Precio (gemas) | Efecto |
|---|---|---|
| `consumible_invocacion5` | 40 (ya ajustado T-507) | +5 invocaciones/día |
| `consumible_invocacion20` | 150 | +20 invocaciones/día |
| `consumible_pergamino10` | 80 | +10 pergaminos |
| **Nuevo**: `recarga_audio30` | — | +30 min de audio IA mensual (gema/compra) |

### C. Flujo de conversión suave
1. Modal "NÚCLEO ARCANO AGOTADO" → 2 CTA: **"RECARGAR (+5 invocaciones)"** y **"IR PREMIUM"**.
2. Fin de sesión exitosa → mostrar "CONVIÉRTETE EN PREMIUM: ilimitado + Battle Pass" (paywall suave).
3. Battle Pass free (niveles 1-5) como gancho → upgrade a premium del pase.

## 4. Implementación recomendada (tareas atómicas)
| # | Tarea | Prioridad | Nota |
|---|---|---|---|
| MO-A | Corregir `lifetime.monthly_audio_minutes_limit` 600→1200 (SQL) | P0 | ✅ Script listo: `20260730_phase8_monetization_fixes.sql` |
| MO-B | Añadir Battle Pass al plan `monthly` (SQL features) | P0 | ✅ Script listo (mismo archivo) |
| MO-C | Modal de energía agotada con CTA "RECARGAR"/"IR PREMIUM" | P1 | Código (pendiente) |
| MO-D | Conectar recarga con `purchaseItem('consumible_invocacion5')` | P1 | Código (pendiente) |

**Estado**: MO-A y MO-B aprobados e implementados como script SQL (`supabase/migrations/20260730_phase8_monetization_fixes.sql`) — **pendiente de aplicar en SQL Editor por el usuario** (proyecto read-only para DML vía MCP).

## 5. Conclusión
La monetización IA está **bien fundada** (4 planes + límites + paywall dinámico + tienda de energía). Las mejoras son: corregir 2 incoherencias de datos (MO-A, MO-B) y pulir el flujo de conversión (MO-C, MO-D). No se requiere rediseño.

**Decisiones pendientes de producto (no implementar sin confirmación):**
- ¿Añadir microtransacción de "recarga de minutos de audio" (MO-nuevo)? Requiere definir precio en gemas o dinero real.
- ¿Battle Pass premium separado por temporada? Requiere modelo de negocio.
