# 01 — Problemas actuales de la pantalla "Create Your Character"

> **Ruta:** `Docs/UX_Audits/CharacterCreation/01_Current_Problems.md`
> **Fecha:** 2026-08-04
> **Componente:** `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`

---

## Resumen

La pantalla fue rediseñada con un **carrusel horizontal** (PageView, viewportFraction 0.62)
y un panel de estadísticas. Si bien el carrusel mejora la selección, la distribución
vertical actual introduce problemas graves de UX.

---

## 1. El carrusel queda demasiado abajo

**Problema:** el `SingleChildScrollView` apila en orden: título → descripción → campo de
nombre (opcional) → avatar preview 120px → carrusel 300px → dots → panel de stats → botón.

El carrusel (elemento central) termina **por debajo del pliegue** en la mayoría de pantallas
de teléfono. El usuario debe hacer scroll para verlo.

**Evidencia:** con ~700px útiles, el carrusel comienza alrededor del pixel 380-420.

---

## 2. El panel de estadísticas queda fuera de pantalla

**Problema:** al seleccionar un personaje, el panel de stats se encuentra **debajo del
carrusel de 300px + dots**, por lo que queda oculto. El usuario debe hacer scroll para
ver las estadísticas de la clase que acaba de elegir. Esto rompe el feedback inmediato.

---

## 3. Excesivo scroll

**Problema:** toda la experiencia (elegir + ver stats) requiere 2-3 scrolls. Un flujo de
selección de personaje debería completarse **en una sola pantalla** sin desplazamiento.

---

## 4. Panel de estadísticas pequeño y comprimido

**Problema:** el panel actual usa `GlassCard` con padding reducido, texto de 9-12px y chips
pequeños. Desperdicia el ancho disponible y las stats quedan apretadas. No se siente como
una **ficha de personaje RPG**.

---

## 5. Las tarjetas no usan el tema medieval del proyecto

**Problema:** el carrusel actual usa:
- `AppColors.manaCyan` (#00E5FF) — turquesa fluorescente
- Efecto de glow brillante moderno (BoxShadow con blur 18)
- Gradientes claros

El proyecto pide un tema **Isekai / Medieval Fantasy** (Solo Leveling, Frieren, FFXIV,
Diablo IV, Baldur's Gate 3, Granblue): negro, gris oscuro, piedra, hierro, madera oscura,
dorado envejecido, azul mágico, púrpura arcano, rojo oscuro. **Nada fluorescente.**

---

## 6. Campo de nombre del personaje

**Problema:** el campo de texto para el nombre ocupa espacio vertical y añade una tarea
extra que no aporta valor en este paso. El nombre puede configurarse posteriormente
desde el perfil. El prompt pide eliminarlo.

---

## 7. Microinteracciones insuficientes

**Problema:** el cambio de personaje solo anima `AnimatedScale`/`AnimatedContainer`.
Faltan: fade de estadísticas, halo detrás del avatar, transición suave del avatar grande,
partículas mágicas discretas. La selección no se siente "mágica".

---

## 8. Accesibilidad

- Texto de chips de 8-9px: demasiado pequeño (mínimo recomendado 11-12px).
- Áreas táctiles de las tarjetas del carrusel pequeñas en algunos casos.
- Contraste de los textos secundarios (`onSurface.withValues(alpha:0.4-0.45)`) insuficiente.

---

## Conclusión

El problema de fondo es la **distribución vertical**: carrusel abajo + panel oculto + scroll.
La solución es reorganizar en una única vista: **avatar protagonista arriba → selector de
clase compacto → ficha de estadísticas grande y siempre visible**.
