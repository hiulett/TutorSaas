# product-discovery — índice de entrada

> Carpeta de **ingeniería inversa del producto** `hiulett/TutorSaas`
> ("Dungeon of English"): Flutter + Supabase, inglés conversacional con una capa
> RPG. Este README está pensado para que **otra IA** (o una persona nueva)
> entienda qué es la app, en qué orden leer y dónde está la verdad de cada cosa
> sin recorrer el repo entero.
>
> Medición base: **31-oct-2026**, `origin/master`, worktree `p14-ai-usage`.
> Antes de leer nada más: [`_baseline.md`](_baseline.md).
> Decisiones canónicas: [`_decisions.md`](_decisions.md) y
> [`19-canon-and-decisions.md`](19-canon-and-decisions.md).

---

## 1. Qué es la app (en 8 líneas)

App **Android** (sin iOS, por decisión) para practicar **inglés oral** con NPCs
de IA. El pipeline es `record` (AAC) → Edge Function `llm-proxy` (Groq Whisper
STT + DeepSeek SSE) → `flutter_tts`. Encima hay una capa RPG: maná que se gasta
al hablar, XP/oro/fragmentos/gemas, niveles, aura, rango F–SSS, prestigio,
títulos, misiones diarias/semanales, gremio con salas de voz y una tienda de
cosméticos. Monetización: Play Billing + RevenueCat (planes `plebeyo`, `noble`,
`realeza`).

- **Versión:** `1.0.21+22` · **Backend:** Supabase `sipiumfdpvnszthykyog`
- **Escala:** 20 pantallas · 20 rutas · 16 features · **90 tablas** · **99
  funciones** · **135 políticas RLS** · **14 vistas** · **733 pruebas** · **8
  Edge Functions** (medido 31-oct-2026; detalle en `_baseline.md`)
- **Idiomas:** UI en es/en/pt; aprendizaje solo inglés

---

## 2. Cómo leer esta carpeta

Etiquetas usadas en todos los documentos:

| Etiqueta | Significa |
|---|---|
| `[IMPLEMENTADO]` | Existe y se puede rastrear en código o datos |
| `[PARCIAL]` | Existe, pero con una brecha declarada |
| `[CONCEPTUAL]` | Diseñado, sin flujo real (código muerto, tabla vacía, UI sin productor) |
| `[PROPUESTA]` | No existe; es una idea de mejora (solo en `15`) |
| `[PENDIENTE DE VALIDAR]` | No verificable desde este entorno |

**Regla de evidencia:** cada afirmación lleva `archivo:línea`, nombre de RPC,
consulta SQL o issue. Si no hay evidencia, se marca `[PENDIENTE DE VALIDAR]` y se
dice qué falta. El repositorio **no** reproduce el esquema: los datos se
verifican contra producción (solo lectura).

**Límites de esta investigación (importante):**

- **No hubo revisión visual.** Sin visión de imágenes y con el móvil
  desconectado. Todo lo estético, el contraste percibido, el overflow real, el
  TTS y la sensación de juego quedan `[PENDIENTE DE VALIDAR]`.
- **No se ejecutó la app ni se probaron compras** (`payments` = 0 en producción).
- **No hay conclusiones de retención**: 68 usuarios, en su mayoría de prueba, y
  **1** activo en los últimos 7 días.
- Los conteos son un snapshot; pueden incluir cuentas de prueba.

---

## 3. Orden de lectura recomendado

| Paso | Documento | Para qué | Tiempo |
|---|---|---|---|
| 0 | [`_baseline.md`](_baseline.md) | Cifras y tokens medidos; si algo contradice, manda el código | 3 min |
| 1 | **Este README** | Mapa general y límites | 5 min |
| 2 | [`_decisions.md`](_decisions.md) | Las 15 decisiones canónicas + G-01 (no se cuestionan) | 3 min |
| 3 | [`19-canon-and-decisions.md`](19-canon-and-decisions.md) | Registro aprobado, coherencia código ↔ decisión y umbral D-15 | 12 min |
| 4 | [`12-current-state-and-gaps.md`](12-current-state-and-gaps.md) | Qué está implementado, parcial, muerto o no verificable, con evidencia | 15 min |
| 5 | [`14-game-design-audit.md`](14-game-design-audit.md) | Por qué el RPG no "juega": hallazgos G-01…G-11 con alternativa conceptual | 15 min |
| 6 | [`18-open-questions-and-decisions.md`](18-open-questions-and-decisions.md) | Histórico del análisis que llevó a las decisiones + registro | 8 min |
| 7 | [`15-improvement-proposals.md`](15-improvement-proposals.md) | Propuestas alineadas con el canon, priorizadas | 20 min |
| 8 | [`16-product-glossary.md`](16-product-glossary.md) | Glosario único: jugador, rango, gremio, maná, aura, nobleza, plebeyo | 5 min |
| 9 | [`../PRODUCT.md`](../PRODUCT.md) | Reglas de negocio vigentes (planes, monedas, maná, decisiones) | 8 min |
| 10 | [`../ARCHITECTURE.md`](../ARCHITECTURE.md) | Capas, rutas, pipeline de voz, tema | 8 min |
| 11 | [`../DATA_MODEL.md`](../DATA_MODEL.md) | Tablas, RLS, RPC (producción manda) | referencia |
| 12 | [`../ui-ux-audit/06-improvement-backlog.md`](../ui-ux-audit/06-improvement-backlog.md) | Los 39 hallazgos UX con archivo:línea | referencia |
| 13 | [`../product-audit/00-INDICE.md`](../product-audit/00-INDICE.md) | Auditoría integral previa (25-oct); algunas cifras ya están desfasadas | referencia |

