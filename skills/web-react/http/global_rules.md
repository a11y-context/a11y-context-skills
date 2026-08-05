---

id: "global_ruleset.baseline"
title: "Foundations"
toc_max_heading_level: 2
slug: "/foundations"
stack: "web/react"
rule_set: "baseline"
status: "beta"
summary: "Baseline accessibility rules applied across most UI work."
cache_ttl_seconds: 86400
apply_policy:
  instruction: "Apply all MUST rules that match the current change scope. If the task does not touch a scope, do not introduce unrelated changes."
  scopes_in_order: ["utility", "page", "layout", "component", "style"]

---

# Foundations

Foundations are the accessibility rules that aren't tied to a single component — utilities used across patterns (like `sr-only`), page-level structure (landmarks, headings, page titles), and visual fundamentals (text contrast, focus indicators). The rules below are the cross-cutting requirements every UI implementation should meet.

## Rule: Offscreen Text Utility (sr-only)

```yaml
id: global.sr-only
scope: [utility, component, style]
```

### Must Haves
- Where a component's rules dictate the use of "offscreen text", then the snippet below must be included as a CSS class: `.sr-only`.
- Offscreen text may be used as an alternative to `aria-labelledby` or `aria-label`.

### Don'ts
- Do not hide offscreen text using `display: none` or `visibility: hidden` when it is needed for an accessible name.
- Do not leave focusable content inside a visually hidden container that stays hidden while focused. A keyboard user reaches it with nothing visible on screen, and the focus indicator appears to vanish.
  - A visually hidden control that returns to the visible layout on focus is the acceptable case, such as a skip link. Pair `.sr-only` with the `:focus` restoration below.

### Snippets
```css
.sr-only {
  clip: rect(1px,1px,1px,1px);
  height: 1px;
  overflow: hidden;
  position: absolute;
  white-space: nowrap;
  width: 1px;
  user-select: none;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
}
```

For a visually hidden element that must become visible when it receives focus, such as a skip link. `:focus-within` covers the case where the focusable element is a descendant of the hidden container:

```css
.sr-only-focusable:focus,
.sr-only-focusable:focus-within {
  clip: auto;
  height: auto;
  overflow: visible;
  position: static;
  white-space: normal;
  width: auto;
}
```

### Acceptance Checks
- Where offscreen text is implemented, it is not overridden by `aria-labelledby` or `aria-label`.
- Tabbing through the page never lands on a control that is invisible at the moment it holds focus.
- Any visually hidden control intended to be reachable, such as a skip link, becomes visible when it receives keyboard focus.

---

## Rule: Page Title

```yaml
id: global.page-title
scope: [page]
```

### Must Haves
- Each page (route/view/document) sets a descriptive page title that reflects the central topic of the current page.
- The page title begins with the name of the current page and is followed by the name of the site.
  - Page name and site name should be separated using a clear visual character, such as a hyphen, emdash, or vertical pipe.
  - Page name should be similar to the `<h1>` text on the page.

### Don'ts
- Do not leave the page title as a generic placeholder across routes.

### Acceptance Checks
- Browser tab title changes appropriately when navigating to the page.
- The browser tab title includes the page name and then the site name, with a clear separator between.

---

## Rule: Landmarks

```yaml
id: global.landmarks
scope: [page, layout]
```

### Must Haves
- When site or app navigation is present on a page (route/view/document), this is contained inside a `<nav>` (or `role="navigation"`) landmark, which is contained inside a `<header>` (or `role="banner"`) landmark.
  - If a single set of navigation is present, then it should be labeled (e.g., `<nav aria-label="primary">`).
  - If more than one set of navigation is present - e.g., primary and secondary or breadcrumbs - then each `navigation` landmark must be labeled (e.g., `<nav aria-label="primary">`, `<nav aria-label="secondary">`, `<nav aria-label="breadcrumbs">`).
