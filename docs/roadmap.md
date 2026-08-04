# Roadmap — TutorSaas

## Fases Completadas

### Fase 1: Corrección de Base de Datos
- [x] Poblar niveles CEFR faltantes (A2, B2, C1, C2 añadidos)
- [x] Eliminar escenarios duplicados (30→15)
- [x] Repoblar scenario_objectives
- [x] Seed de achievements
- [x] Verificar y corregir políticas RLS
- [x] Corrección de schema de conversaciones
- [x] Corrección de RLS en conversaciones
- [x] Migraciones masivas de lecciones (15+ por nivel/idioma)

### Fase 2: Corrección de Código Frontend
- [x] Router extrae scenarioId y scenarioTitle
- [x] LessonCatalog maneja null correctamente + nivel C2 añadido
- [x] Dashboard pasa scenarioTitle en navegación
- [x] ConversationScreen maneja null de LessonData
- [x] ConversationNotifier maneja session sin scenarioId
- [x] System prompt incluye C2

### Fase 3: Motor de Recomendaciones
- [x] Filtrar escenarios por language_id
- [x] Sort por intereses siempre activo
- [x] Filtrar LessonCatalog por idioma + incluir C2

### Fase 4: Dashboard y UI
- [x] IDs de fallback válidos en dashboard
- [x] Mostrar nivel C2 correctamente en LessonCard
- [x] Agregar C2 como opción en onboarding
- [x] Incluir C2 en study plan y resultado de placement
- [x] Texto dinámico en onboarding según idioma seleccionado
- [x] Separación de niveles de corrección (important_only/short/moderate/detailed)

### Fase 5: Modelos
- [x] UserSettings completo con interests y motivation

## Items Pendientes

### Prioridad Crítica
- [ ] **Implementar pasarela de pagos real** — RevenueCat o Stripe (schema listo, código pendiente)
- [ ] **Mover API keys a variables de entorno seguras** — evitar hardcode en código fuente
- [ ] **Rate limiting del lado del cliente** — evitar abuso de APIs en plan gratuito

### Prioridad Alta
- [ ] **Notificaciones push** — Firebase Cloud Messaging o Supabase Realtime (Postergado)
- [ ] **Análisis fonémico profundo** — tabla `pronunciation_assessments` existe pero sin flujo de llenado
- [ ] **Leaderboard multi-usuario real** — actualmente datos mock
- [ ] **Límites del plan gratuito** — definir minutos/día, conversaciones/semana
- [ ] **Modo offline** — caché local con shared_preferences para catálogo de lecciones

### Prioridad Media
- [ ] **Salas de voz grupales en tiempo real** — WebSocket declarado pero lógica pendiente
- [ ] **Estrategia de rotación de API keys** — balanceo entre múltiples keys
- [ ] **Política de retención de datos** — grabaciones de audio, logs
- [ ] **Sistema prompt del LLM en Supabase** — para modificación sin release
- [ ] **Autenticación para Web Admin** — actualmente acceso directo sin login
- [ ] **Soporte C2 completo** — verificar que todos los filtros y UI incluyan C2

### Prioridad Baja
- [ ] **Compartir progreso en redes sociales**
- [ ] **Modo duo** — dos estudiantes practicando juntos con mediación de IA
- [ ] **Traducción en tiempo real** de respuestas del IA al español
- [ ] **Expansión a más idiomas** — portugués, japonés, coreano
- [ ] **Modo B2B corporativo** — capacitación de equipos
- [ ] **Clonación de voz y avatares** fotorrealistas
- [ ] **Pruebas automatizadas** — tests unitarios para LessonCatalog, DashboardRepository

---

## Estado actual (Fases 2-11, 2026-07-30)

### Fases implementadas
| Fase | Estado | Detalle |
|---|---|---|
| 2 � User Experience | ? | l10n, idioma persistente, Oracle conversacional, pa�s |
| 3 � Dashboard | ? | HUD, mapa de mazmorras, accesos r�pidos |
| 4 � Conversaciones | ? | Or�culo, metas animadas, t�cticas, recompensas |
| 5 � Misiones | ? | Motor completo + rotaci�n + mission board |
| 6 � Econom�a | ? | Inventario, battle pass, daily rewards, oro/fragmentos, invocaciones |
| 7 � Guild | ? | Sal�n con NPC, quest board, mesas DB, prestigio, pr�ctica IA |
| 8 � IA | ? | Costos optimizados, plan gratuito, monetizaci�n |
| 9 � RPG | ?? | Items + modificadores implementados; colecciones/trofeos pendientes |
| 10 � Microinteracciones | ? | Tokens, RunicButton, efectos |
| 11 � QA | ?? | Auditor�a: **lista para beta cerrada**; bloqueadores de seguridad en script |

### Pr�ximos pasos (beta p�blica)
1. Aplicar 20260730_phase11_security_fixes.sql (QA-1/2/3).
2. IA-01: mover API keys a dart-define + rotar.
3. QA-5: RLS (select auth.uid()) (perf).
4. Versionar migraciones manuales.
5. Ampliar tests.
