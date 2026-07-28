---
id: checkbox.group
title: Checkbox Group
stack: web/react
status: beta
latest_version: 0.1.0
tags: [checkbox, form, form-control, group, fieldset, multi-select]
aliases: [checkbox group, checkbox list, multi-select checkboxes, fieldset checkboxes, options list, select multiple, preferences checkboxes]
summary: A set of related checkboxes that together answer one question. The group is named with <fieldset> and <legend>, or role="group" with aria-labelledby, and each option is an independent native <input type="checkbox">.
---

# Checkbox Group

Pattern ID: `checkbox.group`

A set of related checkboxes that together answer one question. The group is named with `<fieldset>` and `<legend>`, or `role="group"` with `aria-labelledby`, and each option is an independent native `<input type="checkbox">`.

Each option in the group is an individual checkbox that follows `checkbox.basic`; this pattern adds the group name and group-level validation a related set requires. For a single, self-sufficient checkbox, use `checkbox.basic`.

## Use When
- Use when several checkboxes together answer one question and each option's label is not meaningful without that shared question (e.g., "Which genres do you watch?" with "Action", "Comedy", "Drama").
- Use when the user may select zero, one, or many options from the set.
- Use when the set needs a single visible group label, and sometimes group-level validation (e.g., "Select at least one").

## Do Not Use When
- Do not use when a single, self-sufficient checkbox captures the choice (use `checkbox.basic`).
- Do not use when exactly one option may be selected from the set (use `radio.group`).
- Do not use when each toggle is a persistent setting that takes effect immediately rather than a value submitted with a form (use `switch.basic`).
- Do not use when the choices are presented inside a popup opened from a trigger (use `select.basic`, or a dedicated multi-select pattern for many values).

## Must Haves
- Wrap the related checkboxes in a single named group.
  - Preferred: a `<fieldset>` with a `<legend>`; the `<legend>` states the question the set answers and becomes the group's accessible name.
  - When `<legend>` cannot be laid out or styled as required, use a container with `role="group"` and `aria-labelledby` pointing at the visible group-label element.
- The group label states the question or instruction for the whole set (e.g., "Which genres do you watch?"), not a generic heading.
- Reference any group-level hint (e.g., "Select at least one") from each checkbox's `aria-describedby`.
- Each option is a native `<input type="checkbox">` (preferred) with a programmatically associated visible `<label>` and its own `checked` state; see `checkbox.basic` for the per-control contract. Any number of options may be checked.
- Space toggles the focused option; Tab and Shift+Tab move between options, and each option is its own tab stop.
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around each option.
- If the group is required, validate at the group level, never per option:
  - Indicate the requirement in the group's accessible name (e.g., append "(required)" to the `<legend>` or `aria-labelledby` target), since a group has no native `required` attribute.
  - Provide one inline error container, present in the DOM at all times (empty until invalid), carrying `aria-live="polite"` and referenced from each checkbox's `aria-describedby`.
  - Populate the error only when focus leaves the whole group with the requirement unmet, not as focus moves between options.
  - While invalid, give the group a visible non-color indication (e.g., a red outline plus error text beginning with "Error:").
  - Do not move focus when the error appears; submit-time focus handling is a form-level concern (see `form.error-summary`).

## Customizable
- The grouping mechanism: `<fieldset>` with `<legend>` (most robust), or `role="group"` with `aria-labelledby` (choose this when `<legend>` styling or layout is the blocker). Both convey the group name; pick one and verify with a screen reader.
- Per-option visual styling, using the same ladder as `checkbox.basic` (`accent-color`, `appearance: none`, or a visually hidden input with a painted box), as long as each input stays focusable and operable.
- Whether the options are laid out in a column, grid, or inline, as long as the reading and focus order is sensible.
- Whether a "Select all" affordance is offered. (A tri-state "Select all" that reflects a mix of checked children is `checkbox.tristate`.)