- When a footer is present - i.e., a section at the bottom of the page with information relevant to the entire site, such as a sitemap or navigation links - this is contained inside a `<footer>` (or `role="contentinfo"`) landmark
- A `<main>` (or `role="main"`) landmark must always be present.
  - The `main` landmark contains the dominant content of the page, which directly relates to or expands upon the central topic of the page, or the central functionality of an application.
  - If site or app navigation is present at the top of the page or view (i.e., `header`), and/or a footer (`footer`) is present at the bottom of the page, the `main` landmark should wrap all content between `header` and `footer` content
  - The `main` landmark must be a sibling of the `header` and/or `footer` containers.
- If the page contains complementary content - i.e., content that is only indirectly related to the page's main content - this is contained inside an `<aside>` (or `role="complementary"`) landmark
  - The `aside` landmark is infrequently used and does not need to be present.
  - If present, the `aside` landmark should be a sibling to the `main` landmark, and to the `header` and/or `footer`, if present.

### Don'ts
- Do not use multiple `main` landmarks on the same page.
- Do not wrap the `header`, `footer`, or `aside` inside the `main` landmark, or vice-versa: these should all be siblings.

### Acceptance Checks
- There is one `main` landmark present on every page.
- If there is site or app navigation present, this is contained inside a `nav` landmark, which is contained inside a `header` landmark, sibling to the `main`.

---

## Rule: Heading Structure

```yaml
id: global.headings
scope: [page, layout]
```

### Must Haves
- Each page (route/view/document) has one level 1 heading, or `<h1>`, that identifies the main topic of the page.
- Headings are nested in a logical order according to the relationships of the content they introduce.
  - An `<h2>` introduces a major section of the page.
  - An `<h3>` introduces a subsection of the preceding `<h2>`, and so on.
  - When closing a subsection and returning to a higher-level section, it is acceptable to return to a higher heading level.
- If text visually functions as a heading, it must be marked up as a heading element rather than only styled to look like one.
- If footer links are grouped under visible group titles (e.g., "Company", "Support", "Legal"), each group title is a level 2 heading (`<h2>`).
- Headings are descriptive of the content they introduce.

### Customizable
- Section headings use native HTML heading elements (`<h1>` through `<h6>`) to communicate the structure of the page.
  - If native elements are unavailable, headings can be implemented with `role="heading"` and `aria-level`.

### Don'ts
- Do not use heading elements only to make text look larger or bolder.
- Do not skip heading levels when moving deeper into the hierarchy, such as going from `<h2>` directly to `<h4>`, unless closing a subsection and returning to a higher-level section.
- Do not use non-heading elements as visual-only section titles when they function as headings.

### Acceptance Checks
- Each page has one clear primary heading that identifies the main topic of the page.
- The heading structure forms a logical outline of the content.
- When heading depth increases, levels are not skipped.
- Headings are descriptive of the content they introduce.
- Footer link-group titles, when present, are marked up as `<h2>` headings.
- Text that appears visually to be a heading is programmatically marked up as a heading.
- No empty heading elements are present.

---

## Rule: Text Contrast

```yaml
id: global.text-contrast
scope: [page, layout, component, style]
```

### Must Haves
- Text and images of text must have sufficient contrast against their background.
  - Normal-size text must meet a contrast ratio of at least 4.5:1.
  - Large-scale text (18pt regular, or 14pt bold) must meet a contrast ratio of at least 3:1.
- Text placed over a background image also has a `background-color` behind it, so it stays legible when Windows High Contrast Mode drops the image. See `global.forced-colors`.
- `forced-color-adjust: none` is not applied to text or its container, which would pin the authored text colors and prevent the user's palette from applying.

### Don'ts
- Do not use color combinations for text that fall below 4.5:1 for normal text or 3:1 for large text.
- Do not rely on a background image alone to establish the contrast behind text.

### Acceptance Checks
- Normal text meets at least 4.5:1 contrast against its background.
- Large-scale text meets at least 3:1 contrast against its background.
- With forced colors active, all text remains legible, including text that sits over a background image.

---

## Rule: Non-text Contrast

```yaml
id: global.non-text-contrast
scope: [page, component, style]
```

### Must Haves
- Visual information needed to identify a user interface component - such as control boundaries - must have a contrast ratio of at least 3:1 against adjacent colors.
  - In other words, a component's border or background color must contrast at least 3:1 against the page's background color.
