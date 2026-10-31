# 05 — Propuestas de rediseño

**Alcance:** propuestas derivadas de evidencia de código. Ninguna se ha validado
visualmente (ver `01` §0); cada una declara **cómo se comprobaría**.

Los referentes se usan **solo como principios**, no como plantillas: este
producto es un RPG de inglés con identidad HUD propia y no debe parecer ninguna
de esas apps.

---

## 1. Principios aplicables (y lo que NO se copia)

| Referente | Principio aplicable | Cómo se traduce aquí | Lo que NO se copia |
|---|---|---|---|
| **Airbnb** | Una acción primaria por pantalla; el espacio en blanco es jerarquía | El dashboard tiene 9 bloques antes del CTA (`dashboard_screen.dart:492-542`); se ordena en 3 zonas con **un** CTA | Fotografía editorial, tarjetas blancas |
| **Uber** | Divulgación progresiva: decidir una cosa a la vez | Conversación: hoy compiten header, objetivos, orbes, maná y mic (`conversation_screen.dart:1338-1360`); se deja **una** acción dominante (mic) | Mapas, monocromo |
| **Revolut** | Datos densos con jerarquía numérica; color semántico solo para dinero/riesgo | Cifras en JetBrains Mono alineadas; dorado **solo** recompensa, rojo **solo** destructivo/error (hoy hay 72 `Colors.white*` y carmesí decorativo) | Fondo claro, gráficos de bolsa |
| **Spotify** | Navegación inferior persistente + "continuar donde lo dejaste" | El dock de 4 destinos ya existe (`dashboard_screen.dart:558-604`); el CTA "CONTINUAR AVENTURA" (`:536`) debe ser el ancla de reanudación | Feed horizontal infinito |
| **Notion** | Superficies tranquilas; la tipografía hace la jerarquía, no el cromo | `GlassCard` con esquinas rúnicas y glow en **100** sitios compite con el contenido; limitar cromo a superficies destacadas | Editor, papel blanco |
| **Duolingo** | Camino único, racha como objeto de primera clase, feedback inmediato, objetivos táctiles grandes | `LearningPathRoadmap` ya es un camino (`learning_path_roadmap.dart`); la racha vive en un banner y no en la cabecera; hay botones de 24 px | Mascota, verde corporativo, gamificación infantil |

Regla de marca: **nada de paletas ajenas**. La identidad (cian + oro + violeta
sobre `voidBg`, radios de 4, mono HUD) se conserva.

---

## 2. R1 — Dashboard: de "todo a la vez" a 3 zonas

### Problema (evidencia)

- La pestaña 1 apila: header de cazador, HUD, banner de racha, tarjeta SRS,
  badge PRO, 4 accesos rápidos (`:492-531`), CTA (`:536`), roadmap (`:539`) y
  100 px de relleno (`:546-548`).
- El CTA principal queda **después** de 4 bloques y 4 accesos, a más de un
  scroll en 360×800.
- El dock flota y se oculta deslizándose con el teclado (`:560`), pero no
  colapsa al hacer scroll.
- Estado offline promete "último progreso guardado" sin caché (`:194-213`).

### Propuesta

```
┌ Identidad (avatar · nombre · CEFR · racha) ───────────┐   ← 1 línea, 72 px
├ CTA única: CONTINUAR AVENTURA (48 dp, cian) ──────────┤   ← siempre visible
├ Camino (roadmap) ─────────────────────────────────────┤
│   └ nodo actual destacado, resto atenuado             │
├ Accesos (4 iconos 48 dp en grid 2×2) ─────────────────┤   ← debajo del camino
└ Dock fijo (4 destinos, 48 dp, semantics selected) ────┘
```

- Racha y XP suben a la cabecera (principio Duolingo), con `AnimatedCounter`
  (ya existe) y sin banner aparte.
- Los 4 accesos pasan a grid 2×2 con etiqueta visible (hoy solo icono + texto
  de 11 px): área táctil 48.
- El estado offline usa `HudState.error` honesto: "No pudimos cargar tu
  progreso" + reintentar, **sin** prometer caché inexistente.

### Archivos

`dashboard_screen.dart:196-609`, `progress_tab_view.dart`,
`hunter_hud_header.dart`, `learning_path_roadmap.dart`.

