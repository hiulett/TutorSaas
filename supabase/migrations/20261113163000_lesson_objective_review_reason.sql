-- Objetivos débiles: motivo de revisión (CUR-05).
--
-- `needs_review` ya existe desde CUR-01, pero la historia pide el **motivo**:
-- sin él la cola editorial no se puede priorizar ni se entiende al revisarla.
--
-- Vocabulario del motivo (lo escribe el importador, `scripts/import_curriculum.py`):
--   single_keyword       la lista de palabras clave tiene una sola entrada, así
--                        que cualquier aparición de esa palabra da el objetivo
--                        por cumplido.
--   example_equals_text  el ejemplo repite el texto del objetivo, de modo que no
--                        demuestra nada que el propio objetivo no diga.
-- Varios motivos se guardan separados por coma. Si el objetivo no es débil,
-- `needs_review = false` y `review_reason` queda NULL.
--
-- Aditiva y reejecutable: no toca filas ni crea versiones nuevas.

alter table public.lesson_objectives
  add column if not exists review_reason text;

comment on column public.lesson_objectives.review_reason is
  'Motivo de needs_review (CUR-05): single_keyword | example_equals_text. Varios separados por coma; NULL si el objetivo no es débil.';
