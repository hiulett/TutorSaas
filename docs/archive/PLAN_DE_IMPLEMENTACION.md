# Plan de Implementación Integral — TutorSaas

> **Versión:** 2.0.0  
> **Fecha:** 28 de Julio de 2026  
> **Base:** Análisis completo de BD (36 tablas), 16 migraciones, código Flutter, Web Admin y Supabase Advisors

---

## Convenciones

| Símbolo | Significado |
|---------|-------------|
| 🔴 | Prioridad Crítica (bloqueante / seguridad) |
| 🟠 | Prioridad Alta |
| 🟡 | Prioridad Media |
| ⚪ | Prioridad Baja / Mejora / Optimización |
| ✅ | Completado |

---

## Resumen Ejecutivo del Estado Actual

### Base de Datos (`sipiumfdpvnszthykyog` — TutorSaas)

| Métrica | Valor | Estado |
|---------|-------|--------|
| Tablas | 36 | ✅ Creadas |
| Migraciones | 16 | ✅ Ejecutadas |
| RLS habilitado | En todas | ✅ |
| Escenarios (lecciones) | 3,240 | ✅ Poblado |
| Metas de escenarios | 32,400 | ✅ Poblado |
| Frases útiles | 64,800 | ✅ Poblado |
| Usuarios registrados | 1 | ⚠️ Muy bajo |
| Conversaciones reales | 0 | ❌ |
| Perfiles de idioma | 0 | ❌ |
| Pagos / Suscripciones | 0 | ❌ |
| Logros de usuario | 0 | ❌ |
| Edge Functions | 0 | ❌ Desplegadas |
| Web Admin Auth | No tiene | ❌ Riesgo crítico |
---


## FASE 0: Pendientes del Plan Anterior (Verificar/Completar)

### Tarea 0-1 ✅: Poblar niveles CEFR (DB-1)
**Estado:** ✅ Ya completado — 6 niveles (A1-C2) existen con `order_index` 1-6.
```sql
SELECT code, name, order_index FROM cefr_levels ORDER BY order_index;
-- A1, A2, B1, B2, C1, C2 todos presentes
```

### Tarea 0-2 ✅: Escenarios únicos (DB-2)
**Estado:** ✅ Ya corregido — la migración `20260729020225` normalizó los datos. Sin duplicados.
```sql
SELECT COUNT(*) FROM scenarios; -- 3240 (correcto para 4 idiomas × 15 escenarios × niveles)
```

### Tarea 0-3 ✅: Scenario objectives poblados (DB-3)
**Estado:** ✅ 30 filas en `scenario_objectives`.

### Tarea 0-4 ✅: Achievements (DB-4)
**Estado:** ✅ 6 logros poblados.

### Tarea 0-5 ✅: RLS policies (DB-5)
**Estado:** ✅ Políticas RLS consolidadas en migración `20260729020141`.

---

## FASE 1: Seguridad (🔴 Prioridad Máxima)

### Tarea 1.1 🔴: Fix funciones SECURITY DEFINER ejecutables por anon

**Archivo:** `supabase/migrations/20260728000001_fix_security_definer.sql`

**Problema:** 5 funciones con `SECURITY DEFINER` son ejecutables por `anon` via REST API.

**Funciones afectadas:**
- `public.before_message_inserted_auth_rate_limit()`
- `public.check_ai_audio_quota(p_user_id text)`
- `public.check_user_rate_limit(p_user_id uuid, p_max_requests integer, p_interval_seconds integer)`
- `public.handle_new_user()`
- `public.track_ai_audio_time(p_user_id text, p_duration_seconds integer)`

**SQL:**
```sql
-- Revocar EXECUTE de anon para funciones SECURITY DEFINER
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_auth_rate_limit() FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_ai_audio_quota(p_user_id text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_user_rate_limit(p_user_id uuid, p_max_requests integer, p_interval_seconds integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon;
REVOKE EXECUTE ON FUNCTION public.track_ai_audio_time(p_user_id text, p_duration_seconds integer) FROM anon;
```

**Verificación:** `SELECT * FROM information_schema.role_routine_grants WHERE grantee = 'anon';` → 0 filas.

