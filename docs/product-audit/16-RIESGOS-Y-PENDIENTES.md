# 16 — Riesgos y pendientes

> Medición: 25-oct-2026.
> **Escalas:** Probabilidad — **M** medida (dato/código concluyente), **A** alta
> (estimación), **B** baja (estimación). Impacto — **1** cosmético, **2** fricción,
> **3** pérdida de confianza/datos, **4** legal/económico, **5** inoperativo.
> Prioridad = probabilidad × impacto, ajustada por si bloquea la fase 2.

---

## 1. Registro de riesgos

| ID | Riesgo | Módulo | Evidencia | Prob. | Impacto | Prioridad | Recomendación preliminar |
|---|---|---|---|---|---|---|---|
| R-01 | El cliente consume IA sin pagar maná | IA / economía | `llm-proxy` no consulta maná (doc 07 §5) | M | 4 | **P0** | Validar saldo/cuota de maná en el proxy o aceptar el coste como decisión explícita |
| R-02 | Error de IA se muestra y guarda como respuesta del tutor | IA / UX | `repo:207-217` | M | 3 | **P0** | No persistir ni narrar errores como contenido; mensaje de sistema con reintento |
| R-03 | Botón de dev borra el progreso del usuario en producción | Auth / UX | `settings_screen.dart:179,1257-1346` | M | 3 | **P0** | Gate por `kDebugMode` o eliminar del build release |
| R-04 | No hay forma de borrar cuenta ni exportar datos desde la app | Legal / tiendas | RPC sin UI (doc 09) | M | 4 | **P0** | Exponer ambos flujos en ajustes con confirmación |
| R-05 | Resumen de sesión con cifras fijas y drop repetible | Juego / UX | doc 03 §3.6; `session_drop_controller.dart` | M | 3 | **P0** | Consumir la respuesta real de `apply_session_rewards`; idempotencia del drop |
| R-06 | Racha no se actualiza y el banner está siempre activo | Juego / retención | doc 08 §5; `progress_tab_view.dart:46-48` | M | 3 | **P0** | Mover racha a RPC y alimentar el banner con datos reales |
| R-07 | Importes de XP/oro/gemas elegidos por el cliente en misiones | Economía | `mission_repository.dart:252-258`; RPC `add_*` | M | 3 | **P1** | Recompensa de misión por RPC con importe del servidor |
| R-08 | `add_mana_item` sin `auth.uid()` y ejecutable por `anon` | Seguridad | `pg_proc` (prod) | M | 3 | **P1** | Añadir guarda de identidad y revocar a anon |
| R-09 | `grant_next_seat` sin validación de identidad/rol | Seguridad | `pg_proc` (prod) | M | 2 | **P1** | Validar moderador |
| R-10 | Sin medición de tokens/coste de IA | Negocio | `ai_usage_logs` = 0 | M | 4 | **P1** | Instrumentar en `llm-proxy` (modelo, tokens, latencia, coste) |
| R-11 | Maná no comprable: el free se agota sin salida | Monetización | doc 10 §6 | M | 2 | **P2** | Decidir si se reactiva venta de maná o se ajusta el allowance |
| R-12 | Premium no ofrece nada distinto de más maná | Monetización | doc 10 §3 | M | 3 | **P1** | Definir valor premium real o cambiar el mensaje |
| R-13 | Currículo duplicado Dart/BD con umbrales distintos | Pedagogía | doc 05 §2, §5 | M | 2 | **P1** | Una sola fuente y un solo criterio de "completada" |
| R-14 | Sub-misión de refuerzo nunca se genera (fallo silencioso) | Pedagogía / IA | doc 07 §2.4 | M | 2 | **P2** | Corregir el mapeo de `skill_focus` y dejar de silenciar el error |
| R-15 | Métricas de pronunciación/fluidez no miden lo que afirman | Pedagogía / confianza | doc 05 §1 | M | 3 | **P1** | Etiquetar como estimación en UI o medir de verdad |
| R-16 | Migraciones no reproducen el esquema; `db push` prohibido | Operación | `docs/runbooks/MIGRATION_STATUS.md` | M | 4 | **P1** | Baseline reproducible; bloquear cambios manuales |
| R-17 | Sin staging; pruebas contra producción | Operación | `docs/OPERATIONS.md:15-16` | M | 3 | **P2** | Proyecto de staging con datos sintéticos |
| R-18 | Sin push ni email: no hay retorno | Retención | doc 11 §1 | M | 3 | **P1** | Instrumentar permiso y campaña mínima |
| R-19 | Análitica insuficiente (8 eventos, sin navegación ni aprendizaje) | Analítica | doc 17 | M | 3 | **P1** | Taxonomía mínima de eventos |
| R-20 | El error tracker no envía nada | Calidad | `error_tracker.dart` | M | 2 | **P2** | Integrar crash reporting |
| R-21 | 13 dependencias sin uso y código muerto extenso | Mantenibilidad | doc 02 §12 | M | 1 | **P3** | Limpieza periódica |
| R-22 | `system_ai_settings` no se usa (configuración engañosa) | Operación | doc 07 §1 | M | 2 | **P2** | Leer la config o retirar el panel |
| R-23 | CORS `*` y `/health` con información en el proxy | Seguridad | `index.ts:48-119` | M | 1 | **P3** | Restringir origen y detalle |
| R-24 | `ai_usage_logs` con política FOR ALL del dueño | Seguridad | prod | A | 2 | **P2** | SELECT del dueño, INSERT solo servidor |
| R-25 | Dependencia total de RevenueCat para el paywall | Monetización | `paywall_screen.dart:122` | M | 2 | **P3** | Documentar el fallback y probar el estado sin offerings |
| R-26 | Fuga de datos personales al LLM sin aviso in-app | Privacidad | doc 07 §5 | A | 3 | **P2** | Aviso y sección de privacidad |
| R-27 | Tests no cubren SSE, proxy ni evaluación | Calidad | doc 12 | M | 2 | **P2** | Tests de contrato del proxy y del parser |
| R-28 | Nombre del producto inconsistente (Dungeon of English / DungeonSpeak / TutorSaas) | Marca | `app.dart:31`; manifest; `pubspec` | M | 1 | **P3** | Unificar |

