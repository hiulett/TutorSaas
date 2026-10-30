-- P-34f (#198): modo hold-to-talk del micrófono.
--
-- El ajuste se guarda en `user_settings` y la app lo lee al abrir la
-- conversación (`micModeHoldToTalkProvider`). Por defecto `false`: se mantiene
-- el tap-to-toggle histórico hasta que el alumno lo active en Ajustes > AUDIO.
--
-- Sin cambios de RLS: `user_settings` ya tiene políticas por fila y la columna
-- hereda el mismo permiso de lectura/escritura del propio usuario.

alter table public.user_settings
  add column if not exists mic_mode_hold_to_talk boolean not null default false;

comment on column public.user_settings.mic_mode_hold_to_talk is
  'P-34f (#198): true = mantener pulsado el micrófono para grabar y soltar para enviar; false = tap-to-toggle.';
