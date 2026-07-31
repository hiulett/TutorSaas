-- ============================================================================
-- Pricing Update: Aggressive low prices (unbeatable in market)
-- Apply when DB writes are available
-- ============================================================================

-- Update existing plans with aggressive pricing
UPDATE subscription_plans SET
  price = '$0.00',
  monthly_audio_minutes_limit = 30,
  features = '["5 conversaciones con IA/día", "Corrección gramatical básica", "Acceso al mapa de mazmorras", "1 examen boss/semana", "Historial de 7 días"]',
  description = 'Practica gratis con límites diarios'
WHERE id = 'free';

UPDATE subscription_plans SET
  price = '$1.99',
  monthly_audio_minutes_limit = 300,
  badge_tag = 'MÁS ECONÓMICO',
  features = '["Conversaciones IA ilimitadas", "Corrección gramatical avanzada", "Speech DNA completo", "Blind Listening ilimitado", "Modo Boss ilimitado", "Historial ilimitado"]',
  description = 'Acceso completo por el precio de un café'
WHERE id = 'monthly';

UPDATE subscription_plans SET
  price = '$14.99',
  monthly_audio_minutes_limit = 1200,
  badge_tag = 'AHORRA 37%',
  features = '["Todo lo del plan mensual", "1.200 min/mes de audio IA", "Títulos y cosméticos exclusivos", "Battle Pass incluido", "Soporte prioritario"]',
  description = 'Menos de $1.25/mes — el mejor valor'
WHERE id = 'annual';

UPDATE subscription_plans SET
  price = '$29.99',
  monthly_audio_minutes_limit = 600,
  badge_tag = 'ACCESO TOTAL',
  features = '["Todo lo del plan anual", "600 min/mes de por vida", "Todos los cosméticos futuros", "Acceso a expansiones premium", "Prioridad máxima en servidores"]',
  description = 'Pago único, beneficios de por vida'
WHERE id = 'lifetime';

-- Or insert if tables are being initialized
INSERT INTO subscription_plans (id, name, price, billing_cycle, monthly_audio_minutes_limit, order_index, description, badge_tag, features, is_active)
VALUES
  ('free', 'Plan Gratuito', '$0.00', 'monthly', 30, 1, 'Practica gratis con límites diarios', 'BÁSICO', '["5 conversaciones con IA/día","Corrección gramatical básica","Acceso al mapa de mazmorras","1 examen boss/semana","Historial de 7 días"]'::jsonb, true),
  ('monthly', 'Plan Mensual', '$1.99', 'monthly', 300, 2, 'Acceso completo por el precio de un café', 'MÁS ECONÓMICO', '["Conversaciones IA ilimitadas","Corrección gramatical avanzada","Speech DNA completo","Blind Listening ilimitado","Modo Boss ilimitado","Historial ilimitado"]'::jsonb, true),
  ('annual', 'Plan Anual', '$14.99', 'annual', 1200, 3, 'Menos de $1.25/mes — el mejor valor', 'AHORRA 37%', '["Todo lo del plan mensual","1.200 min/mes de audio IA","Títulos y cosméticos exclusivos","Battle Pass incluido","Soporte prioritario"]'::jsonb, true),
  ('lifetime', 'Acceso Vitalicio', '$29.99', 'lifetime', 600, 4, 'Pago único, beneficios de por vida', 'ACCESO TOTAL', '["Todo lo del plan anual","600 min/mes de por vida","Todos los cosméticos futuros","Acceso a expansiones premium","Prioridad máxima en servidores"]'::jsonb, true)
ON CONFLICT (id) DO UPDATE SET
  price = EXCLUDED.price,
  monthly_audio_minutes_limit = EXCLUDED.monthly_audio_minutes_limit,
  badge_tag = EXCLUDED.badge_tag,
  features = EXCLUDED.features,
  description = EXCLUDED.description,
  is_active = true;
