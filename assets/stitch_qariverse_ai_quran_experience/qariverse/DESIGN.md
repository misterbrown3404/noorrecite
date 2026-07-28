---
name: QariVerse
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3e4a3f'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6d7a6f'
  outline-variant: '#bdcabc'
  surface-tint: '#006d3a'
  primary: '#006a39'
  on-primary: '#ffffff'
  primary-container: '#008649'
  on-primary-container: '#f6fff4'
  inverse-primary: '#64dd91'
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#8df5e4'
  on-secondary-container: '#007165'
  tertiary: '#805200'
  on-tertiary: '#ffffff'
  tertiary-container: '#a16800'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#82faab'
  primary-fixed-dim: '#64dd91'
  on-primary-fixed: '#00210e'
  on-primary-fixed-variant: '#00522b'
  secondary-fixed: '#8df5e4'
  secondary-fixed-dim: '#70d8c8'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#ffddb5'
  tertiary-fixed-dim: '#ffb957'
  on-tertiary-fixed: '#2a1800'
  on-tertiary-fixed-variant: '#643f00'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-ar:
    fontFamily: Amiri
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 72px
  headline-lg:
    fontFamily: Literata
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Literata
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  body-ar:
    fontFamily: Amiri
    fontSize: 24px
    fontWeight: '400'
    lineHeight: 48px
  body-en:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin: 24px
  card-padding: 20px
---

## Brand & Style
The design system is centered on a "Ethereal Sanctuary" aesthetic, blending the divine tradition of Islamic art with cutting-edge UI trends. It targets a global audience seeking a premium, meditative experience for Quranic engagement. 

The style is a sophisticated fusion of **Modern Glassmorphism** and **Soft Neumorphism**. Surfaces feel like polished gemstone or frosted glass floating in a luminous void. The emotional response is intended to be one of tranquility, awe, and focus. To differentiate from standard utility apps, this system utilizes high-fidelity background blurs, subtle glowing edges, and soft, extruded depths to create a tactile sense of luxury and spirituality.

## Colors
The palette is rooted in the "Emerald Sanctum" scheme. 
- **Primary (Emerald Green):** Symbolizing life and paradise, used for main actions and active states.
- **Secondary (Deep Teal):** Provides grounding and depth, used for headers and structural containers.
- **Tertiary (Gold Accent):** Represents divine illumination, used sparingly for highlights, verse markers, and premium features.
- **Gradients:** Backgrounds should never be flat. Use a radial gradient moving from `#00897B` at the top left to `#061A14` at the bottom right in dark mode, and a soft off-white to pale mint gradient in light mode.
- **Glass Effects:** Use 15% opacity white (Light Mode) or 10% opacity emerald (Dark Mode) for glass panels with a 20px backdrop blur.

## Typography
This design system employs a bi-scriptual hierarchy. 
- **Arabic Text:** Uses **Amiri**, a classical typeface that honors the calligraphic tradition. It requires generous line heights (minimum 1.8x) to accommodate diacritics (Tashkeel).
- **English/Latin Text:** **Literata** is used for headings to maintain an editorial, authoritative feel, while **Inter** provides a clean, systematic foundation for body copy and interface labels.
- **Scale:** On mobile, prioritize the Arabic text size. Translation text should be 25-30% smaller than the corresponding Arabic text to maintain visual hierarchy.

## Layout & Spacing
The layout follows a **Fluid Grid** approach with generous safe zones. 
- **Rhythm:** An 8px base unit is used for most spacing, but 4px increments are allowed for micro-adjustments in typography.
- **Safe Areas:** Maintain a 24px horizontal margin on mobile to allow the "floating" elements to breathe against the screen edge.
- **Verticality:** Use substantial vertical spacing between Ayahs (verses) to encourage a slow, meditative reading pace.
- **Patterns:** Subtle Islamic geometric patterns (8-point stars) should be used as a low-opacity watermark (2-5% opacity) within the main background, fixed to the viewport.

## Elevation & Depth
The system uses a unique "Luminous Layering" model:
- **Level 0 (Background):** Deep gradients with fixed geometric patterns.
- **Level 1 (Floating Cards):** Glassmorphic panels with a 1px inner "light leak" stroke (white at 20% opacity) on the top and left edges to simulate physical thickness.
- **Level 2 (Interactive Elements):** Neumorphic "soft-extrusion." Elements appear to be pushed out from the glass surface using two shadows: a dark shadow (`rgba(0,0,0,0.1)`) and a highlight shadow (`rgba(255,255,255,0.05)`).
- **Glows:** Primary buttons and active indicators should have a soft outer glow in the primary Emerald color (`blur: 15px, spread: -2px`).

## Shapes
The shape language is organic and soft, avoiding sharp corners to maintain a "gentle" spirit. 
- **Cards & Containers:** Use `rounded-lg` (16px) as the standard.
- **Interactive Controls:** Buttons and input fields use `rounded-xl` (24px) or full pill-shapes for a modern, tactile feel.
- **Icons:** Use a 2px stroke weight with rounded terminals. Avoid filled icons unless they are in an active state.

## Components
- **Buttons:** Primary buttons use a lush Emerald gradient with a soft shadow. The label should be Inter Semibold in White. Secondary buttons are "ghost glass" with a subtle Gold border.
- **Ayah Cards:** These are the centerpiece. Use a high-blur glass background. The Arabic text is centered. Include a small, Gold-accented "Surah Ornament" for the verse number.
- **Navigation Bar:** A floating glass dock at the bottom of the screen. Active icons should "glow" with a subtle Emerald under-light.
- **Audio Player:** A neumorphic "drawer" that slides from the bottom. The play/pause button should be the most tactile element, using a deep-teal-to-emerald gradient.
- **Chips/Tags:** Used for "Juz" or "Topic" markers. Small, pill-shaped with a faint Emerald tint and `label-caps` typography.
- **Input Fields:** Softly inset (concave) into the background to create a "pressed" neumorphic effect, making the search feel like a physical part of the interface.