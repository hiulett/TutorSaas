# MASTER_AUDIT_V2.md — TutorSaas / Dungeon of English
### Auditoría Estratégica Final Consolidada (Consejo de Revisión AAA)

> **Esta es la nueva Fuente Única de la Verdad del proyecto.** Reemplaza a `MASTER_AUDIT.md` (cuyas conclusiones válidas se conservan, las desactualizadas se corrigen y las áreas nuevas se incorporan).
> Fecha: 2026-07-30 · Método: toda conclusión verificada contra código, DB, assets y documentación. No se implementaron cambios.
> Pregunta rectora: **¿Qué falta para que esta app sea la mejor experiencia RPG de aprendizaje de idiomas y esté lista para Beta Pública y Producción?**

---

## 1. Resumen Ejecutivo

**Dungeon of English** (Flutter + Supabase + Groq/DeepSeek) tiene un core **funcional y estable**: `flutter analyze` 0 errores, `flutter test` 13/13, build apk OK, 20 rutas, 46 tablas, 21 plantillas HTML de referencia visual.

**Estado: LISTO PARA BETA CERRADA. No listo para beta pública ni producción.**

**Tres bloqueos de fondo, en orden de impacto en el producto:**
1. **🔴 Identidad RPG incompleta (producto)**: el usuario percibe una app educativa con skin RPG, no un juego. Narrativa, enemigo, atmósfera y ciclo emocional son débiles. El Guild tiene NPC/quest board, pero el habla entre jugadores es **simulada** (rompe la inmersión).
2. **🔴 Inconsistencia visual**: 17 archivos con diseño antiguo (`orbitron`/`hankenGrotesk`) conviven con el estándar PlantillasHTML. La app NO se ve uniforme.
3. **🟡 Seguridad/claves (IA-01 resuelto)**: las API keys ya no están en el repo ni en el APK — viven como secrets de la Edge Function `llm-proxy` y se rotaron. Pendiente: revisar RLS anon en 54 políticas.

**Verificado en esta ronda:** sin CI/CD, sin push notifications reales, sin Crashlytics/Sentry (solo ErrorTracker local), tests insuficientes (2 archivos), migraciones aplicadas manualmente sin versionar, sin analytics de retención.

---

## 2. Estado General del Proyecto

| Dimensión | Estado | Evidencia |
|---|---|---|
| Compilación | ✅ | `flutter build apk --debug` OK |
| Análisis estático | ✅ | `flutter analyze`: 0 errores (64 infos/warnings) |
| Tests | ✅ 13/13 | 2 archivos (`overflow_test`, `mission`?) — **insuficiente** |
| DB live | ✅ | 46 tablas, RLS, Realtime; proyecto `sipiumfdpvnszthykyog` |
| Rutas | ✅ | 20 rutas go_router |
| Seguridad DB | 🟡 | QA-1/2/3 aplicados; 54 políticas RLS anon pendientes |
| Seguridad claves | ❌ | IA-01 pendiente |
| CI/CD | ❌ | No existe (.github/fastlane ausentes) |
| Observabilidad | 🟡 | ErrorTracker + LatencyBenchmark locales; sin Sentry/Crashlytics |
| Push | ❌ | Sin firebase_messaging |
| Veredicto | 🟡 | Beta cerrada |

---

## 3. Revalidación del MASTER_AUDIT.md

| Sección MASTER_AUDIT | ¿Sigue válida? | Actualización |
|---|---|---|
| 1-2 Resumen/Estado | ✅ Válida | Confirmada con nuevos datos (sin CI/CD, sin push) |
| 3 Arquitectura | ✅ Válida | 20 rutas (antes 19); confirmado sin Firebase |
| 4 Módulos | ✅ Válida | Confirmada |
| 5-17 UI/Diseño/Migración | ✅ Válida | 17 archivos con estilo antiguo **reconfirmados por grep** |
| 18-20 Deuda/Riesgos | ✅ Válida | Confirmada |
| 21-24 Roadmap/Checklists | ✅ Válida | Se mantiene; se amplía en V2 |
| **No analizados antes** | ❌ Faltante | **Partes III-XVI (producto, game loop, retención, psicología, narrativa, economía simulada, balance, live ops, competitivo, visión)** — cubiertas por primera vez en V2 |

**Conclusiones corregidas/actualizadas:**
- "Fases 2-10 implementadas" → correcto, pero el **valor de producto** de esas fases es desigual: la mayoría aporta a la experiencia, algunas (draggable_monster, emote, blind-listening) tienen ROI dudoso.
- La economía es sostenible en costos, pero **no hay prueba de retención** (sin analytics).

