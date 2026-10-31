# 23 — Checklist de validación visual humana en dispositivo (D-13)

> **Decisión que implementa:** D-13 — *«validación visual humana en dispositivo,
> por release»*. Ninguna entrada visual (marcada 🔍 en
> `docs/ui-ux-audit/06-improvement-backlog.md`) puede cerrarse sin este
> checklist cumplimentado y sus capturas.
>
> **Por qué existe:** `docs/product-discovery/13-ux-ui-audit.md` sólo puede
> afirmar lo que se mide en código (conteos, ratios, tamaños declarados). Lo
> percibido —jerarquía, ritmo, legibilidad, glow, animación— y lo que depende del
> lector de pantalla o del escalado del sistema **no es verificable desde el
> repo**: `docs/ui-ux-audit/screenshots/` no tiene ni una captura válida.
>
> **Salida esperada:** una ficha firmada por release, ≥ 22 capturas y cero
> `[PENDIENTE DE VALIDAR]` en los ítems V-01…V-32.

---

## 1. Cuándo se ejecuta

| Momento | Alcance |
|---|---|
| **Antes de cada `flutter build appbundle --release`** | **Completo** (V-01…V-32) |
| Tras tocar tema, tipografía, iconos, `GlassCard` o cabeceras | V-02, V-05, V-07, V-08, V-18 + §7 (TalkBack) |
| Tras tocar estados (loading/error/vacío) | V-12, V-21…V-24 |
| Tras tocar animaciones o `AppMotion` | V-25 |
| Tras editar `.arb` | V-02, V-03, V-18 + §8 (escalado) |

**Duración:** 45–60 min el completo; 15 min el mínimo.

---

## 2. Preparación (10 min)

### 2.1 Build y dispositivo

| # | Paso | Comprobación |
|---|---|---|
| P-01 | Instalar el **AAB/APK release** (no debug) | `flutter build apk --release` → `adb install -r build/app/outputs/flutter-apk/app-release.apk` |
| P-02 | Anotar `version` + `build number` de `pubspec.yaml` y el **hash** del commit | se pegan en §9 |
| P-03 | Pantalla a **brillo automático desactivado, 100 %** | si no, el contraste medido no vale |
| P-04 | **Modo oscuro** del sistema | la app es sólo oscura: no hay nada que comparar |
| P-05 | Desactivar «modo desarrollador» de la app si está activo en Ajustes | cambia el onboarding |
| P-06 | Tener una cuenta con: sesión hecha, maná > 0 **y** una cuenta sin maná | V-20 necesita el guardián bloqueado |
| P-07 | Tener una lección pendiente y una completada | V-05, V-07, V-08 |

### 2.2 Rutas de `adb` (no está en `PATH` en este equipo)

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb devices          # debe listar 1 dispositivo "device", no "unauthorized"
```

### 2.3 Estados del dispositivo que hay que probar

| Estado | Cómo se activa | Qué se valida |
|---|---|---|
| Normal | — | todo el recorrido |
| **Escala de texto 1.5×** | Ajustes → Pantalla → Tamaño de fuente (o `adb shell settings put system font_scale 1.5`) | §8 |
| **Escala de texto 2.0×** | `adb shell settings put system font_scale 2.0` | §8 |
| **Quitar animaciones** | Ajustes → Accesibilidad → **Quitar animaciones** (Android 12+) | §6 (V-25) |
| **TalkBack** | Ajustes → Accesibilidad → TalkBack | §7 |
| **Sin red** | modo avión, o `adb shell svc data disable` + `adb shell svc wifi disable` | V-21…V-23 |
| **Pantalla estrecha** | dispositivo pequeño o `adb shell wm size 312x800` (restaurar con `adb shell wm size reset`) | overflow en las 15 pantallas sin test |

> Si «Quitar animaciones» no existe en el build del dispositivo, usar Opciones de
> desarrollador → *Escala de animación* = **desactivada** como aproximación y
> anotarlo. Si la app sigue animando con la preferencia activa, **es un FALLO**
> (R-02 de `13`), no un problema del dispositivo.

---

## 3. Cómo capturar y dónde guardarlas

### 3.1 Comando (una por ítem)

```powershell
# 1. Capturar en el dispositivo
& $adb shell screencap -p /sdcard/s.png

# 2. Traer al repo
& $adb pull /sdcard/s.png "docs\ui-ux-audit\screenshots\04-dashboard.png"

