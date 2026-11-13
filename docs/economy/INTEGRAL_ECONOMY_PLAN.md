# Plan económico integral (aplicable)

_Síntesis de la auditoría (`ECONOMY_AUDIT`, `MONETIZATION_ANALYSIS`,
`VIRTUAL_CURRENCY_ANALYSIS`, `ITEMS_AND_INVENTORY_AUDIT`,
`PLAYER_ENGAGEMENT_ANALYSIS`, `NEW_MONETIZATION_OPPORTUNITIES`,
`PROPOSED_ECONOMY_DESIGN`, `ECONOMY_TECHNICAL_AUDIT`, `ECONOMY_METRICS_AND_KPIS`,
`ECONOMY_IMPLEMENTATION_ROADMAP`, `EXECUTIVE_ECONOMY_SUMMARY`)._

**Qué es este documento.** Un plan de ejecución único: qué se toca, en qué orden,
con qué valores y con qué puerta de salida entre fases. **No implementa nada**;
las cifras son propuestas a validar con datos reales.

---

## 1. Principios (no negociables)

1. **Ninguna moneda compra aprendizaje evaluado.** Ni niveles, ni aprobar el Oráculo, ni saltarse misiones.
2. **Nada se vende sin efecto verificado.** Si no lo consume código, no está en la tienda.
3. **Un item, un precio.** El objeto base se paga en oro; el premium, en gemas. Nunca los dos.
4. **El plan de estudios nunca depende de pagar.** El contenido comprable es adicional.
5. **Si sube el ingreso y baja la lección completada, se revierte.**

## 2. Punto de partida (verificado en la auditoría)

| Hecho | Dato |
|---|---|
| Vía de ingreso | Solo suscripción ($4.99 / $9.99). No hay SKU de gemas ni pago único |
| Ingresos en base | `payments` no la escribe nadie → ARPU no calculable en Supabase |
| Catálogo | 40 items; **9 sin efecto**; casi todos con doble precio oro/gemas |
| Sumidero | `sink_ratio` sin medir desde P-32; última medición: **0 cosméticos comprados nunca** |
| Integridad | **2 exploits activos** en recompensas de misión |

## 3. Fases, con puerta de salida

### Fase 0 · Integridad y línea base (1 semana)

| Cambio | Detalle | Dónde |
|---|---|---|
| 0.1 Acotar multiplicador | `v_mult := least(2, greatest(1, …))` en `claim_mission_reward` | RPC |
| 0.2 Proteger el multiplicador | `new.reward_multiplier := old.reward_multiplier` en `guard_mission_instance` | Trigger |
| 0.3 Blindar el estado | `status` y `current_value` solo desde `advance_missions_for_user`; el trigger los revierte en UPDATE de `authenticated` | Trigger |
| 0.4 Retirar 9 items muertos | `consumible_invocacion5/20`, `consumible_pergamino10/50`, `key_mazmorra_oculta`, `key_archivo_gremio`, `book_phrasal_verbs`, `book_grimorio_tiempos`, `book_pronunciacion` → `is_active = false` o borrado lógico | Catálogo |
| 0.5 Línea base | Ejecutar y guardar: `sink_ratio` por moneda, saldo medio/mediana, % de activos con saldo > 5× precio medio, filas de `player_inventory` | SQL de solo lectura |

**Puerta F0:** cero filas con `reward_multiplier > 2`; tienda sin items sin consumidor; documento con la línea base fechada.

---

### Fase 1 · Saneamiento del catálogo (2 semanas)

| Cambio | Detalle |
|---|---|
| 1.1 Un precio por item | Quitar `price_gold` de los objetos premium; dejar oro solo en la escalera base (60–1.200) |
| 1.2 Retirar pergaminos e invocaciones del flujo | Recompensa diaria paga **oro/fragmentos**, no pergaminos; borrar `player_pergaminos` e `invocations_*` del estado diario |
| 1.3 Primer gasto garantizado | Mantener entrada a 60/80/90 oro; el perfil nace con 100 |
| 1.4 Consumible educativo recurrente | **Repaso de errores del códex**: 20 fragmentos o 30 oro por sesión de repaso (sumidero semanal + valor educativo) |
| 1.5 Equipado visible | Verificar y, si falta, persistir equipado y pintarlo en perfil, Gremio y burbuja del chat |

