# 16 — Glosario único del producto

> **Qué es.** La lista corta de palabras con **un solo significado canónico** para
> el universo de *Dungeon of English*. Existe porque el código, la BD y el copy
> usan hoy varios nombres para lo mismo (cuatro para el jugador, tres para el
> rango, dos para el prestigio).
>
> **Manda:** [`_decisions.md`](_decisions.md) (D-01…D-15, G-01). La coherencia y la
> brecha medida están en [`19` §2.1](19-canon-and-decisions.md#21-d-01--una-institución-un-nombre-una-escala).
> Si este glosario y una decisión discrepan, **manda la decisión**.
>
> **Alcance:** términos de producto y de interfaz. No define reglas de negocio
> (eso es [`../PRODUCT.md`](../PRODUCT.md)) ni fórmulas (eso es
> [`../product-audit/06-GAMEPLAY-Y-GAMIFICACION.md`](../product-audit/06-GAMEPLAY-Y-GAMIFICACION.md)).

---

## 1. Tabla maestra

| Término | Significado **canónico** | Términos prohibidos / en deuda | Estado del código |
|---|---|---|---|
| **Jugador** | **Aventurero** del gremio. Es la persona que practica inglés; el único nombre visible para ella | "Hunter"/"Hunters", "cazador", "Usuario del Aura", "estamento" (como nombre de persona, no de plan) | `[PARCIAL]`: la UI dice "Hunter" |
| **Rango** | Escala **única F → E → D → C → B → A → S → SS → SSS**. Sube por **examen de jefe** y **abre contenido** | `HIERRO/PLATA/ORO` (cabecera del gremio), `PRESTIGIO N` (battle pass) | `[PARCIAL]`: 3 etiquetas conviven |
| **Gremio** | La **institución central**: da misiones en 3 capas (del día, contratos, evento), presta el tablón y tiene al **Maestre** como NPC | "Guild Hall" como marca en inglés (aceptable como rótulo), "taberna", "estamento feudal" | `[PARCIAL]`: existe la pantalla, no las misiones |
| **Maná** | La **energía que cuesta cada acción de IA** (hablar, evaluar, generar). Se agota; no se regala | "energía", "combustible", "poción" como sinónimo de maná | `[IMPLEMENTADO]` como coste; copy de venta confuso |
| **Aura** | El **mérito acumulado sin tope** que se gana practicando; alimenta el **título de prestigio**. No es una moneda y no se compra | "poder", "XP" (el Aura no es XP) | `[IMPLEMENTADO]`: `aura_xp`, `prestige_ladder` |
| **Nobleza** | La **membresía de pago** del gremio (planes `noble` y `realeza`). Es una jerarquía **declarada**, no una ventaja de aprendizaje evaluado | "estamento", "élite", "premium" como nombre de la jerarquía | `[PARCIAL]`: el copy dice "estamento" |
| **Plebeyo** | El **plan gratuito** del gremio (3.000 maná/mes, tope diario). No es un insulto ni un rango: es el nivel de membresía base | "free", "básico", "trial" como nombre del plan | `[IMPLEMENTADO]` (plan `plebeyo`) |

---

## 2. Los siete términos, en detalle

### 2.1 Jugador = **aventurero**

- **Canónico:** *aventurero* (masculino genérico en el copy; en inglés
  *adventurer*).
- **Por qué:** D-01 declara el **gremio de aventureros** como institución central
  y exige **un solo nombre** para el jugador. "Aventurero" es el único que deriva
  de la institución y no de una metáfora paralela.
- **Deuda medida:** la UI en inglés dice **"Hunter"** (`app_localizations_en.dart:15,488`;
  `dashboard_screen.dart:331-332`), el banner de voz dice **"cazadores"**
  (`voice_room_screen.dart:703`) y los comentarios de dominio dicen
  **"aventurero"** (`aura_system.dart:7`, `mission_repository.dart:99`). La
  ficción del Aura añade **"Usuario del Aura"** (`aura_system.dart:8`).
- **Etiqueta:** `[PARCIAL]`. Cerrar cuando `grep` no devuelva "Hunter" ni
  "cazador" en texto visible.
- **Nota de honestidad:** el nombre exacto **no está escrito** en
  `_decisions.md`; "aventurero" es la lectura directa de D-01 y está marcada como
  **inferencia declarada** en [`19` §5](19-canon-and-decisions.md#5-límites-de-esta-auditoría).
  Si Isaac prefiere otro, se cambia aquí y en el copy, no la decisión.

### 2.2 Rango = **F–SSS, uno solo**

- **Canónico:** una sola escala de nueve peldaños: **F** (iniciado), E, D, C, B,
  A, S, SS, **SSS** (élite). Se **sube con examen de jefe** y **desbloquea
  contenido** (D-07).
- **Relación con el CEFR:** el CEFR mide **lengua**; el rango mide **uso**. Un
  aprendiz A2 puede ser rango D y seguir siendo A2: no son lo mismo, aunque hoy
  el código los haga equivalentes.
- **Deuda medida:**
  1. `cefr_rank.dart:13-21` mapea CEFR → rango 1:1 (A2 → D, B1 → C…), y
     `aura_system.dart:88-98` marca "inconsistencia" si el rango no coincide con
     el CEFR: el sistema **trata el rango como sinónimo**.
  2. La cabecera del gremio pinta **HIERRO / PLATA / ORO** según la banda CEFR
     (`chat_rooms_screen.dart:993-1011`): **segunda escala**, solo cosmética.
  3. El battle pass pinta **"PRESTIGIO {nivel}"** (`app_localizations_es.dart:1138`):
     **tercera escala**, que D-04 retira.
- **Términos prohibidos:** "tier", "liga", "prestigio" como sinónimo de rango.
- **Etiqueta:** `[PARCIAL]`.

### 2.3 Gremio = **la institución**

- **Canónico:** el gremio es la **institución central** que organiza la vida del
  aventurero: emite las **misiones en 3 capas** (del día, contratos, evento
  semanal — G-01), tiene **tablón** y **Maestre** (NPC), y agrupa a los miembros
  por **membresía** (nobleza/plebeyo). En fase 1 es **asíncrono y sin chat
  libre** (D-08).
- **No es:** una taberna, un estamento feudal ni una sala de chat.
- **Deuda medida:** la pantalla se llama "GUILD HALL" y hay 6 salas, pero
  **0 participantes**, **0 mensajes** y **0 misiones** servidas desde el gremio
  (`chat_room_participants` = 0; `chat_room_messages` = 0; `guild_quest_pool` =
  199 sin UI). Además existe un **chat libre** en la sala de voz
  (`voice_room_screen.dart:320,456`), que D-08 prohíbe en fase 1.
- **Etiqueta:** `[PARCIAL]`.

### 2.4 Maná = **coste de la IA**

- **Canónico:** el maná es la **energía** que se consume al invocar IA. Cada
  acción tiene un coste fijo en BD (`ai_action_costs`): Oráculo 15, mazmorra 12,
  chat libre 8, evaluación 30, curaduría 2, lección generada 100. Se agota; **no
  se regala** (D-06).
- **Relación con el plan:** cada membresía incluye una **asignación mensual**
  (`subscription_plans.mana_allowance`: 3.000 / 17.000 / 20.500). El plan
  `plebeyo` tiene además **tope diario de 200** (`consume_mana`).
- **No es:** una moneda que se compra suelta ni un ítem equipable. Los **ítems de
  maná** se retiran (D-05).
- **Deuda medida:** el CTA "Obtener maná" abre el **paywall de membresía**
  (`dungeon_guardian_screen.dart:207-214`), lo que presenta el maná como producto
  vendible. El **turno de gracia** documentado en `PRODUCT.md:123-137` **sí
  existe** (`llm-proxy/index.ts:448-459` + `claim_mana_grace`), pero regala una
  acción de IA al día: **contradice "no se regala maná" (D-06)**.
- **Etiqueta:** `[PARCIAL]` (coste `[IMPLEMENTADO]`; alternativa gratuita
  implementada **en conflicto** con D-06).

### 2.5 Aura = **mérito sin tope**

- **Canónico:** el Aura es el **mérito acumulado** al practicar. Se despierta al
  superar la etapa básica (A1+A2) o con CEFR ≥ B1; crece **sin tope**
  (`aura_xp`) y determina el **título de prestigio** (`prestige_ladder`, 21
  escalones).
- **No es:** una moneda, ni XP de nivel, ni el rango. El rango se gana con
  examen; el Aura se acumula practicando.
- **Deuda medida:** la UI mezcla Aura y título en la misma zona del HUD
  (`aura_hud.dart:167` habla de "progresión de prestigio", `aura_system.dart:27-31`
  expone `prestigeTitleName`). No hay contradicción funcional, sí de copy.
- **Etiqueta:** `[IMPLEMENTADO]` (con deuda de copy).

### 2.6 Nobleza = **membresía de pago**

- **Canónico:** **nobleza** es la jerarquía de **miembros de pago** del gremio.
  En datos se materializa como plan `noble` ($4.99, trial 7 días) y `realeza`
  ($9.99). Comprar nobleza **no** da ventaja en el aprendizaje evaluado; da maná,
  historial de informe y cosmética/títulos.
- **Términos prohibidos:** "estamento" (retirado; hoy en
  `app_localizations_es.dart:1655,3696` y en la descripción del plan `realeza`),
  "élite" como nombre de la jerarquía.
- **Deuda medida:** el copy de paywall y la descripción de `realeza` en BD siguen
  diciendo "Estamento REALEZA: … mayor techo de prestigio". Debe decir
  "membresía" y "techo de título".
- **Etiqueta:** `[PARCIAL]`.

### 2.7 Plebeyo = **plan gratuito**

- **Canónico:** **plebeyo** es el nivel de membresía **gratuito** (3.000 maná/mes,
  tope diario de 200). Es una posición en la jerarquía del gremio, **no** un
  rango, no un insulto y no el estado "sin cuenta".
- **Términos prohibidos:** "free", "básico" y "trial" como **nombre** del plan
  (pueden describir una condición, no sustituir el nombre).
- **Deuda medida:** los planes retirados (`free`, `monthly`, `annual`,
  `lifetime`, `divino`) siguen en `subscription_plans` con `is_active = false`;
  conviven nombres distintos ("Plan Gratuito (Trial)", "Plan Mensual") que ya no
  se muestran, pero confunden al leer la BD.
- **Etiqueta:** `[IMPLEMENTADO]` (limpieza de filas retiradas pendiente).

---

## 3. Términos retirados (no usar en copy nuevo)

| Término retirado | Por qué | Sustituto canónico | Decisión |
|---|---|---|---|
| **Estamento** | Metáfora feudal paralela; el jugador no pertenece a un estamento, pertenece a una **membresía** del gremio | "membresía" / "nobleza" / "plebeyo" | D-01 |
| **Hunter / cazador** | Metáfora de caza de mazmorras paralela al gremio | "aventurero" | D-01 |
| **Usuario del Aura** | Nombre adicional para el jugador dentro de la ficción | "aventurero" (el Aura se *tiene*, no se *es*) | D-01 |
| **HIERRO / PLATA / ORO** | Segunda escala de rango sin respaldo en BD | F–SSS | D-01 / D-07 |
| **PRESTIGIO {nivel}** (battle pass) | Tercera escala, sistema retirado | "título de prestigio" (Aura) | D-04 |
| **Temporada** (como battle pass) | El battle pass se retira | — (no hay temporadas) | D-04 |
| **Ítem de maná / poción** | Recurso equipable retirado | "maná" (asignación del plan) | D-05 |

---

## 4. Reglas de copy (para `.arb` y BD)

1. Un término, un significado: si una palabra necesita dos definiciones, se parte
   en dos palabras.
2. El jugador es **aventurero**; nunca "Hunter", "cazador" ni "usuario".
3. El rango se escribe **F–SSS** y solo con esa escala.
4. La membresía se llama **nobleza** o **plebeyo**; el conjunto es **membresía**.
5. El maná **se gasta**, no se "vende"; la membresía **incluye** maná.
6. El **Aura** se acumula; el **título** se luce; el **rango** se gana con examen.
7. Los `.arb` se editan **solo con la herramienta de edición** y después
   `flutter gen-l10n` (regla del repo).

---

## 5. Estado de cumplimiento

| Término | Canónico definido | Aplicado en copy | Deuda |
|---|---|---|---|
| Jugador | ✅ | ❌ ("Hunter") | Reescribir claves de UI y textos de onboarding |
| Rango | ✅ | ❌ (3 escalas) | Retirar HIERRO/PLATA/ORO y PRESTIGIO N |
| Gremio | ✅ | 🟡 (pantalla sí, misiones no) | Tablón + retirar chat libre |
| Maná | ✅ | 🟡 (coste sí, venta ambigua) | CTA del Santuario; turno de gracia |
| Aura | ✅ | 🟡 | Copy del HUD |
| Nobleza | ✅ | ❌ ("estamento") | `.arb` + `subscription_plans.description` |
| Plebeyo | ✅ | ✅ | Limpiar planes retirados |

> **Mantenimiento.** Si aparece un término nuevo en el producto, se añade aquí
> **antes** de escribirlo en un `.arb` o en una tabla de contenido. Si dos
> documentos de `docs/` discrepan, este glosario y [`_decisions.md`](_decisions.md)
> mandan sobre el vocabulario.
