# Registra la verificación contra la base viva y cierra #13.
# Uso: powershell -ExecutionPolicy Bypass -File .github/issues/update_live_verification.ps1

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
2 = @'
### Confirmado contra la base viva

```
pg_policies · player_inventory
  select_own_inventory | SELECT | auth.uid() = user_id
  (ninguna política INSERT / UPDATE / DELETE)
```

`player_inventory` tiene **0 filas** en producción. Nadie ha podido completar una compra nunca. El bug no es teórico: es el estado actual del sistema.
'@

3 = @'
### Confirmado contra la base viva

```
pg_policies · user_language_profiles
  profiles_self  | ALL | authenticated | auth.uid() = user_id
  admin_all      | ALL | public        | app_metadata.role = 'admin'

pg_policies · user_subscriptions
  subscriptions_self | ALL | authenticated | auth.uid() = user_id
```

Ambas son `FOR ALL` sin `WITH CHECK`, así que el usuario puede escribir su propia suscripción, su saldo de maná, su CEFR y su rango. Sin cambios respecto a lo documentado: el bypass es real en producción.

Datos actuales: 58 usuarios, 10 filas en `user_subscriptions`.
'@

4 = @'
### Confirmado contra la base viva

```
add_gold(p_user_id uuid, p_amount integer)      SECURITY DEFINER
add_xp(p_user_id uuid, p_amount integer)        SECURITY DEFINER
add_gems(p_user_id uuid, p_amount integer)      SECURITY DEFINER
add_fragments(p_user_id uuid, p_amount integer) SECURITY DEFINER
```

Las cuatro están desplegadas con la firma de crédito libre. No validan que el evento haya ocurrido, solo que `p_user_id = auth.uid()`.
'@

10 = @'
### Verificación real del esquema (proyecto reactivado)

```
list_migrations  -> 28 migraciones aplicadas   (el repo tiene 128 archivos)
```

Tablas que el cliente usa y que **no** existen en `supabase/migrations/`, comprobadas en vivo:

| Tabla | Existe en la BD | RLS |
|---|---|---|
| `daily_fluency_stats` | sí | ✅ |
| `user_scenario_goals` | sí | ✅ |
| `user_scenario_phrases` | sí | ✅ |
| `user_scenario_fluency` | sí | ✅ |
| `cefr_recommendation_rules` | sí | ✅ |
| `user_progress` | **no** | — |

Volumen real: 58 usuarios, 58 perfiles, 500 escenarios, 64 conversaciones, 679 mensajes, 12 misiones, 395 eventos de analítica.

Conclusión: el esquema vive en la nube, no en el repo. 5 de las 6 tablas "fantasma" existen; `user_progress` no. Cualquier reconstrucción desde cero pierde eso.
'@

11 = @'
### Confirmado contra la base viva

```
information_schema.columns · messages
  id, conversation_id, sender_role, text, created_at, sequence_number
```

El esquema vivo es `sender_role` + `text`. El `20260717000000_init.sql` del repo define `role` + `content_text`, que **no existen en producción**.

Consecuencia directa: `dashboard_repository_impl.dart` consulta `.eq('role','user')` y esa consulta falla en producción (columna inexistente) → los logros se devuelven vacíos sin error visible.
'@
}

foreach ($num in ($Comments.Keys | Sort-Object)) {
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/comments" -Body @{ body = $Comments[$num] } | Out-Null
        Write-Host "#${num}: comentario publicado"
    } catch { Write-Warning "fallo al comentar #$num" }
    Start-Sleep -Milliseconds 400
}

# #13 -> implementado (código desplegado en v6)
$All = @("estado/implementado", "estado/parcial", "estado/bloqueado", "estado/decision", "estado/pendiente")
foreach ($other in $All) {
    if ($other -eq "estado/implementado") { continue }
    try { Invoke-Gh -Method Delete -Uri "$ApiBase/issues/13/labels/$([uri]::EscapeDataString($other))" | Out-Null } catch {}
}
try {
    Invoke-Gh -Method Post -Uri "$ApiBase/issues/13/labels" -Body @{ labels = @("estado/implementado") } | Out-Null
    Write-Host "#13 -> estado/implementado"
} catch { Write-Warning "no se pudo etiquetar #13" }

$c13 = @'
### Desplegado y verificado

`missions-cron` desplegada en **v6** con la lógica fail-closed.

Prueba sin autorización:

```
POST /functions/v1/missions-cron
  -> HTTP 500 {"error":"CRON_SECRET not configured"}
```

El endpoint ya **no** ejecuta `rotate_daily_missions()` sin credenciales. Antes devolvía 200 y rotaba para todos los usuarios.

Acción pendiente (configuración, no código): definir `CRON_SECRET` en los secretos de la función. Sin él la rotación no corre, pero el endpoint permanece cerrado.
'@
try {
    Invoke-Gh -Method Post -Uri "$ApiBase/issues/13/comments" -Body @{ body = $c13 } | Out-Null
    Write-Host "#13: comentario publicado"
} catch { Write-Warning "fallo al comentar #13" }

Write-Host "Listo."
