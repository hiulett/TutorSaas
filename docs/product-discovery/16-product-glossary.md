# 16 — Glosario oficial del producto

> **Para qué sirve.** Una sola fuente para nombrar las cosas igual en diseño,
> producto, código y textos. Cada término dice **qué significa en este
> producto** (no en el género RPG), **dónde vive** (archivo:línea, tabla o RPC)
> y **si existe de verdad**.
>
> **Medido:** 30-oct-2026. Los `archivo:línea` de `.arb` se refieren a
> `lib/l10n/app_es.arb` salvo que se indique otro idioma.
> Contexto: [`00`](00-product-overview.md), [`01`](01-product-identity-and-universe.md).

---

## 0. Reglas de nomenclatura (normativa)

1. **El producto se llama "Dungeon of English"** en la interfaz
   (`app_es.arb:5`). "DungeonSpeak" es el nombre de tienda/Android
   (`AndroidManifest.xml:11`) y "tutorsaas" el técnico (`pubspec.yaml:1`).
   No inventar un cuarto nombre; "TutorSaaS" solo sobrevive en un mapa de
   traducciones **muerto** (`core/i18n/app_translations.dart:4`).
2. **"Cazador"** (Hunter) es el usuario. Nunca "alumno", "estudiante" ni
   "jugador" en textos de producto — aunque el código use `student` en prompts
   en inglés.
3. **"Mazmorra" = escenario de práctica**, no un nivel abstracto. Si se dice
   "mazmorra de vocabulario" hay que saber que **no existe** (§11).
4. **"Maestre de Mesa"** es el NPC del gremio; **"Maestro del Gremio"** es un
   cargo que solo aparece en una clave duplicada (§10).
5. **"Estamento"** = plan de pago (plebeyo/noble/realeza). **"Título de
   prestigio"** = escalón ganado con Aura. No son lo mismo (§4).
6. **"Maná"** es la energía que cuesta la IA; **"Aura"** es el mérito que no se
   gasta. Confundirlos rompe todo el modelo (§7 y §4).

---

## 1. Identidad y marcas

| Término | Significado en el producto | Dónde vive | Etiqueta |
|---|---|---|---|
| **Dungeon of English** | Nombre de la app en la interfaz | `app_es.arb:5` | `[IMPLEMENTADO]` |
| **DungeonSpeak** | Nombre en el lanzador de Android y en los SKU de Play (`dungeonsspeak_*`) | `AndroidManifest.xml:11`; `docs/PRODUCT.md:34` | `[IMPLEMENTADO]` |
| **tutorsaas** | Nombre del paquete y del proyecto (`com.tutorsaas.tutorsaas`) | `pubspec.yaml:1`, `android/app/build.gradle.kts:37` | `[IMPLEMENTADO]` |
| **TutorSaaS** | Nombre legado en un diccionario de traducciones que **nadie lee** | `core/i18n/app_translations.dart:4` | `[CONCEPTUAL]` |
| **Cazador / Hunter** | El usuario, en clave RPG | `app_es.arb:175,326-327`; `HUNTER_CLASSES` en `hunter_class.dart` | `[IMPLEMENTADO]` |
| **Sistema (HUD)** | La voz que anuncia estado y logros ("EL SISTEMA HA HABLADO") | `app_es.arb:494,509-513` | `[IMPLEMENTADO]` |

---