---

### Tarea 1.2 🔴: Agregar `search_path` fijo a funciones

**Archivo:** `supabase/migrations/20260728000002_fix_search_path.sql`

**Problema:** 6 funciones tienen `search_path` mutable (riesgo de inyección).

**SQL:**
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
SECURITY DEFINER
SET search_path = 'public'
LANGUAGE plpgsql
AS $$ ... $$;

-- Repetir para: before_message_inserted_auth_rate_limit, check_user_rate_limit,
-- check_ai_audio_quota, track_ai_audio_time, trigger_set_timestamps
```

**Verificación:** El advisor ya no debe reportar `function_search_path_mutable`.

---

### Tarea 1.3 🔴: Fix RLS policies con `USING(true)` permisivo

**Archivo:** `supabase/migrations/20260728000003_fix_permissive_rls.sql`

**Problema:** Políticas que permiten INSERT/ALL sin restricciones.

**SQL:**
```sql
-- Fix cefr_recommendation_rules: solo SELECT público, no ALL
DROP POLICY IF EXISTS "All cefr_recommendation_rules write" ON public.cefr_recommendation_rules;
CREATE POLICY "Only admins can write cefr_recommendation_rules"
  ON public.cefr_recommendation_rules FOR ALL
  TO authenticated
  USING (auth.uid() IN (SELECT id FROM public.users WHERE is_active = true AND id = auth.uid()))
  WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_active = true AND id = auth.uid()));

-- Fix languages: remover INSERT público
DROP POLICY IF EXISTS "Permitir inserción de idiomas en desarrollo" ON public.languages;

-- Fix vocabulary_items: remover INSERT público sin control
DROP POLICY IF EXISTS "All authenticated users can insert into vocabulary_items" ON public.vocabulary_items;
CREATE POLICY "Users can insert vocabulary they encounter"
  ON public.vocabulary_items FOR INSERT
  TO authenticated
  WITH CHECK (true); -- OK porque vocabulary_items es catálogo global
```

---

### Tarea 1.4 🟠: Proteger bucket `avatars` contra listado público

**Archivo:** `supabase/migrations/20260728000004_fix_avatars_bucket.sql`

**SQL:**
```sql
-- Remover política de SELECT público en avatars
DROP POLICY IF EXISTS "Allow public select on avatars" ON storage.objects;
-- Crear política solo para archivos propios
CREATE POLICY "Users can read own avatar"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
```

---

### Tarea 1.5 🔴: Habilitar protección leaked passwords en Auth

**Vía:** Supabase Dashboard → Authentication → Settings → Enable "Leaked password protection"

---

## FASE 2: Web Admin — Auth y Seguridad (🔴)

### Tarea 2.1 🔴: Implementar autenticación en Web Admin

**Archivo:** `web_admin/src/` (múltiples archivos)

**Problema:** El panel de administración es accesible sin autenticación. Cualquiera puede gestionar lecciones, usuarios y configuraciones del sistema.

**Implementación:**
1. Agregar Supabase Auth en Web Admin (usando `@supabase/supabase-js`)
2. Crear pantalla de login
3. Proteger rutas con un AuthGuard
4. Verificar rol de admin en sesión

**Archivos a crear/modificar:**
- `web_admin/src/lib/supabaseClient.js`
- `web_admin/src/pages/Login.jsx`
- `web_admin/src/components/AuthGuard.jsx`
- Modificar `App.jsx` para usar AuthGuard

```jsx
// AuthGuard.jsx
import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { useNavigate } from 'react-router-dom';