---

## 4. Auditoría Técnica

### Verificaciones
- **Flutter**: 3.29 / Dart 3.11 · Riverpod · go_router · freezed · dio · fl_chart · google_fonts.
- **Supabase**: Postgres + Auth + RLS + Realtime. **No hay Firebase** (el prompt lo menciona; se aclara: se usa Supabase, no Firebase).
- **IA**: Groq (STT) + DeepSeek (LLM, `deepseek-v4-flash`) + flutter_tts on-device.
- **APIs**: Supabase REST/Realtime; Groq/DeepSeek vía dio.

### Hallazgos técnicos nuevos
| # | Hallazgo | Severidad |
|---|---|---|
| T-01 | **Sin CI/CD**: no hay pipeline de build/test/lint automatizado | Alta |
| T-02 | **Sin observabilidad de producción** (Sentry/Crashlytics) | Alta |
| T-03 | **Sin analytics de producto** (funnel, retención, eventos) | Alta |
| T-04 | **Tests insuficientes**: 2 archivos; sin tests de repos/economía/misiones | Alta |
| T-05 | `dashboard_screen.dart` 2040 líneas (monolito) | Alta |
| T-06 | Misiones sin interfaz abstracta (inconsistencia arquitectónica menor) | Baja |
| T-07 | Sin caching de respuestas IA (IA-06) | Media |
| T-08 | Migraciones aplicadas manualmente (no versionadas en schema_migrations) | Media |

---

## 5. Auditoría Arquitectónica

- **Feature-first clean architecture**: correcta y consistente en 9 features.
- **Riverpod** bien usado (StateNotifierProvider / FutureProvider.autoDispose / StateProvider).
- **go_router** con 20 rutas; uso correcto de `push` para profundidad.
- **SOLID**: cumplido en su mayoría; excepciones: misiones (repo concreto), onboarding (state gigante).
- **Código duplicado**: moderado — estilos de botones repetidos (mitigado con RunicButton), layouts de card repetidos (mitigado con GlassCard).
- **Widgets gigantes**: dashboard (2040), conversation (1221), onboarding (1409) → refactor P1.

---

## 6. Auditoría de Seguridad

| Ítem | Estado |
|---|---|
| QA-1 `system_ai_settings` → service_role | ✅ aplicado |
| QA-2 `vocabulary_items` validado | ✅ aplicado |
| QA-3 REVOKE EXECUTE (PUBLIC+anon) + regrant selectivo | ✅ aplicado y verificado |
| RLS por usuario (`auth.uid() = user_id`) | ✅ mayoría de tablas |
| **RLS accesible a `anon` (54 políticas)** | ❌ pendiente (QA-5) |
| **API keys en repo** (DeepSeek/Groq + fallback) | ✅ IA-01 resuelto (proxy por Edge Function) |
| Leaked-password protection | ❌ deshabilitada (QA-4) |
| Crashlytics/Sentry | ❌ |

---

## 7. Auditoría de Base de Datos

- **46 tablas públicas**, RLS activo, Realtime en tablas clave.
- **Performance (Supabase Advisors)**: 95 hallazgos — 21 FK sin índice, 17 índices sin uso, 55 RLS initplan (`auth.uid()` por fila), 1 índice duplicado (`ai_usage_logs`), 1 política duplicada (`subscription_plans`).
- **Seguridad (Advisors)**: 81 — la mayoría resuelta (QA-1/2/3); restan 54 RLS anon + leaked-password.
- **Riesgo de datos**: migraciones de las fases 7-11 aplicadas manualmente en SQL Editor; no versionadas en `schema_migrations` → riesgo de drift.

---

## 8. Auditoría de Performance (app)

- **Render**: glow rúnico loop infinito en cada GlassCard (AN-07) → riesgo de batería/GPU.
- **Rebuilds**: dashboard monolítico (2040 líneas) → rebuilds amplios.
- **Consultas**: `getRooms` anti N+1 ✅; `evaluateGoals` ventana móvil ✅; resto con N+1 potencial.
- **IA latencia**: objetivo <1.5s; STT+LLM medidos por `LatencyBenchmark`.
- **Memoria/CPU**: sin perfiles documentados; pendiente.

---

## 9. Auditoría UI

Ver sección 11 (Visual) — ambas se fusionan por claridad. Resumen: **mezcla de estilos confirmada en 17 archivos** (grep `orbitron`/`hankenGrotesk`).

---

## 10. Auditoría UX

