# Estado real de las historias P-xx (épico de auditoría)

_Auditoría: 29-oct-2026 · contra `master` `995e958` (no contra comentarios ni PRs)_
_Proyecto Supabase: `sipiumfdpvnszthykyog` · consultas de solo lectura_

## Alcance

Issues **abiertos** con etiqueta `auditoria` y título `P-xx`: **8**.

Quedan fuera de este inventario otras fichas `P-xx` abiertas que no llevan la
etiqueta del épico (`#197 P-34d`, `#199 P-34b`, `#202/#203 P-38`, `#216 P-43b`,
`#220 P-40a`, `#221 P-40b`); pertenecen a sus propios épicos.

## Resumen

| Métrica | Valor |
|---|---|
| Historias auditadas | 8 |
| Cerradas | **0** |
| Parciales | 5 |
| Decisión de producto pendiente | 3 |
| No cumplidas | 0 |
| Bloqueadas por acceso externo | 0 (P-16 lo está solo en su parte restante) |

Cerrar un issue exige que **todos** los criterios estén verificados. Ninguna
historia llegó a ese listón: lo más cerca que se estuvo fue P-07 (7 de 8), y el
que falta es precisamente el que cierra el agujero de seguridad.

## Tabla completa

| Issue | Título | Estado real | Evidencia principal | Acción tomada |
|---|---|---|---|---|
| [#92](https://github.com/hiulett/TutorSaas/issues/92) | P-07 — Cobro de maná en el servidor de IA | **Parcial** | Proxy cobra antes del modelo y devuelve 402 (`llm-proxy/index.ts:443-478`), cuota fail-closed (`:357-377`), topes (`validation.ts:11-13`) y allow-list (`index.ts:410-441`). El cliente ya no cobra (5 llamadas declaran `server_mana`). Falta `MANA_CHARGE_MODE=all` + build publicada: no hay release en producción y la última es `1.0.19+20` (alpha) | Comentario con matriz + `estado/parcial` |
| [#101](https://github.com/hiulett/TutorSaas/issues/101) | P-16 — Entorno de staging y baseline de esquema | **Parcial** (resto bloqueado por coste) | `docs/runbooks/SCHEMA_BASELINE.md` existe (recuentos + consulta), y la app acepta `SUPABASE_URL` por `--dart-define` (`api_constants.dart:8-11`). **No hay staging** (`docs/OPERATIONS.md:15`, `list_branches` → 0) ni dump DDL versionado | Comentario + `estado/parcial` |
| [#131](https://github.com/hiulett/TutorSaas/issues/131) | P-46 — Compra de maná opcional | **Decisión pendiente** | Ni SKU de Play ni decisión ratificada. 4 elixires activos con precio, pero `manaPotionsProvider` (`economy_providers.dart:202`) no lo observa nadie; el `.arb:580` afirma que el maná «se adquiere con dinero real». Solo hay recomendación en `PROPUESTA-P44-P48.md:82-88` | Comentario + `estado/decision` |
| [#132](https://github.com/hiulett/TutorSaas/issues/132) | P-47 — Análisis de margen | **Parcial** | Cálculo preliminar en `PROPUESTA-P44-P48.md:90-106`, pero `ai_usage_logs` tiene 9 filas/5 usuarios, no hay informe por usuario (solo `get_weekly_report`), el allowance no se deriva del margen y no hay revisión trimestral | Comentario + `estado/parcial` |
| [#133](https://github.com/hiulett/TutorSaas/issues/133) | P-48 — Decisión sobre gremio y salas | **Decisión pendiente** | La tab de Gremio sigue en el dock (`dashboard_screen.dart:359-366`); misiones de gremio aún cableadas (`mission_repository.dart:554`); sin anfitrión, horarios ni métrica. Recomendación en `PROPUESTA-P44-P48.md:108-114`, no ratificada en `PRODUCT.md` | Comentario + `estado/decision` |
| [#134](https://github.com/hiulett/TutorSaas/issues/134) | P-49 — Pipeline de contenido | **Parcial** | `review_status` existe y `lesson-generator` inserta `draft` (`index.ts:397`), pero **no hay paso de aprobación**; 500/500 escenarios en `approved`; `global_events` con 0 filas; sin métrica de repetición. Intereses ya llegan a la Ruta (`dashboard_repository_impl.dart:118-127`, hecho en P-40) | Comentario + `estado/parcial` |
| [#135](https://github.com/hiulett/TutorSaas/issues/135) | P-50 — Unificar marca | **Decisión pendiente** | Cuatro marcas vivas: «Dungeon of English» (`.arb:5`), «DungeonSpeak» (manifest y Play Store), «tutorsaas» (`pubspec`/`applicationId`), «DungeonsSpeak Pro» (entitlement). El listing además anuncia tres estamentos cuando DIVINO está retirado | Comentario + `estado/decision` |
| [#136](https://github.com/hiulett/TutorSaas/issues/136) | P-51 — Deuda controlada | **Parcial** (2 de 6 bloques) | Dependencias: solo `cupertino_icons` sin import. `micModeHoldToTalk` ya se usa (#198). Persisten `sttUrl`/`ttsUrl` (`api_constants.dart:50-58`), `UserProgress` muerto, 5 pantallas >1.000 líneas (`conversation_screen` 2.280) y lógica de negocio en repositorios | Comentario + `estado/parcial` |

## Detalle por historia

### P-07 (#92) — 7 de 8 criterios

Lo único que falta es desplegar el estado final:

1. Publicar la app con `client_capabilities: ['server_mana']` (ya está en código).
2. Poner `MANA_CHARGE_MODE=all` en los secrets de `llm-proxy`.

El código desplegado (versión 18 de la función) ya contiene `consume_mana`,
`MANA_CHARGE_MODE`, cuota fail-closed y topes de entrada: la brecha es de
**activación**, no de implementación. El valor actual del secret no se puede
leer con las herramientas disponibles (no hay acceso de solo lectura a los
secrets de Edge Functions), así que el criterio 2 queda como no verificable.

Deuda menor: `consume_mana` conserva `EXECUTE` para `anon`/`authenticated`
(el guard interno lo neutraliza) y `consumeMana` quedó como método muerto.

### P-16 (#101) — baseline sí, entorno no

`SCHEMA_BASELINE.md` da recuentos (84 tablas, 13 vistas, 82 funciones, 130
políticas, 98 migraciones) y la consulta para regenerarlos, pero no es un
`supabase db dump`: no existe `supabase/schema.sql`. Sin dump, el baseline
sirve para **comparar**, no para reconstruir. El staging sigue pendiente de
aprobación de coste (la ficha ya lo decía).

### P-46 (#131) — la contradicción más cara de dejar

La BD vende elixires (`elixir_3500` $0.99 … `elixir_14000` $3.99, activos),
los textos dicen que el maná se compra con dinero real y el listing de Play
ofrece «equip elixirs and gems», pero **no hay ningún flujo de compra**: el
provider que lee `mana_potions` no se consume en ninguna pantalla. Hay que
elegir (a) no vender y limpiar la promesa, o (b) vender con un consumible real.

### P-47 (#132) — el análisis existe, el informe no

El documento calcula ≈ $0.00002/turno de mazmorra y ≈ $0.0008/`oracle_eval`,
con margen bruto del 91 % (76 % tras Play) en el peor caso de NOBLE. Es una
muestra de 8-9 llamadas: el propio documento pide ≥ 2 semanas. No hay consulta
reutilizable de coste por usuario ni cadencia de revisión. Faltan además dos
costes externos: precios por país de Play Console y LiveKit.

### P-48 (#133) — recomendación sin ratificar

`PROPUESTA-P44-P48.md` recomienda un camino intermedio (conservar salas de voz,
ocultar misiones de gremio) que no coincide literalmente con (a) ni con (b) de
la ficha y que tampoco está implementado. La tab sigue visible y las misiones
siguen cableadas. Hace falta decisión + ejecución.

### P-49 (#134) — un criterio resuelto por otra historia

La personalización por intereses llegó a la Ruta con P-40/#125, no con esta
historia. Lo propio de P-49 sigue pendiente: revisión humana de `draft`, calendario
de contenido y métrica de repetición.

### P-50 (#135) — decisión antes que código

No se puede «unificar» sin elegir nombre. La restricción dura es el
`applicationId` (`com.tutorsaas.tutorsaas`), que no cambia tras publicar; el
resto (label, textos, listing, entitlement) sí. El listing está además
desactualizado respecto a los planes.

### P-51 (#136) — paraguas demasiado grande

Dos bloques ya resueltos por trabajo posterior (dependencias y
`micModeHoldToTalk`). Los otros cuatro siguen: código muerto (`sttUrl`/`ttsUrl`,
`UserProgress`), `system_ai_settings` sin uso, pantallas monstruosas y lógica de
negocio en repositorios. Conviene trocearla en issues cerrables por separado.

## Sorpresas relevantes

1. **El agujero de P-07 sigue abierto en producción por una variable de
   entorno, no por código.** Todo está implementado y desplegado, pero no hay
   release en producción (la última es `1.0.19+20` en alpha) y el modo por
   defecto (`capability`) no cobra a quien omita `client_capabilities`.
2. **La app promete comprar maná con dinero real y no se puede comprar.** Hay
   elixires activos con precio en BD, texto en los tres idiomas y mención en la
   ficha de Play, pero el provider que los carga no se usa en ninguna pantalla.
3. **El baseline no es un baseline.** `SCHEMA_BASELINE.md` es un recuento de
   métricas, no un volcado DDL: no permitiría recrear el esquema, que es el
   problema que H-16 quería resolver.
4. **(Extra) El listing de Play vende tres estamentos cuando DIVINO está
   retirado**, y la marca del listing («DungeonSpeak») no coincide con la de la
   app («Dungeon of English»).

## Cómo se verificó

- Código: lectura del árbol en `995e958` (`llm-proxy`, `lib/`, `android/`,
  `pubspec.yaml`, `docs/`).
- Datos: MCP `supabase` (solo lectura) — `scenarios.review_status`,
  `mana_potions`, `subscription_plans`, `ai_usage_logs`, `global_events`,
  `system_ai_settings`, definición de `consume_mana`, `cron.job`,
  `information_schema.role_routine_grants`.
- Publicación: MCP `play-console` — tracks `internal/alpha/beta/production`,
  listing `en-US` y `get_app_info`.
- Despliegue: `list_edge_functions` (llm-proxy versión 18) y
  `get_edge_function` (confirmar que el código desplegado incluye las ramas de
  cobro).
