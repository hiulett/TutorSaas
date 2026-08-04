# Auditoría 03 — Auditoría de Consistencia Visual (Crear Personaje)

**Fecha:** 2026-08-01
**Ámbito:** `character_creation_wizard.dart` — panel de selección de avatar
**Estado:** Hallazgo verificado — propuesta de corrección (sin cambios de código)

---

## 1. Hallazgo

El panel de avatares del asistente de creación de personaje puede **desbordar (overflow) en resoluciones estrechas**.

Evidencia:

- El panel contiene **6 orbes** en una `Row` con `mainAxisAlignment: spaceEvenly`.
- Cada orbe es un `AnimatedContainer(width: 48, height: 48)` con icono `size: 24`.
- Ancho mínimo requerido: 6 × 48 = **288 px** de orbes más los espacios `spaceEvenly`; en pantallas estrechas (p. ej. ≤ 320 dp o con padding) la fila desborda el ancho disponible → `RenderFlex overflow`.

## 2. Causa raíz

El layout del avatar se construyó como una fila fija de tamaño constante. El resto del wizard sí fue modernizado (tarjetas rúnicas + glow + `RunicButton` + avatares-orbe con `AppRadius.circleBorder`), pero el contenedor de avatares no se adaptó a anchos variables.

## 3. Evidencia

| Elemento | Referencia |
|---|---|
| Contenedor de avatares | `character_creation_wizard.dart` (panel avatar) |
| Distribución | `Row` con `mainAxisAlignment: spaceEvenly` |
| Orbes | 6 × `AnimatedContainer(width: 48, height: 48)`, icono `size: 24` |
| Ancho mínimo | 6 × 48 = 288 px + espacios `spaceEvenly` → riesgo de overflow |
| Contexto visual del resto del wizard | `GlassCard` / `AppTypography` / `RunicButton` / avatares-orbe con `AppRadius.circleBorder` (consistente) |

## 4. Archivos afectados

- `lib/features/onboarding/presentation/character_creation_wizard.dart` (único archivo; solo el panel avatar).

## 5. Solución propuesta

Hacer el panel de avatares **responsive**, preservando el estilo visual ya consistente:

1. **`Wrap` en lugar de `Row`** (con `spacing`/`runSpacing`), para que los orbes fluyan a la siguiente línea automáticamente en anchos pequeños.
2. Alternativa: **grid 3×2** (tres por fila, dos filas) para una cuadrícula predecible.
3. Alternativa: reducir el orbe a **44–48 px** manteniendo el `Wrap`, priorizando el tamaño mayor cuando el ancho lo permita.
4. Garantizar **alineación y escalado** en todas las resoluciones (test visual en viewports 320, 360 y 412 dp).

## 6. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| **Hit-area < 48 px** (accesibilidad) | Mantener objetivos táctiles ≥ 48 px aunque el contenedor visual se ajuste; usar `wrap` sin reducir el objetivo. |
| **Romper la selección** del avatar | Conservar el `AnimatedContainer` y la lógica de selección (estado activo) intactos; el cambio es solo de contenedor. |
| Inconsistencia con el resto del wizard | El resto ya usa `GlassCard`/`AppTypography`/`RunicButton`; el fix no altera el estilo, solo el layout del panel. |

## 7. Notas de cierre

- No se modifica código en esta auditoría; es una corrección propuesta pendiente de aprobación.
- Único archivo implicado: `character_creation_wizard.dart`.
