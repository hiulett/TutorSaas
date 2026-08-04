# 05 — Consistencia Visual: Notificaciones (System HUD / Dark Fantasy)

> Documento de propuesta (no ejecución). No modifica código.
> Objetivo: unificar la apariencia de SnackBars/notificaciones del proyecto bajo una guía
> de semántica de color System HUD / Dark Fantasy.

---

## 1. Audit de notificaciones (datos reales)

### 1.1 Problema principal

Muchas notificaciones usan **fondo plano de color de acento completo** (sobre todo
`AppColors.manaCyan`, `#00E5FF`, cian muy brillante). Sobre un fondo de pantalla oscura
(`voidBg #05070E`) un bloque sólido de cian a plena saturación es visualmente estridente y
**desdibuja la semántica**: éxito, info y recompensa se muestran todos igual con cian
brillante, y el texto puede perder legibilidad según el foreground elegido.

### 1.2 Inventario real de usos (fondo/acento manaCyan y amigos)

| Archivo | Línea | Contenido | Tipo semántico real | Estado |
|---|---|---|---|---|
| `lib/core/theme/app_theme.dart` | 201–209 | `snackBarTheme`: `backgroundColor: surfaceContainerHigh` + borde `manaCyan` 1 px + `floating` | Tema global | ✅ Ya parcialmente correcto (fondo neutro + acento en borde) |
| `lib/core/theme/app_theme.dart` | 86 | `elevatedButtonTheme.backgroundColor: manaCyan` | Botón (no notificación) | Referencia de acento, no snackbar |
| `lib/features/dashboard/.../settings_screen.dart` | 1264–1269 | "Perfil de cazador eliminado. Reiniciando..." `backgroundColor: manaCyan` | ⚠️ Destructivo/info → debería ser aviso o error | ❌ Fondo plano cian |
| `lib/features/dashboard/.../settings_screen.dart` | 1272–1276 | "Error al reiniciar: $e" `backgroundColor: errorRed` | Error | ❌ `errorRed` (#FFB4AB, rojo claro) sobre fondo oscuro queda muy brillante |
| `lib/features/dashboard/.../hunter_status_screen.dart` | 104–109 | "ESTADÍSTICAS DEL CAZADOR ACTUALIZADAS ⚡" `backgroundColor: emeraldGreen` | Éxito | ❌ Verde a plena saturación |
| `lib/features/dashboard/.../hunter_status_screen.dart` | 282 | `RunicButton(backgroundColor: manaCyan)` | Botón (no notificación) | Acento correcto |
| `lib/features/dashboard/.../recommended_lessons_hub.dart` | 160 | `ElevatedButton.icon(backgroundColor: manaCyan)` | Botón (no notificación) | Acento correcto |
| `lib/features/dashboard/.../recommended_lessons_hub.dart` | 479–484 | "🔒 Completa la lección anterior…" (usa tema global) | Aviso/lock | ⚠️ Sin color semántico: debería ser ámbar |
| `lib/features/missions/.../mission_board_widget.dart` | 104 | `ElevatedButton(backgroundColor: manaCyan)` | Botón (no notificación) | Acento correcto |
| `lib/features/subscription/.../paywall_screen.dart` | 82–87 | "Thank you for subscribing!..." `backgroundColor: manaCyan` | Éxito/recompensa | ❌ Fondo plano cian |
| `lib/features/economy/.../inventory_screen.dart` | 31–37 | "EQUIPO ACTUALIZADO" `backgroundColor: manaCyan` | Éxito | ❌ Fondo plano cian |
| `lib/features/economy/.../nucleo_arcano_limit_screen.dart` | 67–75, 81–88 | `_showSnackBar(msg, AppColors.crimsonRed)` | Error | ❌ Patrón fondo sólido rojo; acierto en la semántica pero no en la presentación |
| `lib/features/dashboard/.../profile_edit_screen.dart` | 149–159 | "PHOTO UPLOADED SUCCESSFULLY 📸" `backgroundColor: emeraldGreen` | Éxito | ❌ Verde plano |
| `lib/features/dashboard/.../profile_edit_screen.dart` | 168–174 | "ERROR UPLOADING IMAGE: $e" `backgroundColor: crimsonRed` | Error | ❌ Rojo plano |
| `lib/features/dashboard/.../progress_tab_view.dart` | 408–414 | "¡Recompensa Canjeada! +XP" `backgroundColor: accentGreen` | Recompensa | ❌ Verde plano (debería ser dorado) |

**Nota de precisión:** de los ejemplos citados en el encargo, `hunter_status_screen.dart:282`,
`mission_board_widget.dart:104` y `recommended_lessons_hub.dart:160` son **botones** con acento
`manaCyan`, no SnackBars. Se listan aquí solo como contexto del uso masivo del acento. La
auditoría real de notificaciones está en el resto de la tabla.

**Conclusión del audit:**

- ✅ El tema global (`app_theme.dart:201`) ya es correcto: fondo `surfaceContainerHigh`
  (`#272A32`, neutro) + borde de acento 1 px + `SnackBarBehavior.floating`.
- ❌ Decenas de SnackBars **sobrescriben** el `backgroundColor` con color plano brillante
  (manaCyan/emeraldGreen/crimsonRed), saltándose el tema.
- ❌ No hay semántica consistente: el cian se usa para éxito, info y destrucción por igual.
- ⚠️ `errorRed` (#FFB4AB) es un "error container" claro del M3 que en fondo oscuro compite
  con el cian brillante; conviene reservarlo para texto sobre contenedor oscuro.

---

## 2. PROPUESTA: Guía visual de notificaciones System HUD / Dark Fantasy

Principio rector: **fondo neutro oscuro + borde de acento + barra/glifo de acento**, no fondo
plano de color. El color codifica el significado; la superficie lo contiene.

### 2.1 Semántica de color por severidad

| Tipo | Color de acento (borde/barra/icono) | Fondo recomendado | Texto | Uso |
|---|---|---|---|---|
| Éxito | `emeraldGreen` `#00E676` (α bajo) | `surfaceContainerHigh` | `onSurface` | Guardado, estadísticas actualizadas, equipo equipado |
| Error | `crimsonRed` `#FF1744` (rojo intenso, α bajo) — para texto sobre fondo oscuro usar `errorRed` `#FFB4AB` | `surfaceContainerHigh` | `onSurface` / `errorRed` en el glifo | Fallos de red, validación, errores de recarga |
| Advertencia | `guildAmber` `#FFAB00` o `royalGold` `#FFC700` suave (α bajo) | `surfaceContainerHigh` | `onSurface` | Acciones destructivas, lecciones bloqueadas, límites próximos |
| Info | `manaCyan` `#00E5FF` con α 0.15–0.2 **o** `runeViolet` `#9D4EDD` con α | `surfaceContainerHigh` | `onSurface` | Mensajes neutros de sistema |
| Recompensa | `royalGold` `#FFC700` suave (α bajo) + glifo dorado | `surfaceContainerHigh` | `onSurface` | XP, gemas, cofres, suscripción activada |

### 2.2 Reglas de presentación (System HUD)

1. **Fondo:** `surfaceContainerHigh` (neutro) — nunca color plano de acento.
2. **Borde izquierdo o superior:** barra de acento de 3–4 px con el color semántico
   (`crimsonRed` para error, `emeraldGreen` para éxito, etc.).
3. **Icono/glifo:** icono Material en el color semántico (`check_circle`/`error`/
   `warning_amber`/`info`/`star` o `diamond`), 18–20 px, precediendo al texto.
4. **Tipografía:** `JetBrainsMono` 12–13 para mensajes del sistema (lenguaje HUD);
   `Inter` para mensajes largos.
5. **Comportamiento:** `SnackBarBehavior.floating` (ya en tema), radio 4 px, duración
   controlada (1.2 s success / 2–4 s error), opcional `action` "DESHACER" en destructivos.
6. **Texto de error en fondo oscuro:** reservar `errorRed` (#FFB4AB) para el **glifo y el
   título del mensaje**, nunca como fondo plano.

### 2.3 Artefacto recomendado (para la fase de ejecución)

Crear un helper único (p. ej. `lib/core/widgets/system_hud_snack_bar.dart` o
`AppNotifications.show{Success,Error,Warning,Info,Reward}(context, msg)`) que centralice la
guía. Los SnackBars existentes que hoy sobrescriben `backgroundColor` pasarían a delegar en
este helper, y los que ya usan el tema global se quedan como están.

---

## 3. Cambios concretos por archivo

### 3.1 `lib/core/theme/app_theme.dart` (tema global)

- **Ya parcialmente correcto.** `snackBarTheme` (201–209) usa `surfaceContainerHigh` +
  borde `manaCyan` 1 px + floating.
- Ajuste propuesto:
  - Borde por defecto de 1 px `manaCyan` α 0.6 (hoy pleno) para que el tema base sea más
    sutil cuando no se indique semántica.
  - Añadir al `SnackBarThemeData`: `actionTextColor: AppColors.manaCyanLight`, y
    `iconColor`/`closeIconColor` si el Flutter SDK lo permite.
  - Documentar en el tema que el color semántico se inyecta por `SnackBar.shape`/`backgroundColor`
    desde el helper, no cambiando el tema por caso.

### 3.2 SnackBars con fondo plano → migrar a helper semántico

| Archivo | Línea(s) | Notificación | Semántica → color de acento |
|---|---|---|---|
| `settings_screen.dart` | 1264–1269 | "Perfil de cazador eliminado…" | ⚠️ Destructivo → `guildAmber`/`royalGold` |
| `settings_screen.dart` | 1272–1276 | "Error al reiniciar…" | Error → `crimsonRed` (glifo `errorRed`) |
| `hunter_status_screen.dart` | 104–109 | "ESTADÍSTICAS DEL CAZADOR ACTUALIZADAS ⚡" | Éxito → `emeraldGreen` |
| `recommended_lessons_hub.dart` | 479–484 | "🔒 Completa la lección anterior…" | Aviso → `guildAmber` (hoy usa tema sin color) |
| `paywall_screen.dart` | 82–87 | "Thank you for subscribing!..." | Recompensa → `royalGold` |
| `inventory_screen.dart` | 31–37 | "EQUIPO ACTUALIZADO" | Éxito → `emeraldGreen` |
| `nucleo_arcano_limit_screen.dart` | 67–75, 81–88 | "MANÁ INSUFICIENTE…" / "ERROR AL RECARGAR…" | Error → `crimsonRed` + glifo `errorRed` |
| `profile_edit_screen.dart` | 149–159 | "PHOTO UPLOADED SUCCESSFULLY 📸" | Éxito → `emeraldGreen` |
| `profile_edit_screen.dart` | 168–174 | "ERROR UPLOADING IMAGE…" | Error → `crimsonRed` + glifo `errorRed` |
| `progress_tab_view.dart` | 408–414 | "¡Recompensa Canjeada! +XP" | Recompensa → `royalGold` |

### 3.3 Botones con acento `manaCyan` (NO tocar)

`app_theme.dart:86`, `hunter_status_screen.dart:282`, `mission_board_widget.dart:104`,
`recommended_lessons_hub.dart:160` son **botones** y ya siguen el patrón de acento correcto.
Fuera del alcance de esta guía de notificaciones.

---

## 4. Cómo aplicar (método)

1. **Fase A – Artefacto:** crear el helper `SystemHudSnackBar`/`AppNotifications` con la
   semántica de la sección 2.1 (fondo neutro + barra/glifo de acento + tipografía).
2. **Fase B – Tema:** retocar `snackBarTheme` (borde default más sutil, action/icon color).
3. **Fase C – Migración:** recorrer la tabla de la sección 3.2, reemplazando cada
   `SnackBar(... backgroundColor: <color> ...)` por la llamada al helper con la semántica
   correcta. Los SnackBars que ya usan el tema global se dejan intactos.
4. **Fase D – Verificación:** `flutter analyze` (0 errores) y revisión visual en dispositivo
   (éxito/error/aviso/info/recompensa en contraste sobre `voidBg`).

---

## 5. Impacto

- **Positivo:** la información se lee de un vistazo por color (éxito=verde, error=rojo,
  aviso=ámbar, info=cian tenue, recompensa=oro); desaparecen los bloques planos de cian
  brillante; el conjunto se alinea con el System HUD/Dark Fantasy del resto de la app.
- **Neutral:** no cambia lógica de negocio; solo presentación.
- **Estandarización:** un solo punto de entrada para futuras notificaciones → menos
  divergencias.

## 6. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Migración masiva toca muchos archivos (≈10 notificaciones identificadas) | Hacerla en fases; el helper centraliza y reduce diff futuro |
| El color α bajo sobre `surfaceContainerHigh` puede parecer "apagado" | Verificar contraste en dispositivo; la barra de acento de 3–4 px mantiene la señal visual |
| `errorRed` (#FFB4AB) confunde con cian brillante si se usa mal | Usarlo solo para glifo/título de error sobre fondo oscuro, nunca como fondo |
| Cambiar botones por error | Los botones con acento `manaCyan` quedan **fuera de alcance** (sección 3.3) |
| Texto largo rompe el SnackBar con barra de acento | Mantener `floating` + máx 2 líneas; duraciones diferenciadas por tipo |
