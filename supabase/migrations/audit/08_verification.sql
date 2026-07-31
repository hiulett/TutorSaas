-- =============================================================
-- MIGRACIÓN 8: Post-migration verification checks
-- =============================================================

-- 8a. Verificar que no hay usuarios huérfanos (auth.users sin public.users)
SELECT '8a. Usuarios sin perfil público:' AS check_name, count(*) AS issues
FROM auth.users u
LEFT JOIN public.users pu ON u.id = pu.id
WHERE pu.id IS NULL;

-- 8b. Verificar RLS habilitado en todas las tablas
SELECT '8b. Tablas sin RLS:' AS check_name, string_agg(tablename, ', ') AS issues
FROM pg_tables
WHERE schemaname = 'public'
  AND NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = pg_tables.tablename
      AND n.nspname = 'public'
      AND c.relrowsecurity = true
  );

-- 8c. Verificar policies duplicadas (misma tabla y cmd)
SELECT '8c. Tablas con policies duplicadas:' AS check_name, tablename || ' (' || count(*)::text || ' policies)' AS issues
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
HAVING count(*) > 3
ORDER BY count(*) DESC;

-- 8d. Verificar FK sin índices
SELECT '8d. FKs sin índice:' AS check_name, conname AS issues
FROM pg_constraint c
JOIN pg_class t ON t.oid = c.conrelid
WHERE c.contype = 'f'
  AND t.relnamespace = 'public'::regnamespace
  AND NOT EXISTS (
    SELECT 1 FROM pg_index i
    WHERE i.indrelid = c.conrelid
      AND i.indkey::text LIKE '%' || (
        SELECT a.attnum::text FROM pg_attribute a
        WHERE a.attrelid = c.conrelid
          AND a.attname = (
            SELECT column_name FROM information_schema.key_column_usage
            WHERE constraint_name = c.conname
              AND table_schema = 'public'
              AND table_name = t.relname
          )
      ) || '%'
  );

-- 8e. Verificar columnas de tipo TEXT que deberían ser UUID
SELECT '8e. Columnas TEXT que deberían ser UUID:' AS check_name,
  table_name || '.' || column_name AS issues
FROM information_schema.columns
WHERE table_schema = 'public'
  AND data_type = 'text'
  AND column_name LIKE '%user_id%'
  AND table_name NOT IN ('users', 'scenarios', 'messages');

-- 8f. Resumen de ENUMs aplicados
SELECT '8f. ENUMs aplicados:' AS check_name,
  t.typname AS enum_name,
  string_agg(e.enumlabel, ', ' ORDER BY e.enumsortorder) AS values
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
WHERE t.typnamespace = 'public'::regnamespace
GROUP BY t.typname;

-- 8g. Conteo de índices por tabla
SELECT '8g. Índices por tabla:' AS check_name,
  tablename || ': ' || count(*)::text AS issues
FROM pg_indexes
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

SELECT 'Migración 8: Verificaciones completadas' AS result;
