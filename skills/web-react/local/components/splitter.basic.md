---
id: splitter.basic
title: Splitter
stack: web/react
status: beta
latest_version: 0.1.0
tags: [splitter, resizable-panes, window-splitter, drag-alternative, keyboard]
aliases: [split panel, split pane, split view, window splitter, splitter bar, resizable panes, pane divider, resize handle, drag handle, gutter, sash]
summary: Moveable divider between two panes that changes their relative size, using a focusable role="separator" with aria-valuenow, aria-controls, and arrow-key movement.
---

# Splitter

Pattern ID: `splitter.basic`

Moveable divider between two panes that changes their relative size, using a focusable `role="separator"` with `aria-valuenow`, `aria-controls`, and arrow-key movement.

This is the interactive component that shares the `separator` role with the static line, and the two are not variants of each other. A separator that is not focusable is a structural boundary with no value and no keyboard behavior, covered by `separator.basic`. A separator that is focusable is a widget: the user moves it, it reports a position, and it has to work from the keyboard. Only the second one is this pattern.

## Use When
- Use when a moveable divider lets the user change the relative size of two adjacent panes (e.g., an episode list beside an episode detail view, or a player beside a live chat panel).
- Use when a divider moves between a small set of layout positions rather than any value in a range (e.g., a three-stop divider for left pane only, both panes, and right pane only).

## Do Not Use When
- Do not use when the divider is a static line the user cannot move, which is the common case for anything a design system calls a separator or divider (use `separator.basic`).
- Do not use when the divider has only two positions, expanded and collapsed, which is a show/hide control rather than a position with a value (use `disclosure.basic` for the toggle, and `separator.basic` for the line beside it).
- Do not use when the control sets a value in the content rather than a layout size, such as a volume level, a playback position, or a price filter (use `slider.basic`).
- Do not use when the two regions are resized by a control that is not positioned between them, such as a button in a toolbar that expands a panel (use `disclosure.basic`).

## Must Haves

### Roles & structure
- The element the user moves has `role="separator"` and sits between the two panes it divides.
- One pane is designated the primary pane, and the splitter's value describes that pane's size. The other pane takes the remaining space.
- A splitter that divides a left pane from a right pane has `aria-orientation="vertical"`. A splitter that divides a top pane from a bottom pane omits the attribute, because `horizontal` is the implicit value for this role.
- When a pane is collapsed, its content is removed from the accessibility tree and the keyboard tab sequence (e.g., via the `hidden` attribute), so that content the user cannot see cannot be reached.

### Accessible name
- The splitter has an accessible name describing the pane it sizes, set with `aria-label` on the splitter itself. The name lives on the splitter rather than being borrowed from the pane, because the pane leaves the accessibility tree when it collapses.

### State & properties
- `aria-valuenow` is a number representing the current position of the splitter, expressed as the size of the primary pane, and it is updated every time the splitter moves.
- `aria-valuemin` is set when the minimum is not 0, and `aria-valuemax` is set when the maximum is not 100. Both are omitted when the implicit values apply.
- `aria-controls` references the `id` of the primary pane.

### Keyboard
- The arrow keys move the splitter along its axis: Left and Right when it divides left and right panes, Up and Down when it divides top and bottom panes. Each press moves it one step, and holding the key repeats. Where the splitter has a set number of positions, each press moves to the next one.
- Arrow-key movement stops at the minimum and maximum rather than wrapping around to the opposite end.
- Enter collapses the primary pane when it is not collapsed, and restores the splitter to the position it held before collapsing when it is. Arrow keys cannot substitute for this, because they have no memory of the previous position.

### Focus
- The splitter is in the page tab sequence with `tabindex="0"`.
- The step buttons and the splitter follow their visual order in the DOM, leading button first, so the tab order matches the screen even where the controls are placed by layout.
- Focus stays on the splitter while it moves. Moving or collapsing the splitter does not send focus into either pane.
- When a step button is removed because the splitter reached the end of its range, focus moves to the remaining step button before the removal.
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around the splitter and around each step button.

### Pointer & touch
- The splitter is flanked by a step button for each direction it can currently move: a native `<button>` that moves the splitter one step that way when pressed, the same distance an arrow key moves it.
- The splitter's step buttons are the single-pointer alternative to dragging that this pattern requires. Every position the splitter can reach is reachable by pressing them.
  - Keyboard support does not satisfy this. A head pointer, eye-gaze system, trackball, or speech-driven mouse operates a pointer but cannot drag.
  - Double-clicking the splitter does not satisfy it either where the splitter has a range, since that reaches two positions and dragging reaches all of them.
- A step button is visible whenever the splitter can move in its direction. Only at the end of the range, where it has nothing left to do, is it removed or disabled.
- The splitter's pointer target measures at least 24 by 24 CSS pixels, counting the visible line plus the padding around it. The painted line itself may be thinner.