## 2. El mundo

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **El Gran Reino** | Metáfora del backend; el splash "se conecta" a él | `app_es.arb:510-511`, `splash_screen.dart:224` | `[IMPLEMENTADO]` (texto) |
| **Gremio** | El hub social: 2.ª pestaña del dashboard | `app_es.arb:57`, `dashboard_screen.dart:373-374` | `[IMPLEMENTADO]` |
| **Salón del Gremio** | Pantalla del gremio (`ChatRoomsScreen`) | `app_es.arb:192`, `chat_rooms_screen.dart:48` | `[IMPLEMENTADO]` |
| **Mesa** | Una sala de voz del gremio (= fila en `chat_rooms`) | `app_es.arb:262-265`; `public.chat_rooms` (6) | `[IMPLEMENTADO]` |
| **Mazmorra** | Un escenario de práctica; se entra a `/conversation` | `app_es.arb:172`, `learning_path_roadmap.dart:721,774` | `[IMPLEMENTADO]` |
| **Mapa de Mazmorras** | La ruta de lecciones por etapas | `app_es.arb:1004`, `learning_path_roadmap.dart` | `[IMPLEMENTADO]` |
| **Portal** | Entrada de nivel: "ELIGE UN PORTAL SEGÚN TU RANGO" | `app_es.arb:1063-1065` | `[IMPLEMENTADO]` (texto + fondo) |
| **Bioma por banda** | Bosque (PRE-A1/A1), ruinas (A2), viento (B1), portal (B2), arena (C1/C2) | `cyber_manhwa_background.dart:145-156` | `[IMPLEMENTADO]` |
| **Santuario de Maná** | Pantalla de energía agotada/compra. Antes "Guardián" | `app_es.arb:521-529`, `dungeon_guardian_screen.dart:156` | `[IMPLEMENTADO]` |
| **Rusty Flagon** | La posada de Mira, única con escena propia | `mini_conversation_script.dart:28,53` | `[IMPLEMENTADO]` |
| **La Taberna** | La sala del gremio, con música en loop | `tavern_music_service.dart:8`, `app_es.arb:705` | `[IMPLEMENTADO]` |
| **Núcleo Arcano** | Energía antigua del Oráculo, sustituida por el maná. **Texto muerto** | `app_es.arb:219-221,288,428-430` (0 usos en widgets) | `[CONCEPTUAL]` |
| **Taberna del Aprendiz · Mesa Redonda de Tácticas · Consejo Supremo** | Mesas que el Maestre recomienda y que **no existen en la BD** | `app_es.arb:705-711` | `[CONCEPTUAL]` |

---

## 3. Niveles y rangos

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **CEFR** | Escala de nivel: PRE-A1, A1, A2, B1, B2, C1, C2 | `docs/PRODUCT.md:70`; `cefr_rank.dart:10`; tabla `cefr_levels` (7) | `[IMPLEMENTADO]` |
| **Rango del gremio (F–SSS)** | Traducción lúdica del CEFR: PRE-A1=F, A1=E, A2=D, B1=C, B2=B, C1=A, C2=S (+SS, SSS) | `cefr_rank.dart:13-35,73` | `[IMPLEMENTADO]` |
| **SS / SSS** | Rangos superiores sin flujo que los asigne (C2 ya es S) | `cefr_rank.dart:33-34` | `[PARCIAL]` |
| **Placement** | Evaluación oral inicial con el Oráculo que fija CEFR y rango | `placement_service.dart:45` → `evaluate-placement` → `apply_placement_as` | `[IMPLEMENTADO]` |
| **Nivel de cazador** | Nivel numérico por XP: `1 + XP/1000`; desbloquea cosméticos y paga oro | `docs/PRODUCT.md:58`; `hunter_level_test.dart` | `[IMPLEMENTADO]` |
| **Etapa Básica** | PRE-A1 + A1 + A2: requisito para despertar el Aura | `app_es.arb:485,487`; `aura_system.dart:102-115` | `[IMPLEMENTADO]` |
| **Racha (streak)** | Días consecutivos practicando | `app_es.arb:122,204`; `player_streaks`; `streak_rules.dart:5` | `[IMPLEMENTADO]` |
| **Freeze de racha** | Compra con gemas que protege un día perdido (máx. 3) | `app_es.arb:605-609`; RPC `purchase_streak_freeze` (`economy_repository_impl.dart:675`) | `[IMPLEMENTADO]` |

---