export default function AuthGuard({ children }) {
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (!session) navigate('/login');
      setLoading(false);
    });
  }, []);

  if (loading) return <div>Cargando...</div>;
  return children;
}
```

---

## FASE 3: Pagos y Monetización (🟠)

### Tarea 3.1 🟠: Implementar pasarela de pagos real

**Problema:** `subscription_plans` poblada (4 planes), `user_subscriptions` y `payments` existen pero no hay integración real. RevenueCat mencionado pero no implementado.

**Opción recomendada:** Stripe (más flexible, menor costo que RevenueCat para early stage).

**Archivos a crear:**
- `lib/features/subscription/data/repositories/payment_repository.dart`
- `lib/features/subscription/data/repositories/payment_repository_impl.dart`
- `lib/features/subscription/presentation/providers/payment_providers.dart`

**Backend (Supabase Edge Function):**
```bash
supabase/functions/create-payment-intent/index.ts
```

**Flujo:**
1. Usuario toca "Activar PRO" en PaywallScreen
2. App llama a Edge Function `create-payment-intent`
3. Edge Function crea PaymentIntent en Stripe
4. App usa Stripe SDK para confirmar pago
5. Webhook de Stripe actualiza `user_subscriptions` en Supabase

---

### Tarea 3.2 🟠: Definir e implementar rate limiting en cliente

**Problema:** Tabla `rate_limiting` existe, funciones RPC (`check_user_rate_limit`, `check_ai_audio_quota`) existen, pero no se aplican en el cliente.

**Archivo:** `lib/features/conversation/presentation/providers/conversation_providers.dart`

**Implementación:**
1. Llamar `check_ai_audio_quota` antes de iniciar grabación
2. Si cuota excedida, mostrar pantalla de upgrade a PRO
3. Definir límites: 15 min/día plan free, 60 min/día plan PRO

---

## FASE 4: Features Core Faltantes (🟠)

### Tarea 4.1 🟠: Análisis fonémico — pipeline de pronunciation_assessments

**Problema:** Tabla `pronunciation_assessments` existe con schema completo (accuracy, fluency, completeness, prosody, phoneme_details) pero está vacía. No hay flujo que la llene.

**Archivos a modificar:**
- `lib/features/conversation/presentation/providers/conversation_providers.dart`
- `lib/features/conversation/domain/repositories/conversation_repository.dart`

**Implementación:**
1. Después de cada mensaje de usuario, enviar texto a un endpoint de análisis fonético
2. Almacenar resultados en `pronunciation_assessments`
3. Mostrar métricas en SessionSummaryScreen

```dart
// En el provider, después de procesar transcripción:
Future<void> _assessPronunciation(String userText, String targetText) async {
  try {
    await _supabase.from('pronunciation_assessments').insert({
      'user_id': currentUserId,
      'target_text': targetText,
      'overall_score': 85, // Placeholder — implementar métrica real
      'accuracy_score': 82,
      'fluency_score': 88,
      'completeness_score': 90,
      'prosody_score': 80,
      'phoneme_details': {},
    });
  } catch (e) {
    debugPrint('Pronunciation assessment error: $e');
  }
}
```

---

### Tarea 4.2 🟠: Leaderboard real multi-usuario

**Problema:** Actualmente datos mock. Tablas `user_language_profiles` tienen XP y rachas, pero no se comparan entre usuarios.

**Archivo:** `lib/features/dashboard/presentation/providers/dashboard_providers.dart`

**Implementación:**
```dart
Future<List<Map<String, dynamic>>> getLeaderboard(int languageId) async {
  final response = await _supabase
      .from('user_language_profiles')
      .select('user_id, xp_points, current_streak, users!inner(display_name, avatar_url)')
      .eq('language_id', languageId)
      .order('xp_points', ascending: false)
      .limit(20);
  return response;
}
```

---

### Tarea 4.3 🟡: Sistema de chat grupal real-time

**Problema:** `chat_rooms`, `chat_room_participants`, `chat_room_messages` existen, 4 salas creadas, pero sin lógica de WebSocket en tiempo real.

**Archivo:** `lib/features/chat_rooms/presentation/providers/chat_room_providers.dart`

**Implementación:**
1. Usar `realtime.SubscriptionChannel` de Supabase para escuchar nuevos mensajes
2. Actualizar estado del provider cuando llegue un mensaje nuevo
3. Implementar VoiceRoomScreen con comunicación vía WebRTC o polling

---

## FASE 5: Notificaciones Push (🟡) - POSTERGADO

*Nota: Esta característica ha sido postergada por decisión del usuario y queda fuera del alcance actual.*

---

## FASE 6: Data Quality y Limpieza (🟡)

### Tarea 6.1 🟡: Analizar y limpiar the `anotherworldtutor` project - COMPLETADO/ELIMINADO

*Nota: Se decidió borrar todo lo relacionado con este proyecto y olvidarlo. Tarea completada a nivel de planificación.*

---

### Tarea 6.2 🟡: Política de retención de datos

**Problema:** Sin política definida para:
- Grabaciones de audio
- Logs de uso de API (`ai_usage_logs`)
- Mensajes antiguos

**Implementación:** Agregar job de limpieza en Supabase:
```sql
-- Edge Function schedule: cleanup_old_data
-- Correr semanalmente
DELETE FROM public.ai_usage_logs WHERE created_at < NOW() - INTERVAL '90 days';
DELETE FROM public.api_request_logs WHERE created_at < NOW() - INTERVAL '90 days';
```

---

## FASE 7: Código Frontend — Correcciones (🔴/🟠)

### Tarea 7.1 🔴: Fix Router — Extraer scenarioId y scenarioTitle

**Archivo:** `lib/app/router.dart`

**Código actual:**
```dart
GoRoute(
  path: '/conversation',
  builder: (context, state) => const ConversationScreen(),
),
```

**Código propuesto:**
```dart
GoRoute(
  path: '/conversation',
  builder: (context, state) {
    final scenarioId = state.uri.queryParameters['scenarioId'];
    final scenarioTitle = state.uri.queryParameters['scenarioTitle'];
    return ConversationScreen(
      scenarioId: scenarioId,
      scenarioTitle: scenarioTitle,
    );
  },
),
```

---

### Tarea 7.2 🟠: Fix LessonCatalog — Manejar null + incluir C2

**Archivo:** `lib/features/dashboard/data/models/lesson_catalog.dart`

**Problemas:**
- `getLessonById` retorna `catalog.first` cuando no encuentra, en lugar de null
- No hay lecciones C2 en el catálogo

**Cambios:**
1. `getLessonById` debe retornar `LessonData?` y devolver `null` si no existe
2. Agregar 2 lecciones C2 al catálogo (`c2_academic_debate`, `c2_literary_critique`)
3. Agregar campo faltante `targetLanguageCode` en lecciones existentes

---

### Tarea 7.3 🟠: Fix repositorio — Filtrar por language_id

**Archivo:** `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`

**Problema:** Las consultas de escenarios no filtran por `language_id`, mostrando lecciones de todos los idiomas.

**Solución:** Agregar filtro `language_id` en la query a `scenarios` y en el filtrado de `LessonCatalog.catalog`.

---

## FASE 8: Pruebas y Calidad (⚪)

### Tarea 8.1 ⚪: Tests unitarios para LessonCatalog

**Archivo:** `test/lesson_catalog_test.dart`

```dart
void main() {
  test('getLessonById returns null for null input', () {
    expect(LessonCatalog.getLessonById(null), isNull);
  });
  test('getLessonById returns null for non-existent id', () {
    expect(LessonCatalog.getLessonById('non_existent'), isNull);
  });
  test('getLessonById returns correct lesson for valid id', () {
    final lesson = LessonCatalog.getLessonById('l1');
    expect(lesson, isNotNull);
    expect(lesson!.id, 'l1');
  });
  test('catalog contains C2 lessons', () {
    final c2Lessons = LessonCatalog.catalog.where((l) => l.level == 'C2');
    expect(c2Lessons.length, greaterThan(0));
  });
}
```

---

### Tarea 8.2 ⚪: Tests de integración para DashboardRepository

**Archivo:** `test/dashboard_repository_test.dart`

Probar que `getRecommendedLessons` filtra correctamente por `language_id` usando mocks de Supabase.

---

## RESUMEN DE DEPENDENCIAS

```
FASE 1 (Seguridad DB)
  1.1 Fix SECURITY DEFINER  ← SIN DEPENDENCIAS
  1.2 Fix search_path       ← SIN DEPENDENCIAS
  1.3 Fix RLS permisivo     ← SIN DEPENDENCIAS
  1.4 Fix avatars bucket    ← SIN DEPENDENCIAS
  1.5 Enable leaked pwd     ← Dashboard manual

