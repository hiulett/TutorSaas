# Estado real de las historias de legado

> Auditoría de los issues abiertos de `hiulett/TutorSaas` que **no** son historias
> del épico `P-xx` (#137). Fecha: 29-oct-2026.
> Base verificada: `origin/master` = `995e958` (merge #229). El código y la base
> de datos son la fuente de verdad; los comentarios antiguos de los issues **no**
> se dan por ciertos.

## Método

1. Se listaron los 45 issues abiertos y se separaron los 25 que no empiezan por
   `P-` (incluidas las dos épicas, #46 y #137).
2. Para cada uno se buscó el archivo, la consulta o el test que demuestra (o
   refuta) el problema.
3. Verificación de datos con el MCP `supabase` (solo lectura) y de distribución
   con el MCP `play-console` / API de RevenueCat.
4. Clasificación: **resuelto**, **parcial**, **vigente**, **obsoleto/superado**,
   **decisión pendiente**, **bloqueado por acceso externo**.

## Resumen

| Resultado | Issues |
|---|---|
| Revisados | **25** (23 historias + 2 épicas) |
| Cerrados | **3** (#40, #56 resueltos; #84 superado por P-48) |
| Abiertos con evidencia actualizada | **22** (incluidas #46 y #137) |
| De ellos: parciales | 12 |
| De ellos: vigentes / decisión | 6 |
| De ellos: bloqueados por acceso externo | 2 |
| De ellos: épicas actualizadas | 2 |

## Tabla

| Issue | Título | Estado real | Evidencia | Acción |
|---|---|---|---|---|
| #16 | Retención de conversaciones y borrado/exportación | **Parcial** | UI de exportar/borrar en `settings_screen.dart:180-190,470,522`; RPC `delete_my_account`/`export_my_data` y ACL en prod; cron `clean-old-logs` (03:15) y `clean_old_logs` solo `service_role`. Falta enlace de privacidad en Settings y política de retención para `messages`/`conversations`/transcripciones (solo se purgan logs). | Comentario + `estado/parcial` |
| #32 | Estados de carga/error/vacío/offline | **Parcial** | No hay widgets compartidos: `_ErrorState`/`_EmptyState` privados en `weekly_report_screen.dart:627`, `my_errors_screen.dart:288,323`, `listening_quiz_screen.dart:846`. `connectivity_plus` no está en `pubspec.yaml`. Quedan `catch (_) {}` en UI (`onboarding_screen.dart:249,263,270`, `voice_room_screen.dart:421`, etc.). | Comentario + `estado/parcial` |
| #33 | Accesibilidad | **Parcial** | `test/text_scale_test.dart` cubre 1.5×/2.0×; 9 `Semantics(`, 6 `Tooltip(`; persisten opacidades 0.24/0.38 (iconos y texto secundario) y no hay auditoría TalkBack. | Comentario + `estado/parcial` |
| #34 | Design system y god widgets | **Parcial (regresión)** | `conversation_screen.dart` 2.359 líneas (antes 1.487), `conversation_providers.dart` 2.886, `settings_screen.dart` 1.611, `chat_rooms_screen.dart` 1.300, `voice_room_screen.dart` 1.240. Tokens: `AppSpacing` 4 usos vs 418 `EdgeInsets`; `AppTypography` 114 vs 383 `GoogleFonts`; 177 `BorderRadius.circular`; paleta medieval paralela en `app_colors.dart:131-145`. | Comentario + `estado/parcial` |
| #40 | Campos de onboarding que no se leen | **Resuelto** | País y stats eliminados (0 coincidencias de `country_code`/`STR:5`); nombre de personaje se guarda en `display_name` (`onboarding_screen.dart:328`); meta/intereses se leen en `dashboard_repository_impl.dart:74-85` y el prompt; `correction_style` se usa en `tutor_prompt_builder.dart:202`. | **Cerrar** con evidencia |
| #42 | Presencia duplicada / filas fantasma | **Parcial** | Filtro de 120 s en `chat_rooms_repository_impl.dart:687-698`; cron `purge-stale-participants` cada minuto con 180 s (migración `20261018062241`, activo en prod); documentado en `docs/DATA_MODEL.md:128`. Falta unificar/documentar los **dos** sistemas: `report_presence` (`presence_repository_impl.dart:13`) sigue escribiendo `user_presence`, que no se menciona en la documentación vigente. | Comentario + `estado/parcial` |
| #46 | Épica auditoría septiembre-2026 | **Abierta (legado)** | Quedan 19 historias de legado abiertas; #61 (P0) sigue bloqueada por Google Cloud. Criterio de cierre "cero P0" no cumplido. | Comentario de estado; **no cerrar** |
| #51 | Release 1.0.21+22 | **Vigente / bloqueada por operación** | `pubspec.yaml:5` = 1.0.21+22. Play: `internal` solo tiene 19 y `alpha` 20 (ambas `completed`); el 22 no está distribuido. `docs/RELEASE.md:98` confirma que el 21 nunca se publicó. No hay AAB en el worktree para medir. | Comentario + `estado/pendiente` |
| #52 | Tamaño del bundle | **Parcial (comentario incorrecto)** | `pubspec.yaml:64-70` excluye `assets/videos/` y `assets/images/shop/` (correcto), pero en master **no hay ningún `.webp`**: 20 PNG (21,74 MB) + 12 JPG (11,93 MB); `assets/images/ai_tutor_avatar.jpg` (722 KB) sigue presente. El comentario del 22-oct que afirma 21 WebP y AAB de 78,4 MB no está respaldado por el árbol. | Comentario correctivo + `estado/parcial` |
| #54 | 16/71 sin onboarding, 18 sin confirmar email | **Parcial / bloqueada por release** | Embudo instrumentado (`onboarding_screen.dart:72,100,277,287` → `analytics_events`), pero la vista `analytics_onboarding_funnel` devuelve **0 started / 0 completed** y no hay eventos `onboarding_*` en producción. Datos actuales: 73 auth, 65 perfiles, 18 emails sin confirmar. Sin build nuevo no hay datos. | Comentario + `estado/parcial` |
| #56 | GlassCard anula el tap en onboarding | **Resuelto** | El selector de idioma pasa `onTap` al `GlassCard` (`onboarding_screen.dart:982-995`); el `GestureDetector` externo queda redundante pero la acción se ejecuta. El barrido restante vive en #58. | **Cerrar** con evidencia |
| #58 | 5 GlassCard envueltos en GestureDetector | **Parcial / vigente** | Corregidos los de audiencia (999-1003) y chat (1076-1080); **sigue roto** el chip de demo: `voice_room_screen.dart:688-690` envuelve el `GlassCard` sin `onTap`. El `onLongPress` de moderación (937-939) no está verificado en dispositivo. No hay test de widget del caso. | Comentario + `estado/parcial` |
| #61 | Google Sign-In en APK con upload key | **Bloqueado por acceso externo** | `google_sign_in_error.dart:6-12` y `auth_repository_impl.dart:59` detectan `ApiException: 10`; `docs/RELEASE.md:37-59` documenta package y huellas. Falta registrar el SHA-1 de la upload key en Google Cloud (y probar en dispositivo). | Comentario + `estado/bloqueado` |
| #64 | RevenueCat no configurado antes del paywall | **Parcial** | `revenueCatReadyProvider` (`subscription_providers.dart:20`) y espera en `paywall_screen.dart:77,119`; `configure()` hace `logIn` al cambiar de usuario. En prod hay una suscripción `noble` con `store=play` y `rc_product_id=dungeonsspeak_noble_monthly`. Falta la prueba manual con licence tester y la build en Play. | Comentario + `estado/parcial` |
| #72 | Paywall propio y embudo | **Parcial** | Embudo presente (`paywall_viewed` 4, `purchase_started` 1, `purchase_succeeded` 1) y runbook en `docs/runbooks/PURCHASE_TESTING.md`. La API de RevenueCat confirma `offering default` con `paywall_id: null` y 2 paywalls sin publicar/asociar. Falta crear el paywall en el dashboard. | Comentario + `estado/parcial` |
| #75 | Onboarding: conversación antes de configurar | **Vigente** | El onboarding sigue con 4 pasos de configuración antes de la primera conversación (`onboarding_screen.dart:36,518`); #110 añadió la mini-conversación **después** del onboarding, no antes. | Comentario + `estado/pendiente` |
| #76 | Consecuencia narrativa al cerrar la escena | **Parcial** | `scenario_progress` y `record_scenario_outcome` existen y se llaman desde `conversation_providers.dart:1576`; el chip genérico está en `conversation_screen.dart:1001`. Faltan las 3 escenas con consecuencia redactada y consumir `unlocked_next` en la Ruta. | Comentario + `estado/parcial` |
| #77 | Separar los tres ejes en Estado | **Vigente** | `progress_tab_view.dart` sigue mezclando XP, racha, rango/CEFR y radar (255-365) sin secciones Personaje / Narrativa / Lengua. | Comentario + `estado/pendiente` |
| #78 | SRS de producción y dominio real | **Parcial** | `mastered = production_correct >= 2 AND interval >= 14` (migración `20261019052122:84`) y `card_type` en `srs_flashcard_modal.dart:74`. La producción sigue **auto-evaluada**: no hay `TextField` ni comparación de la respuesta. En prod: 74 tarjetas, 0 dominadas, 68 vencidas. | Comentario + `estado/parcial` |
| #79 | Plan de aprendizaje de 4 semanas | **Vigente** | No existe tabla ni código de plan/bloque (0 coincidencias de `learning_plan`/`weekly_plan`). P-38 (#202/#203) y P-40a (#220) siguen abiertos y no cubren el plan de 4 semanas. | Comentario + `estado/pendiente` |
| #82 | Perfil de 5 competencias con confianza | **Vigente** | No hay perfil por competencia ni nivel de confianza; el radar sigue siendo la única vista (`progress_tab_view.dart:361`). | Comentario + `estado/pendiente` |
| #83 | Validar jefes con fases | **Decisión pendiente (parcialmente superada)** | P-31 (#116, cerrado) ya implementó el jefe con tope de turnos, rúbrica y barra de vida (`boss_exam_rules.dart:40-78`), así que la premisa "no hay presión" es falsa. Las 3 fases lingüísticas (comprender/negociar/resolver) no existen. | Comentario + `estado/decision`; **no cerrar** |
| #84 | Gremio cooperativo como evento programado | **Obsoleto / superado** | P-48 (#133, abierto) decide exactamente esto: pausar u ocultar Gremio hasta masa crítica (recomendación >500 WAU). Mantener #84 duplica la decisión. | **Cerrar** como superado por #133 |
| #137 | Épica del backlog nuevo | **Abierta** | 64 historias `P-xx`: **49 cerradas / 15 abiertas** (P-40a/b, P-43b, P-38 fases 2-3, P-34b/d, P-46 a P-51, P-16, P-07). El cuerpo de la épica dice 17/34: está desactualizado. | Comentario con cifras reales; **no cerrar** |
| #226 | Data Safety y política de privacidad de Play | **Bloqueado por acceso externo** | `privacy_body` en los 3 `.arb` y saneador sin PII (`analytics_taxonomy.dart`); la API de Play no expone el formulario Data Safety. Requiere edición manual en Play Console. | Comentario + `estado/bloqueado` |

## Hallazgos transversales

1. **#52: el trabajo de WebP no está en master.** Se documentó como implementado,
   pero `git log --all -- "*.webp"` no devuelve nada y el árbol solo tiene PNG/JPG.
   El AAB de 78,4 MB no es verificable: no hay artefacto en el worktree. Hay que
   rehacerlo o recuperar la rama.
2. **Deriva de documentación: `retention_events` no existe.** `docs/DATA_MODEL.md:134-139`
   y `docs/architecture.md:119` dicen que los eventos van a `retention_events`;
   producción solo tiene `analytics_events` y el código escribe ahí
   (`retention_analytics.dart:35`). Consecuencia: el embudo de onboarding está a 0.
3. **#34 empeoró, no mejoró.** `conversation_screen.dart` pasó de 1.487 a 2.359
   líneas y `conversation_providers.dart` a 2.886; los tokens siguen casi sin usarse.
4. **La release es el cuello de botella.** Play solo tiene 19 (internal) y 20
   (alpha); el 22 nunca se distribuyó. Eso bloquea #51, los datos de #54, la
   verificación en dispositivo de #58 y la prueba de compra de #64.
5. **#16 está desfasado en su narrativa.** La UI de exportar/borrar ya existe
   (P-10), pero siguen faltando el enlace de privacidad en Settings y una política
   de retención para conversaciones/transcripciones.

## Notas de verificación

- Play Console: `list_releases` de `internal` = 1.0.18+19 y `alpha` = 1.0.19+20;
  `beta` y `production` devolvieron "This Edit has been deleted" (sin release
  legible). No se pudo leer el *App bundle explorer*.
- Supabase: solo consultas `select`; sin DDL.
- `flutter analyze` / `flutter test` no se ejecutaron en esta auditoría: no se
  tocó código de producto.
