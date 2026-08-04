# Fase 8 — IA · Plan Gratuito (tarea 30)

> Fuente de verdad: `/docs`. Diseño basado en la infraestructura real verificada (2026-07-30).

## 1. Estado actual (verificado en DB)

| Plan | Precio | Audio IA/mes | Features |
|---|---|---|---|
| `free` | $0 | 30 min | 5 conversaciones IA/día · corrección básica · mapa de mazmorras · 1 examen boss/semana · historial 7 días |
| `monthly` | $1.99 | 300 min | Conversaciones ilimitadas · corrección avanzada · Speech DNA · Blind Listening · Boss ilimitado |
| `annual` | $14.99 | 1200 min | Todo monthly + cosméticos + Battle Pass + soporte |
| `lifetime` | $29.99 | 600 min | Todo annual + cosméticos futuros + expansiones |

## 2. Infraestructura de límites real (verificada)

- **Cuota de minutos mensual**: RPC `check_ai_audio_quota` (lee `user_subscriptions.used_audio_seconds` vs `subscription_plans.monthly_audio_minutes_limit`). Free = 30 min.
- **Núcleo arcano (invocaciones diarias)**: `player_daily_state.invocations_max` (T-506) — 20/día + 5 por cada 7 días de racha.
- **Battle Pass**: `guild_battle_pass` (T-502).
- **Pergaminos**: `player_pergaminos` + límite diario `pergaminos_max`.

## 3. Diseño del Plan Gratuito (objetivo: adquisición + retención + conversión)

### Principios
1. **El usuario debe "ganar" la experiencia** — el free permite probar el core loop completo (mapa → conversación → misiones → summary) sin fricción.
2. **Los límites deben sentirse como energía, no como castigo** — las invocaciones diarias (núcleo arcano) son la unidad de energía; los 30 min/mes son la "freno de seguridad" para costos.
3. **La conversión debe llegar por valor percibido** (al agotar energía y querer más), no por bloqueo agresivo.

### Propuesta de límites (coherentes con lo existente)
| Recurso | Free actual | Free propuesto | Racional |
|---|---|---|---|
| Audio IA | 30 min/mes | 30 min/mes (mantener) | Ya es generoso; evita abuso de costos |
| Invocaciones/día | 20 | 15 base + 5/7d racha | "Energía" renovable; incentiva racha diaria |
| Conversaciones IA | 5/día | Ilimitadas dentro de la energía | Reduce fricción; el tope real es la energía |
| Examen boss | 1/semana | 1/semana (mantener) | Hito semanal que motiva upgrade |
| Misiones | activas | 5 activas + 1 secreta (max 3) | Equilibra progresión gratuita |
| Pergaminos | 5/día | 5/día (mantener) | Contenido offline de valor |
| Historial | 7 días | 7 días (mantener) | Empuja a premium para retención |

### Elementos de conversión (no agresivos)
- **Paywall suave**: al agotar invocaciones, el modal "NÚCLEO ARCANO AGOTADO" ya existe (`nucleo_arcano_limit_screen.dart`) → redirigir con CTA a `/paywall`.
- **Muestra de premium**: el plan mensual muestra "Conversaciones ilimitadas" en el momento de mayor satisfacción (tras completar una sesión).
- **Battle Pass gratuito**: niveles 1-5 gratuitos como prueba del sistema de prestigio.

## 4. Mejoras propuestas (para implementación)

### P0
1. **FR-01**: Ajustar `player_daily_state` default: `invocations_max` de 20 → 15 (base free) — requeriría lógica por plan en `getDailyState`. **Diferimiento**: el default ya aplica a todos; para diferenciar free vs premium, leer el plan en `getDailyState`.

### P1
2. **FR-02**: `check_ai_audio_quota` debería también descontar al plan correcto cuando el usuario es guest (hoy guests saltan la cuota). 
3. **FR-03**: Modal de energía agotada con doble CTA: "RECARGAR (ver anuncio/esperar mañana)" y "IR PREMIUM" — incentivo suave.

### P2
4. **FR-04**: Mensajes de "ya casi sin energía" al 20% de invocaciones restantes (reducción de fricción percibida).

## 5. Impacto económico estimado
- Free 30 min/mes de audio ≈ $0.02-0.05/mes/usuario de costo real (STT+LLM) — **sostenible**.
- La energía diaria (15 invocaciones) ≈ 15 turnos → ~1-3k tokens/turno ≈ $0.001-0.003/día/usuario.
- El free NO rompe la economía si se mantienen los 30 min/mes como tope de audio.

## 6. Conclusión
El plan gratuito actual ya es **atractivo y sostenible**. Las mejoras son de pulido (FR-01..FR-04), no de rediseño. La monetización (tarea 31) debe enfocarse en que el valor premium (ilimitado + cosméticos + battle pass) sea la razón para convertir, no la frustración.
