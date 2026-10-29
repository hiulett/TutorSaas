-- P-37 (#122): ajustes de respuesta sensorial.
--
-- Vibración y sonido del sistema en las celebraciones (meta diaria, subida de
-- nivel, repaso). Se guardan en `user_settings` para que el ajuste persista y
-- el cliente no tenga que adivinarlo.

alter table public.user_settings
  add column if not exists haptics_enabled boolean not null default true,
  add column if not exists sound_enabled boolean not null default true;

comment on column public.user_settings.haptics_enabled is
  'Vibracion en celebraciones (P-37).';
comment on column public.user_settings.sound_enabled is
  'Sonidos del sistema en celebraciones (P-37).';