### Fricciones confirmadas
1. Doble limitación de uso (cuota minutos mensual + núcleo arcano diario) → confuso.
2. i18n incompleto en onboarding (descripciones en inglés).
3. Audio de gremio simulado (`Random()`) → falsa sensación de vida.
4. Onboarding de 9 pasos + paywall al final: largo para un primer contacto (abandono).
5. Sin feedback auditivo generalizado (SFX solo parcial).

### Puntos de fricción nuevos
- **Sin tutorial de cómo hablar/raidear** tras el onboarding (gap entre registro y primera raid).
- **Sin estado vacío motivante** en misiones/inventario cuando el usuario es nuevo.
- El **paywall en el onboarding** (paso 8 de 9) fuerza una decisión monetaria antes de haber experimentado valor.

---

## 11. Auditoría Visual (confirmada y ampliada)

**Mezcla de diseño confirmada por grep.** Archivos con estilo antiguo (`orbitron`/`hankenGrotesk`):

| Archivo | Refs antiguas |
|---|---|
| `onboarding_screen.dart` | 18 hanken |
| `dashboard_screen.dart` | 6 hanken |
| `conversation_screen.dart` | 2 hanken |
| `profile_screen.dart` | 2 orbitron + 1 hanken |
| `level_exam_screen.dart` | 4 orbitron |
| `shop_screen.dart` | 1 orbitron |
| `session_summary_screen.dart` | 1 hanken |
| `voice_room_screen.dart` (mana_meter) | 1 orbitron |
| `system_mana_disruption_screen.dart` | 1 orbitron |
| `mana_meter_widget.dart` | 1 orbitron |
| `status_window_modal.dart` | 5 orbitron + 1 hanken |
| `draggable_monster_widget.dart` | 1 orbitron + 1 hanken |
| Widgets dashboard (6): ai_pick_hero, daily_quests, league_leaderboard, lesson_preview, next_lesson_hero, recommended_hub | 12 hanken |

**Pantallas con diseño nuevo (estándar)**: Gran Salón, HUD, dungeon map, HunterStatus, inventario, battle pass, oracle conversation, placement, settings, NPC, quest board.

---

## 12. Auditoría del Design System

- **Tokens de color**: `AppColors` (Isekai) ✅.
- **Tokens de animación**: `AppMotion` ✅ (nuevo en Fase 10).
- **Tipografía**: SpaceGrotesk/Inter/JetBrainsMono definida, pero **no centralizada** (cada widget importa google_fonts directamente).
- **Falta**: `AppSpacing` (grid 4px), `AppTypography` (wrapper), `AppRadius`, `AppElevation`.
- **Componentes estandarizados**: GlassCard, SystemWindow, SegmentedBar, AnimatedCounter, FloatingReward, RunicButton, RpgAvatar, CyberManhwaBackground, QuestCard.
- **Componentes desactualizados**: `status_window_modal` (→ SystemWindow), `mana_meter_widget` (→ refactor), `draggable_monster_widget`, `configuration_error_widget`.

---

## 13. Auditoría de Migración a Plantillas HTML

**Estándar oficial (extraído de las 21 plantillas):**
- Paleta: voidBg #05070E · manaCyan #00E5FF · royalGold #FFC700 · runeViolet #9D4EDD · emeraldGreen #00E676.
- Tipografía: SpaceGrotesk / Inter / JetBrainsMono.
- Geometría: radio 4px, grid 4px.
- Superficies: GlassCard (opacidad 0.94, borde cyan, glow, esquinas rúnicas).
- Componentes: barras segmentadas, SystemWindow, recompensas flotantes, botones con acento + glow, HUD con gemas/maná.

**Plan Maestro de Migración Visual (orden):**
1. **P0**: eliminar `orbitron`/`hankenGrotesk` de widgets core (mana_meter, status_window_modal, system_mana_disruption, draggable_monster).
2. **P1**: migrar pantallas con diseño antiguo (onboarding, dashboard, profile, session_summary, level_exam, conversation, shop, voice_room).
3. **P1**: migrar 6 widgets de dashboard.
4. **P2**: centralizar tokens (AppSpacing, AppTypography); eliminar hex hardcodeados; i18n completo de onboarding.

---

## 14. Auditoría del Producto

### Problema que resuelve
Hablar inglés con confianza mediante práctica conversacional real, sin vergüenza, dentro de una experiencia que se siente como jugar.

### Propuesta de valor diferencial
- **Voz real con IA** (no ejercicios de lectura): conversación libre corregida en el momento.
- **Temática RPG Isekai/System HUD** (única entre Duolingo/Babbel/Memrise).
- **Guild social** (aprendizaje cooperativo).

