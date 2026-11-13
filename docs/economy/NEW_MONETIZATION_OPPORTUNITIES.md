# Nuevas oportunidades de monetización

_Auditoría económica · Fase 6. Propuestas, no implementación._

> Restricción que gobierna todo el documento: **nada de ventajas de aprendizaje
> evaluado**. La moneda comprada solo puede comprar estética, acceso a
> experiencias y comodidad, nunca progreso académico ni saltarse práctica.

**Punto de partida (verificado):** hoy solo se vende suscripción. No hay paquetes
de moneda, ni productos de pago único, ni publicidad. Las gemas se ganan jugando
y no tienen entrada de dinero (`MONETIZATION_ANALYSIS.md`).

---

## 1. Candidatas de alto valor

### O-1 · Paquetes de gemas (solo cosmético)

- **Descripción:** 3–4 SKU de gemas (p. ej. 300 / 900 / 2.000) para comprar cosméticos del catálogo.
- **Necesidad:** hoy la moneda premium no tiene puerta de entrada de dinero; el usuario que querría pagar por un título o un aura no puede.
- **Público:** usuario gratuito con interés estético; coleccionista.
- **Modelo:** pago único consumible (RevenueCat `non-subscription`).
- **Moneda:** gemas.
- **Coste de desarrollo:** **S** — ya existe `revenuecat_service`; faltan SKU en tienda, offering y un RPC de acreditación (reutiliza `economy_apply_currency`).
- **Complejidad técnica:** baja, con una condición: usar el mismo patrón idempotente del webhook para no acreditar dos veces.
- **Potencial de ingresos:** **alto** (es el upsell más natural del sistema actual).
- **Impacto en retención:** medio (da salida al cosmético deseado).
- **Impacto educativo:** neutro.
- **Riesgos:** si el catálogo sigue teniendo items sin efecto, se venden gemas para comprar nada → **bloqueado hasta retirar los 9 items muertos**.
- **Dependencias:** F-1/F-2 cerrados (no vender una moneda inflable), catálogo limpio.
- **Prioridad:** **P1**.

### O-2 · Expansión de contenido (mazmorra / región temática)

- **Descripción:** pack de escenarios con NPCs y objetivos propios, comprado una vez.
- **Necesidad:** dar un objetivo de medio plazo y una razón de pago no recurrente.
- **Público:** usuario suscrito que ya completó el catálogo base.
- **Modelo:** pago único (no consumible).
- **Moneda:** — (desbloquea contenido, no recursos).
- **Coste:** **XL** (escritura de contenido + `LessonCatalog` + mazmorra).
- **Complejidad:** media-alta; el catálogo es fuente única en Dart y las lecciones están sembradas en base.
- **Potencial:** **alto** y con mejor percepción de valor que comprar gemas.
- **Retención:** alta (contenido nuevo = sesiones nuevas).
- **Educativo:** **positivo** (más práctica).
- **Riesgos:** si la expansión es la única forma de practicar temas útiles, se convierte en paywall educativo. Debe ser **contenido adicional**, nunca el plan de estudios.
- **Dependencias:** `sync_entitlement` extendido a productos no suscripción.
- **Prioridad:** **P2** (después de O-1).

### O-3 · Suscripción anual

- **Descripción:** exponer `dungeonsspeak_{noble|realeza}_yearly` con descuento.
- **Necesidad:** subir LTV y bajar churn con un compromiso anual.
- **Público:** usuario que renueva ≥2 meses.
- **Modelo:** suscripción anual.
- **Coste:** **S** — los SKU ya existen (`PRODUCT.md` §2); falta exponerlos y decidir el descuento.
- **Potencial:** **alto** (palanca de LTV más barata que existe).
- **Riesgo:** canibaliza el mensual si el descuento es agresivo; medir con cohortes.
- **Prioridad:** **P1**.

### O-4 · Cosméticos de pago único y exclusivos

