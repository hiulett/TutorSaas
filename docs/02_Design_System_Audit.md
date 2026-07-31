# 02 — Design System Audit: Tokens actuales vs `abyssal_interface`

> Fase 0/1 · Auditoría de sistema de diseño · Fecha: 2026-07-30
> Criterio: `PlantillaHtml/abyssal_interface/DESIGN.md` (fuente oficial) + `lib/core/theme/`.

## 1. Paleta

| Token | Valor oficial (PlantillaHtml) | En app (`app_colors.dart`) | Paridad |
|---|---|---|---|
| voidBg / fondo | `#05070E` | `voidBg #05070E` | ✅ |
| manaCyan / acento primario | `#00E5FF` | `manaCyan #00E5FF` | ✅ |
| royalGold / acento secundario | `#FFC700` | `royalGold #FFC700` | ✅ |
| runeViolet / acento terciario | `#9D4EDD` | `runeViolet #9D4EDD` | ✅ |
| emeraldGreen / éxito | `#00E676` | `emeraldGreen #00E676` | ✅ |
| crimson / error | `#FF1744` | **Falta token de error en app** | ⚠️ |

**Veredicto**: la paleta ya fue migrada correctamente. Solo falta exponer un token de error/`danger` (`#FF1744`) y verificar que `ColorScheme.error` lo use.

## 2. Tipografía

| Rol | Oficial | En app | Paridad |
|---|---|---|---|
| Headlines | Space Grotesk | `SpaceGrotesk` | ✅ |
| Cuerpo | Inter | `Inter` | ✅ |
| Stats/labels/mono | JetBrains Mono | `JetBrainsMono` | ✅ |

⚠️ Regla AGENTS.md: no introducir otras familias (ej. `HankenGrotesk` ya fue removido). Verificar que ninguna pantalla haya reintroducido una familia externa.

## 3. Geometría y espaciado

| Token | Oficial | En app | Paridad |
|---|---|---|---|
| Radio estándar | 4px | Estándar 4px | ✅ |
| Radio >20px | solo avatares/orbes | `RpgAvatar` orb | ✅ |
| Unidad de espaciado | 4px | — | ⚠️ verificar en pantallas nuevas |
| Gutter 16px / margen móvil 20px / padding ventana 24px | oficial | — | ⚠️ sin tokens compartidos |

**Acción**: centralizar espaciado en tokens (por ej. constantes en `app_colors.dart`-side o un `app_spacing.dart`) para que las pantallas nuevas respeten el grid de 4px.

## 4. Superficies / ventanas del sistema

| Elemento | Oficial | En app | Paridad |
|---|---|---|---|
| Ventana del sistema | opacidad 0.94, borde 1px cyan, glow | `GlassCard` | ✅ (soporta borde y esquinas rúnicas) |
| Esquinas rúnicas | `showRunicCorners` + `runicColor` | `GlassCard` | ✅ |
| Fondo manhwa | 13 `CyberBgMode`s | `CyberManhwaBackground` | ✅ |

## 5. Componentes del sistema oficial

| Componente | PlantillaHtml | En app | Paridad |
|---|---|---|---|
| Barras segmentadas 10-seg | sí (segmentos) | `SegmentedBar` | ✅ |
| Contador animado | sí | `AnimatedCounter` | ✅ |
| Recompensa flotante "+XP" | sí | `FloatingReward` | ✅ |
| Quest cards con letra de rango | sí | — | ⚠️ pendiente |
| Mana orb / botón de mic | sí | existe en `conversation_screen` | ✅ |
| Glifos rúnicos decorativos | sí | `GlassCard` corner + backgrounds | ✅ |

## 6. Conclusión

- El **sistema de diseño base ya alineó el 90%** con `abyssal_interface` (paleta, tipografía, radios, GlassCard).
- Faltan: token `danger/error`, tokens de spacing compartidos, y un componente de **quest/rank card** estándar.
- Las brechas grandes están en **pantallas** (ver `01_UI_Audit`), no en el sistema base.
- Confirmar con `flutter analyze` que no existan hex hardcodeados fuera de `AppColors` (regla: no `Color(0xFF...)` sueltos).
