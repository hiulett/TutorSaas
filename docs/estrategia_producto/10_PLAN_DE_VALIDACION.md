# 10 — Plan de validación con usuarios

> Nada de lo que sigue está probado. Son hipótesis que el código no puede
> resolver.

---

## 1. Hipótesis que requieren usuarios

| # | Hipótesis | Por qué no se puede resolver leyendo código |
|---|---|---|
| H1 | El usuario abandona en el onboarding, no en la primera conversación | Requiere ver dónde se cae |
| H2 | La voz es el motivo de instalación; el texto se usa a diario | Conducta real |
| H3 | El rango motiva más que el CEFR | Preferencia del jugador |
| H4 | El maná se percibe como límite justo o como castigo | Percepción |
| H5 | La consecuencia narrativa cambia el valor percibido | Experiencia |
| H6 | El público que paga tiene un objetivo externo (trabajo, viaje) | Segmentación |
| H7 | Las misiones de 1-3 min encajan mejor que las de 10 | Hábito |

---

## 2. Pruebas

### T1. Entrevistas de activación (H1, H6)
- **Perfil:** 8-12 personas que hayan instalado y abandonado (o usuarios nuevos).
- **Método:** 20 min, preguntas sobre el último uso, no sobre intenciones.
- **Se observa:** dónde recuerdan haberse bloqueado; qué esperaban encontrar.
- **Decisión:** si ≥50 % menciona el onboarding, R4 pasa a P0.
- **Riesgo:** racionalización posterior; cruzar con datos del embudo.

### T2. Prueba de usabilidad del onboarding (H1, H2)
- **Perfil:** 5-8 personas sin contexto del producto.
- **Método:** tarea «consigue que el personaje hable inglés» sin ayuda.
- **Se observa:** tiempo hasta la primera frase, puntos de duda.
- **Decisión:** si nadie llega en <2 min, el orden cambia.
- **Riesgo:** el observador ayuda sin querer; guion fijo.

### T3. Comparación de mecánicas (H5)
- **Perfil:** 10-16 usuarios actuales.
- **Método:** dos versiones de una escena (con y sin consecuencia), contrabalanceadas.
- **Se observa:** repetición voluntaria y recuerdo de la escena al día siguiente.
- **Decisión:** si no hay diferencia, R5 baja a P2.

### T4. Disposición a pagar (H4, H6)
- **Perfil:** 10-15 usuarios activos.
- **Método:** entrevista + tarjetas de precio (no encuesta hipotética aislada).
- **Se observa:** qué comparan, qué esperan por el precio.
- **Decisión:** si el valor percibido es «más maná y ya», el paywall debe
  mostrar profundidad, no volumen.

### T5. Retención de vocabulario (H: el SRS funciona)
- **Perfil:** 20 usuarios, 4 semanas.
- **Método:** repaso con tarjetas de producción a 1 y 7 días.
- **Se observa:** % recuperado.
- **Decisión:** si la retención no supera el azar, el modelo de tarjetas falla.

### T6. Seguimiento longitudinal de aprendizaje
- **Perfil:** 15-20 usuarios, 4 semanas.
- **Método:** misma misión/tipo al inicio y al final, con evaluador ciego.
- **Se observa:** diferencia de objetivos cumplidos.
- **Decisión:** base para cualquier afirmación pública de progreso.

---

## 3. Reglas de interpretación

1. **No confundir uso con aprendizaje.** Más sesiones no es mejor inglés.
2. **No confundir facilidad con calidad.** Si el contenido se vuelve más fácil,
   la precisión sube sin que haya mejora.
3. **No extrapolar de 5 personas.** Las pruebas de usabilidad encuentran
   problemas, no miden prevalencia.
4. **Registrar el guion.** Si cambia entre sesiones, los resultados no comparan.

---

## 4. Qué hacer con cada resultado

| Resultado | Acción |
|---|---|
| H1 confirmada | Adelantar R4 y medir activación antes de tocar nada más |
| H1 refutada (el abandono es en la primera conversación) | Priorizar latencia y calidad de la voz |
| H5 sin efecto | R5 a P3 y buscar consecuencia más fuerte (tangibles) |
| T5 sin retención | Revisar el diseño de tarjetas antes del SRS |
| T6 sin mejora | No afirmar aprendizaje en marketing; revisar el modelo pedagógico |
