<#
.SYNOPSIS
    Sincroniza el backlog unificado (docs/product-audit/22-BACKLOG-UNIFICADO.md)
    con los issues de GitHub.

.DESCRIPTION
    - Sin -Apply: modo simulacion, solo imprime lo que haria.
    - -Apply: crea una issue por historia (W0-*, SEC-*, DAT-*, APP-*).
    - -Apply -CloseAbsorbed: ademas comenta y cierra los issues absorbidos
      (seccion 2.3 del documento). Es la unica parte dificil de deshacer.

    Nota: el script evita caracteres no ASCII a proposito, para que funcione
    igual en Windows PowerShell 5.1 y en PowerShell 7.

.EXAMPLE
    .\.github\issues\sync-unified-backlog.ps1
    .\.github\issues\sync-unified-backlog.ps1 -Apply
    .\.github\issues\sync-unified-backlog.ps1 -Apply -CloseAbsorbed
#>
[CmdletBinding()]
param(
    [string]$Doc = 'docs/product-audit/22-BACKLOG-UNIFICADO.md',
    [string]$MapFile = 'docs/product-audit/22-issues.json',
    [switch]$Apply,
    [switch]$CloseAbsorbed
)

$ErrorActionPreference = 'Stop'

# -- Localizar el repo -------------------------------------------------------
$root = (& git rev-parse --show-toplevel).Trim()
if (-not $root) { throw 'No estas dentro de un repositorio git.' }
Set-Location $root

$docPath = Join-Path $root $Doc
if (-not (Test-Path -LiteralPath $docPath)) { throw "No existe $docPath" }

$lines = Get-Content -LiteralPath $docPath -Encoding UTF8

# -- 1. Extraer historias: "### ID <sep> Titulo" ----------------------------
$stories = [System.Collections.Generic.List[object]]::new()
$current = $null
$body = [System.Text.StringBuilder]::new()

function Flush-Story {
    if ($null -eq $script:current) { return }
    $script:current.Body = $script:body.ToString().Trim()
    $script:stories.Add($script:current)
    $script:current = $null
    [void]$script:body.Clear()
}

foreach ($line in $lines) {
    if ($line -match '^###\s+(?<id>(?:W0|SEC|DAT|APP|PRD)-\d+)\s+(?<title>.+?)\s*$') {
        Flush-Story
        # Quita solo el separador tipografico que sigue al ID (no los backticks).
        $cleanTitle = $Matches.title -replace '^[\s\u00b7\u2022\-]+', ''
        $current = [pscustomobject]@{ Id = $Matches.id; Title = $cleanTitle; Body = '' }
        continue
    }
    if ($line -match '^##\s' -or ($line -match '^###\s' -and $null -ne $current)) {
        Flush-Story
        continue
    }
    if ($null -ne $current) { [void]$body.AppendLine($line) }
}
Flush-Story

if ($stories.Count -eq 0) { throw "No se encontro ninguna historia en $Doc" }

# -- 2. Prioridad, tamano y etiquetas ---------------------------------------
$priorityLabels = @{
    'P0' = 'P0-critico'; 'P1' = 'P1-alto'; 'P2' = 'P2-medio'; 'P3' = 'P3-bajo'
}
$areaByPrefix = @{
    'W0'  = @('area/calidad')
    'SEC' = @('area/backend', 'seguridad')
    'DAT' = @('area/backend', 'deuda-tecnica')
    'APP' = @('area/ux')
    'PRD' = @('area/producto')
}
$waveByPrefix = @{ 'W0' = 'ola/0'; 'SEC' = 'ola/1'; 'DAT' = 'ola/2'; 'APP' = 'ola/3'; 'PRD' = 'ola/4' }

# Excepciones puntuales: las historias de la ola 0 no son todas "calidad".
$areaById = @{
    'W0-1' = @('area/calidad')
    'W0-2' = @('area/backend')
    'W0-3' = @('area/economia', 'area/backend')
    'W0-4' = @('area/calidad')
    'W0-5' = @('area/backend', 'seguridad')
    'W0-6' = @('area/ux')
    'W0-7' = @('area/backend')
}

$labelColors = @{
    'historia' = '1D76DB'; 'ola/0' = 'B60205'; 'ola/1' = 'D93F0B'; 'ola/2' = 'FBCA04'
    'ola/3' = '0E8A16'; 'ola/4' = '5319E7'
}

