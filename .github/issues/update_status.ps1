# Actualiza el estado de las issues de la auditoría y publica un comentario de progreso.
# Uso:  powershell -ExecutionPolicy Bypass -File .github/issues/update_status.ps1
#
# Requiere GitHub CLI autenticado (gh auth login) o GITHUB_TOKEN con Issues: write.

param(
    [string]$Owner = "hiulett",
    [string]$Repo  = "TutorSaas",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ApiBase = "https://api.github.com/repos/$Owner/$Repo"

$Token = $env:GITHUB_TOKEN
if (-not $Token) { $Token = $env:GH_TOKEN }
if (-not $Token) {
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if ($gh) { try { $Token = (& $gh.Source auth token 2>$null) } catch { $Token = $null } }
}
if (-not $Token -and -not $DryRun) { Write-Error "Falta GITHUB_TOKEN o gh autenticado."; exit 1 }

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
        $json = $Body | ConvertTo-Json -Depth 10 -Compress
        $p.Body = [System.Text.Encoding]::UTF8.GetBytes($json)
        $p.ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @p
}

# ---------------------------------------------------------------- labels
$StatusLabels = @(
    @{ name = "estado/implementado"; color = "0e8a16"; description = "Corregido y verificado en local" },
    @{ name = "estado/parcial";      color = "fbca04"; description = "Parte del problema corregida; queda trabajo" },
    @{ name = "estado/bloqueado";    color = "b60201"; description = "Requiere base de datos, despliegue o entorno" },
    @{ name = "estado/decision";     color = "5319e7"; description = "Requiere una decisión de producto antes de tocar código" },
    @{ name = "estado/pendiente";    color = "ededed"; description = "Sin empezar; se puede abordar en código" }
)

foreach ($l in $StatusLabels) {
    try { Invoke-Gh -Method Post -Uri "$ApiBase/labels" -Body $l | Out-Null; Write-Host "Label: $($l.name)" }
    catch {
        $code = 0; try { $code = $_.Exception.Response.StatusCode.value__ } catch {}
        if ($code -ne 422) { Write-Warning "No se pudo crear $($l.name)" }
    }
}

# ---------------------------------------------------------------- mapping
$Status = @{
    1 = "estado/bloqueado";   2 = "estado/bloqueado";  3 = "estado/bloqueado"
    4 = "estado/bloqueado";   5 = "estado/bloqueado";  6 = "estado/bloqueado"
    7 = "estado/bloqueado";   8 = "estado/decision";   9 = "estado/bloqueado"
    10 = "estado/bloqueado";  11 = "estado/bloqueado"; 12 = "estado/bloqueado"
    13 = "estado/implementado"; 14 = "estado/parcial"; 15 = "estado/bloqueado"
    16 = "estado/bloqueado";  17 = "estado/implementado"; 18 = "estado/implementado"
    19 = "estado/decision";   20 = "estado/decision";  21 = "estado/bloqueado"
    22 = "estado/pendiente";  23 = "estado/implementado"; 24 = "estado/pendiente"
    25 = "estado/bloqueado";  26 = "estado/decision";  27 = "estado/decision"
    28 = "estado/decision";   29 = "estado/parcial";   30 = "estado/decision"
    31 = "estado/implementado"; 32 = "estado/parcial"; 33 = "estado/pendiente"
    34 = "estado/pendiente";  35 = "estado/pendiente"; 36 = "estado/decision"
    37 = "estado/pendiente";  38 = "estado/implementado"; 39 = "estado/pendiente"
    40 = "estado/decision";   41 = "estado/decision";  42 = "estado/pendiente"
    43 = "estado/decision";   44 = "estado/pendiente"; 45 = "estado/implementado"
}

