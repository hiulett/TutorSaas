# Plan de Pruebas — Internacionalización

> Fecha: 2026-08-02 · Complementa `01_Current_Audit.md`, `02_Architecture.md` y `06_Migration_Report.md`.
> Este documento define cómo verificar la completitud i18n: QA funcional, detección automática, `followDeviceLanguage`, sincronización entre dispositivos, regresión y checklist por pantalla.

---

## 1. Objetivo y alcance

- **Objetivo**: demostrar que la app es multilingüe de extremo a extremo (`es`/`en`/`pt`), que el idioma de interfaz sigue correctamente al dispositivo o al override manual, y que no se introducen regresiones.
- **Alcance**: validar los tres ejes de idioma (`uiLanguage`, `learningLanguage`, `aiExplanationsInNative`) más `followDeviceLanguage` (nuevo), la detección del dispositivo, la sincronización prefs↔Supabase y la migración de los ~69 textos hardcodeados.
- **Fuera de alcance**: calidad de las traducciones (revisión lingüística se hace aparte) y comportamiento de contenido de lecciones (catálogo, estrategia de datos en P3).

---

## 2. QA funcional — cambiar idioma desde Settings

### 2.1 Prerrequisitos

- Implementada la sección "Language" en Settings (`02_Architecture.md` §5): interruptor *Seguir idioma del dispositivo*, selector *Idioma de la interfaz* (`es`/`en`/`pt`), selector *Idioma que aprendo*, interruptor *Explicaciones en mi idioma*.
- Al menos los lotes P0 y P1 de la migración aplicados para una cobertura de pantallas significativa.

### 2.2 Caso principal (override manual)

| # | Paso | Resultado esperado |
|---|---|---|
| 1 | Desactivar *Seguir idioma del dispositivo* (`followDeviceLanguage = false`) | El selector *Idioma de la interfaz* se habilita/visualiza |
| 2 | Elegir `es` | Toda la UI en español al instante (sin reiniciar) |
| 3 | Recorrer las pantallas de P0+P1 | Todos los textos de esas pantallas en español |
| 4 | Cambiar a `en` | Toda la UI en inglés |
| 5 | Cambiar a `pt` | Toda la UI en portugués |
| 6 | Matar la app y relanzarla | El idioma elegido persiste (prefs) |
| 7 | Cerrar sesión e iniciar de nuevo | El idioma persiste vía `user_settings` (Supabase) |

**Verificación crítica**: en cada idioma, abrir cada pantalla del checklist (§5) y confirmar que **no aparece ninguna clave ARB en texto plano** (síntoma de `t()` o de claves sin regenerar).

### 2.3 Caso: cambiar idioma de aprendizaje vs interfaz

| # | Paso | Resultado esperado |
|---|---|---|
| 1 | `uiLanguage = es`, `learningLanguage = en` | La UI en español; el contenido (lecciones/preguntas) en inglés |
| 2 | `uiLanguage = en`, `learningLanguage = es` | La UI en inglés; el contenido en español |
| 3 | Interruptor *Explicaciones en mi idioma* on/off | Las explicaciones del tutor IA cambian de idioma nativo a idioma objetivo |

---

## 3. Detección automática del dispositivo

### 3.1 Primer inicio (sin valor previo en prefs)

| # | Locale del dispositivo | Resultado esperado |
|---|---|---|
| 1 | `es-ES` | UI en español |
| 2 | `en-US` | UI en inglés |
| 3 | `pt-BR` | UI en portugués |
| 4 | `fr-FR` (no soportado) | Fallback a `es` |

> Fuente de detección: `PlatformDispatcher.instance.locale.languageCode` normalizado (`02_Architecture.md` §2). Probar en emuladores/`adb` con `--lang` distinto o en el simulador iOS con región cambiada.

### 3.2 Arranques posteriores

