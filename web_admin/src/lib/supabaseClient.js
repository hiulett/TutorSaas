import { createClient } from '@supabase/supabase-js';

// Las claves se leen de web_admin/.env (ver .env.example). Nunca se
// versionan en el repo.
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Configura VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY en web_admin/.env (ver .env.example).',
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
