---
id: toast.action
title: Toast with Action
stack: web/react
status: beta
latest_version: 0.2.0
tags: [toast, snackbar, notification, live-region, landmark, transient-message]
aliases: [snackbar, actionable toast, toast with action, undo toast, action toast, flag, actionable notification, snackbar with undo]
summary: Transient status message carrying exactly one action, announced through a text-only live region while the message itself is a named landmark, and used only when that action is also performable elsewhere in the interface.
---

# Toast with Action

Pattern ID: `toast.action`

Transient status message carrying exactly one action, announced through a text-only live region while the message itself is a named landmark, and used only when that action is also performable elsewhere in the interface.

This component is recommended only where no other pattern fits. Its barriers are inherent to the pattern rather than defects in any implementation: focus never moves to the message, and what keeps it from interrupting the user is what puts its action button out of reach. Screen reader users can navigate to it as a landmark; sighted keyboard-only users have no equivalent, are never told a shortcut exists, and may not reach the button before the timer dismisses it.

## Use When
- Use when a completed action needs a brief confirmation that also offers exactly one related action (e.g., "Nightfall Protocol removed from My List" with "Undo", "Added to your watchlist" with "View").
- Use when that action is also performable elsewhere in the interface, so the message can disappear on its own without stranding the user.

## Do Not Use When
- Do not use when the message is the only place the user can perform the action (use `banner.basic`).
- Do not use when the message carries no action beyond a dismiss control (use `toast.basic`).
- Do not use when the message carries more than one action, requires acknowledgment before the user continues, or blocks interaction with the page behind it (use `dialog.basic`).
- Do not use when the message is critical and the user is expected to respond to it rather than merely be informed of it (use `dialog.alert`).
- Do not use when the message reports a page-level or ongoing condition rather than the outcome of an action the user just took (use `banner.basic`).

## Must Haves

- The action this message offers is also performable elsewhere in the interface.

### Roles & structure
- Render the message and its controls inside an element carrying `role="region"`, so the message is itself a landmark.
- Render the announcing element as a separate element from the message, holding text only, and keep it in the DOM before the first message appears.
- The message carries exactly one action control alongside its dismiss control.
- Use a native `<button>` (preferred) for the action control and the dismiss control, or `role="button"` only when a native button cannot be used.
  - If `role="button"` is used instead of a native `<button>`, add `tabindex="0"` and keyboard support for Enter and Space, ensuring Space prevents page scrolling while activating the control.

### Accessible name
- Give the landmark a brief label describing what it holds (e.g., "Notifications"), referencing a visible label with `aria-labelledby` when one is present and using `aria-label` otherwise.
- The action control's visible text names the action rather than its outcome (e.g., "Undo", "View", "Retry"), and serves as its accessible name.
- The dismiss control has an accessible name that describes its purpose or action. For an icon-only dismiss control, provide the name using `aria-label` or `aria-labelledby`.
- Icons within the message controls are decorative (`aria-hidden="true"`).

### State & properties
- The announcing element uses `role="status"`.
- The announced text states the message, the action's label in the same words as the control, and the landmark's name as the route to it (e.g., "Nightfall Protocol removed from My List. Undo available in Notifications.").
- The announced text is cleared once the message has left the screen.
- The surface the message is drawn on is distinguishable from the content behind it by a contrast ratio of at least 3:1, per `global.non-text-contrast`.

### Keyboard
- Tab reaches the action control and then the dismiss control while the message is on screen.

### Focus
- Focus stays on the control that triggered the message when the message appears.
- Activating the action control or the dismiss control returns focus to the element that held focus when the message appeared.
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around the action control and the dismiss control, per `global.focus-states`.

### Motion & timing
- The message dismisses itself after a timed delay.
- The dismiss timer pauses while the pointer is over the message and while focus is inside it, and resumes from its remaining time when the pointer leaves and focus moves out.

### Dismissal
- Activating the action control dismisses the message.
- Esc dismisses the message when focus is inside it.

