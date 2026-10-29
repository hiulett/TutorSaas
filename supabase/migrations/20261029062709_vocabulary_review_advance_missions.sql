-- Issue #109 (P-24) · El repaso SRS también avanza las misiones de vocabulario
-- desde el servidor. Versión real registrada por Supabase: 20261029062709
--
-- Antes: el cliente llamaba a advance_my_missions('vocab_words') al cerrar
-- cada tarjeta SRS (srs_flashcard_modal.dart). El trigger
-- trg_vocabulary_advance_missions solo cubre INSERT en user_vocabulary (alta de
-- palabra), así que al quitar la llamada de cliente se perdía el avance del
-- repaso. Esta migración mueve ese avance al servidor, sobre
-- vocabulary_reviews, que es donde record_vocabulary_review registra cada
-- repaso. No hay doble conteo: alta → INSERT en user_vocabulary (trigger
-- existente); repaso → INSERT en vocabulary_reviews (trigger nuevo).
create or replace function public.on_vocabulary_review_advance_missions()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.user_id is null then
    return new;
  end if;
  perform public.advance_missions_for_user(new.user_id, 'vocab_words', 1);
  return new;
end;
$$;

comment on function public.on_vocabulary_review_advance_missions() is
  'Issue #109: cada repaso SRS cuenta 1 palabra para las misiones vocab_words (servidor, sin llamada del cliente).';

drop trigger if exists trg_vocabulary_review_advance_missions on public.vocabulary_reviews;
create trigger trg_vocabulary_review_advance_missions
  after insert on public.vocabulary_reviews
  for each row execute function public.on_vocabulary_review_advance_missions();