## Customizable
- Continuous or stepped positions. A splitter may move to any value in its range, or to a set number of stops (e.g., left pane only, both panes, right pane only). The keyboard model is the same either way; only the size of a step changes.
- Whether a step button that cannot act at the current position is removed or is marked `aria-disabled="true"` and left in place. Removing it keeps the controls honest about what is available and requires the focus move above; leaving it in place holds the layout steady and needs no focus handling.
- `aria-labelledby` referencing the primary pane's visible heading, instead of `aria-label`. Name computation does include a directly referenced element even when that element is hidden, so this survives the pane being hidden, but it breaks when the pane is unmounted rather than hidden. `aria-label` is the safer default.
- Where the step buttons sit. Beside the splitter, or in the header of the pane they size, as long as they are visible and their relationship to the splitter is obvious. They are siblings of the splitter rather than children, because the `separator` role has presentational children and a button placed inside it would not be announced.
- The visual weight of the step buttons. They may be small and understated, as long as they stay perceivable and meet the contrast requirement in `global.non-text-contrast`.
- Whether double-clicking the splitter collapses and restores it, alongside the step buttons.
- Home and End. Moving the splitter to its minimum with Home and its maximum with End is recommended and is at the engineer's discretion.
- F6 to cycle focus through the panes is recommended in layouts with several panes, where reaching a pane by Tab alone is slow.
- The arrow-key step size is at the engineer's discretion, as long as the full range is reachable in a reasonable number of presses.
- The value scale. The 0 to 100 percentage scale carries no units and needs no extra attributes. A scale in pixels or another unit is acceptable, in which case set `aria-valuemin` and `aria-valuemax` to match and add `aria-valuetext` so the announced value carries its unit (e.g., "320 pixels").
- Whether the collapsed state is also reachable from a separate control, such as a panel header button, in addition to Enter on the splitter.

## Don'ts
- Do not build the splitter as a plain `<div>` with pointer handlers only. Without `tabindex="0"`, `role="separator"`, and the arrow keys it cannot be operated by keyboard at all.
- Do not omit `aria-valuenow`, and do not let it go stale while the splitter moves. It is the only thing reporting the splitter's position.
- Do not put the splitter's accessible name in text inside it, which is not announced because the role has presentational children.
- Do not let a step button disappear while it holds focus without moving focus first. Focus falls to the document body and the user loses their place in the page (see `global.motion`).
- Do not reveal the step buttons only on hover or focus. Touch input has no hover, which puts them out of reach of the pointer users this requirement exists to serve, and a control that is absent from the DOM until hover is outside the tab order as well.
- Do not size the panes as a share of the whole container and add the splitter and its controls on top. The total then exceeds the container, and a control pushed past a clipped edge is focusable while invisible, which is the stranded-focusable failure in `global.sr-only`. Size the panes against the space that remains after the gutter.
- Do not assume a screen reader user can drive the splitter the way their screen reader offers to. VoiceOver maps a focusable separator to the native macOS splitter and offers to move it with VO plus the arrow keys, but WebKit does not deliver those key presses to the page, so the interaction it advertises does nothing. The plain arrow keys work, and are what the user falls back to.
- Do not try to correct that announcement with `aria-describedby`. A description is announced in addition to the screen reader's own interaction hint, not instead of it, so the user receives the working instruction and the broken one together.
- Do not detect double-click with a hand-rolled timer. The native `dblclick` event uses the interval the user set in their operating system, while an author-written threshold is a time limit the content imposes and the user cannot adjust.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

const MIN = 0;
const MAX = 100;
const STEP = 5;
const INITIAL = 32;