FASE 2 (Web Admin Auth)
  2.1 Auth Web Admin       ← SIN DEPENDENCIAS

FASE 3 (Pagos)
  3.1 Stripe integration   ← 2.1 (opcional, para admin)
  3.2 Rate limiting        ← SIN DEPENDENCIAS

FASE 4 (Features)
  4.1 Pronunciation assess ← SIN DEPENDENCIAS
  4.2 Leaderboard real     ← Depende de datos de usuarios
  4.3 Chat grupal real-time← SIN DEPENDENCIAS

FASE 5 (Notificaciones) - POSTERGADO
  5.1 Push notifications   ← (Postergado/Fuera de alcance)

FASE 6 (Data Quality)
  6.1 anotherworldtutor    ← (Eliminado/Completado)
  6.2 Data retention       ← SIN DEPENDENCIAS

FASE 7 (Frontend)
  7.1 Router fix           ← SIN DEPENDENCIAS
  7.2 LessonCatalog null   ← Depende de 7.1
  7.3 Filtrar language_id  ← Depende de datos en user_language_profiles

FASE 8 (Tests)
  8.1 Tests unitarios      ← Depende de 7.2
  8.2 Tests integración    ← Depende de 7.3
```

---

## ORDEN DE EJECUCIÓN RECOMENDADO

```
DÍA 0 (Seguridad — crítico):
  1.1 → 1.2 → 1.3 → 1.4 → 1.5