## 4. Jerarquía social y prestigio

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **Estamento** | Clase social comprada = plan: `plebeyo`, `noble`, `realeza` | `app_es.arb:987,968`; `subscription_plans.class_name` | `[IMPLEMENTADO]` |
| **Techo de prestigio** | Título máximo alcanzable según el estamento (`ceiling_class`) | `prestige_ladder.ceiling_class`; `compute_prestige_title` (migración `20260813_mana_aura_redesign.sql:365-374`) | `[IMPLEMENTADO]` |
| **Título de prestigio** | Escalón ganado por Aura + radar dentro del techo (21 niveles) | `public.prestige_ladder`; `get_prestige_title` (`economy_repository_impl.dart:956`) | `[IMPLEMENTADO]` |
| **Segmento** | Agrupación del escalón: `comun`, `noble`, `real` | `prestige_ladder.segment` | `[IMPLEMENTADO]` |
| **Prestigio (chip)** | El título mostrado en el HUD del gremio | `app_es.arb:395` (`PRESTIGIO {level}`), `chat_rooms_screen.dart:1048-1075` | `[PARCIAL]` (el chip usa nivel de battle pass, no el título) |
| **Aura** | Poder 0–1 calculado con radar, racha y CEFR; también "Aura XP", mérito acumulado sin tope | `aura_system.dart:126-159`, `app_es.arb:483-495` | `[IMPLEMENTADO]` |
| **Usuario del Aura** | Estado desbloqueado al superar la Etapa Básica o ser acreditado ≥B1 | `app_es.arb:486`; `aura_system.dart:78-81` | `[IMPLEMENTADO]` |
| **Tiers de Aura** | `latente · revelada · abierta · dominante · abisal` (cortes 0,25/0,45/0,65/0,85) | `aura_system.dart:19,153-158`; `app_es.arb:489-493` | `[IMPLEMENTADO]` |
| **Título de habilidad** | 25 títulos en 6 líneas (fluidez, fonética, léxico, precisión, constancia, carisma) | `hunter_skill_titles.dart`; `hunter_titles` (24); `app_es.arb:889-966` | `[IMPLEMENTADO]` (hardcodeado; la tabla no se lee) |
| **Matriz de 11 atributos** | FUE/DEX/INT/SUE… **no existe**: el radar real es de 5–6 ejes | `app_es.arb:269,1073-1079` (0 usos) | `[CONCEPTUAL]` |
| **Liga de Nivel** | Clasificación por ligas: **texto sin widget**; el leaderboard real es "Rango de XP" | `app_es.arb:884-887`; `progress_tab_view.dart:535-541` | `[CONCEPTUAL]` |

---

## 5. Personajes

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **El Oráculo** | Examinador y jefe: hace el placement y la promoción de nivel | Prompt `conversation_providers.dart:1263-1300`; `app_es.arb:211,503`; avatar `assets/images/avatars/oracle_01.png` | `[IMPLEMENTADO]` |
| **Mira, la posadera** | NPC de la prueba de 60 s (2 turnos, sin maná) | `mini_conversation_script.dart:28,53-70`; `app_es.arb:1286` | `[IMPLEMENTADO]` |
| **Maestre de Mesa** | NPC consejero del gremio por chat | `guild_master_floating_banner.dart:130-137`; `app_es.arb:712` | `[IMPLEMENTADO]` |
| **Maestro del Gremio** | Cargo que solo existe en la clave duplicada `guild_master` | `app_es.arb:258` | `[CONCEPTUAL]` |
| **Bibliotecaria del Gremio · Escriba Real · Cónsul del Debate** | "NPC" de misión: solo etiqueta, sin agente | `app_es.arb:743-745` | `[CONCEPTUAL]` |
| **Tutor** | El interlocutor de las mazmorras; rol definido por escenario | `lesson_catalog.dart` (`assistantRole`); `conversation_repository_impl.dart` | `[IMPLEMENTADO]` |

---

