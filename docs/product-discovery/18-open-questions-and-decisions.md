# 18 — Preguntas abiertas y decisiones

> **Estado 2026-10-31: las decisiones ya están aprobadas por Isaac.** Este
> documento conserva el **análisis histórico** (qué se preguntó, qué costaba cada
> opción) y el registro. La **resolución canónica**, la coherencia contra el
> código y el umbral de D-15 viven en
> [`19-canon-and-decisions.md`](19-canon-and-decisions.md) y en
> [`_decisions.md`](_decisions.md). Donde una recomendación de §1 contradiga el
> canon (p. ej. D-01, D-05 o D-10), **manda el canon**.
>
> Contexto: [`12`](12-current-state-and-gaps.md) (estado),
> [`14`](14-game-design-audit.md) (crítica), [`15`](15-improvement-proposals.md)
> (propuestas), [`19`](19-canon-and-decisions.md) (decisiones y brechas).

---

## 1. Decisiones que bloqueaban trabajo (análisis histórico)

> Las columnas "Opciones" y "Recomendación" son el material con el que se decidió.
> **No son estado ni instrucción vigente.** La decisión aprobada está en §4 y en
> [`19` §1](19-canon-and-decisions.md#1-registro-de-decisiones-aprobadas).

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
| **H-02** | El rango solo motiva si abre contenido | Aumento de exámenes de jefe y de retorno tras subir de rango | Cohorte con P-GD-1 vs sin ella | M | Se ajusta la dificultad del examen (D-07 sigue vigente) |
| **H-03** | Un gremio vacío resta más de lo que aporta | Ocultar el gremio no baja la retención (o la sube) | A/B de visibilidad de la pestaña | S | Se refuerza el tablón asíncrono de D-08, no se apaga |
| **H-04** | Un resumen con evidencia aumenta el retorno al día siguiente | Más sesiones D1 en el grupo con nueva copy | A/B de `session_summary` | M | Volver al resumen actual |
| **H-05** | Los cosméticos no motivan porque no expresan identidad | Tras ligar cosméticos a clase/rango, suben las compras | Cohorte con catálogo por clase | M | Retirar crafteo y simplificar tienda |
| **H-06** | Las misiones no se completan por techos irreales | Con techos medidos (10 min/día) la tasa de completado sube | `mission_instances` completadas / activas | S | Revisar `MissionVisibility` |

> **Nota de honestidad estadística:** con 68 usuarios (mayoría de prueba) ninguna
> de estas señales es concluyente. Las hipótesis están para diseñar el
> instrumento, no para afirmar resultados.

---

## 3. Riesgos de no decidir (histórico)

> Ya no aplica como advertencia: las decisiones están tomadas. Se conserva para
> explicar por qué se decidió cada cosa.

| Riesgo | Consecuencia | Decisión que lo evita |
|---|---|---|
| Se sigue construyendo sobre tres metáforas | Copy y UI divergen; cada release añade deuda narrativa | D-01 |
| Se mantienen sistemas muertos "por si acaso" | El jugador aprende a ignorar recompensas y rangos | D-03, D-04, D-05 |
| Se mide solo juego | No se puede defender el producto como herramienta de aprendizaje | D-02, D-15 |
| Se cierra el backlog UX sin ver la app | Se declaran "arreglados" problemas que no se ven | D-13 |
| Se mete un segundo currículo | Bugs de desbloqueo y progreso inconsistente | D-09 |

---

## 4. Registro de decisiones

> **Todas aprobadas el 2026-10-31 por Isaac.** El texto literal de cada decisión
> está en [`_decisions.md`](_decisions.md); la auditoría de cumplimiento, en
> [`19` Parte C](19-canon-and-decisions.md#2-parte-c--coherencia-código--decisión).

| Fecha | ID | Decisión aprobada (resumen) | Aprobada por | Estado | Detalle |
|---|---|---|---|---|---|
| 2026-10-31 | **D-01** | Gremio de aventureros como institución central; nobleza (pago) / plebeyo (gratis); un solo nombre para el jugador y una sola escala de rango | Isaac | ✅ Aprobada | [§2.1](19-canon-and-decisions.md#21-d-01--una-institución-un-nombre-una-escala) |
| 2026-10-31 | **G-01** | Misiones solo del gremio, en 3 capas: del día, contratos y evento semanal | Isaac | ✅ Aprobada | [§2.16](19-canon-and-decisions.md#216-g-01--misiones-solo-del-gremio-en-3-capas) |
| 2026-10-31 | **D-02** | Aprendizaje primero; métricas primarias: frases habladas/semana y retención léxica a 7 días | Isaac | ✅ Aprobada | [§2.2](19-canon-and-decisions.md#22-d-02--aprendizaje-primero-con-dos-métricas-primarias) |
| 2026-10-31 | **D-03** | Una sola racha; el freeze se consume solo al faltar un día | Isaac | ✅ Aprobada | [§2.3](19-canon-and-decisions.md#23-d-03--una-racha-y-un-freeze-que-se-consume-al-faltar) |
| 2026-10-31 | **D-04** | Se retira el battle pass; los títulos de prestigio son el único eje | Isaac | ✅ Aprobada | [§2.4](19-canon-and-decisions.md#24-d-04--retirar-el-battle-pass-títulos-como-único-eje) |
| 2026-10-31 | **D-05** | El pergamino pasa a reintento de lección (el maná sigue cobrándose); se retiran los ítems de maná | Isaac | ✅ Aprobada | [§2.5](19-canon-and-decisions.md#25-d-05--pergamino--reintento-sin-ítems-de-maná) |
| 2026-10-31 | **D-06** | No se regala maná; sin maná, alternativa gratuita sin coste de IA (SRS, listening, Mis errores) | Isaac | ✅ Aprobada | [§2.6](19-canon-and-decisions.md#26-d-06--no-se-regala-maná-y-las-alternativas-cuestan-cero) |
| 2026-10-31 | **D-07** | El rango F–SSS se sube con examen de jefe y desbloquea contenido | Isaac | ✅ Aprobada | [§2.7](19-canon-and-decisions.md#27-d-07--rango-por-examen-y-con-desbloqueo) |
| 2026-10-31 | **D-08** | Gremio asíncrono: tablón y Maestre NPC, sin chat libre en fase 1; voz solo con ≥20 activos/semana | Isaac | ✅ Aprobada | [§2.8](19-canon-and-decisions.md#28-d-08--gremio-asíncrono-sin-chat-libre) |
| 2026-10-31 | **D-09** | La BD manda sobre el currículo; copia local de solo lectura e incremental; contenido y parámetros en BD, lógica en código | Isaac | ✅ Aprobada | [§2.9](19-canon-and-decisions.md#29-d-09--la-bd-manda-doble-currículo) |
| 2026-10-31 | **D-10** | Listening se mantiene como alternativa sin coste; contenido por fases | Isaac | ✅ Aprobada | [§2.10](19-canon-and-decisions.md#210-d-10--listening-se-mantiene-por-fases) |
| 2026-10-31 | **D-11** | Se mantienen precios y trial; se instrumenta para medir | Isaac | ✅ Aprobada | [§2.11](19-canon-and-decisions.md#211-d-11--precios-y-trial-con-instrumentación) |
| 2026-10-31 | **D-12** | Solo inglés | Isaac | ✅ Aprobada | [§2.12](19-canon-and-decisions.md#212-d-12--solo-inglés) |
| 2026-10-31 | **D-13** | Validación visual humana en dispositivo, por release | Isaac | ✅ Aprobada | [§2.13](19-canon-and-decisions.md#213-d-13--validación-visual-humana-por-release) |
| 2026-10-31 | **D-14** | Solo Android | Isaac | ✅ Aprobada | [§2.14](19-canon-and-decisions.md#214-d-14--solo-android) |
| 2026-10-31 | **D-15** | Umbral de continuar / iterar / pivotar definido con las métricas de D-02 | Isaac | ✅ Aprobada (umbral concretado) | [§3](19-canon-and-decisions.md#3-umbral-de-d-15-continuar--iterar--pivotar) |

**Cómo se cambia una decisión (desde ahora):** no se reescribe la existente. Se
abre una decisión nueva con fecha y aprobador, se registra en
[`19` §1](19-canon-and-decisions.md#1-registro-de-decisiones-aprobadas) y en
[`_decisions.md`](_decisions.md), y si contradice `../PRODUCT.md` se actualiza ese
documento en el mismo cambio. Las tareas de implementación se abren en los issues
de GitHub (`hiulett/TutorSaas`).