## Don'ts
- Do not rely on a nearby heading or paragraph to label the set without a programmatic association (a `<legend>`, or `aria-labelledby` on a `role="group"` container).
- Do not use `role="radiogroup"`, `role="radio"`, or arrow-key roving focus for checkboxes; checkboxes allow multiple selections, and each is a tab stop.
- Do not put `required` on every checkbox to express "select at least one"; native `required` forces that specific box to be checked. Validate at the group level instead.
- Do not attach a separate live-region error to each checkbox in a group; use one group-level error, announced once, so the user does not hear a string of errors while tabbing through the options.
- Do not rely on `aria-describedby` on the `<fieldset>` or `role="group"` container to convey the hint or error. NVDA does not announce a group-level description when the first control in the group is a checkbox, and descriptions on the container are dropped in browse mode. Put the reference on each `<input>`.
- Do not wrap a single, self-sufficient checkbox in a `<fieldset>` and `<legend>` (that belongs to `checkbox.basic`).
- Do not combine unrelated questions in one group; one question per `<fieldset>` or `role="group"`.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

const GENRES = [
  { value: "action", label: "Action" },
  { value: "comedy", label: "Comedy" },
  { value: "drama", label: "Drama" },
  { value: "documentary", label: "Documentary" },
];

const NOTIFY = [
  { value: "releases", label: "New releases" },
  { value: "price-drops", label: "Price drops" },
  { value: "recommendations", label: "Recommendations" },
];

export function CheckboxGroupDemo() {
  const [genres, setGenres] = useState([]);
  const [notify, setNotify] = useState(["releases"]);
  const [genresError, setGenresError] = useState("");

  function toggle(setList, value) {
    setList((list) =>
      list.includes(value)
        ? list.filter((v) => v !== value)
        : [...list, value]
    );
  }

  // Validate only when focus leaves the whole group, so the error is announced
  // once, not once per checkbox as the user tabs through. React's onBlur maps
  // to focusout, which bubbles.
  function onGenresBlur(e) {
    if (e.currentTarget.contains(e.relatedTarget)) return; // still inside the group
    setGenresError(
      genres.length === 0
        ? "Error: Choose at least one genre to continue."
        : ""
    );
  }

  return (
    <form noValidate>
      {/* Grouped with fieldset + legend (preferred) */}
      <fieldset onBlur={onGenresBlur}>
        <legend>Which genres do you watch? (required)</legend>
        <p id="genres-hint">Select at least one.</p>
        {GENRES.map((g) => (
          <div key={g.value}>
            {/* Hint and error are referenced from each input, not from the
                fieldset: a description on the group container is not announced
                reliably when the first control is a checkbox. */}
            <input
              type="checkbox"
              id={`genre-${g.value}`}
              checked={genres.includes(g.value)}
              aria-describedby={
                genresError ? "genres-hint genres-error" : "genres-hint"
              }
              onChange={() => {
                toggle(setGenres, g.value);
                setGenresError("");
              }}
            />
            <label htmlFor={`genre-${g.value}`}>{g.label}</label>
          </div>
        ))}
      </fieldset>
      {/* One group-level error; the live region announces it once on populate. */}
      <p id="genres-error" aria-live="polite">
        {genresError}
      </p>

      {/* Grouped with role="group" + aria-labelledby (styling escape hatch) */}
      <div role="group" aria-labelledby="notify-label">
        <p id="notify-label">Notify me about</p>
        {NOTIFY.map((n) => (
          <div key={n.value}>
            <input
              type="checkbox"
              id={`notify-${n.value}`}
              checked={notify.includes(n.value)}
              onChange={() => toggle(setNotify, n.value)}
            />
            <label htmlFor={`notify-${n.value}`}>{n.label}</label>
          </div>
        ))}
      </div>
    </form>
  );
}
```

## Acceptance Checks

- Keyboard
  - Tab moves focus to each option in turn; each checkbox is its own tab stop.
  - Space toggles the focused option, and multiple options can be checked at once.
  - Arrow keys do not move focus between options (this is not a radio group).
  - A visible focus indicator is present on the focused option.
- Screen Reader
  - Entering the group announces the group name (the `<legend>` or the `aria-labelledby` target).
  - Each option is announced with its own label, role ("checkbox"), and checked or unchecked state.
  - The group-level hint is announced when a checkbox receives focus.
  - The `role="group"` set announces equivalently to the `<fieldset>` and `<legend>` set.
- Validation
  - Moving focus out of the group with no option selected populates one group-level error, announced once via `aria-live="polite"` (not once per option as focus passes through).
  - While invalid, the group shows a visible non-color indication, and returning focus to a checkbox re-announces the error via `aria-describedby`.
  - Focus is not moved when the error appears.
  - Selecting an option clears the error.
