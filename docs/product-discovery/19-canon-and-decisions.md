# 19 — Canon, decisiones aprobadas y coherencia

> **Qué es este documento.** (1) El **registro** de las 15 decisiones canónicas
> (D-01…D-15) y de la decisión de misiones (**G-01**), aprobadas por **Isaac** el
> **2026-10-31**; (2) la **Parte C**: auditoría del código y de los datos de
> producción **contra** esas decisiones, con la brecha y su evidencia; (3) el
> **umbral de D-15** (continuar / iterar / pivotar) con las métricas de D-02 y las
> cifras de partida.
>
> **Las decisiones no se cuestionan.** Este documento no propone alternativas: mide
> distancia. Toda propuesta que contradiga una decisión se elimina de
> [`15`](15-improvement-proposals.md).
>
> **Medido:** 2026-10-31 sobre `origin/master` (worktree `p14-ai-usage`) y
> producción `sipiumfdpvnszthykyog`, solo lectura. Cifras base en
> [`_baseline.md`](_baseline.md). Estado previo en [`12`](12-current-state-and-gaps.md)
> y crítica de juego en [`14`](14-game-design-audit.md).

---

## 0. Cómo leer la Parte C

| Etiqueta | Significa (en este documento) |
|---|---|
| `[IMPLEMENTADO]` | El comportamiento pedido por la decisión ya ocurre y se puede rastrear |
| `[PARCIAL]` | Ocurre a medias: existe la pieza pero no el recorrido completo |
| `[CONCEPTUAL]` | Solo existe como tabla, clave de texto o proveedor sin productor |
| `[PENDIENTE DE VALIDAR]` | No verificable desde este entorno (visión, dispositivo, tienda) |
| `[PROPUESTA]` | Idea de mejora; **nunca** se usa como si fuera estado |

Cada decisión lleva: **estado actual** (hecho), **estado objetivo** (lo que pide
la decisión), **brecha** (distancia) y **evidencia** (`archivo:línea`, RPC o
consulta). Lo que es inferencia se marca como tal; lo que no se pudo comprobar,
también.

---

## 1. Registro de decisiones (aprobadas)

