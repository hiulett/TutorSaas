# Capturas de la auditoría UX/UI

## Estado actual

| Archivo | Estado |
|---|---|
| `01-arranque.png` | **NO VÁLIDO.** 58 222 bytes, cabecera `FF FE` (BOM UTF-16LE) en lugar de `89 50 4E 47`. Se generó con `adb exec-out screencap -p > archivo.png` en PowerShell, que re-codifica la salida como texto y corrompe el binario. No se puede abrir ni auditar. |

No existe ninguna otra captura. **No se ha generado ni nombrado ninguna captura
falsa.** Cualquier revisión visual pendiente debe hacerse con capturas nuevas
tomadas así:

```powershell
# 1. Localizar adb (no está en PATH en este equipo)
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# 2. Comprobar dispositivo
& $adb devices

# 3. Capturar SIN redirección de PowerShell
& $adb exec-out screencap -p | Set-Content -Encoding Byte -Path docs\ui-ux-audit\screenshots\02-welcome.png

# 4. Verificar que es PNG (debe empezar 137 80 78 71)
Get-Content -Encoding Byte -TotalCount 8 docs\ui-ux-audit\screenshots\02-welcome.png
```

Alternativa equivalente: `cmd /c "adb exec-out screencap -p > archivo.png"`.

## Nombres propuestos

| Archivo | Pantalla | Cómo llegar |
|---|---|---|
| `01-arranque.png` | Splash | abrir la app |
| `02-welcome.png` | Login | tras el splash, sin sesión |
| `03-onboarding.png` | Wizard paso 1 | crear cuenta |
| `04-dashboard.png` | Dashboard · Mazmorras | `/home` |
| `05-dashboard-estado.png` | Dashboard · Estado | dock, 3.er icono |
| `06-conversacion.png` | Conversación | CTA "CONTINUAR AVENTURA" |
| `07-resumen.png` | Resumen de sesión | terminar una conversación |
| `08-paywall.png` | Paywall | badge PRO |
| `09-gremio.png` | Guild | dock, 2.º icono |
| `10-tienda.png` | Tienda | acceso rápido |
| `11-misiones.png` | Misiones | spotlight de misión |
| `12-ajustes.png` | Ajustes | dock, 4.º icono |
| `13-guardian.png` | Guardián (sin maná) | agotar maná |
| `14-errores.png` | Mis errores | acceso rápido |
| `15-informe.png` | Informe semanal | tarjeta del dashboard |

Para revisar escalado de texto, repetir `04`, `06` y `12` con la escala de fuente
del sistema al máximo (Ajustes → Pantalla → Tamaño de fuente).
