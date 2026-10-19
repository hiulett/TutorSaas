# 07 — Roadmap priorizado

Cada iniciativa usa la estructura obligatoria. Las prioridades no miden tamaño
sino **bloqueo**: P0 impide usar el producto correctamente.

**Resumen:** 3 bloqueantes, 5 de alto impacto, 4 de evolución y 3 a validar.

---

# P0 — Bloqueantes

## R1. Conectar el motor de misiones

**Problema identificado:** `updateProgress` no tiene llamadores en `lib/`. Las
533 instancias de misión están `active` y **ninguna se ha completado nunca**.
Existe el tablón, las recompensas y las plantillas, pero nada avanza.

**Por qué importa:** sin misiones completables no hay cierre de bucle, ni
recompensa significativa, ni motivo para volver. Es el agujero más grande entre
lo que el producto promete y lo que hace.

**Propuesta:** invocar `advance_missions_for_user(user, tipo, delta)` desde los
puntos donde ya se produce un evento de juego (fin de escena, turno de Oráculo,
repaso SRS), mediante una Edge Function o una RPC invocable por el usuario con
validación de identidad. Marcar `mission_instances.status = 'completed'` y
acreditar la recompensa existente.

**Alternativas:**
- (a) Completar misiones solo por cron: no refleja la acción del jugador.
- (b) Reconstruir el motor: innecesario, la lógica ya existe.
- (c) Eliminar las misiones: pierde el eje de progresión del personaje.

**Beneficios:** el bucle cierra; las recompensas y el tablón pasan a tener
sentido; se puede medir finalización de misiones.

**Costes y riesgos:** doble acreditación si se llama dos veces (mitigar con
idempotencia por `instance_id` + evento); requiere decidir qué eventos cuentan.

**Prioridad:** **P0** — desbloquea el resto del roadmap de juego.

**Validación:** completar una misión en dispositivo y ver el cambio de estado y
la recompensa.

**Criterios de aceptación:** una misión diaria pasa a `completed` al cumplir su
condición; la recompensa se acredita una sola vez; existe test de idempotencia.

---

## R2. El nivel CEFR no debe ser escribible por el cliente