**Puerta F1:** `sink_ratio` de oro entre **0.4 y 0.7**; compradores de cosmético **> 5 %** de activos; **> 50 %** de lo comprado se equipa.

---

### Fase 2 · Monetización (2–3 semanas)

| Cambio | Detalle |
|---|---|
| 2.1 Suscripción anual | Exponer `dungeonsspeak_{noble|realeza}_yearly` (SKU ya existen). Descuento a decidir con cohortes |
| 2.2 Paquetes de gemas | 2–3 SKU no consumibles (ilustrativo: 300 / 900 / 2.000 gemas). Acreditación idempotente reutilizando `economy_apply_currency` |
| 2.3 Registro de ingresos | El webhook escribe pago, renovación y reembolso en `payments` (y añadir `store_transaction_id`) |
| 2.4 Cosmético de pago único (opcional) | 1–2 objetos exclusivos, no comprables con gemas |

**Precondición dura:** F0 y F1 cerradas. **Nunca** vender gemas mientras la moneda sea inflable.

**Puerta F2:** conversión trial→pago y churn conocidos; ingresos registrados en base; ninguna caída de lecciones completadas.

---

### Fase 3 · Expansión (4+ semanas, solo si F2 valida apetito de pago)

| Cambio | Detalle |
|---|---|
| 3.1 Mazmorra/región temática | Pago único o gemas; contenido **adicional** al plan base |
| 3.2 Colecciones y reliquias | Ruta de obtención explícita para las 3 reliquias existentes |
| 3.3 Pase de temporada | **Solo** con diseño anti-grind; nunca requisito para aprender |

## 4. Valores económicos propuestos (a validar)

| Flujo | Valor propuesto | Hoy | Motivo |
|---|---|---|---|
| Cierre de sesión | 10 oro + 5 fragmentos por objetivo | Idéntico | Funciona |
| Bolsas de nivel | 100–800 oro (2,3,5,8,12,15) | Idéntico | Funciona |
| Recompensa diaria | 5 / 10 / 20 / 40 gemas + oro | 5 / 50 / 100 / 300 + pergaminos | Bajar techo y quitar recurso muerto |
| Misión diaria | 15–30 gemas | Sin techo visible | Poner techo diario |
| Freeze de racha | 30 gemas, máx 3 | Idéntico | Bien calibrado como protección |
| Cosmético base | 60–1.200 oro | Igual, pero sin gemas | Separar monedas |
| Cosmético premium | 350–2.800 gemas | Igual, pero sin oro | Recuperar valor de la gema |
| Repaso de errores | 20 fragmentos o 30 oro | No existe | Sumidero recurrente |
| Maná por turno | 12 / 15 / 30 | Idéntico | Decisión de producto |
| **Objetivo `sink_ratio` oro** | **0.4–0.7** | Desconocido | Banda sana |

## 5. Cuadro de mando (5 métricas de decisión)

| Métrica | Umbral verde | Acción si falla |
|---|---|---|
| `sink_ratio` oro | 0.4–0.7 | < 0.4: añadir sumidero (no bajar precios). > 0.8: ampliar catálogo |
| Compradores de cosmético / activos | > 5 % | Subir visibilidad y bajar la entrada |
| Equipado / comprado | > 50 % | Arreglar equipado antes de vender más |
| Time-to-first-purchase | < 72 h | Tutorial de tienda de un paso |
| Lecciones completadas / usuario | Estable o ↑ | Revertir la iniciativa económica |

KPIs completos y consultas SQL: `ECONOMY_METRICS_AND_KPIS.md`.

## 6. Riesgos y reversibilidad

| Riesgo | Mitigación |
|---|---|
| Vender gemas sobre economía inflable | Bloqueado por F0 |
| Caída del aprendizaje por monetizar | Guardarraíl por fase; revertir si baja la lección completada |
| Contenido de pago percibido como obligatorio | El plan base nunca depende de la expansión |
| Cambios de precio mal medidos | Toda cifra se valida antes con `sink_ratio` |

Casi todo es reversible: precios y recompensas son filas de catálogo/tablas de
configuración; los triggers se revierten con migración.

## 7. Qué NO hace este plan

- Más monedas, conversiones entre monedas, loot boxes, anuncios.
- Vender XP, niveles CEFR, saltar misiones o herramientas educativas por separado.
- Tocar el pipeline de voz ni los planes vigentes antes de medir.
