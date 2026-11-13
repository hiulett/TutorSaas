# Items, inventario y utilidad

_Auditoría económica · Fase 4. Solo lectura._

**Fuentes:** `supabase/migrations/20260730_economy_and_ia_system.sql` (23 items),
`20260730_phase9_items_modifiers.sql` (14), `20261029215518_economy_purpose_p32.sql`
(3 nuevos + precios y niveles), `20260813_shop_gold.sql` (precios en oro) y
`20260730_economy_balance.sql` (ajustes de gemas). **Total: 40 items.**

No se ha consultado producción en esta sesión: el catálogo vivo puede tener
filas creadas o desactivadas desde el SQL Editor. Lo que sigue es el catálogo
**según repo**.

---

## 1. Inventario por categoría

| Categoría | Nº | Items | Precio | Estado |
|---|---|---|---|---|
| `title` | 6 | Novato (0), Aprendiz del Abismo (80 oro), Elocuente (500 gemas / 200 oro), Cazador de Sombras (800 / 350), Leyenda Viva (2000 / 800) | mixto | ✅ Cosmético real |
| `frame` | 4 | Escudo (600 / 250), Alas de Dragón (1200 / 450), Mirada del Abismo (2000 / 900), Marco del Aprendiz (90 oro) | mixto | ✅ Cosmético real |
| `aura` | 3 | Llama de Maná (800 / 300), Espíritu de Fuego (1500 / 550), Alma de las Sombras (2500 / 1100) | mixto | ✅ Cosmético real |
| `pet` | 2 | Lunático (1500 / 600), Fénix (2500 / 1000) | mixto | ✅ Cosmético real |
| `emote` | 2 | Reacciones Arcanas Vol.1 (400 / 120), Saludo del Gremio (60 oro) | mixto | ✅ Cosmético real |
| `table_theme` | 2 | Bosque Nocturno (2000 / 700), Abismo Arcano (3000 / 1200) | mixto | ✅ Cosmético real |
| `skin`/deco | 5 | Skin Cazador (800), Skin Arcano (1600), Fondo Abismo (900), Estandarte (600), Trofeo Colmillo (0) | gemas | ⚠️ Mal clasificados como `consumable` |
| `relic` | 3 | Fragmento del Oráculo, Corazón del Dragón, Llave del Tiempo | 0 | ❓ Sin ruta de obtención verificada |
| `consumable` (modificadores) | 4 | Recompensa x2 (120), Piedra de Facilidad (90), Piedra de Desafío (150), Llave de Ruta Secreta (200) | gemas | ⚠️ Efecto **aplicado desde el cliente** |
| `consumable` (llaves/libros) | 5 | Mazmorra Oculta (150), Archivo del Gremio (250), Phrasal Verbs (100), Grimorio (180), Pronunciación (120) | gemas | ❌ **Sin implementación** |
| `consumable` (recursos muertos) | 4 | +5 Invocaciones (50), +20 Invocaciones (180), 10 Pergaminos (100), 50 Pergaminos (400) | gemas | ❌ **El recurso ya no existe** |

---

## 2. Análisis de utilidad

### 2.1 Lo que funciona: cosméticos (≈27 items)

Títulos, marcos, auras, mascotas, emotes y temas de mesa. Cumplen la función
económica correcta: **no dan ventaja, se lucen, y el nivel desbloquea el acceso**
(`required_level` 1–20). La escalera de precios en oro va de **60 a 1.200** y en
gemas de **400 a 3.000**.

**Problema de diseño, no de implementación:** casi todos tienen **doble precio**
(oro y gemas). Eso permite comprar con oro gratuito el mismo objeto que se ofrece
por gemas, lo que vacía de sentido a la moneda premium. Si la intención es
«gemas = atajo, oro = esfuerzo», el objeto de gemas no debería ser también
comprable con oro, o su precio en oro debería ser mucho más alto que el esfuerzo
equivalente.

### 2.2 Lo que cobra sin dar nada (9 items, ❌)

