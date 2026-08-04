-- ============================================================================
-- TutorSaas — Onboarding v3: Stats de combate para hunter_classes (radar 6-D)
-- Fecha: 2026-08-04
--
-- Añade las 6 estadísticas de combate (0-100) usadas por el gráfico de radar
-- de la pantalla Create Your Character. Valores coherentes con el rol/elemento
-- de cada clase. Idempotente: add column if not exists + update.
-- ============================================================================

alter table public.hunter_classes
  add column if not exists stats_attack int not null default 50,
  add column if not exists stats_defense int not null default 50,
  add column if not exists stats_magic int not null default 50,
  add column if not exists stats_speed int not null default 50,
  add column if not exists stats_support int not null default 50,
  add column if not exists stats_survival int not null default 50;

-- Actualiza valores por clase (ataque, defensa, magia, velocidad, soporte, supervivencia)
update public.hunter_classes set
  stats_attack = 85, stats_defense = 55, stats_magic = 20, stats_speed = 60, stats_support = 35, stats_survival = 70
  where id = 'warrior';

update public.hunter_classes set
  stats_attack = 35, stats_defense = 45, stats_magic = 95, stats_speed = 40, stats_support = 60, stats_survival = 45
  where id = 'mage';

update public.hunter_classes set
  stats_attack = 80, stats_defense = 35, stats_magic = 30, stats_speed = 95, stats_support = 25, stats_survival = 50
  where id = 'assassin';

update public.hunter_classes set
  stats_attack = 55, stats_defense = 95, stats_magic = 15, stats_speed = 35, stats_support = 70, stats_survival = 90
  where id = 'knight';

update public.hunter_classes set
  stats_attack = 65, stats_defense = 40, stats_magic = 40, stats_speed = 80, stats_support = 45, stats_survival = 55
  where id = 'archer';

update public.hunter_classes set
  stats_attack = 45, stats_defense = 40, stats_magic = 85, stats_speed = 55, stats_support = 75, stats_survival = 45
  where id = 'summoner';

update public.hunter_classes set
  stats_attack = 60, stats_defense = 80, stats_magic = 55, stats_speed = 40, stats_support = 90, stats_survival = 85
  where id = 'paladin';

update public.hunter_classes set
  stats_attack = 50, stats_defense = 45, stats_magic = 90, stats_speed = 35, stats_support = 50, stats_survival = 55
  where id = 'necromancer';
