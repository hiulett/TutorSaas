# Economía de items: qué genera cada recurso y en qué se gasta

_Diseño · Alternativas para decidir. Nada implementado._

> Pregunta que responde: **para cada recurso, qué acciones lo generan, en qué se
> gasta, y qué pasa con el que llega por suscripción frente al que se gana
> jugando.**

---

## 1. Correcciones a las ideas de partida

| Idea tuya | Veredicto | Matiz |
|---|---|---|
| Cada plan incluye una canasta de items | ✅ Buena | Solo si cada item tiene sumidero real; regalar aire con ceremonia no aporta valor |
| Gemas **solo** por renovación de suscripción | ✅ Buena, con consecuencias | Hay que dejar de pagar gemas en misiones y dar alternativa al freeze de racha para el gratuito. Y decide: si son exclusivas de suscripción, **no hay packs de gemas** (no se venden) |
| Contadores independientes, saldo consolidado | ✅ Correcta y recomendable | El libro mayor ya registra el origen (`reason`); falta decidir si además hay caducidad por lote |
| Pergaminos como recurso del plan | ⚠️ Hoy son un recurso muerto | Sin una función real, meterlos en la canasta empeora la percepción: hay que darles un uso o retirarlos |

## 2. El problema de los pergaminos (y la solución)

Estado actual: `player_pergaminos` recibe pergaminos de la recompensa diaria y
**no hay ningún sumidero**; su descripción promete «práctica sin IA» que no está
implementada.

**Dos salidas:**

1. **Darles función** — «pergamino = práctica sin coste de maná»: un paquete de
   ejercicios (vocabulario, repaso de errores) generado por servidor y cacheado,
   que el usuario abre sin gastar IA. Es el uso más natural: convierte el recurso
   en la vía del usuario gratuito para seguir aprendiendo cuando se queda sin
   maná, y no canibaliza ingresos porque no genera tokens en tiempo real.
2. **Retirarlos** — si no se quiere construir esa práctica offline, es más honesto
   eliminarlos que venderlos o regalarlos.

**Recomendación:** opción 1, pero **solo si se compromete el desarrollo**; si no,
retirarlos en la Fase 0.

## 3. Qué genera y qué consume cada recurso

### Oro — «progresión blanda»

| Se gana con | Se gasta en |
|---|---|
| Cierre de sesión (objetivos) | Cosméticos base del catálogo (60–1.200) |
| Misión diaria/semanal | **Repaso de errores del códex** (30 oro) |
| Bolsa de nivel (2,3,5,8,12,15) | Re-toques estéticos de bajo coste |
| Canasta del plan | — |

### Gemas — «premium de estatus»

| Se gana con | Se gasta en |
|---|---|
| **Solo renovación del plan** (canasta) | Cosméticos premium (350–2.800) |
| — | Freeze de racha (30, máx 3) |
| — | Cosmético exclusivo de plan (`min_plan`) |
| — | Desbloqueo de mazmorra temática |

### Pergaminos — «práctica sin IA»

| Se gana con | Se gasta en |
|---|---|
| Recompensa diaria | Sesiones de práctica offline/repaso |
| Hito de racha (7/30 días) | Paquete de 10 ejercicios de vocabulario |
| Canasta del plan | Mazo temático del CEFR actual |

**Regla transversal:** ningún recurso compra aprendizaje evaluado. Ni nivel
CEFR, ni aprobar el Oráculo, ni saltar una misión.

## 4. Alternativas

### Alternativa A · Tres recursos con funciones limpias (recomendada)

- **Oro** = todo lo que se gana jugando → cosméticos base + repaso.
- **Gemas** = exclusivas de suscripción → estatus y comodidad.
- **Pergaminos** = práctica sin IA → aprender sin maná.

**Pro:** cada recurso tiene una promesa distinta y comprensible; el gratuito
puede seguir aprendiendo con pergaminos; las gemas quedan blindadas como valor
de plan.
**Contra:** hay que construir la práctica con pergaminos (coste real) y quitar
las gemas de las misiones (migración de `claim_mission_reward`).
**Coste:** M. **Riesgo:** si la práctica con pergaminos es pobre, el recurso
vuelve a morir.

### Alternativa B · Dos recursos (retirar pergaminos)

- **Oro** = ganado jugando → cosméticos base + repaso.
- **Gemas** = solo plan (y opcionalmente packs) → premium.

**Pro:** la más rápida y la más fácil de explicar; elimina el recurso muerto sin
construir nada nuevo.
**Contra:** el gratuito que se queda sin maná no tiene alternativa; pierdes una
vía de retención.
**Coste:** S. **Riesgo:** baja. Es la opción si hay prisa por estabilizar.

### Alternativa C · Sin moneda premium comprable

- **Oro** = todo lo ganado → repaso y consumibles funcionales.
- **Gemas** = **no existen**; el estatus se gana con logros (títulos, marcos por hito).
- **Pergaminos** = práctica sin IA.

**Pro:** máxima coherencia con «aprender primero»; sin economía de estatus
comprado; sin exploits de moneda premium.
**Contra:** renuncias a monetizar estética por separado; el plan solo se
diferencia por maná/capacidades.
**Coste:** M (rediseño de catálogo y de la tienda). **Riesgo:** medio (pierdes
una palanca de ingresos futura).

## 5. Contadores independientes: cómo hacerlo bien

Tu idea es correcta. Dos implementaciones:

**Opción simple (recomendada para empezar):**
- **Un saldo por recurso**, y el **origen** queda en `currency_ledger.reason`
  (`plan_allowance`, `session_reward`, `mission`, `level`, `purchase`).
- La UI muestra el saldo consolidado y, en el detalle, el desglose «ganado» /
  «de tu plan» calculado desde el libro mayor.
- Ventaja: cero migración de saldos; ya idempotente; auditable.

**Opción con caducidad (solo si quieres que la canasta no se acumule):**
- Cada abono del plan se registra con `expires_at` y el gasto consume primero lo
  que caduca antes (FIFO).
- La UI muestra «de tu plan: 120 · caduca el 30-nov» y «ganado: 340».
- Coste: más complejidad en la RPC de gasto; evitaría el «banco» de un suscriptor
  que vuelve tras meses.

**Regla:** el saldo que ve el usuario es uno; el desglose es informativo. Nunca
dos contadores visibles que tenga que sumar mentalmente.

## 6. Cuadro de fuentes propuesto (números a validar)

| Acción | Oro | Gemas | Pergaminos |
|---|---|---|---|
| Cierre de sesión (por objetivo) | +10 | — | — |
| Misión diaria | +30 | — | — |
| Misión semanal | +80 | — | +1 |
| Recompensa diaria | — | — | +1 |
| Subida de nivel | bolsa 100–800 | — | — |
| Racha 7 / 30 días | +50 / +200 | — | +2 / +5 |
| Renovación plan `noble` | +300 | +50 | +5 |
| Renovación plan `realeza` | +800 | +150 | +10 |

## 7. Veredicto

- **A** si el equipo puede construir la práctica con pergaminos: es la que mejor
  convierte el RPG en un sistema que **premia aprender** y no en una tienda.
- **B** si se quiere estabilizar ya: retirar pergaminos y quedarse con oro y
  gemas.
- **C** si la prioridad absoluta es que nada parezca comprable más allá del plan.

En las tres, dos cosas no cambian: **las gemas dejan de salir de misiones** y
**el contador visible es uno** con el origen registrado en el libro mayor.
