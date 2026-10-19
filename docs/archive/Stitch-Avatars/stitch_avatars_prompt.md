# Prompt Mejorado — Avatares del Aventurero para Stitch

> **Proyecto:** TutorSaas / Dungeon of English
> **Propósito:** Generar los 12 avatares oficiales del juego con Stitch (Google) para la pantalla *Create Your Character* y el sistema de identidad del aventurero.
> **Documento de referencia (estilo):** `docs/Onboarding-Redesign/06_Character_Creation.md`
> **Tema:** Isekai / Webtoon Manhwa / System HUD (Dark Fantasy + Sci-Fi Overlay)

---

## 1. Prompt maestro para Stitch

**Style Anchor (pegar al inicio de CADA generación):**

```
Anime semi-realista estilo Webtoon coreano de alta gama (referencia artística:
Solo Leveling, Honkai Star Rail, Zenless Zone Zero, AFK Journey). Dark Fantasy
con overlay Sci-Fi/System HUD. Personaje heroico, carismático, de proporciones
adultas (NO chibi, NO infantil, NO pixel art, NO caricatura). Iluminación
cinematográfica, texturas premium, sombreado de estudio, render de videojuego
AAA. Plano medio (cintura hacia arriba), mirando ligeramente hacia la cámara,
fondo transparente, listo para recorte circular de avatar. Resolución alta.
```

**Negative prompt (usar en todas las generaciones):**

```
chibi, cartoon, childish, pixel art, low poly, flat coloring, watermark,
signature, text, logo, extra limbs, deformed hands, cropped face, multiple
characters, background scenery, no background, full body, face cut off,
oversaturated colors, neon glow without source, anime chibi
```

**Plantilla por personaje:**

```
{Clase} — {Nombre}.

{Descripción detallada del personaje}.

Aura: {color del aura} emanando suavemente alrededor del cuerpo.
Rareza: {rareza}.

Estilo: [Style Anchor]. Fondo: transparente. Plano medio, mirando a cámara.
Iluminación cinematográfica. [Negative prompt]
```

---

## 2. Reglas de consistencia del universo (para TODOS)

1. **Paleta cromática global**: respetar los tokens del juego — `voidBg #05070E`, `manaCyan #00E5FF`, `royalGold #FFC700`, `runeViolet #9D4EDD`, `emeraldGreen #00E676`, `crimsonRed #FF1744`. El aura de cada personaje debe ser un tono de estos o derivado.
2. **Dirección de luz**: luz principal desde arriba-izquierda, luz de acento desde el aura (coloreada).
3. **Anatomía y proporción**: adulto, torso hacia arriba, hombros alineados, rostro legible a 64px (tamaño de avatar en lista) y a 256px (tarjeta del aventurero).
4. **Sombreado**: semi-realista con bordes suaves, sin contornos gruesos tipo cartoon.
5. **Composición**: centro de encuadre en el rostro/torso superior; dejar ~20% de aire alrededor de los hombros para el recorte circular.
6. **Detalle de ropa**: texturas visibles (cuero, metal, tela), runas/glifos luminosos donde corresponda.

---

## 3. Los 12 personajes (prompts individuales)

### 1. Arcane Knight — Clase: Knight — Raro: Común — Aura azul
Caballero joven con armadura negra y plateada, ojos azul brillante, cabello corto negro, pequeñas runas luminosas recorriendo la armadura, espada mágica apoyada sobre el hombro. Disciplina, honor y liderazgo.
`arcana_knight` → `avatar_knight_01`

### 2. Crimson Berserker — Clase: Berserker — Raro: Común — Aura roja
Guerrero musculoso, cabello rojo oscuro, ojos rojos, armadura parcialmente destruida, gran hacha de dos manos, cicatrices, energía roja recorriendo su cuerpo. Fuerza y agresividad.
`crimson_berserker` → `avatar_berserker_01`

### 3. Celestial Mage — Clase: Mage — Raro: Común — Aura morada
Mago elegante, cabello blanco, ojos violeta, túnica negra con detalles dorados, cristales mágicos flotando, libro antiguo suspendido. Sabiduría.
`celestial_mage` → `avatar_mage_01`

### 4. Shadow Assassin — Clase: Assassin — Raro: Común — Aura negra con azul eléctrico
Delgado, capucha negra, rostro parcialmente oculto, dos dagas rúnicas, ojos cian, sombras flotando. Velocidad y sigilo.
`shadow_assassin` → `avatar_assassin_01`

