---
id: separator.basic
title: Separator
stack: web/react
status: beta
latest_version: 0.1.0
tags: [separator, divider, thematic-break, structure, semantics]
aliases: [divider, horizontal rule, hr, rule, hairline, section break, thematic break, vertical divider, list divider, menu divider]
summary: Static line separating sections of content, rendered as an hr and hidden from assistive technology unless the line itself is the only thing marking the boundary.
---

# Separator

Pattern ID: `separator.basic`

Static line separating sections of content, rendered as an `<hr>` and hidden from assistive technology unless the line itself is the only thing marking the boundary.

Every requirement here follows from one question: **is the boundary already in the markup?** If the content on either side sits in its own `<section>` or `<article>`, or begins with a heading, or is a list item, then a screen reader already knows where one thing ends and the next begins, and the line only repeats that visually. It is decorative. If the content is a flat run with no headings, no sectioning elements, and no list structure, and the line is the only signal that the topic changed, then the line carries information and must be exposed. Most separators are the first kind. A separator is never focusable and has no keyboard behavior.

## Use When
- Use when a visible line marks a break between sections of content (e.g., between entries in a feed, or between groups of settings on a preferences screen).
- Use when a line separates groups of items or controls inside a container (e.g., separating destructive actions from the rest of a menu).

## Do Not Use When
- Do not use when the divider can be moved by the user to resize the regions on either side of it, which is a focusable widget with a value and a keyboard model rather than a static line (use `splitter.basic`).
- Do not use when the line is a border belonging to a single element, such as a card edge, an input underline, or a rule between table cells. That is styling on that element rather than a break between two things, and it needs no separator semantics.

## Must Haves
- A decorative separator is `<hr aria-hidden="true">`. It is decorative when the boundary it draws is already carried by the surrounding markup, such as `<section>` or `<article>` elements, headings, or list items.
- A meaningful separator is a plain `<hr>`, which carries the `separator` role implicitly and needs no ARIA. It is meaningful when the line is the only thing marking where one topic ends and the next begins.
- A separator that is exposed and runs vertically carries `aria-orientation="vertical"`, because `horizontal` is the implicit value for this role.
- A separator that is exposed is a graphical object the reader needs, and carries the contrast requirement in `global.non-text-contrast`. A decorative one does not, because it conveys nothing that needs to be perceived.
- A separator drawn as a `background-color` fill rather than a `border` is restated under forced colors, where author backgrounds are replaced and the line disappears entirely. See `global.forced-colors`.

## Customizable
- Drawing the line as a CSS `border` on an element that is already in the markup, instead of adding an `<hr>`. This is equivalent to the decorative case and adds no node at all, which is often the cleaner result when the separator is purely visual.
- Using `role="separator"` on another element where the host element's content model does not permit `<hr>`. Between list items this is the only correct route, and it takes the form `<li role="separator">`.
- Thickness, color, length, inset, and surrounding spacing are all at the engineer's discretion, subject to the contrast requirement above when the separator is exposed. `<hr>` is fully styleable; reset its default border and margins first (e.g., `border: none; border-top: 1px solid; margin: 0;`).
- Whether a section break also carries a visible label (e.g., "Today" above a group of notifications). When it does, that label is a heading and the line beside it is decorative, because the heading already communicates the break.

## Don'ts
- Do not use `<hr>` as a child of `<ul>`, `<ol>`, or `<menu>`. Those elements accept only `<li>` and script-supporting elements, so an `<hr>` between list items is invalid markup. Use `<li role="separator">` instead.
- Do not make a separator focusable. It has no interactive behavior, so a `tabindex` produces a tab stop that does nothing.
- Do not place text, icons, or controls inside a separator. The role has presentational children, so that content is not announced.
- Do not give a decorative separator an accessible name. It produces an announcement carrying no information.
- Do not repeat separators to create rhythm or spacing. Each exposed one is announced, and spacing is a style concern.
- Do not rely on a separator alone to convey a grouping. Even when exposed it reports a boundary without saying what the groups are, so a reader who needs to know what changed still needs a heading or a labelled region.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
export function SeparatorDemo() {
  return (
    <div>
      {/* Decorative: each section has a heading, so the boundary is already in the markup. */}
      <section>
        <h2>Continue watching</h2>
        <p>Signal Lost, Season 2</p>
      </section>
      <hr aria-hidden="true" />
      <section>
        <h2>Because you watched Night Dispatch</h2>
        <p>The Quiet Hours, Static Sky</p>
      </section>

      {/* Meaningful: a flat run with no headings, so the line is the only marker of the break. */}
      <p>The dispatcher works the overnight shift alone.</p>
      <hr />
      <p>Two years earlier, the same station had three people on nights.</p>

      {/* Exposed and vertical, so the implicit horizontal orientation is overridden. */}
      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
        <p>Now playing</p>
        <hr aria-orientation="vertical" style={{ alignSelf: "stretch" }} />
        <p>Up next</p>
      </div>
    </div>
  );
}
```

## Acceptance Checks

Screen Reader
- Reading through the page does not announce a separator for any line whose boundary is already carried by a heading, a sectioning element, or a list item.
- Every line that is the only marker of a topic change is announced as a separator at the point the break occurs.
- No separator is announced with a name, a label, or any inner text.

Keyboard
- Tabbing through the page never lands on a separator.

Structure
- No `<hr>` appears as a child of a `<ul>`, `<ol>`, or `<menu>` element.
- Exposed vertical separators carry `aria-orientation="vertical"`.
- With forced colors active, every separator that is still meant to be seen remains visible.
