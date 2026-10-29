-- P-34c (#119): preferencias de voz del tutor.
--
-- `tutor_voice_id` ya existía (sin uso). Se añade `tts_speed` para persistir
-- el multiplicador de velocidad del motor TTS (0.75x / 1x / 1.25x).
-- Aplicada por MCP (apply_migration) con esta misma versión.

alter table public.user_settings
  add column if not exists tts_speed numeric(3,2) not null default 1.00;

alter table public.user_settings
  drop constraint if exists user_settings_tts_speed_check;
alter table public.user_settings
  add constraint user_settings_tts_speed_check
  check (tts_speed in (0.75, 1.00, 1.25));

comment on column public.user_settings.tts_speed is
  'P-34c: multiplicador de velocidad del TTS del tutor (0.75x, 1x, 1.25x).';
comment on column public.user_settings.tutor_voice_id is
  'P-34c: nombre de la voz TTS del tutor (null = voz del sistema).';
