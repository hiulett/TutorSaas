-- Issue #11: `messages` con dos esquemas incompatibles.
--
-- El esquema vivo usa `sender_role` + `text`, pero el cliente sigue
-- consultando `role` + `content_text` en `getUserAchievements`
-- (`dashboard_repository_impl.dart`), lo que producía un 400 silencioso y
-- logros siempre vacíos.
--
-- En lugar de esperar a una release, se exponen ambos nombres como columnas
-- generadas de solo lectura: mismo dato, sin duplicar almacenamiento y sin
-- romper la app instalada.

alter table public.messages
  add column if not exists content_text text
  generated always as (text) stored;

alter table public.messages
  add column if not exists role character varying
  generated always as (sender_role) stored;

-- Issue #14: el rango debe pertenecer a la escala cerrada.
-- Los datos actuales solo contienen F, E y NULL, así que la restricción
-- valida sin rechazar filas existentes.

alter table public.user_language_profiles
  drop constraint if exists chk_game_rank;
alter table public.user_language_profiles
  add constraint chk_game_rank check (
    game_rank is null or game_rank in ('F', 'E', 'D', 'C', 'B', 'A', 'S', 'SS', 'SSS')
  );

alter table public.oracle_assessments
  drop constraint if exists chk_oracle_rank;
alter table public.oracle_assessments
  add constraint chk_oracle_rank check (
    game_rank is null or game_rank in ('F', 'E', 'D', 'C', 'B', 'A', 'S', 'SS', 'SSS')
  );

alter table public.oracle_assessments
  drop constraint if exists chk_oracle_cefr;
alter table public.oracle_assessments
  add constraint chk_oracle_cefr check (
    cefr_level is null or cefr_level in ('PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2')
  );
