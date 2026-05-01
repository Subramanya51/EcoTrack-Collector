```markdown
# Design System Specification: The Lucid Navigator

## 1. Overview & Creative North Star
**Creative North Star: The Lucid Navigator**
This design system is engineered to transform complex logistics into a frictionless, high-end editorial experience. We are moving away from the cluttered "utility-first" dashboard look and toward a "guided-path" philosophy. By utilizing intentional asymmetry, massive typography scales, and a "one-action-per-screen" layout, we ensure that even the least tech-literate user feels empowered and sophisticated. 

The aesthetic is defined by the tension between the deep, silent depths of the navy base (`#071325`) and the electric precision of the neon green accent (`#00E676`). It is not a tool; it is a premium instrument.

---

## 2. Colors & Surface Architecture
The color palette utilizes a sophisticated dark-mode hierarchy that prioritizes optical comfort and clear mental mapping.

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders for sectioning are strictly prohibited. 
Boundaries must be defined solely through background color shifts or tonal transitions. Use `surface-container-low` to sit on top of a `surface` background to create a logical break. Visual separation is achieved through the Spacing Scale, not through strokes.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of obsidian glass.
*   **Base Layer:** `surface` (#071325) – The foundation.
*   **Content Areas:** `surface-container` (#142032) – Standard grouping.
*   **Elevated Actions:** `surface-container-high` (#1f2a3d) – For cards that require interaction.
*   **Floating Elements:** `surface-container-highest` (#2a3548) – For ephemeral states or critical focus modals.

### The Glass & Gradient Rule
To move beyond a "standard" flat UI, apply semi-transparent surface colors with a `backdrop-blur` (suggested 12px-20px) for floating action buttons or navigation bars. For primary CTAs, use a subtle linear gradient from `primary` (#75ff9e) to `primary_container` (#00e676) at a 135-degree angle to provide a sense of "luminescence" and soul.

---

## 3. Typography: The Editorial Voice
We use **Work Sans** as a mono-typeface system. The hierarchy is designed to minimize reading time by emphasizing scale.

*   **The Hero Statement (Display LG/MD):** Used for the single primary action or data point on the screen. It should be bold and authoritative.
*   **The Command (Headline SM/MD):** Used for direct instructions (e.g., "Scan the QR Code").
*   **The Whisper (Label SM/MD):** For metadata. Use `on_surface_variant` (#bacbb9) to ensure it sits back in the visual hierarchy, allowing the primary data to shine.

**Editorial Spacing:** Maintain a generous line-height for body text (1.5 or 1.6) to ensure the dark-mode text remains legible and premium. Typography is our primary "iconography" alongside the actual glyphs.

---

## 4. Elevation & Depth
In this design system, depth is achieved through **Tonal Layering** rather than traditional structural lines.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section to create a soft, natural lift. This mimics how light interacts with physical matte surfaces.
*   **Ambient Shadows:** When a "floating" effect is mandatory (e.g., a bottom sheet), shadows must be extra-diffused. 
    *   *Blur:* 40px–60px.
    *   *Opacity:* 6%–10%.
    *   *Color:* Use a tinted version of `surface_container_lowest` rather than pure black to keep the navy base feeling rich and deep.
*   **The Ghost Border Fallback:** If accessibility requires a container boundary, use the `outline_variant` token at **15% opacity**. Never use 100% opaque borders.

---

## 5. Components & Interaction Patterns

### The "One-Action" Button (Primary)
*   **Background:** Gradient from `primary` to `primary_container`.
*   **Text:** `on_primary` (#003918), bold.
*   **Shape:** `xl` roundedness (0.75rem) for a modern, tactile feel.
*   **State:** On hover, apply a soft outer glow using the `primary` color at 20% opacity.

### Action Cards & Lists
*   **Rule:** Forbid the use of divider lines. 
*   **Separation:** Use `spacing-6` (2rem) or `spacing-8` (2.75rem) to separate list items. 
*   **Interaction:** On press, the card should shift from `surface-container` to `surface-container-high`.

### Input Fields
*   **Visual Style:** Minimalist. No bounding box. Use a subtle `surface-container-low` background with a `primary` color "underline" (2px) that only appears when the field is focused.
*   **Icons:** Use large, clear icons from the `primary` color palette to the left of the input to signify the "type" of data required.

### Selection Chips
*   **Unselected:** `surface-container-high` background with `on_surface_variant` text.
*   **Selected:** `primary` background with `on_primary` text. Use `full` (9999px) roundedness to make them feel like physical "pills."

### The "Focus" Icon
For the "one-action-per-screen" layouts, use extra-large icons (48px or 64px) centered above the headline. Icons should be monochrome `primary` or `on_surface` to maintain a high-end logistics aesthetic.

---

## 6. Do's and Don'ts

### Do:
*   **Do** use extreme whitespace. If you think there is enough room, add another 1rem of padding.
*   **Do** use `on_surface_variant` for secondary information to create a "dimmed" effect.
*   **Do** ensure the primary action button is always the most luminous object on the screen.
*   **Do** use `surface_bright` sparingly to highlight critical updates or success states.

### Don't:
*   **Don't** use pure black (#000000) or pure white (#FFFFFF). Stick to the navy (`#071325`) and off-blue (`#d7e3fc`) tokens.
*   **Don't** stack more than two "actions" on a single screen. If there are three, move the third to a new step.
*   **Don't** use standard drop shadows with high opacity; it ruins the "glass and metal" logistics aesthetic.
*   **Don't** use generic system fonts. Always render in Work Sans to maintain the signature high-end identity.

---
**Director’s Final Note:** This design system is about the *confidence of the void*. Do not be afraid of the empty navy space. The space is what makes the neon green feel valuable. Every pixel must serve the user’s next single step.```