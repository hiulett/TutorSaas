# Registra la fase 1 del fix de economía (#3, #4) y el estado de #10.
# Uso: powershell -ExecutionPolicy Bypass -File .github/issues/update_rewards_phase1.ps1

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
4 = @'
### Fase 1 aplicada (RPC de recompensas)

Migración `20261018000000_session_rewards_rpc.sql` **aplicada a producción** (29 migraciones).

Nuevo RPC `apply_session_rewards(p_user_id, p_session_id, p_objectives, p_minutes, p_level_code, p_language_id)`:

- Valida `auth.uid() = p_user_id`.
- Acota `objectives` a 0–12 y `minutes` a 0–240.
- **Calcula los importes en servidor**: `xp = minutes*10`, `gold = objetivos*(10+bonus)`, `fragments = objetivos*(5+bonus)`.
- **Idempotente por `session_id`** mediante `session_reward_ledger` (PK) → un doble cierre no duplica la recompensa.

Cliente adaptado:

- `EconomyRepository.applySessionRewards` (interfaz + impl).
- `endSession` deja de llamar `addFragments`/`addGold` y usa el RPC.
- `logPracticeSession` **deja de sumar XP** en `user_language_profiles` para no duplicar.

Verificado: `flutter analyze` 0 errores, `flutter test` 145/145.

Pendiente (fase 2): los RPC antiguos (`add_xp`, `add_gold`, `add_gems`, `add_fragments`) siguen existiendo y accesibles para no romper versiones antiguas de la app. Se revocan cuando la versión con el nuevo camino esté publicada.
'@

3 = @'
### Fase 1 aplicada; RLS aún sin tocar

Se añadió el camino de servidor para las recompensas (`apply_session_rewards`), de modo que XP, oro y fragmentos ya no dependen de columnas escritas por el cliente **en el flujo nuevo**.

Pero las políticas siguen igual y el bypass continúa siendo posible:

```
user_language_profiles → profiles_self FOR ALL
user_subscriptions     → subscriptions_self FOR ALL
```

No se pueden restringir todavía: la app publicada escribe `xp_points`, `total_gold`, `cefr_level_id` y `game_rank` directamente contra esas tablas. Cerrar RLS antes de publicar una versión que use el RPC dejaría sin guardar el progreso a los 58 usuarios actuales.

Orden de cierre:
1. ✅ RPC + cliente nuevo (hecho).
2. ⏳ Publicar versión con el nuevo camino.
3. ⏳ Restringir RLS por columna y quitar `FOR ALL`.
'@

10 = @'
### Actualización de estado

Tras aplicar la migración de recompensas, el proyecto tiene **29 migraciones registradas** frente a **128 archivos** en el repo.

La brecha no se reduce sola: cada migración nueva sube el contador, pero las 99 restantes siguen sin estar en el historial de la base. Para cerrar este issue hace falta un `pg_dump --schema-only` versionado y comparar tabla por tabla, no seguir parcheando.
'@
}

foreach ($num in ($Comments.Keys | Sort-Object)) {
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/comments" -Body @{ body = $Comments[$num] } | Out-Null
        Write-Host "#${num}: comentario publicado"
    } catch { Write-Warning "fallo al comentar #$num" }
    Start-Sleep -Milliseconds 400
}

# #4 -> parcial
$All = @("estado/implementado", "estado/parcial", "estado/bloqueado", "estado/decision", "estado/pendiente")
foreach ($other in $All) {
    if ($other -eq "estado/parcial") { continue }
    try { Invoke-Gh -Method Delete -Uri "$ApiBase/issues/4/labels/$([uri]::EscapeDataString($other))" | Out-Null } catch {}
}
try {
    Invoke-Gh -Method Post -Uri "$ApiBase/issues/4/labels" -Body @{ labels = @("estado/parcial") } | Out-Null
    Write-Host "#4 -> estado/parcial"
} catch { Write-Warning "no se pudo etiquetar #4" }

Write-Host "Listo."