---

## 2. Dependencias críticas

| Dependencia | Qué se cae con ella | Mitigación actual |
|---|---|---|
| Supabase (único backend, sin staging) | Todo | Caché de arranque y placeholders |
| DeepSeek | Conversación, Oráculo, refuerzo | Mensaje de error (mal manejado) |
| Groq Whisper | Voz | Sin alternativa (el chat de texto existe) |
| RevenueCat/Play | Compras y estado premium | Fallback a `user_subscriptions` |
| LiveKit | Salas de voz | Ninguna |
| Cron de Supabase | Rotación de misiones, purga | Manual |

---

## 3. Preguntas sin resolver y qué haría falta

| # | Pregunta | Recurso necesario |
|---|---|---|
| Q1 | ¿Hay usuarios reales o solo pruebas? | Acceso a Play Console (instalaciones, retención) |
| Q2 | ¿Cuál es el coste real de IA por sesión? | Tokens por llamada (hoy no se registran) |
| Q3 | ¿Se vende algo? | RevenueCat/Play: transacciones e ingresos |
| Q4 | ¿La tasa de 429 del proxy afecta a usuarios? | Logs de `function_logs` en ventanas de uso |
| Q5 | ¿El examen del Oráculo termina siempre? | Tasa de `oracle_assessments` sin cierre |
| Q6 | ¿Qué pantallas abandonan los usuarios? | Eventos de navegación (no existen) |
| Q7 | ¿El trigger de guarda bloquea escrituras legítimas en producción? | Confirmar con logs de Postgres o prueba con rol `authenticated` |
| Q8 | ¿El avatar se sube y se sirve bien? | Prueba manual con Storage/RLS |
| Q9 | ¿Los planes legacy se muestran en algún lado? | Revisar RevenueCat offerings |
| Q10 | ¿La app arranca sin red de forma aceptable? | Prueba en dispositivo en modo avión |

---

## 4. Limitaciones de esta auditoría

1. **No se ejecutó la app** en dispositivo ni emulador: los estados visuales,
   permisos y latencias no se observaron.
2. **No se probaron compras** (license testers de Play requieren cuenta).
3. **No se inspeccionaron los logs** de Edge Functions ni de Auth en ventanas
   reales de uso.
4. **El panel `web_admin`** se revisó solo a nivel de servicio y rutas, no de
   cada pantalla.
5. **Los conteos de filas** son una foto del 25-oct-2026 y pueden incluir cuentas
   de prueba.
6. **La documentación previa** (`docs/*.md`) contiene afirmaciones desactualizadas;
   este audit las corrige donde se pudo verificar.
