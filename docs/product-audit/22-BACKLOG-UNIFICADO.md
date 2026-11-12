# 22 — Programa de mejora 1.1 · Backlog unificado

> **Qué es.** La fusión de tres backlogs que hoy compiten: la auditoría de
> septiembre (issues #1–#45 y `.github/issues/audit-backlog.txt`), el backlog de
> mejoras de octubre (P-01…P-51, issues #86–#136, doc `20-MEJORAS-PROPUESTAS`),
> la auditoría UX de noviembre (UX-01…UX-37, issues #240–#261) y la revisión
> técnica del 11-nov (doc `21-REVISION-TECNICA-2026-11`). Además de las series
> `P0-1…P0-4` (#269–#272) que se abrieron por su cuenta.
>
> **Estado de partida:** 57 issues abiertas, 123 cerradas, 3 épicas
> (#46, #137, #239) y 5 numeraciones distintas. Este documento las reduce a
> **24 historias ejecutables + 8 decisiones** en **5 olas**, con un único
> criterio de prioridad.
>
> **Regla de oro:** una historia = una issue = una rama = un PR.

---

## ⚠️ Aviso de rama (leer antes de nada)

La auditoría del 11-nov (doc 21) se hizo sobre el checkout actual, en la rama
**`fix/sentry-kotlin` (1ee3352, 26-oct), que está 160 commits por detrás de
`master` (66a2362, 30-oct)**.

Eso invalida cinco hallazgos y cambia el alcance de cuatro historias. Estado
real en `master`:

| Hallazgo del doc 21 | Estado en `master` | Corrección |
|---|---|---|
| 15 tablas sin `ENABLE ROW LEVEL SECURITY` | **No se sostiene**: `docs/runbooks/SCHEMA_BASELINE.md` (29-oct) midió 84 tablas, 130 políticas, **0 sin RLS** | SEC-1 pasa a ser un *guard* de regresión, no una migración de cierre |
| `apply_session_rewards` confía en el cliente | **Ya resuelto**: `20261029041017_close_session_server_rewards.sql` la sustituye por `close_session(uuid)` y revoca el `EXECUTE` | SEC-2 se estrecha al vector de **misiones**, que sigue vivo |
| `llm-proxy` sin topes de entrada | **Ya resuelto**: `validation.ts` limita 40 mensajes / 4 000 chars / 24 000 totales | SEC-5 se queda sin ese criterio |
| CORS `*` y `/health` informativo | **Ya resuelto**: CORS solo con `CORS_ALLOWED_ORIGIN`; `/health` → `{ok, ts}` | SEC-5 pierde esos criterios |
| Borrado de cuenta y exportación | **Ya existe**: `delete_my_account`, `export_my_data` y cron `clean-old-logs` | DAT-4 se queda solo con retención de contenido |

**Lo que sigue vigente en `master`** (verificado con `git show master:...`):
`add_aura_xp` con importes del cliente y `GRANT` a `authenticated`;
`claimDailyReward` llamando a `add_gems` (revocada) dentro de un `catch` vacío;
`guard_language_profile` sin guarda en el `delete` + `insert` del cliente;
`fetch` del proxy **sin timeout**; `MANA_CHARGE_MODE` por defecto en
`capability` (un cliente modificado omite la capability `server_mana`);
`insert_own_instances` permite fijar `target_value`/`objective_type`;
`insert_own_rewards` permite forjar `reward_history`.

**Consecuencia operativa:** antes de ejecutar cualquier historia, hacer
`git checkout master` (o rebase) y re-verificar las líneas citadas. El trabajo
sin commitear de esta rama (483 cambios) hay que resolverlo primero o se
perderá en el cambio.

---

## 0. Los cinco problemas raíz

Todo el backlog cuelga de cinco causas; las historias están ordenadas por ellas,
no por síntoma.

| # | Causa raíz | Síntomas que explica |
|---|---|---|
| 1 | **El cliente es autoridad de la economía** | oro/XP/aura acuñables (#269, #271), recompensa diaria muda, `spendGold` mentiroso, misiones falsificables (#266) |
| 2 | **Los fallos se silencian** (`catch (_) {}` ×68) | recompensa perdida, `local_<ts>`, logros vacíos, tienda «vacía» en error, historial no guardado |
| 3 | **Dos verdades por concepto** | currículo Dart vs `scenarios`, dos rachas, dos esquemas de `messages`, tres espacios de ID, tres allowances de maná |
| 4 | **El esquema no es reproducible** | 33 migraciones solo en producción, `db push` prohibido, sin staging, RLS no auditable |
| 5 | **Nadie mide ni bloquea** | CI sin build, 0 tests en dinero/auth, métricas simuladas, i18n al 83 % |

---

## 1. Taxonomía y reglas

**Prefijos de historia**

| Prefijo | Alcance |
|---|---|
| `W0-*` | Parar el sangrado (esta semana) |
| `SEC-*` | Seguridad, RLS, autoridad del servidor |
| `DAT-*` | Esquema, migraciones, currículo, integridad |
| `APP-*` | App: bugs, i18n, accesibilidad, design system |
| `PRD-*` | Producto/retención (requiere decisión, no solo código) |

**Prioridad** — `P0` rompe confianza o dinero · `P1` bloquea una ola
siguiente · `P2` deuda con impacto medible · `P3` cosmético.

**Tamaño** — `S` ≤ 1 día · `M` 2–3 días · `L` 4–8 días (una persona
familiarizada con el código).

**Definición de hecho (todas las historias)**

- [ ] `flutter analyze` sin errores nuevos; `flutter test` verde.
- [ ] Test que falla antes del cambio y pasa después (o justificación escrita).
- [ ] Sin `catch` vacío en la ruta tocada.
- [ ] Textos en `.arb` (`flutter gen-l10n` después).
- [ ] `docs/` actualizado si cambia esquema, contrato o comportamiento.
- [ ] Issue enlazada en el PR y criterios marcados uno a uno.

**Reglas de fusión aplicadas**

1. Un issue que solo aporta criterios a otro se absorbe (no se duplica).
2. Un issue cuya evidencia ya no existe en el código (o cuyo `estado/` es
   `implementado` sin cerrar) se cierra con comentario y enlace.
3. Las series `P0-x`, `UX-xx` y `P-xx` desaparecen como numeración; sobreviven
   como criterios dentro de `SEC/DAT/APP/PRD`.
4. Las épicas #46, #137 y #239 se cierran; su contenido vive aquí.

---

## 2. Mapa de reconciliación

### 2.1 Épicas

| Issue | Acción |
|---|---|
| #46 «Épica auditoría septiembre (legado)» | **Cerrar** → sustituida por este documento |
| #137 «Épica backlog 51 historias» | **Cerrar** → P-01…P-51 cerradas o redistribuidas |
| #239 «UX/UI: plan de corrección» | **Cerrar** → UX-01…37 redistribuidas en APP-3/APP-4/APP-5 |

### 2.2 Historias nuevas (creadas por esta revisión)

| ID | Historia | Origen |
|---|---|---|
| W0-1 | Reconciliar el árbol de trabajo y los assets `.webp` | nuevo (doc 21) |
| W0-2 | Reparar el mojibake de `lib/` y de los datos | nuevo (doc 21) |
| W0-3 | Recompensa diaria como RPC transaccional | nuevo (doc 21) |
| W0-4 | CI que compile el AAB | nuevo (doc 21) |
| W0-5 | Consulta de verificación de RLS y RPC en producción | nuevo (doc 21) |
| W0-6 | Tap muerto de `voice_room_screen` + `@override` duplicados | nuevo (doc 21) |
| W0-7 | `saveMessage`: secuencia en servidor | nuevo (doc 21) |
| SEC-1 | Guard de RLS: ninguna tabla sin política | nuevo (doc 21) |
| SEC-2 | Recompensas de misión sin falsificación | **#266, #269** |
| SEC-3 | `add_aura_xp` sin importes del cliente | nuevo (doc 21) |
| SEC-4 | `guard_language_profile`: guarda en `INSERT` y `DELETE` | nuevo (doc 21) |
| SEC-5 | Cobro de maná y timeout del proxy | #92, #271, #272 |
| SEC-6 | Sacar los prompts del cliente | #270 |
| DAT-1 | Staging y `db reset` reproducible | #101 |
| DAT-2 | Currículo único y fin de los IDs de texto | #202, #203 |
| DAT-3 | Vocabulario de sesión sin N+1 ni traducciones falsas | nuevo (doc 21) |
| DAT-4 | Política de retención de datos | #16 (parcial, absorbido) |
| DAT-5 | Contratos de API y tests de integración | nuevo + #254 (parcial) |
| APP-1 | Errores mudos fuera de la ruta crítica | #32 + doc 21 |
| APP-2 | i18n al 100 % (91 claves activas) | #260 (parcial) + doc 21 |
| APP-3 | Design system: tokens, tipografía, botones, tarjetas | #34, #240, #245–#248, #250, #258 |
| APP-4 | Accesibilidad AA real | #33, #251, #259 |
| APP-5 | Matriz responsive y tests de pantalla | #253, #254 |
| APP-6 | Estados de carga/error/vacío/offline | #32, #255, #256 |
| PRD-1 | Google Sign-In en APK firmado | #61 |
| PRD-2 | RevenueCat antes del paywall y matriz de compra | #64, #72 |
| PRD-3 | SRS de producción | #78 |
| PRD-4 | Una sola progresión (tres ejes) | #77, #82 |
| PRD-5 | Activación: conversación antes de configurar | #75, #54 |
| PRD-6 | Valor premium y margen de IA | #132, #131 |
| PRD-7 | Decisión sobre gremio, contenido y marca | #133, #134, #135, #136, #52 |
| PRD-8 | Release 1.0.21+22 | #51 |

### 2.3 Issues que se absorben y se cierran

| Issue(s) | Entra en | Motivo |
|---|---|---|
| #266, #269 | SEC-2 | #266 es el mismo hallazgo que #269 |
| #271, #272 | SEC-5 | Reparto de la facturación de maná |
| #270 | SEC-6 | Prompts en el cliente |
| #92 | SEC-5 | P-07 = cobro en el proxy |
| #240, #245, #246, #247, #248, #249, #258 | APP-3 | Mismo objeto: tokens y componentes |
| #251, #259 | APP-4 | Semantics y contraste |
| #255, #256 | APP-6 | Error de red pintado como vacío |
| #253, #254 | APP-5 | Matriz responsive + tests de pantalla |
| #260 | APP-2 | Idioma y textos |
| #58 | W0-6 | Los `GlassCard` inertes |
| #16, #226 | DAT-4 | Borrado ya existe (#95); falta retención y Data Safety |
| #101 | DAT-1 | P-16 = baseline y staging |
| #202, #203 | DAT-2 | Fases 2 y 3 de P-38 |
| #136 | APP-1 | Deuda técnica repartida entre APP-1/APP-3 |

### 2.4 Issues que siguen abiertas (se reetiquetan, no se duplican)

Producto y decisiones — se quedan como están hasta que haya decisión:
`#75, #76, #77, #78, #79, #82, #83` (ola 4) · `#54` (PRD-5) · `#61` (PRD-1) ·
`#64, #72` (PRD-2) · `#131, #132, #216` (PRD-6) · `#133, #134, #135` (PRD-7) ·
`#51` (PRD-8) · `#52` (cola de PRD-7) · `#197, #199` (PRD-3) · `#42` (cola de
SEC-1).

Estas NO se cierran: son decisiones de producto o trabajo que no cabe en una
historia de ingeniería. Se les añade `ola/4` y se les quita `bloque/` y `fase/`
para que el board no mienta.

### 2.5 Issues que se cierran sin sustituta

| Issue | Motivo |
|---|---|
| #250 | **Ya resuelta**: `mission_card.dart` no existe; la única tarjeta es `QuestCard` (`quest_card.dart:7`) |
| #261 | **No accionable**: remite a 7 entradas de `docs/ui-ux-audit/06-improvement-backlog.md`, documento que no está en el repo ni en el historial |

> **Aviso sobre la auditoría UX.** `docs/ui-ux-audit/` no existe en el árbol ni
> en `git ls-tree HEAD`, pero #239–#261 lo citan como fuente. Varias evidencias
> han derivado (líneas, conteos y hasta archivos inexistentes como
> `HudHeader`, `HudIconButton`, `my_errors_screen`, `weekly_report_screen`).
> Por eso las historias APP-* llevan criterios propios y **no** referencias a
> ese documento: la evidencia se re-verifica en cada PR.

---

## 3. Ola 0 — Parar el sangrado (esta semana)

> Objetivo: que lo que hay publicado no mienta y que el siguiente build sea
> reproducible. Nada de esta ola requiere tocar el pipeline de voz.

### W0-1 · Reconciliar el árbol de trabajo y los assets `.webp`
**P0 · S · sin dependencias**

**Problema.** 483 cambios sin commitear en `fix/sentry-kotlin`: 434 borrados,
26 sin trackear, 23 modificados. Los `.png`/`.jpg` están borrados y sus
reemplazos `.webp` **sin trackear** (`assets/images/avatars/*.webp`,
fondos, `dungeon_guardian.webp`). `rpg_avatar.dart:25` y
`cyber_manhwa_background.dart:122` ya los referencian: un `git add -u`
publica la app sin avatares.

**Criterios**
- [ ] Commit 1: `assets/**/*.webp` nuevos **junto con** los `.png`/`.jpg` que
      sustituyen (mismo commit, nunca separados).
- [ ] Commit 2: borrado de `graphify-out/`, `PlantillaHtml/` y los `.md` de
      estrategia de la raíz.
- [ ] Commit 3: el resto (23 modificaciones + `lib/features/vocabulary/domain/`).
- [ ] `.gitignore`: decidir `.vscode/` y `android/app/upload_certificate.pem`.
- [ ] Verificación: `flutter build apk --debug` y abrir dashboard, conversación
      y perfil (avatares y fondos se pintan).
- [ ] `git status` limpio.

### W0-2 · Reparar el mojibake de `lib/` y de los datos
**P0 · M · sin dependencias**

**Problema.** 66 líneas con doble codificación UTF‑8. No es cosmético: el
diccionario de `conversation_repository_impl.dart:489,494` escribe
`vocabulary_items.translation = 'inglÃ©s'`, y hay respaldos visibles
(`'Â¡SUBIDA DE NIVEL!'`, `'PrÃ¡ctica de ConversaciÃ³n'`).

**Criterios**
- [ ] `conversation_screen.dart`, `hunter_hud_header.dart`,
      `conversation_repository_impl.dart` y el resto de las 66 líneas
      reparadas (no reescritas a mano una a una: revisar con `git diff`).
- [ ] `grep -P 'Ã|â€|Â'` sobre `lib/` = 0 resultados.
- [ ] Script de saneado para las filas ya escritas
      (`vocabulary_items.translation`, `user_vocabulary.translation`),
      ejecutado primero en `SELECT`.
- [ ] `test/l10n_encoding_test.dart` extendido a todo `lib/**` y a
      `supabase/functions/**`.
- [ ] El test falla si se reintroduce un carácter mojibake.

### W0-3 · Recompensa diaria como RPC transaccional
**P0 · M · requiere acceso SQL Editor**

**Problema.** `claimDailyReward` (`economy_repository_impl.dart:182-219`) llama
`add_gems` (revocada), el `catch (_) { return {}; }` se traga el error antes de
marcar `daily_reward_claimed` y el importe se calcula en el cliente.

**Criterios**
- [ ] RPC `claim_daily_reward()` que en una transacción: valide racha, calcule
      gemas/pergaminos en servidor, acredite, marque `daily_reward_claimed` y
      devuelva `{gems, pergaminos}`.
- [ ] Idempotente: dos llamadas el mismo día → la segunda devuelve `already_claimed`.
- [ ] El cliente no calcula importes y muestra el error real si la RPC falla.
- [ ] Test: reclamar dos veces seguidas; saldo sin cambios en la segunda.
- [ ] `@override` duplicado de `:180-181` eliminado.

### W0-4 · CI que compile el AAB
**P0 · S · sin dependencias**

**Problema.** `ci.yml` solo hace `analyze` y `test`. No compila, no publica
cobertura y no cachea. Un release puede romperse con CI verde.

**Criterios**
- [ ] Job `build` que ejecute `flutter build appbundle --debug` en cada PR.
- [ ] `flutter test --coverage` con artefacto publicado.
- [ ] Cache de `~/.pub-cache` y de Gradle.
- [ ] Gate de i18n: falla si `untranslated.json` tiene claves **usadas**.
- [ ] Tiempo total del pipeline < 15 min.

### W0-5 · Consulta de verificación de RLS y RPC en producción
**P0 · S · sin dependencias**

**Problema.** La mitad de los hallazgos de seguridad no son verificables desde
el repo; sin este dato, SEC-1 y SEC-2 se diseñan a ciegas.

**Criterios**
- [ ] Ejecutadas y pegadas en la issue (MCP `supabase`, solo lectura):
      `pg_class.relrowsecurity` de `public`,
      `pg_proc.prosecdef/proacl` de las RPC de economía,
      `information_schema.columns` de `conversations.scenario_id` /
      `lesson_progress.lesson_id`,
      `pg_policies` de `user_subscriptions` y `ai_usage_logs`.
- [ ] Resultado volcado a `docs/product-audit/22-ANEXO-PRODUCCION.md`.
- [ ] Las historias SEC-1/SEC-2 actualizadas con el resultado.

### W0-6 · Tap muerto de `voice_room_screen` + `@override` duplicados
**P0 · S · sin dependencias**

**Problema.** `voice_room_screen.dart:678-680` envuelve un `GlassCard` en un
`GestureDetector`; el chip «TOCA PARA VER DETALLE» no responde. Además hay 8
pares `GlassCard`+`GestureDetector` de los que 1 está roto y 7 duplican `onTap`.

**Criterios**
- [ ] `onTap` pasado al `GlassCard`; `GestureDetector` externo eliminado.
- [ ] Los 8 pares revisados: se queda **solo** el `onTap` del `GlassCard`.
- [ ] `economy_repository_impl.dart:180-181` sin `@override` duplicado.
- [ ] Test de widget: tap en el chip alterna el banner.
- [ ] Cierra #58.

### W0-7 · `saveMessage`: secuencia en servidor
**P1 · S · requiere migración**

**Problema.** `SELECT max(sequence_number)+1` seguido de `INSERT`
(`conversation_repository_impl.dart:420-435`): dos guardados concurrentes
colisionan y la ventana de carrera crece con la latencia.

**Criterios**
- [ ] `sequence_number` con `DEFAULT` de secuencia (o índice único
      `(conversation_id, sequence_number)` + reintento en conflicto).
- [ ] Sin `SELECT` previo en el cliente.
- [ ] Test con dos inserciones concurrentes.

---

## 4. Ola 1 — Autoridad del servidor

> Objetivo: que un cliente modificado no pueda acuñar nada. Es la ola con más
> retorno por hora invertida y desbloquea PRD-6 (margen de IA).

### SEC-1 · Guard de RLS: que ninguna tabla quede sin política
**P1 · S · depende de W0-5**

**Problema.** El baseline del 29-oct midió 84 tablas y **0 sin RLS**, así que el
hallazgo «15 tablas sin RLS» del doc 21 era un falso positivo del checkout
viejo. El riesgo real no es el estado actual: es la deriva. Las migraciones se
aplican a mano en el SQL Editor (33 sin archivo) y nada impide que la siguiente
cree una tabla sin política.

**Criterios**
- [ ] Consulta versionada que falle si alguna tabla de `public` tiene
      `rowsecurity = false` o no tiene ninguna política.
- [ ] Se ejecuta en el mismo sitio que el baseline de DAT-1 (CI o cron).
- [ ] Revisión mensual: política `USING (true)` sobre una tabla de datos de
      usuario → alerta.
- [ ] `docs/DATA_MODEL.md` corregido con los números reales (dice 75 tablas /
      120 políticas; el baseline dice 84 / 130).
- [ ] `#42` (presencia fantasma) revisada como efecto colateral.

### SEC-2 · Recompensas: una sola puerta con evidencia de servidor
**P0 · L · sin dependencias (re-verificar en `master`)**

**Problema.** Hay tres puertas y todas aceptan datos del cliente:
1. **Misiones.** `guard_mission_instance` normaliza `status`/`current_value` en
   el `INSERT` pero **no** `xp_reward`/`gem_reward`/`target_value`/
   `objective_type`/`reward_multiplier`; `claim_mission_reward` paga
   `xp_reward × reward_multiplier` **sin tope**; `advance_my_missions(p_type,
   p_delta)` está `GRANT` a `authenticated` y aplica el delta tal cual.
2. **Drop de sesión.** `claim_session_drop(p_session_id text,
   p_completed_goals)` acepta un id inventado y objetivos declarados: 15 XP +
   10 oro por id nuevo.
3. **Cierre de sesión.** `close_session(uuid)` ya calcula en servidor, pero
   deriva los objetivos de `user_scenario_goals`, que el dueño puede escribir:
   12 metas falsas → 240 min → 2 400 XP + 180 oro + 60 fragmentos.

Absorbe #266 y #269.

**Criterios**
- [ ] `xp_reward`, `gem_reward`, `target_value`, `objective_type` y
      `reward_multiplier` solo desde la plantilla; `INSERT`/`UPDATE` del cliente
      no pueden fijarlos.
- [ ] `claim_mission_reward` con tope por misión y por día.
- [ ] `advance_my_missions` fuera del alcance del cliente (o tope + evidencia
      del evento que lo justifica).
- [ ] `claim_session_drop` exige una sesión existente del usuario y objetivos
      del servidor, no del parámetro.
- [ ] `close_session` deriva objetivos de una fuente no escribible por el
      cliente (ledger de eventos, no `user_scenario_goals`).
- [ ] Tests de abuso: INSERT con recompensa alta, avance repetido, drop con id
      inventado, 12 metas falsas.
- [ ] Consulta de solo lectura de XP anómalo documentada; **reportar, no
      corregir datos**.

### SEC-3 · `add_aura_xp` sin importes del cliente
**P0 · M · depende de SEC-2**

**Problema.** Acredita XP/aura con `p_metas`, `p_bonus_nivel`, `p_radar` del
cliente y mantiene `GRANT EXECUTE` a `authenticated`
(`20260813_mana_aura_redesign.sql:299-338,443`).

**Criterios**
- [ ] Firma sin parámetros de importe; calcula desde el ledger de sesión.
- [ ] `REVOKE EXECUTE ... FROM authenticated`.
- [ ] El cliente deja de enviar `metas`/`bonus`/`radar`.
- [ ] Test: llamada directa con importes → error o 0 efecto.

### SEC-4 · El perfil de progreso: cerrar `INSERT` y `DELETE`
**P0 · L · requiere verificación (W0-5)**

**Problema.** Es el agujero maestro: invalida toda la economía. La política
`profiles_self` es `FOR ALL` sobre `user_language_profiles`
(`audit/02_consolidate_rls_policies.sql:21-22`) y `guard_language_profile` solo
protege el `UPDATE` (en `INSERT` devuelve `new` sin filtrar). Un cliente puede
`DELETE` su fila y `INSERT` otra —o insertar con otro `language_id`— fijando
`xp_points`, `total_gold`, `total_gems`, `aura_xp`, `current_streak` y
`cefr_level_id`. `settings_screen` ya borra la fila para «resetear». Con eso,
SEC-2 y SEC-3 son irrelevantes: el saldo se escribe en un `INSERT`.

**Criterios**
- [ ] `profiles_self` dividida: `SELECT` y `UPDATE` del dueño; `INSERT`/`DELETE`
      solo por RPC (`SECURITY DEFINER`) o `service_role`.
- [ ] En el `INSERT` legítimo de onboarding, saldos/rango/CEFR con valores del
      servidor (el placement real, no el payload).
- [ ] `DELETE` del perfil desde el cliente prohibido; el borrado de cuenta pasa
      por `delete_my_account`.
- [ ] `settings_screen` deja de borrar la fila para «resetear».
- [ ] Test de la secuencia `DELETE` + `INSERT` con saldos inflados → rechazada.
- [ ] `pg_policies` de la tabla pegado en la issue (evidencia de producción).

### SEC-5 · Maná: modo de cobro, reembolso y timeout
**P0 · M · sin dependencias**

**Problema.** El proxy de `master` ya cobra antes del modelo (402 `no_mana`),
valida `action_code`, tiene cuota 30/min *fail-closed*, topa la entrada
(40 mensajes / 4 000 / 24 000 chars), restringe CORS y limpia `/health`. Quedan
cuatro huecos:
1. `MANA_CHARGE_MODE` cae por defecto en `capability`, donde solo se cobra si el
   cliente declara la capability `server_mana`: un cliente modificado la omite y
   usa IA sin maná. Es la causa estructural del 38,7 % facturado a 0 (#271).
2. `refund_failed_turn` es ejecutable por `authenticated`, devuelve el coste de
   cualquier débito de los últimos 5 minutos **sin probar que el turno falló** y
   deduplica por un `ref_id` que elige el cliente: maná gratis indefinido.
3. `consume_mana` sigue con `GRANT` a `authenticated`.
4. El `fetch` a DeepSeek/Groq no tiene `AbortSignal` y no se registran tokens.

Absorbe #92, #271 y #272 (la decisión de producto del turno de gracia se
mantiene aparte, en PRD-6).

**Criterios**
- [ ] `MANA_CHARGE_MODE=all` desplegado (o `capability` eliminada del código),
      con test de cliente que omite la capability → 402.
- [ ] `refund_failed_turn` exige prueba del fallo y un `ref_id` emitido por el
      servidor; tope diario de reembolsos.
- [ ] `consume_mana` revocado de `authenticated` (solo proxy/`service_role`).
- [ ] `AbortSignal.timeout(...)` en las llamadas al proveedor y cierre del SSE
      al desconectar el cliente.
- [ ] Tokens de entrada/salida y latencia registrados en `ai_usage_logs`
      (esto es lo que permite cerrar #271 con datos).

### SEC-6 · Sacar los prompts del cliente
**P0 · M · depende de SEC-5**

**Problema.** #270: 6 prompts viven en `conversation_repository_impl.dart`
(`evaluateGoals` `:223-245`, `evaluateCarismaScore` `:293-302`, etc.). Cualquier
usuario puede extraerlos, alterarlos o pedir `model` distinto. Además un cambio
de prompt exige release.

**Criterios**
- [ ] Prompts en servidor (tabla `prompt_templates` o constante de la función),
      versionados.
- [ ] El cliente envía intención (`evaluate_goals`, `carisma`, `tutor_turn`),
      no el prompt.
- [ ] Versión del prompt registrada con cada evaluación (auditable).
- [ ] Test de contrato por intención.

---

## 5. Ola 2 — Datos e integridad

### DAT-1 · Staging y `db reset` reproducible
**P1 · L · sin dependencias · #101**

**Problema.** El baseline ya existe (`docs/runbooks/SCHEMA_BASELINE.md`, 29-oct:
84 tablas, 130 políticas, 0 sin RLS) y `MIGRATION_STATUS.md` documenta el
historial. Falta lo que de verdad bloquea: un entorno donde `supabase db reset`
produzca ese esquema. Sin él, cualquier migración de este backlog se prueba
contra producción.

**Criterios**
- [ ] `supabase migration repair` para alinear el historial de las 33
      migraciones aplicadas sin archivo.
- [ ] Proyecto de staging (cloud o local con Docker) con datos sintéticos.
- [ ] `supabase db reset` verde en staging y `pg_dump --schema-only` idéntico al
      baseline (diff automatizado).
- [ ] Workflow/runbook de «solo migración revisada»: nada se aplica a mano sin
      archivo previo.
- [ ] Scripts destructivos movidos a `scripts/manual/`.

### DAT-2 · Currículo único y fin de los IDs de texto
**P1 · L · depende de DAT-1 · #202, #203**

**Problema.** Dos currículos (312 KB en Dart vs tabla `scenarios`) y tres
espacios de ID (`scenarios.id` UUID, `conversations.scenario_id` varchar,
`lesson_progress.lesson_id` text). El parche de
`conversation_providers.dart:121-138` solo evita el `SELECT` con texto.

**Criterios**
- [ ] `scenarios` es la fuente; el catálogo Dart queda como semilla offline
      generada, no editada a mano.
- [ ] `scenarios.lesson_key` mapea el ID del catálogo (fase 2 de #202).
- [ ] `conversations.scenario_id` y `lesson_progress.lesson_id` con un solo tipo
      y FK restaurada.
- [ ] Ningún `INSERT` con ID de texto; se elimina el fallback `local_<ts>`.
- [ ] Test de ida y vuelta lección → conversación → reanudar.

### DAT-3 · Vocabulario de sesión sin N+1 ni traducciones falsas
**P1 · M · depende de SEC-6**

**Problema.** Hasta 18 consultas secuenciales por sesión, diccionario de 21
palabras hardcodeado, categoría adivinada por sufijo y `translation = word`
cuando no está (`conversation_repository_impl.dart:442-553`).

**Criterios**
- [ ] RPC/`upsert` único por sesión (≤ 2 round-trips).
- [ ] Traducción real (LLM del turno o tabla `vocabulary_items` compartida).
- [ ] Sin categoría inventada: `part_of_speech` del modelo o `null`.
- [ ] Palabras > 200 caracteres o sin traducción no se guardan.
- [ ] Test: sesión de 10 palabras → ≤ 2 queries.

### DAT-4 · Política de retención de datos
**P1 · M · sin dependencias · #16, #226**

**Problema.** El borrado de cuenta (`delete_my_account`), la exportación
(`export_my_data`) y el cron `clean-old-logs` (90 días sobre logs) ya existen
desde el 18-oct. Lo que falta es la retención del **contenido**: `messages`,
`conversations` y `oracle_turns.answer_transcript` se guardan para siempre, y no
hay enlace a la política de privacidad en la app.

**Criterios**
- [ ] Periodo documentado y aplicado por tabla (`messages`, `conversations`,
      `oracle_turns.answer_transcript`); decisión explícita si es «para siempre».
- [ ] Purga programada que respete el borrado de cuenta ya existente.
- [ ] Play Data Safety coherente con lo anterior.
- [ ] Texto de privacidad enlazado desde Ajustes (y aviso de que las
      transcripciones se envían al LLM).

### DAT-5 · Contratos de API y tests de integración
**P1 · L · depende de DAT-1**

**Problema.** 0 tests en las RPC que mueven dinero, auth y cierre de sesión. El
«test de economía» copia la fórmula (`economy_repository_helpers_test.dart:5-31`).

**Criterios**
- [ ] Contrato por RPC económica contra un cliente falso (parámetros, respuesta,
      error tipado).
- [ ] Test de cierre de sesión completo con fallo inyectado en el paso 3 →
      saldos coherentes o rollback.
- [ ] `asset_manifest_test`: toda ruta `assets/...` de `lib/` existe en disco y
      está declarada en `pubspec.yaml`.
- [ ] Cobertura mínima acordada en `data/` (p. ej. 60 %).

---

## 6. Ola 3 — Calidad percibida

### APP-1 · Política de errores: eliminar los `catch` mudos
**P1 · M · sin dependencias · #32, #136**

**Problema.** 245 `catch`, 68 vacíos de una línea. Devuelven `{}`/`[]`/`false`
y convierten un fallo de red en «no hay datos».

**Criterios**
- [ ] Tipo `AppFailure` (red / auth / datos / cuota) y `debugPrint` obligatorio.
- [ ] `catch` vacío solo en lecturas best-effort **y** con comentario que lo
      justifique; el resto registra y propaga.
- [ ] Lint o test que impida `catch (_) {}` nuevos en `lib/` (regla custom o
      grep en CI).
- [ ] Las 68 ocurrencias actuales revisadas una a una.

### APP-2 · i18n al 100 %
**P1 · M · sin dependencias · #260**

**Problema.** `en` 988 claves, `es`/`pt` 824: faltan **164**, y **91 se usan en
pantalla** (`gen-l10n` rellena con inglés). 443 claves definidas no se usan.

**Criterios**
- [ ] 91 claves activas traducidas en `es` y `pt`; `flutter gen-l10n`.
- [ ] CI falla si hay claves usadas sin traducir.
- [ ] Claves muertas depuradas; `app_translations.dart` (590 líneas) eliminado.
- [ ] Los 467 respaldos `?? 'texto'` sustituidos por claves reales.
- [ ] `test/l10n_encoding_test.dart` cubre también los `.arb` nuevos.

### APP-3 · Design system: tokens, tipografía, botones, tarjetas
**P2 · L · sin dependencias · #34, #240, #245–#250, #258, #261**

**Problema.** ≈300 `EdgeInsets` literales frente a 5 `AppSpacing`; 270
`GoogleFonts.*` frente a 83 `AppTypography`; 61 `Colors.*` y 18 `Color(0x)`
fuera de la paleta; 22 tamaños de fuente distintos con 156 usos por debajo de
12 sp (uno de 7 px en `chat_rooms_screen.dart:1063`); 49 `SnackBar` crudos
frente a 34 `SystemSnack`. `app_theme.dart:22-61` solo define dos estilos de
`TextTheme`, así que `headlineSmall`/`titleSmall`/`bodySmall`/`labelSmall`
caen a Roboto. `RunicButton` no tiene variantes y `AppElevation` tiene 0 usos.
(`QuestCard`/`MissionCard` ya no aplica: ver §2.5.)

**Criterios**
- [ ] `AppSpacing`/`AppTypography`/`AppRadius` cubren ≥ 80 % de los usos.
- [ ] Cero `GoogleFonts.*` fuera de `lib/core/theme/`; lint que lo impida.
- [ ] Un solo `SystemSnack`; cero `SnackBar(` en pantallas.
- [ ] Los 4 estilos que faltan de `TextTheme` definidos; nada por debajo de 11 sp.
- [ ] `AppElevation` en `GlassCard`; radios y opacidad centralizados.
- [ ] Guard en CI: grep de `Colors.`/`fontSize:`/`EdgeInsets.` crudos con
      allow-list.

### APP-4 · Accesibilidad AA real
**P2 · M · depende de APP-3 · #33, #251, #259**

**Problema.** 1 solo `Semantics`; `GlassCard.semanticLabel` nunca se pasa; 26
`IconButton` frente a 6 con `tooltip`; un botón de 24 dp; `runeViolet` 4,38:1 y
`outlineVariant` 1,98:1.

**Criterios**
- [ ] Todo `IconButton` con `tooltip`/`semanticLabel`.
- [ ] Objetivos táctiles ≥ 48 dp.
- [ ] Contraste AA en texto, placeholders y estados deshabilitados.
- [ ] `textScaler` 1.5 y 2.0 en las 14 pantallas sin overflow.
- [ ] Prueba con TalkBack en las 4 pantallas principales.

### APP-5 · Matriz responsive y tests de pantalla
**P2 · M · depende de APP-6 · #253, #254**

**Problema.** 26 `Row` sin `Flexible`/`Expanded` en 16 archivos; los tests de
overflow cubren 5 de 14 pantallas; `ConversationScreen` (2.281 líneas) sin
widget tests.

**Criterios**
- [ ] Test por pantalla a 312 px y `textScaler` 2.0.
- [ ] Widget test de `ConversationScreen` (al menos: montar, enviar, error).
- [ ] Los 26 `Row` corregidos.
- [ ] Goldens estables en CI (hoy dependen de Windows).

### APP-6 · Estados de carga/error/vacío/offline
**P2 · M · depende de APP-1 · #32, #255, #256**

**Problema.** El dashboard muestra `XP 2450 / RACHA 7 / A1` inventados mientras
carga (`dashboard_screen.dart:46-53`); la tienda pinta un error de red como
tienda vacía; `voice_room_screen.dart:421` usa `SizedBox.shrink()` como error.

**Criterios**
- [ ] Widgets `LoadingState`, `ErrorState(retry)`, `EmptyState(action)`.
- [ ] Cero datos de ejemplo en estados de carga.
- [ ] Detección de conectividad y aviso de modo offline.
- [ ] Test de pantalla en error y en vacío.

---

## 7. Ola 4 — Producto y retención (decisiones)

> Estas historias **no se estiman** hasta que producto decida. Cada una lleva la
> decisión explícita que la desbloquea.

| ID | Historia | Decisión que falta | Issues |
|---|---|---|---|
| PRD-1 | Google Sign-In en APK firmado | ninguno técnico: huella SHA-1 de Play App Signing en el cliente OAuth | #61 |
| PRD-2 | RevenueCat antes del paywall + matriz de compra | matriz de dispositivos/cuentas de prueba | #64, #72 |
| PRD-3 | SRS de producción | ¿la cola de repaso entra en la sesión o es pantalla aparte? | #78, #197, #199 |
| PRD-4 | Una sola progresión (tres ejes) | ¿qué representa el nivel del personaje? | #77, #82 |
| PRD-5 | Conversación antes de configurar | ¿se permite probar sin registro? | #75, #54 |
| PRD-6 | Valor premium y margen de IA | presupuesto máximo por usuario activo | #132, #131, #216 |
| PRD-7 | Gremio, contenido y marca | ¿se pausa el gremio hasta masa crítica? ¿marca única? | #133, #134, #135, #136, #52 |
| PRD-8 | Release 1.0.21+22 | checklist de verificación en dispositivo | #51 |

**Para PRD-8 (única que corre ya):** verificar en un dispositivo real, con el
AAB de release, los 5 flujos que las historias de la ola 0–1 tocan: login con
Google, lección completa, recompensa diaria, compra de maná y cierre de sesión
con resumen. Sin eso, la release no sale.

---

## 8. Orden de ejecución

| Semana | Historias | Salida |
|---|---|---|
| **S1** | W0-1, W0-2, W0-4, W0-5, W0-6, W0-7 | Árbol limpio, build reproducible, mojibake fuera, datos de producción consultados |
| **S2** | W0-3, SEC-1, SEC-4 | RLS cerrado, recompensa diaria funcionando |
| **S3–S4** | SEC-2, SEC-3 | Economía con evidencia de servidor |
| **S5** | SEC-5, SEC-6 + DAT-1 (inicio) | Proxy con coste controlado; baseline en marcha |
| **S6–S7** | DAT-1, DAT-2 | Esquema reproducible; currículo único |
| **S8** | DAT-3, DAT-5, APP-1 | Sin N+1; con contratos; errores que se ven |
| **S9** | APP-2, APP-6 | App en español de verdad; estados honestos |
| **S10–S11** | APP-3, APP-4, APP-5 | Design system y accesibilidad |
| **Continuo** | PRD-1…PRD-8 | Según decisión de producto |

**Capacidad asumida:** una persona a tiempo completo. Con dos, SEC y DAT en
paralelo y la ola 0 se cierra en 3 días.

**Paralelizable sin conflicto de archivos:** W0-2 (i18n/textos) ∥ W0-4 (CI) ∥
W0-5 (SQL) ∥ W0-6 (una pantalla). SEC-1 y SEC-4 tocán SQL y no se pisan con
W0-*.

---

## 9. Cómo se aplicó en GitHub

**Estado: aplicado el 11-nov-2026.** Épica [#298](https://github.com/hiulett/TutorSaas/issues/298)
y 24 historias [#274–#297](https://github.com/hiulett/TutorSaas/issues/274).
Mapeo en [`22-issues.json`](22-issues.json). Se cerraron 32 issues: 27
absorbidas, #250 (ya resuelta), #261 (no accionable) y las épicas #46, #137 y
#239. El tablero pasó de 57 a 50 abiertas.

Herramienta: `.github/issues/sync-unified-backlog.ps1`

1. Sin `-Apply` simula; con `-Apply` crea épica + una issue por historia
   (parsea este documento, así que el documento sigue siendo la fuente).
2. `-Apply -CloseAbsorbed` cierra lo que dice la tabla §2.3.
3. Las etiquetas nuevas son `historia` y `ola/0`…`ola/3`.

**No re-ejecutar `-Apply` sin antes vaciar el mapa**: volvería a crear las 24
issues. Para corregir una historia, se edita este documento y se hace
`gh issue edit <n> --body ...` (así se corrigieron SEC-1, SEC-2, SEC-5, DAT-1 y
DAT-4 tras el aviso de rama).

---

## Anexo — Preguntas que bloquean historias

| # | Pregunta | Bloquea |
|---|---|---|
| 1 | ¿Qué es «día practicado» y en qué zona horaria? | SEC-2, PRD-4 |
| 2 | ¿Umbral de aprobado 75 % o 100 %? | DAT-2 |
| 3 | ¿Se permite probar sin registro? | PRD-5 |
| 4 | ¿Qué vende el premium además de maná? | PRD-6 |
| 5 | ¿Se pausa el gremio? | PRD-7 |
| 6 | ¿Pronunciación real o etiquetada como estimación? | PRD-3 |
| 7 | ¿Single-language o multiidioma? | DAT-2 |
| 8 | ¿Presupuesto de IA por usuario activo? | SEC-5, PRD-6 |
| 9 | ¿Proveedor de analítica único (hoy Sentry + `retention_events`)? | APP-6, PRD-6 |
| 10 | ¿Staging en Supabase cloud o local con Docker? | DAT-1 |
