# 06 — Modelo de negocio

---

## 1. Lo que existe hoy

| Plan | Maná/mes | Audio/mes | Precio mensual | Precio anual |
|---|---|---|---|---|
| PLEBEYO | 3.000 | 30 min | $0.00 | — |
| NOBLE | 17.000 | 300 min | $4.99 | $53.99 |
| REALEZA | 20.500 | 1.200 min | $9.99 | $107.99 |
| DIVINO | 25.500 | 2.000 min | $12.99 | $132.99 |

> Los precios de la tabla son los **declarados** en `subscription_plans`. Los
> precios efectivos los fija Google Play por territorio y se muestran desde
> RevenueCat; no se ha verificado que coincidan. Cualquier análisis de margen
> debe usar el precio neto de Play, no esta tabla.

Estado comercial real: **1 suscriptor, y es una cuenta de prueba**. No hay
evidencia de conversión ni de disposición a pagar.

---

## 2. Principio

**Se cobra por coste de IA y por profundidad, nunca por conocimiento.**

| Se puede vender | No se puede vender |
|---|---|
| Más maná (más conversación) | Nivel CEFR |
| Más minutos de audio | Rango o títulos por dinero |
| Evaluaciones adicionales | Respuestas correctas |
| Contenido extra | Evitar el esfuerzo |
| Personalización del tutor | Saltarse misiones |

Si pagar permite «aprobar» sin hablar, el producto deja de ser una herramienta
de aprendizaje y pasa a ser un juego de compras.

---

## 3. Qué debe ser gratis (demostración de valor)

- El test del Oráculo (primera vez).
- Una escena completa de conversación.
- Repaso SRS **ilimitado** (coste marginal cero).
- Misiones de elección/comprensión (sin IA).
- Ver tu progreso y tu evidencia de aprendizaje.

Motivo: el usuario debe poder comprobar que el producto funciona **antes** de
pagar. Y lo que no cuesta dinero no tiene sentido limitarlo.

---

## 4. Qué justifica la suscripción

1. **Volumen de conversación**: 3.000 maná ≈ 375 turnos libres; 17.000 ≈ 2.125.
2. **Audio**: 30 min vs 300-2.000 (el STT es el coste variable más alto).
3. **Tutor con memoria y plan**: briefing persistente y bloques de 4 semanas.
4. **Generación de lecciones de refuerzo** bajo demanda (100 maná cada una).
5. **Evaluaciones de cierre de bloque** con informe.

---

## 5. Escenarios económicos (cualitativos)

Como faltan precios de proveedor y comisión exacta, se plantean escenarios con
variables, no cifras inventadas.

```
Margen por usuario = (precio_neto_play) − (turnos × coste_turno) − (min × coste_min)
```

| Escenario | Supuesto | Resultado esperado |
|---|---|---|
| **Conservador** | 20 % de usuarios gratuitos agotan el maná cada mes; 2 % convierte | Sostenible solo si `coste_turno` es bajo; hay que medirlo |
| **Medio** | 40 % agota; 3-5 % convierte | El plan gratuito debe recortarse o el precio subir |
| **Optimista** | 10 % agota; 6 % convierte | Margen sano |

**Decisión que no se puede tomar sin datos:** si el plan gratuito de 3.000 maná
es sostenible. Hay que medir el consumo real de los usuarios gratuitos durante
un mes con `ai_usage_logs` antes de tocarlo.

---

## 6. Riesgo principal: usuario gratuito caro

Un usuario gratuito puede consumir 375 turnos y 30 min de STT al mes. Si el
coste de esas dos cosas supera el valor de tenerlo (retención, boca a boca),
el producto pierde dinero con cada usuario.

Controles ya disponibles:

1. Maná (límite duro por diseño).
2. Tope de audio mensual por plan.
3. Repaso y misiones deterministas sin coste.

Controles que **no** se deben usar:

- Bajar la calidad del modelo para gratuitos (rompe la promesa y la percepción).
- Anuncios (incompatibles con la inmersión y con el público adulto).

---

## 7. Alternativas evaluadas

| Modelo | Ventaja | Problema | Veredicto |
|---|---|---|---|
| **Freemium con maná** (actual) | Controla coste y comunica valor | El maná puede sentirse como castigo | **Mantener**, con mejor comunicación |
| Suscripción pura sin gratis | Menos coste | Nadie paga sin probar | Descartar |
| Pago por uso (paquetes de maná) | Flexible | Confuso y difícil de calibrar | Descartar por ahora |
| Cosméticos de pago | Margen alto | No resuelve el coste de IA | Mantener solo con oro |
| Anuncios | Ingreso sin fricción | Rompe la fantasía | Descartar |

---

## 8. Precio: qué falta para decidirlo

1. Coste real por turno y por minuto de audio (medible).
2. Distribución de consumo de los usuarios gratuitos (medible).
3. Conversión del embudo (instrumentada, sin datos aún).
4. Comparables de mercado (no se asumen).
5. Comisión neta de Play por territorio.

**No se recomienda cambiar precios antes de tener 4 semanas de datos** con el
embudo actual. Cambiarlos ahora sería calibrar a ciegas.

---

## 9. Riesgos de negocio

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Gratuitos caros | Pérdida por usuario | Maná + medir consumo |
| Conversión nula | Sin ingresos | Paywall propio, valor claro, prueba de 7 días |
| Reembolsos altos | Penalización en Play | Expectativa honesta, sin promesas de fluidez |
| Dependencia de un proveedor de IA | Coste o corte | Proxy propio ya abstrae el proveedor |
| Comisión de Play | Margen | Considerar precio anual (mejor conversión y retención) |