## 6. Pedagogía

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **Escenario** | Unidad de contenido: rol + metas + frases clave | `scenarios` (500), `scenario_goals`, `scenario_objectives`, `scenario_phrases`; `lesson_catalog.dart` | `[IMPLEMENTADO]` |
| **Meta / objetivo** | Condición de comunicación a cumplir en la conversación | `scenario_goals`/`user_scenario_goals`; evaluadas por LLM (`evaluate_placement`/`goal_eval`) | `[IMPLEMENTADO]` |
| **Estrella** | Calificación de la lección (1–5); la 4.ª/5.ª exigen "chat oculto" | `app_es.arb:1048` (`convo_hidden_chat`); `lesson_completion_stars` (RPC) | `[IMPLEMENTADO]` |
| **Chat oculto** | Modo sin texto visible: obliga a escuchar | `app_es.arb:1048,1058` | `[IMPLEMENTADO]` |
| **Camino / Ruta** | Secuencia desbloqueada de escenarios por nivel | `lesson_unlock_service.dart:37`; `get_recommended_path` | `[IMPLEMENTADO]` |
| **Centro de descubrimiento** | Vista de catálogo filtrable (nivel, interés, meta) | `app_es.arb:1180-1200` | `[IMPLEMENTADO]` |
| **SRS / repaso espaciado** | Repaso de vocabulario por vencimiento (SM-2) | `srs_review_card.dart`, `srs_flashcard_modal.dart`; `record_vocabulary_review` (`dashboard_repository_impl.dart:682`); `vocabulary_reviews` | `[IMPLEMENTADO]` |
| **Retención a 7 días** | % de palabras recordadas; única métrica "dura" de aprendizaje | `app_es.arb:415` (`srs_retention`) | `[IMPLEMENTADO]` |
| **Corrección** | Sugerencia "Escribiste / Mejor" con tipo (gramática, vocabulario, elección, pronunciación, STT) | `app_es.arb:1010-1025`; `corrections` (0 filas) | `[PARCIAL]` |
| **Mis errores** | Historial agrupado por tipo y recurrencia | `my_errors_screen.dart:20`; `corrections_repository.dart:72-88` | `[IMPLEMENTADO]` (sin datos todavía) |
| **Lección de refuerzo** | Lección generada a partir de errores/metas falladas; cuesta 100 de maná | `lesson_generator_service.dart:32`; `lesson_generation` (100); `app_es.arb:793-801` | `[IMPLEMENTADO]` |
| **Comprensión auditiva** | Diálogo TTS + preguntas corregidas en servidor | `listening_quiz_screen.dart:26`; `submit_listening_attempt` (`listening_repository.dart:128`) | `[IMPLEMENTADO]` (0 intentos) |
| **Informe semanal** | Resumen calculado en servidor con historial según plan | `weekly_report_service.dart:26`; `get_weekly_report`; `app_es.arb:1351-1377` | `[IMPLEMENTADO]` |
| **Meta diaria** | Objetivo de minutos/día elegido en el onboarding | `get_daily_goal_progress` (`dashboard_providers.dart:45`); `DailyGoalRingCard` (`dashboard_screen.dart:399`) | `[IMPLEMENTADO]` |
| **Precisión (est.) / Fluidez (est.)** | Métricas **estimadas** por el modelo, no acústicas | `app_es.arb:806-809`; `docs/PRODUCT.md:63-64` | `[IMPLEMENTADO]` con salvedad |
| **Huella de voz / Speech DNA** | Métricas por escenario de pronunciación | `app_es.arb:255,1060`; `speech_dna_metrics` | `[PARCIAL]` |

---

## 7. IA y su coste

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **Maná** | Energía que consume cada acción de IA; expira con el ciclo | `app_es.arb:518-533`; `user_subscriptions.mana_*`; `consume_mana` (`economy_repository_impl.dart:785`) | `[IMPLEMENTADO]` |
| **Coste por acción** | Precio en maná de cada llamada, decidido en servidor | `public.ai_action_costs` (7 acciones, §00 §7.2) | `[IMPLEMENTADO]` |
| **Acción exenta (`FREE_ACTIONS`)** | Llamadas que no gastan maná: `goal_eval`, `carisma_eval`, `guild_chat`, `stt_transcribe`, `correction_turn` | `supabase/functions/llm-proxy/validation.ts:23-29` | `[IMPLEMENTADO]` |
| **Tope diario** | 200 de maná/día en el plan gratuito | `docs/PRODUCT.md:123-137` | `[IMPLEMENTADO]` |
| **Turno de gracia** | Un cierre gratis al día cuando se agota el tope diario; lo reclama el servidor | `claim_mana_grace` (0 usos en cliente: es correcto, vive en `llm-proxy`) | `[IMPLEMENTADO]` |
| **`llm-proxy`** | Edge Function única para STT y chat SSE | `supabase/functions/llm-proxy/index.ts` | `[IMPLEMENTADO]` |
| **`evaluate-placement`** | Edge Function que decide CEFR/rango y escribe el intento | `supabase/functions/evaluate-placement/index.ts:492,518` | `[IMPLEMENTADO]` |
| **`lesson-generator`** | Edge Function de lecciones de refuerzo | `supabase/functions/lesson-generator/`; `lesson_generator_service.dart:32` | `[IMPLEMENTADO]` |
| **Jefe de mazmorra** | El examen de promoción (el propio Oráculo), con rúbrica de 6 dimensiones | `app_es.arb:1316-1350`; `boss_exam_rules.dart`; `boss_exam_attempts` | `[IMPLEMENTADO]` |
| **Checkpoint de nivel** | Aviso al completar N lecciones para retar al Oráculo | `app_es.arb:1377-1381`; `level_checkpoint_banner.dart:117` | `[IMPLEMENTADO]` |
| **Rúbrica** | 6 dimensiones: comprensión, fluidez, gramática, vocabulario, pronunciación, naturalidad | `app_es.arb:1334,1345-1350` | `[IMPLEMENTADO]` |
| **NPC que recuerda** | Aviso de que el NPC retoma tu intento anterior | `app_es.arb:412-413` | `[PARCIAL]` |