- Meaningful graphical objects must have a contrast ratio of at least 3:1 against adjacent colors when their appearance is needed to understand the content.
  - This includes meaningful icons, simple charts, data marks, indicators, and other non-decorative graphics.
- A boundary carried by `background-color` alone is restated under `@media (forced-colors: active)`, since Windows High Contrast Mode replaces author backgrounds and the boundary disappears rather than merely losing contrast. See `global.forced-colors`.

### Don'ts
- Do not use very low-contrast borders, outlines, or icons when they are necessary to identify a control or its current state.
- Do not verify contrast only in the authored palette. A boundary that passes 3:1 can still vanish entirely under forced colors.

### Snippets

A boundary painted as a background fill needs a real border under forced colors, since the fill and its surroundings collapse to the same system color:

```css
@media (forced-colors: active) {
  .control-boundary {
    border: 1px solid CanvasText;
  }
}
```

### Acceptance Checks
- Visible UI controls and authored state indicators needed for perception meet at least 3:1 contrast against adjacent colors.
- Meaningful icons and other non-text graphics needed for understanding meet at least 3:1 contrast against adjacent colors.
- With forced colors active, every boundary and indicator that was carried by a background fill is still perceivable.

---

## Rule: Use of Color

```yaml
id: global.use-of-color
scope: [component, style]
```

### Must Haves
- Do not use color as the only visual means of conveying information, indicating an action, prompting a response, or distinguishing a visual element (WCAG 1.4.1).
- When a component renders a meaningful state visually (e.g., selected, active, current, invalid, pressed), that state is distinguishable by something in addition to color, such as an icon, checkmark, shape, underline, or text.
  - This is the visual counterpart to exposing the state programmatically. A component may satisfy `aria-selected` yet still fail 1.4.1 if selection is shown by a background tint alone.
- The additional cue is an icon, a shape, a border, or text rather than a second color treatment, so that it survives Windows High Contrast Mode. See `global.forced-colors`.
  - Forced colors is the reason this rule has teeth beyond grayscale: a state shown by a background tint does not merely lose contrast there, it is repainted with the system color and disappears.

### Don'ts
- Do not signal selection, validity, current-ness, or availability by color alone.
- Do not satisfy this rule with a second color treatment, such as a darker tint or a colored background swap, which fails under forced colors exactly as the first one does.

### Acceptance Checks
- Every meaningful state the component renders is perceivable without relying on color (verify in grayscale).
- With forced colors active, every meaningful state is still distinguishable, and the cue carrying it is not a background tint.

---

## Rule: Forced Colors (Windows High Contrast Mode)

```yaml
id: global.forced-colors
scope: [component, style]
```

Windows High Contrast Mode replaces the author's palette with a small set of user-chosen system colors. It is not a dark theme: `background-color`, `border-color`, and `color` are re-mapped, `box-shadow` is removed, and some background images are dropped. Anything whose meaning rested on those properties alone disappears.

### Must Haves
- An element distinguished from its surroundings only by `background-color` also carries a real `border`, so its boundary survives when backgrounds are flattened.
  - This covers progress fills against their tracks, selected rows, badges, chips, pills, custom form-control indicators, and any painted state layer.
- Where the authored colors carry meaning the system palette would erase, pair the styling with a `@media (forced-colors: active)` block that restates the distinction using CSS system color keywords.
  - The keywords are `Canvas`, `CanvasText`, `LinkText`, `VisitedText`, `ActiveText`, `ButtonFace`, `ButtonText`, `ButtonBorder`, `Field`, `FieldText`, `Highlight`, `HighlightText`, `SelectedItem`, `SelectedItemText`, `Mark`, `MarkText`, `GrayText`, `AccentColor`, and `AccentColorText`.
- `box-shadow` is not the only carrier of a boundary, a state, or an elevation cue that the user needs, since shadows are removed under forced colors.
- Icons drawn as a CSS `background-image` are paired with a forced-colors fallback, such as an inline SVG or a text alternative.
  - Inline SVG painted with `fill: currentColor` or `stroke: currentColor` inherits the system text color and needs no override.
