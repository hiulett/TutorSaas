# Actualiza el estado de las issues de la oleada 2 (#22, #34, #37).
# Uso: powershell -ExecutionPolicy Bypass -File .github/issues/update_status_wave2.ps1

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

$Status = @{ 22 = "estado/implementado"; 34 = "estado/parcial"; 37 = "estado/parcial" }
$All = @("estado/implementado", "estado/parcial", "estado/bloqueado", "estado/decision", "estado/pendiente")

$Comments = @{
22 = @'
**Estado: implementado.**

El dashboard tiene ahora una **CTA primaria de práctica** (`_buildPrimaryCta` en `dashboard_screen.dart`) situada por encima del roadmap:

- Muestra la siguiente lección pendiente del nivel del usuario (título, nivel y número de objetivos).
- Un toque abre `/conversation` directamente en esa lección.
- La selección usa `LessonUnlockService.classify(...) == nextAvailable`, la misma regla que el roadmap, así que no puede ofrecer una lección bloqueada.
- Si el nivel está completo, ofrece la primera lección como repaso en lugar de quedarse vacía.

Verificación: `flutter analyze` 0 errores; `flutter test` 142/142.
'@

34 = @'
**Estado: parcial.**

- Eliminado `GoogleFonts.hankenGrotesk` de `conversation_screen.dart` (las dos únicas apariciones, ~líneas 287 y 581). Ahora usa `spaceGrotesk`, dentro de las tres familias permitidas.

Pendiente: quedan ~345 `EdgeInsets` crudos frente a 5 usos de `AppSpacing`, 98 `BorderRadius.circular` literales, 12 hex crudos y 46 `Colors.white*/black*` en `conversation_screen.dart`, la paleta "medieval" paralela, y los god widgets (`settings_screen` 1.540, `conversation_screen` ~1.400, `chat_rooms_screen` 1.294, `voice_room_screen` 1.219).
'@

37 = @'
**Estado: parcial.**

Eliminados 11 archivos sin ningún consumidor (**~1.700 líneas**):

`next_recommended_lesson_hero.dart`, `recommended_lessons_hub.dart`, `lesson_preview_sheet.dart`, `lesson_card.dart`, `practice_heatmap.dart`, `fluency_latency_chart.dart`, `stat_tile.dart`, `hunter_avatar.dart`, `mission_board_skeleton.dart`, `mic_pulse_button.dart`, `system_mana_disruption_screen.dart`.

Se conservaron a propósito:
- `draggable_monster_widget.dart`: **sí se usa** en `conversation_screen.dart:1316` (la auditoría lo daba por muerto; era un falso positivo).
- `srs_flashcard_modal.dart`: se necesita para #24.

Resultado: `flutter analyze` infos 141 → 131, 0 errores; `flutter test` 142/142.

Pendiente: los 19 métodos de repositorio sin llamadores (`mission_repository`, `economy_repository`, `auth_repository`) y las tablas sin función.
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