- Con `followDeviceLanguage = true`: cambiar el idioma del dispositivo entre arranques → la UI sigue al dispositivo.
- Con `followDeviceLanguage = false`: cambiar el idioma del dispositivo entre arranques → la UI permanece en el `uiLanguage` guardado.
- Primer inicio con sesión Supabase activa: la detección resuelve el idioma y se persiste un primer registro en `user_settings` (si no existía).

### 3.3 Matriz `followDeviceLanguage` × `uiLanguage`

| `followDeviceLanguage` | Dispositivo | `uiLanguage` guardado | UI efectiva |
|---|---|---|---|
| `true` | `en` | `es` | `en` |
| `true` | `fr` (no soportado) | `es` | `es` (fallback) |
| `false` | `en` | `es` | `es` |
| `false` | `pt` | `pt` | `pt` |

> Regla: `uiLanguage_efectivo = followDeviceLanguage ? (deviceLocale ∈ {es,en,pt} ? deviceLocale : 'es') : uiLanguage`.

---

## 4. Sincronización entre dispositivos

### 4.1 Push (prefs → Supabase)

| # | Paso | Resultado esperado |
|---|---|---|
| 1 | Dispositivo A, sesión iniciada, cambia `uiLanguage` a `pt` | `user_settings.user_id = A` registra `ui_language = 'pt'` |
| 2 | Cambia `followDeviceLanguage` a `false` | La columna `follow_device_language = false` se persiste |
| 3 | Cambia *Explicaciones en mi idioma* | `ai_explanations_native` se persiste (brecha G8 cerrada) |

### 4.2 Pull (Supabase → prefs) — arranque con sesión

| # | Paso | Resultado esperado |
|---|---|---|
| 1 | Dispositivo B (nuevo), misma cuenta, `followDeviceLanguage = true` | La UI sigue al idioma de B; no se fuerza `uiLanguage` remoto (idempotente) |
| 2 | Dispositivo B, `followDeviceLanguage = false` | Se aplica el `uiLanguage` remoto en la primera sesión de B |
| 3 | Sin conexión | No bloquea el arranque; usa prefs + detección (el pull es best-effort) |

### 4.3 Conflicto y failover

- `followDeviceLanguage = true` gobierna por encima de `uiLanguage` remoto (regla de `02_Architecture.md` §3.3).
- Si el fetch de `user_settings` falla, se registra el error (`debugPrint`) y se continúa con prefs; no debe crashear el arranque.

---

## 5. Checklist por pantalla

> Para cada pantalla: verificar en `es`, `en` y `pt`. Marcar (✓) cuando todo el texto visible venga de `AppLocalizations`.

| Pantalla | Ruta de acceso | Textos a verificar | es | en | pt |
|---|---|---|---|---|---|
| Welcome | Onboarding paso 0 | `welcome_*`, CTA de login/registro | | | |
| Onboarding | Paso 1 idioma nativo | `onboarding_search_country` (hint), títulos de idioma | | | |
| Oracle test | Onboarding | hint/tooltip/títulos `oracle_*` | | | |
| Settings | Dashboard → Config | 23 títulos de opciones, sección Language | | | |
| Dashboard (Dungeons) | Tab 0 | `dashboard_*`, tarjetas de lección | | | |
| Guild | Tab 1 → `/chat-rooms` | `chat_rooms_*` (9), títulos de diálogo | | | |
| Voice room | Sala de voz | `voice_room_*`, hint/tooltip | | | |
| Conversación | `/conversation` | `conversation_*`, `live_goals_*` | | | |
| Level exam | Examen de nivel | `level_exam_*` | | | |
| Misión (tablero) | Dungeons → misiones | `missions_*` | | | |
| Inventario | `/shop` → inventario | `inventory_*` | | | |
| Battle Pass | `/shop` → battle pass | `battle_pass_*` | | | |
| Colecciones | `/shop` → colecciones | `collections_*` | | | |
| Núcleo Arcano límite | Paywall/economía | `nucleo_*` | | | |
| Paywall | `/paywall` | `paywall_*` | | | |
| Perfil | Dashboard → Status → Perfil | `profile_*`, `language_*` | | | |
| Editar perfil | Perfil → editar | `profile_edit_*`, `labelText` | | | |
| Progreso | Dashboard → Status | `progress_*`, tooltips | | | |
| Sesión resumida | Fin de lección | `session_summary_*` | | | |
| Tarjetas SRS | Repaso de vocabulario | `srs_*` | | | |
| Gráficos | Perfil/Progreso | `chart_*`, `heatmap_*` | | | |
| Header HUD / Leaderboard | Dashboard | tooltips `hud_*`, `leaderboard_tooltip` | | | |

