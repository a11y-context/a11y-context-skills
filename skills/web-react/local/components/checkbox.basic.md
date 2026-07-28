---
id: checkbox.basic
title: Checkbox
stack: web/react
status: beta
latest_version: 0.1.0
tags: [checkbox, form, form-control, boolean, consent, selection]
aliases: [checkbox, check box, tickbox, agree to terms, remember me, opt-in, consent checkbox, boolean input]
summary: A single binary checkbox for an independent on/off choice submitted with a form. Uses a native <input type="checkbox"> with an associated <label>, or role="checkbox" with aria-checked when a native input cannot be used.
---

# Checkbox

Pattern ID: `checkbox.basic`

A single binary checkbox for an independent on/off choice submitted with a form. Uses a native `<input type="checkbox">` with an associated `<label>`, or `role="checkbox"` with `aria-checked` when a native input cannot be used.

Native `<input type="checkbox">` is accessible out of the box and is the preferred implementation; a custom `role="checkbox"` element applies only when a native input cannot be used. For a set of related checkboxes that together answer one question, use `checkbox.group`.

## Use When
- Use when a single control records an independent yes/no choice that is submitted with a form rather than taking effect immediately (e.g., "I agree to the Terms of Service", "Remember me on this device", "Email me about new releases").
- Use when the control's label is self-sufficient, including when several such independent checkboxes appear in the same form.
- Use when both the checked and unchecked values are meaningful and are read when the form is submitted.

## Do Not Use When
- Do not use when several checkboxes answer one shared question and their labels are not meaningful without it (use `checkbox.group`).
- Do not use when toggling the control takes effect immediately as a persistent setting rather than a value submitted with a form (use `switch.basic`).
- Do not use when the control toggles a feature, tool, or formatting state in the current context rather than recording a value to submit (use `button.toggle`).
- Do not use when a third "mixed" or "partially checked" state is required, such as a parent reflecting a mix of checked children (use `checkbox.tristate`).

## Must Haves
- Use a native `<input type="checkbox">` (preferred). Use a custom `role="checkbox"` only when a native input cannot be used; it then needs `tabindex="0"`, `aria-checked="true|false"` reflecting state, and a key handler where Space toggles it and prevents page scrolling.
- Associate a visible `<label>` with the input (wrap the input, or point `for` / `htmlFor` at its `id`). Word the label so it reads true when checked (e.g., "Remember me on this device").
- The checkbox has an accessible name equivalent to its visible label. When additional context is needed, add it via `aria-label`, `aria-labelledby`, or offscreen text (`.sr-only`), with the visible text at the start of the accessible name.
- Convey the checked state programmatically: on a native input use the `checked` property (never `aria-checked`); on `role="checkbox"` use `aria-checked="true|false"`.
- The control is in the tab order and Space toggles it. Enter does not toggle a checkbox (within a form, Enter submits).
- If the checkbox is required:
  - Mark it with the native `required` attribute and a visible non-color text indicator (e.g., "(required)"); `aria-hidden` the visible indicator when it would duplicate the native required announcement.
  - Give it an inline error container that is always present in the DOM (empty until invalid), carries `aria-live="polite"`, and is referenced by the input's `aria-describedby`.
  - Populate the error on blur when left invalid, not on submit and not per keystroke. The error text names the problem and is itself non-color (e.g., begins with "Error:"). Do not move focus to the checkbox; submit-time focus is a form-level concern (see `form.error-summary`).
- Associate any supporting hint text with the input via `aria-describedby`.
- If the choice is unavailable, disable the input with the native `disabled` attribute.
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around the control.

## Customizable
- The base element: a native `<input type="checkbox">` (preferred), or a custom `role="checkbox"` element only when a native input cannot be used. Native elements reduce the keyboard, focus, and state wiring that must be hand-rolled.
- Visual styling, in increasing order of control, while keeping a real native input:
  - Recolor only: set `accent-color` on the input to apply a brand color with no markup change.
  - Full control: set `appearance: none` on the input and style the element directly (border, background, check indicator), driving the appearance from the `:checked` state, and keep a visible `:focus-visible` indicator.
  - Older equivalent: visually hide the native input with the `.sr-only` utility (`global.sr-only`) and draw a styled box from the associated `<label>`. The input must remain focusable and operable.
- Whether the label wraps the input or is associated by `for` / `htmlFor`.
- Whether the box is rendered before or after the label text, as long as the two remain programmatically associated.
- Whether a hint or description is shown under the label (associate it with `aria-describedby` when present).