## Don'ts
- Do not give the message `role="alert"`, `role="status"`, `role="alertdialog"`, or `aria-live`, and do not place the action control inside the announcing element. Interactive content in a live region is announced as flat text, so the button is spoken as part of the message with nothing marking it activatable.
- Do not expose more than one landmark for messages. When several stack, the container carries the role and the messages do not, or the rotor's landmark list fills with duplicates of one name.
- Do not rely on Tab order alone as the route to the action. The message is commonly mounted at the end of the document, which places the action after every other control on the page.
- Do not mount or unmount the announcing element along with the message. A live region that is not in the DOM before its text changes does not announce reliably.
- Do not announce the message text alone when an action is present. An action the user is never told about is unreachable in practice.
- Do not restart a paused timer from its full duration when the pointer leaves. A user who reads a message slowly is then given less time than one who never looked at it.

## Customizable
- Whether more than one message can be on screen at once. One message is the default, and it carries `role="region"` itself. When several can stack, move the role to a single container that wraps them all, give that container the accessible name, and drop the per-message role, so the page still exposes one landmark rather than one per message. Each message keeps its own timer and its own single action. Pausing the whole container is the simpler default, since it keeps a stacked message from expiring while the user reads the one above it.
- The keyboard route to the action. Screen reader users reach a named landmark through landmark navigation with no additional code. Sighted keyboard users have no equivalent, so binding F6 to move focus to the action control and Shift+F6 to move back is recommended, and is the binding React Aria and Adobe Spectrum both ship. F6 supplements the landmark rather than replacing it, and it is not discoverable on its own, which is why the action's availability elsewhere carries the accessibility weight rather than the key binding.
- The announcing element. `role="status"` is the default. A plain element carrying `aria-live="polite"` and `aria-atomic="true"` is equivalent, since those are the implicit values of `role="status"`.
- Where the announcing element lives. A visually hidden element separate from the message, and the message's own text when the action control is a sibling of that text rather than a descendant of it, are equally acceptable. Both keep interactive content out of the live region.
- The dismiss delay. Systems that set one converge between 5 and 10 seconds: Adobe Spectrum enforces a 5 second floor, Microsoft Fluent uses 7 seconds, and Nord and Elastic EUI default to 10. Shopify Polaris sets 10 seconds specifically for a message carrying an action. 10 seconds is a reasonable default for this pattern, and a shorter delay is at the engineer's discretion as long as the message can be read and the action reached.
- Visual placement (e.g., bottom-center, top-right), and the transition used to show and hide a message, subject to `global.motion`.

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

export function ActionToast({
  message,
  actionLabel,
  onAction,
  onClose,
  duration = 10000,
  label = "Notifications",
}) {
  const [paused, setPaused] = useState(false);
  const regionRef = useRef(null);
  const openerRef = useRef(null);
  const remainingRef = useRef(duration);

  useEffect(() => {
    // A new message gets a full clock, and the focused element is recorded so
    // focus can return to it. Recorded, not taken: focus never moves here.
    remainingRef.current = duration;
    if (message) openerRef.current = document.activeElement;
  }, [message, duration]);

  useEffect(() => {
    if (!message || paused) return undefined;
    const startedAt = Date.now();
    const handle = window.setTimeout(onClose, remainingRef.current);
    return () => {
      window.clearTimeout(handle);
      // Banking the elapsed time is what makes a pause resume rather than restart.
      remainingRef.current -= Date.now() - startedAt;
    };
  }, [message, paused, onClose]);

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

  function dismiss() {
    const opener = openerRef.current;
    onClose();
    // rAF defers the focus call until React has removed the message.
    requestAnimationFrame(() => opener?.focus());
  }

  return (
    <>
      {/* Text only, mounted before any message. A button inside a live region
          is announced as flat text, so this names the action rather than
          containing it. */}
      <div role="status" style={srOnly}>
        {message ? `${message} ${actionLabel} available in ${label}.` : ""}
      </div>

      {message ? (
        // The message is the landmark. A wrapper is added only when several
        // messages can stack, and then the role moves to the wrapper.
        <div
          ref={regionRef}
          role="region"
          aria-label={label}
          onMouseEnter={() => setPaused(true)}
          onMouseLeave={() => setPaused(false)}
          onFocus={() => setPaused(true)}
          onBlur={() => setPaused(false)}
          onKeyDown={(event) => {
            if (event.key === "Escape") dismiss();
          }}
        >
          <span>{message}</span>
          <button
            type="button"
            onClick={() => {
              onAction();
              dismiss();
            }}
          >
            {actionLabel}
          </button>
          <button type="button" onClick={dismiss}>
            Dismiss
          </button>
        </div>
      ) : null}
    </>
  );
}
```
