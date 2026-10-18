-- Issue #10: baseline de las tablas que existían en producción pero no en el
-- repositorio.
--
-- `supabase/migrations/` no crea estas cinco tablas, que el cliente sí usa:
--   daily_fluency_stats, user_scenario_goals, user_scenario_phrases,
--   user_scenario_fluency, cefr_recommendation_rules
--
-- Las definiciones se extrajeron de la base en producción (columnas, PK,
-- UNIQUE, FK e índices reales). Todo va dentro de un bloque condicional: si la
-- tabla ya existe no se toca nada, así el archivo puede aplicarse también sobre
-- el proyecto actual sin duplicar políticas.
--
-- Nota: `user_progress` no se incluye. Solo aparece en un modelo Dart sin
-- consultas (`UserProgress`), no existe en la base y no se usa en runtime.

do $baseline$
begin

  -- ── daily_fluency_stats ────────────────────────────────────────────────
  if to_regclass('public.daily_fluency_stats') is null then
    create table public.daily_fluency_stats (
        id uuid not null default gen_random_uuid(),
        user_id uuid not null,
        date date not null default current_date,
        avg_response_latency_seconds double precision default 2.5,
        avg_speaking_wpm integer default 110,
        fluency_score integer default 75,
        total_turns_count integer default 1,
        created_at timestamptz default now(),
        updated_at timestamptz default now(),
        constraint daily_fluency_stats_pkey primary key (id),
        constraint daily_fluency_stats_user_id_date_key unique (user_id, date),
        constraint daily_fluency_stats_user_id_fkey
            foreign key (user_id) references public.users (id) on delete cascade
    );
    create index idx_daily_fluency_user_date on public.daily_fluency_stats (user_id, date);
    alter table public.daily_fluency_stats enable row level security;
    create policy "daily_fluency_own" on public.daily_fluency_stats
        for all to authenticated
        using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;

  -- ── user_scenario_goals ────────────────────────────────────────────────
  if to_regclass('public.user_scenario_goals') is null then
    create table public.user_scenario_goals (
        id uuid not null default gen_random_uuid(),
        user_id uuid not null,
        scenario_id character varying(50) not null,
        conversation_id uuid,
        goal_id character varying(50) not null,
        goal_text text not null,
        is_completed boolean default true,
        completed_at timestamptz default now(),
        constraint user_scenario_goals_pkey primary key (id),
        constraint user_scenario_goals_user_id_scenario_id_goal_id_key
            unique (user_id, scenario_id, goal_id),
        constraint user_scenario_goals_user_id_fkey
            foreign key (user_id) references public.users (id) on delete cascade,
        constraint user_scenario_goals_conversation_id_fkey
            foreign key (conversation_id) references public.conversations (id) on delete cascade
    );
    create index idx_user_scenario_goals_user_id_hot on public.user_scenario_goals (user_id);
    create index idx_user_scenario_goals_scenario on public.user_scenario_goals (user_id, scenario_id);
    create index idx_user_scenario_goals_conversation_id_fk on public.user_scenario_goals (conversation_id);
    alter table public.user_scenario_goals enable row level security;
    create policy "scenario_goals_own" on public.user_scenario_goals
        for all to authenticated
        using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;

  -- ── user_scenario_phrases ──────────────────────────────────────────────
  if to_regclass('public.user_scenario_phrases') is null then
    create table public.user_scenario_phrases (
        id uuid not null default gen_random_uuid(),
        user_id uuid not null,
        scenario_id character varying(50) not null,
        conversation_id uuid,
        phrase_id character varying(50) not null,
        phrase_text text not null,
        phonetic_accuracy_score integer default 95,
        is_completed boolean default true,
        completed_at timestamptz default now(),
        constraint user_scenario_phrases_pkey primary key (id),
        constraint user_scenario_phrases_user_id_fkey
            foreign key (user_id) references public.users (id) on delete cascade,
        constraint user_scenario_phrases_conversation_id_fkey
            foreign key (conversation_id) references public.conversations (id) on delete cascade
    );
    alter table public.user_scenario_phrases enable row level security;
    create policy "scenario_phrases_own" on public.user_scenario_phrases
        for all to authenticated
        using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;

  -- ── user_scenario_fluency ──────────────────────────────────────────────
  if to_regclass('public.user_scenario_fluency') is null then
    create table public.user_scenario_fluency (
        id uuid not null default gen_random_uuid(),
        user_id uuid not null,
        scenario_id character varying(50) not null,
        best_response_latency_seconds double precision default 2.0,
        avg_speaking_wpm integer default 120,
        fluency_score integer default 80,
        updated_at timestamptz default now(),
        constraint user_scenario_fluency_pkey primary key (id),
        constraint user_scenario_fluency_user_id_scenario_id_key unique (user_id, scenario_id),
        constraint user_scenario_fluency_user_id_fkey
            foreign key (user_id) references public.users (id) on delete cascade
    );
    alter table public.user_scenario_fluency enable row level security;
    create policy "scenario_fluency_own" on public.user_scenario_fluency
        for all to authenticated
        using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;

  -- ── cefr_recommendation_rules ──────────────────────────────────────────
  if to_regclass('public.cefr_recommendation_rules') is null then
    create table public.cefr_recommendation_rules (
        id uuid not null default gen_random_uuid(),
        level_code text not null,
        strategy_name text not null,
        target_category text not null,
        description text,
        created_at timestamptz default timezone('utc'::text, now()),
        constraint cefr_recommendation_rules_pkey primary key (id)
    );
    alter table public.cefr_recommendation_rules enable row level security;
    create policy "cefr_rules_read" on public.cefr_recommendation_rules
        for select to authenticated using (true);
  end if;

end;
$baseline$;
