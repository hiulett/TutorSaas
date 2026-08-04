-- ============================================================================
-- TutorSaas — RPG-04: Colecciones del Cazador (Trofeos del Reino del Verbo)
-- Fecha: 2026-07-31
--
-- Catálogo de coleccionables (hunter_collection_catalog) + colecciones
-- desbloqueadas por cada cazador (hunter_collections).
-- Idempotente: `create table if not exists` + seed con `on conflict do nothing`.
-- ============================================================================

-- ── Catálogo de colecciones ─────────────────────────────────────────────────
create table if not exists public.hunter_collection_catalog (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  description text,
  category text not null default 'boss', -- 'boss' | 'portal' | 'episodio'
  rarity text not null default 'comun',  -- 'comun' | 'raro' | 'epico' | 'legendario'
  icon_emoji text
);

-- ── Colecciones desbloqueadas por cazador ───────────────────────────────────
create table if not exists public.hunter_collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  collection_code text not null, -- ej. 'boss_goblin', 'boss_espectro', 'portal_a1'...
  unlocked_at timestamptz not null default now(),
  unique (user_id, collection_code)
);

-- ── Row Level Security ──────────────────────────────────────────────────────
alter table public.hunter_collection_catalog enable row level security;
alter table public.hunter_collections enable row level security;

-- Catálogo: lectura para todos los autenticados
drop policy if exists "catalog_read_authenticated" on public.hunter_collection_catalog;
create policy "catalog_read_authenticated"
  on public.hunter_collection_catalog
  for select
  to authenticated
  using (true);

-- Colecciones: cada cazador solo lee las suyas
drop policy if exists "collections_select_owner" on public.hunter_collections;
create policy "collections_select_owner"
  on public.hunter_collections
  for select
  to authenticated
  using (user_id = auth.uid());

-- Los inserts/updates/deletes se ejecutan únicamente con service_role
-- (no se exponen políticas de escritura a anon/authenticated).

-- ── Seed del catálogo ───────────────────────────────────────────────────────
insert into public.hunter_collection_catalog
  (code, name, description, category, rarity, icon_emoji)
values
  ('boss_goblin',   'Goblin del Bosque',     'Derrota al jefe Goblin en la mazmorra A1.',           'boss',    'comun',      '👹'),
  ('boss_espectro', 'Espectro de las Ruinas','Derrota al jefe Espectro en la mazmorra A2.',         'boss',    'raro',       '👻'),
  ('boss_dragon',   'Dragón del Abismo',     'Derrota al jefe Dragón en la arena final.',           'boss',    'legendario', '🐉'),
  ('portal_a1',     'Portal A1',             'Cruza el portal del Reino del Verbo A1.',             'portal',  'epico',      '🌀'),
  ('portal_b1',     'Portal B1',             'Cruza el portal del Reino del Verbo B1.',             'portal',  'epico',      '🌀'),
  ('portal_c1',     'Portal C1',             'Cruza el portal del Reino del Verbo C1.',             'portal',  'epico',      '🌀')
on conflict (code) do nothing;