# 3. Verificar que es PNG (debe empezar 137 80 78 71)
Get-Content -Encoding Byte -TotalCount 8 "docs\ui-ux-audit\screenshots\04-dashboard.png"
```

Equivalente con `cmd` si PowerShell corrompe el binario:

```cmd
cmd /c "adb shell screencap -p /sdcard/s.png && adb pull /sdcard/s.png docs\ui-ux-audit\screenshots\04-dashboard.png"
```

**Reglas:**

- Guardar **siempre** en `docs/ui-ux-audit/screenshots/`. No en `Downloads`, no
  en la raíz del repo.
- Nombres: los 15 de `docs/ui-ux-audit/screenshots/README.md` + los sufijos de
  este checklist (`-error`, `-vacio`, `-texto15`, `-texto20`, `-talkback`,
  `-sinred`). Ejemplo: `06-conversacion-texto15.png`.
- Si el PNG pesa > 2 MB o el repo no acepta binarios, guardar igualmente y
  anotarlo en §9 (no sustituirlo por un enlace temporal).
- **Nunca** renombrar una captura para que parezca de otra pantalla: es la
  razón por la que la carpeta lleva meses vacía.

---

## 4. Recorrido por pantalla (V-01…V-20)

Puntuar **OK / FALLO / N/A**. «N/A» sólo si la pantalla no existe en el build.
Cada FALLO necesita **captura + línea de evidencia** (§9.4).

### 4.1 Entrada

| # | Pantalla | Cómo llegar | Qué mirar | OK si |
|---|---|---|---|---|
| **V-01** | Splash | abrir la app | logo centrado, sin salto al pasar a Welcome, sin frame en negro | transición limpia, < 2 s |
| **V-02** | Welcome (login) | sin sesión | **CTA violeta** (contraste), teclado sobre los campos, «REGISTER WITH GOOGLE» | texto del CTA legible a 20 cm; campos no tapados; sin overflow |
| **V-03** | Onboarding (4 pasos) | crear cuenta | CTA «continuar» violeta, paso actual visible, «volver» | se entiende en qué paso está sin leer todo; CTA legible |
| **V-04** | Mini-conversación | paso final del onboarding | burbujas, botón de saltar, volver a hablar | se entiende que es una prueba y no la app completa |

### 4.2 Núcleo

| # | Pantalla | Cómo llegar | Qué mirar | OK si |
|---|---|---|---|---|
| **V-05** | Dashboard · Mazmorras | `/home` | **jerarquía del HUD** (avatar, nivel, maná vs. tarjetas), dock de 4, tarjeta «continuar» | en < 2 s se identifica la acción principal; el HUD no compite con el CTA |
| **V-06** | Dashboard · Estado | dock, 3.er icono | densidad (11 niveles de texto en otras pantallas), gráficas, racha | se lee sin sensación de ruido; cifras con jerarquía |
| **V-07** | **Conversación** | CTA «continuar aventura» | burbuja del tutor (`#1E60FF`), burbuja propia, **micrófono 72 px**, **botón replay de 20 px** | micrófono es el objeto dominante; el replay **se puede pulsar con el pulgar sin fallar** (hoy mide 20×20: probable FALLO) |
| **V-08** | **Resumen de sesión** | terminar una conversación | botón **LISTO** violeta, «volver» de la cabecera, cifras fijas vs. recompensa real | recompensa cuadra con lo ganado; el «volver» no exige puntería (hoy 40 px) |
| **V-09** | Paywall | badge PRO | CTA violeta, planes, precio/trial | CTA legible; se distingue trial de suscripción |
| **V-10** | Gremio (salas) | dock, 2.º icono **y** ruta `/chat-rooms` | nada bajo la barra de estado/notch (la pantalla no tiene `SafeArea` propia: depende del contenedor), tabs, «CREAR MESA» | ni en pestaña ni en ruta queda contenido tapado |
| **V-11** | Sala de voz | crear/unirse a mesa | avatares, hablando/no hablando, salir | estado de habla se distingue sin color únicamente |
| **V-12** | **Tienda** | acceso rápido | tarjetas, bordes de input/botones, «RECLAMAR» (48×40) | bordes visibles; «RECLAMAR» se pulsa a la primera |
| **V-13** | Inventario | acceso rápido | rejilla, rarezas, volver | rarezas se distinguen por algo más que el color |
| **V-14** | Misiones | spotlight | 3 capas (día/contratos/evento), progreso | se distingue la capa de cada misión |
| **V-15** | **Mis errores** | acceso rápido | color del «volver» (`medievalText`, fuera de paleta), tarjetas | el icono no parece «apagado» respecto al resto |
| **V-16** | Informe semanal | tarjeta del dashboard | gráficas, navegación de semanas | cifras legibles; flechas ≥ 48 px |
| **V-17** | Listening | tarjeta de ruta | reproductor, opciones, progreso | se puede responder sin mirar el texto pequeño |

### 4.3 Cierre y sistema