### Verificación

- Test: CTA visible sin scroll a 312×576 (nuevo).
- Test: dock con `Semantics(selected: true)` en el tab activo.
- Test: estado offline no menciona caché.
- **No verificable:** densidad percibida y equilibrio del camino.

**Esfuerzo:** M (3–4 d).

---

## 3. R2 — Conversación: una acción dominante y accesible

### Problema (evidencia)

- 2 281 líneas en un archivo; sin test de widget (ver `01` §4.2).
- La barra inferior mezcla maná, modo, ajustes TTS, avatar y estados
  (`conversation_screen.dart:1338-1360`).
- Iconos de 20 px con `Colors.white70` (`:1251-1255`), fuera de tokens.
- El waveform anima en infinito sin reduce-motion
  (`voice_waveform_visualizer.dart:30`).
- Mic de 72 px (correcto) pero con fondo `Colors.white` y `Color(0xFF0F172A)`
  hardcodeados (`conversation_mic_button.dart:129-150`).

### Propuesta

- **Jerarquía:** micrófono 72 en el centro; estado de escucha como texto
  (`labelSmall`) encima; maná como pill compacta a la izquierda; ajustes en un
  `HudIconButton` 48 a la derecha.
- **Un solo acento por estado:** reposo = cian; grabando = carmesí; cancelando =
  violeta con texto blanco (contraste 4.60).
- **Waveform** solo si `!reduceMotion`.
- **Semántica:** `Semantics(button: true, onTap: ...)` con acción real, no solo
  rol (`conversation_mic_button.dart:167-171`).
- **Error de red:** `HudState.error` con reintentar, en lugar de repetir el
  mensaje del proveedor.

### Archivos

`conversation_screen.dart`, `conversation_mic_button.dart`,
`voice_waveform_visualizer.dart`, `conversation_status_bar.dart`,
`oracle_mana_bar.dart`.

### Verificación

- Nuevo `conversation_screen_smoke_test.dart`: monta la pantalla con providers
  falsos y comprueba mic + estado + reintento.
- Test de hold-to-talk ya existe (`hold_to_talk_gesture_test.dart`): mantener.
- **No verificable:** legibilidad del glow del orbe, sensación de latencia.

**Esfuerzo:** L (5–7 d, incluye extraer 4 widgets).

---

## 4. R3 — Resumen de sesión: recompensa primero y objetivos táctiles

### Problema (evidencia)

- Botones de cerrar y siguiente de **24×24** px
  (`session_summary_screen.dart:524-530,544-550`).
- 1 238 líneas y cero tests de widget, pese a ser el momento de "pago" de la
  sesión (XP/oro/fragmentos, `:588-627`).
- El orden actual pone recompensa, luego "qué aprendiste", correcciones y
  siguiente lección, pero sin jerarquía tipográfica consistente
  (`_SectionTitle` 943, `_Label` 967, `_Tag` 1010, `_RewardChip` 1206: 4 estilos
  propios).

### Propuesta

```
┌ HudHeader (cerrar 48 dp) ─────────────────────────────┐
├ +XP · +ORO · +FRAGMENTOS  (una fila, chips unificados)┤
├ ¿Qué aprendiste? (lista con estado vacío explícito)   │
├ Errores corregidos (agrupados, sin duplicar _Tag)     │
└ Siguiente lección (CTA 48 dp) ────────────────────────┘
```

- Extraer `HudRewardRow` y `HudErrorList` a `core/widgets`.
- Cerrar y continuar pasan a 48×48 con `tooltip`.
- Mantener los estados reales de recompensa (loading/error/pendiente) que ya
  están bien (`:639-660`).

### Archivos

`session_summary_screen.dart` (dividir en 3 archivos), `system_window.dart`.

### Verificación

- Test: recompensa pendiente y error no muestran cifras.
- Test: botones ≥48 dp (`tester.getSize`).
- **No verificable:** impacto emocional del momento de recompensa.

**Esfuerzo:** M (2–3 d).

---

## 5. R4 — Ajustes: de pantalla-jaula a ruta con secciones

### Problema (evidencia)

- **No tiene ruta** (`router.dart` no la registra): solo se llega por el dock;
  no se puede enlazar desde una notificación ni desde soporte.
