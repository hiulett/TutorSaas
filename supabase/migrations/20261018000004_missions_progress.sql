-- Issue #5: las misiones no podían completarse.
--
-- `MissionRepository.updateProgress()` era el único escritor de `current_value`
-- y no tenía ningún llamador. No había triggers que reaccionaran a la
-- actividad real, así que toda misión se quedaba en 0 y el botón de reclamar
-- era inalcanzable.
--
-- Este cambio mueve el avance al servidor: la actividad verificable (sesión
-- cerrada, palabra nueva, turno de conversación) avanza la misión y la marca
-- como completada al alcanzar el objetivo.
--
-- También endurece `mission_instances` contra el auto-servicio: un cliente
-- autenticado no puede insertar misiones ya completadas con recompensas
-- arbitrarias ni reclamar una misión que no está completada.

create or replace function public.advance_missions_for_user(
    p_user_id uuid,
    p_type    text,
    p_delta   integer
)
returns integer
language plpgsql
security definer
set search_path = public
as $fn$
declare
    v_count integer := 0;
    v_new   integer;
begin
    if p_user_id is null or p_type is null or p_delta is null or p_delta <= 0 then
        return 0;
    end if;

    with upd as (
        update public.mission_instances
           set current_value = least(target_value, coalesce(current_value, 0) + p_delta),
               status = case
                            when least(target_value, coalesce(current_value, 0) + p_delta) >= target_value
                            then 'completed' else status
                        end,
               completed_at = case
                            when least(target_value, coalesce(current_value, 0) + p_delta) >= target_value
                            then coalesce(completed_at, now()) else completed_at
                        end
         where user_id = p_user_id
           and objective_type = p_type
           and status = 'active'
        returning 1
    )
    select count(*) into v_count from upd;

    return v_count;
end;
$fn$;

revoke all on function public.advance_missions_for_user(uuid, text, integer) from public, anon, authenticated;
grant execute on function public.advance_missions_for_user(uuid, text, integer) to service_role;

-- 1) Sesión cerrada → sesiones, práctica y minutos hablados.
create or replace function public.on_session_reward_advance_missions()
returns trigger
language plpgsql
security definer
set search_path = public
as $t1$
begin
    perform public.advance_missions_for_user(new.user_id, 'sessions', 1);
    perform public.advance_missions_for_user(new.user_id, 'practice_session', 1);
    if coalesce(new.minutes, 0) > 0 then
        perform public.advance_missions_for_user(new.user_id, 'speak_minutes', new.minutes);
    end if;
    return new;
end;
$t1$;

drop trigger if exists trg_session_reward_advance_missions on public.session_reward_ledger;
create trigger trg_session_reward_advance_missions
    after insert on public.session_reward_ledger
    for each row execute function public.on_session_reward_advance_missions();

-- 2) Palabra nueva → vocab_words.
create or replace function public.on_vocabulary_advance_missions()
returns trigger
language plpgsql
security definer
set search_path = public
as $t2$
begin
    perform public.advance_missions_for_user(new.user_id, 'vocab_words', 1);
    return new;
end;
$t2$;

drop trigger if exists trg_vocabulary_advance_missions on public.user_vocabulary;
create trigger trg_vocabulary_advance_missions
    after insert on public.user_vocabulary
    for each row execute function public.on_vocabulary_advance_missions();

-- 3) Turno del alumno → conversation_turns.
create or replace function public.on_message_advance_missions()
returns trigger
language plpgsql
security definer
set search_path = public
as $t3$
declare
    v_uid uuid;
begin
    if new.sender_role is distinct from 'user' then
        return new;
    end if;

    select user_id into v_uid from public.conversations where id = new.conversation_id;
    if v_uid is not null then
        perform public.advance_missions_for_user(v_uid, 'conversation_turns', 1);
    end if;
    return new;
end;
$t3$;

drop trigger if exists trg_message_advance_missions on public.messages;
create trigger trg_message_advance_missions
    after insert on public.messages
    for each row execute function public.on_message_advance_missions();

-- 4) Integridad: un cliente no puede fabricar misiones ni recompensas.
create or replace function public.guard_mission_instance()
returns trigger
language plpgsql
security definer
set search_path = public
as $t4$
begin
    if coalesce(auth.role(), '') <> 'service_role' then
        if tg_op = 'INSERT' then
            new.status := 'active';
            new.current_value := 0;
            new.is_reward_claimed := false;
            new.completed_at := null;
        else
            -- No se pueden alterar recompensas ni objetivos de una misión.
            new.xp_reward := old.xp_reward;
            new.gem_reward := old.gem_reward;
            new.target_value := old.target_value;
            new.objective_type := old.objective_type;
            new.user_id := old.user_id;

            if new.is_reward_claimed and not old.is_reward_claimed and old.status <> 'completed' then
                raise exception 'La misión no está completada';
            end if;
        end if;
    end if;
    return new;
end;
$t4$;

drop trigger if exists trg_guard_mission_instance on public.mission_instances;
create trigger trg_guard_mission_instance
    before insert or update on public.mission_instances
    for each row execute function public.guard_mission_instance();
