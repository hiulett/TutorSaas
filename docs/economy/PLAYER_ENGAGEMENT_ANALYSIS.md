# Motivación, consumo y retención

_Auditoría económica · Fase 5. Solo lectura._

> Pregunta que responde este documento: **¿la economía hace que el usuario vuelva
> a aprender, o solo decora la app?**

---

## 1. El ciclo de motivación, paso a paso

El ciclo que debería existir:

```
entrar → objetivo → actividad educativa → recompensa → gastar
   ↑                                                    ↓
   └──────── nuevo objetivo ← desbloquear/mejorar ←──────┘
```

Estado real de cada eslabón, con evidencia:

| # | Paso | ¿Existe? | Evidencia / hueco |
|---|---|---|---|
| 1 | Entrar al mundo | ✅ | Splash → dashboard con racha, maná y lección |
| 2 | Tener un objetivo | ✅ | «Siguiente paso» del dashboard + misión del día |
| 3 | Actividad educativa | ✅ | Conversación con NPC, Oráculo, listening |
| 4 | Recibir recompensa | ✅ | Oro + fragmentos al cerrar sesión; gemas por misión; XP por turno |
| 5 | **Poder gastar** | ⚠️ | Existe la tienda, pero el oro solo compra **cosméticos** y hay 9 items que no hacen nada |
| 6 | Desbloquear algo | ⚠️ | `required_level` bloquea cosméticos, pero **no se ha verificado que el equipado se aplique** |
| 7 | Mejorar personaje | ❌ | No hay progresión de equipo ni stats: el «personaje» hoy es nivel + cosmético |
| 8 | Nuevo objetivo | ✅ | Niveles 2–20 escalonados con bolsas de oro y cosméticos |

**Diagnóstico del ciclo:** los pasos 1–4 son sólidos y específicos del producto
(la recompensa está atada al cierre de sesión educativa, no a un clic). El ciclo
**se rompe en el 5–6**: el usuario gana recursos que solo sirven para ropa digital
que quizá no puede llevar puesta.

## 2. Mecánicas de retención presentes

| Mecánica | Implementación | Fuerza de retención | Riesgo |
|---|---|---|---|
| **Racha** | `player_streaks`; freeze comprable (30 gemas, máx 3) | Alta si se ve en el dashboard | Pérdida de racha sin aviso = abandono |
| **Recompensa diaria** | Gemas 5 / 50 / 100 / 300 + pergaminos | Media (una por día) | Los pergaminos entregados no sirven |
| **Misiones diarias/semanales/colaborativas** | Semillas en `mission_pool` (3 diarias, 4 semanales, 3 colaborativas) | Alta | Recompensa gema por misión sin techo visible |
| **Drops de sesión** | `claim_session_drop` | Media | Sin garantía de que el drop sea útil |
| **Nivel de cazador** | `1 + XP/1000`, bolsas de oro en 2,3,5,8,12,15 | Alta a largo plazo | Nivel 15 → 20 son 5.000 XP sin recompensa (solo desbloqueo de cosmético) |
| **Cosméticos por nivel** | `required_level` 1–20 | Baja si no se equipan | Ya hay items inalcanzables por precio en gemas |
| **Pase de batalla del gremio** | `guild_battle_pass` existe en esquema | Desconocida | Sin verificar si tiene contenido/rotación |

## 3. Dónde se pierde el usuario

1. **Al agotar el maná diario sin haber cerrado una misión.** El gratuito tiene 200/día ≈ 16 turnos de mazmorra; una misión con objetivos puede consumirlos antes de terminar. El turno de gracia mitiga quedarse «a mitad», no el día siguiente.
2. **Al primer «he ganado oro y no puedo comprar nada»**: el cosmético útil más barato son 60 de oro y el perfil nace con 100, lo que P-32 arregló; pero el siguiente salto de precio es 250–300 y el usuario gratis tarda días.
3. **Al comprar un item muerto** (invocaciones, pergaminos, llaves): la decepción es inmediata y desproporcionada, porque se paga con gemas.
4. **Al perder la racha** por un día de ausencia sin haber entendido el freeze.
5. **En el nivel 15–20**, tramo sin recompensa explícita.

## 4. Motivación para gastar: qué existe y qué falta

Legítimas y presentes:

- **Estética con estatus**: títulos, auras y marcos que el gremio ve.
- **Progresión de acceso**: el nivel desbloquea objetos (motiva a subir).
- **Protección de progreso**: freeze de racha.
- **Colección**: reliquias declaradas (aunque sin ruta de obtención).

Ausentes:

- **Consumo funcional recurrente**: nada se consume habitualmente. Un cosmético se compra una vez.
- **Consumo educativo**: no hay ningún objeto que ayude a estudiar (repaso de errores, mazos temáticos, práctica extra).
- **Consumo social**: no hay regalos ni estatus compartido monetizable.
- **Consumo de experiencia**: no hay mazmorras ni campañas desbloqueables.

**No se propone** comprar ventajas de aprendizaje, ni presión por tiempo, ni cofres de pago con probabilidad oculta.

## 5. Evaluación honesta

**¿La economía retiene?** Sí, como **capa de progresión**: el oro y el nivel dan
una razón para cerrar la sesión y subir de nivel. Pero es una capa **fina y
agotable**: tras comprar 3–4 cosméticos no queda nada que comprar, y no hay
consumibles recurrentes que renueven el motivo.

**¿La economía es una barrera?** Hoy no: nada bloquea aprender. El maná limita la
práctica, y esa es una decisión consciente del producto. El riesgo es que, al
añadir monetización, esa línea se cruce por accidente.

**El problema de retención no es la economía.** Con todas las mecánicas
presentes, el abandono probable viene de (a) fricción del pipeline de voz,
(b) sesiones que no se cierran/apuntan y (c) falta de objetivo visible de largo
plazo. La economía puede amplificar la retención, pero **no la crea**.

## 6. Las tres palancas con más retorno

1. **Cerrar el ciclo de gasto**: que el cosmético comprado **se vea** (perfil,
   gremio, burbuja del chat) y que haya un objeto de cada pocos niveles a precio
   alcanzable.
2. **Un consumible educativo recurrente** y barato (repaso de errores del códex
   con fragmentos): da uso semanal a la moneda blanda y refuerza el aprendizaje.
3. **Consumo de experiencia**: una mazmorra temática desbloqueable por gemas o
   por progreso; añade un objetivo de medio plazo sin tocar el plan de estudios.

## 7. No verificable

- Si el equipado de cosméticos se persiste y se pinta.
- Rotación y premios reales del `guild_battle_pass`.
- Curva real de abandono (no hay analítica de retención consultada).