| ID | Fecha | Aprobador | Decisión (literal de `_decisions.md`) | Estado | Parte C |
|---|---|---|---|---|---|
| **D-01** | 2026-10-31 | Isaac | Gremio de aventureros como institución central; nobleza (pago) / plebeyo (gratis); **un solo nombre** para el jugador y **una sola escala de rango** | Aprobada | [§2.1](#21-d-01--una-institución-un-nombre-una-escala) |
| **G-01** | 2026-10-31 | Isaac | Misiones **solo del gremio**, en **3 capas**: del día, contratos y evento semanal | Aprobada | [§2.16](#216-g-01--misiones-solo-del-gremio-en-3-capas) |
| **D-02** | 2026-10-31 | Isaac | **Aprendizaje primero**; métricas primarias: **frases habladas/semana** y **retención léxica a 7 días** | Aprobada | [§2.2](#22-d-02--aprendizaje-primero-con-dos-métricas-primarias) |
| **D-03** | 2026-10-31 | Isaac | **Una sola racha**; el freeze se consume **solo al faltar un día** | Aprobada | [§2.3](#23-d-03--una-racha-y-un-freeze-que-se-consume-al-faltar) |
| **D-04** | 2026-10-31 | Isaac | Se **retira el battle pass**; los **títulos de prestigio** son el único eje | Aprobada | [§2.4](#24-d-04--retirar-el-battle-pass-títulos-como-único-eje) |
| **D-05** | 2026-10-31 | Isaac | El **pergamino** pasa a **reintento de lección** (el maná sigue cobrándose); se **retiran los ítems de maná** | Aprobada | [§2.5](#25-d-05--pergamino--reintento-sin-ítems-de-maná) |
| **D-06** | 2026-10-31 | Isaac | **No se regala maná**; sin maná, la alternativa gratuita son actividades **sin coste de IA** (SRS, listening, Mis errores) | Aprobada | [§2.6](#26-d-06--no-se-regala-maná-y-las-alternativas-cuestan-cero) |
| **D-07** | 2026-10-31 | Isaac | El rango **F–SSS se sube con examen de jefe** y **desbloquea contenido** | Aprobada | [§2.7](#27-d-07--rango-por-examen-y-con-desbloqueo) |
| **D-08** | 2026-10-31 | Isaac | **Gremio asíncrono**: tablón de contratos y Maestre NPC, **sin chat libre** en fase 1; mesas de voz solo con **≥20 activos/semana** | Aprobada | [§2.8](#28-d-08--gremio-asíncrono-sin-chat-libre) |
| **D-09** | 2026-10-31 | Isaac | **La BD manda** sobre el currículo; copia local de solo lectura e incremental. **Contenido y parámetros en BD, lógica en código** | Aprobada | [§2.9](#29-d-09--la-bd-manda-doble-currículo) |
| **D-10** | 2026-10-31 | Isaac | **Listening se mantiene** como alternativa sin coste; contenido por fases | Aprobada | [§2.10](#210-d-10--listening-se-mantiene-por-fases) |
| **D-11** | 2026-10-31 | Isaac | Se mantienen **precios y trial**; se instrumenta para medir | Aprobada | [§2.11](#211-d-11--precios-y-trial-con-instrumentación) |
| **D-12** | 2026-10-31 | Isaac | **Solo inglés** | Aprobada | [§2.12](#212-d-12--solo-inglés) |
| **D-13** | 2026-10-31 | Isaac | **Validación visual humana** en dispositivo, **por release** | Aprobada | [§2.13](#213-d-13--validación-visual-humana-por-release) |
| **D-14** | 2026-10-31 | Isaac | **Solo Android** | Aprobada | [§2.14](#214-d-14--solo-android) |
| **D-15** | 2026-10-31 | Isaac | **Umbral** de continuar / iterar / pivotar definido con las métricas de D-02 | Aprobada (umbral concretado; cifras revisables) | [§3](#3-umbral-de-d-15-continuar--iterar--pivotar) |

> **Nota de proceso.** El registro vive aquí y [`18` §4](18-open-questions-and-decisions.md)
> apunta a este documento. Si una decisión cambia, se versiona con fecha nueva en
> los dos sitios y se actualiza `_decisions.md`; nunca se reescribe el histórico.

---

## 2. Parte C — coherencia código ↔ decisión

### Resumen

| ID | Estado | Brecha en una línea | Impacto |
|---|---|---|---|
| D-01 | `[PARCIAL]` | Cuatro nombres para el jugador, tres etiquetas de rango visibles y "estamento" en el copy de pago | **Alto** |
| G-01 | `[PARCIAL]` | Solo existe la capa "del día"; contratos y evento no tienen UI ni productor | **Alto** |
| D-02 | `[PARCIAL]` | Se emite telemetría de sesión e IA, pero **no** de frases habladas ni de retención léxica | **Alto** |
| D-03 | `[PARCIAL]` | Dos rachas y un freeze que **nunca se consume**; la racha se reinicia a 1 | **Alto** |
| D-04 | `[PARCIAL]` | El battle pass sigue visible como chip "PRESTIGIO" y con 23 filas congeladas | **Alto** |
| D-05 | `[PARCIAL]` | El pergamino no reintenta nada y se regala en la recompensa diaria; quedan ítems de maná en UI | **Medio** |
| D-06 | `[PARCIAL]` | No se vende maná suelto, pero hay **1 turno de IA gratis/día** (contradice la decisión) y el CTA vende membresía como maná | **Medio** |
| D-07 | `[PARCIAL]` | El examen de jefe existe y escribe rango, pero no desbloquea contenido y nunca se ha usado | **Alto** |
| D-08 | `[PARCIAL]` | Hay **chat libre** en la sala de voz (0 mensajes) y no hay tablón; el umbral de 20 activos no existe | **Alto** |
| D-09 | `[PARCIAL]` | Doble currículo y doble criterio: **10 de 17** lecciones medidas discrepan | **Alto** |
| D-10 | `[PARCIAL]` | Módulo y ruta existen; 3 ejercicios y 0 intentos | Medio |
| D-11 | `[PARCIAL]` | Precios y trial correctos; 0 pagos en el libro y 1 evento `purchase_succeeded` sin reconciliar | Medio |
| D-12 | `[IMPLEMENTADO]` | Nada que corregir | — |
| D-13 | `[CONCEPTUAL]` | Carpeta `screenshots/` sin capturas válidas ni acta de sesión visual | **Alto** (bloquea cierre UX) |
| D-14 | `[IMPLEMENTADO]` | No existe `ios/` | — |
| D-15 | `[PENDIENTE DE VALIDAR]` | Umbral definido aquí; **hoy no es medible** (1 usuario activo/semana) | **Alto** |

---

### 2.1 D-01 · Una institución, un nombre, una escala

**Decisión.** Gremio de aventureros como institución central; nobleza (pago) y
plebeyo (gratis) como jerarquía declarada; **un solo nombre** para el jugador y
**una sola escala de rango**.

**Estado actual** `[PARCIAL]`

| Elemento | Realidad medida | Evidencia |
|---|---|---|
| Nombre del jugador | **Cuatro**: "Hunter" (UI en inglés y eslogan), "cazador" (comentarios y banner de voz), "aventurero" (comentarios de dominio), "Usuario del Aura" (ficción del Aura) | `dashboard_screen.dart:331-332`; `app_localizations_en.dart:15,488`; `voice_room_screen.dart:703`; `aura_system.dart:7-8`; `mission_repository.dart:99` |
| Jerarquía nobleza/plebeyo | Existe como planes (`plebeyo` 3.000 maná/mes, `noble` 17.000, `realeza` 20.500) pero el copy la llama **"estamento"** | `subscription_plans` (`plebeyo`, `noble`, `realeza`); `app_localizations_es.dart:1655,3696` |
| Escalas de rango | **Tres etiquetas distintas**: `F–SSS` (perfil), `HIERRO/PLATA/ORO` (cabecera del gremio derivada del CEFR), `PRESTIGIO N` (battle pass) + `prestige_ladder` (21 escalones) | `cefr_rank.dart:3-4,73`; `chat_rooms_screen.dart:993-1011,1049-1066`; `app_localizations_es.dart:1138`; `prestige_ladder` = 21 filas |
| Gremio como institución | La pestaña existe y se llama "GUILD HALL", pero 0 participantes y 0 mensajes | `chat_rooms_screen.dart`; `chat_room_participants` = 0; `chat_room_messages` = 0 |

**Estado objetivo.** Un glosario único ([`16`](16-product-glossary.md)), un solo
nombre ("aventurero"), "estamento" retirado del copy y **una** escala de rango
(F–SSS) con una sola fuente.

**Brecha.**

1. **Nombre**: 4 términos en UI y comentarios. Palabras de UI: "Hunter"/
   "Hunters" (en), "cazadores" (banner de voz), "aventurero" (comentarios),
   "Usuario del Aura" (ficción). Requiere reescritura de claves `.arb` y de
   nombres de clase (`HunterCatalog`, `HunterHudHeader`) — solo texto visible
   obliga; los símbolos internos pueden esperar.
2. **"Estamento"**: el término canónico para la jerarquía es **nobleza/plebeyo**
   (planes del gremio). "Estamento" debe desaparecer del copy de paywall y de la
   descripción de planes en BD (`subscription_plans.description` de `realeza`).
3. **Escalas**: `F–SSS` convive con `HIERRO/PLATA/ORO` (cabecera del gremio) y con
   `PRESTIGIO N`. La segunda es puramente cosmética y no tiene respaldo en BD; la
   tercera es el battle pass que D-04 retira.
4. **Institución vacía**: el gremio no produce misiones (ver G-01), así que la
   "institución central" hoy no organiza nada del bucle diario.

**Criterio de cierre.** `grep` sin resultados de `estamento`, `Hunter` en texto
visible y `HIERRO|PLATA|ORO`; una sola función de rango usada por dashboard,
gremio y misiones; glosario aplicado en los 3 `.arb` + `gen-l10n`.

---

### 2.2 D-02 · Aprendizaje primero, con dos métricas primarias

**Decisión.** Métricas primarias: **frases habladas por semana** y **retención
léxica a 7 días**. El juego es el motor, no el norte.

**Estado actual** `[PARCIAL]`

| Métrica | ¿Se puede medir hoy? | Evidencia |
|---|---|---|
| Frases habladas/semana | **Parcial**: existe el registro por frase (`user_scenario_phrases`, 20 filas / 7 usuarios) pero **no** hay evento ni vista semanal | `user_scenario_phrases` (`phrase_text`, `is_completed`, `completed_at`); `analytics_events` no tiene evento de frase |
| Retención léxica a 7 días | **No**: hay palabras y repasos, pero ninguna vista/consulta que mida "palabra retenida a 7 días" | `user_vocabulary` = 79; `vocabulary_reviews` = 7; `analytics_retention` mide **cohortes de app** (`cohort, day_offset, users`), no léxico |
| Telemetría existente | Sesión e IA: `invoke_llm` 433, `session_start` 21, `session_end` 11, `app_open` 20 | `analytics_events` (511 filas) |
| Retención de app | Vista disponible pero con 1–2 usuarios por semana | `analytics_sessions_per_week` (semana 2026-10-26: 4 sesiones / **1** usuario) |

**Estado objetivo.** Un dashboard con dos cifras primarias semanales, calculadas
en BD (D-09: lógica en código/BD, no en el cliente) y visibles en el informe
semanal.

**Brecha.** No existe la consulta "frases habladas/semana" ni el cálculo de
retención a 7 días; el resumen de sesión muestra cifras fijas (ver [`12`](12-current-state-and-gaps.md)
y [`14`](14-game-design-audit.md)). Mientras no existan, **ninguna** de las
propuestas de aprendizaje se puede evaluar.

**Criterio de cierre.** Una vista `analytics_learning_week` (o equivalente) con
`phrases_spoken` por usuario/semana y `lexical_retention_7d` por cohorte de
palabras; ambas citadas en el informe semanal y en `19` §3.

---

### 2.3 D-03 · Una racha y un freeze que se consume al faltar

**Decisión.** **Una sola racha**; el freeze se consume **solo al faltar un día**.

**Estado actual** `[PARCIAL]`

- **Dos fuentes de racha.** `user_language_profiles.current_streak` (la que se
  pinta) y `player_streaks` (52 filas, con columna `streak_freezes`) que **nadie
  lee ni escribe** en el flujo de práctica.
- **El servidor no consume freeze.** `register_practice` calcula:
  `si last_practice_date < hoy-1 → streak := 1`. No consulta
  `player_streaks.streak_freezes` ni `user_subscriptions`.
- **El freeze se puede comprar** (`purchase_streak_freeze`) y existe el trigger
  `guard_player_streak_freezes`, pero **no hay consumo**: el jugador paga por un
  objeto inerte.
- **Espejo en cliente**: `StreakRules.nextStreak` replica el reinicio a 1
  (`streak_rules.dart:14-26`).

**Evidencia.** RPC `register_practice` (rama `diff > 1 → 1`);
`player_streaks.streak_freezes`; RPC `purchase_streak_freeze`;
`guard_player_streak_freezes`; `streak_rules.dart:19-25`.

**Estado objetivo.** Una única tabla de racha (la de `player_streaks` o la del
perfil, no ambas); al detectar un hueco de **exactamente un día**, el servidor
descuenta un freeze y mantiene la racha; si no hay freeze, reinicia. El cliente
solo pinta lo que devuelve el servidor.

**Brecha.** (1) Consolidar tablas; (2) implementar el consumo en
`register_practice`; (3) decidir qué pasa con la UI de compra de freeze si nunca
se consume (hoy promete algo que no ocurre).

**Criterio de cierre.** Un test SQL/RPC que: falte un día con freeze → racha
intacta y freeze-1; falte un día sin freeze → racha 1; falten dos días → racha 1
aunque haya freeze. `player_streaks` y el perfil deben coincidir tras cada
práctica.

---

### 2.4 D-04 · Retirar el battle pass; títulos como único eje

**Decisión.** Se **retira el battle pass**; los **títulos de prestigio** son el
único eje.

**Estado actual** `[PARCIAL]` (existe el eje correcto y **también** el retirado)

| Pieza | Estado | Evidencia |
|---|---|---|
| Títulos de prestigio (eje canónico) | `[IMPLEMENTADO]`: `prestige_ladder` 21 escalones, `hunter_titles` 24, `user_titles` 12; RPC `compute_prestige_title` / `get_prestige_title`; `aura_xp` sin tope | BD; `aura_system.dart:27-31`; `dashboard_providers.dart:703-734` |
| Battle pass (a retirar) | `[PARCIAL]`: 23 filas, **todas en nivel 1**, 0 funciones que lo suban; se pinta como chip "PRESTIGIO {nivel}" en la cabecera del gremio | `guild_battle_pass` (23×nivel 1, `is_premium=false`); `chat_rooms_screen.dart:1012-1066`; `app_localizations_es.dart:1138`; `battlePassProvider` (`economy_providers.dart:119-130`) |
| Copy | La clave `battle_pass` sigue existiendo en los 3 idiomas | `app_localizations_en.dart:1776` |

**Estado objetivo.** Sin chip de prestigio numérico, sin `battlePassProvider`,
sin lectura de `guild_battle_pass`; el título de prestigio (ladder de Aura) es lo
único que se muestra y lo único que evoluciona.

**Brecha.** Retirar UI + provider + lectura; conservar la tabla (histórico) o
marcarla deprecada. El "PRESTIGIO {level}" que hoy ve el jugador es un eje muerto
que compite con el eje vivo.

**Criterio de cierre.** `grep` sin `battlePassProvider`/`guild_battle_pass` en
`lib/`; el gremio muestra solo el título; ninguna clave `battle_pass` en `.arb`
(se puede conservar la clave sin uso, pero no debe renderizarse).

---

### 2.5 D-05 · Pergamino = reintento, sin ítems de maná

**Decisión.** El **pergamino** pasa a ser **reintento de lección** (el maná sigue
cobrándose); se **retiran los ítems de maná**.

**Estado actual** `[CONCEPTUAL]` para el pergamino, `[PARCIAL]` para los ítems

| Elemento | Realidad | Evidencia |
|---|---|---|
| Pergamino como reintento | **No existe**: `retryLastTurn()` vuelve a cobrar maná sin consumir pergamino | `conversation_providers.dart:1916`; sin referencias a `pergamino` en `conversation/` |
| Pergamino como recurso | Se **regala** en la recompensa diaria ("+N PERGAMINOS") y se genera como *placeholder*; **0 instancias** en producción | `daily_reward_modal.dart:145-146`; `economy_repository_impl.dart:469-490`; `player_pergaminos` = 0 |
| Consumibles de pergamino en tienda | Se venden `consumible_pergamino10/50` que solo suben el máximo diario | `economy_repository_impl.dart:308-318`; RPC `increment_pergaminos_max` |
| Ítems de maná | Se compran/equipan y `consume_mana` los gasta; **0 filas** en producción | `mana_item_inventory.dart:16-210`; `dungeon_guardian_screen.dart:217-222`; `consume_mana` (rama "Gasto 2"); `mana_items` = 0 |

**Estado objetivo.** Un solo uso del pergamino: reintentar la lección fallida
(con el coste de maná intacto). Los ítems de maná desaparecen de tienda,
inventario y RPC de consumo no se usan desde la app.

**Brecha.** (1) Implementar el consumo de pergamino en el reintento y dejar de
cobrar solo maná; (2) dejar de regalar pergaminos como moneda sin uso;
(3) retirar `ManaItemInventory`, `equip_mana_item`/`desequip_mana_item` del flujo
y los consumibles de tienda. La decisión **no** autoriza retirar el pergamino:
se conserva y se reasigna.

**Criterio de cierre.** Reintento que exige y descuenta 1 pergamino y el maná del
turno; `grep` sin `ManaItemInventory` en pantallas; tienda sin ítems de maná.

---

### 2.6 D-06 · No se regala maná y las alternativas cuestan cero

**Decisión.** **No se regala maná.** Sin maná, la alternativa gratuita son
actividades **sin coste de IA**: repaso SRS, listening, Mis errores.

**Estado actual** `[PARCIAL]`

| Elemento | Realidad | Evidencia |
|---|---|---|
| Costes de IA | 6 acciones activas: Oráculo 15, mazmorra 12, chat libre 8, evaluación 30, curaduría 2, lección generada 100 (`correction_turn` inactiva) | `ai_action_costs` (7 filas, 6 `is_active`) |
| Maná por plan | Solo asignación de plan: 3.000 / 17.000 / 20.500 al mes; tope diario 200 solo en `plebeyo` | `subscription_plans`; `consume_mana` |
| Maná regalado | **No se vende suelto** (la venta directa sigue retirada), pero existe **un turno de IA gratis al día**: si `consume_mana` responde `daily_limit_reached`, `llm-proxy` reclama `claim_mana_grace` y permite ese turno con coste 0 (`source: 'grace'`) | `llm-proxy/index.ts:448-459`; RPC `claim_mana_grace`; `user_subscriptions.mana_grace_date` (1 fila, 2026-10-29) |
| CTA del muro | "Obtener maná" abre el **paywall de membresía** (no vende maná) | `dungeon_guardian_screen.dart:207-214` |
| Alternativas sin coste | Existen SRS (`vocabulary_reviews` 7) y listening (3 ejercicios, 0 intentos); **"Mis errores" está vacío** (`corrections` = 0, vista `user_recurring_errors` = 0) | vistas/tablas; `listening_quiz_screen.dart` |

**Estado objetivo.** El muro de maná ofrece en primer plano las tres actividades
de coste cero; la membresía se presenta como membresía (no como "maná"); no hay
mecanismo que inyecte IA gratis.

**Brecha.** (1) **El turno de gracia contradice D-06 al pie de la letra**: es una
acción de IA regalada (coste 0), no maná, pero el efecto es el mismo: practicar
sin pagar fuera de las actividades de coste cero. O se retira y se sustituye por
SRS/listening/Mis errores, o D-06 se reformula (hoy no lo está); (2) el CTA del
Santuario sigue nombrando "maná" para vender suscripción; (3) las alternativas
gratuitas no están jerarquizadas en el muro (el botón primario es pagar).

**Nota de coherencia.** No es código muerto: `llm-proxy` lo ejecuta y 1 usuario
lo ha usado (2026-10-29). Es una **contradicción de producto**, no un bug. La
decisión manda; `PRODUCT.md:123-137` y el Edge Function deben alinearse.

**Criterio de cierre.** El muro muestra SRS/listening/Mis errores como acciones
primarias; no hay turno con coste 0 fuera de esas actividades; `PRODUCT.md` sin
prometer gracia de IA.

---

### 2.7 D-07 · Rango por examen y con desbloqueo

**Decisión.** El rango **F–SSS se sube con examen de jefe** y **desbloquea
contenido**.

**Estado actual** `[PARCIAL]`

| Pieza | Estado | Evidencia |
|---|---|---|
| Escala F–SSS | `[IMPLEMENTADO]` como dato y helper (9 rangos) | `cefr_rank.dart:3-4,73` |
| Asignación del rango | Lo escribe `evaluate-placement` (la IA devuelve `game_rank` y `apply_placement` lo persiste) **a la vez que el CEFR**, y además se **deriva del CEFR** para detectar "inconsistencia" | `evaluate-placement/index.ts:121,437,539`; RPC `apply_placement(p_rank)`; `aura_system.dart:83-98` (`hasRankMismatch`) |
| Examen de jefe | `[IMPLEMENTADO]` con rúbrica de 6 dimensiones; `evaluate-placement` en modo `boss` decide **banda CEFR y rango** y los persiste; **0 intentos** registrados | `boss_exam_rules.dart`; `boss_exam_rubric.dart`; RPC `boss_exam_status`; `conversation_providers.dart:1335-1345`; `boss_exam_attempts` = 0 |
| Desbloqueo por rango | **Casi nulo**: solo el gate de contratos de gremio (`canAcceptRank`), y ese flujo **no tiene UI** | `mission_repository.dart:522`; sin llamadas a `acceptGuildQuest` en `presentation/` |
| Distribución real | 55 de 65 perfiles con `game_rank` **NULL**; 6 en F, 2 en E | `user_language_profiles` |

**Estado objetivo.** Subir de rango es un **acto voluntario** (examen de jefe),
no un efecto del tiempo ni del CEFR; cada rango abre contenido (lección,
mazmorra o mesa) y el CEFR sigue midiendo lengua.

**Brecha.** (1) El examen existe y **sí** escribe rango, pero está atado a la
**banda CEFR** (un examen por banda, no un examen por rango), así que el rango
sigue siendo un derivado del CEFR; además `aura_system.dart:88-98` marca
"inconsistencia" si el rango no coincide con el CEFR, tratándolos como
sinónimos; (2) **no hay contenido bloqueado por rango** (el único gate está en un
flujo sin pantalla); (3) **0 exámenes jugados** → el bucle no está probado.

**Criterio de cierre.** Un examen por rango que escriba `game_rank`; al menos un
elemento de contenido por rango que hoy esté bloqueado y se abra; el gate de
contratos expuesto en UI.

---

### 2.8 D-08 · Gremio asíncrono, sin chat libre

**Decisión.** **Gremio asíncrono**: tablón de contratos y el Maestre como NPC,
**sin chat libre** en fase 1; mesas de voz como evento solo con **≥20
activos/semana**.

**Estado actual** `[PARCIAL]` (y con una contradicción directa)

| Elemento | Realidad | Evidencia |
|---|---|---|
| Tablón de contratos | **No existe en UI**: 199 quests en `guild_quest_pool`; el repositorio sabe aceptarlas pero nadie las llama | `guild_quest_pool` = 199; `mission_repository.dart:413-547`; sin uso en `presentation/` |
| Maestre NPC | `[IMPLEMENTADO]`: banner flotante con mensaje y respuesta | `guild_master_floating_banner.dart:117` |
| **Chat libre** | **Existe**: campo de envío en la sala de voz que inserta en `chat_room_messages` (0 filas) | `voice_room_screen.dart:320,456`; `chat_rooms_repository_impl.dart:286`; `chat_room_messages` = 0 |
| Sala de voz | `[PARCIAL]`: pantalla + `livekit-token`, banner "DEMO", 0 participantes | `voice_room_screen.dart:685-716`; `chat_room_participants` = 0; Edge Function `livekit-token` |
| Umbral de 20 activos | **No existe**: no hay gating por actividad semanal | sin referencias a umbral en `chat_rooms/` |
| Anuncios | 4 filas | `guild_announcements` = 4 |

**Estado objetivo.** Fase 1: tablón + Maestre, sin caja de texto libre; la mesa de
voz se enciende solo con ≥20 activos/semana (medido en BD, no en el cliente).

**Brecha.** (1) **Contradicción**: hay chat libre implementado (muerto por falta
de gente, pero presente); debe retirarse de la UI; (2) falta el tablón, que es el
corazón de la fase 1 (y la capa "contratos" de G-01); (3) no hay umbral técnico
que impida abrir la sala con 0 activos.

**Criterio de cierre.** Sala sin composer de texto; tablón con 2–3 contratos
aceptables; apertura de voz condicionada a una consulta de activos semanales.

---

### 2.9 D-09 · La BD manda (doble currículo)

**Decisión.** **La BD manda** sobre el currículo; copia local de **solo lectura**
con descarga incremental. **Contenido y parámetros en BD, lógica en código.**

**Estado actual** `[PARCIAL]` (dos fuentes y dos criterios)

| Elemento | Realidad | Evidencia |
|---|---|---|
| Currículo en BD | `scenarios` = **500** filas; `lesson_catalog_index` = **140** | BD |
| Currículo en Dart | `LessonCatalog` con lecciones embebidas; es la fuente de la ruta, del Aura y del desbloqueo | `lesson_catalog.dart:95`; `lesson_unlock_service.dart:2,107`; `aura_system.dart:107` |
| Lectura doble | El dashboard lee `scenarios` y **cae** al catálogo Dart si no hay filas | `dashboard_repository_impl.dart:94-124,218` |
| Criterio de "completada" | Dos: metas del servidor (`user_scenario_goals`, umbral 75 % con tolerancia) y estado de cliente/estrellas | `lesson_unlock_service.dart:8-52`; vista `lesson_completion_state` |
| Divergencia medida | **10 de 17** lecciones con `criteria_disagree = true` (59 %); 1 donde solo el cliente la da por pasada | vista `lesson_completion_state` (17 filas, 10 discrepancias, 1 `client_only`) |
| Parámetros en código | Techos de misión y umbrales viven en Dart (`MissionVisibility.dailyCaps`, `passThreshold`) | `mission_visibility.dart:43-58`; `lesson_unlock_service.dart:41` |

**Estado objetivo.** `scenarios` (y su índice) como fuente única en runtime;
Dart solo como semilla/seed y caché de solo lectura; un único criterio de
completada calculado por el servidor; techos y costes leídos de BD.

**Brecha.** (1) La ruta, el Aura y el desbloqueo siguen leyendo Dart; (2) el
criterio doble produce 59 % de discrepancias medidas; (3) `MissionVisibility`
duplica en código los techos de la vista `mission_templates_reachability`.

**Criterio de cierre.** `LessonCatalog` sin lectores de runtime (solo seed);
`criteria_disagree = 0` en la vista; techos servidos por BD con una sola
definición.

---

### 2.10 D-10 · Listening se mantiene, por fases

**Decisión.** **Listening se mantiene** como alternativa sin coste; contenido por
fases.

**Estado actual** `[PARCIAL]`

- Pantalla y ruta existen (`router.dart:130`, `listening_quiz_screen.dart`).
- Contenido: **3 ejercicios**, **0 intentos** (`listening_exercises`,
  `listening_attempts`).
- Es coherente con la decisión (no se retira), pero **no puede** cumplir su papel
  de alternativa gratuita (D-06) con 3 ejercicios y 0 uso.

**Estado objetivo.** Listening disponible como actividad de coste cero, con
contenido por niveles (fase 1: mínimo jugable; fase 2: por banda CEFR).

**Brecha.** Contenido insuficiente y sin uso; no hay enlace desde el muro de maná
ni desde el cierre de lección (ver P-LRN-2 en [`15`](15-improvement-proposals.md)).

**Criterio de cierre.** ≥1 intento por banda activa y acceso desde el flujo de
práctica (no solo desde el menú).

---

### 2.11 D-11 · Precios y trial, con instrumentación

**Decisión.** Se mantienen **precios y trial**; se instrumenta para medir.

**Estado actual** `[PARCIAL]`

| Elemento | Realidad | Evidencia |
|---|---|---|
| Planes activos | `plebeyo` $0; `noble` $4.99 con **trial 7 días**; `realeza` $9.99 | `subscription_plans` (`is_active`) |
| Planes retirados | `monthly`, `annual`, `lifetime`, `divino`, `free` (inactivos) | `subscription_plans` |
| Pagos | **0** en `payments`; 1 suscripción `noble` en BD | `payments` = 0; `user_subscriptions` (1 noble, 14 plebeyo) |
| Eventos de compra | `paywall_viewed` 4, `purchase_started` 1, `purchase_succeeded` 1 | `analytics_events` |
| Reconciliación | `revenuecat_events` = 1; existe `revenuecat-webhook` y `sync-entitlement` | BD; Edge Functions |

**Estado objetivo.** Precio y trial sin cambios; embudo instrumentado
(view → start → success → entitlement) reconciliado con el libro de pagos.

**Brecha.** Hay un `purchase_succeeded` **sin pago** en `payments` (probable
prueba o evento sin reconciliar): el embudo no es de fiar todavía. Falta medir
intención (ver D-15).

**Criterio de cierre.** Cero eventos de compra sin fila correspondiente (o
explicados como test); cohorte de trial con conversión calculable.

---

### 2.12 D-12 · Solo inglés

**Estado actual** `[IMPLEMENTADO]`

- Un solo idioma objetivo: texto de onboarding "Aprenderás inglés"
  (`app_es.arb:1009`).
- UI en es/en/pt (`lib/l10n/app_{en,es,pt}.arb`), lo que **no** contradice la
  decisión (idiomas de interfaz ≠ idiomas que se enseñan).
- El nombre "Dungeon of English" refuerza el foco.

**Brecha.** Ninguna funcional. Riesgo de deriva: cualquier selector de idioma
objetivo futuro debe pasar por una decisión nueva.

---

### 2.13 D-13 · Validación visual humana por release

**Estado actual** `[CONCEPTUAL]`

- Existe `docs/ui-ux-audit/screenshots/`, pero su `README.md:3-10` declara
  **cero capturas válidas** (la única intentada se corrompió y se borró).
- No hay acta de sesión visual ni registro por release.
- El backlog UX (`docs/ui-ux-audit/`, UX-01…UX-37) sigue **abierto** y sin
  verificación en dispositivo.
- Este entorno no tiene móvil ni visión: todo lo estético es
  `[PENDIENTE DE VALIDAR]`.

**Brecha.** Sin la sesión humana, ni los 39 hallazgos UX ni las propuestas de
`15` §1 se pueden cerrar con evidencia. Es la decisión más barata y la que más
bloquea.

**Criterio de cierre.** `screenshots/<versión>/` con capturas por pantalla +
acta firmada por Isaac por release.

---

### 2.14 D-14 · Solo Android

**Estado actual** `[IMPLEMENTADO]`

- No existe carpeta `ios/`; el manifest, Gradle y las compras son Android/Play.
- Sin rutas ni plugins de iOS.

**Brecha.** Ninguna. Vigilar que ninguna dependencia nueva arrastre
configuración iOS.

---

### 2.16 G-01 · Misiones solo del gremio, en 3 capas

**Decisión.** Las misiones salen **solo del gremio**, en **3 capas**: **del día**,
**contratos** y **evento semanal**.

**Estado actual** `[PARCIAL]` — existe **1 de 3** capas, y esa no es del gremio

| Capa | Estado | Evidencia |
|---|---|---|
| Del día | `[IMPLEMENTADO]`: pestaña "Diarias" y motor servidor (`rotate_daily_missions`, triggers) | `missions_screen.dart:33-50`; RPC `rotate_daily_missions`; `mission_visibility.dart:30` |
| Contratos (gremio) | `[CONCEPTUAL]`: 199 quests en pool, repositorio con gate de rango y cuota, **sin pantalla** | `guild_quest_pool` = 199; `mission_repository.dart:413-547`; sin llamadas a `acceptGuildQuest` en `presentation/` |
| Evento semanal | `[CONCEPTUAL]`: tablas vacías, sin productor | `global_events` = 0; `guild_collaborative_missions` = 0; `daily_challenges` = 0 |
| Tipos extra | `daily` 15 plantillas, `weekly` 7, **`secondary` 13** (oculto en UI) | `mission_templates` (35) |
| Instancias | 637 creadas, **8 completadas** | `mission_instances` |
| Fuente | La capa "del día" **no** viene del gremio: la pestaña está en el dashboard/misiones, no en el gremio | `missions_screen.dart`; `chat_rooms_screen.dart` (sin acceso a misiones) |

**Estado objetivo.** Un solo motor con tres capas, todas servidas desde el gremio:
1 principal del día, 2–3 contratos asíncronos y 1 evento semanal de mundo; el
progreso lo avanza el servidor (ya es así).

**Brecha.** (1) Faltan 2 capas con productor y UI; (2) la capa existente no está
ubicada en el gremio; (3) 13 plantillas `secondary` invisibles y 629 instancias
sin completar indican techos y visibilidad mal calibrados (los techos ya están
medidos en `MissionVisibility`).

**Criterio de cierre.** Pantalla de gremio con las tres capas; `secondary`
eliminado o productizado; tasa de completado medida por capa.

---

## 3. Umbral de D-15: continuar / iterar / pivotar

> **Principio.** Sin umbral, cualquier resultado se interpreta a favor. El umbral
> se fija **antes** de la próxima campaña y se evalúa con las métricas de D-02,
> calculadas en BD (no en el cliente) y con muestra suficiente.

### 3.1 Métricas y fuentes

| Métrica | Definición operativa | Fuente (a construir/verificar) | Estado |
|---|---|---|---|
| **M1 · Frases habladas/semana** | Frases del usuario completadas (`user_scenario_phrases.is_completed`) por usuario activo y semana | `user_scenario_phrases` (20 filas, 7 usuarios) → vista semanal **pendiente** | `[PARCIAL]` |
| **M2 · Retención léxica a 7 días** | % de palabras vistas por primera vez en la semana S que se acierta en repaso entre D+6 y D+9 | `user_vocabulary` (79) + `vocabulary_reviews` (7) → consulta **pendiente** | `[CONCEPTUAL]` |
| **M3 · Retención de app D7** | Cohorte por semana de instalación con sesión en D7 | vista `analytics_retention` (`cohort, day_offset, users`) | `[IMPLEMENTADO]` (vista) |
| **M4 · Sesiones con ≥3 turnos** | % de sesiones cerradas con ≥3 turnos hablados | `messages` (771) / `analytics_events.session_end` (11) | `[PARCIAL]` |
| **M5 · Embudo de pago** | `paywall_viewed → purchase_started → purchase_succeeded → entitlement` | `analytics_events`, `payments`, `revenuecat_events` | `[PARCIAL]` (1 éxito sin pago) |

### 3.2 Cifras de partida (2026-10-31, producción)

| Dato | Valor | Nota |
|---|---|---|
| Usuarios totales | **68** | Mayoría de prueba |
| Usuarios con perfil de idioma | 65 | 55 sin `game_rank` |
| Activos últimos 7 días | **1** usuario distinto (9 `app_open`) | Muestra insuficiente |
| Sesiones de práctica registradas | **2** (`practice_sessions`) | Última: 2026-10-31 |
| Sesiones por semana (vista) | 4 sesiones / 1 usuario (semana 2026-10-26) | `analytics_sessions_per_week` |
| `session_reward_ledger` | 4 filas | Base de minutos/objetivos |
| Mensajes | 771 | ≈11 por conversación (70 conversaciones) |
| Palabras en vocabulario | 79 filas | Base de M2 (sin ventana de retención todavía) |
| Repasos SRS | 7 | Base de M2 |
| Frases registradas | 20 (7 usuarios) | Base de M1 |
| Exámenes de jefe | **0** | D-07 sin uso |
| Pagos | **0** | 1 suscripción `noble` en BD, 1 evento de éxito |
| Misiones completadas | **8 / 637** | 1,3 % |
| Participantes de gremio | **0** | 6 salas |

> **Conclusión honesta:** hoy el umbral **no es evaluable**. No hay cohorte ni
> volumen. Cualquier lectura de estas cifras como "validación" sería un error
> estadístico.

### 3.3 Umbral operativo inicial (cifras revisables por Isaac)

Se evalúa a las **8 semanas** de la próxima campaña, con **≥100 usuarios reales**
en la cohorte (excluyendo cuentas de prueba) y **≥30 %** de ellos con al menos una
sesión con ≥3 turnos.

| Veredicto | Condición (todo debe cumplirse) | Acción |
|---|---|---|
| **CONTINUAR** | M1 ≥ 12 frases/semana mediana **y** M2 ≥ 60 % **y** M3 D7 ≥ 25 % **y** M4 ≥ 30 % | Doblar en el bucle actual: más contenido, no más sistemas |
| **ITERAR** | Una métrica por debajo del umbral pero M1 o M2 en crecimiento ≥2 semanas seguidas, **o** M4 < 30 % con M1 ≥ 8 | Un solo cambio por release sobre el embudo que falla (no rediseño) |
| **PIVOTAR** | M1 < 6 frases/semana **y** M2 < 40 % **y** M3 D7 < 15 % durante 4 semanas | Replantear la promesa (producto de práctica guiada vs RPG) antes de añadir features |

Reglas de lectura:

- **Nunca** se juzga con <30 usuarios en la cohorte: se declara "sin datos".
- Las métricas de juego (XP, oro, rango) **no** deciden: son motor, no norte
  (D-02).
- Un resultado mixto cae siempre en **ITERAR**, no en CONTINUAR.
- La decisión se registra aquí con fecha y las cifras que la sustentan.

---

## 4. Brechas ordenadas por impacto

| # | Brecha | Decisión | Por qué primero | Evidencia |
|---|---|---|---|---|
| 1 | Instrumentación de M1 y M2 inexistente | D-02 / D-15 | Sin esto no se puede decidir nada; todo lo demás es opinión | `analytics_events` sin evento de frase; sin vista de retención léxica |
| 2 | Doble currículo y doble criterio (59 % de discrepancias) | D-09 | Corrompe progreso y desbloqueo, y hace imposible medir aprendizaje | vista `lesson_completion_state` (10/17) |
| 3 | Freeze comprado que nunca se consume + dos rachas | D-03 | Promesa incumplida en el bucle diario más visible | `register_practice`; `player_streaks` |
| 4 | Solo 1 de 3 capas de misión; contratos sin UI | G-01 | El gremio no organiza el día; 199 quests muertas | `missions_screen.dart:33-50`; `guild_quest_pool` = 199 |
| 5 | Chat libre en el gremio (contra D-08) | D-08 | Riesgo de moderación y de contradicción de canon | `voice_room_screen.dart:320,456` |
| 6 | Battle pass visible como "PRESTIGIO" | D-04 | Eje muerto compitiendo con el vivo (títulos) | `chat_rooms_screen.dart:1012-1066`; 23 filas nivel 1 |
| 7 | Rango = CEFR; examen sin desbloqueo ni uso | D-07 | La fantasía de ascenso no existe | `boss_exam_attempts` = 0; `mission_repository.dart:522` sin UI |
| 8 | Cuatro nombres y tres escalas | D-01 | Deuda de copy que se multiplica con cada release | `dashboard_screen.dart:331`; `chat_rooms_screen.dart:993-1011` |
| 9 | Pergamino sin función, regalado; ítems de maná vivos | D-05 | Recompensa diaria promete algo que no ocurre | `daily_reward_modal.dart:145`; `player_pergaminos` = 0 |
| 10 | Turno de gracia de IA gratis (contradice D-06) y CTA "Obtener maná" | D-06 | El muro gratuito regala IA antes de ofrecer las actividades de coste cero | `llm-proxy/index.ts:448-459`; `dungeon_guardian_screen.dart:207-214` |

---

## 5. Límites de esta auditoría

- **No verificable aquí:** validación visual (D-13), sensación de juego, TTS,
  compras reales, retención real. Falta un dispositivo y acceso a Play Console /
  RevenueCat más allá de los eventos en BD.
- **Datos de producción** compatibles con un entorno de desarrollo (68 usuarios,
  1 activo/semana, 0 pagos): ninguna conclusión de comportamiento es válida.
- **Inferencia declarada:** el nombre canónico del jugador se fija como
  **"aventurero"** a partir de D-01 ("gremio de aventureros" + "un solo nombre").
  Es la lectura más directa, pero **no está escrita literalmente** en
  `_decisions.md`; si Isaac prefiere otro, cambia el glosario y no la decisión.
