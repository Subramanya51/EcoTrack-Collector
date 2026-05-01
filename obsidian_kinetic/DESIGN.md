# Design System Strategy: Operational Tactical High-Contrast

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Tactical Command Center."** 

This isn't a consumer app; it is a high-performance instrument for field operatives. We are moving away from the "soft and friendly" web aesthetic toward a rugged, industrial, and high-precision interface. By leveraging the deep contrast between the `surface-dim` (#071325) and the `primary` Neon Green (#75ff9e), we create an environment that prioritizes legibility in high-glare outdoor conditions while maintaining a premium, "GTA-style" dark-ops aesthetic.

To break the "template" look, we utilize **intentional asymmetry**. Action modules should feel like physical hardware bolted onto the interface. We avoid centered, symmetrical layouts in favor of data-heavy, left-aligned "rugged" stacks that mimic a cockpit display.

---

## 2. Colors
Our palette is engineered for low-light environments and high-stress decision-making.

- **Primary (`primary` / `primary_container`):** The "Go" signal. Use `#00E676` specifically for success states and active route tracking.
- **Secondary (`secondary` / `secondary_container`):** The "Caution" signal. Use `#FFB300` for pending pickups or vehicle maintenance alerts.
- **Surface Hierarchy:** 
    - Use `surface_container_lowest` (#030e20) for the global background.
    - Use `surface_container` (#142032) for the primary "work area" or map overlays.
    - Use `surface_container_highest` (#2a3548) for interactive cards and floating modals.

### The "No-Line" Rule
Explicitly prohibit 1px solid borders for sectioning. To separate a "Bin ID" module from a "Route Progress" module, use a background shift from `surface_container_low` to `surface_container_high`. If elements feel like they are "bleeding" together, increase the spacing using the `Spacing Scale (4 / 1.4rem)` rather than adding a line.

### The "Glass & Glow" Rule
For bottom sheets and floating action buttons (FABs), use `surface_container_highest` with a 60% opacity and a `backdrop-filter: blur(20px)`. To signify an active state (e.g., a "Current Task" card), apply a subtle `0px 0px 15px` outer glow using the `primary` color at 30% opacity. This creates a "neon-on-asphalt" vibe that feels premium and intentional.

---

## 3. Typography
The typography system is split between "Industrial Utility" and "High-Precision Data."

- **Display & Headlines (`workSans`):** Use for bold, short instructions (e.g., "NEXT STOP," "DUMP FULL"). It provides a "workman" feel—sturdy, wide, and authoritative.
- **Titles & Body (`inter`):** Used for logistical details and descriptive text. It is neutral and highly legible to balance the aggressive headlines.
- **Labels (`spaceGrotesk`):** This is our "Mono-Style" proxy. Use this for Route IDs, GPS coordinates, and weight stats. The geometric nature of Space Grotesk provides that "high-tech instrument" feel without the legibility issues of a true monospaced font.

---

## 4. Elevation & Depth
In this system, depth is a tool for focus, not just decoration.

- **The Layering Principle:** Treat the UI as a series of tactical panels. A map resides at `surface_dim`. A persistent bottom navigation sits at `surface_container_low`. A critical alert "pops" at `surface_container_highest`.
- **Ambient Shadows:** Standard dropshadows are forbidden. If an element must float (like a FAB), use a large, 24px blur with a color sampled from our `surface_container_lowest` (#030e20) at 40% opacity. It should look like the component is hovering in a dark room, casting a soft, ambient occlusion shadow.
- **The Ghost Border:** If a boundary is required for an input field, use the `outline_variant` token at 15% opacity. This "Ghost Border" provides just enough structure for the eye without breaking the dark-mode immersion.

---

## 5. Components

### Buttons (Tactical Trigger Style)
- **Primary:** Full `primary` (#75ff9e) background with `on_primary` (#003918) text. Minimum height: **56px**. This is the "Action Taken" button.
- **Secondary:** `surface_container_highest` background with a `primary` Ghost Border. 
- **Urgent/Red:** Use the `error` token (#ffb4ab) only for "Emergency Stop" or "Report Hazard."

### Tactical Cards
- **Construction:** Use `surface_container` (#142032) with a `xl` (0.75rem) roundedness.
- **Content:** No dividers. Use `Spacing Scale 3` (1rem) to separate the Title from the Data. Use a `primary_container` vertical accent bar (4px width) on the left side of a card to denote the "Active" task.

### Inputs & Fields
- **Container:** Darker than the card surface (`surface_container_lowest`). 
- **Focus State:** Instead of a border change, use a `primary` neon glow (4px spread, 20% opacity) to make the field "hum" with energy.

### Maps (The "GTA" Style)
- Use `Map BG #0A0F0D`.
- Roads should be `surface_container_highest`. 
- Active paths use a 4px `primary` line with a soft outer glow.

---

## 6. Do's and Don'ts

### Do:
- **Use Large Tap Targets:** Ensure every interactive element is at least 56px tall. Drivers are wearing gloves or bouncing in a cab; precision is a luxury they don't have.
- **Leverage Color for Status:** Use `secondary` (Amber) for "Pending" and `primary` (Green) for "Complete." The user should understand the status of their day without reading a single word.
- **Embrace Negative Space:** Use the `Spacing Scale 6` (2rem) between major functional groups to prevent "visual clutter" during high-speed operations.

### Don't:
- **Don't Use Dividers:** Never use a 1px line to separate list items. Use a 4px gap or a slight shift in surface tone.
- **Don't Use White:** Pure white (#FFFFFF) is too harsh for this dark-ops theme. Always use `Text Primary #E8F4FD` (a very pale blue) to maintain the "Deep Navy" atmosphere.
- **Don't Use Standard Shadows:** Avoid "Material Design" style 2dp/4dp shadows. Use tonal shifts or large, diffused ambient glows.