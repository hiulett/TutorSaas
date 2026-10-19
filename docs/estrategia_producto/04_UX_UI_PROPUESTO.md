# 04 — UX/UI propuesto

> **Base de observación.** Se han visto capturas reales del login, del dashboard
> (pestaña GREMIO) y del modal del Maestre en un Galaxy Note 20 (1080×2400).
> Las afirmaciones visuales se limitan a lo observado; el resto son propuestas.

---

## 1. Dirección visual

**Mantener:** HUD cian/dorado, monoespaciada para datos, esquinas de 4 px,
fondo `voidBg`, `GlassCard`, avatar del Oráculo.

**Corregir:**

| Problema observado | Evidencia | Cambio |
|---|---|---|
| El dock flotante subía con el teclado y tapaba contenido | Captura en dispositivo; corregido en #63 | Ya resuelto: se oculta al escribir |
| Botón principal con texto pegado al borde | Primer frame sin la fuente cargada | Fuentes empaquetadas + `FittedBox` (#53, #60) |
| Dos burbujas superpuestas en el chat del Maestre | Captura en dispositivo; corregido en #62 | Ya resuelto |
| Exceso de indicadores simultáneos (gemas, racha, prestigio, maná, oro) | Dashboard | Máx. 3 indicadores en la cabecera |

**Paleta y tipografía no cambian.** Cualquier rediseño debe verse como una
evolución del HUD, no como otra app.

---

## 2. Principios de interfaz

1. **Una decisión por pantalla.** La acción principal debe ser evidente sin leer.
2. **El estado, en una línea.** Nivel, rango y maná caben en una sola fila.
3. **Lo secundario, a una pulsación.** Inventario, títulos, ajustes: fuera de la
   vista principal.
4. **El texto nunca bajo 11 px efectivos** y contraste ≥ 4.5:1 en cuerpo.
5. **Nada de números que no cambien una decisión.**

---

## 3. Navegación

Actual: 4 pestañas (Mazmorras, Gremio, Estado, Config) con dock flotante.

Propuesta: **conservar** las 4 pestañas y el dock. Cambia el contenido, no el
esqueleto:

| Pestaña | Hoy | Propuesta |
|---|---|---|
| Mazmorras | HUD + accesos + camino de aprendizaje | **Misión activa** como bloque principal; el catálogo pasa a secundario |
| Gremio | Salas de voz y texto | Igual, con el Maestre como entrada a misiones sociales |
| Estado | Perfil, radar, progreso | Perfil + **3 ejes separados** (personaje / narrativa / lengua) |
| Config | Ajustes | Igual, sin los controles falsos (retirados en #39) |

Cambio de navegación real: **una sola**, la pestaña Mazmorras deja de ser un
catálogo y pasa a ser «qué toca ahora».

---

## 4. Pantallas prioritarias

### 4.1 Mazmorras (home)

| Punto | Propuesta |
|---|---|
| Propósito | Decir qué hacer ahora |
| Información principal | Misión activa con su gancho narrativo y su recompensa |
| Acción principal | **Continuar misión** |
| Secundarias | Ver mapa de arcos, repaso SRS, tienda |
| Jerarquía | Título de misión > objetivo > recompensa > resto |
| Componentes | `GlassCard` de misión, chip de maná, barra de progreso del arco |
| Estados | Vacío: «El Sistema aún no te ha asignado una misión» + CTA al Oráculo |
| Feedback | Al completar: consecuencia narrada + recompensa animada |
| Móvil | Una columna, scroll vertical, sin tablas |
| Resuelve | Que el usuario no sepa qué hacer al abrir |

### 4.2 Conversación

| Punto | Propuesta |
|---|---|
| Propósito | Hablar y entender |
| Información principal | NPC, última frase, estado de escucha |
| Acción principal | Botón de hablar (grande, pulgar) |
| Secundarias | Repetir frase, ver pista, salir |
| Jerarquía | NPC > subtítulo > botón |
| Componentes | Burbujas, waveform, indicador de maná restante |
| Estados | Escuchando / transcribiendo / pensando / hablando / error |
| Feedback | Al cerrar: objetivos cumplidos y qué palabra se aprendió |
| Móvil | Texto de la última frase legible a una mano |
| Resuelve | La falta de señal de estado durante el pipeline |

### 4.3 Estado / perfil

| Punto | Propuesta |
|---|---|
| Propósito | Ver qué ha cambiado |
| Información principal | Rango, nivel estimado, evidencia de aprendizaje |
| Acción principal | Ver detalle de competencia |
| Secundarias | Títulos, colección, historial |
| Jerarquía | Tres bloques separados (personaje / narrativa / lengua), no un solo muro |
| Componentes | Radar, barras de confianza, lista de palabras dominadas |
| Estados | Sin datos: explicar qué falta para tener evidencia |
| Feedback | Al subir de rango: animación breve, sin bloquear |
| Móvil | Radar legible a 360 px (hoy es la pantalla más densa) |
| Resuelve | Que el radar muestre valores sin significado |

### 4.4 Paywall

| Punto | Propuesta |
|---|---|
| Propósito | Explicar el valor del plan |
| Información principal | Qué desbloquea cada estamento |
| Acción principal | Suscribirse |
| Secundarias | Restaurar compras, gestionar suscripción |
| Jerarquía | Precio y maná > beneficios > letra pequeña |
| Componentes | Tarjetas comparativas con precio de Play |
| Estados | Cargando, error con reintento (ya implementado), sin conexión |
| Feedback | Éxito: plan aplicado al instante |
| Móvil | Comparativa en vertical, no tabla horizontal |
| Resuelve | Que hoy sea la plantilla genérica de RevenueCat |

### 4.5 Onboarding

| Punto | Propuesta |
|---|---|
| Propósito | Llevar al usuario a su primera frase útil |
| Información principal | Qué va a pasar |
| Acción principal | Empezar a hablar |
| Secundarias | Elegir idioma |
| Jerarquía | Una pregunta por pantalla |
| Componentes | Selector de idioma, botón grande, progreso 1/4 |
| Estados | Error de sesión (ya implementado en #55) |
| Feedback | Cada paso confirma lo elegido |
| Móvil | Sin scroll en ninguna pantalla |
| Resuelve | El valor llega tarde (4-8 min) |

**Cambio propuesto (funcional):** invertir el orden para que la primera
conversación ocurra en el primer minuto.

---

## 5. Estados de carga, error y vacío

Hoy: muchos `catch` silenciosos y pantallas en blanco. Ya se corrigieron los de
Compras, Onboarding y Maestre.

Regla propuesta: **toda pantalla con datos remotos tiene 4 estados** y ninguno
es «vacío sin explicación»:

```
cargando → skeleton con la forma del contenido
vacío    → qué falta y cómo conseguirlo
error    → qué pasó + botón de reintentar
datos    → contenido
```

---

## 6. Accesibilidad

Pendiente (issue #33). Prioridades concretas:

- Contraste ≥ 4.5:1 en texto de cuerpo (hoy hay grises por debajo).
- `textScale` hasta 1.3 sin recortes: probado en `overflow_test`, pero no en
  todas las pantallas.
- `Semantics` en los botones de acción (hablar, enviar, comprar).
- Sin información solo por color: los estados llevan icono o texto.

---

## 7. Qué cambiar y de qué tipo

| Cambio | Tipo |
|---|---|
| Misión activa como bloque principal | Funcional + navegación |
| Dock oculto al escribir | Visual (hecho) |
| Fuentes empaquetadas | Visual (hecho) |
| 3 ejes en Estado | Funcional |
| Paywall propio | Visual + comercial |
| Onboarding invertido | Funcional |
| Reducir indicadores a 3 | Visual |
| Estados de carga/error | Funcional |
