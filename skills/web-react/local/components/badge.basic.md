---
id: badge.basic
title: Badge
stack: web/react
status: beta
latest_version: 0.1.0
tags: [badge, count, status, indicator, notification-count]
aliases: [badge, status badge, count badge, notification badge, unread count, status chip, lozenge, pill]
summary: Small non-interactive indicator annotating a host element with a count or a status, where the meaning is folded into an accessible name and read on arrival rather than announced on change.
---

# Badge

Pattern ID: `badge.basic`

Small non-interactive indicator annotating a host element with a count or a status, where the meaning is folded into an accessible name and read on arrival rather than announced on change.

## Use When
- Use when a small indicator on or beside another element reports a count for that element (e.g., unread messages on a mail icon, items in a cart).
- Use when a small indicator reports a status of the element it annotates (e.g., "Live" on a channel tile, an online dot on an avatar, "New" on a menu entry).

## Do Not Use When
- Do not use when the user must be told about the change immediately, without navigating to the indicator (use `toast.basic`).
- Do not use when the indicator can be selected, dismissed, or removed by the user (use `tag.basic`).
- Do not use when the element is supplementary text revealed on hover or focus of another control (use `tooltip.basic`).
- Do not use when the indicator is the control the user activates, such as a filter that toggles on click (use `button.toggle`).

## Must Haves

### Roles & structure
- When the badge annotates a control, it is rendered inside that control's element, so its text joins the control's accessible name.
  - When it cannot be rendered inside, because it is positioned over a separate element or the host is not a nameable control, the host carries the meaning through its own name and the badge is `aria-hidden="true"`.
- A badge that annotates no host is plain text content and needs no role.

### Accessible name
- The badge's meaning is available as text. A badge rendered only as a colored dot, a shape, or a fill has a text alternative (e.g., "Online", "Live", "3 unread").
- The text states what the value represents, not the value alone. A control named "Notifications" carrying a badge reading "3" is named "Notifications, 3 unread".
- When the badge is inside a control and displays text, the control's accessible name contains that text (WCAG 2.5.3), including a capped value such as "9+".
- The badge's meaning appears once in the host's accessible name.
- A badge duplicating text already visible inside the same control is `aria-hidden="true"`.

### State & properties
- The accessible name tracks the rendered value.
- When no badge is rendered, the host's accessible name makes no claim about one. A control with no badge is named "Notifications", not "Notifications, 0 unread".
- The badge stays distinguishable without color and keeps a real border rather than a background fill alone, per `global.use-of-color` and `global.forced-colors`.

## Customizable
- Shape and placement. A dot, a circle, a pill, or a rectangle, on a corner of the host or beside it.
- Where the text alternative lives. Visually hidden text inside the badge, and the meaning folded into the host's own name, are equally acceptable. The second is preferred when the badge is not a descendant of its host.
- Whether a count is capped for display, and at what threshold, as long as the accessible name carries the text the badge shows.
- Whether the badge renders at zero or at an empty status, as long as the host's name agrees with what is rendered.

## Don'ts
- Do not make the badge focusable, give it an interactive role, or render it as a `<button>` or a link.
- Do not announce the badge on change with `aria-live`, `role="status"`, or `role="alert"`. A count that increments while the user is reading elsewhere interrupts work the badge is not urgent enough to interrupt.
- Do not leave the count or status in `aria-hidden` content with nothing else carrying it. Hidden descendants are excluded from name computation, so the value is dropped while the screen still looks correct.
- Do not repeat the badge's text in both the host's content and an `aria-label` on the host.
- Do not hard-code a count into an `aria-label` that does not track the rendered value.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

// Visually-hidden styles matching the global sr-only utility (global.sr-only).
const srOnly = {
  clip: "rect(1px, 1px, 1px, 1px)",
  height: "1px",
  overflow: "hidden",
  position: "absolute",
  whiteSpace: "nowrap",
  width: "1px",
};

// The border is load-bearing: a boundary carried by a background fill alone
// disappears under forced colors (global.forced-colors).
const anchor = { position: "relative", display: "inline-block" };
const dot = {
  position: "absolute",
  right: 0,
  bottom: 0,
  width: "10px",
  height: "10px",
  borderRadius: "50%",
  border: "1px solid",
};

/** `describes` is read but not shown: a badge of "3" announces as "3 unread". */
export function Badge({ children, describes }) {
  return (
    <span>
      <span>{children}</span>
      {describes ? <span style={srOnly}> {describes}</span> : null}
    </span>
  );
}

// What varies across these is where the accessible name lives, not the badge.
function BadgeExamples({ unread }) {
  return (
    <>
      {/* Inside a nameable control: the badge's text joins the button's name.
          At zero no badge renders and the button claims nothing. */}
      <button type="button">
        <span aria-hidden="true">[icon]</span>
        Notifications
        {unread > 0 && (
          <Badge describes="unread">{unread > 9 ? "9+" : unread}</Badge>
        )}
      </button>

      {/* Host cannot be named, so its own name carries the status and the
          indicator is hidden. Badge is deliberately unused here. */}
      <span style={anchor}>
        <img src="/avatars/jane.jpg" alt="Jane Okonkwo, Online" />
        <span aria-hidden="true" style={dot} />
      </span>

      {/* Standalone, annotating nothing: ordinary text content, no role. */}
      <p>
        Nightfall Protocol
        <Badge>
          <span aria-hidden="true">[dot]</span> Live
        </Badge>
      </p>
    </>
  );
}
```

## Acceptance Checks
- Structure
  - Tab never lands on the badge.
  - The badge exposes no interactive role and no live-region role.
- Accessible naming
  - Reaching the host reports the badge's meaning as part of its accessible name.
  - The name states what the value represents rather than the number alone.
  - The text visible in the badge appears in the host control's accessible name, including a capped value such as "9+".
  - Changing the value changes the host's accessible name, and removing the badge removes its claim.
- Screen reader
  - Changing the badge's value announces nothing while focus is elsewhere.
  - A badge rendered only as a dot still reports what it means.
- Visual
  - The badge's meaning is perceivable in grayscale, per `global.use-of-color`.
  - With forced colors active, the badge remains distinguishable from its host, per `global.forced-colors`.
