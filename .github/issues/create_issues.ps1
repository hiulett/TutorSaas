# Crea el backlog de la auditoría como issues de GitHub.
#
# Uso:
#   $env:GITHUB_TOKEN = "<PAT con permiso Issues: Read and write>"
#   powershell -ExecutionPolicy Bypass -File .github/issues/create_issues.ps1 -DryRun
#   powershell -ExecutionPolicy Bypass -File .github/issues/create_issues.ps1
#
# El script es idempotente: si un issue con el mismo título ya existe, lo omite.

param(
    [switch]$DryRun,
    [string]$Owner = "",
    [string]$Repo  = "",
    [string]$BacklogFile = (Join-Path $PSScriptRoot "audit-backlog.txt")
)

# Deriva owner/repo del remoto de git si no se pasan explícitamente.
if (-not $Owner -or -not $Repo) {
    $repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $remote = ""
    try { $remote = (git -C $repoRoot remote get-url origin 2>$null) } catch { $remote = "" }
    if ($remote -match 'github\.com[:/](?<o>[^/]+)/(?<r>[^/]+?)(\.git)?$') {
        if (-not $Owner) { $Owner = $Matches.o }
        if (-not $Repo)  { $Repo  = $Matches.r }
    }
}
if (-not $Owner -or -not $Repo) {
    Write-Error "No se pudo determinar owner/repo. Ejecuta con -Owner <usuario> -Repo <repo>."
    exit 1
}
Write-Host "Destino: $Owner/$Repo" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$ApiBase = "https://api.github.com/repos/$Owner/$Repo"

# ---------------------------------------------------------------- token
$Token = $env:GITHUB_TOKEN
if (-not $Token) { $Token = $env:GH_TOKEN }
if (-not $Token) {
    # Fallback: reutiliza la sesión de GitHub CLI si está instalada y autenticada.
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if ($gh) {
        try { $Token = (& $gh.Source auth token 2>$null) } catch { $Token = $null }
        if ($Token) { Write-Host "Token obtenido de GitHub CLI." -ForegroundColor DarkGray }
    }
}
if (-not $Token -and -not $DryRun) {
    Write-Error "Falta GITHUB_TOKEN (o GH_TOKEN) en el entorno, y 'gh auth token' no devolvió nada. Crea un PAT con permiso 'Issues: Read and write' sobre $Owner/$Repo."
    exit 1
}
$Headers = @{
    Accept               = "application/vnd.github+json"
    Authorization        = "Bearer $Token"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"         = "tutorsaas-audit-backlog"
}

function Invoke-Gh {
    param([string]$Method, [string]$Uri, $Body)
    $params = @{ Method = $Method; Uri = $Uri; Headers = $Headers }
    if ($null -ne $Body) {
        $json  = $Body | ConvertTo-Json -Depth 10 -Compress
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        $params.Body        = $bytes
        $params.ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @params
}

# ---------------------------------------------------------------- labels
$LabelDefs = @(
    @{ name = "auditoria";      color = "5319e7"; description = "Hallazgo de la auditoría integral" },
    @{ name = "epic";           color = "3e4b9e"; description = "Issue de seguimiento" },
    @{ name = "P0-critico";     color = "b60205"; description = "Bloquea cobrar o perder datos" },
    @{ name = "P1-alto";        color = "d93f0b"; description = "Rompe una promesa del producto" },
    @{ name = "P2-medio";       color = "fbca04"; description = "Mejora relevante" },
    @{ name = "P3-bajo";        color = "0e8a16"; description = "Limpieza / deuda menor" },
    @{ name = "area/backend";   color = "1d76db"; description = "Supabase, SQL, Edge Functions" },
    @{ name = "area/economia";  color = "bfd4f2"; description = "Moneda, tienda, inventario, maná" },
    @{ name = "area/misiones";  color = "c2e0c6"; description = "Motor de misiones" },
    @{ name = "area/aprendizaje"; color = "d4c5f9"; description = "Pedagogía, CEFR, contenido" },
    @{ name = "area/ia";        color = "006b75"; description = "LLM, STT, TTS, prompts" },
    @{ name = "area/ux";        color = "f9d0c4"; description = "Interfaz, accesibilidad, estados" },
    @{ name = "area/negocio";   color = "fef2c0"; description = "Planes, pagos, analítica" },
    @{ name = "area/calidad";   color = "ededed"; description = "Tests, docs, deuda técnica" },
    @{ name = "area/producto";  color = "e99695"; description = "Alcance y decisiones de producto" },
    @{ name = "area/seguridad"; color = "b60205"; description = "Privacidad, borrado de datos, cumplimiento" },
    @{ name = "seguridad";      color = "ee0701"; description = "Vulnerabilidad o privacidad" },
    @{ name = "deuda-tecnica";  color = "c5def5"; description = "Refactor o mantenibilidad" },
    @{ name = "bug";            color = "d73a4a"; description = "Comportamiento incorrecto" },
    @{ name = "mejora";         color = "a2eeef"; description = "Mejora" }
)

# ---------------------------------------------------------------- parse
$raw = [System.IO.File]::ReadAllText((Resolve-Path $BacklogFile), [System.Text.Encoding]::UTF8)
$lines = $raw -split "`r?`n"

$issues = @()
$current = $null
$bodyLines = $null
$field = $null

foreach ($line in $lines) {
    if ($line.Trim() -eq "=== ISSUE ===") {
        $current = [ordered]@{ slug = ""; title = ""; labels = @(); body = "" }
        $bodyLines = New-Object System.Collections.Generic.List[string]
        $field = "meta"
        continue
    }
    if ($null -eq $current) { continue }
    if ($line.Trim() -eq "=== END ===") {
        $current.body = ($bodyLines -join "`n").Trim()
        $issues += $current
        $current = $null
        $bodyLines = $null
        $field = $null
        continue
    }
    if ($field -eq "meta" -and $line -match '^TITLE:\s*(.+)$')        { $current.title = $Matches[1].Trim(); continue }
    if ($field -eq "meta" -and $line -match '^SLUG:\s*(.+)$')         { $current.slug  = $Matches[1].Trim(); continue }
    if ($field -eq "meta" -and $line -match '^LABELS:\s*(.+)$')       {
        $current.labels = $Matches[1].Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        continue
    }
    if ($field -eq "meta" -and $line -match '^BODY:\s*$')             { $field = "body"; continue }
    if ($field -eq "body") { $bodyLines.Add($line) }
}

if ($issues.Count -eq 0) {
    Write-Error "No se pudo parsear ningún issue en $BacklogFile"
    exit 1
}

Write-Host "Issues en el backlog: $($issues.Count)" -ForegroundColor Cyan
foreach ($i in $issues) { Write-Host ("  - [{0}] {1}" -f ($i.labels -join ","), $i.title) }

if ($DryRun) {
    Write-Host "`nDRY RUN: no se ha llamado a la API." -ForegroundColor Yellow
    exit 0
}

# ---------------------------------------------------------------- labels upsert
foreach ($l in $LabelDefs) {
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/labels" -Body $l | Out-Null
        Write-Host "Label creada: $($l.name)"
    } catch {
        $code = $_.Exception.Response.StatusCode.value__
        if ($code -eq 422) { Write-Host "Label ya existe: $($l.name)" -ForegroundColor DarkGray }
        else { Write-Warning "No se pudo crear la label $($l.name): $($_.Exception.Message)" }
    }
}

