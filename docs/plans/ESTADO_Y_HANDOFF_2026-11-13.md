# Estado del proyecto y traspaso · 13-nov-2026

Documento de continuidad. Léelo antes de abrir una sesión nueva sobre economía,
monetización o currículo.

---

## 1 · Qué se cerró hoy

### Monetización (verificada con compras reales)

| Pieza | Estado |
|---|---|
| Paywall nativo de RevenueCat | ✅ abre (faltaba `FlutterFragmentActivity`) |
| Compra → webhook → `payments` | ✅ tres pagos registrados con `store_transaction_id` |
| `sync-entitlement` | ✅ migrado a API v2 (la clave `sk_` no funciona en v1) |
| Desactivación al cancelar | ✅ se aplica siempre |
| Canasta del plan | ✅ con prorrateo al subir de plan |

### Economía

- Exploits cerrados: multiplicador de misión, auto-completado y **acuñación por `add_gems`**.
- Precio único por ítem (oro ≤ nivel 5, gemas ≥ 6).
- Gemas solo por plan; misiones pagan oro; freeze comprable con oro.
- Repaso con pergaminos (`open_review_pergamino`).
- Santuario, jardín, vitrina y expedición (servidor).
- Dashboard de economía: `v_economy_flow_monthly`, `v_economy_balances`, `v_economy_catalog_health`.

### Diseño

- Splash variante B: puerta trazada, estado real de arranque, sin porcentaje.
- Anillo de meta diaria: `0m` en vez de `0`.
- Cross-sell del aura y tarjeta contextual de maná (umbral < 30 % del cupo diario).
- Contador animado arreglado (arrancaba en 0).

### Documentación

- `docs/audits/AUDITORIA_COMPLETA_INVENTARIO_LECCIONES.md` — 140 lecciones, 540 objetivos, 539 frases.
- `docs/plans/PLAN_IMPLEMENTACION_MIGRACION_Y_ADMINISTRACION_LECCIONES.md` — plan en 26 secciones, 27 historias.

---

## 2 · Pendiente inmediato (bloquea lo siguiente)

1. **Mergear PR [#447](https://github.com/hiulett/TutorSaas/pull/447)** (CUR-01 + CUR-02).
2. **Aplicar** `20261113150000_curriculum_schema.sql` en SQL Editor.
3. **Aplicar** `20261113140000_plan_allowance_month_key.sql` si no está ya.
4. **Rotar claves** expuestas en el chat: `sb_secret_…`, `sk_…` (RevenueCat) y la de Stitch.
5. **Actualizar el header del webhook** en RevenueCat si se rota `REVENUECAT_AUTH_TOKEN`.

## 3 · Pendiente funcional (no bloquea)

- Mover el CTA `PROBAR GRATIS` arriba (hoy vive tras cuatro tarjetas, fuera del pliegue).
- Marcar `pagado` en `payments`… no aplica: el enum ya es `completed/refunded/failed/pending`.
- Limpiar filas de sandbox en `payments` antes de mirar ARPU.
- Verificar el estado gratuito del splash y de la tarjeta de maná en dispositivo.
- `#417` cross-sell completo: el chip del header ya emite `source=header`.

## 4 · Riesgos vivos

| Riesgo | Estado |
|---|---|
| Webhook con token viejo tras rotación | Mitigado documentando el orden: rotar y actualizar el panel en el mismo minuto |
| Sandbox llenando `payments` | Sin limpiar; contamina ARPU |
| Contenido duplicado entre Dart y DB | Controlado por el flag `curriculum_source` (aún no implementado) |
| 481 traducciones idénticas | Deuda editorial, en cola (CUR-15) |

## 5 · Lecciones de proceso (para no repetirlas)

1. **Nunca `Get-Content -Raw` para editar Dart con acentos.** Doble-codifica. Usar la herramienta de edición.
2. **Verificar en dispositivo antes de dar por bueno un cambio de UI.** Cuatro fallos de hoy solo aparecieron ahí.
3. **Un bloque por PR.** Los errores encadenados de hoy (payload → enum → constraint) se detectaron probando, no leyendo.
4. **No afirmar sobre el esquema sin consultarlo.** Mi diagnóstico de «offering vacío» fue un error de endpoint.

## 6 · Siguiente bloque de trabajo

Orden recomendado, uno por sesión:

1. **CUR-03** ([#422](https://github.com/hiulett/TutorSaas/issues/422)) — importación idempotente de las 140 lecciones, con validación 140/540/539.
2. **CUR-04 y CUR-05** — marcar traducciones idénticas y objetivos débiles.
3. **CUR-07** — RPC `get_curriculum_pack`.
4. **CUR-16** — repositorio Flutter con caché y flag de origen.
5. **CUR-25** — rúbrica de colocación del Oráculo.

Cada una tiene su historia en la épica [#419](https://github.com/hiulett/TutorSaas/issues/419).
