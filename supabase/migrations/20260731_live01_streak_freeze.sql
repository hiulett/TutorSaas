-- LIVE-01: Streak freeze (consumable)
-- A user can buy a freeze for 30 gems; a freeze protects the daily streak
-- from resetting if a day is missed.
ALTER TABLE public.player_streaks
    ADD COLUMN IF NOT EXISTS streak_freezes INTEGER DEFAULT 0;