### Ventaja competitiva
Ningún competidor mainstream combina: conversación de voz libre + identidad RPG de "cazador" + gremio social + economía gamificada.

### Innovaciones reales
- Conversación por voz con IA como mecánica central (no como complemento).
- Evaluación de metas por LLM con ventana móvil.
- Oráculo conversacional para CEFR.
- Modificadores de misión (reward_multiplier).

### Funcionalidades de bajo valor / a simplificar
- `draggable_monster_widget` (sin uso educativo claro).
- `emote` del gremio (1 item, ROI dudoso).
- "Blind Listening" (sin probar su retención).
- El paywall dentro del onboarding (fricción temprana).

### Decisión de producto sugerida
Reducir onboarding a **3 pasos**: (1) idioma nativo/objetivo, (2) Oracle conversacional (2-3 preguntas), (3) primera raid guiada. Mover el paywall a post-primera-sesión.

---

## 15. Auditoría del Game Loop

### Game Loop actual (real)
```
Abrir app → Dashboard (HUD) → Mapa mazmorras → Conversación (raid)
  → Evaluación metas → Summary (+XP/gemas/fragmentos) → Guild (salón/NPC/quest)
  → Misiones (board) → Tienda/Inventario/Battle Pass → Cerrar
```

### Bucles rotos
1. **La raid no alimenta el mapa de mazmorras**: completar una conversación no "desbloquea" visiblemente el siguiente portal con claridad.
2. **El Guild no retroalimenta el core**: el salón es social pero el audio es simulado → el jugador no "siente" el gremio.
3. **Las misiones no se conectan con la raid en el momento**: el board existe pero no hay "aceptar misión → ir a la raid que la cumple" en un flujo.
4. **Falta el "gancho de regreso"**: no hay recompensa diaria con cuenta atrás visible que invite a volver al día siguiente (la daily reward existe pero sin urgencia visible en el HUD).

### Game Loop ideal (propuesto)
```
Día nuevo → Notificación/gancho (racha en peligro / misión diaria)
  → 1 raid rápida (5-10 min) → loot inmediato + XP
  → Revisar misiones (progreso) → 1 acción social en Guild (NPC/quest)
  → Reclamar daily reward (cuenta atrás visible) → Cerrar con "hito mañana"
```
Meta: **una sesión de 10-15 min/día con 3 micro-ganancias** (raid + misión + daily).

---

## 16. Auditoría de Retención

### Por qué volvería mañana (D1)
- Racha (🔥 streak) con daily reward escalonado (5/50/100/300 gemas). **Existe pero sin urgencia visual**.
- **Falta**: notificación push de racha, countdown de daily reward en HUD.

### Por qué volvería la próxima semana (D7)
- Misiones semanales + battle pass progresivo. **Existe**.
- **Falta**: evento semanal (jefe/desafío) que cree pico de interés.

### Por qué seguiría 6 meses (D30-D180)
- Progresión CEFR + cosméticos + colecciones. **Parcial** — falta contenido narrativo que evolucione.
- **Riesgo alto**: sin narrativa continua ni temporadas, el jugador agota el contenido.

### Eventos/sistemas faltantes
- Notificaciones push (D1/D7).
- Temporadas (contenido que caduca y renueva).
- Eventos semanales (jefe cooperativo del gremio).
- Tabla de clasificación real (leaderboard existe pero sin competencia activa).
- Narrativa episódica.

### Riesgos de abandono
- Fricción del onboarding (9 pasos + paywall).
- Audio de gremio simulado (expectativa social frustrada).
- Doble limitación confusa.
- Sin analytics → no se detecta el abandono.

---

## 17. Auditoría Psicológica del Jugador

| Emoción | ¿Cuándo? | Estado actual |
|---|---|---|
| Satisfacción | Completar una raid con metas | ✅ FloatingReward +XP |
| Orgullo | Subir de nivel / racha larga | 🟡 Solo "SUBIDA DE NIVEL"; falta celebración de racha/CFR |
| Curiosidad | Desbloquear mazmorra / misión secreta | 🟡 Mapa existe; secretas sin narrativa de descubrimiento |
| Sorpresa | Loot raro / evento | ❌ Sin drops sorpresa ni eventos |
| Progreso | HUD XP / battle pass | ✅ AnimatedCounter + SegmentedBar |
| Frustración | Núcleo agotado sin CTA claro | 🟡 Modal existe; falta "recargar" |
| Abandono | Onboarding largo + paywall temprano | ⚠️ Riesgo alto |
| Paga | Cuando agota energía y valora el progreso | 🟡 Paywall correcto en momento de necesidad |

