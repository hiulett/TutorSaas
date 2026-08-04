-- ============================================================================
-- TutorSaas — Onboarding v2: Catálogo de Clases de Cazador (hunter_classes)
-- Fecha: 2026-08-04
--
-- Las clases YA NO viven hardcodeadas en el código. Se obtienen desde esta
-- tabla. Añadir una clase nueva = insertar un registro (sin tocar la app).
--
-- Estructura preparada para el sistema de progresión futuro: habilidades,
-- pasivas, especializaciones, equipamiento, misiones, logros, títulos,
-- cosméticos y estadísticas (ver docs/Onboarding-Character/).
-- Idempotente: `create table if not exists` + seed `on conflict do nothing`.
-- ============================================================================

create table if not exists public.hunter_classes (
  id text primary key,                    -- id técnico (warrior, mage...)
  name_en text not null,                  -- nombre (inglés)
  name_es text,                           -- nombre localizado (español)
  name_pt text,                           -- nombre localizado (portugués)
  role_en text not null,                  -- rol / archetype (inglés)
  role_es text,
  role_pt text,
  description_en text,                    -- descripción larga
  description_es text,
  description_pt text,
  image_url text,                         -- arte del avatar (asset)
  icon text,                              -- icono (Material icon name)
  element text,                           -- elemento (Fuego, Arcano...)
  aura text,                              -- color del aura (legible)
  rarity text not null default 'comun',   -- comun | raro | epico | legendario
  color text not null default '#00E5FF',  -- color representativo (hex)
  display_order int not null default 0,   -- orden en la UI
  is_active boolean not null default true,
  is_starter boolean not null default true, -- disponible en onboarding vs desbloqueable
  difficulty int not null default 1,      -- 1 (fácil) a 3 (difícil)
  combat_type_en text,                    -- tipo de combate (Soporte, Burst...)
  combat_type_es text,
  combat_type_pt text,
  affinity_en text,                       -- afinidad (pronunciación, gramática...)
  affinity_es text,
  affinity_pt text,
  abilities_en jsonb default '[]',        -- habilidades principales (lista)
  abilities_es jsonb default '[]',
  abilities_pt jsonb default '[]',
  playstyle_en text,                      -- estilo de juego
  playstyle_es text,
  playstyle_pt text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ── Row Level Security ──────────────────────────────────────────────────────
alter table public.hunter_classes enable row level security;

drop policy if exists "hunter_classes_read" on public.hunter_classes;
create policy "hunter_classes_read"
  on public.hunter_classes
  for select
  to authenticated
  using (is_active = true);

-- Escritura solo con service_role (no se exponen políticas de escritura).

-- ── Seed: las 8 clases iniciales ────────────────────────────────────────────
-- El arte de avatar apunta a los assets de Stitch en assets/images/avatars/.
insert into public.hunter_classes
  (id, name_en, name_es, name_pt, role_en, role_es, role_pt,
   description_en, description_es, description_pt,
   image_url, icon, element, aura, rarity, color, display_order,
   is_active, is_starter, difficulty,
   combat_type_en, combat_type_es, combat_type_pt,
   affinity_en, affinity_es, affinity_pt,
   abilities_en, abilities_es, abilities_pt,
   playstyle_en, playstyle_es, playstyle_pt)
values
  ('warrior',
   'Berserker', 'Berserker', 'Berserker',
   'Vanguard', 'Vanguardia', 'Vanguarda',
   'Outspoken and brave. You speak first and think later. Ideal for overcoming the fear of speaking.',
   'Extrovertido y valiente. Hablas primero y piensas después. Ideal para perder el miedo a hablar.',
   'Extrovertido e corajoso. Você fala primeiro e pensa depois. Ideal para perder o medo de falar.',
   'assets/images/avatars/avatar_berserker_01.png', 'shield', 'Fuego', 'carmesí', 'comun', '#FF1744', 1,
   true, true, 1,
   'Aggressive', 'Agresivo', 'Agressivo',
   'Pronunciation', 'Pronunciación', 'Pronúncia',
   '["Lead the conversation", "Speak first", "High energy"]',
   '["Lidera la conversación", "Habla primero", "Alta energía"]',
   '["Lidera a conversa", "Fala primeiro", "Alta energia"]',
   'Speaks first, learns by doing, fearless.', 'Habla primero, aprende haciendo, sin miedo.', 'Fala primeiro, aprende fazendo, sem medo.'),
  ('mage',
   'Arcane Mage', 'Mago Arcano', 'Mago Arcano',
   'Strategist', 'Estratega', 'Estrategista',
   'Analytical and precise. You observe and structure before speaking. Ideal for perfecting grammar.',
   'Analítico y preciso. Observas y estructuras antes de hablar. Ideal para perfeccionar la gramática.',
   'Analítico e preciso. Você observa e estrutura antes de falar. Ideal para aperfeiçoar a gramática.',
   'assets/images/avatars/avatar_mage_01.png', 'auto_awesome', 'Arcano', 'violeta', 'comun', '#9D4EDD', 2,
   true, true, 2,
   'Control', 'Control', 'Controle',
   'Grammar', 'Gramática', 'Gramática',
   '["Structure first", "Perfect grammar", "Analytical"]',
   '["Estructura primero", "Gramática perfecta", "Analítico"]',
   '["Estrutura primeiro", "Gramática perfeita", "Analítico"]',
   'Observes, structures, then speaks with precision.', 'Observa, estructura y luego habla con precisión.', 'Observa, estrutura e depois fala com precisão.'),
  ('assassin',
   'Assassin', 'Asesino', 'Assassino',
   'Precision Striker', 'Golpeador de precisión', 'Atacante de precisão',
   'Tactical observer. You aim for precision and stealthy efficiency. Ideal for high-accuracy vocabulary.',
   'Observador táctico. Buscas la precisión y la eficiencia sigilosa. Ideal para vocabulario de precisión.',
   'Observador tático. Você busca precisão e eficiência furtiva. Ideal para vocabulário de alta precisão.',
   'assets/images/avatars/avatar_assassin_01.png', 'colorize', 'Sombra', 'azul oscuro', 'comun', '#00B0FF', 3,
   true, true, 2,
   'Burst', 'Ráfaga', 'Rajada',
   'Vocabulary', 'Vocabulario', 'Vocabulário',
   '["Precision words", "Stealthy", "Tactical"]',
   '["Palabras precisas", "Sigiloso", "Táctico"]',
   '["Palavras precisas", "Furtivo", "Tático"]',
   'Aims for the perfect word, strikes with precision.', 'Apunta a la palabra perfecta, golpea con precisión.', 'Mira a palavra perfeita, ataca com precisão.'),
  ('knight',
   'Knight', 'Caballero', 'Cavaleiro',
   'Sentinel', 'Centinela', 'Sentinela',
   'Constant and methodical. You stand firm in your routines. Ideal for building streaks and consistency.',
   'Constante y metódico. Te mantienes firme en tus rutinas. Ideal para construir rachas y constancia.',
   'Constante e metódico. Mantém-se firme em suas rotinas. Ideal para construir sequências e consistência.',
   'assets/images/avatars/avatar_knight_01.png', 'military_tech', 'Tierra', 'dorada', 'comun', '#FFC700', 4,
   true, true, 1,
   'Tank', 'Tanque', 'Tanque',
   'Consistency', 'Constancia', 'Consistência',
   '["Daily streaks", "Methodical", "Reliable"]',
   '["Rachas diarias", "Metódico", "Confiable"]',
   '["Sequências diárias", "Metódico", "Confiável"]',
   'Stands firm, builds unstoppable consistency.', 'Se mantiene firme, construye constancia imparable.', 'Mantém-se firme, constrói consistência imparável.'),
  ('archer',
   'Archer', 'Arquero', 'Arqueiro',
   'Marksman', 'Tirador', 'Atirador',
   'Agile and quick. You learn on the go within context. Ideal for mastering useful expressions.',
   'Ágil y rápido. Aprendes sobre la marcha dentro del contexto. Ideal para dominar expresiones útiles.',
   'Ágil e rápido. Você aprende na prática dentro do contexto. Ideal para dominar expressões úteis.',
   'assets/images/avatars/avatar_archer_01.png', 'gps_fixed', 'Viento', 'esmeralda', 'comun', '#00E676', 5,
   true, true, 1,
   'Ranged', 'A distancia', 'À distância',
   'Expressions', 'Expresiones', 'Expressões',
   '["Useful phrases", "Context learning", "Agile"]',
   '["Frases útiles", "Aprende en contexto", "Ágil"]',
   '["Frases úteis", "Aprende em contexto", "Ágil"]',
   'Learns on the go, mastering expressions in context.', 'Aprende sobre la marcha, dominando expresiones en contexto.', 'Aprende na prática, dominando expressões em contexto.'),
  ('summoner',
   'Summoner', 'Invocador', 'Invocador',
   'Combo Master', 'Maestro de combos', 'Mestre de combos',
   'Creative and associative. You connect concepts and conjure ideas. Ideal for idiomatic phrases.',
   'Creativo y asociativo. Conectas conceptos e invocas ideas. Ideal para frases idiomáticas.',
   'Criativo e associativo. Você conecta conceitos e conjura ideias. Ideal para frases idiomáticas.',
   'assets/images/avatars/avatar_summoner_01.png', 'auto_fix_high', 'Estelar', 'magenta', 'comun', '#D500F9', 6,
   true, true, 3,
   'Summon', 'Invocación', 'Invocação',
   'Idioms', 'Frases idiomáticas', 'Expressões idiomáticas',
   '["Connect concepts", "Idioms", "Creative"]',
   '["Conecta conceptos", "Frases idiomáticas", "Creativo"]',
   '["Conecta conceitos", "Expressões idiomáticas", "Criativo"]',
   'Conjures ideas, linking concepts into vivid idioms.', 'Invocas ideas, conectando conceptos en frases vívidas.', 'Conjura ideias, ligando conceitos em expressões vívidas.'),
  ('paladin',
   'Paladin', 'Paladín', 'Paladino',
   'Guardian', 'Guardián', 'Guardião',
   'Goal-driven protector. Guided by clear duties. Ideal for formal and structured conversations.',
   'Protector guiado por objetivos. Orientado al deber. Ideal para conversaciones formales y estructuradas.',
   'Protetor guiado por objetivos. Orientado ao dever. Ideal para conversas formais e estruturadas.',
   'assets/images/avatars/avatar_paladin_01.png', 'volunteer_activism', 'Luz', 'celeste', 'raro', '#40C4FF', 7,
   true, true, 2,
   'Support', 'Soporte', 'Suporte',
   'Formal speech', 'Discurso formal', 'Fala formal',
   '["Formal conversations", "Structured", "Protective"]',
   '["Conversaciones formales", "Estructurado", "Protector"]',
   '["Conversas formais", "Estruturado", "Protetor"]',
   'Protects and guides, excelling in formal discourse.', 'Protege y guía, sobresaliendo en el discurso formal.', 'Protege e guia, destacando-se no discurso formal.'),
  ('necromancer',
   'Necromancer', 'Nigromante', 'Necromante',
   'Researcher', 'Investigador', 'Pesquisador',
   'Etymological explorer. You resurrect the roots of the language. Ideal for Latin roots and word origins.',
   'Explorador etimológico. Resucitas las raíces del idioma. Ideal para raíces latinas y orígenes de palabras.',
   'Explorador etimológico. Ressuscita as raízes do idioma. Ideal para raízes latinas e origens de palavras.',
   'assets/images/avatars/avatar_necromancer_01.png', 'gavel', 'Óseo', 'púrpura', 'epico', '#8E24AA', 8,
   true, true, 3,
   'Research', 'Investigación', 'Pesquisa',
   'Etymology', 'Etimología', 'Etimologia',
   '["Word roots", "Etymology", "Deep research"]',
   '["Raíces de palabras", "Etimología", "Investigación profunda"]',
   '["Raízes de palavras", "Etimologia", "Pesquisa profunda"]',
   'Resurrects word origins, unlocking linguistic secrets.', 'Resucita orígenes de palabras, desbloqueando secretos lingüísticos.', 'Ressuscita origens de palavras, desbloqueando segredos linguísticos.')
on conflict (id) do nothing;
