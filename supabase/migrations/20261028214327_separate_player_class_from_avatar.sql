-- P-11i (#157): separar la clase de jugador de avatar_url.
--
-- `users.avatar_url` guardaba el id de clase (`warrior`, `mage`, ...) en vez
-- de la foto. La clase canonica vive en user_language_profiles.character_class.

update public.user_language_profiles p
   set character_class = u.avatar_url
  from public.users u
 where u.id = p.user_id
   and (p.character_class is null or p.character_class = '')
   and u.avatar_url in (
     'warrior','mage','assassin','knight','archer','summoner','necromancer','paladin','berserker','priest'
   );

update public.users
   set avatar_url = null
 where avatar_url in (
   'warrior','mage','assassin','knight','archer','summoner','necromancer','paladin','berserker','priest'
 );