**Punto de diseño clave**: el mayor momento de "pago justo" es **después de una raid exitosa**, no durante el onboarding.

---

## 18. Auditoría de Engagement

| Sistema | Estado | Refuerzo |
|---|---|---|
| Curiosidad | 🟡 | Añadir secretos/drops sorpresa |
| Sorpresa | ❌ | Drops raros + eventos |
| Recompensa | ✅ | FloatingReward, daily, loot |
| Exploración | 🟡 | Mapa existe; sin nodos ocultos |
| Progresión | ✅ | XP/CFR/BP |
| Descubrimiento | ❌ | Sin misiones secretas descubribles en juego |
| Coleccionismo | ❌ | Sin colecciones (DC-02 pendiente) |
| Personalización | 🟡 | Títulos/cosméticos; skins sin usar |
| Competencia | 🟡 | Leaderboard estático |
| Cooperación | ❌ | Guild simulado; sin raids cooperativas reales |
| Comunidad | ❌ | Sin chat global/eventos comunitarios |

---

## 19. Auditoría RPG (identidad)

**Veredicto: el usuario siente una app educativa con elementos RPG, NO un RPG.**

Evidencia:
- El HUD/HUD funciona, pero la **narrativa** (quién soy, por qué peleo, cuál es mi enemigo) es casi inexistente.
- El **Guild es el mayor activo RPG** (NPC, quest board, prestigio) pero el habla simulada rompe la ilusión.
- La **progresión** es RPG (rangos CEFR, XP, títulos) ✅.
- La **ambientación** (CyberManhwaBackground, GlassCard rúnico) es fuerte visualmente ✅.
- **Falta**: enemigo/boss narrativo recurrente, arco de historia, decisiones que importen, consecuencias narrativas.

**Para convertirse en RPG de verdad**, la prioridad no es más mecánicas sino **capa narrativa** + **agencia** (el jugador elige y eso cambia algo).

---

## 20. Auditoría Narrativa

| Pregunta | Respuesta |
|---|---|
| ¿Existe un mundo? | 🟡 Sí, ambientación Isekai (portales, maná, gremio) pero sin lore documentado ni visible |
| ¿Existe un conflicto? | ❌ No hay enemigo/villano claro |
| ¿Existe una historia? | ❌ No hay arco narrativo |
| ¿Existe un enemigo? | ❌ Solo "boss" de examen (mecánico, no narrativo) |
| ¿Progresión narrativa? | ❌ Ninguna (mazmorras no cuentan una historia) |
| ¿Objetivo final? | ❌ No hay meta narrativa (ej. "salvar el Reino del Vacío") |
| ¿Memorable? | ❌ Sin historia, no hay memorabilidad |

**Mejoras propuestas:**
1. Definir el "Reino" y su amenaza (ej. el **Vacío del Olvido** consume el lenguaje).
2. Boss narrativo por rango (A1: aprendiz vs. goblin de gramática; C2: dragón del abismo).
3. Diálogos del Oráculo que avancen un arco.
4. Episodios por temporada con cliffhanger.

---

## 21. Auditoría del Guild

- **Fuerte**: NPC Maestre, quest board, mesas DB reales, prestigio (battle pass), práctica IA con Oráculo.
- **Débil**: audio/moderación entre jugadores **simulados** (bloqueador de inmersión social).
- **Falta**: tipos de mesa activos (mentorship/event/training), trofeos/colecciones, tabla de clasificación del gremio, raids cooperativas.
- **DB**: operativa (7 tablas de gremio).

---

## 22. Auditoría de la Economía (simulación)

### Simulación de recursos
| Horizonte | XP | Gemas | Fragmentos | Observación |
|---|---|---|---|---|
| 1 día | ~200-500 | ~10-30 | ~5-15 | Free agota 30min rápido |
| 1 semana | ~2k-3k | ~100-200 | ~50-100 | Misiones semanales activas |
| 1 mes | ~10k | ~500-800 | ~300-500 | Battle pass nivel 10-20 |
| 6 meses | ~60k | ~3k-5k | ~2k | Gemas se acumulan sin gasto de oro |
| 1 año | ~120k | ~7k-10k | ~5k | **Riesgo: gemas infladas si no hay sinks** |

