# 04 — Technical Debt & Risk Register

> Fase 0/1 · Deuda técnica y riesgos · Fecha: 2026-07-30

## 1. Riesgos críticos (P0)

| # | Riesgo | Impacto | Mitigación |
|---|---|---|---|
| R1 | **Un solo commit + trabajo sin commitear** | Cualquier `checkout`/`restore`/`clean` borra todo el trabajo de features | Commit temprano de todo lo actual, o backup manual. **Nunca** `git checkout -- '*.dart'` |
| R2 | El reporte de Graphify está construido sobre el commit inicial (`8c1ef25e`) | Métricas de arquitectura no reflejan economy/missions/l10n | Ejecutar `graphify update .` antes de decisiones de arquitectura |
| R3 | Migraciones de DB probablemente no aplicadas al live; live puede rechazar DDL ("read-only transaction") | Features de economía/misiones fallan en producción | Aplicar vía SQL Editor o branch; verificar `supabase_list_migrations` |

## 2. Deuda técnica funcional (P1)

| Área | Problema |
|---|---|
| Onboarding | Wizard de creación de personaje + oracle test existen untracked pero **sin cablear** al router/flujo |
| Rutas planificadas | `/hunter-status`, `/oracle-test`, `/shop`, inventario, battle pass, daily reward **no existen ni están registradas** |
| Chat rooms | Voice room crashea con `roomId` no-UUID (rooms default `guild_table_1`) |
| Dashboard tabs | "ESTADO" y "CONFIG" no muestran contenido equivalente al HUD oficial |
| Misiones/Economía | Módulos existen y compilan pero su integración con el dashboard está sin verificar |
| `t()` legacy | El helper `t()` en `lib/core/i18n/locale_provider.dart` es un **stub** que devuelve la key — no confiar en él; usar `AppLocalizations.of(context)!.key` |
| Paleta vieja | `#0B1326` / `#B76DFF` deprecadas — no reintroducir |

## 3. Deuda de diseño (P1/P2)

| Área | Problema |
|---|---|
| Token danger/error | Falta color `#FF1744` en el sistema de tokens |
| Tokens de spacing | No hay constantes compartidas de espaciado (grid 4px / gutter 16px / margen 20px) |
| Quest/Rank card | No existe widget estándar; cada pantalla lo improvisa |
| Hex hardcodeados | Riesgo de colores sueltos fuera de `AppColors` (regla AGENTS.md) |

## 4. Deuda de i18n

- `app_es.arb` y `app_pt.arb` existen; debe verificar cobertura frente a `app_en.arb`.
- Tras editar cualquier `.arb` **obligatorio** `flutter gen-l10n`.
- No hardcodear strings de UI en pantallas nuevas.

## 5. Proceso / higiene

- `flutter analyze`: barra = 0 errores; no perseguir los ~56 infos/warnings.
- `flutter test`: 5 archivos en `test/` — mantener verde.
- `dart run build_runner build --delete-conflicting-outputs` tras editar freezed/json_serializable.
- **Voice pipeline** (record→Groq→DeepSeek SSE→flutter_tts 0.48): NO alterar.

## 6. Prioridad de pago recomendada

1. **R1** → commit/backup de todo lo actual (evitar otra regresión).
2. **R3** → verificar y aplicar migraciones de DB.
3. **Onboarding + rutas** → cablear pantallas untracked y crear las faltantes.
4. **Bug voice room** (roomId no-UUID).
5. **Tokens de diseño** (danger + spacing) y QuestCard.
