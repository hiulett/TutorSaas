# Dungeon of English (TutorSaas)

App Android de práctica de inglés conversacional con una capa de RPG (estética
Isekai/Webtoon y HUD de "Sistema"). El usuario habla, un tutor IA responde por
voz y la app gamifica el progreso con misiones, rangos y maná.

**Estado:** `1.0.21+22` · Android únicamente · en pruebas cerradas de Play.

---

## Stack

| Capa | Tecnología |
|---|---|
| App | Flutter · Dart `^3.11.5` · Material 3 (solo tema oscuro) |
| Estado | `flutter_riverpod` (`StateNotifier`, `FutureProvider`) |
| Navegación | `go_router` (14 rutas) |
| Backend | Supabase (Postgres + Auth + RLS + Realtime + Edge Functions) |
| IA | Edge Function `llm-proxy` → DeepSeek (chat SSE) y Groq Whisper (STT) |
| Voz | `record` (AAC/m4a) + `flutter_tts` (on-device) |
| Compras | Google Play Billing vía RevenueCat |
| Admin | `web_admin/` (React + Vite, cliente Supabase) |

35 dependencias de runtime, 6 de desarrollo.

---

## Arranque rápido

```sh
flutter pub get
copy config.sample.json config.json     # rellena SUPABASE_URL y SUPABASE_ANON_KEY
flutter run -d <device>                 # dispositivo o emulador Android
```

```sh
flutter analyze     # 0 errores es el criterio
flutter test        # 155 pruebas
flutter gen-l10n    # tras editar cualquier .arb
```

Backend y despliegue: [docs/OPERATIONS.md](docs/OPERATIONS.md),
[docs/RELEASE.md](docs/RELEASE.md).

---

## Documentación

| Documento | Contenido |
|---|---|
| [docs/CONTEXTO_ACTUAL.md](docs/CONTEXTO_ACTUAL.md) | **Traspaso**: estado, trabajo abierto y cómo continuar |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Capas, features, rutas, pipeline de voz, estado |
| [docs/DATA_MODEL.md](docs/DATA_MODEL.md) | Tablas, RLS, RPC, migraciones |
| [docs/OPERATIONS.md](docs/OPERATIONS.md) | Entornos, secretos, Edge Functions, cron, webhooks |
| [docs/RELEASE.md](docs/RELEASE.md) | Build, firma, publicación, pruebas de compra |
| [docs/PRODUCT.md](docs/PRODUCT.md) | Planes, moneda, CEFR, decisiones de producto |
| [docs/HISTORY.md](docs/HISTORY.md) | Qué cambió y qué se corrigió de auditorías antiguas |
| [AGENTS.md](AGENTS.md) | Reglas para agentes que trabajen en el repo |

Los documentos antiguos (auditorías, planes de diseño, análisis por fase) están
en [docs/archive/](docs/archive/). No se mantienen: son contexto histórico.

---

## Qué funciona hoy

- Onboarding de 4 pasos con evaluación oral del Oráculo (CEFR + rango).
- Conversaciones de voz 1:1 con los 500 escenarios sembrados.
- Salas de voz del gremio (LiveKit) y texto con Maestre de Mesa (IA).
- Progresión: XP, rachas, misiones diarias, títulos de prestigio.
- Repaso espaciado SM-2 sobre el vocabulario visto.
- Suscripciones con Play Billing + reconciliación servidor.

## Qué falta

- Registrar el SHA-1 del *upload key* en Google Cloud para que funcione Google
  Sign-In en builds locales (issue #61).
- Subir el AAB a Play (issue #51).
- Baseline de migraciones (requiere Docker + contraseña de BD, issue #10).
- Paywall propio en el dashboard de RevenueCat (issue #72).

El detalle vive en el repositorio de issues de GitHub (`hiulett/TutorSaas`).