- 1 557 líneas, 7 `SafeArea`, 4 `SnackBar` crudos (`:281,530`), botón de borrar
  cuenta con contraste 2.99 (`:1536-1537`).
- Acciones destructivas (reiniciar historial, borrar cuenta) quedan tras un
  `Divider` pero con el mismo peso visual que el resto (`:1508-1545`).
- El bloque de herramientas de desarrollo **sí está** gateado por `kDebugMode`
  (`:203`), así que no es un riesgo de producción (esto corrige la auditoría
  anterior, ver `07` §4).

### Propuesta

- Registrar `/settings` y abrirla también desde el dock (misma pantalla, dos
  entradas).
- `HudHeader` + secciones colapsables: **Cuenta**, **Aprendizaje**, **Voz/TTS**,
  **Notificaciones**, **Datos**, **Zona de peligro** (fondo carmesí al 8 %,
  borde carmesí, texto `onSurface`).
- Botón destructivo: fondo `crimsonRed` + texto **`voidBg`** (5.23).
- Confirmación de doble paso ya existe para borrar cuenta: conservar y añadir
  explicación de consecuencias.

### Archivos

`settings_screen.dart`, `router.dart`, `dashboard_screen.dart`.

### Verificación

- Test de ruta `/settings` en `router_contract_test.dart`.
- Test de contraste de botón destructivo (token, no píxel).
- **No verificable:** agrupación percibida de 6 secciones.

**Esfuerzo:** M (3 d).

---

## 6. R5 — Misiones y gremio: un solo patrón de pestañas y de tarjeta

### Problema (evidencia)

- Tres patrones de navegación secundaria: dock del dashboard
  (`dashboard_screen.dart:569-600`), `TabBar` de misiones
  (`missions_screen.dart:33-54`) y pestañas propias de la tienda
  (`shop_screen.dart` con `_selectedTab`).
- Dos tarjetas de misión: `QuestCard` (core, 157 líneas,
  `quest_card.dart:48-162`) y `MissionCard` (feature, ~540 líneas,
  `mission_card.dart:44`), con radios y jerarquías distintas.
- `MissionCard` tiene 6 `SnackBar` crudos para el resultado de reclamar
  (`mission_card.dart`), en vez de `SystemSnack`.

### Propuesta

- `HudTabs` (una implementación) para Misiones y Tienda: indicador cian de 3 px,
  labels `titleSmall`, altura 48.
- `MissionCard` como única tarjeta de misión; `QuestCard` se depreca o pasa a ser
  un `MissionCard.compact`.
- Reclamar misión → `SystemSnack.reward` (dorado) o `.error`, no `SnackBar`.

### Archivos

`missions_screen.dart`, `shop_screen.dart`, `mission_card.dart`,
`mission_spotlight_widget.dart`, `quest_card.dart`.

### Verificación

- Test: una sola implementación de tarjeta (grep/lint de clase).
- Test: reclamar muestra `SystemSnack` (finder por tipo).
- **No verificable:** ritmo entre pestañas y scroll.

**Esfuerzo:** M (2–3 d).

---

## 7. Orden recomendado y criterio de éxito

| Orden | Propuesta | Por qué primero |
|---|---|---|
| 1 | R4 Ajustes (contraste + ruta) | Arregla un CRÍTICO de accesibilidad y una carencia de navegación con coste bajo |
| 2 | R3 Resumen | Botones de 24 px en el momento de mayor valor percibido |
| 3 | R2 Conversación | La pantalla más usada y la menos testeada |
| 4 | R1 Dashboard | Requiere el DS de estados (`HudState`) ya definido |
| 5 | R5 Misiones/Tienda | Consolida componentes, no bloquea nada |

**Criterio de éxito global (medible, no estético):**

1. 0 `EdgeInsets` literales fuera de `AppSpacing`.
2. 0 textos < 11 px.
3. 0 controles tocables < 48 dp.
4. 20/20 pantallas a 312 px y `textScaler` 2×.
5. 0 animaciones infinitas sin gate de reduce-motion.
6. 0 `SnackBar` crudos fuera de `SystemSnack`.

Nada de eso requiere ver una captura: se verifica con lints y tests, lo que
encaja con el límite de este entorno.
