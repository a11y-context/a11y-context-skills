---
id: toast.action
title: Toast with Action
stack: web/react
status: beta
latest_version: 0.1.0
tags: [toast, snackbar, notification, live-region, landmark, transient-message]
aliases: [snackbar, actionable toast, toast with action, undo toast, action toast, flag, actionable notification, snackbar with undo]
summary: Transient status message carrying exactly one action, announced through a text-only live region while the visible message and its controls sit in a separately mounted landmark region, and dismissing itself only when that action is also reachable elsewhere in the interface.
---

# Toast with Action

Pattern ID: `toast.action`

Transient status message carrying exactly one action, announced through a text-only live region while the visible message and its controls sit in a separately mounted landmark region, and dismissing itself only when that action is also reachable elsewhere in the interface.

Whether the message dismisses itself is decided by where the action lives, not by the design. An action the user can also perform somewhere else permits a timed dismissal. An action that exists only in this message does not, and the message stays until the user acts.

## Use When
- Use when a completed action needs a brief confirmation that also offers exactly one related action (e.g., "Nightfall Protocol removed from My List" with "Undo", "Added to your watchlist" with "View").
- Use when that single action must stay available until the user takes it, without interrupting what they are doing.

## Do Not Use When
- Do not use when the message carries no action beyond a dismiss control (use `toast.basic`).
- Do not use when the message carries more than one action, requires acknowledgment before the user continues, or blocks interaction with the page behind it (use `dialog.basic`).
- Do not use when the message is urgent and must interrupt the user immediately (use `dialog.alert`).
- Do not use when the message reports a page-level or persistent condition rather than the outcome of an action the user just took (use `banner.basic`).

## Must Haves

### Roles & structure
- Render the visible messages and their controls inside a container with `role="region"` that is present in the DOM before the first message appears.
- One region holds every message on screen, so the page exposes a single such landmark however many messages are showing.
  - `role="region"` is exposed as a landmark only when the container carries an accessible name.
- Render the announcing element as a separate element from that region, holding text only.
- Each message carries exactly one action control alongside its dismiss control.
- Use a native `<button>` (preferred) for the action control, or `role="button"` only when a native button cannot be used.
  - If `role="button"` is used instead of a native `<button>`, add `tabindex="0"` and keyboard support for Enter and Space, ensuring Space prevents page scrolling while activating the control.
- Use a native `<button>` for the dismiss control.

### Accessible name
- Give the region a brief label describing what it holds (e.g., "Notifications"), referencing a visible label with `aria-labelledby` when one is present and using `aria-label` otherwise.
- The action control's visible text names the action rather than its outcome (e.g., "Undo", "View", "Retry"), and serves as its accessible name.
- The dismiss control has an accessible name that describes its purpose or action. For an icon-only dismiss control, provide the name using `aria-label` or `aria-labelledby`.
- Icons within the message controls are decorative (`aria-hidden="true"`).

### State & properties
- The announcing element uses `role="status"`, and is present in the DOM before the first message is announced.
- The announced text states the message, the action's label in the same words as the control, and the region's name as the route to it (e.g., "Nightfall Protocol removed from My List. Undo available in Notifications.").
- The announced text is cleared once the message has left the screen.

### Keyboard
- Tab reaches each message's action control and then its dismiss control while the message is on screen.

### Focus
- Focus stays on the control that triggered the message when the message appears.
- Activating a message's action control or dismiss control returns focus to the element that held focus when the messages appeared.
  - When another message is still on screen, focus moves to that message's action control instead.
- Move focus to a stable element before removing a message that holds focus, per `global.motion`.
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around each action control and dismiss control, per `global.focus-states`.