Los documentos `00`–`11`, `13`, `17` y `22` de esta carpeta los escriben otros
agentes en paralelo; este README no los resume para no duplicar ni contradecir.
Los documentos de esta entrega son **12, 14, 15, 18, 19 y 22** (este último se
enlazará en el paso de lectura cuando exista el archivo).

---

## 4. Dónde vive cada cosa

| Si buscas… | Ve a |
|---|---|
| Reglas de negocio (planes, maná, monedas, premium) | [`../PRODUCT.md`](../PRODUCT.md) |
| Decisiones canónicas (D-01…D-15, G-01) | [`_decisions.md`](_decisions.md) · [`19`](19-canon-and-decisions.md) |
| Decisiones históricas y qué ya no es cierto | [`../HISTORY.md`](../HISTORY.md) |
| Rutas y pantallas | `lib/app/router.dart` · [`../ui-ux-audit/02-screen-inventory.md`](../ui-ux-audit/02-screen-inventory.md) |
| Pipeline de voz y capas | [`../ARCHITECTURE.md`](../ARCHITECTURE.md) · `lib/features/conversation/` |
| Tablas, RLS, RPC | [`../DATA_MODEL.md`](../DATA_MODEL.md) (verificar contra BD) |
| Entornos, secretos, cron, Edge Functions | [`../OPERATIONS.md`](../OPERATIONS.md) |
| Build y publicación | [`../RELEASE.md`](../RELEASE.md) |
| Estado de migraciones | [`../runbooks/MIGRATION_STATUS.md`](../runbooks/MIGRATION_STATUS.md) |
| Identidad visual (tokens reales) | [`_baseline.md`](_baseline.md) §tokens · `lib/core/theme/` |
| Qué está roto y por qué | [`12`](12-current-state-and-gaps.md) |
| Qué cambiar y en qué orden | [`15`](15-improvement-proposals.md) |
| Qué se decidió y cuánto falta para cumplirlo | [`19`](19-canon-and-decisions.md) |
| Un término y su significado canónico | [`16`](16-product-glossary.md) |

---

## 5. Mecánicas actuales (resumen operativo)

