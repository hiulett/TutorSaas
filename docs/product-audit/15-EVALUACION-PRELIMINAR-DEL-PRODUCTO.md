# 15 — Evaluación preliminar del producto

> **Este documento es interpretación, no descripción.** Los hechos están en los
> documentos 01–14 y 17; aquí se valoran.
> Base de evidencia: código, producción (60 cuentas, actividad de 4 días en 30) y
> 159 pruebas. **No hay usuarios reales ni datos de retención.**
> Escala de confianza: **A** alta (código/datos concluyentes) · **B** media
> (código + inferencia razonable) · **C** baja (hipótesis a validar).

---

## 1. Síntesis: qué es hoy el producto

Un **simulador de conversación con un tutor de IA** con una capa de rol que
puntúa la actividad. La conversación funciona de extremo a extremo; la capa de
juego **mide** pero apenas **recompensa**, y el bucle se cierra con cifras que no
coinciden con lo acreditado.

Fortalezas verificables:

1. **Pipeline de voz completo y con claves fuera del cliente** (doc 07).
2. **Contenido amplio**: 140 lecciones en código y 500 escenarios en BD.
3. **Economía aplicada en servidor** para sesiones y maná (RPC idempotentes).
4. **Identidad visual consistente** (tema, tipografías empaquetadas, 951 claves
   i18n en 3 idiomas).
5. **Disciplina de pruebas**: 159 en verde, con tests de overflow y de curvas.

---

## 2. Engagement

| # | Hecho (evidencia) | Problema | Usuario afectado | Consecuencia probable | Confianza | Dato que lo confirmaría |
|---|---|---|---|---|---|---|
| E1 | El onboarding exige 3 pantallas + examen oral antes de la primera lección (doc 09) | El valor llega tarde | Nuevo | Abandono en onboarding | B | Embudo por paso |
| E2 | El resumen muestra "+80 XP" fijo (doc 03 §3.6) | Se rompe la relación acción→recompensa | Todos | Menor sensación de progreso | A | Comparación recompensa mostrada vs acreditada |
| E3 | El drop se puede repetir al reabrir `/summary` | Recompensa no fiable | Todos | Desconfianza o farmeo | A | Eventos de reapertura |
| E4 | El coste por turno no se muestra antes de empezar; solo un chequeo de 12 | Corte inesperado | Free | Sesión truncada | B | Turnos por sesión, salidas por maná |
| E5 | El 98,7 % de misiones creadas no se completó (7/533) | La capa de misivas no engancha | Todos | Ruido sin función | A (dato) | Tasa por plantilla |
| E6 | No hay variedad de actividad: todo es conversación | Monotonía a medio plazo | Activos | Caída de uso | C | Curva de sesiones por usuario |
| E7 | Corrección implícita, sin tarjeta de error | El usuario no sabe qué falló | Todos | Aprendizaje más lento | B | Encuesta + análisis de repetición |
| E8 | 20 tópicos y frases útiles ayudan a arrancar | Mitiga el bloqueo inicial | Nuevos | — | B | Uso de tópicos |

---

## 3. Retención

| # | Hecho | Problema | Consecuencia probable | Confianza | Dato necesario |
|---|---|---|---|---|---|
| R1 | No hay push ni email (doc 11) | No hay retorno programado | Depende de la memoria | A | Notificaciones enviadas/abiertas |
| R2 | `current_streak` no se actualiza por el trigger | El ancla de hábito está rota | Sin sensación de racha | A | Serie diaria real |
| R3 | El banner "racha en riesgo" está siempre activo | Alarma falsa → se ignora | Pérdida de credibilidad | A | Impresiones/clics |
| R4 | No hay objetivo diario rastreado | No hay "misión del día" clara | Menos ritual | B | % que cumple meta |
| R5 | Las misiones semanales no se ven | Sin horizonte de 7 días | Menos planificación | A | — |
| R6 | Gremio vacío (0 mensajes) | La capa social no aporta | Se percibe como maqueta | A | Mensajes/semana |
| R7 | No hay contenido nuevo por nivel más allá de 20 escenarios | Repetición | Aburrimiento | B | Escenarios repetidos/usuario |

---

## 4. Calidad del aprendizaje

