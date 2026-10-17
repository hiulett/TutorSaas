# Actualiza el estado de las issues de la oleada 3 (#35, #44).
# Uso: powershell -ExecutionPolicy Bypass -File .github/issues/update_status_wave3.ps1

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

$Status = @{ 35 = "estado/parcial"; 44 = "estado/parcial" }
$All = @("estado/implementado", "estado/parcial", "estado/bloqueado", "estado/decision", "estado/pendiente")

$Comments = @{
35 = @'
**Estado: parcial.**

Eventos que ahora se emiten (antes documentados y nunca enviados):

| Evento | Dónde | Propiedades |
|---|---|---|
| `app_open` | `app.dart` (una vez por proceso) | — |
| `session_start` | `initSession` | `scenario_id`, `oracle` |
| `session_end` | `endSession` | `turns`, `goals_completed`, `goals_total`, `oracle` |
| `paywall_viewed` | `paywall_screen.dart` | `source` |

`RetentionAnalytics.trackAppOpenOnce` evita duplicados en cada rebuild.

Pendiente (requiere despliegue de webhooks): eventos de compra con `sku`, `amount` y `gateway` en `stripe-webhook` y `revenuecat-webhook`; eventos de onboarding por paso; y latencia/tokens reales por turno.
'@

44 = @'
**Estado: parcial.**

- `test/oracle_conversation_test.dart` ya **no replica** los umbrales: importa `PlacementAiEvaluator.classifyCefrByWordCount`, que se extrajo del `_heuristicFallback` real en `lib/core/ai/placement_ai.dart`. 17 casos sobre el código de producción.
- Eliminado el "benchmark" de latencia simulado (`lib/core/utils/latency_benchmark.dart` + su test) y su arranque en `main.dart`: cuatro `Future.delayed` con `success: true` hardcodeado que no medían nada.

Pendiente: `test/economy_repository_helpers_test.dart` sigue copiando los tramos de recompensa; requiere extraer un helper puro del `EconomyRepositoryImpl` para poder testear el código real. Tampoco hay aún tests de pipeline de voz, RLS ni SM-2.
'@
}

foreach ($num in ($Status.Keys | Sort-Object)) {
    $label = $Status[$num]
    foreach ($other in $All) {
        if ($other -eq $label) { continue }
        try { Invoke-Gh -Method Delete -Uri "$ApiBase/issues/$num/labels/$([uri]::EscapeDataString($other))" | Out-Null } catch {}
    }
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/labels" -Body @{ labels = @($label) } | Out-Null
        Write-Host "#$num -> $label"
    } catch { Write-Warning "No se pudo etiquetar #$num" }

    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/comments" -Body @{ body = $Comments[$num] } | Out-Null
        Write-Host "  comentario publicado"
    } catch { Write-Warning "  fallo al comentar #$num" }
    Start-Sleep -Milliseconds 400
}
Write-Host "Listo."