| # | Pantalla | Cómo llegar | Qué mirar | OK si |
|---|---|---|---|---|
| **V-18** | **Ajustes** | dock, 4.º icono | botón destructivo (carmesí + texto oscuro), interruptores, «volver» | destructivo se lee como peligro y **no** se pulsa por accidente |
| **V-19** | Perfil | «editar perfil» | avatar, campos, «volver» 44 px | campos con borde visible; volver cómodo |
| **V-20** | Guardián (sin maná) | agotar maná | ilustración, pulso, «volver» 40 px | la animación no distrae del mensaje; volver cómodo |
| **V-20b** | Resultado de jefe | examen de rango | botones de 46 px de alto, rango nuevo | ambos botones se pulsan sin fallar |

**Extra (modal, no pantalla):** V-20c **repaso SRS** — abrir una tarjeta de
vocabulario; comprobar el botón «cerrar» violeta y el giro de la tarjeta.

---

## 5. Estados: error, vacío, sin red (V-21…V-24)

| # | Escenario | Cómo forzarlo | Qué mirar | OK si | FALLO conocido |
|---|---|---|---|---|---|
| **V-21** | **Tienda sin red** | modo avión → abrir Tienda | ¿dice «AÚN NO HAY OBJETOS»? | distingue **error** de **vacío** y ofrece reintentar | hoy pinta vacío (`shop_screen.dart:657-665`, E-01) |
| **V-22** | **Dashboard sin red, sin caché** | borrar datos de la app, modo avión, abrir | copy «Mostrando el último progreso guardado» | el copy es cierto: si no hay caché, lo dice | hoy miente (`dashboard_screen.dart:194-231`, E-02) |
| **V-23** | **Dashboard sin red, con caché** | abrir con red, cerrar, modo avión, reabrir | banner dorado de «datos de hace X min» | el banner aparece y la cifra es la última real | — |
| **V-24** | **Error de IA en conversación** | modo avión a mitad de turno | ¿el fallo aparece como mensaje del tutor? | error accionable + reintento, **nunca** como turno del tutor | hoy correcto (`conversation_providers.dart:1869-1876`) |

Capturas: `10-tienda-sinred.png`, `04-dashboard-error.png`,
`04-dashboard-cache.png`, `06-conversacion-error.png`.

---

## 6. Reduce-motion y texto mínimo (V-25…V-26)

| # | Prueba | Cómo | OK si | FALLO conocido |
|---|---|---|---|---|
| **V-25** | **Quitar animaciones** activo | activar la preferencia y recorrer Dashboard, Conversación y Guardián | **no queda ningún movimiento infinito**: sin esquinas rúnicas pulsando, sin partículas, sin monstruo flotando, sin waveform girando | hoy 12 de 14 loops siguen (R-02) |
| **V-26** | Texto mínimo legible | buscar los textos de 7 px (badge PREMIUM del gremio, estado de la sala de voz) | se leen sin acercar el móvil | hoy 7 px (`chat_rooms_screen.dart:1063`, `voice_room_screen.dart:914`) |

---

## 7. TalkBack (V-27…V-29)

Activar TalkBack y **no mirar la pantalla**: navegar sólo con gestos.

| # | Control | Prueba | OK si |
|---|---|---|---|
| **V-27** | **Micrófono hold-to-talk** | enfocar el micrófono y **doble toque**; luego doble toque mantenido | el lector anuncia el control **y** la grabación empieza/termina. Hoy el `Semantics` no tiene acción (`conversation_mic_button.dart:160-172`): doble toque **no hace nada** → FALLO esperado |
| **V-28** | **Cabeceras «volver»** | recorrer las 14 cabeceras | se anuncia «Volver» (no «botón» a secas). Hoy sólo 4 de 14 tienen etiqueta |
| **V-29** | **Dock del dashboard** | recorrer los 4 destinos | anuncia el destino **y si está seleccionado**. Hoy 0 `Semantics(selected:)` → FALLO esperado |
| **V-29b** | **Barras de progreso** | tarjeta de meta diaria / maná / misión | anuncia el valor («60 %» o «3 de 5»). `SegmentedBar` no expone `value` |
| **V-29c** | **Recompensas y chips** | terminar una misión | el foco no se queda atrapado; el cambio de estado se anuncia |
| **V-29d** | **Botón replay de la burbuja** | doble toque | funciona y se anuncia como «reproducir» (hoy no tiene etiqueta) |

Capturas de TalkBack no sirven: anotar el **texto exacto anunciado** en §9.3.

---

## 8. Escalado de texto (V-30…V-32)

Repetir con **1.5×** y con **2.0×**; comparar con la captura base.

| # | Pantalla | Qué mirar | OK si |
|---|---|---|---|
| **V-30** | Conversación | burbujas, barra inferior, micrófono | nada se corta; el micrófono no se sale; **el texto no se solapa** |
| **V-31** | Resumen | cifras, botón LISTO, chips de recompensa | las cifras no se truncan; el CTA sigue entero |
| **V-32** | Ajustes | filas, interruptores, destructivo | los títulos largos no empujan el interruptor fuera |