# ---------------------------------------------------------------- existing titles
$existing = @{}
$page = 1
do {
    $resp = @(Invoke-Gh -Method Get -Uri "$ApiBase/issues?state=all&per_page=100&page=$page")
    foreach ($it in $resp) { if ($it.title) { $existing[$it.title] = $it.number } }
    $page++
} while ($resp.Count -eq 100)

# ---------------------------------------------------------------- create
function New-IssueWithRetry {
    param($Payload)
    $attempt = 0
    while ($true) {
        $attempt++
        try { return (Invoke-Gh -Method Post -Uri "$ApiBase/issues" -Body $Payload) }
        catch {
            $code = 0
            try { $code = $_.Exception.Response.StatusCode.value__ } catch { $code = 0 }
            if ($attempt -lt 3 -and ($code -eq 403 -or $code -eq 429 -or $code -eq 502 -or $code -eq 503)) {
                Write-Host "  HTTP $code, reintento $attempt en $(20 * $attempt)s..." -ForegroundColor Yellow
                Start-Sleep -Seconds (20 * $attempt)
                continue
            }
            throw
        }
    }
}

$created = @()
$skipped = @()
foreach ($i in $issues) {
    if ($existing.ContainsKey($i.title)) {
        $skipped += $i.title
        Write-Host "Ya existe #$($existing[$i.title]): $($i.title)" -ForegroundColor DarkGray
        continue
    }
    $payload = @{
        title  = $i.title
        body   = $i.body + "`n`n---`n_Generado desde la auditoría integral de producto (`docs/auditoria_producto/AUDITORIA_INTEGRAL.md`)._"
        labels = @($i.labels) + @("auditoria")
    }
    try {
        $new = New-IssueWithRetry -Payload $payload
        $created += [pscustomobject]@{ number = $new.number; title = $new.title; url = $new.html_url }
        Write-Host "Creado #$($new.number): $($i.title)" -ForegroundColor Green
        Start-Sleep -Milliseconds 1200
    } catch {
        Write-Warning "Falló la creación de '$($i.title)': $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------- epic
$epicTitle = "[EPIC] Auditoría integral: backlog de pendientes y mejoras"
if (-not $existing.ContainsKey($epicTitle)) {
    $checklist = ($created | Sort-Object number | ForEach-Object { "- [ ] #$($_.number) $($_.title)" }) -join "`n"
    $epicBody = @"
## Objetivo

Seguimiento único de todo lo detectado en la auditoría integral de producto, código y negocio.

Documento fuente: ``docs/auditoria_producto/AUDITORIA_INTEGRAL.md``

## Estado

- Issues creados en esta ejecución: **$($created.Count)**
- Issues ya existentes (omitidos): **$($skipped.Count)**

## Cómo usar este backlog

1. Los ``P0-critico`` bloquean cualquier intento de cobrar o de confiar en los datos.
2. Los ``P1-alto`` rompen una promesa visible del producto.
3. ``P2``/``P3`` son mejora y limpieza y pueden agruparse por hito.

## Backlog

$checklist

## Criterio de cierre del epic

- [ ] Cero issues abiertos con etiqueta ``P0-critico``.
- [ ] ``AGENTS.md`` actualizado y verificado contra el código.
- [ ] ``supabase db reset`` reproducible en un proyecto limpio.
"@
    try {
        $newEpic = Invoke-Gh -Method Post -Uri "$ApiBase/issues" -Body @{
            title  = $epicTitle
            body   = $epicBody
            labels = @("auditoria", "epic", "P1-alto")
        }
        Write-Host "`nEpic creado: #$($newEpic.number) $($newEpic.html_url)" -ForegroundColor Cyan
    } catch {
        Write-Warning "No se pudo crear el epic: $($_.Exception.Message)"
    }
} else {
    Write-Host "`nEl epic ya existe: #$($existing[$epicTitle])" -ForegroundColor DarkGray
}

Write-Host "`nResumen: $($created.Count) creados, $($skipped.Count) omitidos." -ForegroundColor Cyan
$created | Format-Table -AutoSize