### 5. Spirit Archer — Clase: Archer — Raro: Común — Aura verde esmeralda
Elegante, cabello largo plateado, arco de energía, espíritus luminosos, capa oscura, ojos verdes brillantes. Precisión y calma.
`spirit_archer` → `avatar_archer_01`

### 6. Holy Paladin — Clase: Paladin — Raro: Raro — Aura dorada
Guerrero sagrado, armadura blanca y dorada, martillo enorme, cabello rubio, alas de luz formándose detrás, expresión noble.
`holy_paladin` → `avatar_paladin_01`

### 7. Elemental Summoner — Clase: Summoner — Raro: Épico — Aura turquesa
Invocador, cabello azul oscuro, vestimenta ceremonial, cinco espíritus elementales (agua, fuego, viento, tierra, rayo) flotando alrededor.
`elemental_summoner` → `avatar_summoner_01`

### 8. Abyss Necromancer — Clase: Necromancer — Raro: Épico — Aura morado oscuro
Cabello gris, ojos púrpura, túnica negra, bastón antiguo, almas flotando, runas oscuras iluminadas. Misterio.
`abyss_necromancer` → `avatar_necromancer_01`

### 9. Dragon Spearmaster — Clase: Lancer — Raro: Legendario — Aura naranja
Lanza gigantesca, armadura escamada inspirada en dragones, cabello negro, ojos dorados, escamas luminosas.
`dragon_spearmaster` → `avatar_lancer_01`

### 10. Frost Witch — Clase: Sorceress — Raro: Épico — Aura celeste
Hechicera del hielo, cabello azul claro, vestido negro con detalles cristalinos, copos de nieve suspendidos, ojos color hielo. Serenidad.
`frost_witch` → `avatar_sorceress_01`

### 11. Rune Engineer — Clase: Engineer — Raro: Raro — Aura cian
Ingeniero mágico, guantes mecánicos, lentes tecnológicos, runas holográficas, herramientas flotando. Magia + tecnología.
`rune_engineer` → `avatar_engineer_01`

### 12. Oracle Disciple — Clase: Oracle — Raro: Legendario — Aura blanco azulado
Aprendiz del Oráculo, vestimenta ceremonial negra con detalles blancos, símbolos dorados, ojos completamente luminosos, sin armas. Conocimiento.
`oracle_disciple` → `avatar_oracle_01`

---

## 4. Formato de entrega y estructura de assets

```
assets/images/avatars/
├── avatar_knight_01.png
├── avatar_berserker_01.png
├── avatar_mage_01.png
├── avatar_assassin_01.png
├── avatar_archer_01.png
├── avatar_paladin_01.png
├── avatar_summoner_01.png
├── avatar_necromancer_01.png
├── avatar_lancer_01.png
├── avatar_sorceress_01.png
├── avatar_engineer_01.png
└── avatar_oracle_01.png
```

- Formato: **PNG**, fondo transparente.
- Resolución mínima: **1024×1024 px** (centrado, sujeto ocupa ~70%).
- Preparado para recorte circular (el encuadre debe centrar el rostro).
- Naming: `avatar_{clase}_{variante}.png` — la variante `01` es la base; las futuras skins usarán `02`, `03`, etc. (armaduras evolucionadas, trajes de temporada, skins legendarias, versiones corrompidas/sagradas, eventos especiales, auras personalizadas).

---

## 5. Personalización futura (criterio de diseño de cada avatar)

Cada avatar debe tener:

- **Silueta fuerte y reconocible** (se distingue a 32px en listas compactas).
- **Identidad de color única** (aura + acento principal).
- **Zona de evolución clara**: el equipamiento/aura puede cambiar sin romper la identidad base.
- Compatibilidad con el sistema de rarezas (Común/Raro/Épico/Legendario) para la tienda cosmética y el Battle Pass.

---

## 6. Checklist de validación por avatar

- [ ] Plano medio, cintura hacia arriba.
- [ ] Mirando ligeramente a cámara.
- [ ] Fondo transparente.
- [ ] Sin texto, logos ni marcas de agua.
- [ ] Anatomía adulta, sin chibi/infantil/pixel art.
- [ ] Iluminación cinematográfica consistente con el universo.
- [ ] Aura del color especificado.
- [ ] Reconocible a 32px (silueta) y a 256px (detalle).
- [ ] Paleta coherente con los tokens del juego.
- [ ] Listo para recorte circular.