**Problema identificado:** `user_language_profiles` mantiene `FOR ALL` del
dueño porque el onboarding calcula el nivel en el cliente (#3, parcial). Un
usuario puede ponerse C2.

**Por qué importa:** contamina la métrica de aprendizaje y permite desbloquear
contenido sin demostrar nada. Si el producto va a vender evidencia de progreso,
esa evidencia no puede ser autoasignada.

**Propuesta:** mover el cálculo de placement a una Edge Function que valide el
resultado del modelo contra una escala cerrada y escriba con service role.
Después, cerrar la escritura del cliente con un trigger que solo permita
cambiar columnas no sensibles.

**Alternativas:**
- (a) Dejarlo: barato ahora, caro cuando haya que demostrar progreso.
- (b) Quitar el nivel del onboarding: empeora la experiencia.

**Beneficios:** integridad de datos; base para evidencia defendible.

**Costes y riesgos:** latencia extra en el onboarding; migración de la lógica de
placement (hoy en Dart).

**Prioridad:** **P0** — integridad del dato educativo.

**Validación:** intentar modificar `cefr_level` desde el cliente y recibir error.

**Criterios de aceptación:** el cliente solo puede leer el nivel; el placement
se escribe por función; los usuarios existentes conservan su nivel.

---

## R3. Ninguna afirmación de aprendizaje sin evidencia

**Problema identificado:** la app muestra radar y niveles, pero no mide
retención, transferencia ni progreso comparable. El propio producto no puede
responder «¿estoy mejorando?».

**Por qué importa:** es la diferencia entre un juego con inglés y una
herramienta educativa. También es lo que sostiene el precio.

**Propuesta:** implementar las tres evidencias mínimas: (1) retención de
vocabulario a ≥7 días, (2) progreso en misión comparable, (3) transferencia a
una misión no vista del mismo nivel. Mostrar en Estado la evidencia disponible y
explicar la que falta.

**Alternativas:**
- (a) Mantener el radar estimado: no es evidencia.
- (b) Test formal periódico: rompe la fantasía.

**Beneficios:** se puede afirmar (o no) que el producto enseña; permite ajustar
contenido.

**Costes y riesgos:** requiere datos a lo largo de semanas; riesgo de mostrar
resultados poco halagüeños.

**Prioridad:** **P0** — sin esto el resto de la estrategia educativa es retórica.

**Validación:** con 20 usuarios durante 4 semanas, calcular las tres métricas.

**Criterios de aceptación:** las tres métricas se calculan automáticamente y se
muestran con su limitación.

---

# P1 — Alto impacto

## R4. El valor en el primer minuto

**Problema identificado:** onboarding de 4 pasos + evaluación oral antes de la
primera frase útil (4-8 min).

**Por qué importa:** la promesa (hablar y que te entiendan) se demuestra
hablando, no eligiendo idiomas.

**Propuesta:** abrir con una escena de 60 s (saludo + una pregunta), luego el
Oráculo, luego el personaje. Reutiliza todo el contenido existente.

**Alternativas:** mantener el orden actual y acortar pantallas (menos impacto).

**Beneficios:** activación más alta; comprensión inmediata del producto.

**Costes y riesgos:** hay que poder saltar a una escena sin perfil completo;
cuidado con usuarios que abandonen a mitad y queden sin perfil (13 de 73
usuarios auth no tienen perfil a 18-oct).

**Prioridad:** P1.

**Validación:** comparar activación (onboarding_completed) antes/después.

**Criterios de aceptación:** el usuario habla antes de elegir clase; la tasa de
onboarding completado no baja.

---

## R5. Consecuencia al cerrar la escena

**Problema identificado:** la conversación no cambia nada del mundo.

**Propuesta:** derivar del ratio de objetivos `éxito | parcial | fallo` y
aplicar: desbloqueo de escena siguiente, cambio de actitud del NPC, objeto. Sin
IA adicional.

**Beneficios:** convierte el ejercicio en decisión; reduce la sensación de
cuestionario.

**Costes y riesgos:** requiere estado narrativo (nuevo campo), contenido de
consecuencias por escena (500 escenarios).

**Prioridad:** P1.

**Validación:** prueba A/B con 2 escenas con y sin consecuencia; medir
repetición voluntaria.

**Criterios de aceptación:** al menos 3 escenas tienen consecuencia real y
persistente.

---

## R6. Tres ejes de progresión visibles

**Problema identificado:** XP, rango, CEFR, prestigio y maná cuentan historias
distintas en la misma pantalla.

**Propuesta:** separar en Estado: Personaje (rango/XP), Narrativa (arco),
Lengua (competencias + evidencia).

**Beneficios:** el jugador entiende qué mejora; el negocio sabe qué vende.

**Costes y riesgos:** reordenar el perfil; riesgo de dejar sin sitio el radar.

**Prioridad:** P1.

**Criterios de aceptación:** un usuario puede explicar en una frase qué subió y
por qué.

---

## R7. Retención de vocabulario real

**Problema identificado:** el SRS ya se conectó (#24), pero solo hay tarjetas de
reconocimiento y `mastered` se alcanza sin producción.

**Propuesta:** tarjetas de producción, intervalo mínimo de 24 h para contar, y
`mastered` solo con recuperación tras 1 y 7 días.

**Beneficios:** evidencia defendible; mejor retención.

**Costes y riesgos:** más fricción (producir cuesta más que reconocer).

**Prioridad:** P1.

**Criterios de aceptación:** el contador de palabras dominadas solo incluye las
recuperadas en producción tras 7 días.

---

## R8. Paywall con propuesta de valor

**Problema identificado:** plantilla genérica de RevenueCat (`paywall_id: null`),
sin comparativa ni prueba.

**Propuesta:** paywall propio en el dashboard de RevenueCat con los 4
estamentos, maná y minutos; incluir 7 días de prueba si el negocio lo aprueba.

**Beneficios:** conversión; menos reembolsos por expectativa clara.

**Costes y riesgos:** trabajo de diseño; la prueba puede aumentar el coste de
usuarios que no convierten.

**Prioridad:** P1.

**Criterios de aceptación:** el paywall muestra precio de Play y qué incluye
cada plan; conversión medible por plan.

---

# P2 — Evolución

## R9. Plan de 4 semanas
Bloques con competencia primaria/secundaria, 3 hitos narrativos y evaluación de
cierre. **Problema:** hoy es un menú de 500 escenarios. **Coste:** medio (usa
datos existentes). **Métrica:** % de usuarios que completan un bloque.

## R10. Reducir ruido en la interfaz
**Problema:** indicadores que no cambian decisiones. **Propuesta:** máximo 3 en
cabecera; el resto a Estado. **Coste:** bajo. **Métrica:** tiempo hasta pulsar
la acción principal.

## R11. Refuerzo generado desde errores
**Problema:** el generador de lecciones existe y no se usa. **Propuesta:**
generar una lección por patrón de error recurrente, cacheada por combinación.
**Coste:** medio. **Riesgo:** contenido incorrecto → revisión y caché.

## R12. Evaluación multi-competencia con confianza
**Problema:** un CEFR único desde una llamada. **Propuesta:** perfil de 5
competencias con nivel de confianza. **Coste:** bajo (datos ya recolectados).

---

# P3 — Exploración (validar antes de construir)

## R13. Jefes con fases
Mayor valor de juego; requiere diseño de contenido y evaluación más estricta.

## R14. Gremio cooperativo
LiveKit ya funciona; necesita masa crítica (sin usuarios, las salas están vacías).

## R15. Exploración / mapa persistente
Alto coste de contenido; no resuelve ningún problema actual.

---

## Dependencias

```
R1 ──► R5 ──► R9
R1 ──► R6
R7 ──► R3
R4 ──► R10
R2 ──► R12
```

R1 desbloquea casi todo lo de juego. R3 desbloquea cualquier afirmación
comercial sobre aprendizaje.
