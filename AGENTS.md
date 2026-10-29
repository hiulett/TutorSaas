# AGENTS.md — Dungeon of English (TutorSaas)

Guía para agentes que trabajen en este repositorio. La documentación de
referencia está en `docs/`:

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — capas, rutas, pipeline de voz
- [docs/DATA_MODEL.md](docs/DATA_MODEL.md) — tablas, RLS, migraciones
- [docs/OPERATIONS.md](docs/OPERATIONS.md) — entornos, secretos, funciones, cron
- [docs/RELEASE.md](docs/RELEASE.md) — build y publicación
- [docs/PRODUCT.md](docs/PRODUCT.md) — planes, moneda, decisiones
- [docs/HISTORY.md](docs/HISTORY.md) — qué cambió y qué ya no es cierto
- [docs/runbooks/QUALITY_TESTS.md](docs/runbooks/QUALITY_TESTS.md) — tests y red de regresión visual

---

## Proyecto

App **Android** de inglés conversacional con capa RPG. Voz: `record` (AAC) →
Edge Function `llm-proxy` (Groq Whisper STT, DeepSeek SSE) → `flutter_tts`.
Backend: Supabase (`sipiumfdpvnszthykyog`). Compras: Play Billing + RevenueCat.

**Versión:** `1.0.21+22`. **No hay código de iOS ni debe añadirse.**

---

## Comandos

```sh
flutter analyze     # 0 errores · 0 warnings (127 infos son la línea base)
flutter test        # 637 pruebas (0 saltadas)
flutter gen-l10n    # obligatorio tras editar cualquier .arb
dart run build_runner build --delete-conflicting-outputs   # freezed/json
flutter build appbundle --release
```

---

## Reglas que no se negocian

1. **Nunca** uses `git checkout -- <archivo>` ni `git restore` para "arreglar"
   un archivo: se pierde trabajo. Corrige editando.
2. **Los `.arb` se editan solo con la herramienta de edición**, nunca con
   scripts de consola (rompen acentos). Después, `flutter gen-l10n`.
3. El pipeline de voz (record → STT → LLM → TTS) no se altera sin pedido
   explícito.
4. Android únicamente. Nada de rutas, plugins ni configuración de iOS.
5. Las claves de IA viven como secretos de `llm-proxy`; nunca en el cliente.

---

## Arquitectura

- **Estado:** `flutter_riverpod` (`StateNotifierProvider`, `FutureProvider`,
  `StateProvider`). Sin BLoC, Redux ni GetX.
- **Rutas:** `go_router`, 20 rutas registradas en `lib/app/router.dart`.
  Toda pantalla nueva debe registrarse ahí.
- **Features:** `auth`, `onboarding`, `conversation`, `chat_rooms`, `dashboard`,
  `economy`, `missions`, `presence`, `subscription`, `vocabulary`,
  `boss_exam`, `weekly_report`, `corrections`, `listening`.
- **Tema:** solo oscuro, radios de 4 px, paleta en `app_colors.dart`
  (`voidBg`, `manaCyan`, `royalGold`, `runeViolet`, `emeraldGreen`).
- **Tipografía:** empaquetada en `assets/google_fonts/` (Space Grotesk, Inter,
  JetBrains Mono). `google_fonts` no descarga en runtime.
- **i18n:** `lib/l10n/app_{en,es,pt}.arb`; `app_en.arb` es la plantilla.

### Trampa conocida: `GlassCard`

`GlassCard` tiene un `GestureDetector` interno que **gana la arena de gestos**.
Cualquier acción de toque debe pasarse como `onTap:` al propio `GlassCard`; si
se envuelve en un `GestureDetector` externo, el tap no llega. `onLongPress` sí
funciona desde el ancestro.

---

## Base de datos

88 tablas, 134 políticas RLS (sobre 84 tablas), 92 funciones, 14 vistas,
101 migraciones, 3 jobs de cron.
_(Verificado en producción el 29-oct-2026.)_

- La app **solo lee** `user_subscriptions` y `payments`; las escrituras van por
  RPC `SECURITY DEFINER` o service role.
- **Monedas (oro, gemas, fragmentos):** el cliente nunca escribe saldos. Todo
  movimiento pasa por `economy_apply_currency` vía `purchase_cosmetic`,
  `craft_cosmetic`, `purchase_streak_freeze`, `spend_currency` o
  `claim_level_rewards`, y queda en `currency_ledger` (idempotente por
  `(user_id, ref_key)`). Ver `docs/runbooks/ECONOMY_SINKS.md`.
- El plan y el maná se leen de `user_subscriptions`; RevenueCat es la fuente
  para el entitlement, con reconciliación vía `sync-entitlement`.
- **No ejecutes `supabase db push`**: el repo no reproduce el esquema (33
  migraciones se aplicaron desde el SQL Editor). Los cambios se aplican por el
  SQL Editor o MCP y se guardan como archivo con la **versión real** del
  historial. Detalle en `docs/runbooks/MIGRATION_STATUS.md`.

---

## Convenciones

- Archivos `snake_case`; clases `PascalCase`; variables `camelCase`;
  providers terminan en `Provider`.
- `const` siempre que se pueda; nada de `setState` para lógica de negocio.
- Toda llamada de red dentro de `try/catch` con `debugPrint` (incluye el
  mensaje del error, no solo "falló").
- No introducir familias tipográficas nuevas.
- Mensajes de error al usuario: siempre accionables; nunca dejar un `catch`
  vacío que devuelva al login sin explicar.

---

## Estado del backlog

El trabajo vive en los issues de GitHub (`hiulett/TutorSaas`). Los documentos de
`docs/archive/` son históricos: varias de sus conclusiones ya no son ciertas
(ver `docs/HISTORY.md`).

---

## Herramientas del agente

Antes de explorar el repo, lee `docs/CONTEXT_MAP.md` (índice de punteros, no
cargues la auditoría completa).

**Comandos**

| Comando | Cuándo |
|---|---|
| `/build` | Tras editar código: `flutter analyze` (0 errores) |
| `/test` | Antes de commit: 637 pruebas |
| `/review` | Antes de commit: revisión read-only del diff |
| `/db-check` | Si tocas esquema, RLS o RPC |
| `/ui-check` | Si tocas pantallas, estilos o textos |
| `/release` | Antes de compilar el AAB |
| `/audit` | Para refrescar `docs/product-audit/` |

**Subagentes**

| Agente | Uso |
|---|---|
| `explore` | Localizar código sin editar (siempre lo primero) |
| `reviewer` | Revisar el diff sin editar |
| `db-auditor` | Deriva repo ↔ producción, RLS, funciones |
| `design-auditor` | Paleta, tipografía, i18n, overflow |
| `release-captain` | Checklist de release |
| `acceptance` | Verificar criterios con evidencia, no con el reporte del implementador |
| `test-author` | Escribir los tests que faltan sin tocar producción |
| `doc-auditor` | Actualizar `docs/product-audit/` |

**Reglas de evidencia**

- Afirmar algo sobre el esquema o los datos exige consulta de solo lectura al MCP
  `supabase`; el repo no reproduce el esquema.
- No confíes en comentarios ni en `docs/archive/`: verifica contra código.
- Si no puedes comprobarlo, escribe "no verificable" y qué falta.

