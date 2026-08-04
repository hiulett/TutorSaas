-- ============================================================================
-- TutorSaas — OBS-02 (fase 1): tabla de eventos de uso para analytics de retención
-- Fecha: 2026-07-31
--
-- Complementa `api_request_logs` (logs de API). Esta tabla registra eventos de
-- sesión clave: 'app_open' | 'session_start' | 'session_end' | 'invoke_llm' |
-- 'claim_daily' | 'purchase_item'.
-- ============================================================================

create table if not exists public.analytics_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_name text not null,          -- 'app_open' | 'session_start' | 'session_end' | 'invoke_llm' | 'claim_daily' | 'purchase_item'
  properties jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_analytics_events_user_id ON public.analytics_events(user_id);
create index if not exists idx_analytics_events_created_at ON public.analytics_events(created_at desc);

alter table public.analytics_events enable row level security;

drop policy if exists "analytics_events_select_owner" on public.analytics_events;
create policy "analytics_events_select_owner" on public.analytics_events
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "analytics_events_insert_owner" on public.analytics_events;
create policy "analytics_events_insert_owner" on public.analytics_events
  for insert to authenticated with check (auth.uid() = user_id);