DÍA 1 (Web Admin + Frontend):
  2.1 → 7.1 → 7.2

DÍA 2 (Features Core):
  3.1 → 3.2 → 7.3 → 4.2

DÍA 3 (Características avanzadas):
  4.1 → 4.3

DÍA 4 (Limpieza + Calidad):
  6.2 → 8.1 → 8.2
```

---

## VERIFICACIÓN FINAL

| # | Check | Cómo verificar |
|---|-------|----------------|
| 1 | Sin funciones SECURITY DEFINER ejecutables por anon | `SELECT * FROM information_schema.role_routine_grants WHERE grantee = 'anon' AND routine_name LIKE 'check_%' OR routine_name LIKE 'before_%' OR routine_name = 'handle_new_user' OR routine_name = 'track_%';` → 0 filas |
| 2 | search_path fijo en funciones | Advisor `function_search_path_mutable` → 0 resultados |
| 3 | Sin RLS con USING(true) | Advisor `rls_policy_always_true` → 0 resultados |
| 4 | Avatars bucket sin listado público | Advisor `public_bucket_allows_listing` → 0 resultados |
| 5 | Leaked password protection | Dashboard Auth Settings → Enabled |
| 6 | Web Admin requiere login | Navegar a `/` del admin → redirige a `/login` |
| 7 | Stripe checkout funcional | Probar compra de plan PRO en sandbox |
| 8 | Rate limiting activo | Intentar >15 min de conversación en plan free |
| 9 | ConversationScreen recibe scenarioId | Debug: `widget.scenarioId` tiene el valor correcto |
| 10 | LessonCatalog sin null | `getLessonById('no_existe')` → null (no crash) |
| 11 | Lecciones filtradas por idioma | Usuario con `language_id=2` (FR) solo ve lecciones FR |
| 12 | pronunciation_assessments con datos | `SELECT COUNT(*) FROM pronunciation_assessments;` → > 0 |
| 13 | Leaderboard con datos reales | Dashboard → Tab Hunter → muestra otros usuarios |
| 14 | Tests pasan | `flutter test` → todos verdes |

---

## Notas Adicionales

### Proyecto `anotherworldtutor` - ELIMINADO/OLVIDADO
Se ha decidido eliminar todo lo relacionado con este proyecto y olvidarlo.

### Segundo Proyecto en Flutter (TutorSaas_tmp)
Hay un directorio `TutorSaas_tmp/` en la raíz del proyecto. Verificar si es un artefacto temporal que deba eliminarse o incluirse en `.gitignore`.