| # | Hecho | Problema | Confianza | Dato necesario |
|---|---|---|---|---|
| L1 | La evaluación de metas la decide el LLM sin rúbrica | Resultados inconsistentes | A | Acuerdo entre evaluaciones repetidas |
| L2 | Fluidez/pronunciación son estimaciones (latencia fija 1.8 s; similitud de texto) | Métricas que no miden lo que dicen | A | Comparación con evaluación humana |
| L3 | El vocabulario se extrae con regex y traducción hardcodeada de 21 palabras | Mazo con ruido | A | % de palabras válidas en el mazo |
| L4 | SRS correcto (SM-2 server-side) | Buena base, mal alimentado | A | Retención 7d con volumen |
| L5 | No hay práctica acumulativa ni revisión de errores | El conocimiento no se consolida | B | Tests de transferencia |
| L6 | El nivel no se adapta dentro del CEFR | Techo/barrera artificial | A | Tasa de éxito por lección |
| L7 | La IA aporta conversación real y contextual | Valor educativo genuino | B | Evaluación con hablantes |

**Sobre "¿aprende el usuario?":** el sistema puede demostrar retención de
vocabulario (`retention_7d`) y cumplimiento de metas; **no** puede demostrar
mejora gramatical, de comprensión ni de fluidez real.

---

## 5. Monetización y experiencia

| # | Hecho | Problema | Confianza | Dato necesario |
|---|---|---|---|---|
| M1 | Premium = más maná, sin features nuevas | Poca razón para pagar | A | Conversión por plan |
| M2 | 0 compras y 1 suscripción en producción | Sin validación comercial | A | Ingresos reales |
| M3 | `llm-proxy` no valida maná | Coste ilimitado si se manipula el cliente | A | Peticiones sin consumo |
| M4 | Sin medición de coste de IA | Margen desconocido | A | Tokens/usuario |
| M5 | Paywall delega todo en RevenueCat | Dependencia total de la config externa | B | Estado de offerings |
| M6 | Planes legacy con promesas falsas en BD | Riesgo de promesa incumplida | B | Si se reactivan |

---

## 6. Fricciones por severidad (para la fase 2)

**Bloqueantes de confianza (arreglar antes de crecer):**
1. Resumen con cifras fijas y drop repetible.
2. Racha que no se actualiza + banner falso.
3. Error de IA mostrado como mensaje del tutor.
4. Maná no validado en el servidor de IA.

**Bloqueantes de producto:**
5. No hay retorno programado (push/email).
6. La misión semanal y el gremio no se pueden usar.
7. La sub-misión de refuerzo nunca se genera.

**Deuda que limita la iteración:**
8. Currículo duplicado (Dart/BD) y dos umbrales de "completada".
9. Configuración de IA que no se usa (`system_ai_settings`).
10. Sin telemetría de coste ni de aprendizaje.

---

## 7. Oportunidades que merecen estudio (no recomendaciones cerradas)

| Oportunidad | Por qué | Qué habría que validar |
|---|---|---|
| Cerrar el bucle de recompensa con las cifras reales del servidor | Elimina la principal incoherencia | Que el usuario perciba la diferencia |
| Hacer visible el objetivo diario y la racha real | Convierte actividad en hábito | Si la racha rota era el freno |
| Notificación personalizada con el tema pendiente | Único canal de retorno | Permiso, copy, horario, métrica |
| Convertir el resumen en "qué aprendiste" (palabras nuevas, metas, 1 corrección) | Da valor pedagógico al cierre | Tiempo de lectura aceptable |
| Dar un uso a gemas/fragmentos o retirarlos | Simplifica la economía | Si el usuario los nota |
| Ofrecer una primera lección antes del onboarding | Reduce time-to-value | Impacto en clasificación |
| Medir el coste por sesión antes de tocar precios | Sin datos no hay margen | Instrumentación previa |

---

## 8. Lo que no se puede concluir

- Nada sobre retención D1/D7/D30, conversión ni LTV.
- Nada sobre aprendizaje medido con usuarios.
- Nada sobre la calidad percibida de la voz o del tutor.
- Nada sobre el efecto de la capa RPG en la motivación.

Cualquier afirmación de negocio en este punto sería inventada. La fase 2 debería
empezar por instrumentar (doc 17) y validar con una cohorte pequeña.
