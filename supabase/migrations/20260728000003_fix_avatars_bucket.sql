-- ============================================================
-- FASE 1.4: Fix avatars bucket - remove public listing
-- ============================================================

DROP POLICY IF EXISTS "Allow public select on avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow public update on avatars" ON storage.objects;

-- Only authenticated users can read their own avatar
CREATE POLICY "Users can read own avatar"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Users can upload their own avatar
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