## Don'ts
- Do not build a checkbox out of a `<div>` or `<span>` with a click handler unless a native input cannot be used; the native `<input type="checkbox">` is the baseline.
- Do not convey the checked state by appearance alone (e.g., a filled box) without the native `checked` property or `aria-checked`.
- Do not set both the native `checked` property and `aria-checked` on the same element.
- Do not hide the input with `display: none` or `visibility: hidden` when styling a custom box; that removes it from the tab order and disables keyboard operation. Use the `.sr-only` technique instead.
- Do not remove the focus ring when restyling with `accent-color` or `appearance: none`; provide a visible `:focus-visible` indicator.
- Do not bind Enter to toggle the box; a checkbox toggles on Space, and Enter submits the surrounding form.
- Do not rely on adjacent or placeholder text for the label without a programmatic association (`<label for>`, a wrapping `<label>`, `aria-labelledby`, or `aria-label`).
- Do not indicate the required state or an error with color alone; include text (e.g., "Required", "Error:") or an icon carrying an `aria-label`.
- Do not move focus to the checkbox when its inline error appears; populating the `aria-live` container is what announces it.
- Do not use a single checkbox for a set of related options that answer one question (that is a grouped pattern).

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

export function CheckboxDemo() {
  const [rememberMe, setRememberMe] = useState(false);
  const [marketing, setMarketing] = useState(true);
  const [agreed, setAgreed] = useState(false);
  const [agreeError, setAgreeError] = useState("");

  // Custom role="checkbox" state (used only when a native input cannot be used).
  const [parentalControls, setParentalControls] = useState(false);

  return (
    // Field-level inline errors only (no submit button, no form-level
    // validation). Enter does not toggle a checkbox.
    <form noValidate>
      {/* Basic: label associated by htmlFor */}
      <div>
        <input
          type="checkbox"
          id="remember-me"
          checked={rememberMe}
          onChange={(e) => setRememberMe(e.target.checked)}
        />
        <label htmlFor="remember-me">Remember me on this device</label>
      </div>

      {/* With a description via aria-describedby */}
      <div>
        <input
          type="checkbox"
          id="marketing"
          checked={marketing}
          onChange={(e) => setMarketing(e.target.checked)}
          aria-describedby="marketing-hint"
        />
        <label htmlFor="marketing">Email me about new releases and offers</label>
        <p id="marketing-hint">You can unsubscribe at any time.</p>
      </div>

      {/*
        Required checkbox with a FIELD-LEVEL inline error:
        - "(required)" is shown as text (not color alone), and is aria-hidden
          because the native required attribute already conveys the state.
        - The error container is always in the DOM (empty until invalid) with
          aria-live="polite", so populating it announces the error once.
        - aria-describedby always points the input at the container, so the
          error is re-announced if focus returns.
        - The error populates on blur when left unchecked, not on submit, and
          focus is never moved.
      */}
      <div>
        <input
          type="checkbox"
          id="agree"
          checked={agreed}
          required
          aria-describedby="agree-error"
          onChange={(e) => {
            setAgreed(e.target.checked);
            if (e.target.checked) setAgreeError("");
          }}
          onBlur={(e) =>
            setAgreeError(
              e.target.checked
                ? ""
                : "Error: You must agree to the Terms of Service to continue."
            )
          }
        />
        <label htmlFor="agree">
          I agree to the Terms of Service and Privacy Policy{" "}
          <span aria-hidden="true">(required)</span>
        </label>
        <p id="agree-error" aria-live="polite">
          {agreeError}
        </p>
      </div>

      {/* Disabled: native disabled attribute removes it from the tab order */}
      <div>
        <input type="checkbox" id="promo" defaultChecked disabled />
        <label htmlFor="promo">Founding-member pricing (applied)</label>
      </div>

      {/*
        Custom role="checkbox": use ONLY when a native input cannot be used.
        It takes on tabindex, aria-checked, and the Space key handler manually.
        The visual box must reflect aria-checked (shown here with a placeholder).
      */}
      <div
        role="checkbox"
        aria-checked={parentalControls ? "true" : "false"}
        tabIndex={0}
        onClick={() => setParentalControls((v) => !v)}
        onKeyDown={(e) => {
          if (e.key === " ") {
            e.preventDefault();
            setParentalControls((v) => !v);
          }
        }}
      >
        <span aria-hidden="true">{parentalControls ? "[x]" : "[ ]"}</span> Enable
        parental controls
      </div>
    </form>
  );
}
```

## Acceptance Checks

- Keyboard
  - Tab moves focus to each checkbox, and the disabled checkbox is skipped.
  - Space toggles the focused checkbox.
  - Enter does not toggle the checkbox.
  - A visible focus indicator is present on the focused checkbox.
- Screen Reader
  - Each checkbox is announced with its accessible name and role ("checkbox").
  - The checked or unchecked state is announced and updates when toggled.
  - A description associated with `aria-describedby` is announced (e.g., "You can unsubscribe at any time").
  - A required checkbox is announced as required.
  - The custom `role="checkbox"` control announces its role and `aria-checked` state just like the native input, and its visible box matches the announced state.
- Validation
  - Leaving the required checkbox unchecked (moving focus away) populates an inline error that is announced once via the `aria-live="polite"` container.
  - Returning focus to the checkbox re-announces the error via `aria-describedby`.
  - Focus is not moved when the error appears.
  - Checking the box clears the error.