### Problemas de economía simulada
1. **Gemas acumulables sin propósito fuerte**: la tienda tiene pocos sinks; el jugador ahorra sin gastar → desmotivación.
2. **Oro (`total_gold`) es un recurso muerto**: nunca se gasta (sin lógica).
3. **Fragmentos sin redimir**: solo sirven de contador.
4. **Daily reward llega a 300 gemas** pero la tienda cara (2800 para tema) tarda meses → frustración de precio.

### Corrección sugerida
- **Sinks periódicos**: tienda rotativa diaria/semanal, temporadas con precios que caducan.
- **Oro real**: gastar en "pergaminos de práctica" o entrenamiento del gremio.
- **Fragmentos**: canjear por cosméticos raros o recargas.

---

## 23. Auditoría del Balance

| Ítem | Análisis |
|---|---|
| XP | ~1000 por nivel (HUD); raids dan decenas → razonable |
| Energía | Free 15-20 invocaciones/día + cuota 30min → puede frustrar al free heavy-user |
| Recompensas | Daily 5→300 gemas: buena curva; pero catálogo caro (2800) |
| Dificultad | Sin dificultad dinámica; el mapa CEFR es lineal |
| Misiones | Target razonables; modificadores añaden flexibilidad (sin UI aún, MM-04) |
| Objetos | 13 nuevos; sin colecciones ni drops sorpresa |

**Desequilibrios**: oro muerto, gemas infladas a 6+ meses, dificultad no adaptativa, catálogo sin sinks.

---

## 24. Auditoría de LiveOps

| Sistema | Estado |
|---|---|
| Temporadas | ❌ No existe |
| Eventos | ❌ No existe (solo emergency_missions table) |
| Desafíos semanales | 🟡 Misiones semanales existen |
| Festividades | ❌ No existe |
| Rotación | 🟡 `rotate_daily_missions` SQL + edge fn (local) |
| Battle Pass | ✅ T-502 (nivel/claim) |
| Tablas de clasificación | 🟡 Leaderboard estático |
| Contenido dinámico | ❌ Sin contenido narrativo por temporada |

**Preparado para operar años: NO.** Falta la capa de contenido recurrente (temporadas/eventos) que sostenga D30+.

---

## 25. Auditoría de Monetización

- **Planes**: free $0 / monthly $1.99 / annual $14.99 / lifetime $29.99. Precio **muy competitivo** (Duolingo ~$6-13/mes).
- **Equidad**: sin pay-to-win claro — cosméticos puros + energía recargable.
- **Riesgo**: 30 min/mes de audio free puede sentirse restrictivo en conversación (2-3 raids). Considerar 60 min o "raids ilimitadas con energía".
- **Conversión**: paywall en onboarding = prematuro; mover a post-sesión.
- **IA como monetización**: correcta (minutos = recurso); el core arcano diario es la energía.
- **Riesgo de percepción**: la doble limitación (minutos + núcleo) puede leerse como doble castigo.

**Recomendación**: simplificar a UNA métrica de energía (minutos de audio IA) y que el núcleo arcano sea la "recarga" de esos minutos.

---

## 26. Auditoría de Accesibilidad

| Ítem | Estado |
|---|---|
| Tamaños de fuente | 🟡 Fuentes pequeñas en HUD (8-11px JetBrainsMono) — riesgo |
| Contraste | 🟡 Bajo en onSurfaceVariant sobre fondo oscuro |
| Lectores de pantalla | ❌ Sin semántica explícita en widgets custom (GlassCard etc.) |
| Motion reduction | 🟡 `AppMotion.reduceMotion` existe; no todas las animaciones lo respetan (glow rúnico loop) |
| Táctil | 🟡 Botones custom (RunicButton) deben tener hit-area ≥48px |
| Tiempos de respuesta | ✅ Streaming rápido |

**Prioridad media-baja** para beta cerrada; **alta** antes de producción accesible.

---

## 27. Análisis Competitivo

| Competidor | Fortaleza | Debilidad vs. este proyecto |
|---|---|---|
| **Duolingo** | Retención masiva (D30 altísimo), gamificación probada, IA en beta | Sin conversación de voz libre real; tema cartoon, no RPG inmersivo |
| **Babbel** | Contenido estructurado, calidad pedagógica | Precio alto, menos "juego", poca gamificación social |
| **Memrise** | Contenido mnemotécnico, comunidad | Menos conversación; gamificación menor |
| **RPG ed-tech (Bushido, etc.)** | Temática RPG | Alcance pequeño; la mayoría son ejercicios con skin |
| **Tutor AI (ELSA, Speak)** | Enfoque pronunciación | Sin mundo/progresión RPG ni gremio |

