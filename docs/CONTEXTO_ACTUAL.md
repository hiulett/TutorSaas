# Contexto actual del proyecto (traspaso de sesión)

> Lee esto y nada más para empezar. Última actualización: 18-oct-2026, noche.

---

## En una frase

App Android (Flutter + Supabase) de inglés conversacional con capa RPG. El
pipeline de voz, la economía y las compras funcionan. **Lo que falla es que las
misiones no se pueden completar** (#5), así que el bucle de juego no cierra.

---

## Estado

| Dato | Valor |
|---|---|
| Versión | `1.0.21+22` (Android únicamente) |
| Tests / analyze | 155 en verde · 0 errores (36 warnings, 128 infos) |
| AAB / APK | 104,0 MB / 131,9 MB |
| Backend | Supabase `sipiumfdpvnszthykyog` (producción) |
| Issues | 84: 48 implementados · 20 parciales · 12 pendientes · 2 decisión · 1 descartado · 1 epic |
| Último commit | `866ecbc` — 14 docs de estrategia |

---

## Qué se hizo en las últimas sesiones

1. **Auditoría integral** (72 issues) y oleadas de correcciones de cliente y
   servidor: RLS de suscripciones, webhook de RevenueCat, Stripe eliminado,
   fuentes empaquetadas, Maestre de Sesión sin duplicar burbujas, dock que subía
   con el teclado, restaurar compras real.
2. **Fase 2 de estrategia**: 14 documentos en `docs/estrategia_producto/`.
3. **Documentación consolidada**: 268 `.md` → 10 vigentes + `docs/archive/`.

---

## Trabajo abierto

### Pendiente de ti (bloquea al resto)

- **#61** — registrar el SHA-1 `14:13:F7:…:1F:4C` en Google Cloud (consola web).
- **#51** — subir el AAB 1.0.21+22 a *internal testing* de Play.

### Siguiente en la cola (nadie lo ha empezado)

- **#5 (P0)** — conectar el motor de misiones. Evidencia: 533 instancias
  `mission_instances`, todas `active`; `updateProgress` sin llamadores.
  Desbloquea #76, #79 y #74.

### Las 12 historias de la fase 2

`#73` placement en servidor · `#74` evidencia de aprendizaje · `#75` onboarding
invertido · `#76` consecuencia narrativa · `#77` tres ejes · `#78` SRS de
producción · `#79` plan de 4 semanas · `#80` dashboard a 3 indicadores ·
`#81` refuerzo desde errores · `#82` perfil de 5 competencias · `#83`/`#84`
validaciones P3.

---

## Reglas que no se negocian

1. Android únicamente; nada de iOS.
2. Nunca `git checkout -- archivo` ni `git restore` para "arreglar".
3. Los `.arb` se editan **solo** con la herramienta de edición; después
   `flutter gen-l10n`.
4. No tocar el pipeline de voz (record → STT → LLM → TTS).
5. No ejecutar `supabase db push`: el repo no reproduce el esquema
   (`docs/runbooks/MIGRATION_STATUS.md`).

## Trampas conocidas

- `GlassCard` absorbe el tap: pasar `onTap:` al widget, no envolverlo.
- Las funciones que escriben `user_subscriptions` son `SECURITY DEFINER`.
- Los precios viven en RevenueCat/Play, no en `subscription_plans`.

---

## Documentación (no leer toda)

| Necesitas | Archivo |
|---|---|
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
flutter analyze && flutter test     # 0 errores · 155 tests
flutter gen-l10n                    # tras editar un .arb
flutter build appbundle --release
supabase functions deploy <f> --project-ref sipiumfdpvnszthykyog --use-api
```

---

## Cómo continuar en una sesión nueva

```
Lee docs/CONTEXTO_ACTUAL.md y continúa con el issue #5.
```

Eso es todo el contexto necesario. Si el trabajo es de otro tema, cambia el
número del issue.
