# Registra el hallazgo de que el proyecto Supabase está pausado (INACTIVE).
# Uso: powershell -ExecutionPolicy Bypass -File .github/issues/update_findings_paused.ps1

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
10 = @'
### BLOQUEO REAL: el proyecto Supabase está pausado

```
deploy_edge_function -> Cannot retrieve service for project
                        sipiumfdpvnszthykyog with current status 'INACTIVE'
```

Comprobación adicional desde la red:

```
GET https://sipiumfdpvnszthykyog.supabase.co/rest/v1/    -> ENOTFOUND
GET .../auth/v1/health                                  -> ENOTFOUND
GET .../functions/v1/missions-cron                      -> ENOTFOUND
```

El host ni siquiera resuelve por DNS: Supabase retira el DNS cuando el proyecto se pausa (típico de planes gratuitos tras días sin actividad).

**Consecuencia:** no se puede verificar el esquema, ni desplegar funciones, ni aplicar migraciones mientras el proyecto siga `INACTIVE`. La app desplegada apunta a un backend que no responde.
'@

13 = @'
### Deploy intentado y bloqueado por el estado del proyecto

Se intentó desplegar el fix fail-closed vía Supabase MCP:

```
deploy_edge_function(missions-cron) -> project sipiumfdpvnszthykyog status 'INACTIVE'
```

El código está listo en el repo y commiteado, pero **no se puede desplegar hasta reactivar el proyecto**. Mientras tanto, la versión v5 desplegada sigue con `verify_jwt=false` y lógica fail-open.
'@
}

foreach ($num in ($Comments.Keys | Sort-Object)) {
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/comments" -Body @{ body = $Comments[$num] } | Out-Null
        Write-Host "#${num}: comentario publicado"
    } catch { Write-Warning "fallo al comentar #$num" }
    Start-Sleep -Milliseconds 400
}

$epic = @'
## ⚠️ El backend está pausado

El proyecto Supabase `sipiumfdpvnszthykyog` está en estado **`INACTIVE`**.

- `deploy_edge_function` falla: *"Cannot retrieve service for project … with current status 'INACTIVE'"*.
- El host `sipiumfdpvnszthykyog.supabase.co` **no resuelve por DNS**, así que REST, Auth y Functions están caídos.
- No se pueden verificar ni aplicar migraciones, ni desplegar los fixes de Edge Functions.

**Esto bloquea las 15 issues `estado/bloqueado` y convierte el resto en trabajo sin verificación posible.**

Acción necesaria (fuera del repo): reactivar el proyecto en
`https://supabase.com/dashboard/project/sipiumfdpvnszthykyog`

Cuando vuelva a estar `ACTIVE`, el orden previsto es:

1. `list_migrations` + `list_tables` para confirmar el esquema real.
2. Desplegar `missions-cron` fail-closed (#13).
3. Atacar los P0 de RLS y economía (#2, #3, #4, #7).
'@

try {
    Invoke-Gh -Method Post -Uri "$ApiBase/issues/46/comments" -Body @{ body = $epic } | Out-Null
    Write-Host "epic #46 actualizado"
} catch { Write-Warning "fallo al comentar el epic" }

Write-Host "Listo."
