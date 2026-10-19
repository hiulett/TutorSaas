# 01 — Diagnóstico estratégico

_Verificado contra código y base de datos el 18-oct-2026._

---

## 0. Evidencia utilizada

| Dato | Valor | Fuente |
|---|---|---|
| Tablas / políticas RLS / funciones | 75 / 120 / 52 | `information_schema`, `pg_policies`, `pg_proc` |
| Escenarios sembrados | 500 | `scenarios` |
| Plantillas de misión | 33 | `mission_templates` |
| Instancias de misión | 533 — **todas `active`, 0 completadas** | `mission_instances` |
| Misiones de gremio en pool | 199 | `guild_quest_pool` |
| Tests / errores de análisis | 155 / 0 | `flutter test`, `flutter analyze` |
| Issues del backlog | 48 implementados · 21 parciales · 2 pendientes · 1 descartado | GitHub |
| Coste de IA por acción | 8-100 de maná | `ai_action_costs` |
| Planes activos | plebeyo, noble, realeza, divino | `subscription_plans` |

Limitación: no hay analítica histórica. `retention_events` se instrumentó en
octubre; las conclusiones sobre comportamiento se marcan como hipótesis.

---

## 1. Fortalezas

### F1. El pipeline de voz funciona de punta a punta
`record` → Groq Whisper → DeepSeek SSE → `flutter_tts`, con las claves en el
servidor. Es la pieza más difícil de copiar y ya está construida.

### F2. La identidad visual no es un mockup
`CyberManhwaBackground` (13 modos), `GlassCard`, `SegmentedBar`,
`AnimatedCounter`, tipografías empaquetadas y una paleta consistente. El HUD
existe en la app, no solo en Figma.

### F3. Base de contenido amplia
500 escenarios con objetivos, frases y roles; catálogo Dart como fuente única.

### F4. Economía aplicada en servidor
`consume_mana`, `session_rewards`, `purchase_cosmetics` son `SECURITY
DEFINER`; el cliente no puede escribir su suscripción ni su maná (tras #3).

### F5. Compras completas
Play Billing + RevenueCat + webhook idempotente + reconciliación al iniciar
sesión. Es más de lo que tiene la mayoría de apps indie.

### F6. Disciplina de ingeniería
155 tests, 0 errores de análisis, tracker de errores, documentación consolidada.

---

## 2. Debilidades

### D1. El motor de misiones está inerte **(el hallazgo más grave)**
`updateProgress` no tiene **ni un llamador** en `lib/`. Las 533 instancias están
`active` y ninguna se ha completado nunca. Existe el tablón, existen las
recompensas… pero nada avanza.

*Impacto:* el bucle de juego no cierra. El jugador no puede «terminar» nada.

### D2. Las conversaciones no tienen consecuencias
Al terminar, se guardan mensajes y se evalúan objetivos. El mundo no cambia: el
NPC no recuerda, no se desbloquea nada, no hay estado persistente de la escena.

### D3. El aprendizaje no se demuestra
- El CEFR sale de una sola llamada al modelo.
- Las 6 dimensiones del radar se rellenan desde hace días (#25).
- No hay ninguna medida de **retención** (¿recuerda la palabra a los 7 días?).
- El repaso SM-2 existía sin interfaz hasta esta fase (#24).

### D4. La interfaz muestra más de lo que decide
Atributos STR/INT/DEX/LUK, gemas, fragmentos y prestigio aparecen o aparecían
sin cambiar ninguna decisión. Regla incumplida: si un número no cambia lo que
haces, no debe estar en la pantalla principal.

### D5. El valor llega tarde
Onboarding de 4 pasos + evaluación oral antes de la primera frase útil. Entre 4
y 8 minutos hasta que el producto demuestra para qué sirve.

### D6. Retención sin medir
Hasta hace días solo existía `paywall_viewed`. Ahora hay embudo de onboarding y
de compra, pero no de sesión de juego.

### D7. Monetización sin validar
Un solo usuario con plan de pago (cuenta de prueba). No hay evidencia de
disposición a pagar ni de conversión.

---

## 3. Los cinco problemas fundamentales

| # | Problema | Evidencia | Por qué es fundamental |
|---|---|---|---|
| **P1** | El bucle no cierra: no hay misión completable ni consecuencia | 533 instancias `active`, `updateProgress` sin llamadores | Sin cierre no hay recompensa significativa ni motivo para volver |
| **P2** | El aprendizaje no se demuestra | Evaluación única del modelo, sin retención ni evidencia | Sin evidencia no se puede cobrar como herramienta educativa ni mejorar el contenido |
| **P3** | Progresión mezclada | XP, rango, CEFR, prestigio y maná cuentan historias distintas | El jugador no sabe qué está mejorando; el negocio no sabe qué está vendiendo |
| **P4** | La fantasía no toca la mecánica | Atributos y clases sin efecto verificable | Se percibe como cuestionario con skin |
| **P5** | El coste de IA se controla, pero el negocio no está probado | Maná por acción real; 1 suscriptor de prueba | El producto puede ser insostenible si crece sin modelo validado |

---

## 4. Oportunidades

| # | Oportunidad | Esfuerzo | Por qué ahora |
|---|---|---|---|
| O1 | **Conectar el motor de misiones** (llamar a `advance_missions_for_user`) | Bajo | Ya existe todo: tablas, RPC y UI |
| O2 | **Convertir el cierre de escena en consecuencia** (desbloqueo + cambio de NPC) | Medio | Reutiliza `scenario_goals` y `lesson_progress` |
| O3 | **Medir retención de vocabulario** con el SM-2 ya conectado | Bajo | La tarjeta de repaso existe desde #24 |
| O4 | **Reordenar el onboarding**: conversación primero | Bajo | No requiere contenido nuevo |
| O5 | **Usar el generador de lecciones** ya desplegado para misiones de refuerzo | Medio | `lesson-generator` está en producción y sin uso |
| O6 | **Salas de voz** (LiveKit ya funciona) como retención social | Alto | Diferenciador fuerte, pero requiere masa crítica |

---

## 5. Qué conservar tal cual

- Pipeline de voz y sus claves en servidor.
- HUD y paleta.
- El Oráculo como personaje y examen.
- Maná como coste real.
- RLS y RPC de economía.
- Catálogo Dart de lecciones.

## 6. Qué corregir sin reconstruir

- Motor de misiones (una llamada, no un módulo nuevo).
- Orden del onboarding.
- Exceso de indicadores en el dashboard.
- Paywall (plantilla genérica → diseño propio en RevenueCat).

## 7. Qué no se debe añadir todavía

- Más monedas (gemas, fragmentos, cristales…).
- Combate por turnos completo.
- Mundo abierto / mapa persistente.
- PvP.
- Generación de contenido narrativo en tiempo real.

Cada una de esas multiplica el coste de IA y la superficie de diseño sin haber
cerrado el bucle básico.

---

## 8. Hipótesis abiertas (no conclusiones)

1. El usuario abandona en el onboarding, no en la primera sesión de voz.
2. El rango motiva más que el CEFR.
3. El maná percibido como límite molesta más de lo que protege el coste.
4. La voz es el motivo de instalación, pero el texto es el que se usa a diario.
5. El público dispuesto a pagar no es el que más juega, sino el que tiene un
   objetivo externo (entrevista, viaje, trabajo).

Ninguna está validada. Ver `10_PLAN_DE_VALIDACION.md`.
