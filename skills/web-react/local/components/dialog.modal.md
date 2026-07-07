---
id: dialog.modal
title: "Dialog (Modal)"
stack: web/react
status: beta
latest_version: 0.3.0
tags: [dialog, modal, pop-up, overlay, focus-trap, blocking, native-dialog, show-modal]
aliases: [dialog, modal, pop-up]
summary: User-initiated blocking dialog. Uses the native <dialog> element with .showModal() so the browser handles focus trap, background inertness, Escape dismissal, focus restoration, and top-layer rendering.
---

# Dialog (Modal)

Pattern ID: `dialog.modal`

User-initiated blocking dialog. Uses the native `<dialog>` element with `.showModal()` so the browser handles focus trap, background inertness, Escape dismissal, focus restoration, and top-layer rendering. When the native element cannot be used, a manual `<div role="dialog">` fallback is documented under Customizable with the full behavior contract that must be implemented by hand.

## Use When
- Use when content appears in an overlay that blocks interaction with the underlying page.
- Use when keyboard focus must move into the dialog and remain contained until dismissal.
- Use when the user must explicitly complete or dismiss the dialog before returning to the main interface.

## Do Not Use When
- Do not use when the content is part of the normal page flow and does not block background interaction.
- Do not use when presenting brief, non-blocking status messages that do not require focus movement (use `toast` or `snackbar`).
- Do not use when the message is urgent and requires immediate acknowledgment (use `dialog.alert`).
- Do not use when the interaction involves complex, multi-step workflows spanning multiple screens.

## Must Haves
- Use the native `<dialog>` element (preferred). When `<dialog>` cannot be used, `<div role="dialog">` is the documented fallback — see Customizable → Manual fallback.
- **Native `<dialog>` must be opened with `.showModal()`.** A `<dialog>` present in the DOM without this call is non-modal: no focus trap, no background inertness, no `aria-modal`, no top-layer rendering. Only `.showModal()` produces the modal contract this pattern requires.
- Dialog surface has an accessible name via `aria-labelledby` (preferred) or `aria-label`. If `aria-labelledby` is used, it references a visible title element (e.g., `<h2 id="...">`).
- If a description is rendered, it is referenced by `aria-describedby`. Do not rely on incidental reading order.
- Dialog width is fluid so content reflows at 400% zoom (WCAG 1.4.10 Reflow). Prefer `max-width: min(<Npx>, 100%)`; do not set fixed pixel widths that would exceed the 320-CSS-pixel viewport at 400% zoom.
- Provide a visible close control (`<button type="button">`) with an accessible name (e.g., `aria-label="Close dialog"`).
- The invoking control declares dialog-trigger semantics — apply `aria-haspopup="dialog"` to the trigger element.
- The dialog satisfies the following behavior contract (all six required):
  - Focus moves into the dialog on open.
  - Focus is trapped within the dialog while open.
  - Escape closes the dialog.
  - Focus returns to the invoking element on close.
  - Background content is not focusable or reachable by keyboard or screen readers while open.
  - Body scroll is prevented while open.
