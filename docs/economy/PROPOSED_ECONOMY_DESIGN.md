# Economía objetivo: diseño propuesto

_Auditoría económica · Fase 7. Diseño, no implementación. **Todas las cifras son
propuestas a validar con datos**, no decisiones tomadas._

> Principio rector: la economía debe sentirse parte del mundo, pero **el eje
> sigue siendo aprender**. Ninguna regla de este documento puede comprar
> progreso académico.

---

## 1. Arquitectura: cuatro recursos, cuatro funciones

Se mantienen los cuatro recursos actuales porque ya tienen funciones disjuntas.
**No se añade ninguna moneda nueva.**

| Recurso | Función | Se gana | Se gasta | Cambio propuesto |
|---|---|---|---|---|
| **Maná** | Combustible de IA | Plan mensual + pociones | Turnos de IA (servidor) | Mantener; revisar el tope de 200/día con `ai_usage_logs` |
| **Oro** | Progresión blanda | Cierre de sesión, bolsas de nivel | Cosméticos base, **repaso de errores** | Añadir un sumidero recurrente |
| **Gemas** | Estética premium | Misiones, diaria, **paquetes** | Cosméticos premium, freeze, **contenido** | Dar entrada de dinero (O-1) y uso de contenido (O-2) |
| **Fragmentos** | Fabricación | Cierre de sesión | Crafteo + **repaso** | Mantener, dar salida semanal |

**Se retiran:**
- **Pergaminos** (se entregan y no se gastan) → convertir la recompensa diaria a oro o fragmentos.
- **Invocaciones** → el límite real es el maná; el contador muerto y sus 4 items de tienda se eliminan.

## 2. Reglas duras (no negociables)

1. **Ningún recurso compra aprendizaje evaluado.** Ni niveles CEFR, ni saltar misiones, ni aprobar el Oráculo.
2. **Ningún precio vive en el cliente.** Ya se cumple: el servidor lee el catálogo.
3. **Todo movimiento pasa por el libro mayor** con `ref_key` idempotente. Ya se cumple.
4. **Un item, un precio.** Nada de doble precio oro/gemas para el mismo objeto (canibaliza la moneda premium). El objeto premium es **solo gemas**; el base **solo oro**.
5. **Ningún item se vende sin efecto verificado.** Regla de catálogo: si no tiene consumidor en código, no está en la tienda.
6. **La suscripción da capacidades, no ventaja de juego**: historial, informe, cosméticos con `min_plan`.

## 3. Fuentes y sumideros objetivo

### Fuentes (por sesión cerrada, usuario gratuito activo)

| Fuente | Propuesta | Razón |
|---|---|---|
| Cierre de sesión | 10 oro + 5 fragmentos por objetivo | Ya existe; se mantiene |
| Misión diaria | 15–30 gemas | Ya existe; poner techo diario |
| Recompensa diaria | 5 / 10 / 20 / 40 gemas + oro (sin pergaminos) | Renovar el hábito sin recurso muerto |
| Nivel | Bolsas 100–800 oro (2,3,5,8,12,15) | Ya existe |
| **Nuevo**: racha de 7 días | 1 fragmento extra/día y objeto del catálogo a los 30 | Da valor al freeze |

### Sumideros

| Sumidero | Propuesta | Frecuencia | Recurso |
|---|---|---|---|
| Cosmético base | 60–1.200 oro | Única | Oro |
| Cosmético premium | 350–2.800 gemas | Única | Gemas |
| Freeze de racha | 30 gemas, máx 3 | Según riesgo | Gemas |
| Crafteo | 120/250/400 fragmentos | Única | Fragmentos |
| **Nuevo**: Repaso de errores del códex | 20 fragmentos o 30 oro por sesión de repaso | **Semanal recurrente** | Fragmentos/Oro |
| **Nuevo**: Mazmorra temática | 150–300 gemas o pago único | Estacional | Gemas/dinero |
| Maná | 12/15/30 por turno | Continuo | Maná |

