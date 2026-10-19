# 05 — IA y optimización de costes

---

## 1. Inventario de operaciones

| Operación | Motor | Frecuencia | Coste (maná) | Latencia tolerable | ¿Determinista posible? |
|---|---|---|---|---|---|
| Turno de conversación (tutor/NPC) | DeepSeek `deepseek-v4-flash`, SSE | Cada turno | 8-15 según contexto | < 1.5 s al primer token | No |
| Evaluación de objetivos de escena | DeepSeek, JSON, `temperature 0.3` | 1 por escena | Incluida | 2-5 s al cerrar | **Parcial** (keywords primero) |
| Evaluación de placement (Oráculo) | DeepSeek, JSON | 1 por examen | 30 | 5-10 s | No |
| Transcripción de voz | Groq `whisper-large-v3-turbo` | Cada turno de voz | Incluida | < 1 s | No |
| Generación de lección | `lesson-generator` | Bajo demanda | 100 | 10-20 s | No |
| Cálculo de recompensas | RPC `session_rewards` | 1 por sesión | 0 | Inmediata | **Sí** (ya lo es) |
| Progreso de misión | RPC `advance_missions_for_user` | Por evento | 0 | Inmediata | **Sí** (hoy sin usar) |

---

## 2. Qué debe seguir siendo IA

Solo tres cosas **necesitan** un modelo en tiempo real:

1. **Mantener la conversación** (es el producto).
2. **Transcribir voz** (no hay alternativa práctica on-device con esta calidad).
3. **Evaluar respuestas abiertas** que no caben en reglas.

Todo lo demás debe ser regla, caché o contenido pre-generado.

---

## 3. Reglas antes que modelo

### Evaluación de objetivos

Hoy: una llamada al LLM con la conversación completa y una instrucción estricta.

Propuesta en cascada:

```
1. ¿Todos los objetivos tienen keywords presentes en el texto del alumno?
   → no: los que fallan se marcan false sin llamar al modelo
2. Si quedan objetivos dudosos → llamada al modelo SOLO con esos objetivos
   y los turnos relevantes (no la conversación entera)
3. Si la llamada falla → se aplica el resultado de keywords (nunca se inventa)
```

Ventajas: menos tokens, resultados explicables, y el sistema sigue funcionando
si el proveedor cae.

### Consecuencias narrativas

Se derivan del ratio `objetivos cumplidos / totales`. **Cero IA.**

---

## 4. Caché y pre-generación

| Qué | Estrategia | Ahorro esperado |
|---|---|---|
| Frases de apertura de escena | Ya son estáticas (`initial_assistant_message`) | 1 llamada por escena |
| Contexto del sistema (personaje + nivel + reglas) | Prompt estable por sesión; reutilizable con *prompt caching* del proveedor | 30-50 % de tokens de entrada |
| Lecciones de refuerzo | Se generan una vez por combinación (nivel × competencia × tema) y se guardan | De N llamadas a 1 por variante |
| Correcciones | Se derivan de la evaluación ya hecha; no requieren llamada extra | 1 llamada por sesión |
| Respuestas del Maestre de Mesa | No se cachean (contexto conversacional), pero se limitan a `max_tokens 200` | Control de cola |

---

## 5. Límites y cuotas

Ya existen en el esquema:

- `ai_usage_logs`, `llm_quota_events`.
- `check_ai_audio_quota`, `track_ai_audio_time`.
- `ai_action_costs` con el coste por acción.

Propuesta:

1. **Maná por acción** (ya funciona): el usuario ve el coste antes de gastar.
2. **Tope diario de audio** por plan (`monthly_audio_minutes_limit` ya existe:
   30 / 300 / 1200 / 2000 min).
3. **Degradación**: agotado el maná, la app sigue permitiendo repaso SRS,
   lectura de contenido y misiones de elección (sin IA).
4. **Reintentos acotados**: 2 en cliente, 3 en el proxy (ya implementado). Si
   falla, no se cobra.

---

## 6. Modelo de coste (con variables, sin cifras inventadas)

```
Coste mensual por usuario activo
  = turnos_mes × coste_turno
  + evaluaciones_mes × coste_eval
  + minutos_audio_mes × coste_minuto_stt

Ingreso mensual por usuario
  = ARPU_suscripción × prob_suscripción
```

Incógnitas que hay que medir (no se asumen):

| Variable | Cómo obtenerla |
|---|---|
| `coste_turno` | Precio del proveedor × tokens medios por turno (medible en `ai_usage_logs`) |
| `turnos_mes` | Media por usuario activo (instrumentar) |
| `coste_minuto_stt` | Precio del proveedor × minutos (ya se registran) |
| `prob_suscripción` | Conversión real del embudo (instrumentado en #72) |
| `ARPU` | Precio neto de Play (descontando la comisión de la tienda) |

**Sin estas cinco cifras no se puede afirmar si el producto es rentable.** Lo
que sí se puede afirmar: el maná ya limita el gasto por diseño, y el plan
gratuito (3.000 maná ≈ 375 turnos de conversación libre) acota el coste de un
usuario que no paga.

### Comprobación aritmética del límite

```
3.000 maná / 8 por turno libre = 375 turnos
375 turnos × ~15 s de audio   ≈ 94 min de STT al mes como máximo
```

Ese es el techo de coste de un usuario gratuito, medido en unidades de producto,
no en dinero.

---

## 7. Fiabilidad

| Riesgo | Mitigación |
|---|---|
| El modelo devuelve JSON inválido | Reintento único; si falla, evaluación por keywords |
| Respuesta en el idioma equivocado | Regla en el prompt + validación de idioma en la respuesta |
| Deriva del personaje | Briefing corto y fijo por sesión; no historial completo |
| Proveedor caído | El proxy reintenta con backoff; la app informa y no cobra |
| Coste desbocado | Maná + tope de audio + `max_tokens` por operación |

---

## 8. Gratis vs premium (sostenibilidad)

| Capacidad | Gratis | Premium |
|---|---|---|
| Conversación con IA | 3.000 maná/mes | 17.000-25.500 |
| Audio STT | 30 min/mes | 300-2.000 min |
| Repaso SRS | Ilimitado | Ilimitado |
| Misiones de elección | Ilimitadas | Ilimitadas |
| Generación de lecciones | 1 de prueba | Incluida |

La regla: **lo que cuesta dinero se limita; lo que no cuesta, no.** El repaso y
las misiones deterministas son gratis siempre porque su coste marginal es cero.

---

## 9. Lo que no se debe hacer

- Bajar `max_tokens` hasta que las respuestas queden telegráficas.
- Sustituir la conversación por plantillas para ahorrar: es el producto.
- Evaluar con un modelo más barato sin medir la calidad de la evaluación.
- Cachear respuestas de conversación (se notaría y rompe la ilusión).