- `forced-color-adjust: none` is applied only to elements whose authored colors are themselves the information, such as a color-picker swatch, a chart series key, or a brand preview.
- Focus indicators follow `global.focus-states`, which carries its own required `forced-colors` override.

### Don'ts
- Do not convey state, selection, or a boundary with `background-color` alone.
- Do not rely on `box-shadow` for a border, a ring, or any cue that carries meaning.
- Do not apply `forced-color-adjust: none` broadly to preserve a design's ordinary palette. It overrides the colors the user chose and defeats the mode.
- Do not hard-code a color value inside a `@media (forced-colors: active)` block. The system keywords follow the user's chosen theme; a literal does not.
- Do not treat a component as verified because it reads correctly in a dark theme. Forced colors replaces the palette outright and removes shadows.

### Snippets

An element distinguished only by `background-color` vanishes when the palette is replaced. Restate the distinction with system colors, and give the container a border so its bounds survive:

```css
@media (forced-colors: active) {
  .indicator-track {
    border: 1px solid CanvasText;
  }

  .indicator-fill {
    background: Highlight;
  }
}
```

Opting out, for the narrow case where the authored color is the content itself:

```css
.swatch {
  forced-color-adjust: none;
}
```

### Acceptance Checks
- With Windows High Contrast Mode active, or emulated via a browser dev-tool forced-colors setting, every meaningful boundary, state, and indicator remains visible.
- Elements that were distinguished by background color alone remain distinguishable from their surroundings.
- No meaningful element becomes invisible once shadows are removed.
- Colors inside `forced-colors` blocks come from the system keyword palette rather than being hard-coded.
- `forced-color-adjust: none` appears only where the authored color is itself the information.

---

## Rule: Focus Not Obscured

```yaml
id: global.focus-not-obscured
scope: [component, layout, style]
```

### Must Haves
- When a component receives keyboard focus, the focused element is not entirely hidden by author-created content such as sticky headers, sticky footers, or the component's own overlapping chrome (WCAG 2.4.11 Focus Not Obscured, Minimum).
- Components with their own sticky or floating sub-regions (e.g., a frozen header row or column) keep the focused element scrolled or offset into a visible area.

### Don'ts
- Do not let a sticky or floating region overlap and fully conceal the element that currently has keyboard focus.

### Acceptance Checks
- Tabbing or arrowing to any focusable element leaves at least part of that element and its focus indicator visible, not fully covered by sticky or overlapping content.

---

## Rule: Focus States

```yaml
id: global.focus-states
scope: [component, style]
```

### Must Haves
- Each keyboard-focusable user interface component must have a visible focus indicator when it receives keyboard focus.
- The focus indicator must have a contrast ratio of at least 3:1 against adjacent colors.

### Customizable 
- The focus indicator may take different forms, such as an outline, border, background change, underline, or other visible treatment, provided that it clearly indicates which element currently has keyboard focus.
- Prefer styling keyboard focus with `:focus-visible` so the indicator is shown when users navigate by keyboard, not on mouse click.
- **Strongly recommended:** a two-layer focus style — a 2px solid ring floated 2px outside the element with a white box-shadow behind it — so the indicator remains visible against any surrounding surface (light, dark, image, or gradient). See the first snippet below.
- A simple solid outline offset from the element remains acceptable when the surrounding surfaces are known and the ring's 3:1 contrast against them is verified.
  - Starting pattern: `outline: 2px solid ...`
  - Starting offset: `outline-offset: 2px` (`1px` may be used where spacing is tighter).
- **Windows High Contrast Mode (forced-colors) support is required for any focus style.** Pair the primary style with a `@media (forced-colors: active)` override that uses the `Highlight` CSS system color and drops the box-shadow. See the shared override snippet below.

### Don'ts
- Do not use a focus indicator whose color blends into adjacent colors below the required 3:1 contrast ratio.
- Do not make the focus indicator so subtle that users cannot quickly identify which element currently has focus.
- Do not rely on hover-only styles as the only visible indicator of focus.
- Do not ship focus styles without a `forced-colors` override — Windows High Contrast Mode users will lose the custom colors and be left with browser defaults that may not match the design's contrast intent.