**Objetivo de balance:** `sink_ratio` de oro entre **0.4 y 0.7** en usuarios
activos. Por debajo, el oro sobra (hay que añadir sumideros, no bajar precios).
Por encima de 0.8, el catálogo se queda corto.

## 4. Recorrido integrado (ejemplo numérico, no balanceado)

```
Día 0  Registro → onboarding → Oráculo → perfil con 100 oro.
Día 1  Primera sesión: 3 objetivos → +30 oro, +15 fragmentos, +5 gemas diarias.
       Nivel 2 alcanzado → bolsa +100 oro (total 230).
       Tienda: emote 60 oro (asequible) → primera compra del usuario.
Día 3  Misión diaria cumplida → +20 gemas. Racha 3 días.
       Ve título premium de 500 gemas → objetivo de medio plazo.
Día 7  Racha 7 → fragmento extra. Craftea marco de 250 fragmentos.
       Compra un paquete de 300 gemas (dinero real) para el título de 500.
Día 15 Nivel 8 → bolsa +400 oro. Compra marco de 900.
Día 30 Racha 30 → reliquia Llave del Tiempo (colección).
       Mazmorra temática de temporada → gemas o pago único.
```

Dónde entra el dinero real: **paquetes de gemas**, **suscripción** y
**expansiones**. Dónde entra la economía virtual: todo lo demás. El usuario que
nunca paga completa el recorrido igual, solo más despacio en lo estético.

## 5. Personas y experiencia económica

| Perfil | Cómo vive la economía |
|---|---|
| **Gratuito** | 200 maná/día, oro y fragmentos por sesión, compra 2–3 cosméticos base. Aprende sin fricción; el cosmético premium es aspiracional |
| **Suscrito (noble)** | 17.000 maná, 4 semanas de informe, cosméticos `min_plan`. Percibe capacidad, no ventaja |
| **Compra ocasional** | Paquete de gemas cuando un cosmético le gusta; 1–2 veces al año |
| **Muy activo** | Agota el catálogo base; necesita contenido y colecciones nuevas cada temporada |
| **Casual** | Entra 2–3 veces/semana; racha con freeze; recompensa diaria es su ancla |
| **Coleccionista** | Reliquias, sets, títulos de hito. Necesita catálogo amplio y trazabilidad de "cómo se consigue" |
| **Solo aprende** | Ignora la tienda; la economía no debe estorbarle. Ningún muro de pago en el camino educativo |

**Criterio de éxito transversal:** el usuario «solo aprende» debe poder llegar a
B1 sin tocar la economía, y sin que la app le recuerde constantemente que existe.

## 6. Qué cambia respecto a hoy (resumen)

| Cambio | Tipo | Motivo |
|---|---|---|
| Retirar pergaminos e invocaciones (recurso y 4 items) | Eliminar | Recurso muerto y cobro sin valor |
| Retirar los 5 items sin implementación (llaves, libros) | Eliminar | Cobro sin valor |
| Un precio por item (no dual oro/gemas) | Modificar | Proteger la moneda premium |
| Añadir repaso de errores como consumible | Incorporar | Sumidero recurrente + valor educativo |
| Paquetes de gemas + suscripción anual | Incorporar | Ingresos con coste bajo |
| Temporada/mazmorra desbloqueable | Incorporar | Objetivo de medio plazo |
| Cerrar exploits de misión | Corregir | Integridad (P0) |

## 7. Riesgos del diseño

1. **Complejidad percibida**: cuatro recursos ya son muchos para un usuario nuevo. Mitigación: la tienda tiene 3 pestañas y el tutorial solo presenta oro y gemas.
2. **Repaso de errores como paywall educativo**: debe poder pagarse con **recursos ganados**; el pago acelera, no abre.
3. **Contenido estacional que se convierte en obligación**: si la mazmorra de temporada es el único contenido nuevo útil, el usuario que no paga se queda atrás → el plan de estudios base nunca puede depender de ella.

## 8. Lo que este diseño NO propone

- Más monedas.
- Conversión entre monedas.
- Loot boxes o azar de pago.
- Venta de XP, niveles o CEFR.
- Anuncios.
