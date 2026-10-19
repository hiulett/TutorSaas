# 13 — Resumen para el propietario

_Lenguaje llano. Qué hacer primero, qué conservar y qué evitar._

---

## La idea en una frase

**Tu app ya sabe hablar. Lo que no hace todavía es que hablar sirva para algo.**

Ese es el diagnóstico completo en una línea: tienes la pieza más difícil
construida (voz, IA, HUD, compras) y te falta cerrar el círculo para que el
jugador sienta que sus palabras cambian el mundo.

---

## 1. La visión recomendada

Un RPG de fantasía oscura donde **el inglés es la mecánica**, no el peaje. Tu
personaje avanza porque el mundo te entiende. La fantasía (Sistema, rangos,
mazmorras) explica por qué tienes que hablar, en lugar de disfrazar un
cuestionario.

---

## 2. Los cinco problemas más importantes

1. **Ninguna misión se puede completar.** Hay 533 misiones creadas y todas
   siguen «activas»: el código que las avanza nunca se llama.
2. **Las conversaciones no tienen consecuencias.** Hablas, te evalúan y volvés
   al menú. Nada cambia.
3. **No puedes demostrar que alguien aprende.** No se mide si recuerda una
   palabra a los siete días.
4. **La progresión mezcla cosas distintas.** Rango, nivel de inglés, XP y
   prestigio cuentan historias diferentes en la misma pantalla.
5. **El valor llega tarde.** Entre 4 y 8 minutos antes de la primera frase útil.

---

## 3. Las cinco oportunidades de mayor impacto

1. **Conectar el motor de misiones** (poco esfuerzo, todo el efecto).
2. **Consecuencia al cerrar la escena** (desbloqueos, NPC que recuerdan).
3. **Medir retención de vocabulario** con el repaso que ya existe.
4. **Conversación en el primer minuto** (reordenar el onboarding).
5. **Paywall que explique el valor**, no la plantilla genérica.

---

## 4. Qué conservar tal cual

- El pipeline de voz y las claves en el servidor.
- El HUD y la paleta: es tu identidad.
- El Oráculo como personaje y examen.
- El maná como coste real de IA.
- Las compras (Play + RevenueCat + reconciliación), que ya funcionan.
- Los 500 escenarios y el catálogo.

## 5. Qué modificar

- **Motor de misiones**: conectar, no reconstruir.
- **Onboarding**: invertir el orden.
- **Pantalla de Estado**: tres ejes separados.
- **Dashboard**: máximo 3 indicadores.
- **Paywall**: diseño propio.

## 6. Qué merece validación antes de construirse

- Jefes con fases.
- Gremio cooperativo (sin usuarios, las salas están vacías).
- Mapa persistente / exploración.
- Prueba gratuita de 7 días.

---

## 7. Prioridades de aprendizaje

1. Nivel calculado en servidor (hoy se puede escribir desde el cliente).
2. Tarjetas de producción, no solo de reconocimiento.
3. Retención a 7 días como métrica visible.
4. Evidencia por competencia, no un CEFR único.
5. Errores que generan refuerzo.

## 8. Prioridades de UX/UI

1. Misión activa como bloque principal.
2. Tres ejes en Estado.
3. Menos indicadores, más decisión.
4. Estados de carga/error/vacío en todas las pantallas con datos.
5. Accesibilidad: contraste y escalado de texto.

---

## 9. Decisiones de negocio que te tocan

| Decisión | Qué necesitas para tomarla |
|---|---|
| Segmento inicial | 8-12 entrevistas |
| Mantener o recortar el plan gratuito | 4 semanas de consumo real |
| Prueba gratuita sí/no | Conversión y coste de quien no convierte |
| Precio | Precio neto de Play + conversión real |
| Gremio (mantener/congelar) | Masa crítica |
| Marca (Dungeon of English / DungeonsSpeak) | Decisión tuya |

**No cambies precios todavía.** Hoy hay **un** suscriptor y es de prueba;
cualquier ajuste sería calibrar a ciegas.

---

## 10. Roadmap recomendado

| Fase | Semanas | Qué |
|---|---|---|
| **A** | 1-2 | Misiones que se completan + eventos |
| **B** | 1-2 | Nivel en servidor + SRS de producción + retención a 7 días |
| **C** | 2-3 | Conversación en el primer minuto + consecuencias + tres ejes |
| **D** | 2 | Paywall propio + coste por usuario |
| **E** | después | Plan de 4 semanas, refuerzo por errores, multi-competencia |

La fase A desbloquea casi todo lo demás.

---

## 11. Incertidumbres principales

- ¿El usuario se va por el onboarding o por la primera conversación?
- ¿Prefiere el rango o el nivel de inglés?
- ¿El maná se percibe como límite justo o como castigo?
- ¿Paga quien juega o quien tiene un objetivo externo?
- ¿Hay masa crítica para el gremio?

Ninguna se responde leyendo código. Están en `10_PLAN_DE_VALIDACION.md`.

---

## 12. Documentos generados

Todos en `docs/estrategia_producto/`:

```
00_VISION_Y_ESTRATEGIA.md
01_DIAGNOSTICO_ESTRATEGICO.md
02_GAME_DESIGN_PROPUESTO.md
03_SISTEMA_DE_APRENDIZAJE_PROPUESTO.md
04_UX_UI_PROPUESTO.md
05_IA_Y_OPTIMIZACION_DE_COSTES.md
06_MODELO_DE_NEGOCIO.md
07_ROADMAP_PRIORIZADO.md
08_MVP_ESTRATEGICO.md
09_METRICAS_Y_EXPERIMENTOS.md
10_PLAN_DE_VALIDACION.md
11_DECISIONES_PENDIENTES.md
12_PLAN_DE_IMPLEMENTACION.md
13_RESUMEN_PARA_EL_PROPIETARIO.md   ← este documento
```

No se modificó código ni documentación existente en esta fase.

---

## La frase que resume el riesgo

> Si no conectas las misiones, tendrás un producto precioso que nadie puede
> terminar. Si las conectas y no mides la retención, tendrás un juego que se
> juega pero del que no puedes afirmar que enseña.
