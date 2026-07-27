---
name: Abyssal Interface
colors:
  surface: '#11131b'
  surface-dim: '#11131b'
  surface-bright: '#373942'
  surface-container-lowest: '#0b0e16'
  surface-container-low: '#191b23'
  surface-container: '#1d1f27'
  surface-container-high: '#272a32'
  surface-container-highest: '#32343d'
  on-surface: '#e1e2ed'
  on-surface-variant: '#bac9cc'
  inverse-surface: '#e1e2ed'
  inverse-on-surface: '#2e3039'
  outline: '#849396'
  outline-variant: '#3b494c'
  surface-tint: '#00daf3'
  primary: '#c3f5ff'
  on-primary: '#00363d'
  primary-container: '#00e5ff'
  on-primary-container: '#00626e'
  inverse-primary: '#006875'
  secondary: '#ffe9b9'
  on-secondary: '#3e2e00'
  secondary-container: '#ffc703'
  on-secondary-container: '#6e5400'
  tertiary: '#f8e7ff'
  on-tertiary: '#4c007d'
  tertiary-container: '#e6c3ff'
  on-tertiary-container: '#7e2cbe'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#9cf0ff'
  primary-fixed-dim: '#00daf3'
  on-primary-fixed: '#001f24'
  on-primary-fixed-variant: '#004f58'
  secondary-fixed: '#ffdf94'
  secondary-fixed-dim: '#f5bf00'
  on-secondary-fixed: '#251a00'
  on-secondary-fixed-variant: '#594400'
  tertiary-fixed: '#f2daff'
  tertiary-fixed-dim: '#e0b6ff'
  on-tertiary-fixed: '#2e004e'
  on-tertiary-fixed-variant: '#6a0baa'
  background: '#11131b'
  on-background: '#e1e2ed'
  surface-variant: '#32343d'
typography:
  display-title:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.3'
  stat-value:
    fontFamily: JetBrains Mono
    fontSize: 20px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 0.05em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.0'
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
  window-padding: 24px
---

## Brand & Style
The design system embodies the "System Window" trope found in high-stakes Isekai narratives. It is designed to feel like a sentient, magical interface projected directly into a user's consciousness from a void dimension. 

The style is a fusion of **Dark Glassmorphism** and **Arcane Minimalism**. It rejects the cluttered "hacker" aesthetic of cyberpunk in favor of a clean, lethal, and ethereal RPG atmosphere. Surfaces appear as translucent shards of obsidian, held together by glowing mana conduits. The emotional response is one of high-stakes authority, power progression, and mystical precision. Visuals are dominated by sharp angles, runic motifs, and high-contrast atmospheric glows that simulate dimensional portals and mana particles.

## Colors
The palette is rooted in the deep **Abyssal Night (#05070E)**, providing a void-like backdrop that makes magical elements pop. 

- **Mana Cyan (#00E5FF):** Used for active status effects, primary interactions, and the "System" voice.
- **Royal Gold (#FFC700):** Reserved for legendary items, rank-ups, and critical achievements.
- **Rune Violet (#9D4EDD):** Associated with mystery, dimensional skills, and high-level mana consumption.
- **Crimson Blood (#FF1744):** Denotes low health, boss-tier threats, and failed quests.
- **Success Emerald (#00E676):** Used for quest completions and level-up confirmations.

All surface colors use the semi-transparent **rgba(12, 17, 29, 0.94)** to maintain the "floating overlay" feel against the dark world backdrop.

## Typography
The typographic hierarchy distinguishes between the "System's Voice" and "Player Data." 

- **Headlines & Display:** Space Grotesk provides the necessary angularity and futuristic sharpness required for a magical system window.
- **Stats & Data:** JetBrains Mono is utilized for numerical values and technical labels (STR, AGI, INT) to evoke a sense of calculated precision and RPG logic.
- **Body Text:** Inter ensures that quest descriptions and item lore remain highly legible even when displayed on translucent, dark backgrounds.

Always use "Label Caps" for system categories to mimic the metadata feel of a game HUD.

## Layout & Spacing
This design system utilizes a **Fluid Overlay Model**. Elements are not bound by a traditional web grid but are treated as floating modules within a dimensional viewport.

- **The HUD Layer:** Essential stats (HP/MP bars) are anchored to the screen edges with fixed 40px margins on desktop.
- **Floating Windows:** Modals and Quest windows should never exceed a width of 600px, centering themselves to maintain focus. 
- **Modular Rhythm:** A 4px base unit ensures tight, technical alignment. Padding within system windows is generous (24px) to prevent the "mana" glow of the borders from bleeding into the text.
- **Responsive Behavior:** On mobile, windows expand to full width with a 20px safe area margin, losing the "floating" effect to maximize legibility.

## Elevation & Depth
Depth is achieved through **Luminous Layering** rather than traditional shadows.

- **The Void:** The base layer is the #05070E black background.
- **System Surfaces:** These use the 0.94 opacity surface color. They do not have shadows; instead, they have a **1px solid border (#00E5FF)** with a 4px outer glow (box-shadow: 0 0 8px rgba(0, 229, 255, 0.3)).
- **Dimensional Stacking:** When one window overlaps another, the lower window's border-glow dims by 50% to focus the player's attention on the foreground "Active" window.
- **Runic Accents:** Decorative glyphs are placed at 0.1 opacity behind text, creating a sense of layered magical depth within the window itself.

## Shapes
The shape language is **Aggressive and Precise**. 

- **Primary Radius:** A consistent 4px (Soft) radius is applied to all main windows and buttons. This provides just enough refinement to look "designed" while maintaining a sharp, weapon-like edge.
- **Beveling:** Large UI containers should feature 45-degree "clipped" corners (dog-eared) rather than rounding, reinforcing the metallic/magical plate aesthetic.
- **Dividers:** Use 1px horizontal lines that fade out at the edges (radial gradient) to separate content sections within a window.

## Components
- **System Buttons:** Rectangular with 4px radius. Default state has a Mana Cyan border. Hover state triggers a full Mana Cyan fill with black text and a 10px outer glow.
- **Mana/Health Bars:** Segmented progress bars. Each 10% of the bar is separated by a 1px void gap. HP bars are Crimson; MP bars are Cyan.
- **Quest Cards:** Feature a header with a "Rank" letter (E, D, C, B, A, S) in the top-right corner, stylized in Space Grotesk Bold and framed in Royal Gold.
- **Input Fields:** Minimalist. Only a bottom border of 2px Mana Cyan. Text entry appears in JetBrains Mono.
- **Runic Glyphs:** Small, non-functional icons placed at the corners of windows. They should pulse slowly (2s duration) to indicate the system is "processing."
- **Floating Tooltips:** Pure black (#000000) with a Rune Violet border, appearing near the cursor or touch point for item descriptions.