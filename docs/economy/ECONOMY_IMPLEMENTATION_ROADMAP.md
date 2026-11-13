# Roadmap de implementación

_Auditoría económica · Fase 12. Plan propuesto, **nada implementado**._

> Priorización por **impacto/riesgo** primero y esfuerzo después. No se propone
> hacer todo: la etapa 1 es requisito de las demás.

---

## Etapa 1 · Correcciones fundamentales (bloqueante)

| # | Iniciativa | Problema | Solución | Complejidad | Impacto | Criterio de aceptación |
|---|---|---|---|---|---|---|
| 1.1 | Acotar `reward_multiplier` | Exploit: gemas/XP ilimitadas (F-1) | `least(2, greatest(1, …))` en `claim_mission_reward` + restaurar el campo en `guard_mission_instance` | **S** | Crítico | Un cliente no puede subir el multiplicador ni reclamar más de 2× |
| 1.2 | Bloquear auto-completado de misiones | Exploit F-2 | `status` y `current_value` solo desde funciones `SECURITY DEFINER`; el trigger los revierte | M | Crítico | Un `UPDATE` directo a `status='completed'` no persiste |
| 1.3 | Retirar 9 items sin efecto | Cobro sin valor (F-3/F-4) | `is_active=false` o borrado lógico en `cosmetic_catalog` de invocaciones, pergaminos, llaves y libros | **S** | Alto | La tienda no ofrece ningún item sin consumidor en código |
| 1.4 | Medir el flujo real | Ceguera sobre `sink_ratio` | Ejecutar `v_economy_flow` y guardar la línea base | **S** | Alto | Documento con `sink_ratio` por moneda y fecha |
| 1.5 | Retirar pergaminos e invocaciones | Recursos muertos que se siguen entregando | Recompensa diaria paga oro/fragmentos; borrar `player_pergaminos` y `daily_state.invocations_*` del flujo | M | Medio | No se entrega ningún recurso sin sumidero |

**Regla de salida de la etapa 1:** no se empieza monetización nueva hasta que 1.1–1.3 estén en producción.

---

## Etapa 2 · Optimización de la economía base

| # | Iniciativa | Problema | Solución | Complejidad | Impacto |
|---|---|---|---|---|---|
| 2.1 | Un precio por item | Doble precio oro/gemas canibaliza la moneda premium | Objetos base solo en oro; premium solo en gemas | M | Alto |
| 2.2 | Consumible educativo recurrente | No hay gasto recurrente; el catálogo se agota | Repaso de errores del códex por 20 fragmentos / 30 oro | M | **Alto** (sumidero + aprendizaje) |
| 2.3 | Sumidero de fragmentos ampliado | 3 recetas para un recurso que se gana cada sesión | Recetas de consumibles educativos y cosméticos de temporada | S | Medio |
| 2.4 | Time-to-first-purchase | El primer gasto tarda días | Primer objeto a 60 oro + tutorial de tienda de un paso | S | Alto |
| 2.5 | Equipado visible | Comprar sin ver el resultado | Persistir equipado y pintarlo en perfil, gremio y burbuja | L | **Alto** |

**Métrica de éxito de la etapa:** `sink_ratio` de oro 0.4–0.7 y compradores de cosmético > 5 % de activos.

---

## Etapa 3 · Monetización

| # | Iniciativa | Problema | Solución | Complejidad | Impacto |
|---|---|---|---|---|---|
| 3.1 | Suscripción anual | Techo de ingresos = plan mensual | Exponer SKU `yearly` ya existentes con descuento | **S** | Alto |
| 3.2 | Paquetes de gemas | La moneda premium no tiene entrada de dinero | 2–3 SKU no consumibles + acreditación idempotente | M | Alto |
| 3.3 | Registro de ingresos | `payments` no la escribe nadie | Escribir pago/renovación/reembolso desde el webhook | M | Alto (ARPU real) |
| 3.4 | Cosméticos de pago único | Usuario que paga una vez y no quiere suscripción | 2–3 objetos exclusivos | M | Medio |

**Dependencia dura:** 3.2 requiere 1.1 y 1.3 cerrados (no vender gemas inflables ni cobrar por nada).

---

## Etapa 4 · Expansión

| # | Iniciativa | Complejidad | Impacto | Riesgo |
|---|---|---|---|---|
| 4.1 | Mazmorra/región temática de pago único | XL | Alto | Que el contenido base parezca incompleto sin ella |
| 4.2 | Colecciones y reliquias con ruta de obtención | M | Alto (retención) | Sobrecomplicar la economía |
| 4.3 | Pase de temporada | XL | Medio | Grind y presión de tiempo en un producto educativo |
| 4.4 | Funciones sociales monetizables | XL | Incierto | Mercado secundario y fraude |

**Principio de la etapa 4:** el contenido comprable es **adicional**; el plan de
estudios base nunca depende de él.

---

## Resumen de prioridades

| Prioridad | Iniciativa | Etapa |
|---|---|---|
| **P0** | 1.1, 1.2, 1.3 | 1 |
| **P0** | 1.4 (medir) | 1 |
| **P1** | 2.1, 2.2, 2.5 | 2 |
| **P1** | 3.1, 3.3 | 3 |
| **P2** | 2.3, 2.4, 3.2, 3.4, 4.1, 4.2 | 2–4 |
| **P3** | 4.3, 4.4 | 4 |

## Lo que NO debe hacerse

- Añadir monedas o items nuevos antes de cerrar 1.1–1.3.
- Subir precios sin `sink_ratio` medido.
- Monetizar herramientas de aprendizaje (deben ir dentro de la suscripción).
- Introducir azar de pago, anuncios o venta de progreso académico.
