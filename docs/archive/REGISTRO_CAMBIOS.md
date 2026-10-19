# Registro de Cambios — Implementación (DungeonSpeak)

> Documento vivo del modelo de suscripciones, maná, currículo y su implementación.
> Estado: código implementado y verificado (analyze 0 errores · 136 tests OK).
> Los scripts SQL requieren ejecutarse en Supabase (acceso del usuario).

---

## 💳 1. Estructura final de planes (3 estamentos × 2 ciclos) — ✅ CERRADO

| Plan | Estatus | Mensual | Anual | Ahorro | Maná/mes | Ritmo currículo |
|---|---|---|---|---|---|---|
| FREE | PLEBEYO | $0 | — | — | 3,000 + 200/día | nunca completa |
| PLUS | NOBLE | $4.99 | $53.99 | 9.8% | **17,000** | 6 meses |
| PRO | REALEZA | $9.99 | $107.99 | 9.9% | **20,500** | 5 meses |
| MAX | DIVINO | $12.99 | $132.99 | 14.7% | **25,500** | 4 meses |

- **Ritmo**: MAX 4 meses · PRO 5 · PLUS 6 (currículo base 340, sin mazmorras secretas).
- **Implementado en código**: `subscription_plans` (script SQL 20260818_01) · RevenueCat display names (API v2).

## 🕐 2. Límite diario de maná — ✅ DISEÑADO + RPC

- Free: **200 maná/día** + 3,000/mes (sello diario convertible con compra).
- Pagos: sin límite diario (solo tope mensual).
- **Implementado**: `consume_mana` reescrito (script 20260818_03) con doble validación + gasto del equipado.

## ⚗️ 3. Elixires y gemas (inventario equipable) — ✅ DISEÑADO + CÓDIGO

| Producto | Maná | Precio | Tipo |
|---|---|---|---|
| gem_1000 / gem_1700 / gem_2400 / gem_3100 | 1,000/1,700/2,400/3,100 | $0.29/$0.49/$0.69/$0.89 | Gema (< $1) |
| elixir_3500 / elixir_7000 / elixir_10500 / elixir_14000 | 3,500/7,000/10,500/14,000 | $0.99/$1.99/$2.99/$3.99 | Elixir |

- **Mecánica**: 1 equipado por vez · nunca expiran en bolsa · al equipar: gema 48h / elixir 15d · al caducar se pierde el maná restante.
- **Ratio**: ~3,500 maná/$ uniforme.
- **Implementado**: tabla `mana_items` + RPCs `add_mana_item`/`equip_mana_item`/`desequip_mana_item` (script 20260818_03) · providers `manaItemsProvider`/`equippedManaItemProvider` · widget `ManaItemInventory` en `NucleoArcanoLimitScreen`.

## 🎓 4. Currículo de 340 lecciones — ✅ DEFINIDO

| Nivel | Lecciones |
|---|---|
| PRE-A1 | 40 |
| A1/A2 | 40 c/u |
| B1/B2 | 50 c/u |
| C1/C2 | 60 c/u |
| **Total** | **340** |

- Maná por nivel completo: PRE-A1 ~3,440 · A1 ~5,760 · A2 ~6,720 · B1 ~12,600 · B2 ~16,200 · C1 ~28,800 · C2 ~28,800 · **Total ~102,300**.
- **Implementado**: migración PRE-A1 (script 20260818_02, 20 lecciones del catálogo local → `scenarios`).

## 🤖 5. Generador de lecciones por IA + sub misiones — ✅ IMPLEMENTADO

- **Edge function `lesson-generator`**: busca por `skill_focus`+nivel → reutiliza si existe → genera si no (DeepSeek) → inserta con `is_custom=true` + `parent_id` → debita 100 maná server-side.
- **Router pedagógico** (`LessonGeneratorService`): tras lección no superada (<80%), detecta el skill más débil del radar y genera/reutiliza la sub misión.
- **Sub misiones**: `scenarios.parent_id` (máx 3/lección) · en el mapa se muestran indentadas como mazmorras ocultas.
- **Goals dinámicos**: `updateCatalogFromMap` ya soporta cualquier nº de goals (sin fijar a 4).

## 🗺️ 6. Mapa de Mazmorras — ✅ IMPLEMENTADO

- Título `path_roadmap_title` → "Mapa de Mazmorras" (ARB ×3).
- **12 lecciones visibles + scroll interno** (`LayoutBuilder` con altura limitada).
- **Sub misiones** indentadas bajo su lección padre (`_SubMissionTile`).
- **Tarjeta "Evaluación del Oráculo"** al final del nivel (gate 80%, `_OracleChallengeCard`).

## 📖 7. Flujo de superación de lección — ✅ IMPLEMENTADO

- Umbral **≥80%** metas (`LessonUnlockService.passThreshold = 0.80`).
- **`lesson_progress`** registra passed/failed al terminar.
- **Cierre robusto**: flag `_sessionFinalized` idempotente + `_handleExit` central (PopScope/back/go) + `dispose` como red de seguridad (persiste sin summary).
- **Resumen**: botón "Siguiente lección" (navega a la próxima del nivel) + reintento con maná si <80%.

## 🧙 8. Evaluación del Oráculo (promotion) — ✅ IMPLEMENTADO

- Modo promotion: arranca en el nivel actual + contexto (radar, weaknesses).
- **Nunca baja de nivel** (guarda en `_finalizeOracleEvaluation`).
- Reto desde **80%** de lecciones del nivel (tarjeta en el mapa).
- `/oracle-test?mode=promotion&level=B1` (router actualizado).

## 🌐 9. Idioma único EN — ✅ IMPLEMENTADO

- Selector de idioma del onboarding reemplazado por tarjeta fija de Inglés.
- `_selectedLanguageCode = 'en'` por defecto.
- Clave `onboarding_english_only` añadida (ARB ×3).

---

## 📦 Entregables para ejecutar (usuario)

| Script/Archivo | Qué hace | Dónde |
|---|---|---|
| `20260818_01_esquema_mana_curriculo.sql` | Planes (17/20.5/25.5K) + catálogo maná + `mana_items` + `lesson_progress` + `skill_focus`/`parent_id` + `lesson_generation` (100) + límite diario | Supabase SQL Editor |
| `20260818_02_migrar_prea1.sql` | 20 lecciones PRE-A1 → `scenarios` | Supabase SQL Editor |
| `20260818_03_mana_rpcs.sql` | `consume_mana` doble validación + `add_mana_item`/`equip`/`desequip` | Supabase SQL Editor |
| `lesson-generator/index.ts` + `APPLY_SECRETS.md` | Generación de sub misiones | `supabase functions deploy lesson-generator` |
| `revenuecat-webhook` (ya listo) | Activar plan + renovar maná | `supabase functions deploy` |

## ✅ Estado global
- **Código**: implementado y verificado (analyze 0 errores · 136 tests OK).
- **BD**: scripts listos para ejecutar (usuario).
- **RevenueCat/Play**: config de dashboard pendiente (usuario).