| Sistema | Regla real | Fuente |
|---|---|---|
| **Maná** | Cada acción de IA cuesta maná: Oráculo 15, mazmorra 12, chat libre 8, evaluación 30, curaduría de vocabulario 2, lección generada 100 | `ai_action_costs` (7 filas, 6 activas) |
| **Tope gratuito** | 200/día en plan `plebeyo`; al agotarlo, `llm-proxy` concede **1 turno de gracia gratis al día** (`claim_mana_grace`), lo que **contradice D-06** | `consume_mana`; `llm-proxy/index.ts:448-459`; [`19` §2.6](19-canon-and-decisions.md#26-d-06--no-se-regala-maná-y-las-alternativas-cuestan-cero) |
| **Recompensa de sesión** | XP = minutos×10; oro = objetivos×(10+bonus CEFR); fragmentos = objetivos×(5+bonus) | RPC `apply_session_rewards` |
| **Nivel** | `1 + XP/1000`; desbloquea cosméticos y paga bolsas de oro | `docs/PRODUCT.md:56-61` |
| **Rango** | F–SSS; lo escribe el examen/colocación y hoy **no** desbloquea contenido | `lib/features/onboarding/domain/models/cefr_rank.dart:3-4` |
| **Aura** | 5 tiers; se despierta con CEFR ≥ B1 o superando la etapa básica; `aura_xp` alimenta el título de prestigio | `aura_system.dart`; `prestige_ladder` (21) |
| **Misiones** | Solo diarias y semanales visibles; el progreso lo avanza el servidor por triggers | `mission_visibility.dart:29-30` |
| **Racha** | `user_language_profiles.current_streak` vía `register_practice`; `player_streaks` es una copia con freezes **no consumidos** | RPC `register_practice` |
| **Planes** | `plebeyo` $0 (3.000 maná/mes), `noble` $4.99 (17.000 + trial 7d), `realeza` $9.99 (20.500) | `subscription_plans` (3 activos) |
| **Premium** | No vende ventajas de aprendizaje evaluado; sí maná, historial de informe y cosméticos | `docs/PRODUCT.md:30-42` |

---

## 6. Identidad visual (resumen)

- **Solo tema oscuro.** `voidBg #05070E`, superficies `#11131B`–`#272A32`.
- **Acentos:** `manaCyan #00E5FF`, `runeViolet #9D4EDD`, `royalGold`,
  `emeraldGreen`, `crimsonRed`.
- **Radios:** 4 / 8 / 12 / 999 (`AppRadius`). **Espaciado:** 4–48 (`AppSpacing`).
- **Tipografía empaquetada** en `assets/google_fonts/`: Space Grotesk (títulos),
  Inter (cuerpo), JetBrains Mono (datos). No se descarga en runtime.
- **Deuda medida:** 419 `EdgeInsets` literales frente a 4 usos de `AppSpacing`;
  95 colores hardcodeados; 384 `GoogleFonts.*` frente a 114 `AppTypography.*`;
  4 estilos del `TextTheme` caen en Roboto no empaquetado.
- **Trampa:** `GlassCard` gana la arena de gestos; el tap va en su `onTap:`, no
  en un `GestureDetector` externo.

---

## 7. Flujos principales

```mermaid
flowchart LR
  S[Splash] --> W[Welcome]
  W --> O[Onboarding<br/>idioma · nivel · personaje]
  O --> M[Mini-charla 60 s]
  M --> H[Dashboard]
  H --> L[Lección / conversación]
  L --> R[Resumen + recompensa]
  R --> H
  L -.maná 0.-> G[Santuario de Maná]
  G -.CTA.-> P[Paywall]
  H --> T[Tienda / Inventario]
  H --> E[Mis errores]
  H --> X[Gremio]
  X --> V[Sala de voz]
  H --> I[Informe semanal]
```

Flujo comercial: `Play Billing → RevenueCat → webhook → Supabase → app`, con
`sync-entitlement` al abrir sesión. Detalle en [`../PRODUCT.md`](../PRODUCT.md) §7.

---

## 8. Decisiones aprobadas y brechas abiertas (top 5)

Las 15 decisiones + G-01 están **aprobadas** (2026-10-31, Isaac) y no se
cuestionan. Lo que queda abierto es la **brecha de implementación**, con detalle
y evidencia en [`19`](19-canon-and-decisions.md):

1. **D-02/D-15** Instrumentar frases/semana y retención léxica: sin esto no hay
   umbral evaluable.
2. **D-09** Un solo currículo y un solo criterio de "completada" (59 % de
   discrepancias medidas).
3. **D-03** Una sola racha y freeze consumido al faltar un día.
4. **G-01/D-08** Gremio con tablón de contratos y sin chat libre; hoy solo existe
   la capa "del día".
5. **D-01/D-04/D-05** Limpiar el canon visible: un nombre, una escala de rango,
   sin battle pass, pergamino como reintento.

---

## 9. Cómo mantener esta carpeta

1. Si cambia el código o el esquema, **manda el código**: actualizar
   [`_baseline.md`](_baseline.md) y el documento afectado en el mismo cambio.
2. No duplicar lo que ya está en `../product-audit/` o `../ui-ux-audit/`: citar y
   corregir la deriva.
3. Toda propuesta nueva va a `15`, no a `12` (que es estado, no idea).
4. Toda decisión aprobada se registra en [`19` §1](19-canon-and-decisions.md#1-registro-de-decisiones-aprobadas)
   (y se refleja en [`18` §4](18-open-questions-and-decisions.md#4-registro-de-decisiones));
   si contradice `../PRODUCT.md`, se actualiza ese documento en el mismo cambio.
5. Si aparece una revisión visual real (capturas + dispositivo), sustituir los
   `[PENDIENTE DE VALIDAR]` visuales por evidencia y anotar la fecha.

---

## 10. Documentos añadidos el 31-oct-2026

| Documento | Contenido |
|---|---|
| [`22-hardcoded-inventory.md`](22-hardcoded-inventory.md) | **67 hardcodes** (contenido 13, balance 21, lógica 10, seguridad 18, interfaz 5) con `archivo:línea`, equivalente en BD, divergencia y acción. |
| [`23-visual-validation-checklist.md`](23-visual-validation-checklist.md) | Checklist de **37 ítems** para la sesión humana por release (D-13): 20 pantallas, estados, TalkBack, escalado 1.5×/2× y comandos de captura. |

Ambos se apoyan en [`19-canon-and-decisions.md`](19-canon-and-decisions.md) y en [`_decisions.md`](_decisions.md).
