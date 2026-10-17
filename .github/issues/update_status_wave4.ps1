# Actualiza el estado de las issues de la oleada 4 (#33, #42).
# Uso: powershell -ExecutionPolicy Bypass -File .github/issues/update_status_wave4.ps1

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

$Status = @{ 33 = "estado/parcial"; 42 = "estado/parcial" }
$All = @("estado/implementado", "estado/parcial", "estado/bloqueado", "estado/decision", "estado/pendiente")

$Comments = @{
33 = @'
**Estado: parcial.**

- **Contraste**: subidos a 60 % los textos que incumplían AA (`welcome_screen` ×3, `profile_edit_screen` ×2, `voice_room_screen` ×3). A 60 % el ratio es ~5,9:1 sobre `voidBg`.
- **Semantics**: añadidos `tooltip` a los 4 `IconButton` de `conversation_screen` (cerrar, objetivos, temas, huella de voz), que no tenían etiqueta.
- **Escalado de texto**: nuevo `test/text_scale_test.dart` que monta `WelcomeScreen`, `DashboardScreen` y `DungeonGuardianScreen` con `textScaler` 1.5 y 2.0 y falla ante overflow.

Pendiente: `Semantics` explícito en el resto de acciones, targets de 40×40 (`session_summary_screen`) y 18 px (`voice_room_screen`), RTL (la app solo soporta en/es/pt, todos LTR) y auditoría con TalkBack/VoiceOver.
'@

42 = @'
**Estado: parcial.**

`getOnlineGuildUsers` filtra ahora por `last_seen_at >= now() - 120 s`, así que los usuarios que cerraron la app dejan de aparecer como conectados. El heartbeat de 30 s ya existía; lo que faltaba era el filtro.

Pendiente: siguen coexistiendo dos sistemas de presencia (`user_presence`, legible solo por admin, y `chat_room_participants`, que alimenta el roster) y no hay job de limpieza programado. Unificar o documentar esa separación queda abierto.
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
