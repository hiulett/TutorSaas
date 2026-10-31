# Decisiones canónicas (vigentes)

> Aprobadas por **Isaac** (dueño del producto). Fecha de registro: **2026-10-31**.
> Estas decisiones **no se cuestionan**: se audita el código contra ellas y se
> documenta la brecha. Cualquier propuesta que las contradiga se descarta.

| ID | Decisión |
|---|---|
| **D-01** | El **gremio de aventureros** es la institución central. Nobleza (de pago) y plebeyo (gratis) son la jerarquía declarada. **Un solo nombre para el jugador** y **una sola escala de rango**. |
| **G-01** | Las misiones salen **solo del gremio**, en **3 capas**: del día, contratos y evento semanal. |
| **D-02** | **Aprendizaje primero**, el juego es el motor. Métricas primarias: **frases habladas por semana** y **retención léxica a 7 días**. |
| **D-03** | **Una sola racha**; el freeze se consume **solo al faltar un día**. |
| **D-04** | Se **retira el battle pass**; los **títulos de prestigio** son el único eje. |
| **D-05** | El **pergamino pasa a ser reintento de lección** (el maná sigue cobrándose); se **retiran los ítems de maná**. |
| **D-06** | **No se regala maná**. Sin maná, la alternativa gratuita son actividades **sin coste de IA**: repaso SRS, listening, Mis errores. |
| **D-07** | El rango **F–SSS se sube con examen de jefe** y **desbloquea contenido**. |
| **D-08** | **Gremio asíncrono**: tablón de contratos y el Maestre como NPC, **sin chat libre** en fase 1; mesas de voz como evento **solo con ≥20 activos/semana**. |
| **D-09** | **La BD manda sobre el currículo**; copia local de solo lectura con descarga incremental. **Contenido y parámetros en BD, lógica en código.** |
| **D-10** | **Listening se mantiene** como alternativa sin coste; contenido por fases. |
| **D-11** | Se mantienen **precios y trial**; se instrumenta para medir. |
| **D-12** | **Solo inglés.** |
| **D-13** | **Validación visual humana en dispositivo, por release.** |
| **D-14** | **Solo Android.** |
| **D-15** | **Umbral de continuar / iterar / pivotar** definido con las métricas de D-02 (se concreta en `19`). |

## Regla de ubicación (Parte B)

| Va a **BD** (administrable desde el panel web) | Se queda en **código** |
|---|---|
| Contenido (lecciones, escenarios, ejercicios, guiones, textos narrativos) | Lógica y algoritmos |
| Parámetros de balance (costes, recompensas, umbrales, fórmulas) | Tokens de diseño |
| **Prompts** (los lee la Edge Function desde BD; **nunca** se envían al cliente) | Textos de interfaz (`.arb`) |
| | Validaciones de seguridad |
