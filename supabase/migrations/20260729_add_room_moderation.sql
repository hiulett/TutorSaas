-- Add moderation type and assigned moderator to chat rooms
ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS moderator_type TEXT NOT NULL DEFAULT 'ai',
ADD COLUMN IF NOT EXISTS assigned_moderator_id UUID REFERENCES public.users(id) ON DELETE SET NULL;

-- Add constraint to ensure valid moderator_type values
ALTER TABLE public.chat_rooms 
ADD CONSTRAINT chat_rooms_moderator_type_check 
CHECK (moderator_type IN ('ai', 'creator', 'assigned'));

-- Add description column (moved from hardcoded fallback)
ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS description TEXT;