**Prueba negativa en cada pantalla**: ninguna cadena en texto plano igual a una clave ARB (p.ej. no ver `profile_xp_total` literal en pantalla).

---

## 6. Regresión

| Comando | Qué valida | Frecuencia |
|---|---|---|
| `flutter analyze` | **0 errores** (infos/warnings existentes no se persiguen) | Por lote y en CI |
| `flutter test` | Suites unitarias (5 archivos) no rompen con los reemplazos | Por lote y en CI |
| `flutter gen-l10n` | Paridad de claves y generación correcta tras editar `.arb` | Tras cada edición de ARB |
| `dart run build_runner build --delete-conflicting-outputs` | Codegen (freezed/json) intacto tras tocar modelos | Si se modifica `language_settings.dart` |

### 6.1 Pruebas unitarias nuevas recomendadas

- `UserLanguageNotifier`: carga de prefs, fallback `es`, persistencia de los 4 campos, idempotencia del pull desde Supabase.
- `effectiveUiLanguageProvider`: matriz §3.3 con `deviceLocaleProvider` inyectado (fake `PlatformDispatcher`).
- Normalización de locale: `fr → es`, `pt-BR → pt`, `en-US → en`.
- Verificación de paridad de claves entre los 3 `.arb` (script de test que compara claves de `app_en.arb` contra `app_es.arb` y `app_pt.arb`).

### 6.2 Barrido automatizable (script de QA)

```
grep -rEn "Text\(\s*['\"]|labelText:\s*['\"]|hintText:\s*['\"]|tooltip:\s*['\"]|title:\s*['\"]" lib/features --include=*.dart
```

- Cualquier coincidencia en los 20 archivos del inventario = fallo del lote.
- Cualquier coincidencia nueva en archivos ya migrados = regresión a reportar.

---

## 7. Entorno de prueba

| Aspecto | Configuración |
|---|---|
| Dispositivos | Emulador Android (`adb shell settings put system system_locales pt-BR`), simulador iOS (región), al menos 2 dispositivos físicos para sync |
| Locales a probar | `es`, `en`, `pt` (soportados) + `fr`/`de` (no soportados → fallback) |
| Cuentas | 1 cuenta nueva (primer inicio) + 1 cuenta existente con ajustes en `user_settings` |
| Base de datos | Revisar RLS de lectura de `user_settings` (política `user_id = auth.uid()`) |
| Build | `flutter run -d <device>`; para el arranque con sesión, sesión real o token de prueba |

---

## 8. Criterios de aceptación

- [ ] QA funcional §2 completo: cambio de idioma en vivo y persistente (reinicio + relogin).
- [ ] Detección §3: primer inicio sigue al dispositivo; fallback correcto a `es` con locale no soportado.
- [ ] Matriz `followDeviceLanguage` §3.3 en verde en los 4 casos.
- [ ] Sync §4: push de los 4 campos, pull idempotente, sin bloqueo sin conexión.
- [ ] Checklist §5 completo en `es`/`en`/`pt` sin claves en texto plano.
- [ ] `flutter analyze` 0 errores; `flutter test` en verde.
- [ ] Sin regresiones detectadas por el barrido §6.2.