---

## 8. Economía

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **Oro** | Moneda de cosméticos | `app_es.arb:590`; `add_gold` (`economy_repository_impl.dart:862`) | `[IMPLEMENTADO]` |
| **Gemas** | Moneda premium (cosméticos exclusivos, freeze de racha) | `app_es.arb:589`; `spend_gems` (`:420`), `add_gems` (`:221`) | `[IMPLEMENTADO]` |
| **Fragmentos** | Moneda de crafteo | `app_es.arb:591`; `add_fragments` (`:734`), `craft_cosmetic` (`:653`) | `[IMPLEMENTADO]` |
| **Pergaminos** | Recompensa de racha acumulable con tope | `app_es.arb:546-550`; tabla `player_pergaminos`; `increment_pergaminos_max` | `[IMPLEMENTADO]` |
| **XP** | Puntos de nivel de cazador | `app_es.arb:121`; `add_xp` (`:944`) | `[IMPLEMENTADO]` |
| **Bolsas de nivel / recompensas de nivel** | Oro que se cobra al subir de nivel | `app_es.arb:600-604`; UI en `shop_screen.dart:532-565`; `level_rewards`, `claim_level_rewards` (`:705`) | `[IMPLEMENTADO]` |
| **Recompensa diaria** | Cofre diario escalado por racha | `app_es.arb:542-554`; `daily_reward_modal.dart` | `[IMPLEMENTADO]` |
| **Tienda** | Cosmética por oro/gemas/fragmentos (no vende ventajas de aprendizaje) | `shop_screen.dart:29`; `cosmetic_catalog` (40); `purchase_cosmetic` (`:627`) | `[IMPLEMENTADO]` |
| **Inventario** | Cosméticos poseídos y equipados | `inventory_screen.dart:18`; `player_inventory`; `equip_cosmetic` (`:376`) | `[IMPLEMENTADO]` |
| **Elixir / Gema de maná** | Objeto equipable que da maná | `app_es.arb:527,997-1003`; `mana_items`, `equip_mana_item` (`:987`) | `[IMPLEMENTADO]` |
| **Poción de maná** | Pack de maná (7 en catálogo) — **no se vende**. `docs/PRODUCT.md:60-61` | `mana_potions` (7) | `[PARCIAL]` |
| **Battle Pass / Pase del Gremio** | Tabla con nivel y temporada fija (`season_2026_02`); **no hay pantalla de pase** | `economy_repository_impl.dart:508-536`; `guild_battle_pass` (23); `app_es.arb:618` | `[PARCIAL]` |
| **Recompensa de sesión** | XP/oro/fragmentos al cerrar sesión; la calcula el servidor | `apply_session_rewards`; `close_session` (`:798`); `session_summary_screen.dart:22-24` | `[IMPLEMENTADO]` |
| **Drop de sesión** | Objeto sorpresa de fin de sesión | `session_drop_controller.dart`; `claim_session_drop` (`:926`) | `[PARCIAL]` |

---

## 9. Compras