# ---------------------------------------------------------------- comments
$Comments = @{
13 = @'
**Estado: implementado (código).**

`supabase/functions/missions-cron/index.ts` ahora falla cerrado: si `CRON_SECRET` no está configurado devuelve **500** y no ejecuta la RPC. Con secreto presente, exige `Authorization: Bearer <CRON_SECRET>`.

Pendiente de despliegue: `supabase functions deploy missions-cron` + configurar el secreto (no ejecutable desde esta sesión).
'@

14 = @'
**Estado: parcial.**

Cambios en `lib/features/conversation/presentation/providers/conversation_providers.dart`:

- El `RANK` declarado por el modelo se valida contra la escala cerrada `{F,E,D,C,B,A,S,SS,SSS}`. Si no pertenece, se deriva del CEFR (antes se persistía cualquier valor, p. ej. `ZZ`).
- El texto del alumno se sanea con `_stripControlTokens` antes de entrar al contexto del Oráculo, para que no pueda inyectar `[EVALUATION_COMPLETE]` ni `[RESULT:...]`.

Pendiente: el clasificador independiente sigue sin tener la última palabra y no existe un camino de descenso de nivel.
'@

17 = @'
**Estado: implementado.**

- `LessonUnlockService.passThreshold`: 0.80 → **0.75** y nuevo `meetsThreshold(completed, total)` que supera la lección cuando se completan todas las metas, o falla como máximo una con 4 metas o menos, o se alcanza el 75 % en lecciones largas.
- `LessonHalo.passThreshold` pasa a usar la misma constante (antes 0.70), así que la UI y la regla de desbloqueo dejan de contradecirse.
- Tests actualizados: `test/lesson_unlock_service_test.dart` (16 casos: 4/4, 3/4, 2/4, 2/3, 1/3, 8/10, 7/10, sin metas) y `test/lesson_halo_test.dart`.

Verificación local: `flutter analyze` 0 errores; `flutter test` **142/142**.
'@

18 = @'
**Estado: implementado.**

`endSession` (`conversation_providers.dart`) usa ahora `lesson.goals.length` como denominador (antes usaba el número de metas **evaluadas**) y **no registra `lesson_progress`** cuando no hubo evaluación.

Consecuencia: una caída del LLM ya no marca la lección como `passed`, no otorga recompensas por ese motivo y no dispara la generación de la lección remedial (que cuesta 100 de maná).
'@

23 = @'
**Estado: implementado.**

- Nuevo `OnboardingRepository.updateLanguagePreferences` (interfaz + impl) que actualiza **solo** `language_id` y `cefr_level_id`.
- `SettingsScreen` deja de llamar a `saveOnboardingData`, que hacía upsert con `xp_points: 0`, `current_streak: 0`, `native_language: 'es'` y podía fijar el CEFR en B1.
- La pantalla hidrata idioma objetivo y nivel desde el perfil real una sola vez (`_prefsHydrated`), en lugar de mostrar siempre los valores por defecto.

Pendiente: confirmar en dispositivo con sesión real que guardar no altera XP ni racha (requiere BD).
'@

29 = @'
**Estado: parcial.**

Corregido el bug del primer día en `economy_repository_impl.dart`: cuando `diff == 0` y `current_streak == 0`, la racha pasa a **1** (antes se quedaba en 0 hasta el segundo día).

Pendiente: siguen existiendo dos fuentes de verdad (`player_streaks` y `user_language_profiles.current_streak`), la zona horaria local vs UTC no está unificada y el banner "racha en riesgo" sigue leyendo un contador muerto (`invocations_used`).
'@

31 = @'
**Estado: implementado (chat de rol).**

`_chatWindow()` limita el contexto enviado al tutor a los **últimos 24 mensajes con contenido**; antes se enviaba el historial completo y el coste de entrada crecía en cada turno. El Oráculo ya truncaba a 24.

Pendiente: cerrar conversaciones (`ended_at` / `status`) para que el historial no crezca entre sesiones.
'@

32 = @'
**Estado: parcial.**

Eliminados los datos inventados mientras carga:

- `dashboard_screen.dart`: `2450 XP` / `racha 7` → `0` / `0`.
- `dashboard_repository_impl.dart`: los dos fallbacks `120 XP` / `racha 1` → `0` / `0`.

Pendiente: no existe todavía un widget compartido de carga/error/vacío, ni detección de offline, ni se han revisado los `catch (_) {}` del resto de pantallas.
'@

38 = @'
**Estado: implementado.**

- Eliminada la ruta `/settings` (Settings se renderiza como tab 3 del dashboard).
- Eliminada la ruta `/disruption` y su import: no tenía ningún punto de entrada.
- Eliminados `oraclePromotionMode` / `oraclePromotionLevel` de `ConversationScreen` y del router, que nunca se leían.

Rutas registradas: **16 → 14**. `flutter analyze` 0 errores; `flutter test` 142/142.
'@

45 = @'
**Estado: implementado.**

`AGENTS.md` actualizado con los hechos verificados:

| Afirmación anterior | Ahora |
|---|---|
| "un solo commit" | **6 commits** |
| "~56 infos/warnings" | **177 issues** (36 W + 141 I) |
| `deepseek-chat` | `deepseek-v4-flash` |
| "evaluación por keyword (`isSatisfiedBy`)" | **LLM**; `isSatisfiedBy` sin llamadas |
| "hold-to-talk" | **tap-to-toggle** |
| "`HankenGrotesk` eliminado" | **sigue presente** (issue #34) |
| "12 rutas" | **14 rutas** |
| "5 archivos de test" | **15 archivos / 142 casos** |

También se añadió la advertencia de que solo 23 de 128 migraciones son aplicables por CLI.
'@
}

# ---------------------------------------------------------------- apply
$allStatusLabels = $StatusLabels | ForEach-Object { $_.name }

foreach ($num in ($Status.Keys | Sort-Object)) {
    $label = $Status[$num]
    if ($DryRun) { Write-Host "#$num -> $label"; continue }

    foreach ($other in $allStatusLabels) {
        if ($other -eq $label) { continue }
        try { Invoke-Gh -Method Delete -Uri "$ApiBase/issues/$num/labels/$([uri]::EscapeDataString($other))" | Out-Null } catch {}
    }
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/labels" -Body @{ labels = @($label) } | Out-Null
        Write-Host "#$num -> $label"
    } catch {
        Write-Warning "No se pudo etiquetar #$num"
    }

    if ($Comments.ContainsKey($num)) {
        try {
            Invoke-Gh -Method Post -Uri "$ApiBase/issues/$num/comments" -Body @{ body = $Comments[$num] } | Out-Null
            Write-Host "  comentario publicado"
        } catch { Write-Warning "  fallo al comentar #$num" }
        Start-Sleep -Milliseconds 400
    }
    Start-Sleep -Milliseconds 250
}

