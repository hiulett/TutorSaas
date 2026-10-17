# Registra en las issues los hallazgos de infraestructura obtenidos vía Supabase MCP.
# Uso: powershell -ExecutionPolicy Bypass -File .github/issues/update_findings_infra.ps1

$ErrorActionPreference = "Stop"
$Owner = "hiulett"; $Repo = "TutorSaas"
$ApiBase = "https://api.github.com/repos/$Owner/$Repo"

$Token = $env:GITHUB_TOKEN
if (-not $Token) { $Token = $env:GH_TOKEN }
if (-not $Token) {
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if ($gh) { try { $Token = (& $gh.Source auth token 2>$null) } catch { $Token = $null } }
}
if (-not $Token) { Write-Error "Falta GITHUB_TOKEN o gh autenticado."; exit 1 }

$Headers = @{
    Accept                 = "application/vnd.github+json"
    Authorization          = "Bearer $Token"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"           = "tutorsaas-audit-status"
}
function Invoke-Gh {
    param([string]$Method, [string]$Uri, $Body)
    $p = @{ Method = $Method; Uri = $Uri; Headers = $Headers }
    if ($null -ne $Body) {
        $p.Body = [System.Text.Encoding]::UTF8.GetBytes(($Body | ConvertTo-Json -Depth 10 -Compress))
        $p.ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @p
}

$Comments = @{
13 = @'
### Hallazgo de infraestructura (verificado vía API de Supabase)

`missions-cron` está **desplegada y ACTIVE (v5)** con `verify_jwt = false`.

Es decir: hoy el endpoint que ejecuta `rotate_daily_missions()` con `service_role` **está abierto a cualquiera**, porque el código desplegado es la versión fail-open y además Supabase no exige JWT para invocarla.

El fix de este issue (fail-closed si falta `CRON_SECRET`) está en `supabase/functions/missions-cron/index.ts` pero **no está desplegado**. Pendiente de autorización para desplegar, porque si existe un cron externo que llama sin el secreto, dejaría de rotar misiones.
'@

8 = @'
### Hallazgo de infraestructura (verificado vía API de Supabase)

Funciones desplegadas en el proyecto `sipiumfdpvnszthykyog`:

| Función | Estado |
|---|---|
| `llm-proxy` | ACTIVE v8 |
| `missions-cron` | ACTIVE v5 |
| `livekit-token` | ACTIVE v6 |
| `revenuecat-webhook` | ACTIVE v2 |
| `lesson-generator` | ACTIVE v1 |
| **`stripe-checkout`** | **NO desplegada** |
| **`stripe-webhook`** | **NO desplegada** |

Consecuencia: la compra de maná con Stripe **no puede funcionar en producción** — el cliente invoca `stripe-checkout` y la función no existe. Esto refuerza la decisión del issue: o se migra el maná a la pasarela de la tienda, o se despliegan ambas funciones con secretos configurados.
'@

9 = @'
### Hallazgo de infraestructura (verificado vía API de Supabase)

`llm-proxy` está **ACTIVE en v8** con `verify_jwt = true`, así que la autenticación por JWT sí está desplegada. Lo que sigue sin existir es la cuota: el proxy no consulta maná ni limita peticiones, por lo que un cliente autenticado puede consumir DeepSeek/Groq sin tope.

Los asesores de seguridad de Supabase devuelven **0 avisos**, pero eso no cubre la ausencia de rate limiting en una Edge Function.
'@

10 = @'
### Intento de verificación (fallido)

Se intentó leer el estado real de migraciones y tablas vía Supabase MCP:

```
list_migrations   -> Connection terminated due to connection timeout
list_tables       -> Failed to run sql query: Connection terminated due to connection timeout
```

La API de administración responde (Edge Functions y URL del proyecto sí se obtuvieron), pero el pooler de base de datos no acepta conexión desde esta sesión. Por tanto **el estado aplicado sigue sin verificarse**.

Evidencia necesaria: ejecutar con acceso directo `supabase migration list --linked` y `pg_dump --schema-only`, o revisar `supabase_migrations.schema_migrations` desde el SQL Editor.
'@
}

foreach ($num in ($Comments.Keys | Sort-Object)) {
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/comments" -Body @{ body = $Comments[$num] } | Out-Null
        Write-Host "#${num}: comentario publicado"
    } catch { Write-Warning "fallo al comentar #$num" }
    Start-Sleep -Milliseconds 400
}
Write-Host "Listo."
