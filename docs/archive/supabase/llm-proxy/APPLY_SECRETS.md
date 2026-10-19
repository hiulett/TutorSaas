# Aplicar secrets al llm-proxy (ejecutar manualmente en Supabase)

> Copia este bloque y ejecútalo en tu terminal (PowerShell o bash) desde cualquier
> directorio. Configura los secrets de la Edge Function `llm-proxy` del proyecto
> `sipiumfdpvnszthykyog` con las claves de DeepSeek y Groq.
>
> IMPORTANTE: estas claves están expuestas en el historial de git (docs/deployment.md).
> Se recomienda ROTARLAS en console.groq.com y platform.deepseek.com antes de
> usarlas en producción. Si ya las rotaste, reemplaza los valores de abajo.

## Paso 0 — Requisitos
# Necesitas el Supabase CLI logueado:
#   supabase login
# (pedirá un access token de https://supabase.com/dashboard/account/tokens)

## Paso 1 — Setear los secrets (una sola línea)
supabase secrets set \
  DEEPSEEK_API_KEY=<tu-clave-deepseek> \
  DEEPSEEK_BASE_URL=https://api.deepseek.com/v1 \
  GROQ_API_KEY=<tu-clave-groq> \
  GROQ_STT_URL=https://api.groq.com/openai/v1/audio/transcriptions \
  --project-ref sipiumfdpvnszthykyog

## Paso 2 — Verificar que quedaron seteados
supabase secrets list --project-ref sipiumfdpvnszthykyog

## Paso 3 — Comprobar que la función los ve (health endpoint)
# Reemplaza <ANON_KEY> con tu anon key del proyecto.
# El health debe responder: {"ok":true,"hasDeepSeek":true,"hasGroq":true}
curl -s https://sipiumfdpvnszthykyog.supabase.co/functions/v1/llm-proxy/health \
  -H "apikey: <ANON_KEY>" \
  -H "Authorization: Bearer <ANON_KEY>"

# ──────────────────────────────────────────────────────────────────────────────
# FORMA ALTERNATIVA (PowerShell, sin curl)
# $anon = "<ANON_KEY>"
# Invoke-WebRequest -Uri "https://sipiumfdpvnszthykyog.supabase.co/functions/v1/llm-proxy/health" `
#   -Headers @{ apikey=$anon; Authorization="Bearer $anon" }
# ──────────────────────────────────────────────────────────────────────────────
