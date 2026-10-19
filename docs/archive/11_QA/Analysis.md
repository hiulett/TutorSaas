# Fase 11 — QA · Auditorías (tareas 38-42)

> Fuente de verdad: `/docs`. Basada en verificación real: `flutter analyze`, `flutter test`, `flutter build`, Supabase Advisors (security + performance) consultados en vivo (2026-07-30).

## Tarea 38 — Auditoría completa (arquitectura, seguridad, escalabilidad)

### Estado de build y calidad
| Check | Resultado |
|---|---|
| `flutter analyze` | 64 issues (0 errores; infos/warnings tolerados) |
| `flutter test` | 13/13 ✅ |
| `flutter build apk --debug` | ✅ OK |

### Arquitectura
- Feature-first clean architecture (data/domain/presentation) en 10 features. ✅
- Riverpod + go_router + Supabase. ✅ Consistente.
- 2 repositorios con interfaz abstracta (economía, chat_rooms); misiones usa repo concreto (menor, aceptable).
- Deuda: `dashboard_screen.dart` (2040 líneas) y `conversation_screen.dart` (1221) grandes — refactor futuro.

### Seguridad — Supabase Advisors (81 WARN)
| Severidad | Hallazgo | Impacto |
|---|---|---|
| WARN (54) | Políticas RLS accesibles a rol `anon` | Acceso anónimo a datos que deberían ser autenticados |
| WARN (12+12) | Funciones `SECURITY DEFINER` ejecutables por anon/authenticated vía RPC | `add_xp`, `add_gems`, `spend_gems`, `rotate_daily_missions`, etc. invocables sin control |
| WARN | `system_ai_settings` legible por todos (`using_expr=true`) | Config interna expuesta (no contiene claves, pero innecesario) |
| WARN | `vocabulary_items` INSERT con `WITH CHECK (true)` | Cualquier autenticado inserta vocabulario sin restricción |
| WARN | `before_message_inserted_rate_limit` search_path mutable | Riesgo de secuestro de objetos |
| WARN | Leaked password protection deshabilitada | Auth menos seguro |

### Escalabilidad
- `getRooms` refactorizado (anti N+1, Fase 7) ✅.
- `evaluateGoals` con ventana móvil (Fase 8) ✅.
- RLS initplan (55 WARN): políticas reevalúan `auth.*()` por fila → subóptimo a escala.

## Tarea 39 — Auditoría de Base de Datos

### Performance — Supabase Advisors (95: 38 INFO + 57 WARN)
| Tipo | Nº | Detalle |
|---|---|---|
| FK sin índice | 21 INFO | `conversations.language_id`, `user_language_profiles.cefr_level_id`, `mission_instances.template_id`, etc. |
| Índices sin uso | 17 INFO | `idx_global_events_active`, `idx_chat_rooms_active_type`, `idx_secret_missions_user`, etc. |
| RLS initplan | 55 WARN | Reescribir `auth.uid()` → `(select auth.uid())` |
| Políticas permisivas duplicadas | 1 WARN | `subscription_plans` (2 políticas anon SELECT) |
| Índice duplicado | 1 WARN | `ai_usage_logs` (`idx_ai_usage_logs_user` vs `idx_ai_usage_user_date`) |

### Relaciones/consultas
- Esquema normalizado; 46 tablas públicas.
- Consultas hot: `getRooms` (optimizada), `evaluateGoals` (ventana móvil), `check_ai_audio_quota` (simple).

## Tarea 40 — Auditoría UI
- Paleta/typografía consistentes (AppColors + SpaceGrotesk/Inter/JetBrainsMono) ✅ (orbitron eliminado en salón y HunterStatus).
- `GlassCard`/`SystemWindow`/`SegmentedBar`/`RunicButton` reutilizados ✅.
- Pantallas nuevas (HUD, dungeon map, oracle, inventario, battle pass, quest board, NPC) siguen PlantillasHTML.
- Pendiente: 1 info de const no crítico; `hankenGrotesk` aún en onboarding (fuera de estándar, migrar).

## Tarea 41 — Auditoría UX
- Onboarding 9 pasos + Oracle conversacional ✅.
- Gran Salón con NPC + quest board + prestigio (Fase 7) ✅.
- Microinteracciones tokenizadas (Fase 10) ✅.
- Fricción: doble limitación (cuota mensual + núcleo diario) — documentada en Free_Plan.
- Faltante: strings de onboarding aún en inglés hardcoded (T-105 parcial — solo títulos).

## Tarea 42 — Auditoría de Performance (app)
- TTS on-device ($0, sin red) ✅.
- STT Groq + LLM DeepSeek: costos optimizados (Fase 8) ✅.
- `_runicController` loop infinito en cada GlassCard → candidato a respetar reduce-motion / desactivar en listas.
- Dashboard grande (2040 líneas): candidato a dividir widgets para reducir rebuilds.

## Resumen de acciones priorizadas (deuda QA)
| # | Acción | Severidad | Esfuerzo |
|---|---|---|---|
| QA-1 | Corregir `system_ai_settings` RLS (solo admins) | Alta (seguridad) | Bajo |
| QA-2 | Corregir `vocabulary_items` INSERT `WITH CHECK (true)` | Media | Bajo |
| QA-3 | Revocar EXECUTE anon/authenticated de funciones SECURITY DEFINER internas | Media | Medio |
| QA-4 | Habilitar leaked-password protection | Media | Bajo (config) |
| QA-5 | Reescribir RLS a `(select auth.uid())` (55 políticas) | Baja (perf) | Alto (generado) |
| QA-6 | Índices FK faltantes (21) | Baja | Medio |
| QA-7 | Eliminar índices/índice duplicado sin uso | Baja | Bajo |
| QA-8 | Reducir tamaño de dashboard_screen | Media (mantenibilidad) | Alto |

## Estado de implementación (2026-07-30)
- **QA-1 ✅ aplicado**: `system_ai_settings` → política `ai_settings_service_role` (solo service_role). Verificado.
- **QA-2 ✅ aplicado**: `vocabulary_items` → INSERT validado (longitud + language_id) + lectura autenticada. Verificado.
- **QA-3 ✅ aplicado (v2)**: REVOKE EXECUTE a `PUBLIC` + `anon` de todas las funciones internas; regrant a `authenticated` solo de las del cliente (`add_xp`, `add_gems`, `spend_gems`, `add_fragments`, `increment_pergaminos_max`, `check_ai_audio_quota`, `track_ai_audio_time`). Verificado: anon=false en todas, authenticated=true solo en las de la app. (Causa raíz: heredaban EXECUTE de PUBLIC.)
- **QA-4..QA-8**: pendientes (requieren decisiones/esfuerzo mayor).
