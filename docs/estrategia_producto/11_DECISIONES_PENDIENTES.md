# 11 — Decisiones pendientes del propietario

Estas decisiones no se pueden tomar desde el código ni desde la documentación.
Están ordenadas por cuánto bloquean.

---

## D1. Segmento inicial

**Opciones**
- (a) Adultos con objetivo externo (trabajo, viaje, entrevista), A2-B2.
- (b) Adolescentes atraídos por el RPG, A1-B1.
- (c) Principiantes absolutos.

**Implicaciones**
- (a) paga más, exige evidencia de progreso y menos «juego».
- (b) engancha más, tiene menos poder de compra y más riesgo de contenido
  inapropiado.
- (c) necesita otra pedagogía (más andamiaje) y otro ritmo.

**Recomendación provisional:** (a) como núcleo de pago y (b) como motor de
crecimiento orgánico. **Requiere validación (T1).**

---

## D2. Plan gratuito

**Decisión:** mantener 3.000 maná / 30 min o recortar.

**Datos que faltan:** consumo real de los usuarios gratuitos durante 4 semanas.

**Riesgo:** recortar antes de medir rompe la activación; no recortar puede hacer
insostenible el coste.

---

## D3. Prueba gratuita

**Opciones:** 7 días de premium, 3 días, o ninguna.

**Implicaciones:** más conversión y más coste de IA de quien no convierte.

---

## D4. Precio

**Decisión:** mantener $4.99 / $9.99 / $12.99 o revisar.

**Datos que faltan:** conversión real, precio neto de Play, comparables.

**No recomendaría tocarlo antes de 4 semanas de datos.**

---

## D5. Gremio y salas de voz

**Opciones:** mantener, congelar o retirar.

**Situación:** LiveKit funciona, pero sin usuarios las salas están vacías y
generan coste de infraestructura.

**Recomendación:** congelar (dejar el código, ocultar la entrada) hasta tener
base de usuarios; reabrir como evento.

---

## D6. Contenido generado por IA

**Decisión:** ¿quién revisa las lecciones generadas?

**Opciones:** revisión humana, revisión por segundo modelo, o solo caché + tests.

**Riesgo:** contenido incorrecto publicado como lección.

---

## D7. Atributos y clases

**Decisión:** darles efecto mecánico o retirarlos de la UI.

Mantener atributos sin efecto contradice el principio «si no cambia una decisión,
no se muestra».

---

## D8. Idioma de la interfaz

Hoy: es/en/pt. El aprendizaje es solo inglés.

**Decisión:** ¿se abre el aprendizaje a otros idiomas? Implica contenido nuevo,
no solo traducción.

---

## D9. Marca

«Dungeon of English» / «DungeonsSpeak» aparecen mezclados en el proyecto.

**Decisión:** unificar antes de invertir en marketing.

---

## D10. Qué hacer con las tablas sin uso

`secret_missions`, `global_events`, `guild_battle_pass` y otras están vacías.

**Opciones:** implementar, congelar o eliminar del esquema.

**Recomendación:** congelar documentadas; eliminar solo cuando haya baseline de
migraciones (#10).
