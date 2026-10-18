# Registra la decisión tomada en cada issue `estado/decision`.
# Todas las decisiones fueron aprobadas por el propietario el 2026-10-18.

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
    "User-Agent"           = "tutorsaas-decisions"
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

$Decisions = @{
20 = "**Decisión: inglés solo.** El pipeline (STT `en`, TTS `en-US`, prompt *always English*) y el catálogo asumen un único idioma. Multiidioma real se pospone: exigiría parametrizar STT/TTS, prompts y contenido. Siguiente paso: retirar el selector de idioma objetivo y archivar las semillas fr/de/it."
19 = "**Decisión: etiquetar como estimación ahora, medir después.** Las cifras de fluidez y pronunciación se presentarán como estimación (`~`) y no como medición. La latencia real sí se puede medir ya (fin de audio → primer token); la pronunciación requiere análisis de audio."
47 = "**Decisión: 15 por turno + 30 al cerrar.** Implementado: `oracle_turn` en cada turno y `oracle_eval` una sola vez en el cierre. El «primer examen gratis» queda pendiente de definir (¿por usuario o por nivel?)."
8 = "**Decisión: retirar la compra de maná ahora; migrar a la tienda después.** Vender con Stripe en navegador externo es riesgo de expulsión de Play. Siguiente paso: ocultar la pestaña MANÁ y crear productos de consumo en RevenueCat/Play Billing."
36 = "**Decisión: reducir el premium a lo que existe.** La propuesta pasa a ser «más maná y sin límite diario». Se retiran del JSONB las promesas no implementadas (salas prioritarias, misiones premium, títulos SSS, acceso anticipado)."
27 = "**Decisión: retirar gemas y fragmentos de la UI.** Dos monedas sin sumidero son ruido. Se mantiene el oro (tiene tienda) y el XP (ranking). Se ocultan los saldos hasta que exista un uso real."
28 = "**Decisión: curva de nivel simple.** `nivel = 1 + floor(xp / 100)` (provisional) para que el XP signifique algo. Se conserva el XP porque alimenta el leaderboard."
30 = "**Decisión: renombrar a «Santuario de Maná».** Deja de presentarse como combate. Se retira la iconografía de jefe y el copy de «Guardián». Un modo de repaso real queda como proyecto aparte."
41 = "**Decisión: retirar la afirmación «Moderated by AI».** No hay moderación de contenido. Se elimina el copy hasta que exista filtro real + reportes."
43 = "**Decisión: declarar alcance «conversación oral».** El producto no promete lectura, escritura ni comprensión auditiva evaluada. Se ajustan textos de tienda y onboarding. Añadir esas competencias queda como fase posterior."
26 = "**Decisión: catálogo Dart como fuente única.** Es lo que la app ya usa. Las semillas SQL masivas se archivan fuera de `migrations/` y se documenta que la BD no es la fuente del currículo."
40 = "**Decisión: mixta.** Se eliminan del onboarding país y los stats STR/DEX/INT/LUK (no se leen). Se conectan meta diaria e intereses a recomendaciones reales."
}

foreach ($num in ($Decisions.Keys | Sort-Object)) {
    $label = "estado/decision"
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/comments" -Body @{ body = $Decisions[$num] } | Out-Null
        Write-Host "#${num}: decisión registrada"
    } catch { Write-Warning "fallo en #$num" }
    Start-Sleep -Milliseconds 300
}
Write-Host "Listo."
