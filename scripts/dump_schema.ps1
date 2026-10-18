# Genera un volcado reproducible del esquema enlazado.
#
# Requiere Docker en marcha: el CLI de Supabase ejecuta pg_dump en un contenedor.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File scripts/dump_schema.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/dump_schema.ps1 -IncludeSystemSchemas

param(
    [string]$PublicOut = "supabase/schema.sql",
    [string]$SystemOut = "supabase/schema_system.sql",
    [switch]$IncludeSystemSchemas
)

$ErrorActionPreference = "Stop"
$env:SUPABASE_NO_TELEMETRY = "1"

$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $repoRoot

if (-not (Test-Path "supabase/.temp/project-ref")) {
    Write-Error "El proyecto no está enlazado. Ejecuta 'supabase link --project-ref <ref>' primero."
    exit 1
}

$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Error "Docker no está instalado. Sin él, 'supabase db dump' no puede ejecutar pg_dump."
    exit 1
}

$dockerInfo = & docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker no está en marcha. Arráncalo y vuelve a intentarlo."
    exit 1
}

Write-Host "Volcando esquema public -> $PublicOut" -ForegroundColor Cyan
supabase db dump --linked --schema public -f $PublicOut

if ($IncludeSystemSchemas) {
    Write-Host "Volcando esquemas de sistema -> $SystemOut" -ForegroundColor Cyan
    supabase db dump --linked --schema auth,storage -f $SystemOut
}

Write-Host "Listo. Revisa los archivos y commitéalos como baseline." -ForegroundColor Green