export function SplitterDemo() {
  const [size, setSize] = useState(INITIAL);
  const [restoreTo, setRestoreTo] = useState(INITIAL);
  const [dragging, setDragging] = useState(false);
  const containerRef = useRef(null);
  const narrowRef = useRef(null);
  const widenRef = useRef(null);

  const collapsed = size === MIN;
  const atMin = size === MIN;
  const atMax = size === MAX;

  // Panes divide what is left after the gutter, so nothing overflows the edge.
  const gutter = 24 + (atMin ? 0 : 24) + (atMax ? 0 : 24);

  function moveTo(next) {
    const clamped = Math.min(MAX, Math.max(MIN, Math.round(next)));
    // Hand focus to the survivor before this button unmounts.
    if (clamped === MIN && document.activeElement === narrowRef.current) {
      widenRef.current?.focus();
    } else if (clamped === MAX && document.activeElement === widenRef.current) {
      narrowRef.current?.focus();
    }
    setSize(clamped);
    // Remember the last open position so Enter can restore it.
    if (clamped !== MIN) setRestoreTo(clamped);
  }

  function toggleCollapse() {
    setSize(collapsed ? restoreTo : MIN);
  }

  function onKeyDown(event) {
    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault();
        moveTo(size - STEP);
        break;
      case "ArrowRight":
        event.preventDefault();
        moveTo(size + STEP);
        break;
      case "Home":
        event.preventDefault();
        moveTo(MIN);
        break;
      case "End":
        event.preventDefault();
        moveTo(MAX);
        break;
      case "Enter":
        event.preventDefault();
        toggleCollapse();
        break;
      default:
        break;
    }
  }

  return (
    <div ref={containerRef} style={{ display: "flex", height: 320 }}>
      <div
        id="episode-pane"
        // Collapsed content leaves the accessibility tree and the tab order.
        hidden={collapsed}
        style={{
          flexBasis: `calc((100% - ${gutter}px) * ${size / 100})`,
          flexGrow: 0,
          flexShrink: 0,
          overflow: "hidden",
        }}
      >
        <ul>
          {EPISODES.map((episode) => (
            <li key={episode}>{episode}</li>
          ))}
        </ul>
      </div>

      {/* Required, not chrome: the no-drag pointer route (WCAG 2.5.7).
          Siblings, in visual order, since DOM order is the tab order. */}
      <div style={{ flex: `0 0 ${gutter}px`, display: "flex", alignItems: "stretch" }}>
        {!atMin && (
          <button
            type="button"
            ref={narrowRef}
            aria-label="Narrow episode list"
            onClick={() => moveTo(size - STEP)}
            style={{ flex: "0 0 24px", height: 24, alignSelf: "flex-end" }}
          >
            <span aria-hidden="true">[chevron-left]</span>
          </button>
        )}

        <div
          role="separator"
          tabIndex={0}
          aria-orientation="vertical"
          aria-label="Episode list"
          aria-controls="episode-pane"
          aria-valuenow={size}
          // valuemin/valuemax omitted: 0 and 100 are the implicit values.
          onKeyDown={onKeyDown}
          onDoubleClick={toggleCollapse}
          onPointerDown={(event) => {
            event.currentTarget.setPointerCapture(event.pointerId);
            setDragging(true);
          }}
          onPointerMove={(event) => {
            if (!dragging) return;
            const bounds = containerRef.current.getBoundingClientRect();
            moveTo(((event.clientX - bounds.left) / bounds.width) * 100);
          }}
          onPointerUp={(event) => {
            event.currentTarget.releasePointerCapture(event.pointerId);
            setDragging(false);
          }}
          style={{
            // 24px pointer target around a 2px visible line (WCAG 2.5.8).
            flex: "0 0 24px",
            display: "flex",
            justifyContent: "center",
            cursor: "col-resize",
            touchAction: "none",
          }}
        >
          {/* Presentational children: this is never announced. */}
          <span style={{ width: 2, background: "currentColor" }} />
        </div>

        {!atMax && (
          <button
            type="button"
            ref={widenRef}
            aria-label="Widen episode list"
            onClick={() => moveTo(size + STEP)}
            style={{ flex: "0 0 24px", height: 24, alignSelf: "flex-end" }}
          >
            <span aria-hidden="true">[chevron-right]</span>
          </button>
        )}
      </div>

      <div style={{ flex: 1, overflow: "hidden" }}>
        <h2>Signal Lost</h2>
        <p>Season 2, Episode 4</p>
      </div>
    </div>
  );
}

const EPISODES = [
  "1. Cold Open",
  "2. Dead Air",
  "3. The Quiet Hours",
  "4. Signal Lost",
  "5. Last Transmission",
];
```

## Acceptance Checks

Keyboard
- Tab moves focus to the splitter, and the splitter shows a visible focus indicator.
- Tab reaches the step buttons and the splitter in the order they appear on screen, leading button first.
- Arrow keys move the splitter along its axis, and the panes resize as it moves.
- On a splitter with a set number of positions, each arrow press lands on the next position rather than moving by a smaller amount.
- Arrow keys stop the splitter at its minimum and maximum instead of wrapping to the opposite end.
- Enter collapses the primary pane, and Enter again restores it to the position it held before collapsing.
- Focus remains on the splitter after every move and after collapsing or restoring.
- Driving the splitter to either end from its own step button leaves focus on a visible button, never on the document body.
- While a pane is collapsed, Tab never lands on anything inside it.

Pointer
- A button sits on each side of the splitter, visible without hovering over or focusing anything, and pressing one moves the splitter one step in that direction.
- Every position the splitter can reach is reachable by pressing those buttons, without ever dragging.
- The splitter's clickable area is at least 24 by 24 CSS pixels even where the visible line is thinner, and each step button meets the same size.

Screen Reader
- The splitter is announced with a role and a name describing the pane it sizes. The role name varies by platform: VoiceOver maps it to the native splitter and says "vertical splitter" or "splitter" rather than "separator".
- A splitter carrying `aria-orientation="vertical"` is announced as vertical, confirming the attribute reached the accessibility tree.
- The announced value changes as the splitter moves.
- Any glyph drawn inside the splitter is not announced.
- Content inside a collapsed pane is absent from the reading order.
- With a screen reader running, the panes can still be resized or collapsed without relying on the screen reader's own splitter interaction. Verify this in VoiceOver, where that interaction is offered and does not work.