**Posición defendible**: **única combinación de voz libre + RPG identitario + gremio social.** La brecha a cerrar es **retención (D7/D30)** — el fuerte de Duolingo — mediante: narrativa, temporadas, notificaciones y menos fricción.

---

## 28. Visión Estratégica a 3-5 años

### Sistemas que soportan evolución
- Arquitectura feature-first + Riverpod: escalable.
- Supabase RLS por usuario: multi-tenant.
- Pipeline IA desacoplado: permite cambiar modelos (DeepSeek → GPT/Gemini/otro) y añadir embeddings.
- Sistema de misiones/items/battle pass: extensible a temporadas.

### Componentes que deberán rediseñarse
- `dashboard_screen.dart` (monolito) → dividir en widgets por tab.
- Diseño visual: completar migración PlantillasHTML.
- Persistencia de narrativa (tabla de episodios/progreso de historia).

### Riesgos que limitan crecimiento
- Costos IA sin tope duro por plan en producción.
- Sin analytics → no se puede iterar la retención.
- Sin CI/CD → riesgo de regresiones al escalar el equipo.
- Sin push → no se reactiva a usuarios dormidos.

### Oportunidad a 3-5 años
- Liderar el nicho "RPG conversacional para aprender idiomas" con: temporadas narrativas, gremios reales (audio), IA adaptativa por perfil, y expansión multi-idioma (ya hay infraestructura en/l10n multi-target).

---

## 29. Riesgos

| Riesgo | Severidad | Mitigación |
|---|---|---|
| IA-01 claves en repo | **Crítica** | Mover a dart-define + rotar |
| Inconsistencia visual (17 archivos) | **Crítica (producto)** | Plan de migración |
| Audio de gremio simulado | Alta (inmersión) | Etiquetar "demo" o implementar real |
| Sin retención probada (sin analytics) | Alta (negocio) | Añadir analytics + push + temporadas |
| Sin CI/CD | Alta | Pipeline GitHub Actions |
| RLS anon (54) | Media | QA-5 |
| Costos IA | Media | Ya limitados por plan; monitorear |
| Migraciones manuales | Media | Versionar |

---

## 30. Deuda Técnica

| Ítem | Severidad |
|---|---|
| Dashboard 2040 líneas | Alta |
| Onboarding 1409 líneas + 18 hanken | Alta |
| Conversation 1221 líneas | Media |
| API keys (IA-01) | Crítica |
| Tests insuficientes | Alta |
| Sin CI/CD | Alta |
| Sin observabilidad prod | Alta |
| RLS anon (QA-5) | Media |
| Índices (QA-6/7) | Media |
| Migraciones manuales | Media |
| i18n onboarding incompleto | Media |

---

## 31. Oportunidades de Innovación

1. **Narrativa episódica generada por IA**: cada temporada cuenta una historia; el Oráculo adapta la trama al progreso.
2. **Drops sorpresa con rareza visual**: cofres al completar raids con recompensas raras (impulso de sorpresa).
3. **Boss cooperativo del gremio**: raid semanal donde el gremio "pelea" un boss de vocabulario con progreso colectivo (usa `guild_collaborative_missions`).
4. **Modificadores de misión con UI** (MM-04): decisiones tácticas antes de aceptar.
5. **IA adaptativa de dificultad**: el LLM ajusta el nivel en vivo según errores.
6. **Modo mentoría**: usuarios avanzados guían novatos en mesas (nuevo tipo de mesa).

---

## 32. Roadmap Consolidado

### 🔴 Crítica (impide lanzamiento)
- R1 IA-01: claves fuera del repo + rotación.
- R2 Migración visual completa (17 archivos) al estándar PlantillasHTML.
- R3 Reducir onboarding a 3 pasos; mover paywall a post-sesión.
- R4 CI/CD básico (lint+test+build en push).

### 🟠 Alta (antes de beta pública)
- R5 Seguridad: QA-4 leaked-password, revisión RLS anon (QA-5).
- R6 Observabilidad: Sentry/Crashlytics + analytics de retención (D1/D7/D30).
- R7 Push notifications (racha en peligro, misión diaria).
- R8 Dividir dashboard (refactor a widgets por tab).
- R9 MM-04 (UI modificadores) + MO-C/D (modal energía con recarga).
- R10 Tests ampliados (economía, misiones, conversación).