**Fuera de cobertura de test (revisar todas):** Splash, Onboarding,
MiniConversation, **Conversación**, **Resumen**, Paywall, ProfileEdit, Sala de
voz, Inventario, Resultado de jefe, Mis errores, Informe, Listening, Misiones,
Ajustes. Sólo Welcome, Dashboard y Guardián tienen test a 1.5×; a 2.0× sólo
Welcome y Guardián (`test/text_scale_test.dart:78-100`).

`FALLO` si aparece overflow, texto cortado, o un control que deja de ser
pulsable. Captura obligatoria: `NN-pantalla-texto15.png` / `-texto20.png`.

---

## 9. Registro y criterio de release

### 9.1 Puntuación

| Valor | Significado |
|---|---|
| **OK** | cumple y hay captura (o nota en TalkBack) |
| **FALLO** | no cumple; **abrir issue** con la plantilla §9.4 y la captura |
| **N/A** | no aplica a este release (justificar) |
| **NO VERIFICABLE** | no se pudo reproducir el estado; decir qué faltó |

### 9.2 Bloqueantes de release (criterio **propuesto** — lo aprueba Isaac)

Se considera **bloqueante** si cualquiera de estos es FALLO:

1. **V-07** micrófono no pulsable, o **V-27** inutilizable con TalkBack.
2. **V-02/V-03/V-08/V-09** el CTA principal no se lee (contraste).
3. **V-30/V-31/V-32** overflow o control inaccesible a 1.5×.
4. Cualquier **crash** o pantalla en blanco.
5. **V-25** movimiento infinito con «Quitar animaciones» activo.

No bloquean (se registran y se priorizan): V-15 color fuera de paleta, V-19
volver de 44 px, V-26 texto de 7 px.

### 9.3 Ficha del release

| Campo | Valor |
|---|---|
| Versión / build | |
| Commit (hash) | |
| Dispositivo / Android / densidad | |
| Fecha y persona | |
| Ítems ejecutados | V-__ … V-__ |
| OK / FALLO / N/A / NV | __ / __ / __ / __ |
| Capturas añadidas | __ (nombre → ítem) |
| Bloqueantes | sí / no |
| Firma | |

### 9.4 Plantilla de issue para un FALLO

```
Título: [UX] V-07 · micrófono no activable con TalkBack
Release: 1.0.21+22 · <device> · Android <ver>
Pantalla: Conversación
Esperado: doble toque inicia grabación; se anuncia "micrófono, botón"
Obtenido: doble toque sin efecto; se anuncia sólo "botón"
Evidencia: docs/ui-ux-audit/screenshots/06-conversacion-talkback.png
Código: lib/features/conversation/presentation/widgets/conversation_mic_button.dart:160-172
Cierra: #252 (reabrir) · Relacionado: UX-13
```

---

## 10. Anexo: comandos útiles

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

& $adb shell wm size                 # resolución real
& $adb shell wm density              # densidad (dp)
& $adb shell settings get system font_scale
& $adb shell settings put system font_scale 1.5
& $adb shell settings put system font_scale 1.0     # restaurar

& $adb shell wm size 312x800         # forzar pantalla estrecha
& $adb shell wm size reset            # restaurar

& $adb shell svc wifi disable; & $adb shell svc data disable   # sin red
& $adb shell svc wifi enable;  & $adb shell svc data enable    # restaurar

& $adb logcat -c; & $adb logcat | Select-String "flutter|Exception|overflow"
```

Rendimiento (si se sospecha jank, hoy no medido): Opciones de desarrollador →
*Perfil de GPU* → «En pantalla como barras».

---

## 11. Cobertura de este checklist

| Bloque | Ítems | Nº | Qué cierra de `13-ux-ui-audit.md` |
|---|---|---:|---|
| Entrada | V-01…V-04 | 4 | J-01, J-02, R-01 en el embudo |
| Núcleo | V-05…V-17, V-20b | 14 | jerarquía, CTA, tacto, contraste |
| Cierre | V-18, V-19, V-20, V-20c | 4 | destructivo, volver, modal SRS |
| Estados | V-21…V-24 | 4 | E-01…E-03, E-07 |
| Escalado | V-30…V-32 | 3 | A-06, #253 |
| Movimiento y tamaño mínimo | V-25, V-26 | 2 | R-02, A-11 |
| TalkBack | V-27…V-29d | 6 | R-04, A-03, A-05, A-09 |
| **Total** | | **37** | |

**Total: 37 ítems ejecutables + 7 estados de dispositivo (§2.3) + ≥ 22 capturas
(una por pantalla) + 4 de estados + las de escalado.**
Con esto, los 6 puntos «no verificable» de `13` §8 quedan cubiertos salvo el
rendimiento (que requiere perfilado aparte).