# ---------------------------------------------------------------- epic summary
if (-not $DryRun) {
    $counts = @{}
    foreach ($v in $Status.Values) { if ($counts.ContainsKey($v)) { $counts[$v]++ } else { $counts[$v] = 1 } }
    $summary = @"
## Progreso de implementación — oleada 1

Verificación local: ``flutter analyze`` **0 errores** (36 warnings + 141 infos) · ``flutter test`` **142/142**.

| Estado | Issues |
|---|---|
| ``estado/implementado`` | $($counts['estado/implementado']) |
| ``estado/parcial`` | $($counts['estado/parcial']) |
| ``estado/bloqueado`` | $($counts['estado/bloqueado']) |
| ``estado/decision`` | $($counts['estado/decision']) |
| ``estado/pendiente`` | $($counts['estado/pendiente']) |

### Implementado en esta oleada

- **#13** missions-cron fail-closed.
- **#17** umbral único 0.75 + ``meetsThreshold`` (halo y desbloqueo coherentes).
- **#18** evaluación vacía ya no marca la lección como aprobada.
- **#23** Settings deja de resetear XP, racha, idioma nativo y CEFR.
- **#31** ventana de 24 mensajes en el chat de rol.
- **#38** rutas huérfanas eliminadas (16 → 14).
- **#45** ``AGENTS.md`` corregido con 8 hechos verificados.

### Parcial

- **#14** validación de RANK + saneamiento del token de control. Falta descenso de nivel y que el clasificador independiente tenga la última palabra.
- **#29** bug del primer día corregido. Sigue habiendo dos fuentes de racha.
- **#32** eliminados los fallbacks de XP/racha. Faltan estados compartidos y offline.

### Bloqueado y por qué

Los ``estado/bloqueado`` requieren algo que esta sesión no tiene: **acceso a la base viva** (RLS, RPC, migraciones, tablas ausentes), **despliegue de Edge Functions** o **entorno macOS/Xcode** (iOS). Están listados con su evidencia en el informe de auditoría.

Los ``estado/decision`` no se han tocado a propósito: cambiar el modelo de negocio, el alcance idiomático o el significado de "mazmorra" es una decisión de producto, no una corrección.
"@
    try {
        Invoke-Gh -Method Post -Uri "$ApiBase/issues/46/comments" -Body @{ body = $summary } | Out-Null
        Write-Host "Resumen publicado en el epic #46"
    } catch { Write-Warning "No se pudo comentar el epic" }
}

Write-Host "Listo."