### 🟡 Media (mejoras)
- R11 Narrativa: definir Reino/conflicto + boss por rango + diálogos del Oráculo.
- R12 Temporada 1 + eventos semanales (jefe de gremio).
- R13 Sinks económicos (tienda rotativa, oro real, fragmentos canjeables).
- R14 Audio real (o etiquetado) en gremio.
- R15 Colecciones/trofeos (DC-02/03) + cosméticos equipados (DC-04).
- R16 QA-6/7 índices + versionar migraciones.
- R17 i18n completo de onboarding.

### 🟢 Baja (futuro)
- R18 Coach premium (`ai_mentor_chat_system`), SRS review (`grimoire_recalibration_srs`).
- R19 Multi-idioma objetivo completo (fr/de/it ya en catálogo).
- R20 Embeds/embeddings + caché de respuestas IA (IA-06).
- R21 Modo mentoría, skins/fondos activos, temporadas 2+.

---

## 33. Checklist para Beta Cerrada

- [x] Build debug OK · analyze 0 errores · tests 13/13.
- [x] QA-1/2/3 seguridad DB aplicados.
- [x] Gran Salón, misiones, economía, conversación funcionales.
- [x] Oracle conversacional + mapa + HUD.
- [ ] IA-01: claves fuera del repo.
- [ ] Migración visual (al menos onboarding + dashboard).
- [ ] Onboarding reducido a 3 pasos.
- [ ] Sentry/Crashlytics.
- [ ] Test en dispositivo real (release).

---

## 34. Checklist para Beta Pública

- [ ] IA-01 resuelto (bloqueador).
- [ ] 0 refs `orbitron`/`hankenGrotesk` (migración completa).
- [ ] QA-4 leaked-password + revisión RLS anon.
- [ ] CI/CD verde en cada push.
- [ ] Analytics de retención activos.
- [ ] Push notifications.
- [ ] Audio de gremio real o etiquetado como demo.
- [ ] Tests ≥10 archivos.
- [ ] Paywall post-sesión (no en onboarding).
- [ ] Términos/privacidad/consentimiento.

---

## 35. Checklist para Producción

- [ ] Release optimizado (split per ABI, tree-shaking, tamaño).
- [ ] Observabilidad completa (Sentry + analytics de funnel).
- [ ] Costos IA monitoreados por plan/usuario (dashboard).
- [ ] Backup/restore + retención de datos.
- [ ] Cumplimiento GDPR/CCPA.
- [ ] Escalado de índices + RLS initplan optimizado.
- [ ] Pruebas de carga del pipeline de voz.
- [ ] LiveOps operativo (temporada 1, eventos, battle pass por temporada).
- [ ] Soporte + panel admin (web_admin ya existe).

---

## 36. Conclusión Ejecutiva

**Dungeon of English tiene una base técnica sólida y una propuesta de valor única**: la única combinación de **conversación de voz libre con IA + identidad RPG de cazador + gremio social + economía gamificada** frente a Duolingo/Babbel/Memrise. La arquitectura feature-first y la infraestructura IA ya permiten escalar y evolucionar.

**Estado: LISTO PARA BETA CERRADA.**

**Para beta pública y producción, el camino crítico es:**
1. **Producto**: transformar la app de "educativa con skin RPG" a "RPG real" — narrativa, enemigo, agencia, y audio de gremio real (o claramente demo). Reducir onboarding a 3 pasos y mover el paywall a post-sesión.
2. **Visual**: completar la migración PlantillasHTML (eliminar 17 archivos con diseño antiguo).
3. **Seguridad**: IA-01 (claves) + revisión RLS.
4. **Retención**: analytics + push + temporadas + eventos semanales (el talón de Aquiles frente a Duolingo).

Con esos cuatro frentes resueltos, la app no solo está lista para producción, sino que tiene la base para convertirse en **la mejor experiencia RPG de aprendizaje de idiomas** del mercado.

---

### Incertidumbres explícitas
- No se verificó el estado visual completo de `paywall_screen`, `nucleo_arcano_limit_screen` y `level_exam_screen` (diseño) — marcados para re-auditoría visual.
- No hay datos reales de uso (sin analytics) → las simulaciones de retención/economía son **proyecciones**, no mediciones.
- No se probó el pipeline de voz en dispositivo físico con cuentas reales (solo build/analyze).
- La carpeta referida como "plantillas HTML" en el prompt corresponde a `PlantillaHtml/` en el repo (21 plantillas).

---

*Documento consolidado generado con evidencia verificada el 2026-07-30. Conserva las conclusiones válidas de `MASTER_AUDIT.md`, corrige las desactualizadas y añade las 13 secciones nuevas (producto, game loop, retención, psicología, engagement, narrativa, economía simulada, balance, live ops, accesibilidad, competitivo, visión, innovación).*
