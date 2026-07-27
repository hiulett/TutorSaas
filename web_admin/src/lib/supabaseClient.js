import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://sipiumfdpvnszthykyog.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpcGl1bWZkcHZuc3p0aHlreW9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzMzA3MDIsImV4cCI6MjA5OTkwNjcwMn0.VXKRRFqsCNtAmdJtvaGvHQCA7ZNANjxxrBSmshed0jQ';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
