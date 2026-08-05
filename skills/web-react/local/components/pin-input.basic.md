---
id: pin-input.basic
title: PIN Input
stack: web/react
status: beta
latest_version: 0.1.0
tags: [pin, otp, form, form-control, authentication, numeric]
aliases: [pin entry, passcode field, otp input, one-time code input, verification code input, 2fa code entry, segmented code input, security code boxes]
summary: A fixed-length numeric code entered across segmented boxes, implemented as a single <input> whose expected length is carried in a description rather than by the box count, with the boxes and any group separator rendered as aria-hidden presentation.
---

# PIN Input

Pattern ID: `pin-input.basic`

A fixed-length numeric code entered across segmented boxes, implemented as a single `<input>` whose expected length is carried in a description rather than by the box count, with the boxes and any group separator rendered as `aria-hidden` presentation.

The segmented boxes are a visual treatment, not a structure: the field is one input, and the expected length reaches assistive technology as text rather than as a count of rendered boxes.

## Use When
- Use when the user enters a short numeric code of a known fixed length across segmented boxes (e.g., "Parental control PIN", "Profile lock", "Purchase confirmation").
- Use when a verification code delivered out of band is entered (e.g., "Enter the 6-digit code we texted you").

## Do Not Use When
- Do not use when the value has no fixed length, such as free-form text, an arbitrary number, or an account password (no pattern is needed; use a native `<input>` with a visible `<label>` and the Foundations rules).
- Do not use when the requirement is collecting and summarizing errors across several fields rather than validating one code field (use `form.error-summary`).

## Must Haves

### Roles & structure
- The field is a single native `<input>` element holding the entire code, regardless of how many boxes are rendered (e.g., a 4-digit PIN drawn as 4 separate boxes is one input whose value is all 4 digits).
- Wrap the presentational boxes in a container carrying `aria-hidden="true"`, and keep the `<input>` outside that container.
- Set `inputmode="numeric"` on the input.
  - `inputmode` requests a digits keyboard without restricting typed characters; strip non-digits in the change handler.
- Set `type="password"` while the value is masked, and `type="text"` when it is unmasked or revealed.
- Set `maxlength` to the expected number of digits.
- Render the group separator inside the `aria-hidden` container.
- Set `autocomplete="one-time-code"` only when the code is delivered out of band, such as by SMS, email, or an authenticator app.
  - For a stored credential such as a parental-control or profile PIN, omit the `autocomplete` attribute.

### Accessible name
- Associate a visible `<label>` with the input using `for` / `htmlFor`.
- State the expected number of digits in a description referenced by the input's `aria-describedby` (e.g., "4 digits", "7-digit account code").
- When the boxes are grouped and the groups carry meaning, state that meaning in the same description.

### State & properties
- Give the input an inline error container that is always present in the DOM (empty until invalid), carries `aria-live="polite"`, and is referenced by the input's `aria-describedby`.
- Populate the error on blur when the value is incomplete, or after the code is rejected, not per keystroke. The error text names the problem and is itself non-color (e.g., begins with "Error:").
- Set `aria-invalid="true"` on the input while an error is displayed, and remove it when the error clears.
- When the field is cleared after a rejected code, state that in the error text.
- When the value is masked, provide a reveal control implemented as a toggle button (see `button.toggle`) that switches the input to `type="text"`.

### Keyboard
- Typing a digit fills the box at the caret and advances the caret to the next box.
- Backspace deletes the digit before the caret and moves the caret back one box.
- Left and Right move the caret between boxes in visual order.
- Paste fills the field across every box from the caret position, and a pasted value containing the group separator, spaces, or other non-digits is reduced to its digits.

### Focus
- The field occupies one stop in the tab order.
- Indicate the box at the caret with a visible current-position indicator, distinct from the field's own focus indicator (see `global.focus-states`).

## Customizable
- A code delivered out of band and a stored PIN are the same control and differ only in `autocomplete`: out-of-band codes carry `autocomplete="one-time-code"`, stored PINs omit it. Every other requirement above applies to both.
- The expected digit count may live in the accessible name instead of the description (e.g., a label reading "Parental control PIN, 4 digits"). A visible description is the better default, because it gives sighted users the same information the box count already gives them.
- Masking is at the engineer's discretion as long as the user can reveal the value. An unmasked field needs no reveal control; a masked field requires one.
- Group sizes and the separator glyph are at the engineer's discretion, as long as the separator stays inside the `aria-hidden` container and out of the value.
- Layout is horizontal in this pattern, so Left and Right are the caret keys. A vertical arrangement would make Up and Down the expected keys and is outside the scope of this pattern.

## Don'ts
- Do not render the field as one `<input>` per box; each box then announces as an unlabeled text field, and the field consumes one tab stop per digit.
- Do not make an individual box focusable.
- Do not rely on the number of boxes rendered to communicate the expected length.
- Do not use `type="number"`, which exposes spinner controls, drops leading zeros, and changes the value on scroll.
- Do not give the group separator separator semantics such as `role="separator"` or `<hr>` (see `separator.basic`); inside a single field it is decorative presentation.
- Do not expose the group separator as text content or as part of the submitted value.
- Do not capture the keys the browser uses for text editing (character keys, caret movement, selection, and deletion).
- Do not announce the entered digits through a live region.
- Do not block paste, and do not block password managers or platform autofill from filling the field.
- Do not set `autocomplete="off"` on the field; it suppresses the password manager and platform autofill that a user may rely on to complete it.
- Do not mask the value by substituting mask glyphs in the presentational boxes while the input stays `type="text"`; the screen reader then speaks the real digits aloud while the screen shows the mask.
- Do not move focus to the field when its inline error appears; populating the `aria-live` container is what announces it. Submit-time focus is a form-level concern (see `form.error-summary`).

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

