# 18 — Preguntas abiertas y decisiones pendientes

> Este documento no decide: **propone** y marca lo que necesita aprobación del
> dueño del producto. Cada decisión incluye la opción recomendada y su coste.
> Hasta que se apruebe, el comportamiento actual no cambia.
>
> Contexto: [`12`](12-current-state-and-gaps.md) (estado),
> [`14`](14-game-design-audit.md) (crítica), [`15`](15-improvement-proposals.md)
> (propuestas).

---

## 1. Decisiones que bloquean trabajo

| ID | Pregunta | Por qué ahora | Opciones | Recomendación | Coste de la recomendación | Bloquea a |
|---|---|---|---|---|---|---|
| **D-01** | ¿Cuál es la metáfora dominante del universo? | Hay tres (cazador de mazmorras, estamento feudal, gremio de taberna) y cuatro nombres para el jugador | (a) Cazador del Sistema; (b) Estamento feudal; (c) Gremio de taberna; (d) mezcla declarada con jerarquía | **(a) Cazador del Sistema** con el gremio como institución. Retirar "estamento" del copy de pago | 1 documento de canon + reescritura de ~20 claves `.arb` (M) | P-NAR-1, P-NAR-2, copy de paywall |
| **D-02** | ¿El norte del producto es aprendizaje o juego? | Todas las métricas actuales miden juego (XP, oro), ninguna mide aprendizaje | (a) Aprendizaje primero; (b) Juego primero; (c) Ambos con métrica doble | **(a)** con métrica secundaria de juego. Métrica primaria: *frases habladas/semana* y *retención léxica a 7 días* | Definir instrumentación (S) + cambiar resumen y rango (L) | P-ECO-1, P-LRN-1, P-GD-1 |
| **D-03** | ¿La racha se arregla o se retira? | Hoy hay dos tablas y el freeze no protege; 4/52 usuarios con datos divergentes | (a) Una sola racha + freeze consumido automáticamente; (b) Retirar racha y freeze | **(a)** si la racha es KPI de retención; si no, (b) | (a) M: migrar a `player_streaks`, consumir freeze en `register_practice`; (b) S: ocultar | P-GD-3, tienda de gemas |
| **D-04** | ¿Battle pass: temporada real o retirada? | 23 filas en nivel 1, 0 funciones que lo suban; se pinta como "PRESTIGIO" | (a) Temporada de 30 niveles; (b) Retirar y dejar títulos; (c) Dejar congelado | **(b) retirar** hasta que la retención justifique una temporada | S (retirar UI) / L (si (a)) | P-GD-3, P-NAR-1 |
| **D-05** | ¿Pergaminos e ítems de maná se productizan o se retiran? | 0 instancias en producción; se anuncian en la recompensa diaria | (a) Retirar de UI; (b) Convertir pergamino en reintento de lección; (c) Dejarlos | **(a)** ahora; (b) si se implanta P-LRN-1 | S | P-ECO-2, P-GD-3 |
| **D-06** | ¿Se vuelve a vender maná suelto? | El CTA "Obtener maná" abre el paywall; la venta directa está retirada desde P-32 | (a) Mantener retirada y renombrar CTA; (b) Reintroducir packs de maná | **(a)** con alternativa gratuita visible (turno de gracia / mañana) | S copy + jerarquía | P-ECO-2, P-NAR-2 |
| **D-07** | ¿El rango F–SSS abre contenido o queda como etiqueta? | Hoy es un sinónimo del CEFR; la fantasía de ascenso no existe | (a) Rango con examen y desbloqueos; (b) Rango solo cosmético; (c) Eliminar rango | **(a)** | L (gating + UI + recompensas) | P-GD-1, P-ECO-1 |
| **D-08** | ¿Gremio asíncrono o apagado hasta tener masa? | 0 participantes, 199 quests sin usar, sala etiquetada DEMO | (a) Tablón asíncrono + NPC; (b) Apagar voz y dejar tablón; (c) Apagar todo | **(a)** fase 1 sin chat libre | M | P-GD-2, P-GD-4 |
| **D-09** | ¿Qué currículo manda: Dart o BD? | Dos currículos y dos criterios de completada (#202, #203) | (a) `scenarios` en runtime, Dart como seed; (b) Dart manda y BD es contenido; (c) Mantener ambos | **(a)** | L (migración, caché, doble lectura) | P-LRN-3, ruta de lecciones |
| **D-10** | ¿Se invierte en listening o se retira del camino? | 3 ejercicios y 0 intentos | (a) 20–40 ejercicios por nivel; (b) Retirar del path hasta tener contenido; (c) Dejar como está | **(b)** mientras no haya contenido; (a) si se aprueba presupuesto de contenido | S (b) / L (a) | P-LRN-2 |
| **D-11** | ¿Se mantiene el precio y el trial? | 2 planes activos ($4.99 / $9.99), trial 7 días, **0 pagos** registrados | (a) Mantener y probar trial; (b) Bajar precio; (c) Añadir plan anual | **(a)**; no mover precio sin datos de intención | S (instrumentar) / M (experimento) | P-ECO-2, paywall |
| **D-12** | ¿Se añaden idiomas objetivo? | Solo inglés; el universo se llama "Dungeon of English" | (a) Solo inglés hasta validar; (b) Añadir segundo idioma | **(a)** | 0 | Currículo, prompts, i18n |
| **D-13** | ¿Quién firma la validación visual y con qué dispositivo? | Todo el backlog UX queda abierto sin capturas; el entorno no tiene visión ni móvil | (a) Sesión humana con dispositivo + `screenshots/README.md`; (b) Aplazar y aceptar deuda | **(a)** una sesión por release | 1–2 h humanas | Cierre de #239 y de los 39 hallazgos |
| **D-14** | ¿Se permite iOS? | Regla actual: Android únicamente | (a) No; (b) Sí | **(a)** mantener | 0 | Nada (regla vigente) |
| **D-15** | ¿Qué umbral decide continuar, iterar o pivotar? | Sin umbral, cualquier resultado se puede interpretar a favor | (a) Definir ahora (p. ej. D7 ≥ 25 % con ≥100 usuarios y ≥30 % de sesiones con ≥3 turnos); (b) Definir tras el próximo release | **(a)**, antes de la próxima campaña | S (documento + dashboard) | Todas las propuestas |

---

## 2. Hipótesis a validar (no son hechos)

Cada hipótesis es falsable con datos que la app **ya puede** registrar o con un
experimento pequeño. Ninguna se usa como base de una propuesta sin marcarla.

| ID | Hipótesis | Señal que la confirmaría | Cómo medirla | Coste | Si se falsa |
|---|---|---|---|---|---|
| **H-01** | El muro de maná es la principal causa de abandono de sesión | Muchos cierres justo al recibir `daily_limit_reached` | Evento de bloqueo + siguiente acción (`analytics_events`) | S | Revisar P-ECO-2 y el turno de gracia |
| **H-02** | El rango solo motiva si abre contenido | Aumento de exámenes de jefe y de retorno tras subir de rango | Cohorte con P-GD-1 vs sin ella | M | Rango queda cosmético (D-07 opción b) |
| **H-03** | Un gremio vacío resta más de lo que aporta | Ocultar el gremio no baja la retención (o la sube) | A/B de visibilidad de la pestaña | S | Apagar gremio (D-08 opción c) |
| **H-04** | Un resumen con evidencia aumenta el retorno al día siguiente | Más sesiones D1 en el grupo con nueva copy | A/B de `session_summary` | M | Volver al resumen actual |
| **H-05** | Los cosméticos no motivan porque no expresan identidad | Tras ligar cosméticos a clase/rango, suben las compras | Cohorte con catálogo por clase | M | Retirar crafteo y simplificar tienda |
| **H-06** | Las misiones no se completan por techos irreales | Con techos medidos (10 min/día) la tasa de completado sube | `mission_instances` completadas / activas | S | Revisar `MissionVisibility` |

> **Nota de honestidad estadística:** con 68 usuarios (mayoría de prueba) ninguna
> de estas señales es concluyente. Las hipótesis están para diseñar el
> instrumento, no para afirmar resultados.

---

## 3. Riesgos de no decidir

| Riesgo | Consecuencia | Decisión que lo evita |
|---|---|---|
| Se sigue construyendo sobre tres metáforas | Copy y UI divergen; cada release añade deuda narrativa | D-01 |
| Se mantienen sistemas muertos "por si acaso" | El jugador aprende a ignorar recompensas y rangos | D-03, D-04, D-05 |
| Se mide solo juego | No se puede defender el producto como herramienta de aprendizaje | D-02, D-15 |
| Se cierra el backlog UX sin ver la app | Se declaran "arreglados" problemas que no se ven | D-13 |
| Se mete un segundo currículo | Bugs de desbloqueo y progreso inconsistente | D-09 |

---

## 4. Registro de decisiones

| Fecha | ID | Decisión | Aprobada por | Nota |
|---|---|---|---|---|
| — | D-01 | Pendiente | — | — |
| — | D-02 | Pendiente | — | — |
| — | D-03 | Pendiente | — | — |
| — | D-04 | Pendiente | — | — |
| — | D-05 | Pendiente | — | — |
| — | D-06 | Pendiente | — | — |
| — | D-07 | Pendiente | — | — |
| — | D-08 | Pendiente | — | — |
| — | D-09 | Pendiente | — | — |
| — | D-10 | Pendiente | — | — |
| — | D-11 | Pendiente | — | — |
| — | D-12 | Pendiente | — | — |
| — | D-13 | Pendiente | — | — |
| — | D-15 | Pendiente | — | — |

**Cómo cerrar una decisión:** marcar la opción, escribir la fecha y el nombre, y
abrir el issue de implementación correspondiente. Si la decisión contradice
`docs/PRODUCT.md`, actualizar ese documento en el mismo cambio (es la fuente de
verdad de producto).
