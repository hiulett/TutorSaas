# Resumen ejecutivo: la economía de TutorSaas

_Auditoría económica · Fase 11. Documento de cierre. Solo lectura; nada
implementado._

---

## 1. Veredicto en tres frases

La economía de TutorSaas está **bien diseñada y mal asegurada**: cuatro recursos
con funciones disjuntas, prohibición expresa de comprar ventaja educativa y un
libro mayor idempotente, pero con **dos exploits activos** y **nueve items que se
venden sin efecto**. Además, **la única vía de dinero real es la suscripción**:
ni gemas ni cosméticos se pueden comprar con dinero. El trabajo urgente no es
diseñar más economía, es **cerrar los agujeros y medir el flujo**.

## 2. Cómo entra el dinero hoy (verificado)

- `plebeyo` $0 · `noble` $4.99/mes (trial 7 días) · `realeza` $9.99/mes.
- Play Billing → RevenueCat → webhook idempotente → `sync_entitlement`.
- **No existe** compra de gemas, ni de maná, ni productos de pago único, ni
  publicidad, ni venta web.
- **La tabla `payments` no la escribe nadie**: los ingresos no están en Supabase,
  así que ARPU/ARPPU solo se pueden calcular en Play/RevenueCat.

## 3. Los tres problemas que importan

### P0 · Exploits de recompensas (activos)
`reward_multiplier` se puede inflar desde el cliente y `claim_mission_reward`
paga `recompensa × multiplicador` sin techo; `status` y `current_value` tampoco
están protegidos. Un usuario autenticado puede generar gemas y XP ilimitadas y
el sistema lo registra como legítimo. **Arreglo pequeño, impacto máximo**
(`ECONOMY_TECHNICAL_AUDIT.md` F-1/F-2).

### P0 · Se cobra por items sin efecto
Invocaciones (50–180 gemas), pergaminos (100–400 gemas), llaves y libros
(100–250 gemas cada uno): **9 items** cuya funcionalidad ya no existe o nunca se
implementó. Si el usuario compró gemas con dinero, se le está cobrando por nada.

### P0 · La economía está a ciegas
El `sink_ratio` no se mide desde P-32. La última medición conocida (29-oct) es
previa al arreglo: **0 cosméticos comprados nunca**, oro mediano 100 frente a un
mínimo de 120. Sin `sink_ratio` actual no se puede decidir ningún precio.

## 4. Lo que hay que proteger

1. **Ninguna moneda compra aprendizaje evaluado.** El maná se cobra por turno sin importar el plan. Es la decisión más valiosa del producto.
2. **Integridad por defecto**: el cliente no escribe saldos, RPC `SECURITY DEFINER`, `currency_ledger` con `unique(user_id, ref_key)` y `balance_after >= 0`.
3. **Trazabilidad**: `reward_history`, `mana_transactions`, `v_economy_flow`.
4. **El ciclo educativo ya cierra**: sesión → objetivos → oro/fragmentos → nivel → cosméticos.

## 5. Dirección recomendada

**Orden estricto:**

1. **Cerrar** (días): acotar el multiplicador, blindar `status`/`current_value`, retirar los 9 items muertos.
2. **Medir** (semanas): `sink_ratio` por moneda, saldo medio, time-to-first-purchase.
3. **Sanear el catálogo**: un precio por item (no dual oro/gemas), un consumible educativo recurrente (repaso de errores), equipado visible.
4. **Monetizar sin tocar el aprendizaje**: suscripción anual (SKU ya existen) y paquetes de gemas; registrar ingresos en `payments`.
5. **Expandir solo después**: mazmorra temática, colecciones; nunca pase de temporada con grind.

## 6. Modelo objetivo en una tabla

| Recurso | Función | Cambio |
|---|---|---|
| Maná | Combustible de IA | Mantener |
| Oro | Progresión blanda + repaso | Añadir sumidero recurrente |
| Gemas | Estética premium + contenido | Dar entrada de dinero |
| Fragmentos | Fabricación + repaso | Ampliar recetas |
| ~~Pergaminos~~ | ~~Sin uso~~ | **Retirar** |
| ~~Invocaciones~~ | ~~Fósil~~ | **Retirar** |

## 7. Riesgos si no se actúa

| Riesgo | Consecuencia |
|---|---|
| Exploits abiertos | Inflación de gemas/XP; cualquier economía futura nace muerta |
| Items sin efecto | Reembolsos, reseñas negativas, pérdida de confianza en la tienda |
| Monetizar antes de sanear | Se vende una moneda inflable → fraude y pérdida |
| Añadir mecánicas de grind | El producto pasa de «aprender» a «farmear»; se pierde la propuesta |

## 8. Criterio de éxito de la economía

- `sink_ratio` de oro en **0.4–0.7** con usuarios activos.
- **> 5 %** de activos compra al menos un cosmético; **> 50 %** de lo comprado se equipa.
- Conversión de suscripción medida y churn mensual conocido.
- **Lecciones completadas y palabras nuevas estables o crecientes** mientras suben ingresos. Si bajan, la iniciativa se revierte.

## 9. Índice de la auditoría

| Documento | Contenido |
|---|---|
| `ECONOMY_AUDIT.md` | Diagnóstico global y mapa de flujos |
| `MONETIZATION_ANALYSIS.md` | Planes, dinero real, huecos de conciliación, viabilidad |
| `VIRTUAL_CURRENCY_ANALYSIS.md` | Monedas, fuentes, sumideros, balance histórico |
| `ITEMS_AND_INVENTORY_AUDIT.md` | Los 40 items, utilidad y dead stock |
| `PLAYER_ENGAGEMENT_ANALYSIS.md` | Ciclo de motivación, retención, dónde se rompe |
| `NEW_MONETIZATION_OPPORTUNITIES.md` | Oportunidades priorizadas y descartes |
| `PROPOSED_ECONOMY_DESIGN.md` | Economía objetivo y personas |
| `ECONOMY_TECHNICAL_AUDIT.md` | Integridad, RPC, hallazgos F-1…F-6 |
| `ECONOMY_METRICS_AND_KPIS.md` | KPIs, guardarraíles educativos, dashboard |
| `ECONOMY_IMPLEMENTATION_ROADMAP.md` | 4 etapas con criterios de aceptación |

## 10. Límites de esta auditoría (honestidad de método)

- **No hay acceso MCP a producción en esta sesión.** Las políticas RLS y el
  cuerpo vigente de funciones se citan **según migraciones**; el repo no
  reproduce el esquema completo.
- Las cifras de volumen son las de la medición del **29-oct-2026** documentada en
  `ECONOMY_SINKS.md`, no re-ejecutadas.
- **No verificado**: equipado real de cosméticos, rotación del `guild_battle_pass`,
  ruta de obtención de las 3 reliquias, filas actuales de `player_inventory`.
- Sin datos de ventas, conversión ni churn: toda cifra de negocio aquí es
  hipótesis con fórmula explícita, nunca un hecho.