$plan = foreach ($s in $stories) {
    $prefix = $s.Id.Split('-')[0]

    $priority = 'P1'
    if ($s.Body -match '\*\*(P\d)\s*[*·]\s*([SML])') { $priority = $Matches[1] }

    $labels = [System.Collections.Generic.List[string]]::new()
    $labels.Add('historia')
    if ($priorityLabels.ContainsKey($priority)) { $labels.Add($priorityLabels[$priority]) }
    $areas = if ($areaById.ContainsKey($s.Id)) { $areaById[$s.Id] } else { $areaByPrefix[$prefix] }
    foreach ($l in $areas) { if (-not $labels.Contains($l)) { $labels.Add($l) } }
    if ($waveByPrefix.ContainsKey($prefix)) { $labels.Add($waveByPrefix[$prefix]) }

    $anchor = $s.Id.ToLower() -replace '[^a-z0-9-]', ''

    [pscustomobject]@{
        Id     = $s.Id
        Title  = "[$($s.Id)] $($s.Title)"
        Labels = ($labels -join ',')
        Body   = @"
> Historia del Programa de mejora 1.1 (``docs/product-audit/22-BACKLOG-UNIFICADO.md``, seccion $($s.Id)).

$($s.Body)

---
_Definicion de hecho: ver seccion 1 del backlog unificado._
"@
    }
}

# -- 3. Mapa de issues absorbidos (seccion 2.3) -----------------------------
$absorbed = @{}
$inSection = $false
foreach ($line in $lines) {
    if ($line -match '^###\s+2\.3') { $inSection = $true; continue }
    if ($inSection -and $line -match '^###\s') { break }
    if ($inSection -and $line -match '^\|\s*(?<nums>#\d+[^|]*?)\s*\|\s*(?<story>(?:W0|SEC|DAT|APP)-\d+)') {
        $storyId = $Matches.story
        foreach ($m in [regex]::Matches($Matches.nums, '#(\d+)')) {
            $absorbed[[int]$m.Groups[1].Value] = $storyId
        }
    }
}

# -- 4. Informe / ejecucion -------------------------------------------------
Write-Host ''
Write-Host "Historias detectadas: $($stories.Count)   Issues absorbidos: $($absorbed.Count)" -ForegroundColor Cyan
Write-Host ('-' * 72)

if (-not $Apply) {
    foreach ($p in $plan) {
        Write-Host ("  {0,-6} {1}" -f $p.Id, $p.Title)
        Write-Host ("         labels: {0}" -f $p.Labels) -ForegroundColor DarkGray
    }
    Write-Host ''
    Write-Host 'Modo simulacion. Anade -Apply para crear las issues.' -ForegroundColor Yellow
    return
}

$existing = @((& gh label list --limit 200 --json name | ConvertFrom-Json) | ForEach-Object { $_.name })
foreach ($p in $plan) {
    foreach ($l in $p.Labels.Split(',')) {
        if ($existing -notcontains $l) {
            $color = if ($labelColors.ContainsKey($l)) { $labelColors[$l] } else { 'EDEDED' }
            & gh label create $l --color $color --description 'Programa de mejora 1.1' 2>$null | Out-Null
            Write-Host "  + etiqueta $l" -ForegroundColor DarkGreen
            $existing += $l
        }
    }
}

$created = @{}
foreach ($p in $plan) {
    $url = (& gh issue create --title $p.Title --body $p.Body --label $p.Labels) | Select-Object -Last 1
    $num = if ($url -match '/issues/(\d+)') { [int]$Matches[1] } else { 0 }
    $created[$p.Id] = $num
    Write-Host ("  #{0,-4} {1}" -f $num, $p.Id) -ForegroundColor Green
}

$created | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $root $MapFile) -Encoding UTF8
Write-Host "Mapa guardado en $MapFile" -ForegroundColor DarkGray

if ($CloseAbsorbed) {
    foreach ($issueNum in $absorbed.Keys) {
        $storyId = $absorbed[$issueNum]
        $newNum = $created[$storyId]
        if (-not $newNum) { Write-Host "  ! $storyId sin issue; se omite #$issueNum" -ForegroundColor Yellow; continue }
        $msg = "Consolidada en #$newNum ($storyId) dentro del Programa de mejora 1.1. Ver docs/product-audit/22-BACKLOG-UNIFICADO.md"
        & gh issue comment $issueNum --body $msg | Out-Null
        & gh issue close $issueNum --reason 'not planned' | Out-Null
        Write-Host "  cerrada #$issueNum -> $storyId (#$newNum)" -ForegroundColor DarkYellow
    }
}
else {
    Write-Host 'No se cierra ningun issue (usa -CloseAbsorbed cuando revises el board).' -ForegroundColor Yellow
}