const boxStyle = {
  width: 32,
  height: 40,
  border: "1px solid GrayText",
  display: "grid",
  placeItems: "center",
};

const inputStyle = {
  position: "absolute",
  inset: 0,
  width: "100%",
  // Transparent glyphs and caret let the boxes below read as the value, while
  // the input stays focusable and exposed so paste and password managers work.
  color: "transparent",
  caretColor: "transparent",
  background: "transparent",
  border: 0,
};

export function PinInput({
  label = "Parental control PIN",
  length = 4,
  groupSizes = null,
  masked = true,
  outOfBand = false,
}) {
  const [value, setValue] = useState("");
  const [error, setError] = useState("");
  const [caret, setCaret] = useState(0);
  const [revealed, setRevealed] = useState(false);

  const baseId = useId();
  const inputId = `${baseId}-input`;
  const hintId = `${baseId}-hint`;
  const errorId = `${baseId}-error`;

  const separatorAfter = new Set();
  let filled = 0;
  for (const size of (groupSizes ?? []).slice(0, -1)) {
    filled += size;
    separatorAfter.add(filled - 1);
  }

  function onChange(e) {
    // inputmode="numeric" only requests a digits keyboard; it does not restrict
    // what can be typed. Stripping here is also what lets a pasted value
    // carrying the separator ("123-4567") land in the right boxes.
    setValue(e.target.value.replace(/\D/g, "").slice(0, length));
    if (error) setError("");
  }

  function onBlur() {
    if (value.length > 0 && value.length < length) {
      setError(`Error: enter all ${length} digits.`);
    }
  }

  return (
    <div>
      <label htmlFor={inputId} style={{ display: "block" }}>{label}</label>

      {/* The expected length is stated in text. The box count never carries it. */}
      <p id={hintId}>{length} digits</p>

      <div style={{ position: "relative", display: "inline-block" }}>
        {/* Presentation only. The boxes and the separator are hidden from
            assistive technology; the input holds the name and the value. */}
        <div aria-hidden="true" style={{ display: "flex", gap: 4 }}>
          {Array.from({ length }).flatMap((_, i) => [
            <span
              key={`box-${i}`}
              style={{
                ...boxStyle,
                outline: i === Math.min(caret, length - 1) ? "2px solid Highlight" : "none",
              }}
            >
              {value[i] ? (masked && !revealed ? "•" : value[i]) : ""}
            </span>,
            separatorAfter.has(i) ? <span key={`sep-${i}`}>[separator]</span> : null,
          ])}
        </div>

        <input
          id={inputId}
          // Masking is real, not painted. Under type="text" the screen reader
          // speaks the actual digits while the boxes show bullets.
          type={masked && !revealed ? "password" : "text"}
          inputMode="numeric"
          // Omitted for a stored PIN. "off" would suppress the password manager
          // and platform autofill some users depend on.
          autoComplete={outOfBand ? "one-time-code" : undefined}
          maxLength={length}
          value={value}
          onChange={onChange}
          // Tracking the caret, not the value length, is what makes Left and Right move the indicator.
          onSelect={(e) => setCaret(e.currentTarget.selectionStart ?? 0)}
          onBlur={onBlur}
          aria-describedby={`${hintId} ${errorId}`}
          aria-invalid={error ? "true" : undefined}
          style={inputStyle}
        />
      </div>

      {masked && (
        <button type="button" aria-pressed={revealed} onClick={() => setRevealed((v) => !v)}>
          Show PIN
        </button>
      )}

      {/* Always mounted, empty until invalid, so the update is announced. */}
      <p id={errorId} aria-live="polite">{error}</p>
    </div>
  );
}
```

## Acceptance Checks

Structure
- The accessibility tree exposes one text field for the whole control, and no entry for any individual box.
- The group separator is absent from the accessibility tree and absent from the submitted value.
- Pasting a value that includes the separator or spaces fills the boxes with digits only.

Keyboard
- Tab moves focus to the field once, and Tab again leaves it; no box is a separate stop.
- Typing digits fills boxes left to right and the current-position indicator advances.
- Backspace clears the digit before the caret and the indicator moves back one box.
- Left and Right move the current-position indicator between boxes, and never onto the separator.
- Paste fills the whole field rather than the first box only.
- Text selection and deletion behave as they do in a normal text field.

Screen Reader
- The field is announced once, with its label and the expected number of digits.
- No box is announced as a separate unlabeled text field.
- The separator is not spoken.
- While the value is masked, typing does not speak the entered digits.
- After the reveal control is activated, typing speaks the entered digits.
- The reveal control conveys its pressed state when activated.
- An incomplete or rejected code is announced from the live region without focus moving.
