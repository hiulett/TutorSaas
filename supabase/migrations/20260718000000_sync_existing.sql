-- ==========================================================
-- ELIMINAR RESTRICCIÓN NOT NULL DE EMAIL E IMPORTAR USUARIOS
-- ==========================================================

-- 1. Permite que el email sea nulo para soportar inicios de sesión anónimos o SSO sin email
ALTER TABLE public.users ALTER COLUMN email DROP NOT NULL;

-- 2. Insert any missing users from auth.users into public.users
INSERT INTO public.users (id, email, display_name, avatar_url, native_language, is_active)
SELECT 
    id, 
    email, 
    COALESCE(
        raw_user_meta_data->>'full_name', 
        raw_user_meta_data->>'display_name', 
        (CASE WHEN email IS NOT NULL THEN split_part(email, '@', 1) ELSE NULL END), 
        'Estudiante'
    ), 
    raw_user_meta_data->>'avatar_url',
    'es',
    TRUE
FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- 3. Initialize default user settings for any user who doesn't have them
INSERT INTO public.user_settings (user_id)
SELECT id FROM public.users
ON CONFLICT (user_id) DO NOTHING;
