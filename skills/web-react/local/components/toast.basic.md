---
id: toast.basic
title: Toast
stack: web/react
status: beta
latest_version: 0.3.0
tags: [toast, notification, status, live-region, transient-message]
aliases: [notification, toast, transient message, status message, status toast, confirmation message, auto-dismiss message]
summary: Temporary, non-blocking status message carrying no action beyond an optional dismiss control, announced through a text-only live region and disappearing on its own.
---

# Toast

Pattern ID: `toast.basic`

Temporary, non-blocking status message carrying no action beyond an optional dismiss control, announced through a text-only live region and disappearing on its own.

The dismiss control is a convenience rather than a route the user depends on, because the message removes itself either way. That is what separates this pattern from `toast.action`, where the control does something the timer cannot do for the user.

## Use When
- Use when a completed action needs a brief confirmation the user does not have to act on (e.g., "Saved", "Added to your watchlist").
- Use when a background event is worth reporting without interrupting what the user is doing (e.g., "Sync complete", "3 new episodes available").

## Do Not Use When
- Do not use when the message offers an action the user can take, such as Undo, Retry, or View (use `toast.action`).
- Do not use when the message requires acknowledgment before the user continues, or blocks interaction with the page behind it (use `dialog.basic`).
- Do not use when the message is critical and the user is expected to respond to it rather than merely be informed of it (use `dialog.alert`).
- Do not use when the message reports a page-level or persistent condition rather than the outcome of an action the user just took (use `banner.basic`).

## Must Haves

### Roles & structure
- Render the announcing element into the DOM before the first message appears, and keep it mounted whether or not a message is showing.
- The announcing element holds text only.
- Render the dismiss control, when one exists, as a sibling of the announcing element rather than inside it.
- Use a native `<button>` for the dismiss control.

### Accessible name
- The dismiss control has an accessible name that describes its purpose or action. For an icon-only dismiss control, provide the name using `aria-label` or `aria-labelledby`.
- Icons within the message are decorative (`aria-hidden="true"`).

### State & properties
- The announcing element uses `role="status"`.
- The announced text is cleared once the message has left the screen.
- The surface the message is drawn on is distinguishable from the content behind it by a contrast ratio of at least 3:1, per `global.non-text-contrast`.

### Focus
- Focus stays on the control that triggered the message when the message appears.
- Activating the dismiss control returns focus to the element that held focus when the message appeared.
- When a dismiss control is rendered, ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around it, per `global.focus-states`.

### Motion & timing
- The message dismisses itself after a timed delay.

## Don'ts
- Do not move focus to the message, which interrupts a user mid-task to deliver something they were not required to act on.
- Do not place the dismiss control inside the element carrying `role="status"` or `aria-live`. Interactive content in a live region is announced as flat text, so the control is spoken as part of the message with nothing marking it activatable.
- Do not mount or unmount the announcing element along with the message. A live region that is not in the DOM before its text changes does not announce reliably.
- Do not use `role="alert"` or `role="alertdialog"` for a message the user does not have to act on. Both interrupt the user's current task, and `alertdialog` additionally implies a dialog that must be dismissed before continuing.
- Do not leave announced text in the live region after the message has left the screen. A stale message stays discoverable to a user browsing the page later.

## Customizable
- Whether a dismiss control is rendered at all. The message removes itself either way, so the control is a convenience rather than the only route out.
- The dismiss delay. ~5 seconds is the common default for a message carrying nothing to act on, and the exact value is at the engineer's discretion as long as the message can be read.
- Which element announces. A visually hidden element separate from the visible message, and the visible message text itself, are equally acceptable, as long as the dismiss control is a sibling of the announcing element rather than a descendant of it.
- Whether a newer message replaces the current one or queues behind it, as long as each message is announced once and the live region is cleared when the last one leaves.
- Visual placement (e.g., top-right, bottom-center), and the transition used to show and hide a message, subject to `global.motion`.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

export function Toast({ message, onDismiss, dismissible = false, duration = 5000 }) {
  const openerRef = useRef(null);

  useEffect(() => {
    if (!message) {
      openerRef.current = null;
      return undefined;
    }
    // Recorded, not taken: focus returns here only if the user dismisses by hand.
    openerRef.current = document.activeElement;
    const handle = window.setTimeout(onDismiss, duration);
    return () => window.clearTimeout(handle);
  }, [message, duration, onDismiss]);

  function dismiss() {
    const opener = openerRef.current;
    onDismiss();
    // rAF defers the focus call until React has removed the message.
    requestAnimationFrame(() => opener?.focus());
  }

  return (
    <div>
      {/* The visible text is itself the live region, mounted before any message
          so that injecting text into it is announced. */}
      <p role="status">{message ?? ""}</p>

      {/* Sibling, never a descendant: a button inside a live region is
          announced as flat text with nothing marking it activatable. */}
      {message && dismissible ? (
        <button type="button" onClick={dismiss}>
          Dismiss
        </button>
      ) : null}
    </div>
  );
}
```