- Under native `<dialog>` + `.showModal()` (the Golden Pattern), these six behaviors are provided automatically by the browser. Under the manual `<div role="dialog">` fallback (Customizable → Manual fallback), each is the implementation's responsibility.
- Focus indicators on the dialog surface, close button, and any focusable content follow the [Foundations focus rule](/web/react/foundations#rule-focus-states).

## Customizable

### Native `<dialog>` preferred; manual `<div role="dialog">` fallback

Native `<dialog>` + `.showModal()` is the Golden Pattern. Switch to the manual `<div role="dialog">` fallback only when the implementation cannot use `<dialog>` — for example:
- A legacy browser target matrix that predates the stable-support cutoff (Safari 15.4 / Firefox 98 / Chromium 37).
- Portal-based architectures where the framework's portal target and the browser's top-layer produce conflicting stacking or event delegation.
- Custom stacking contexts (transformed or filtered ancestors) that break `<dialog>`'s top-layer contract in ways the design cannot accommodate.

The manual fallback's Must Haves — each implemented by hand:
- Dialog surface uses `<div role="dialog">` with `aria-modal="true"`.
- Dialog surface is focusable for entry (`tabIndex={-1}` or equivalent) and receives initial focus on open.
- Focus trap: capture and wrap Tab / Shift+Tab within the dialog's focusable descendants.
- Background isolation via `inert` on the application content root (not on `document.body` or `document.documentElement`) while open.
- Body scroll prevention: the browser-managed scroll lock does not apply, so an explicit strategy is required. `body { overflow: hidden }` is a common starting point; on iOS Safari this is insufficient because of momentum scrolling — the robust idiom is to save `window.scrollY`, set `body { position: fixed; top: -${scrollY}px; width: 100% }`, and restore on close.
- Escape closes the dialog (bound via a `keydown` listener).
- Focus restoration on close: capture the invoking element's DOM reference at open time and refocus it on close.
- Render via a portal to `document.body` (or an equivalent top-level container). Nesting the dialog inside the trigger's DOM position breaks `inert`-based isolation, collides with parent stacking contexts, and can inherit conflicting CSS.
- Backdrop is a non-semantic container (e.g., `<div role="presentation">`); the click-to-close contract below applies.

### Backdrop click contract

The default contract is that clicking the backdrop closes the dialog. For destructive or high-stakes confirmations (delete, unsaved-data warning, payment authorization), the dialog may opt out of backdrop dismissal so only Cancel / Confirm can dismiss it. When disabled, the backdrop remains visually present but does not trigger `onClose`.

Native `<dialog>` does not close on backdrop click by default. Add a target-check `onClick` handler on the `<dialog>` element itself — clicks that land on the dialog's padding area (not on a content descendant) target the `<dialog>` element and can be treated as backdrop clicks. See the Golden Pattern for the exact form.

### Initial focus target on open

Three acceptable defaults; the pattern permits any of them:
- **Focus the dialog surface** (`tabIndex={-1}` on the container) — user hears the accessible name announced, then Tabs to the first control. Least prescriptive.
- **Focus the safe-default control** — for destructive confirmations, focus Cancel or Close so an inadvertent Enter does not confirm the destructive action.
- **Focus the first interactive** — for form-shaped dialogs where the user's next action is to type or select.

Under native `<dialog>` + `.showModal()`, if no explicit focus is set, the browser focuses the first focusable descendant. To force one of the alternatives, add `autoFocus` (or set focus in an effect after `showModal()`) to the intended element.

### `<form method="dialog">` for form-shaped confirmations

Native `<dialog>` accepts a `<form method="dialog">` child. Submitting the form closes the dialog and passes the submit button's `value` as the dialog's `returnValue`, dispatched to the `close` event. Zero JS is required for dismiss:

```html
<dialog>
  <form method="dialog">
    <p>Delete this file?</p>
    <button value="cancel">Cancel</button>
    <button value="confirm">Confirm</button>
  </form>
</dialog>
```

Read `dialog.returnValue` in the `close` event handler to distinguish outcomes. Useful for simple confirmations; not required.

## Don'ts
- Do not render `<dialog>` without calling `.showModal()` and expect modal behavior. A bare `<dialog>` produces a non-modal reveal with none of the modal contract.
- Do not implement the manual `<div role="dialog">` fallback without every one of its Must Haves. Partial implementations produce broken screen-reader announcements and stranded focus.
- Do not rely on `aria-modal="true"` to block background interaction; it is announcement metadata, not an interaction gate. Background isolation is a separate implementation concern.
- Do not render the manual fallback inside containers that create clipping or stacking contexts (e.g., `overflow: hidden/auto`, `transform`), and do not rely on `z-index` alone to "make it work."
- Do not inert `document.body` or `document.documentElement` on the manual fallback; inert only the application content root.
- Do not omit focus restoration; closing a dialog must return the user to the element that invoked it.
- Do not set fixed pixel widths on the dialog surface that exceed the 320-CSS-pixel viewport at 400% zoom.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

export function ModalDialog({
  open,
  title,
  description,
  onClose,
  children,
}) {
  const dialogRef = useRef(null);
  const titleId = useId();

  // Open / close the native dialog imperatively when `open` changes.
  // .showModal() is what produces the modal contract: focus trap, background
  // inertness, Escape dismissal, focus restoration, and top-layer rendering.
  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    if (open && !el.open) el.showModal();
    if (!open && el.open) el.close();
  }, [open]);

  // Route the browser's `cancel` (Escape) and `close` events through onClose
  // so callers see a single close pathway. preventDefault on `cancel` lets
  // the effect above handle el.close() for consistency.
  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    const handleCancel = (e) => {
      e.preventDefault();
      onClose();
    };
    const handleClose = () => onClose();
    el.addEventListener("cancel", handleCancel);
    el.addEventListener("close", handleClose);
    return () => {
      el.removeEventListener("cancel", handleCancel);
      el.removeEventListener("close", handleClose);
    };
  }, [onClose]);

  // Backdrop click closes. A click that lands on the <dialog> element itself
  // (not on a content descendant) is a click on the padding around the
  // content — treat that as a backdrop dismiss.
  const handleClick = (e) => {
    if (e.target === dialogRef.current) onClose();
  };

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby={titleId}
      onClick={handleClick}
      style={{
        maxWidth: "min(560px, 100%)",
        border: 0,
        borderRadius: 12,
        padding: 16,
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-start",
          gap: 12,
        }}
      >
        <div style={{ minWidth: 0 }}>
          <h2 id={titleId} style={{ margin: 0 }}>
            {title}
          </h2>
          {description ? (
            <p style={{ marginTop: 8, marginBottom: 0 }}>{description}</p>
          ) : null}
        </div>

        <button
          type="button"
          onClick={onClose}
          aria-label="Close dialog"
          style={{
            width: 36,
            height: 36,
            borderRadius: 8,
            border: "1px solid rgba(0,0,0,0.2)",
            background: "transparent",
            display: "inline-grid",
            placeItems: "center",
            lineHeight: 1,
            cursor: "pointer",
            flex: "0 0 auto",
          }}
        >
          <span aria-hidden="true" style={{ fontSize: 18 }}>
            ×
          </span>
        </button>
      </div>

      <div style={{ marginTop: 16 }}>{children}</div>
    </dialog>
  );
}
```

## Acceptance Checks
- On open:
  - Focus moves into the dialog.
  - Dialog is announced with its accessible name.
  - Background content is not reachable by keyboard or screen reader.
  - Body scroll is prevented.

- While open:
  - Tab and Shift+Tab remain within the dialog.
  - Escape closes the dialog.
  - Clicking the backdrop closes the dialog (unless the pattern has intentionally opted out per Customizable → Backdrop click contract).
  - Clicking inside the dialog content does not close it.
  - Focus indicators on all interactive elements follow the Foundations focus rule.

- On close:
  - Focus returns to the invoking element.
  - Background content becomes interactive again.
  - Body scroll is restored.

- Semantics:
  - Dialog has an accessible name.
  - Close button has an accessible name.
  - Under native `<dialog>` + `.showModal()`, the modal state is conveyed by the top-layer/modal contract; under the manual fallback, `aria-modal="true"` is set explicitly.
  - The invoking control declares dialog-trigger semantics (e.g., `aria-haspopup="dialog"`).

- Reflow:
  - At 400% browser zoom (~320 CSS pixels wide), dialog content reflows within the viewport without horizontal scrolling.
