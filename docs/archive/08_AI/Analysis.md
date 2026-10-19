# Fase 8 — IA · Auditoría de Costos (tarea 29)

> Fuente de verdad: `/docs`. Auditoría basada en código real + RPCs de Supabase verificados (2026-07-30).

## 1. Infraestructura de IA actual

| Servicio | Modelo | Uso | Costo unitario aprox. |
|---|---|---|---|
| STT (Groq) | `whisper-large-v3-turbo` | Transcribir grabación .m4a por turno | ~$0.04/hora audio |
| LLM (DeepSeek) | `deepseek-v4-flash` (chat SSE) · `deepseek-v4-pro` (evaluación metas) | Respuesta del tutor + evaluación de objetivos | Flash: barato · Pro: ~10x Flash |
| TTS | `flutter_tts` **on-device** | Síntesis local | **$0** |
| Caché | — | No hay caché de respuestas/embeddings | — |
| DB | Supabase | Persistencia + RPCs de cuota | fijo |

**Nota clave**: `generateTtsAudio` en el repo es un stub (`=> ''`); el TTS real es `flutter_tts` local (rate 0.48) → **cero costo de TTS cloud**. El plan AGENTS.md confirma: TTS on-device.

## 2. Problemas de costos detectados

### A0 — Críticos
| ID | Problema | Impacto económico |
|---|---|---|
| IA-01 | **API keys hardcodeadas en el código**: `deepseekApiKey` (línea 17), `groqApiKey` (línea 27) con valores reales en `api_constants.dart` | Riesgo de filtración/abuso → costo descontrolado; y **fallback en `conversation_repository_impl.dart:83`** (`'sk-592...'`) |
| IA-02 | **Modelos inconsistentes**: chat usa `deepseek-v4-flash` pero `evaluateGoals` usa `deepseek-v4-pro` (línea 240) | Pro es ~10x más caro por evaluación de metas (se ejecuta CADA turno) |

### A1 — Optimizables
| ID | Problema | Impacto |
|---|---|---|
| IA-03 | **`evaluateGoals` envía la conversación COMPLETA cada turno** (`conversation_repository_impl.dart:508` en provider) | El contexto crece linealmente → tokens/costo crecen con cada turno |
| IA-04 | **Retries innecesarios**: `maxRetries=2` en streaming con timeout 90s | Duplica costo en fallos de red |
| IA-05 | **Doble limitación**: `check_ai_audio_quota` (minutos/mes) + `canInvoke` (núcleo diario T-506) sin coordinación visible | Puede frustrar al usuario pero no es costo |
| IA-06 | **Sin caché de respuestas del tutor** para mensajes repetidos/frases sugeridas | Desperdicio en práctica guiada |
| IA-07 | **`trackAiAudioTime` cuenta el tiempo de grabación real** (correcto) pero no hay cap de minutos por día en código | El free de 30min/mes es generoso para producción |

## 3. Estrategias de reducción de costos (priorizadas)

### P0 — Seguridad y modelo (ahorro inmediato)
1. **IA-01 → Mover API keys a `--dart-define` / config remota**: quitar valores hardcodeados; los fallbacks `'sk-592...'` deben eliminarse. Beneficio: evita abuso (mayor ahorro potencial). Riesgo: requiere reconfigurar builds.
2. **IA-02 → Unificar modelo**: usar `deepseek-v4-flash` también en `evaluateGoals` (es tarea de clasificación simple). Ahorro ~10x en evaluaciones. Riesgo: ligera pérdida de precisión — mitigable con `temperature=0.3` ya presente.

### P1 — Contexto y retries (ahorro moderado)
3. **IA-03 → Evaluar metas solo con los últimos N mensajes** (ventana móvil, ej. últimos 6 del estudiante) en vez de la conversación completa. Ahorro: contexto acotado.
4. **IA-04 → Reducir `maxRetries` a 1** para streaming (el usuario reenvía si falla). Ahorro: mitad de reintentos.
5. **IA-06 → Caché en memoria de respuestas** para frases sugeridas / saludos repetidos.

### P2 — Políticas de plan
6. **IA-05 → Coordinar cuotas**: la cuota de minutos (mensual) es la autoridad; el núcleo arcano (diario) como fricción suave. Documentar jerarquía.
7. **IA-07 → Plan gratuito**: definir 30 min/mes (ya existe) + cap diario de invocaciones (T-506 ya limita). Ver tarea 30 (Plan Gratuito).

## 4. Estimación de impacto
- **IA-02** (unificar modelo en evaluaciones): ahorro ~50-70% del costo de LLM si las evaluaciones dominan el consumo.
- **IA-03** (ventana móvil): ahorro ~30-50% en tokens por sesión larga.
- **IA-01** (seguridad): elimina riesgo de abuso externo (potencialmente el mayor ahorro).

## 5. Próximos pasos
- Tarea 30 (Plan Gratuito): definir límites atractivos basados en esta auditoría.
- Tarea 31 (Monetización IA): planes premium coherentes con los costos reales.
- Implementar IA-02 y IA-03 (cambios de código pequeños y seguros) tras aprobación.
