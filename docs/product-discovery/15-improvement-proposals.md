# 15 — Propuestas de mejora

> **Separación explícita:** este documento **no describe lo que la app hace**.
> Describe lo que podría hacer. El estado actual vive en
> [`12-current-state-and-gaps.md`](12-current-state-and-gaps.md) y la crítica de
> juego en [`14-game-design-audit.md`](14-game-design-audit.md).
>
> Escalas: **Impacto** A (cambia la naturaleza del producto) · B (mejora el bucle)
> · C (pulido). **Complejidad** S (≤1 día) · M (2–4) · L (≥5) · XL (rediseño).
> Ninguna propuesta asume cambiar la paleta ni las familias tipográficas.
>
> **Alineadas con el canon (2026-10-31).** Las decisiones D-01…D-15 y G-01 están
> aprobadas y no se cuestionan ([`19`](19-canon-and-decisions.md)). Se han
> **eliminado** las propuestas que las contradecían: temporada de battle pass,
> ítems de maná, retirada del pergamino y chat libre en el gremio. Los IDs `Q…`
> del análisis previo se citan ya como `D…`.

---

## 1. UX / UI

### P-UX-1 · Un solo estado honesto para toda la app

| Campo | Contenido |
|---|---|
| **Problema** | Cada pantalla inventa su forma de cargar, fallar o estar vacía. La tienda pinta un error de red como "AÚN NO HAY OBJETOS" y el dashboard dice "mostrando el último progreso guardado" cuando no hay nada guardado. |
| **Evidencia** | `shop_screen.dart` sin rama `hasError` (UX-16, #255); `dashboard_screen.dart:195-231` (UX-17, #256); `docs/ui-ux-audit/06` UX-16/17. |
| **Solución** | Un widget `HudState` con cuatro ramas obligatorias (`loading`, `empty`, `error+retry`, `offline+timestamp`) y un lint de revisión que exija usarlo en toda pantalla con `AsyncValue`. El error nunca puede caer en la rama de vacío. |
| **Justificación** | Un estado que miente destruye la confianza más rápido que un fallo visible. Es la corrección más barata del backlog (S) con el mayor efecto percibido. |
| **Beneficio** | El jugador distingue "no hay contenido" de "no hay red" y sabe qué hacer. |
| **Impacto** | B |
| **Complejidad** | S por pantalla; M el conjunto (20 pantallas). |
| **Dependencias** | Ninguna técnica. Requiere criterio de copy (i18n en 3 idiomas). |
| **Riesgos** | Tentación de tapar el error con un vacío "bonito". Mitigación: test que monta el provider en error y exige el botón de reintento. |

### P-UX-2 · Accesibilidad mínima real (AA, 48 dp, reduce-motion)

| Campo | Contenido |
|---|---|
| **Problema** | Cuatro hallazgos críticos siguen abiertos: contraste del botón primario, objetivos táctiles de 24 dp, 12 animaciones infinitas sin `reduce-motion` y 5 `Semantics` en toda la app. |
| **Evidencia** | `docs/ui-ux-audit/06` UX-01/03/04/12/13; `runic_button.dart:24-25`; `session_summary_screen.dart:524-550`; issues #240, #242, #243, #251, #252. |
| **Solución** | (1) `onTertiary = blanco` o primario cian/void; (2) `HudIconButton` 48×48 y `minimumSize` global; (3) `AppMotion.loop(context)` que no anima con `disableAnimations`; (4) `Semantics` obligatorio en icon-only con test de TalkBack. |
| **Justificación** | Es requisito de publicación (Play) y de producto: la práctica es oral, y quien no ve bien el botón de micrófono no puede practicar. |
| **Beneficio** | Más usuarios pueden completar el bucle; menos riesgo de rechazo en tienda. |
| **Impacto** | B |
| **Complejidad** | M |
| **Dependencias** | `core/widgets` y tema; validación visual humana (`screenshots/README.md`). |
| **Riesgos** | Cambiar el violeta del primario altera la identidad percibida. Mitigación: mantener violeta como acento y usar cian para la acción. |

### P-UX-3 · "Hoy": una sola pantalla de decisión

| Campo | Contenido |
|---|---|
| **Problema** | El dashboard acumula HUD, bienvenida, anillo de meta, SRS, misión del día, badge PRO, cuatro accesos rápidos, CTA, ruta completa y dock de cuatro pestañas. La decisión ("¿qué hago ahora?") compite con nueve bloques. |
| **Evidencia** | `dashboard_screen.dart:388-548`; `docs/ui-ux-audit/03` y `06` (jerarquía y densidad). |
| **Solución** | Reordenar por decisión: **una** acción primaria (continuar la lección), **una** tarjeta de "hoy" (misión + meta + repaso fusionados) y **un** acceso secundario plegado. La ruta se mueve a su propia pestaña o a scroll bajo demanda. |
| **Justificación** | La app ya sabe cuál es la siguiente lección (`dashboard_screen.dart:143-155`). Mostrar nueve caminos contradice ese cálculo. |
| **Beneficio** | Menos tiempo hasta la primera frase hablada; onboarding y recurrencia más claros. |
| **Impacto** | B |
| **Complejidad** | M |
| **Dependencias** | P-GD-2 (misión única) para que "hoy" tenga una sola misión. |
| **Riesgos** | Perder visibilidad de monetización (badge PRO). Mitigación: la membresía vive en Estado/Ajustes, no en el camino de práctica. |

---

## 2. Game design

### P-GD-1 · El rango vuelve a ser una llave

| Campo | Contenido |
|---|---|
| **Problema** | El rango F–SSS es un sinónimo del CEFR y no desbloquea nada. La fantasía de ascenso no tiene escalones. |
| **Evidencia** | `aura_system.dart:83-86`; `mission_repository.dart:109-120`; `docs/product-audit/06` §rango; hallazgo G-03. |
| **Solución** | Cada rango exige un **examen de jefe** (ya existe `boss_exam`) y abre: una mazmorra temática, una mesa del gremio y un título. El CEFR sigue midiendo lengua; el rango mide *uso*. Subir de rango es un acto voluntario, no un efecto del tiempo. |
| **Justificación** | Convierte una etiqueta en objetivo y da uso al contenido de examen que ya está construido. |
| **Beneficio** | Un motivo para volver que no depende de maná ni de monedas. |
| **Impacto** | A |
| **Complejidad** | L (gating, exámenes, recompensas, UI de "siguiente rango"). |
| **Dependencias** | P-ECO-1 (maestría), `boss_exam`, datos de rango en `user_language_profiles`. |
| **Riesgos** | Frustración si el examen es duro o injusto. Mitigación: reintento con coste bajo y rúbrica visible (ya existe `boss_exam_result_screen`). |

### P-GD-2 · Un solo motor de misión en tres capas

| Campo | Contenido |
|---|---|
| **Problema** | Siete tipos de misión, dos visibles, trece plantillas `secondary` invisibles y un embudo de 8 completadas sobre 637 instancias. |
| **Evidencia** | `mission_visibility.dart:29-30,61-67`; `mission_templates` (15 daily / 7 weekly / 13 secondary); `mission_instances` (637, 8 completadas); G-01. |
| **Solución** | Tres capas con un solo motor, **como fija G-01**: **Hoy** (1 principal narrativa), **Contratos** (2–3 de gremio, asíncronos, del `guild_quest_pool` ya sembrado) y **Evento** (1 semanal de mundo, reservado para la capa 3). Eliminar del modelo `secret`, `emergency` y `secondary` hasta que tengan productor. El progreso solo lo avanza el servidor (ya es así). |
| **Justificación** | Menos tipos, más densidad. El pool de 199 quests ya existe y no se usa. |
| **Beneficio** | Una lista que se puede completar y que cambia cada día; el gremio gana una razón asíncrona. |
| **Impacto** | A |
| **Complejidad** | L |
| **Dependencias** | P-GD-4 (gremio), `advance_missions_for_user`, `guild_quest_pool`. |
| **Riesgos** | Volver a inflar objetivos no alcanzables. Mitigación: los techos de `MissionVisibility` ya están medidos (10 min/día, 15/semana); mantenerlos y testear alcanzabilidad. |

### P-GD-3 · Cerrar los sistemas muertos (sin reabrirlos)

| Campo | Contenido |
|---|---|
| **Problema** | Cuatro sistemas se anuncian y no funcionan: freeze de racha (no protege), battle pass (nivel 1 congelado), pergaminos (0 filas) e ítems de maná (0 filas). |
| **Evidencia** | `register_practice` no lee `player_streaks` ni consume `streak_freezes`; `guild_battle_pass` 23×nivel 1 y 0 funciones; `player_pergaminos` = 0; `mana_items` = 0; `chat_rooms_screen.dart:1012-1066` (chip PRESTIGIO); G-04, G-05, G-06. |
| **Solución** | Una salida por sistema, **fijada por decisión**: **racha/freeze** → una sola racha y freeze consumido en `register_practice` al faltar un día (**D-03**); **battle pass** → **retirar** el chip, el provider y la lectura, y dejar los títulos de prestigio como único eje (**D-04**); **pergamino** → reasignarlo a **reintento de lección**, con el maná cobrándose igual (**D-05**); **ítems de maná** → **retirar** de tienda e inventario (**D-05**). No se deja nada "visible y quieto". |
| **Justificación** | Cada sistema muerto resta credibilidad a los vivos y consume mantenimiento. Las cuatro salidas ya están decididas: la propuesta solo ejecuta. |
| **Beneficio** | Menos superficie que explicar; el jugador deja de aprender a ignorar la recompensa diaria. |
| **Impacto** | B |
| **Complejidad** | S (retirar battle pass e ítems de maná) · M (consumir freeze + pergamino como reintento). |
| **Dependencias** | D-03, D-04, D-05; P-LRN-1 (reintento con evidencia). |
| **Riesgos** | La retirada del battle pass deja un hueco visual en la cabecera del gremio. Mitigación: ocuparlo con el **título de prestigio** (ya existe en `prestige_ladder`) y con el tablón de contratos de P-GD-4. |

### P-GD-4 · Gremio asíncrono o NPC colectivo

| Campo | Contenido |
|---|---|
| **Problema** | El gremio exige coincidencia en tiempo real, se autodenomina DEMO y hoy tiene 0 participantes. Un módulo social vacío comunica que el juego está muerto. |
| **Evidencia** | `chat_room_participants` = 0; `voice_room_screen.dart:703`; `guild_announcements` = 4; `guild_quest_pool` = 199; G-10. |
| **Solución** | Fase 1 (sin masa crítica): el gremio es **tablón asíncrono** con 2–3 contratos del pool, reputación por aportar frases y el Maestre como NPC que narra el mundo. **Sin chat libre**: se retira el composer de la sala de voz (hoy `voice_room_screen.dart:320,456`). Fase 2 (≥20 activos/semana, medido en BD): mesas de voz como evento programado. |
| **Justificación** | El valor social se puede entregar sin coincidencia horaria; la voz en vivo es el último paso, no el primero. Con 0 participantes, un chat libre solo añade moderación sin uso. |
| **Beneficio** | El gremio deja de estar vacío; alimenta misiones y narrativa. |
| **Impacto** | B |
| **Complejidad** | M (fase 1) / L (fase 2). |
| **Dependencias** | P-GD-2 (contratos), `guild_quest_pool`, `guild_announcements`, D-08. |
| **Riesgos** | Complejidad de moderación si se abre chat. Mitigación: fase 1 **sin** chat libre, por decisión (D-08). |

---

## 3. Narrativa

### P-NAR-1 · Declarar el canon y un glosario

| Campo | Contenido |
|---|---|
| **Problema** | Conviven tres metáforas (cazador de mazmorras, estamento feudal, gremio de taberna) y cuatro nombres para el jugador. El "rango" tiene tres escalas. |
| **Evidencia** | `dashboard_screen.dart:332` ("Hunter"); `paywall_upgrade_subtitle` ("estamento"); `chat_rooms_screen.dart:993-1003` (HIERRO/PLATA/ORO); `guild_battle_pass` ("PRESTIGIO"); hallazgo G-01/§1. |
| **Solución** | Aplicar el **glosario único** ([`16`](16-product-glossary.md)): un solo nombre para el jugador (**aventurero**), "estamento" → **membresía del gremio** (nobleza/plebeyo) y **una sola escala de rango** (F–SSS). Retirar la escala `HIERRO/PLATA/ORO` de la cabecera del gremio. El chip "PRESTIGIO {nivel}" **desaparece** con el battle pass (D-04): el prestigio pasa a ser el **título del Aura** (`prestige_ladder`). Tabla "término prohibido → término único" en `16`. |
| **Justificación** | La coherencia narrativa es barata (texto) y es lo que hace que un RPG se sienta un mundo y no una hoja de cálculo. |
| **Beneficio** | Menos confusión, más identidad; base para copy de tienda, paywall y onboarding. |
| **Impacto** | B |
| **Complejidad** | S (documento) + M (i18n y reemplazos). |
| **Dependencias** | D-01 y D-04 aprobadas; [`16`](16-product-glossary.md). |
| **Riesgos** | Reescritura masiva de `.arb` (regla del repo: solo con la herramienta de edición y `flutter gen-l10n`). |

### P-NAR-2 · El maná como pacto narrado

| Campo | Contenido |
|---|---|
| **Problema** | El maná es un contador. El Santuario de Maná es una pantalla de bloqueo que empuja al paywall y el Guardián grita sin consecuencias. La ficción no explica por qué hablar cuesta energía ni qué pasa cuando se acaba. |
| **Evidencia** | `dungeon_guardian_screen.dart:90-107,207-214`; `ai_action_costs`; `docs/PRODUCT.md:123-137` (turno de gracia, hoy en conflicto con D-06). |
| **Solución** | Narrar el maná como **pacto con el Oráculo**: cada turno es una invocación; al agotarse, el Guardián **no regala IA** (D-06): ofrece las actividades de **coste cero** (repaso SRS, listening, Mis errores) y recuerda la recarga del ciclo. El CTA de pago se convierte en "ampliar el pacto" (membresía), con la alternativa gratuita al mismo nivel visual. |
| **Justificación** | Convierte una restricción técnica (coste de IA) en regla de mundo, que es exactamente lo que pide el principio rector. |
| **Beneficio** | El bloqueo deja de sentirse como un muro de pago y pasa a ser parte de la ficción; baja la percepción de "me están frenando". |
| **Impacto** | B |
| **Complejidad** | S (copy + jerarquía de CTAs) / M si se añade evento narrado. |
| **Dependencias** | P-ECO-2 (monetización honesta); D-06. |
| **Riesgos** | Prometer un turno gratis que contradice D-06. Mitigación: ofrecer actividades de **coste cero**, no IA gratis; retirar el turno de gracia si se mantiene la decisión. |

---

## 4. Economía

### P-ECO-1 · Esfuerzo y Maestría: dos monedas de progreso

| Campo | Contenido |
|---|---|
| **Problema** | XP = minutos × 10 y el rango deriva del CEFR: el juego paga por estar, no por mejorar. |
| **Evidencia** | RPC `apply_session_rewards`; `aura_system.dart:83-86`; G-02. |
| **Solución** | Separar **Esfuerzo** (minutos, oro, cosméticos) de **Maestría** (objetivos nuevos, precisión, palabras retenidas a 7 días). Solo Maestría sube rango y abre contenido; el Esfuerzo compra identidad visual. El resumen muestra ambas cifras. |
| **Justificación** | Alinea la recompensa con la promesa del producto (aprender inglés) y elimina el farmeo por tiempo. |
| **Beneficio** | Progreso defendible ante quien paga; el rango vuelve a significar algo. |
| **Impacto** | A |
| **Complejidad** | L (nueva fuente de datos, fórmula, migración, UI). |
| **Dependencias** | `learning_evidence` (retención 7d ya existe), `srs` y radar de habilidades; P-GD-1. |
| **Riesgos** | Castigar a quien practica mucho pero mejora despacio. Mitigación: Maestría con suelo garantizado por sesión válida. |

### P-ECO-2 · Tres recursos, tres frases (y monetización honesta)

| Campo | Contenido |
|---|---|
| **Problema** | Cinco recursos con funciones solapadas; el Santuario vende una suscripción con la etiqueta "obtener maná"; la tienda y la membresía compiten por el mismo espacio mental. |
| **Evidencia** | `dungeon_guardian_screen.dart:208-214`; `paywall_screen.dart:314-520`; `docs/PRODUCT.md:46-61`; G-04/G-07. |
| **Solución** | Maná = *puedo practicar*; Oro = *me visto*; Gemas = *me salto una espera* (con espera real). **Retirar los ítems de maná** (tienda, inventario y consumo equipado) y **reasignar el pergamino** a reintento de lección (D-05), dejando de regalarlo como moneda sin uso. Renombrar el CTA del Santuario a "Ampliar el pacto" y presentar los planes como **membresía del gremio** (nobleza/plebeyo) en su propia pantalla, no como tienda. |
| **Justificación** | Un recurso por intención se explica en una frase; cinco no se explican. |
| **Beneficio** | Menos confusión, menos fricción en el momento de pagar, menos promesas incumplidas. |
| **Impacto** | B |
| **Complejidad** | S (copy y jerarquía) + M (retirar ítems de maná y reasignar el pergamino). |
| **Dependencias** | P-NAR-2; D-05 y D-06. |
| **Riesgos** | El pergamino deja de ser una recompensa "extra" de la recompensa diaria. Mitigación: sustituirlo por gemas o por el propio reintento ya desbloqueado. |

---

## 5. Aprendizaje

### P-LRN-1 · Resumen con evidencia y siguiente acción

| Campo | Contenido |
|---|---|
| **Problema** | El resumen entrega moneda pero no demuestra aprendizaje; las métricas que lo harían están en otra pestaña. |
| **Evidencia** | `session_summary_screen.dart:614-665`; `srs_review_card.dart:27-30`; `learning_evidence_card.dart`; `daily_fluency_stats` (16 filas); G-11. |
| **Solución** | Encabezar el resumen con una frase de evidencia ("4 estructuras nuevas; 2 palabras pasan a repaso largo; fluidez +3 en 2 semanas") y un botón "practicar esto mañana". La recompensa económica baja al pie. |
| **Justificación** | El valor percibido del producto es aprender, no acumular oro; el resumen es el único momento en que el jugador mira su progreso de cerca. |
| **Beneficio** | Percepción de progreso real; motivo para volver mañana con intención. |
| **Impacto** | A |
| **Complejidad** | M |
| **Dependencias** | P-ECO-1 (maestría), `learning_evidence`, `user_vocabulary`. |
| **Riesgos** | Mostrar una métrica poco fiable como prueba. Mitigación: etiquetar "estimación" y no inventar precisión acústica (regla ya vigente). |

### P-LRN-2 · Listening y SRS como variantes, no como destinos

| Campo | Contenido |
|---|---|
| **Problema** | Listening (3 ejercicios, 0 intentos) y SRS (7 reviews) viven como módulos aparte que no alimentan la lección ni las misiones. |
| **Evidencia** | `learning_path_roadmap.dart:472`; `srs_review_card.dart:23-24`; `listening_exercises` = 3 / 0 intentos; G-08. |
| **Solución** | Insertar ambas dentro del flujo de lección: al cerrar una lección, ofrecer "escucha esta conversación" y "repasa 3 palabras de hoy". El contenido se genera desde el escenario ya jugado (y desde `lesson-generator` cuando esté sano). |
| **Justificación** | La mejor variedad es la que no exige cambiar de contexto; hoy el jugador tiene que ir a buscar el módulo. |
| **Beneficio** | Más uso del contenido ya construido; refuerzo inmediato = mejor retención. |
| **Impacto** | B |
| **Complejidad** | M |
| **Dependencias** | Contenido de listening (hoy 3), `lesson-generator`, P-LRN-1. |
| **Riesgos** | Depender de generación por IA con coste y calidad variable. Mitigación: fallback a ejercicios curados. |

### P-LRN-3 · Un solo currículo y un solo criterio de "completada"

| Campo | Contenido |
|---|---|
| **Problema** | Hay dos currículos (Dart `LessonCatalog` y 500 `scenarios` en BD) y dos criterios de completada (estrellas por metas vs desbloqueo secuencial). |
| **Evidencia** | `docs/PRODUCT.md:74-75`; `lesson_unlock_service.dart`; `dashboard_repository_impl.dart:186-195` (estrellas); issues #202 y #203. |
| **Solución** | `scenarios` como fuente única en runtime; `LessonCatalog` como semilla/seed. Un solo criterio: la lección se completa si se cumplen los objetivos del servidor; las estrellas se retiran o se convierten en "calidad" separada de "completada". |
| **Justificación** | Dos verdades producen progreso inconsistente y bugs de desbloqueo. |
| **Beneficio** | Progreso predecible; menos deuda y menos confusión. |
| **Impacto** | B |
| **Complejidad** | L |
| **Dependencias** | #202 → #203; migración de datos y caché offline. |
| **Riesgos** | Romper el desbloqueo existente. Mitigación: migración con doble lectura y feature flag. |

---

## 6. Priorización

| # | Propuesta | Dimensión | Impacto | Compl. | Depende de |
|---|---|---|---|---|---|
| 1 | P-UX-1 Estados honestos | UX | B | M | — |
| 2 | P-GD-3 Cerrar sistemas muertos | Game design | B | S/M | D-03/D-04/D-05 |
| 3 | P-GD-1 Rango como llave | Game design | A | L | P-ECO-1 |
| 4 | P-ECO-1 Esfuerzo vs Maestría | Economía | A | L | Datos de evidencia |
| 5 | P-GD-2 Motor de misión en 3 capas | Game design | A | L | P-GD-4 |
| 6 | P-LRN-1 Resumen con evidencia | Aprendizaje | A | M | P-ECO-1 |
| 7 | P-NAR-1 Canon y glosario | Narrativa | B | S/M | D-01/D-04 · [`16`](16-product-glossary.md) |
| 8 | P-UX-2 Accesibilidad AA | UX | B | M | Validación visual |
| 9 | P-ECO-2 Tres recursos + monetización honesta | Economía | B | S/M | P-NAR-2 |
| 10 | P-GD-4 Gremio asíncrono | Game design | B | M | P-GD-2 |
| 11 | P-LRN-2 Listening/SRS como variantes | Aprendizaje | B | M | Contenido |
| 12 | P-UX-3 "Hoy" como hub | UX | B | M | P-GD-2 |
| 13 | P-LRN-3 Currículo único | Aprendizaje | B | L | #202/#203 |
| 14 | P-NAR-2 Maná como pacto | Narrativa | B | S/M | P-ECO-2 |

## 7. Las 10 oportunidades más importantes (ordenadas)

1. **P-ECO-1 · Esfuerzo vs Maestría.** Sin esto, el RPG recompensa estar, no
   aprender, y ninguna otra propuesta arregla la promesa central.
2. **P-GD-1 · Rango como llave.** Devuelve la fantasía de ascenso y da sentido a
   exámenes, gremio y contenido.
3. **P-GD-3 · Cerrar los sistemas muertos.** La relación
   coste/credibilidad más alta: freeze, battle pass, pergamino e ítems de maná,
   con salida ya decidida (D-03/D-04/D-05).
4. **P-GD-2 · Motor único de misión en 3 capas.** Convierte 629 instancias y 8
   completadas en un bucle que se puede cerrar.
5. **P-LRN-1 · Resumen con evidencia.** El único momento de "prueba" de
   aprendizaje; hoy solo muestra moneda.
6. **P-UX-1 · Estados honestos.** Barato, visible y arregla dos issues abiertos
   (#255, #256).
7. **P-NAR-1 · Canon y glosario.** Una página de texto que ordena todo el copy y
   elimina tres escalas de rango.
8. **P-UX-2 · Accesibilidad AA.** Requisito de tienda y de producto; 4 críticos
   abiertos.
9. **P-ECO-2 · Tres recursos y monetización honesta.** Quita fricción justo donde
   el jugador decide pagar.
10. **P-GD-4 · Gremio asíncrono.** Evita que el módulo social comunique "juego
    muerto" mientras no haya masa crítica.

**Secuencia recomendada:** primero los *quick wins* que ordenan el terreno
(P-UX-1 → P-GD-3 → P-NAR-1 → P-ECO-2); en paralelo, el rediseño de progresión
(P-ECO-1 → P-GD-1 → P-LRN-1). El resto, cuando esas tres tengan datos.