### Snippets

Strongly recommended two-layer focus ring. The `box-shadow` extends 4px in white around the element; the outline floats 2px outside the element edge, so the white halo sits between the element and the colored ring for surface-independent visibility:

```css
:focus-visible {
  outline: 2px solid var(--focus-ring-color, #1a73e8);
  outline-offset: 2px;
  box-shadow: 0 0 0 4px #fff;
}
```

Acceptable simpler alternative when the surrounding surfaces are known and contrast is verified:

```css
:focus-visible {
  outline: 2px solid var(--focus-ring-color, #1a73e8);
  outline-offset: 2px;
}
```

Required forced-colors override — pair with either primary style above. `Highlight` maps to the OS-defined focus/selection color under Windows High Contrast Mode; `box-shadow: none` prevents doubled visuals under the system-managed palette:

```css
@media (forced-colors: active) {
  :focus-visible {
    outline: 2px solid Highlight;
    outline-offset: 2px;
    box-shadow: none;
  }
}
```

### Acceptance Checks
- Every keyboard-focusable component shows a visible focus indicator when reached by keyboard navigation.
- The visible focus indicator remains present while the component has keyboard focus.
- The focus indicator has at least 3:1 contrast against adjacent colors.
- If a custom focus style is used, it is clearly visible and does not make focus harder to perceive than the default browser or platform behavior.
- Hover alone is not the only visible cue for the currently focused element.
- With Windows High Contrast Mode active (or emulated via a browser dev-tool forced-colors setting), the focus indicator remains clearly visible using the system `Highlight` color.

---

## Rule: Motion and Unmounting

```yaml
id: global.motion
scope: [component, style]
```

Animation and content removal belong to one rule because they fail together. An element animating out is still in the DOM while it is visually gone, and that window is where keyboard focus is lost and the accessibility tree stops matching the screen.

### Must Haves
- Under `prefers-reduced-motion: reduce`, no animation repeats, travels an element across the screen, or scales it.
  - Changes to color, opacity, or blur that do not alter an element's perceived size, shape, or position are not motion animation and may continue.
  - Movement driven by a value the user is waiting on, such as a progress fill advancing, is not decorative motion and continues.
- Animation that starts automatically, lasts more than 5 seconds, and runs alongside other content provides a mechanism to pause, stop, or hide it, unless the movement is essential to an activity in progress (WCAG 2.2.2).
- Motion is not the only means of conveying that something changed. A change communicated by movement is also communicated by text, by a change in the accessibility tree, or by a live region.
- Before an element holding keyboard focus is removed from the DOM or made unfocusable, focus is moved to a stable element that remains present, such as the control that opened it or the container that replaces it.
- `aria-hidden="true"` is not applied to a focusable element, nor to any ancestor of one.
- An element being animated out leaves the accessibility tree when it stops being available to the user, not when its exit animation finishes.

### Don'ts
- Do not remove or disable an element that holds focus without first moving focus somewhere stable. Focus falls to the document body and the user loses their place in the page.
- Do not apply `aria-hidden="true"` to a container that holds a focusable control. A keyboard user reaches a control that assistive technology cannot report.
- Do not rely on an exit animation to communicate that something was removed.
- Do not treat `prefers-reduced-motion: reduce` as a request to remove the element. It asks for less movement, not less information.
- Do not hold content out of the accessibility tree for the duration of an entrance animation. It is available to a screen reader as soon as it is available at all.

### Snippets

Disable decorative motion under the reduced-motion preference. Scope it to the elements that animate decoratively rather than applying it to everything, so movement the user is waiting on still runs:

```css
@media (prefers-reduced-motion: reduce) {
  .marquee,
  .spinner,
  .slide-in {
    animation: none;
    transition: none;
  }
}
```

Reading the preference in script, for components that need to render differently rather than merely stop animating:

```js
const query = window.matchMedia("(prefers-reduced-motion: reduce)");
const apply = () => setReduceMotion(query.matches);
apply();
query.addEventListener("change", apply);
```

Moving focus before removal, deferred so the replacement is focusable by the time the call lands:

```js
requestAnimationFrame(() => returnTarget.current?.focus());
```

### Acceptance Checks
- With `prefers-reduced-motion: reduce` set, no element repeats an animation, travels across the screen, or scales.
- With that preference set, all content that would have animated in is present and readable, and nothing has been removed.
- Dismissing or collapsing a component that holds focus leaves focus on a stable, visible element, never on the document body.
- No focusable control has `aria-hidden="true"` on itself or on any ancestor.
- Content that has been dismissed is absent from the accessibility tree as soon as it is unavailable, not after its exit animation completes.
- Every change communicated by movement is also available without perceiving that movement.

---

## Rule: Icons

```yaml
id: global.icon
scope: [component, style]
```

An icon is meaningful when the user needs it to understand or operate the interface and no text beside it carries the same meaning. Everything else is decorative, which is most icons. The two are marked up in opposite ways, so answer this first.

### Must Haves
- Hide a decorative icon from assistive technology. Inline `<svg>` and icon-font elements take `aria-hidden="true"`; an `<img>` takes an empty `alt=""`.
- Expose a meaningful icon one of two ways: name the graphic, or supply its meaning as text.
  - To name it, give the graphic `role="img"` and `aria-label` or `aria-labelledby`. ARIA requires a label on `role="img"`.
  - To supply text, place the equivalent text beside the icon, visually hidden when it should not be seen (see `global.sr-only`), and hide the icon.
- For an icon-only control, put the accessible name on the `<button>` or `<a>` and leave the graphic decorative.
- Name what the control does or what the icon means, not what it depicts (e.g., "Add to my list", not "Plus sign").
- A meaningful icon carries the non-text contrast requirement in `global.non-text-contrast`. A decorative one does not.

### Don'ts
- Do not name both a control and the icon inside it. The control is announced with its name repeated (e.g., "Delete Delete button").
- Do not hide an inline `<svg>` with `role="presentation"` or `role="none"`. Unlike `aria-hidden="true"`, they drop the element's own role but leave its `<title>` and text descendants in the accessibility tree.
- Do not give a decorative graphic a `<title>` child, which names it.
- Do not use an emoji or an icon-font glyph as a meaningful icon without a text alternative. Emoji are announced by their Unicode name (a flame reads as "fire" where "trending" was meant), and icon-font glyphs read as private use area characters or as nothing.

### Snippets

Decorative, because the adjacent text already carries the meaning:

```jsx
<button type="button">
  <span aria-hidden="true">[download-icon]</span>
  Download
</button>
```

Icon-only control. The name lives on the control, and the graphic stays decorative:

```jsx
<button type="button" aria-label="Add to my list">
  <span aria-hidden="true">[plus-icon]</span>
</button>
```

Meaningful standalone icon, where no text nearby carries the status. Either route is correct, and the second one hides the graphic because the text has taken over the meaning:

```jsx
{/* Name the graphic. */}
<svg role="img" aria-label="Downloaded" width="16" height="16" viewBox="0 0 16 16">
  <path d="M2 8l4 4 8-8" fill="none" stroke="currentColor" strokeWidth="2" />
</svg>

{/* Or supply the meaning as text, which makes the graphic decorative. */}
<span>
  <svg aria-hidden="true" width="16" height="16" viewBox="0 0 16 16">
    <path d="M2 8l4 4 8-8" fill="none" stroke="currentColor" strokeWidth="2" />
  </svg>
  <span className="sr-only">Downloaded</span>
</span>
```

### Acceptance Checks
- Icons the user does not need, and icons whose meaning is already in adjacent text, are absent from the screen reader's output.
- Every icon the user does need is announced with its meaning.
- No control is announced with its name repeated.
- Icon-only controls are announced with a name describing the action, not the shape of the glyph.
- Controls that differ only by their icon are announced with different names.
- No announcement contains an icon font glyph, a private use area character, or an emoji name standing in for a meaning.