| Item | Precio | Por qué no sirve |
|---|---|---|
| `consumible_invocacion5/20` | 50 / 180 gemas | Las invocaciones dejaron de limitar la IA: `llm-proxy` cobra `consume_mana`. El contador `invocations_max` solo se mueve en cliente y nadie lo comprueba |
| `consumible_pergamino10/50` | 100 / 400 gemas | No existe práctica offline; `pergamino` no aparece en ninguna Edge Function |
| `key_mazmorra_oculta`, `key_archivo_gremio` | 150 / 250 gemas | Cero referencias en `lib/` |
| `book_phrasal_verbs`, `book_grimorio_tiempos`, `book_pronunciacion` | 100 / 180 / 120 gemas | Cero referencias en `lib/` |

**Estos nueve items son el mayor riesgo reputacional de la tienda**: se cobran
gemas (que el usuario puede haber comprado con dinero) por objetos sin efecto.

### 2.3 Lo que funciona a medias (4 items, ⚠️)

Los modificadores de misión (`mod_recompensa_x2`, `mod_piedra_facilidad`,
`mod_piedra_desafio`, `mod_llave_ruta_secreta`):

- El efecto **existe** en el servidor: `claim_mission_reward` multiplica por
  `reward_multiplier`.
- Pero **quien escribe el multiplicador es el cliente**
  (`mission_repository.dart:242-248`) y el guard de `mission_instances` no lo
  protege → ver `ECONOMY_TECHNICAL_AUDIT.md` F-1/F-5. Es a la vez un item
  semi-funcional y un vector de exploit.
- No se ha encontrado el descuento del item del inventario en la misma
  operación.

### 2.4 Reliquias (3 items, ❓)

`relic_oraculo`, `relic_dragón`, `relic_tiempo` tienen precio 0 y descripciones
que las ligan a logros (prueba inicial, nivel CEFR completo, racha de 30 días).
**No se ha verificado ninguna ruta de concesión** en el código revisado. Si no
existe, son filas de catálogo sin uso; si existe, son un buen embrión de
coleccionismo.

---

## 3. Relación item ↔ aprendizaje

Lo que esta economía **no** tiene y debería tener, coherente con la fantasía:

| Idea | Función económica | ¿Rompe el aprendizaje? |
|---|---|---|
| **Pergamino de repaso** (repasar errores del códex sin coste de IA) | Sumidero de fragmentos, uso recurrente | No: refuerza, no sustituye |
| **Tomo de vocabulario** (mazo SRS temático desbloqueable) | Sumidero de oro, coleccionable | No |
| **Pase de mazmorra temática** (escenario extra) | Sumidero de gemas, contenido | No: es práctica adicional |
| **Título por hito de dominio** (p. ej. «B2: 500 palabras activas») | Estatus educativo | No: premia aprendizaje real |
| **Skin del tutor/NPC de misión** | Personalización afectiva | No |

Lo que **no** conviene vender nunca: saltarse misiones, multiplicar XP de forma
permanente, o desbloquear niveles CEFR. Eso convertiría el progreso académico en
algo comprable y destruiría la credibilidad del producto.

---

## 4. Conclusiones

1. **El catálogo tiene volumen suficiente** (40 items) para una economía de
   cosméticos, pero **más de un tercio no aporta valor verificable**.
2. **El inventario no tiene mecánicas de equipado verificadas en la economía**:
   comprar un título o un aura no parece cambiar nada visible salvo que
   `inventory_screen.dart` aplique equipado (no confirmado en esta pasada). Es la
   siguiente comprobación obligatoria: *si no se puede equipar, el cosmético no
   existe para el usuario*.
3. **Los cosméticos comparten precio en oro y gemas**, lo que canibaliza la
   moneda premium.
4. **Los items funcionales que sí existen (modificadores) están mal protegidos**:
   su efecto es explotable.
5. Antes de añadir items nuevos hay que **retirar los 9 muertos** y **cerrar los
   exploits**: añadir catálogo a una tienda que a veces cobra por nada multiplica
   el problema.

## 5. Qué falta verificar

- Si `inventory_screen.dart` permite equipar y si ese equipado se persiste
  (`player_inventory`) y se pinta en el perfil/Gremio.
- Cuántas filas tiene hoy `player_inventory` (la última medición conocida: **0**).
- Si las 3 reliquias se conceden desde algún trigger o función no revisada.
