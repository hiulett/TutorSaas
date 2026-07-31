# ADR-005: Abyssal Interface (Isekai Manhwa System HUD)

## Estado
Aceptado

## Contexto
TutorSaas necesita una identidad visual única y premium que:
- Sea atractiva para adultos jóvenes (target principal: 18-35)
- Refuerce la gamificación (XP, niveles, logros)
- Se diferencie de apps educativas tradicionales (Duolingo, Babbel)
- Transmita una sensación de "sistema" o "juego" inmersivo
- Sea 100% dark mode

## Opciones Consideradas
1. **Abyssal Interface (Isekai Manhwa System HUD)** — Inspirado en manhwa coreano de sistemas de juego/isekai
2. **Deep Space Glassmorphism** — Estilo elegante, profesional, menos gamificado
3. **Material Design 3 estándar** — Seguro pero genérico
4. **Minimalista** — Similar a apps de productividad
5. **Neobrutalismo** — Moderno pero demasiado agresivo

## Decisión
Se adopta **Abyssal Interface (Isekai Manhwa System HUD)** — una fusión de:
- Estética oscura de "sistema de juego" (manhwa coreano)
- Glassmorphism para componentes flotantes
- Elementos rúnicos y partículas de maná animadas
- Tipografía tecnológica (JetBrains Mono para labels)
- Paleta: void `#05070E`, mana cyan `#00E5FF`, royal gold `#FFC700`, rune violet `#9D4EDD`

## Consecuencias
**Positivas:**
- Identidad visual única y memorable
- Refuerza la gamificación (maná como moneda, barras segmentadas, runas)
- Atractivo para el target de adultos jóvenes interesados en gaming/manhwa
- Componentes reutilizables (GlassCard, SystemWindow, ManaBar, ManaMeterWidget)
- CyberManhwaBackground con modos contextuales (12 modos diferentes)

**Negativas:**
- No apto para todos los públicos (puede resultar demasiado temático)
- Mayor costo de desarrollo de UI (animaciones, partículas, efectos)
- Desviación de Material Design puede afectar accesibilidad
- Persona visual fuerte limita futuros cambios de branding

## Componentes del Sistema
- `GlassCard` — Contenedor translúcido base
- `SystemWindow` — Ventana con runas decorativas animadas
- `SystemButton` — Botón con borde de color (cyan/gold/violet)
- `ManaBar` — Barra de progreso segmentada
- `ManaMeterWidget` — Indicador de maná con glow
- `SystemChatBubble` — Burbuja de chat con estilo sistema
- `CyberManhwaBackground` — Fondo animado multi-capa
- `DraggableMonsterWidget` — Mascota IA interactiva

## Referencias
- Estilo visual inspirado en: Solo Leveling, Tower of God, y manhwa de sistema/isekai
- Paleta basada en colores neón oscuros con acentos fríos y cálidos
