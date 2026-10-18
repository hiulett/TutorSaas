# Checklist de release — Android

Estado: **borrador para la próxima build**. Última release publicada: `1.0.19+20`.

## 0. Antes de construir

- [ ] `flutter analyze` → **0 errores** (hoy: 0 errores, 36 warnings, 131 infos)
- [ ] `flutter test` → **149/149**
- [ ] `flutter gen-l10n` ejecutado tras el último cambio en `.arb`
- [ ] `pubspec.yaml` con `version:` incrementado (`1.0.19+20` → `1.0.20+21`)
- [ ] `android/key.properties` y `android/app/upload-keystore.jks` presentes y **fuera de git**
- [ ] Sin cambios de servidor pendientes de aplicar (ver §3)

## 1. Qué incluye esta build (cambios de cliente)

| Issue | Cambio visible |
|---|---|
| #2 | La tienda de oro entrega el ítem y permite equiparlo |
| #47 | El turno del Oráculo cuesta 15; el cierre 30 |
| #27 | El badge de gemas desaparece del dashboard |
| #28 | Chip «Nv. X» en el HUD |
| #19 | Fluidez y precisión se muestran como `~X%` y `(EST.)` |
| #20 | El selector de idioma solo ofrece inglés |
| #36 | La ficha premium ya no promete misiones ni títulos SSS |
| #41 | Se retira «Moderated by AI» de las salas de voz |
| #30 | «Guardián de la Mazmorra» → «Santuario de Maná» |
| #23 | Guardar Settings ya no resetea XP, racha, idioma ni CEFR |
| #18 | Una evaluación fallida ya no marca la lección como aprobada |
| #17 | Umbral de aprobación 0.75 (3/4 pasa) y halo coherente |
| #14 | El rango inválido se descarta |
| #31 | El chat envía solo los últimos 24 mensajes |
| #32 | El dashboard no inventa XP ni racha mientras carga |
| #33 | Contraste AA en textos secundarios; tooltips en acciones |
| #50 | Sin carpeta `ios/` |

## 2. Qué ya está activo en servidor (no requiere build)

#5 (progreso de misiones), #6 (nivel del Oráculo persistente), #7 (fin del doble cobro), #9 (cuota de IA), #11 (logros), #12 (IDOR de gremio), #13 (cron cerrado), #16 (borrado/exportación), #26 (semillas archivadas).

> Nota: #6, #7, #9, #11, #12, #13 ya benefician a los usuarios con la app actual. **#2 y #47 no**, porque cambian el cliente.

## 3. Build

```powershell
flutter build appbundle --release
```

**Resultado del 2026-10-18:**

- [x] Genera `build/app/outputs/bundle/release/app-release.aab` — **110,5 MB**
- [x] `versionCode = 21`, `versionName = 1.0.20` (verificado en el manifiesto fusionado)
- [x] Firmado con `upload-keystore.jks` (Play App Signing gestiona la clave final)
- [ ] Verificar el tamaño de descarga por dispositivo en Play Console (el AAB incluye todas las ABIs; el usuario descarga una)

> El build tardó ~10,6 minutos. Los assets suman 52 MB (imágenes 34,4 · branding 14,4 · vídeos 2,6 · música 0,6); el resto es motor Flutter y librerías nativas por ABI.

## 4. Prueba en dispositivo (obligatoria antes de subir)

Con una cuenta de prueba real, en un Android físico:

**Camino nuevo (usuario nuevo)**
- [ ] Registro + onboarding completo (4–5 pasos, sin selector de idioma)
- [ ] Examen del Oráculo: comprobar que el maná baja **15 por turno** y **30 al cerrar**
- [ ] El nivel asignado se guarda (cerrar y reabrir la app)

**Camino existente (usuario actual)**
- [ ] Guardar Settings **no** altera XP, racha, idioma ni CEFR
- [ ] La tienda de oro entrega el ítem, descuenta el precio exacto y permite equiparlo
- [ ] Comprar dos veces el mismo ítem no cobra la segunda vez
- [ ] El dashboard muestra `Nv. X` y no muestra gemas
- [ ] El resumen de sesión muestra `~X%` y `(EST.)`
- [ ] Una misión diaria avanza al cerrar sesión y se puede reclamar
- [ ] La pantalla de maná agotado dice «Santuario de Maná»
- [ ] Las salas de voz no muestran «Moderated by AI»

**Regresiones que no deben aparecer**
- [ ] Pantalla en blanco o datos falsos mientras carga el dashboard
- [ ] Cobro de maná superior a 15 en un turno de Oráculo
- [ ] Pérdida de progreso al guardar ajustes
- [ ] Crash al abrir conversación desde el roadmap

## 5. Publicación

- [ ] Subir el AAB a **Internal testing**
- [ ] Notas de la versión (español): resumen de §1 sin jerga técnica
- [ ] Añadir 1–2 testers nuevos y esperar 48 h
- [ ] Revisar *Play Console → Calidad → Rendimiento* (no hay Crashlytics: esta es la única señal de crashes)
- [ ] Promocionar a **Closed testing** si no hay crashes nuevos

## 6. Después de publicar

- [ ] Verificar en producción que el maná se cobra 15/turno (revisar `mana_transactions`)
- [ ] Cerrar **#3**: restringir `profiles_self` y `subscriptions_self`, revocar `add_xp`/`add_gold`/`add_gems`/`add_fragments`
- [ ] Cerrar **#1** (persistencia de lecciones) y **#25** (radar) en la siguiente iteración
- [ ] Vigilar `llm_quota_events`: si hay muchos 429, subir el límite de 30/min

## 7. Rollback

- La app anterior sigue funcionando: el servidor es retrocompatible (los RPC antiguos siguen vivos).
- Si la build falla en producción: pausar el rollout en Play Console; no hace falta revertir servidor.
- **No** cerrar #3 hasta que la build nueva esté adoptada (si se cierra antes, la app antigua deja de guardar progreso).

## 8. Limitaciones conocidas de esta release

- Sin notificaciones reales (#39).
- Sin repaso espaciado (#24).
- Sin compra de maná (#8): solo plan por suscripción.
- Las métricas de fluidez y pronunciación siguen siendo estimaciones (#19).
- El arte del «Santuario» sigue siendo el del guardián (#30).
