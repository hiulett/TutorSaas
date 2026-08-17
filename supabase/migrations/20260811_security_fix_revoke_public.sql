-- ============================================================================
-- FIX HARDENING 007 — Revocar PUBLIC (no solo anon) de las RPC del gremio
--
-- La migración 20260811_security_hardening_guild.sql revocó EXECUTE de `anon`,
-- pero eso NO es suficiente: las funciones recién creadas tenían EXECUTE para
-- PUBLIC (acl =X/postgres), y `anon` hereda de PUBLIC. El resultado es que
-- cualquiera sin sesión sigue pudiendo llamar claim_seat, grant_next_seat, etc.
--
-- Solución: revocar de PUBLIC y regrantear SOLO a authenticated.
-- ============================================================================

REVOKE EXECUTE ON FUNCTION public.join_table(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.claim_seat(uuid, uuid, integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.request_seat(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.stand_up(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.leave_table(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.grant_next_seat(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.moderator_stand(uuid, uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.touch_presence(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.purge_stale_participants(integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.check_token_rate_limit(uuid, int, int) FROM PUBLIC;

-- Leaderboard: quitar anon explícito (solo authenticated).
REVOKE EXECUTE ON FUNCTION public.get_leaderboard(integer) FROM anon;

-- Re-afirmar grants a authenticated (por si algún REVOKE se pasó de largo).
GRANT EXECUTE ON FUNCTION public.join_table(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.claim_seat(uuid, uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.request_seat(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.stand_up(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.leave_table(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.grant_next_seat(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.moderator_stand(uuid, uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.touch_presence(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.purge_stale_participants(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_token_rate_limit(uuid, int, int) TO authenticated;