### Motion & timing
- When a message's action is also reachable elsewhere in the interface, that message dismisses itself after a timed delay.
- When a message carries the only route to its action, that message stays on screen until the user activates the action or dismisses it.
- The dismiss delay is long enough for the user to read the message and reach the action.
- Dismiss timers pause while the pointer is over the region and while focus is inside it, and resume from their remaining time when the pointer leaves and focus moves out.
- A message leaves the accessibility tree when it stops being available to the user rather than when its exit animation finishes, per `global.motion`.

### Dismissal
- Activating a message's action control dismisses that message.
- Esc dismisses the message holding focus when focus is inside the region.

## Customizable
- The keyboard route into the region. Screen reader users reach a named landmark through landmark navigation with no additional code. Sighted keyboard users have no equivalent, so binding F6 to move focus into the region and Shift+F6 to move back is recommended, and is the binding React Aria and Adobe Spectrum both ship. F6 supplements the landmark rather than replacing it, and it is not discoverable on its own, which is why the action's availability elsewhere carries the accessibility weight rather than the key binding.
- The announcing element. `role="status"` is the default. A plain element carrying `aria-live="polite"` and `aria-atomic="true"` is equivalent, since those are the implicit values of `role="status"`.
- Where the announcing element lives. A visually hidden element separate from the visible messages, and a visible message's own text when the action control is a sibling of that text rather than a descendant of it, are equally acceptable. Both keep interactive content out of the live region.
- The dismiss delay. Systems that set one converge between 5 and 10 seconds: Adobe Spectrum enforces a 5 second floor, Microsoft Fluent uses 7 seconds, and Nord and Elastic EUI default to 10. Shopify Polaris sets 10 seconds specifically for a message carrying an action. 10 seconds is a reasonable default for this pattern, and a shorter delay is at the engineer's discretion as long as the message can be read and the action reached.
- Whether more than one message is on screen at a time. A queue that shows one at a time and a stack that shows several are both acceptable, as long as each message keeps its own timer and its own single action.
- Whether pausing applies to every message at once or only to the message under the pointer. Pausing the whole region is the simpler default, and it keeps a stacked message from expiring while the user reads the one above it.
- Visual placement of the region (e.g., bottom-center, top-right), and the transition used to show and hide a message, subject to `global.motion`.

## Don'ts
- Do not give the container holding the visible messages `role="alert"`, `role="status"`, `role="alertdialog"`, or `aria-live`, and do not place an action control inside the announcing element. Interactive content in a live region is announced as flat text, so the button is spoken as part of the message with nothing marking it activatable.
- Do not give each message its own `role="region"`. A landmark per message fills the rotor's landmark list with duplicates of one name.
- Do not rely on Tab order alone as the route to the action. The region is commonly mounted at the end of the document, which places the action after every other control on the page.
- Do not mount or unmount the announcing element along with the messages. A live region that is not in the DOM before its text changes does not announce reliably.
- Do not announce the message text alone when an action is present. An action the user is never told about is unreachable in practice.
- Do not restart a paused timer from its full duration when the pointer leaves. A user who reads a message slowly is then given less time than one who never looked at it.

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

