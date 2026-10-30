# Arquitectura

_Actualizado: 18-oct-2026 · verificado contra el código._

---

## 1. Organización

Feature-first con separación por capas dentro de cada feature:

```
lib/
├── app/            router, splash, navegación (resolución de sesión/onboarding)
├── core/
│   ├── ai/         evaluador de placement (LLM)
│   ├── cache/      CachedFutureController + caché en disco
│   ├── constants/  ApiConstants (URLs y claves por dart-define)
│   ├── i18n/       idioma de UI / aprendizaje / explicaciones
│   ├── services/   RevenueCat, analítica, error tracker
│   ├── theme/      colores, tipografía, radios, motion
│   └── widgets/    GlassCard, SegmentedBar, RpgAvatar, CyberManhwaBackground…
├── features/       16 features (abajo)
└── l10n/           ARB + generados (es/en/pt)
```

### Features actuales

| Feature | Responsabilidad |
|---|---|
| `auth` | Sesión Supabase, perfil, Google Sign-In |
| `boss_exam` | Examen de promoción (jefe de nivel), rúbrica y cooldown |
| `chat_rooms` | Salas de voz (LiveKit) y gremio, Maestre de Mesa |
| `conversation` | Pipeline de voz, chat con tutor/Oráculo, evaluación |
| `corrections` | Correcciones por turno y pantalla «Mis errores» |
| `dashboard` | Home, progreso, perfil, ajustes, radar de habilidades |
| `economy` | Maná, oro, inventario, tienda, recompensas |
| `home_widget` | Widget de pantalla de inicio |
| `listening` | Comprensión auditiva: audio TTS + quiz corregido en servidor |
| `missions` | Motor de misiones diarias/semanales |
| `notifications` | Recordatorios locales |
| `onboarding` | Wizard de 4 pasos, test del Oráculo, placement |
| `presence` | Presencia de usuarios en salas (heartbeat + purga) |
| `subscription` | Paywall, RevenueCat, estado premium |
| `vocabulary` | Repaso SM-2 (tarjetas) |
| `weekly_report` | Informe semanal calculado en servidor |

---

## 2. Rutas (`lib/app/router.dart`)

| Ruta | Pantalla |
|---|---|
| `/` | Entrada (splash lógico) |
| `/splash` | Splash con resolución de sesión |
| `/home` | Dashboard con 4 pestañas |
| `/onboarding` | Wizard |
| `/mini-conversation` | Prueba de valor de 60 s |
| `/oracle-test` | Evaluación oral del Oráculo (y `mode=promotion`) |
| `/conversation` | Conversación con el tutor |
| `/listening` | Comprensión auditiva (`exerciseId=<slug>`) |
| `/chat-rooms` | Salón del gremio |
| `/voice-room` | Sala de voz |
| `/dungeon-guardian` | Santuario de Maná (mazmorra) |
| `/shop` | Tienda (oro) |
| `/inventory` | Inventario |
| `/paywall` | Suscripciones |
| `/profile-edit` | Edición de perfil |
| `/summary` | Resumen de sesión |
| `/boss-result` | Resultado del jefe de nivel |
| `/my-errors` | Errores agrupados por tipo |
| `/weekly-report` | Informe semanal |
| `/missions` | Misiones |

El dashboard tiene 4 pestañas: **Mazmorras (0)**, **Gremio (1 → embebe
`ChatRoomsScreen` en modo tab)**, **Estado (2)**, **Config (3)**.

---

## 3. Estado

- `StateNotifierProvider` para lógica con estado mutable (conversación, economía
  cacheada, presencia).
- `FutureProvider(.autoDispose)` para lecturas asíncronas.
- `StateProvider` para valores simples (pestaña activa, flags de UI).
- Invalidación explícita tras mutaciones (`ref.invalidate(...)`).
- `CachedFutureController` + `json_disk_cache` para arranque sin red.

No hay BLoC, Redux, GetX ni `provider` clásico.

---

## 4. Pipeline de voz

```
record (AAC/m4a)  →  llm-proxy /stt (Groq Whisper, language=en)
                  →  llm-proxy /chat (DeepSeek, SSE)
                  →  flutter_tts (on-device, rate 0.48)
```

- La captura de voz usa el paquete `record`. Por defecto es **tap-to-toggle**;
  con `user_settings.mic_mode_hold_to_talk` (#198) pasa a **mantener para
  hablar**: graba al pulsar, envía al soltar y descarta el clip (sin STT) si
  se suelta antes de 300 ms o se arrastra fuera del botón.
- Las claves de IA (DeepSeek/Groq) **nunca** están en el cliente: viven como
  secretos de la Edge Function.
- El streaming se muestra token a token; la evaluación de objetivos se hace con
  una llamada LLM aparte (`evaluateGoals`).
- La evaluación final de placement pide al modelo CEFR, rango y 10 dimensiones
  (listening, speaking, pronunciation, vocabulary, grammar, sentence_structure,
  confidence, fluency, response_time, naturalness).

---

## 5. Servicios transversales

| Servicio | Archivo | Nota |
|---|---|---|
| RevenueCat | `core/services/revenuecat_service.dart` | `configure(userId)` idempotente + `logIn` al cambiar de cuenta; paywall nativo y Customer Center |
| Analítica | `core/services/retention_analytics.dart` | escribe en `retention_events` |
| Error tracker | `core/utils/error_tracker.dart` | inicializado en `main` |
| Evaluador IA | `core/ai/placement_ai.dart` | CEFR + rango + scores |

---

## 6. Tema

- Solo modo oscuro. Paleta en `core/theme/app_colors.dart`:
  `voidBg #05070E`, `manaCyan #00E5FF`, `royalGold #FFC700`, `runeViolet #9D4EDD`,
  `emeraldGreen #00E676`.
- Radios de 4 px (excepciones: avatares y orbes).
- Tipografías **empaquetadas** en `assets/google_fonts/` (Space Grotesk, Inter,
  JetBrains Mono); `google_fonts` no descarga en runtime.
- `GlassCard` es el contenedor estándar. **Su detector interno gana la arena de
  gestos**: cualquier acción de tap debe pasarse como `onTap:` al propio
  `GlassCard`, no envolverlo en un `GestureDetector`.

---

## 7. Internacionalización

- `lib/l10n/app_{en,es,pt}.arb`; `app_en.arb` es la plantilla.
- Tras editar un `.arb`: `flutter gen-l10n` (obligatorio).
- `UserLanguageSettings` separa idioma de UI, de aprendizaje y de explicaciones.
- Preferencias: `SpaceGrotesk` titulares, `Inter` cuerpo, `JetBrainsMono` datos.

---

## 8. Pruebas y calidad

```
flutter analyze → 0 errores, 0 warnings, 127 infos (deprecaciones; no bloquean)
flutter test    → 530 pruebas (0 saltadas)
```

Verificado el 29-oct-2026 (#207). Detalle de la red visual en
`docs/runbooks/QUALITY_TESTS.md`.

Cobertura relevante: modelos de misión, economía, desbloqueo de lecciones,
overflow en pantallas pequeñas, escalado de texto, codificación de ARB,
tipografías empaquetadas y un test de regresión del streaming del Maestre.

CI: `.github/workflows/ci.yml` ejecuta `analyze` + `test`; no hay CD.
