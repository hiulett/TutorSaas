# Contexto actual del proyecto (traspaso de sesión)

> Lee esto y nada más para empezar. Última actualización: **29-oct-2026**,
> verificado contra código, producción y GitHub.

---

## En una frase

App Android (Flutter + Supabase) de inglés conversacional con capa RPG. El
pipeline de voz, la economía, las compras y el bucle de misiones funcionan y
están verificados en producción; lo que queda es **publicar** (`#51`), cerrar
**configuración de Play/Google Cloud** (`#61`, trial de NOBLE) y la deuda de la
épica `#137`.

---

## Estado

| Dato | Valor |
|---|---|
| Versión | `1.0.21+22` (Android únicamente) |
| Commits base | `d75fc29` (merge de `#198`, hold-to-talk) |
| Tests / analyze | **725 en verde** (0 saltadas) · 0 errores, 0 warnings, **126 infos** |
| Backend | Supabase `sipiumfdpvnszthykyog` (producción; no hay staging) |
| Esquema | 89 tablas · 134 políticas RLS (84 tablas) · 98 funciones · 14 vistas · 36 triggers · 3 cron |
| Migraciones | 106 aplicadas; 39 sin archivo en el repo; no ejecutar `supabase db push` |
| Edge Functions | 8 desplegadas y activas |
| Pistas de Play | internal `1.0.18+19` · alpha `1.0.19+20` · beta/production vacías |
| Issues | 152 en total · **40 abiertos** · 112 cerrados |

Cifras y comandos: [INDICE-DOCUMENTACION.md](INDICE-DOCUMENTACION.md).

---

## Qué está hecho y verificado

1. **Voz:** `record` → `llm-proxy /transcribe` (Groq Whisper) →
   `/chat` (DeepSeek SSE) → `flutter_tts`. Hold-to-talk por
   `user_settings.mic_mode_hold_to_talk` (#198).
2. **Maná en servidor** (P-07): cobra `consume_mana` antes del modelo; `402
   no_mana`, `413 payload_too_large` y reembolso con `refund_mana` /
   `refund_failed_turn`.
3. **Economía con sumideros** (P-32): `currency_ledger` idempotente, compras,
   crafteo, freeze de racha (30 gemas, máx. 3) y recompensas de nivel.
4. **Misiones** (#109/#124): progreso solo por triggers `SECURITY DEFINER`;
   `claim_mission_reward` idempotente con contrato `{success, ok, …}`.
5. **Currículo** (P-38 fase 1): criterio único de lección superada
   (`lesson_completion_passed()` + `LessonCompletion.isPassed`). Quedan el
   mapeo `lesson_key` (fase 2, `#202`) y el runtime (fase 3, `#203`).
6. **Planes** (P-44/P-45): activos `plebeyo`, `noble`, `realeza`; DIVINO
   inactivo; diferenciación por capacidad (historial del informe, cosméticos) y
   trial de 7 días de NOBLE configurable en Play.
7. **Comprensión auditiva** (P-30): 3 ejercicios activos en
   `listening_exercises`, audio por TTS y corrección en
   `submit_listening_attempt`.
8. **Correcciones gratuitas en chat libre** (P-40-c, `#222`): `correction_turn`
   con fila inactiva en `ai_action_costs` y en `FREE_ACTIONS` del proxy.

---

## Trabajo abierto (los que bloquean o condicionan)

### Pendiente de configuración, no de código

- **#51** — subir y verificar el AAB `1.0.21+22` en Play.
- **#61** — registrar el SHA-1 de la upload key en Google Cloud (Google
  Sign-In falla en builds firmadas con `ApiException: 10`).
- **Trial de NOBLE** — se crea en Play Console y RevenueCat; runbook en
  `runbooks/TRIAL_NOBLE_P45.md`.
- **#226** — reflejar en Data Safety de Play las métricas agregadas de P-15.

### Deuda de producto y técnica

- **#137** — épica con el resto del backlog de la auditoría (51 historias).
- **#101** — staging y baseline de esquema (`supabase db dump` requiere Docker).
- **#202 / #203** — fases 2 y 3 de P-38 (mapeo de `lesson_key` y runtime sobre
  `scenarios`).
- **#16** — retención de conversaciones y borrado/exportación de cuenta.

Los documentos de `docs/estrategia_producto/` describen el resto como
propuestas; no son hechos.

---

## Reglas que no se negocian

1. Android únicamente; nada de iOS.
2. Nunca `git checkout -- archivo` ni `git restore` para "arreglar".
3. Los `.arb` se editan **solo** con la herramienta de edición; después
   `flutter gen-l10n`.
4. No tocar el pipeline de voz (record → STT → LLM → TTS).
5. No ejecutar `supabase db push`: el repo no reproduce el esquema
   (`docs/runbooks/MIGRATION_STATUS.md`).
6. Las claves de IA viven como secretos de `llm-proxy`, nunca en el cliente.

---

## Trampas conocidas

- `GlassCard` absorbe el tap: pasar `onTap:` al widget, no envolverlo.
- La escritura de `xp/racha/minutos` desde el cliente la descarta
  `guard_language_profile`.
- El resumen de sesión muestra cifras fijas; la recompensa real viene de
  `close_session` (`session_reward_ledger`).
- Hay dos currículos (Dart y BD): el criterio de "completada" ya es único, pero
  el mapeo de claves no.
- El defecto de `MANA_CHARGE_MODE` es `capability`, no `all` (`validation.ts`).

---

## Documentación (no leer toda)

| Necesitas | Archivo |
|---|---|
| Qué doc es vigente y con qué fuente | `docs/INDICE-DOCUMENTACION.md` |
| Cómo está construido | `docs/ARCHITECTURE.md` |
| Tablas y RLS | `docs/DATA_MODEL.md` |
| Infra, secretos, funciones | `docs/OPERATIONS.md` |
| Publicar | `docs/RELEASE.md` |
| Planes y decisiones | `docs/PRODUCT.md` |
| Estrategia y roadmap | `docs/estrategia_producto/07_ROADMAP_PRIORIZADO.md` |
| Resumen de estrategia | `docs/estrategia_producto/13_RESUMEN_PARA_EL_PROPIETARIO.md` |

`docs/archive/` es histórico: no se mantiene.

---

## Comandos

```sh
flutter analyze && flutter test     # 0 errores/0 warnings · 725 tests
flutter gen-l10n                    # tras editar un .arb
flutter build appbundle --release
supabase functions deploy <f> --project-ref sipiumfdpvnszthykyog --use-api
```

---

## Cómo continuar en una sesión nueva

```
Lee docs/CONTEXTO_ACTUAL.md y continúa con el issue #51.
```

Eso es todo el contexto necesario. Si el trabajo es de otro tema, cambia el
número del issue.
