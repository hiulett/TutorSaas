# AGENTS.md — Dungeon of English (TutorSaas)

Guía para agentes que trabajen en este repositorio. La documentación de
referencia está en `docs/`:

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — capas, rutas, pipeline de voz
- [docs/DATA_MODEL.md](docs/DATA_MODEL.md) — tablas, RLS, migraciones
- [docs/OPERATIONS.md](docs/OPERATIONS.md) — entornos, secretos, funciones, cron
- [docs/RELEASE.md](docs/RELEASE.md) — build y publicación
- [docs/PRODUCT.md](docs/PRODUCT.md) — planes, moneda, decisiones
- [docs/HISTORY.md](docs/HISTORY.md) — qué cambió y qué ya no es cierto

---

## Proyecto

App **Android** de inglés conversacional con capa RPG. Voz: `record` (AAC) →
Edge Function `llm-proxy` (Groq Whisper STT, DeepSeek SSE) → `flutter_tts`.
Backend: Supabase (`sipiumfdpvnszthykyog`). Compras: Play Billing + RevenueCat.

**Versión:** `1.0.21+22`. **No hay código de iOS ni debe añadirse.**

---

## Comandos

```sh
flutter analyze     # 0 errores (36 warnings + 128 infos son la línea base)
flutter test        # 155 pruebas
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
- **Rutas:** `go_router`, 14 rutas registradas en `lib/app/router.dart`.
  Toda pantalla nueva debe registrarse ahí.
- **Features:** `auth`, `onboarding`, `conversation`, `chat_rooms`, `dashboard`,
  `economy`, `missions`, `presence`, `subscription`, `vocabulary`.
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

75 tablas, 120 políticas RLS, 52 funciones, 3 jobs de cron.

- La app **solo lee** `user_subscriptions` y `payments`; las escrituras van por
  RPC `SECURITY DEFINER` o service role.
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
