# 21 — Revisión técnica (11-nov-2026)

> **Qué es este documento.** No sustituye a los documentos 00–20 (auditoría del
> 25-oct-2026). Es un **delta**: qué sigue abierto, qué se cerró y qué aparece
> nuevo tras los merges de finales de octubre (#86–#98).
>
> **Método.** Lectura estática de `lib/` (140 archivos, 37.012 líneas sin
> generados ni `l10n/`), `supabase/functions/`, `supabase/migrations/`, `test/`,
> `pubspec.yaml`, CI y `git`. **No se ejecutó la app, ni `flutter test`, ni
> `flutter analyze`, ni consultas al proyecto Supabase**: todo lo que depende de
> producción va marcado como *no verificable*.

> ⚠️ **Corrección importante (11-nov, posterior).** Esta medición se hizo sobre
> la rama `fix/sentry-kotlin` (1ee3352, 26-oct), que está **160 commits por
> detrás de `master`** (66a2362, 30-oct). Verificado después con
> `git show master:...`, **cinco hallazgos ya no aplican**: las 15 tablas sin
> RLS (el baseline del 29-oct mide 0), `apply_session_rewards` con importes del
> cliente (sustituida por `close_session`), los topes de entrada del proxy
> (existen), CORS/`/health` (resueltos) y el borrado de cuenta (existe).
> Sigue vigente: `add_aura_xp`, `guard_language_profile` (delete+insert),
> `claimDailyReward`, la falta de timeout del proxy, `MANA_CHARGE_MODE` por
> defecto en `capability`, `insert_own_instances` y `insert_own_rewards`.
> El delta está en [`22-BACKLOG-UNIFICADO.md`](22-BACKLOG-UNIFICADO.md), sección
> «Aviso de rama».

---

## Resumen ejecutivo

| # | Acción | Por qué ahora | Coste |
|---|---|---|---|
| 1 | Commitear por lotes el árbol de trabajo (483 cambios) | Los `.webp` nuevos están *sin trackear* y los `.png` que sustituyen, borrados: un `git add -u` deja la app sin avatares | 1 h |
| 2 | Reparar el mojibake que llega a base de datos | `vocabulary_items.translation` se guarda como `inglÃ©s` | 2 h |
| 3 | Cerrar `apply_session_rewards` / `add_aura_xp` / `guard_language_profile` | El cliente sigue pudiendo acuñar oro, XP y aura | 2–3 d |
| 4 | Un único `claim_daily_reward` en RPC | Hoy la recompensa diaria se pierde en silencio | 1 d |
| 5 | Eliminar los `catch (_) {}` de rutas de escritura | Es la causa raíz de #4 y de media docena de bugs mudos | 1 d |
| 6 | Completar 91 claves de traducción usadas | Un usuario ES/PT ve inglés en pantalla | 4 h |
| 7 | Arreglar el tap muerto de `voice_room_screen.dart:678` | Botón que dice «TOCA PARA VER DETALLE» y no responde | 15 min |
| 8 | Tests de contrato de las RPC económicas y de auth | 0 cobertura justo en el dinero | 2–3 d |
| 9 | Baseline reproducible de la base de datos | 33 migraciones solo existen en producción | 1 sem |
| 10 | CI que compile el AAB | Hoy CI puede estar verde y el release roto | 2 h |

---

## 0. Riesgo inmediato: el árbol de trabajo

`git status` en `fix/sentry-kotlin`:

```
434 archivos borrados · 26 sin trackear · 23 modificados
```

- **434 borrados** incluyen `graphify-out/` (360, correcto: salida generada),
  `PlantillaHtml/` (41), `assets/*.png|jpg` (22) y 10 `.md` de estrategia en la
  raíz.
- **Los 26 sin trackear incluyen los `.webp` que reemplazan a esos `.png`**
  (`assets/images/avatars/*.webp`, fondos, `dungeon_guardian.webp`).
  `rpg_avatar.dart:25-32` y `cyber_manhwa_background.dart:122-155` ya apuntan a
  `.webp`.

**Consecuencia:** commitear con `git add -u` (o un `git commit -a`) publica los
borrados sin los reemplazos → `AssetImage` falla en runtime en avatares, fondos
y guardián. Hay que añadir explícitamente `assets/**/*.webp`.

También sin trackear y **no** cubiertos por `.gitignore`: `.vscode/` (está
comentado a propósito en la línea 24) y `android/app/upload_certificate.pem`.
Decidir si se versionan o se ignoran.

---

## 1. Bugs de usuario (P0)

### 1.1 Mojibake que se persiste en base de datos

`lib/features/conversation/data/repositories/conversation_repository_impl.dart:489,494`

```dart
'english': 'inglÃ©s',
'conversation': 'conversaciÃ³n',
```

Ese diccionario escribe `vocabulary_items.translation` y
`user_vocabulary.translation` (`:500-548`), que la tarjeta SRS muestra al
usuario. El texto queda corrupto en la base de datos, no solo en pantalla.

**Alcance:** 66 líneas con mojibake en `lib/` (doble codificación UTF-8 leída
como Latin-1). Además de los datos, hay literales de respaldo visibles:
`'Â¡SUBIDA DE NIVEL!'` (`hunter_hud_header.dart:159`), `'GuÃ­a de MisiÃ³n'` y
`'PrÃ¡ctica de ConversaciÃ³n'` (`conversation_screen.dart:288,306,795`),
`'InglÃ©s'` (`:480`) y `'Escribe tu mensaje en inglÃ©s...'` (`:1190`).

**Arreglo:** reparar los literales, migrar las filas ya escritas
(`UPDATE ... SET translation = convert_from(convert_to(translation,'LATIN1'),'UTF8')`
acotado a los casos detectados) y **extender `test/l10n_encoding_test.dart` a
`lib/**`**, no solo a los `.arb` — hoy el guardián no cubre el código.

### 1.2 Recompensa diaria que se pierde en silencio

`economy_repository_impl.dart:180-220`

- `add_gems` está revocada para `authenticated` (`harden_economy.sql:70-73`).
  Si la RPC lanza, el `catch (_) { return {}; }` de `:217` se traga el error
  **antes** de marcar `daily_reward_claimed` (`:208-212`): el usuario pulsa
  «reclamar», no recibe nada y la UI no explica nada.
- El importe (gemas y pergaminos) se calcula en el cliente (`:191-196`).
- `@override` duplicado en `:180-181`.

**Arreglo:** una sola RPC `claim_daily_reward()` que valide racha, acredite y
marque el estado **en una transacción**; devolver resultado tipado y pintar el
error.

### 1.3 Tap muerto por la trampa de `GlassCard`

`voice_room_screen.dart:678-680`: un `GestureDetector` externo envuelve un
`GlassCard` para alternar el banner de demo. El detector interno del `GlassCard`
gana la arena de gestos (documentado en `AGENTS.md`): el chip que dice «TOCA
PARA VER DETALLE» no responde. Pasar `onTap:` al `GlassCard`.

### 1.4 `saveMessage` con carrera de secuencia

`conversation_repository_impl.dart:416-439`: `SELECT max(sequence_number)+1` y
después `INSERT`. Dos guardados concurrentes (tutor + usuario) obtienen el mismo
número. Mover la secuencia al servidor (`DEFAULT nextval` o índice único +
`ON CONFLICT`).

### 1.5 Tres espacios de identificadores

`scenarios.id` UUID · `conversations.scenario_id` `varchar` ·
`lesson_progress.lesson_id` `text`. El parche de
`conversation_providers.dart:121-138` solo evita el `SELECT` con clave de texto;
el `INSERT` (`conversation_repository_impl.dart:374`) sigue enviando la clave de
texto y, si la columna es UUID en producción, cae al fallback `local_<ts>`
(`:380-386`) y **el historial no se guarda**. *No verificable* sin consultar el
tipo real en producción.

---

## 2. Seguridad y economía (servidor)

Detalle completo y evidencia en el anexo A. Resumen:

| Sev. | Hallazgo | Evidencia |
|---|---|---|
| Crítico* | 15 tablas se crean sin `ENABLE ROW LEVEL SECURITY` en ninguna migración (`payments`, `corrections`, `daily_stats`, `pronunciation_assessments`, `ai_usage_logs`…) | `20260717000002_rate_limiting.sql:14`, `20261026104553_harden_economy.sql:80` |
| Alto | `apply_session_rewards` paga oro/XP/fragmentos con `p_minutes` (0–240) y `p_objectives` (0–12) del cliente, sin cupo diario | `20261018000000_session_rewards_rpc.sql:99-101` |
| Alto | `add_aura_xp` acredita XP/aura con parámetros del cliente y sigue con `EXECUTE` a `authenticated` | `20260813_mana_aura_redesign.sql:299-338,443` |
| Alto | `guard_language_profile` permite `INSERT` libre y el cliente borra su propia fila | `20261019043716_guard_language_profile.sql:27-29`, `settings_screen.dart:1439` |
| Alto | `spendGold` escribe `total_gold` directo y devuelve `true` aunque el trigger revierta | `economy_repository_impl.dart:527-541` |
| Alto | `llm-proxy` no topa entrada, no pone timeout al `fetch` y la cuota falla abierta | `llm-proxy/index.ts:32-43,156-188` |
| Medio | RPCs de gremio reciben `p_user_id` sin `auth.uid()` (IDOR) | `20260811_security_hardening_guild.sql:29-49` |
| Medio | `/transcribe` parsea el multipart completo antes de comprobar 10 MB | `llm-proxy/index.ts:233-252` |
| Medio | CORS `*` en las 6 funciones; `GET /health` expone configuración | `llm-proxy/index.ts:48-52,112-119` |
| Medio | Fugas de error internas (`String(e)` al cliente) | `llm-proxy/index.ts:147` y 4 funciones más |

\* Crítico si se confirma en producción; **no verificable** desde el repo. La
consulta es una línea:
`select relname, relrowsecurity from pg_class where relnamespace='public'::regnamespace and relkind='r' order by 1;`

**Lo que sí está bien** (y conviene no romper): las 6 Edge Functions validan el
JWT con `auth.getUser()`; `consume_mana`, `check_llm_quota`, `sync_entitlement`
y `claim_mission_reward` están correctamente guardadas; no hay claves de IA en
el repo ni en el historial; `secrets/` y `config.json` están ignorados.

---

## 3. Arquitectura y mantenibilidad

### 3.1 El patrón que causa casi todos los bugs mudos

```
245 bloques catch · 68 vacíos de una línea · 139 con `catch (_)`
```

Esto contradice dos reglas de `AGENTS.md` («toda llamada de red con
`debugPrint`» y «nunca un `catch` vacío»). Un `catch (_) {}` que devuelve `[]`
o `{}` convierte un fallo de red en «no hay datos»: es exactamente lo que
esconde 1.2 y el fallback de `local_<ts>`.

**Propuesta concreta:** tipo `AppFailure` (red / auth / datos / cuota) +
`debugPrint` obligatorio + `ErrorTracker.logError` en escrituras. Regla de
revisión: un `catch` vacío solo se admite en lecturas best-effort y con
comentario que lo justifique.

### 3.2 Fuga de la capa de datos a la presentación

- **41** llamadas `supabase.from(...)` en `presentation/` (12 archivos) frente a
  171 en `data/` (13 archivos).
- **13** usos de `Supabase.instance.client` fuera de `data/`
  (`conversation_providers.dart` ×8, `placement_providers.dart`,
  `hunter_classes_providers.dart`, `welcome_screen.dart`, `voice_room_screen.dart`).
- Existe `supabaseClientProvider` (`auth_providers.dart:6-8`): debería ser el
  único punto de inyección.

Efecto secundario: ninguna de esas rutas es testeable sin un `Supabase.instance`
inicializado, lo que explica la cobertura de tests actual.

### 3.3 Doble currículo y catálogo estático

- `lesson_catalog.dart`: **312 KB / 4.621 líneas** en un literal `static final`;
  `getLessonById` hace hasta 3 barridos lineales con `contains` por subcadena
  (`:4543-4618`) → puede resolver a la lección equivocada.
- `dynamicCatalogCache` es un `static` mutable escrito desde providers y UI, **sin
  `clear()`** (`:4155,4311`) → se mezcla contenido entre usuarios y no tiene cota.
- Dashboard lee `scenarios` con fallback al catálogo Dart
  (`dashboard_repository_impl.dart:226-243`), la Ruta usa solo el catálogo
  (`learning_path_roadmap.dart:101,293`): dos verdades, dos criterios de
  «completada» (R-13 del doc 16, sigue abierto).

### 3.4 Coste de red evitable

`analyzeAndSaveSessionProgress` (`conversation_repository_impl.dart:442-553`)
hace, por sesión, hasta **6 palabras × 3 consultas** = 18 idas y vueltas
secuenciales para poblar vocabulario, con un diccionario de 21 palabras
hardcodeado y la categoría gramatical adivinada por sufijo (`:500-521`):
`-ly → Adverbio`, `-ing → Verbo`, resto → `Sustantivo`. Cuando la palabra no
está en el diccionario guarda `translation = word` (inglés como traducción).

Mejor: RPC única de «vocabulario de sesión» + traducción real (el LLM ya está en
el flujo) + `upsert` con `ON CONFLICT`.

### 3.5 Cierre de sesión no atómico

`conversation_providers.dart:1537,1646,1660,1670` + `session_drop_controller`:
5 escrituras independientes (recompensas, aura, racha, practice log, drop). Un
fallo parcial deja saldos incoherentes sin rollback.

### 3.6 Higiene del proyecto

- `pubspec.yaml:2` → `description: "A new Flutter project."`; el paquete se
  llama `tutorsaas` y la marca oscila entre *Dungeon of English*,
  *DungeonSpeak* y *TutorSaas* (R-28).
- Dependencias congeladas: `flutter_lints ^3` (hay 6), `riverpod 2.5` (hay 3),
  `go_router 14` (hay 17), `fl_chart 0.68`. `hooks_riverpod` + `flutter_hooks`
  están declarados pero no se usan.
- `assets/videos/cinematica.mp4` (2,6 MB) y `assets/images/shop/*` (~4 MB) están
  en git pero fuera del bundle (decisión consciente, `pubspec.yaml:78-80`).
- `.git` = 63,7 MB; árbol de trabajo = 616 MB (incluye `node_modules`,
  `web_admin/dist`, `build/`).
- Deriva de documentación: `AGENTS.md` dice 171 tests / 34 warnings;
  `ARCHITECTURE.md:136-137` dice 155 / 36 warnings / 128 infos;
  `DATA_MODEL.md:127-135` dice 116 migraciones, el recuento actual sin
  `archive/` es 136.

---

## 4. i18n, UI y accesibilidad

- **Paridad ARB rota:** `en` 988 claves, `es` 824, `pt` 824 → **164 claves
  faltan** en ES y PT; **91 de ellas se usan en pantalla**. `gen-l10n` las
  rellena con el texto inglés: un usuario ES ve «SAVE LICENSE REGISTRY»
  (`app_localizations_es.dart:2481`). Además **443 claves definidas no se usan**.
- `lib/core/i18n/app_translations.dart` (590 líneas) y `t()` son código muerto
  que devuelve la clave.
- **Overflow:** 26 `Row` con 2+ `Text` sin `Flexible`/`Expanded` en 16 archivos
  (p. ej. `chat_rooms_screen.dart:291-305`,
  `session_summary_screen.dart:497-524`). Los tests de overflow cubren 5 de 14
  pantallas, y solo 3 con `textScaler`.
- **Accesibilidad:** 1 solo widget con `Semantics` (`runic_button.dart:72`);
  `GlassCard` acepta `semanticLabel` y nunca se pasa; 26 `IconButton` frente a 6
  con `tooltip`; un botón de 24 dp en `session_summary_screen.dart:486`.
- **Contraste:** `runeViolet` da 4,38:1 sobre `voidBg` y 3,58:1 sobre superficie;
  texto a 7 sp con cian al 50 % = 3,78:1; `outlineVariant` 1,98:1.
- **Drift de tokens:** 61 `Colors.*` y 18 `Color(0x…)` fuera de `app_colors`;
  353 `fontSize` literales fuera de `app_typography` (156 por debajo de 12 sp).
- 113 `Text()` con literal y 467 respaldos `?? 'texto'` en 44 archivos.

---

## 5. Pruebas y CI

- 21 archivos / 171 pruebas. **Sin test:** `apply_session_rewards`,
  `consume_mana`, `claim_mission_reward`, `claimDailyReward`,
  `register_practice`, `refund_failed_turn`, `auth_repository_impl`,
  `subscription_repository_impl`/RevenueCat, `conversation_repository_impl`.
  El «test de economía» (`economy_repository_helpers_test.dart:5-31`) **copia la
  fórmula**; no ejecuta el repositorio.
- CI (`.github/workflows/ci.yml`): `analyze` + `test` en Ubuntu. No compila el
  AAB, no publica cobertura, no cachea `~/.pub-cache`, no bloquea warnings y no
  hay CD. Un release puede romperse sin que CI lo detecte (de hecho, el árbol de
  trabajo actual rompería el bundle de assets, y CI no lo vería).

**Tres tests que valen más que veinte:**
1. Contrato de cada RPC económica con un cliente falso que verifique
   parámetros y respuesta.
2. Cierre de sesión completo con fallo inyectado en el paso 3 → saldos
   coherentes o rollback.
3. `asset_manifest_test`: toda ruta `assets/...` de `lib/` existe en disco y
   está declarada en `pubspec.yaml`.

---

## 6. Sigue abierto del audit de octubre

De los 28 riesgos del doc 16, los merges #86–#98 cerraron R-02, R-03, R-04,
R-05, R-06, R-07 (parcial), R-20. Continúan:

- **R-01** el proxy no cobra maná (verify: `llm-proxy` no llama a
  `consume_mana`).
- **R-10** sin medición de coste de IA (`ai_usage_logs` sin instrumentar
  tokens/modelo/latencia).
- **R-12** premium = más maná y nada más.
- **R-16** migraciones no reproducen el esquema (33 aplicadas sin archivo).
- **R-17** sin staging; se prueba contra producción.
- **R-18** sin push/email: no hay canal de retorno.
- **R-19** analítica de 8 eventos, sin navegación.

---

## 7. Plan propuesto

**Semana 1 — parar el sangrado**
1. Commits por lotes (assets `.webp` con sus borrados; después docs/PlantillaHtml;
   después código).
2. Mojibake: literales + filas de BD + test de encoding sobre `lib/`.
3. Tap de `voice_room_screen` + `@override` duplicados + `saveMessage`.
4. Consulta de solo lectura a producción: `relrowsecurity`, `prosecdef` de las
   RPC de economía y tipo real de `conversations.scenario_id`.

**Semana 2 — cerrar la economía**
5. `claim_daily_reward`, `purchase_streak_freeze`, `spend_gold` como RPC.
6. `apply_session_rewards`: minutos desde `practice_sessions`, cupo diario,
   `unique(user_id, ventana)`.
7. `add_aura_xp` sin parámetros de importe + revoke a `authenticated`.
8. `guard_language_profile` también en `INSERT`; prohibir el `DELETE` del perfil
   desde el cliente.

**Semana 3 — calidad sostenible**
9. `AppFailure` + eliminar `catch` vacíos en escrituras.
10. Mover los 41 `from(` de presentación a repositorios; `supabaseClientProvider`
    en todas partes.
11. 91 traducciones + eliminar `app_translations.dart`.
12. Tests de contrato de RPC, cierre de sesión y `asset_manifest_test`.
13. CI: `flutter build appbundle --debug` + `--coverage` + gate de `untranslated.json`.

**Después** (necesita decisión de producto, no solo código): baseline de BD y
staging (R-16/R-17), coste de IA instrumentado (R-10), valor real del premium
(R-12), canal de retorno (R-18).

---

## Anexo A — Evidencia de los hallazgos de servidor

| # | Hallazgo | Evidencia |
|---|---|---|
| 1 | 15 tablas sin `ENABLE ROW LEVEL SECURITY` en migraciones | `20260717000002_rate_limiting.sql:14` cubre solo `api_request_logs`; `20261026104553_harden_economy.sql:80` crea política sobre `ai_usage_logs` sin RLS |
| 2 | `apply_session_rewards` confía en el cliente | `20261018000000_session_rewards_rpc.sql:39-46,67-101` |
| 3 | `add_aura_xp` con importes del cliente | `20260813_mana_aura_redesign.sql:299-338,443` |
| 4 | `guard_language_profile` sin guarda en INSERT | `20261019043716_guard_language_profile.sql:27-29` |
| 5 | RPCs de gremio con `p_user_id` ajeno | `20260811_security_hardening_guild.sql:29-49,242-274,325-333` |
| 6 | `purge_stale_participants`, `grant_next_seat`, `check_token_rate_limit` abiertas | `20260811_security_hardening_guild.sql:287-321,330,345-377` |
| 7 | `llm-proxy` sin tope de entrada ni timeout | `supabase/functions/llm-proxy/index.ts:32-43,156-188` |
| 8 | `/transcribe` parsea antes de validar tamaño | `supabase/functions/llm-proxy/index.ts:233-252` |
| 9 | CORS `*` y `/health` informativo | `llm-proxy/index.ts:48-52,112-119` |
| 10 | `user_subscriptions` con `FOR ALL USING (true)` en script histórico | `full_database_decoupling.sql:217-219` (si se reejecutó después de `20261018234615_restrict_subscription_writes.sql:15-23`, reabre la auto-asignación de plan) |

## Anexo B — Verificación pendiente (requiere MCP `supabase`, solo lectura)

1. `select relname, relrowsecurity from pg_class where relnamespace='public'::regnamespace and relkind='r' order by 1;`
2. `select proname, prosecdef, proacl from pg_proc where pronamespace='public'::regnamespace and proname in ('apply_session_rewards','add_aura_xp','add_gems','spend_gold','claim_mission_reward','add_mana_item','grant_next_seat');`
3. `select column_name, data_type from information_schema.columns where table_name in ('conversations','lesson_progress','scenario_progress') and column_name in ('scenario_id','lesson_id','id');`
4. Estado real de `verify_jwt` por función (`supabase functions list` o dashboard).
