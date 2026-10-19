# Aplicar secretos al lesson-generator (ejecutar manualmente)

Configura la Edge Function `lesson-generator` del proyecto
`sipiumfdpvnszthykyog`.

## Paso 0 — Requisitos

```sh
supabase login   # access token de https://supabase.com/dashboard/account/tokens
```

## Paso 1 — Setear secrets

```sh
supabase secrets set \
  SUPABASE_URL=https://sipiumfdpvnszthykyog.supabase.co \
  SUPABASE_ANON_KEY=<tu-anon-key-publica> \
  SUPABASE_SERVICE_ROLE_KEY=<tu-service-role-key> \
  DEEPSEEK_API_KEY=<tu-clave-deepseek> \
  DEEPSEEK_BASE_URL=https://api.deepseek.com/v1 \
  --project-ref sipiumfdpvnszthykyog
```

> `SUPABASE_SERVICE_ROLE_KEY` es el rol de servicio (¡nunca en el cliente!).
> `DEEPSEEK_API_KEY` debe ser la MISMA que usa `llm-proxy`.

## Paso 2 — Desplegar la función

```sh
supabase functions deploy lesson-generator --project-ref sipiumfdpvnszthykyog
```

## Paso 3 — Verificar

```sh
curl -s https://sipiumfdpvnszthykyog.functions.supabase.co/lesson-generator
# → {"ok":true,"hasDeepSeek":true}
```

## Comportamiento

- Autenticación: **JWT del usuario** (Bearer). Sin sesión → 401.
- **Costo**: debita **100 maná** (`lesson_generation` en `ai_action_costs`) ANTES de
  generar, validando el saldo server-side. Si falla la generación, devuelve
  `{ error: 'generation_failed', cost }` y **reembolsa manualmente** (el débito
  ya ocurrió; la app decide si compensar — en la práctica la app llama solo tras
  confirmar que la lección se usó).
- **Reutilización**: si ya existe una lección con el mismo `skill_focus` + nivel
  (+ `parent_id`), se reutiliza (`reused: true`) sin volver a generar.
- **Sub misiones**: inserta con `parent_id` (id de la lección principal) cuando
  se pasa en el request.
- Requiere que el esquema FASE 1 esté aplicado (`skill_focus`, `parent_id` en
  `scenarios`, `ai_action_costs.lesson_generation`).