| Término | Significado | Dónde vive | Etiqueta |
|---|---|---|---|
| **Plebeyo** | Plan gratis por defecto | `subscription_plans.id='plebeyo'`; `app_es.arb` | `[IMPLEMENTADO]` |
| **Noble** | Plan de $4.99 con 7 días de trial | `subscription_plans.id='noble'` (`trial_days=7`) | `[IMPLEMENTADO]` |
| **Realeza** | Plan de $9.99, techo de prestigio completo | `subscription_plans.id='realeza'` | `[IMPLEMENTADO]` |
| **Divino** | Plan retirado (`is_active=false`), conservado por integridad referencial | `subscription_plans.id='divino'`; `docs/PRODUCT.md:27-29` | `[PARCIAL]` |
| **Entitlement** | `DungeonsSpeak Pro` en RevenueCat | `docs/PRODUCT.md:37`; `core/services/revenuecat_service.dart` | `[IMPLEMENTADO]` |
| **`sync-entitlement`** | Reconciliación del entitlement al abrir sesión | `supabase/functions/sync-entitlement/` | `[IMPLEMENTADO]` |
| **Paywall** | Pantalla de estamentos y compra | `paywall_screen.dart:32`; planes activos desde `subscription_plans` | `[IMPLEMENTADO]` |

---

## 10. Claves en conflicto (no usar hasta resolver)

| Clave | Valores en conflicto | Efecto | Evidencia |
|---|---|---|---|
| `guild_master` | "★ MAESTRO DEL GREMIO" vs "MAESTRE DE MESA" | Gana la última: el cargo mayor desaparece | `app_es.arb:258` vs `:712` |
| `radar_title` | "Radar de Habilidades 5-D" vs "Radar Holográfico de Habilidades" | El "5-D" es incierto (el jefe mide 6) | `app_es.arb:113` vs `:445` |
| `rank` | "Rango" vs "RANGO" | Inconsistencia tipográfica | `app_es.arb:176` vs `:372` |
| `profile_vocab_empty` | Dos mensajes distintos | Copy arbitrario | `app_es.arb:475` vs `:845` |
| `room_live` | Duplicado idéntico | Ruido | `app_es.arb:237` vs `:383` |
| `path_roadmap_title`, `cancel`, `onboarding_start_eval` | Duplicados solo en `en` | paridad de claves rota | `app_en.arb` |

---

## 11. Términos que **no** existen (falsos amigos)

Evitan que diseño o marketing prometan algo que no hay:

| Término | Por qué no existe |
|---|---|
| **Mazmorra de Vocabulario** | Solo en el diccionario muerto (`app_translations.dart:36`); el vocabulario se practica con SRS |
| **Matriz de 11 atributos** | Texto huérfano; el radar es de 5–6 ejes |
| **Liga** | Texto huérfano; hay leaderboard plano |
| **Resonancia / mentoría** | Etiqueta de tipo de sala, sin flujo |
| **Moderación por IA/creador/asignada** | `mod_*` sin usos; las salas son `moderator_type='ai'` pero no hay UI de moderación |
| **Battle pass con tiers y recompensas** | Hay tabla y nivel; no hay pase jugable |
| **Misiones secretas / eventos globales** | Tablas sin pantalla |
| **63 títulos** | Hay 24 en BD y 25 en código |
| **Núcleo Arcano** | 8 claves, 0 usos |
| **Pase del Gremio** | Clave sin uso (`app_es.arb:653`) |
| **Plan Divino** | Retirado |
| **Enseñanza de lectura/escritura** | No hay ejercicios evaluados (`docs/PRODUCT.md:11-13`) |

---

## 12. Siglas internas (para leer el código)

| Sigla | Significado | Nota |
|---|---|---|
| **CEFR** | Marco Común Europeo de Referencia | 7 niveles, `cefr_rank.dart:10` |
| **SRS** | Spaced Repetition System | SM-2, `vocabulary_reviews` |
| **STT / TTS** | Speech-to-text (Groq Whisper) / text-to-speech (`flutter_tts`) | `docs/ARCHITECTURE.md:92-98` |
| **RPC** | Función Postgres expuesta por Supabase | 82 en `public` |
| **RLS** | Row Level Security | 130 políticas |
| **P-NN** | Identificador de paquete de trabajo con issue de GitHub | p. ej. P-31 = #116 |
| **Aura XP** | Mérito acumulado sin tope que decide el título de prestigio | ≠ XP de nivel |
