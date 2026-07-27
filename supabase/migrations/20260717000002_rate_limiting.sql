-- ==========================================================
-- SISTEMA DE CONTROL DE ABUSO, VALIDACIÓN Y RATE LIMITS (RLS)
-- ==========================================================

-- Table to log user request timestamps for API rate limiting
CREATE TABLE IF NOT EXISTS public.api_request_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    endpoint    VARCHAR(100) NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on request logs
ALTER TABLE public.api_request_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can insert their own request logs" ON public.api_request_logs;
DROP POLICY IF EXISTS "Users can view their own request logs" ON public.api_request_logs;

CREATE POLICY "Users can insert their own request logs" 
    ON public.api_request_logs FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own request logs" 
    ON public.api_request_logs FOR SELECT 
    USING (auth.uid() = user_id);

-- Function to check and enforce request limits at the database level
CREATE OR REPLACE FUNCTION public.check_user_rate_limit(
    p_user_id UUID,
    p_max_requests INTEGER,
    p_interval_seconds INTEGER
) 
RETURNS BOOLEAN AS $$
DECLARE
    v_request_count INTEGER;
    v_is_premium BOOLEAN;
BEGIN
    -- 1. Check if user is premium. Premium users bypass standard rate limits.
    SELECT is_active INTO v_is_premium 
    FROM public.users 
    WHERE id = p_user_id;
    
    IF v_is_premium THEN
        RETURN TRUE;
    END IF;

    -- 2. Count requests in the given window
    SELECT COUNT(*) INTO v_request_count
    FROM public.api_request_logs
    WHERE user_id = p_user_id
      AND created_at >= NOW() - (p_interval_seconds || ' seconds')::INTERVAL;

    -- 3. Reject if limit exceeded
    IF v_request_count >= p_max_requests THEN
        RETURN FALSE;
    END IF;

    -- 4. Log the request
    INSERT INTO public.api_request_logs (user_id, endpoint)
    VALUES (p_user_id, 'deepseek_chat_completion');

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to protect the messages table from spam inserts
CREATE OR REPLACE FUNCTION public.before_message_inserted_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
    -- Enforce 30 requests per minute for free tier users
    IF NOT public.check_user_rate_limit(NEW.conversation_id, 30, 60) THEN
        RAISE EXCEPTION 'Rate limit exceeded. Please wait a minute or upgrade to Premium.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply rate limiting trigger to messages
-- Note: conversation_id in public.messages matches user_id indirectly, but to keep it simple, we can tie the limit check to auth.uid() directly:
CREATE OR REPLACE FUNCTION public.before_message_inserted_auth_rate_limit()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NOT NULL THEN
        IF NOT public.check_user_rate_limit(v_user_id, 20, 60) THEN
            RAISE EXCEPTION 'Límite de solicitudes alcanzado. Por favor, espera un minuto o adquiere el plan Premium.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_messages_rate_limit ON public.messages;

CREATE OR REPLACE TRIGGER trigger_messages_rate_limit
    BEFORE INSERT ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION public.before_message_inserted_auth_rate_limit();
