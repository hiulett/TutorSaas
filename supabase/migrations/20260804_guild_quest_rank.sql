-- ============================================================================
-- TutorSaas — Gremio v2: rangos y categorías para el pool de misiones
-- Fecha: 2026-08-04
--
-- Añade a `guild_quest_pool` el rango mínimo del gremio requerido (game_rank:
-- E, D, C, B, A, S...) y una categoría de misión. Las misiones de rango
-- superior al del aventurero no podrán aceptarse (gate en la app).
-- Idempotente.
-- ============================================================================

alter table public.guild_quest_pool
  add column if not exists game_rank varchar(5),
  add column if not exists category varchar(40);

-- Seeds: asignar rango y categoría a las misiones del pool (por title real).
update public.guild_quest_pool set game_rank = 'E', category = 'speaking'    where title = 'El Viajero Frecuente';
update public.guild_quest_pool set game_rank = 'E', category = 'vocabulary'  where title = 'El Librero Curioso';
update public.guild_quest_pool set game_rank = 'D', category = 'speaking'    where title = 'El Mensajero Veloz';
update public.guild_quest_pool set game_rank = 'D', category = 'writing'     where title = 'El Escriba Diligente';
update public.guild_quest_pool set game_rank = 'E', category = 'speaking'    where title = 'El Eco del Guerrero';
update public.guild_quest_pool set game_rank = 'D', category = 'speaking'    where title = 'El Afinador de Vocales';
update public.guild_quest_pool set game_rank = 'B', category = 'argumentation' where title = 'El Gramático';
update public.guild_quest_pool set game_rank = 'C', category = 'argumentation' where title = 'El Políglota';
update public.guild_quest_pool set game_rank = 'C', category = 'speaking'    where title = 'El Orador Incansable';
update public.guild_quest_pool set game_rank = 'A', category = 'speaking'    where title = 'El Campeón del Gremio';
update public.guild_quest_pool set game_rank = 'D', category = 'collaborative' where title = 'La Lluvia de Maná';
update public.guild_quest_pool set game_rank = 'C', category = 'collaborative' where title = 'La Cacería Colectiva';
update public.guild_quest_pool set game_rank = 'B', category = 'collaborative' where title = 'El Banquete del Gremio';