export function ActionToast({ toasts, onClose, regionLabel = "Notifications" }) {
  const [paused, setPaused] = useState(false);
  const regionRef = useRef(null);
  const openerRef = useRef(null);
  const clocksRef = useRef(new Map());
  const latest = toasts[toasts.length - 1];

  useEffect(() => {
    // Recorded, not taken: focus returns here once the region empties.
    if (toasts.length > 0 && !openerRef.current) openerRef.current = document.activeElement;
    if (toasts.length === 0) openerRef.current = null;
  }, [toasts.length]);

  useEffect(() => {
    const clocks = clocksRef.current;
    const live = new Set(toasts.map((toast) => toast.id));
    clocks.forEach((_, id) => {
      if (!live.has(id)) clocks.delete(id);
    });
    if (paused) return undefined;

    toasts.forEach((toast) => {
      // A timer runs only for a message whose action outlives it.
      if (!toast.actionElsewhere) return;
      const clock = clocks.get(toast.id) ?? { remaining: toast.duration ?? 10000 };
      clock.startedAt = Date.now();
      clock.handle = window.setTimeout(() => onClose(toast.id), clock.remaining);
      clocks.set(toast.id, clock);
    });

    return () => {
      clocks.forEach((clock) => {
        window.clearTimeout(clock.handle);
        // Banking the elapsed time is what makes a pause resume rather than restart.
        clock.remaining -= Date.now() - clock.startedAt;
      });
    };
  }, [toasts, paused, onClose]);

  useEffect(() => {
    function onKeyDown(event) {
      if (event.key !== "F6") return;
      const target = regionRef.current?.querySelector("button");
      if (!target) return;
      event.preventDefault();
      target.focus();
    }
    document.addEventListener("keydown", onKeyDown);
    return () => document.removeEventListener("keydown", onKeyDown);
  }, []);

  function dismiss(id) {
    const wasLast = toasts.length === 1;
    const opener = openerRef.current;
    onClose(id);
    // rAF defers the focus call until React has removed the message.
    requestAnimationFrame(() => {
      if (wasLast) opener?.focus();
      else regionRef.current?.querySelector("button")?.focus();
    });
  }

  return (
    <>
      {/* Text only. A button inside a live region is announced as flat text,
          so the announcement names the action instead of containing it. */}
      <div role="status" style={srOnly}>
        {latest ? `${latest.message} ${latest.actionLabel} available in ${regionLabel}.` : ""}
      </div>

      {/* One landmark for every message, mounted whether or not any are showing. */}
      <div
        ref={regionRef}
        role="region"
        aria-label={regionLabel}
        onMouseEnter={() => setPaused(true)}
        onMouseLeave={() => setPaused(false)}
        onFocus={() => setPaused(true)}
        onBlur={() => setPaused(false)}
      >
        {toasts.map((toast) => (
          <div
            key={toast.id}
            onKeyDown={(event) => {
              if (event.key === "Escape") dismiss(toast.id);
            }}
          >
            <span>{toast.message}</span>
            <button
              type="button"
              onClick={() => {
                toast.onAction();
                dismiss(toast.id);
              }}
            >
              {toast.actionLabel}
            </button>
            <button type="button" onClick={() => dismiss(toast.id)}>
              Dismiss
            </button>
          </div>
        ))}
      </div>
    </>
  );
}
```

## Acceptance Checks

- Structure
  - The region is in the DOM before any message appears, not mounted alongside one.
  - Two messages on screen at once produce one landmark, not two.
  - The element carrying `role="status"` contains no buttons or links.
  - Each message carries one action control and one dismiss control, and no more.
- Keyboard
  - Triggering a message leaves focus on the control that triggered it.
  - Tab reaches a message's action control and then its dismiss control.
  - With the F6 binding implemented, F6 moves focus into the region from anywhere on the page, and Shift+F6 moves back.
  - Esc dismisses the message holding focus when focus is inside the region.
  - Activating the action or the dismiss control returns focus to the control that triggered the message, or to the next message's action control when one remains.
- Screen reader
  - The message is announced once, politely, without focus moving.
  - The announcement carries the action's label and the region's name, not the message text alone.
  - Landmark navigation lists the region under the name given to it, once, however many messages are showing.
  - After the message leaves the screen, the announced text is no longer discoverable.
- Timing
  - A message whose action is reachable elsewhere dismisses itself after its delay.
  - A message carrying the only route to its action stays until the user activates the action or dismisses it.
  - Hovering the pointer over the region stops the timers, and moving it away resumes them.
  - Moving focus into the region stops the timers, and moving focus out resumes them.
  - A message hovered partway through its delay expires at its remaining time, not at a fresh full delay.
- Visual
  - Each action control and dismiss control shows a visible focus state, per `global.focus-states`.
  - With forced colors active, the messages and their controls remain visible, per `global.forced-colors`.
