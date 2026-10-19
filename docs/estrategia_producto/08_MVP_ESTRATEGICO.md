# 08 — MVP estratégico

> El MVP **no** es una reconstrucción. La app ya tiene pipeline de voz, contenido,
> economía y compras. El MVP es el conjunto mínimo que hace que todo eso se
> sienta como un juego completo.

---

## 1. Las nueve condiciones del MVP

| # | Condición | ¿Se cumple hoy? |
|---|---|---|
| 1 | Entiende el concepto en 60 s | ❌ (onboarding largo) |
| 2 | Empieza a jugar | ⚠️ (elige lección de un catálogo) |
| 3 | Actividades adecuadas a su nivel | ✅ (catálogo por CEFR) |
| 4 | Usa el inglés de forma significativa | ✅ (voz) |
| 5 | Recibe retroalimentación útil | ⚠️ (solo al cerrar) |
| 6 | Experimenta progresión | ⚠️ (XP sí, misiones no) |
| 7 | Recompensas coherentes | ⚠️ (maná/XP existen, sin cierre) |
| 8 | Percibe un objetivo futuro | ❌ (no hay gancho) |
| 9 | Regresa por algo más que recompensas | ❌ |

---

## 2. Funcionalidades indispensables (MVP)

1. **Primera conversación en el primer minuto** (R4).
2. **Misión que se completa** (R1) con recompensa y gancho siguiente.
3. **Consecuencia de la escena** en al menos 3 escenarios (R5).
4. **Repaso SRS** con tarjetas de producción (R7) — ya existe la base.
5. **Estado con tres ejes** (R6).
6. **Evidencia mínima**: palabras retenidas a 7 días (R3, versión mínima).

---

## 3. Reutilizar tal cual

- Pipeline de voz y `llm-proxy`.
- Catálogo Dart + 500 escenarios.
- HUD, `GlassCard`, tipografías.
- Economía y `session_rewards`.
- Compras Play + RevenueCat + reconciliación.
- RLS y RPC de servidor.
- Onboarding (contenido), aunque cambie el orden.

---

## 4. Corregir antes de lanzar

| Elemento | Estado | Acción |
|---|---|---|
| Motor de misiones | Inerte | R1 |
| CEFR escribible | Abierto | R2 |
| Paywall genérico | Plantilla | R8 |
| Indicadores excesivos | Desorden | R10 |
| Retención sin medir | Sin datos | R3 |

---

## 5. Posponer sin culpa

- Combate por turnos.
- Mapa persistente.
- PvP.
- Nuevas monedas.
- Generación narrativa en tiempo real.
- Traducción a más idiomas (hoy es/en/pt de UI; el aprendizaje es solo inglés).

Motivo: ninguna resuelve un problema actual, y todas aumentan coste de IA o
superficie de diseño.

---

## 6. Requiere validación antes de construir

- Jefes con fases (R13): ¿aportan o son una escena larga?
- Gremio cooperativo (R14): sin masa crítica no hay señal.
- Prueba gratuita de 7 días (R8): impacto en coste.

---

## 7. Por qué este MVP y no otro

| Alternativa | Problema |
|---|---|
| Reconstruir el juego desde cero | Tira 500 escenarios, pipeline de voz y economía ya probados |
| Añadir contenido masivo | No arregla que nada se complete |
| Añadir multiplayer | Necesita usuarios que aún no existen |
| Solo pulir la UI | No cambia que el bucle no cierre |

El MVP elegido **convierte lo que ya existe en un juego**: cierra el bucle,
da consecuencia y muestra evidencia. Es la ruta de menor coste y menor riesgo
hacia la promesa del producto.
