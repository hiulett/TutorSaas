-- Weekly retention job to clean up ai_usage_logs and api_request_logs older than 90 days.
CREATE OR REPLACE FUNCTION public.clean_old_logs()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  DELETE FROM public.ai_usage_logs WHERE created_at < NOW() - INTERVAL '90 days';
  DELETE FROM public.api_request_logs WHERE created_at < NOW() - INTERVAL '90 days';
END;
$$;