- **Descripción:** skins de NPC/tutor, temas de mesa y marcos vendidos directamente por dinero (no por gemas).
- **Necesidad:** capturar al usuario que paga una vez y no quiere suscripción.
- **Modelo:** pago único.
- **Coste:** **M** (arte + SKU + catálogo `min_plan`-style flag).
- **Potencial:** medio-alto; margen alto (arte ya existe en parte).
- **Riesgo:** competir con el catálogo de gemas y con la suscripción; requiere exclusividad real.
- **Prioridad:** **P2**.

## 2. Candidatas de valor medio

### O-5 · Pase de temporada (battle pass)

- **Descripción:** progreso por temporadas con recompensas cosméticas en dos carriles (gratis / pago).
- **Necesidad:** renovar el motivo de gasto y dar cadencia.
- **Coste:** **XL**; ya existe `guild_battle_pass` en esquema pero **sin contenido verificado**.
- **Potencial:** alto en retención, medio en ingresos.
- **Riesgo:** **alto** si introduce grind o presión de tiempo; el battle pass de un producto educativo puede empujar a jugar por recompensas y no por aprender.
- **Prioridad:** P3, y solo con diseño anti-grind explícito.

### O-6 · Slots y personalización ampliada

- **Descripción:** más espacio de personajes, mascotas o temas guardados.
- **Coste:** **M**.
- **Potencial:** bajo; comodidad de nicho.
- **Prioridad:** P3.

### O-7 · Herramientas de estudio premium

- **Descripción:** repaso intensivo de errores, mazos temáticos, plan personalizado.
- **Decisión clave:** **deben ir dentro de la suscripción**, no venderse aparte.
- **Razón:** son aprendizaje evaluado; venderlas aparte crearía un alumno de primera y otro de segunda.
- **Prioridad:** P2, como **valor de suscripción** (mejora de conversión, no producto nuevo).

## 3. Candidatas que descarto (y por qué)

| Idea | Por qué no |
|---|---|
| **Vender maná** | Ya retirado por decisión de producto; convierte el dinero en tiempo de práctica |
| **Cofres con probabilidad oculta** | Riesgo regulatorio (loot boxes), presión psicológica y daño reputacional |
| **Anuncios** | Rompen la inmersión RPG y el flujo de voz; el ingreso por usuario sería mínimo frente al daño |
| **Intercambio de items entre usuarios** | Abre mercado secundario, RMT y fraude; complejidad de integridad enorme |
| **Saltarse misiones / multiplicar XP permanente** | Destruye la credibilidad educativa |
| **Pagar por subir de nivel CEFR** | Convierte el producto en una mentira |

## 4. Matriz de priorización

| Id | Iniciativa | Ingresos | Retención | Educativo | Coste | Prioridad |
|---|---|---|---|---|---|---|
| O-3 | Suscripción anual | Alto | Medio | Neutro | S | **P1** |
| O-1 | Paquetes de gemas | Alto | Medio | Neutro | S | **P1** |
| O-2 | Expansión de contenido | Alto | Alto | Positivo | XL | P2 |
| O-7 | Herramientas de estudio (dentro del plan) | Medio (conversión) | Alto | Positivo | M | P2 |
| O-4 | Cosméticos de pago único | Medio | Bajo | Neutro | M | P2 |
| O-5 | Pase de temporada | Medio | Alto | Riesgo | XL | P3 |
| O-6 | Slots extra | Bajo | Bajo | Neutro | M | P3 |

## 5. Secuencia recomendada

1. **Primero sanear** (no es monetización, es requisito): cerrar F-1/F-2, retirar los 9 items muertos, medir el flujo.
2. **O-3 + O-1**: dos SKU como máximo, coste bajo, ingresos directos.
3. **Medir 2–4 semanas** antes de invertir en O-2.
4. **O-2** solo si la conversión de O-1/O-3 demuestra apetito de pago.

Nada de esto se implementa en esta auditoría.
