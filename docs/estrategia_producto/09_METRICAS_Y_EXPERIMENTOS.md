# 09 — Métricas y experimentos

> Ninguna cifra de referencia de este documento es inventada. Donde no hay dato,
> se indica la variable que falta.

---

## 1. Producto

| Métrica | Fórmula | Fuente | Limitación |
|---|---|---|---|
| Activación | `onboarding_completed / onboarding_started` | `retention_events` | Recién instrumentado (oct-2026) |
| Abandono por paso | 1 − (`usuarios_paso_n+1 / usuarios_paso_n`) | `onboarding_step` | Mismo |
| Tiempo hasta primera frase | `primer mensaje de usuario − onboarding_started` | `messages` + eventos | No medido aún |
| Errores de flujo | `onboarding_failed / onboarding_started` | eventos | — |

## 2. Juego

| Métrica | Fórmula | Fuente | Limitación |
|---|---|---|---|
| Misiones completadas | `mission_instances status=completed` | BD | **Hoy siempre 0** (motor inerte) |
| Diversidad diaria | tipos distintos de actividad por día | `mission_instances` | Requiere R1 |
| Repetición voluntaria | misiones iniciadas sin misión pendiente | eventos | No instrumentado |
| Progresión | rango/XP por cohorte semanal | `user_language_profiles` | — |
| Uso de recompensas | `mana_transactions type=reward` por usuario | BD | — |

## 3. Aprendizaje

| Métrica | Fórmula | Fuente | Limitación |
|---|---|---|---|
| Retención a 7 días | repasos correctos con intervalo ≥7 d / repasos elegibles | `user_vocabulary` | Necesita series temporales |
| Precisión por competencia | objetivos cumplidos / objetivos intentados por tipo | `scenario_goals` + evaluación | La evaluación depende del modelo |
| Progreso comparable | misma misión/tipo, dificultad igual, semana 1 vs 4 | misiones | Requiere R1 |
| Transferencia | objetivos cumplidos en misión no vista del mismo nivel | misiones | Requiere R1 |
| Fluidez | palabras/min y reparaciones por turno | `messages` | Estimación textual, no acústica |

**Trampa a evitar:** la tasa de respuestas correctas puede subir porque el
contenido se vuelve más fácil (o porque el usuario repite la misma misión). Por
eso toda métrica de precisión se acompaña de **dificultad y repetición**.

## 4. Negocio

| Métrica | Fórmula | Fuente | Limitación |
|---|---|---|---|
| Conversión | suscripciones / usuarios que ven el paywall | `retention_events` + `user_subscriptions` | Embudo recién creado |
| Retención por cohorte | usuarios activos semana N / semana 0 | eventos | Sin histórico |
| Cancelaciones | `EXPIRATION` + `CANCELLATION` | `revenuecat_events` | — |
| Coste de IA por usuario | turnos × coste_turno + min × coste_min | `ai_usage_logs` + precios | Faltan precios de proveedor |
| Coste por sesión | coste_ia / sesiones | igual | — |
| Margen | precio neto Play − coste IA | ambos | Falta comisión exacta |

---

## 5. Experimentos propuestos

| # | Hipótesis | Diseño | Métrica | Criterio de decisión |
|---|---|---|---|---|
| E1 | Hablar antes de elegir idioma aumenta la activación | A/B onboarding (orden actual vs invertido) | `onboarding_completed` | +5 puntos porcentuales |
| E2 | La consecuencia aumenta la repetición | 2 escenas con/sin consecuencia | repetición voluntaria | +20 % |
| E3 | El rango motiva más que el CEFR | mostrar uno u otro en el HUD | sesiones/semana | diferencia clara |
| E4 | El repaso de producción mejora la retención | tarjetas A (reconocer) vs B (producir) | retención a 7 d | B > A |
| E5 | 7 días de prueba aumentan conversión | prueba vs sin prueba | conversión neta y coste | conversión neta mejora |
| E6 | El plan de 4 semanas reduce abandono | con plan vs catálogo libre | retención semana 4 | +10 % |

Tamaño: con la base actual (≈70 usuarios) **no hay potencia estadística**. Los
experimentos deben hacerse con cohortes pequeñas y métricas de proceso, o
esperar a tener más usuarios.

---

## 6. Qué no medir como éxito

- Tiempo en pantalla.
- Nº de misiones completadas sin mirar dificultad.
- Rachas: premian presencia, no aprendizaje.
- Palabras «vistas».
- Respuestas correctas sin control de repetición.

---

## 7. Instrumentación que falta

1. Evento de inicio y fin de sesión de conversación.
2. Evento de misión iniciada/completada/abandonada.
3. Resultado de la evaluación (éxito/parcial/fallo) por escena.
4. Repaso SRS (tarjeta, resultado, intervalo).
5. Paywall: ya instrumentado en #72.

Todos caben en `retention_events` sin cambiar el esquema.
