---
id: radio.group
title: Radio Group
stack: web/react
status: beta
latest_version: 0.1.0
tags: [radio, form, form-control, group, fieldset, single-select]
aliases: [radio group, radio buttons, option buttons, single choice, choose one, mutually exclusive options, radio list, segmented control]
summary: A set of mutually exclusive options from which the user picks exactly one. Native <input type="radio"> elements share one name inside a <fieldset> with a <legend>, so the browser provides single selection, a single tab stop, and arrow-key movement.
---

# Radio Group

Pattern ID: `radio.group`

A set of mutually exclusive options from which the user picks exactly one. Native `<input type="radio">` elements share one `name` inside a `<fieldset>` with a `<legend>`, so the browser provides single selection, a single tab stop, and arrow-key movement.

## Use When
- Use when the user picks exactly one option from a small set of mutually exclusive choices, all visible at once (e.g., "Video quality" with "Auto", "High", "Data saver").
- Use when the options benefit from being compared side by side rather than hidden in a popup, typically 2–6 options.

## Do Not Use When
- Do not use when the user may select more than one option (use `checkbox.group`).
- Do not use when the options are many or space is tight, so a collapsed single-value picker fits better (use `select.native`).
- Do not use when the choice is a persistent on/off setting that takes effect immediately (use `switch.basic`), or a single yes/no choice submitted with a form (use `checkbox.basic`).
- Do not use when choosing an option displays a different panel of content rather than recording a value (use `tabs.basic`).

## Must Haves

### Roles & structure
- Wrap the radios in a single named group.
  - Preferred: a `<fieldset>` with a `<legend>`; the `<legend>` states the question the set answers and becomes the group's accessible name.
  - When `<legend>` cannot be laid out or styled as required, use a container with `role="radiogroup"` and `aria-labelledby` pointing at the visible group-label element.
- Each option is a native `<input type="radio">` (preferred) with a programmatically associated visible `<label>`.
- Every radio in the group shares one `name`, and no radio outside the group uses it.
  - Generate the `name` with `useId()` when the group is written as a reusable component.

### Accessible name
- The group label states the question or instruction for the whole set (e.g., "Video quality"), not a generic heading.
- Each radio's `<label>` names its option on its own (e.g., "High", "Data saver").
- Reference any group-level hint (e.g., "You can change plans at any time.") from each radio's `aria-describedby`.

### State & properties
- The selected option is the native `checked` state, bound in React with `checked` and `onChange` on each radio.
- One radio in the group is checked from the first render, so the group always holds a value.
  - When no option is a safe default, add an explicit neutral option (e.g., "Decide later", "Prefer not to say") and check that one.

### Keyboard
- The group is a single tab stop. Tab moves focus to the checked radio.
- Arrow Down and Arrow Right move focus to the next radio and check it; Arrow Up and Arrow Left move focus to the previous radio and check it. Movement wraps from the last radio to the first and from the first to the last.
- Space checks the focused radio when it is not already checked.

### Focus
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around each radio.

## Don'ts
- Do not navigate, submit the form, or replace page content from a radio's `change` event. Arrow keys check every radio they pass, so the user is moved off the page before reaching the option they wanted.
- Do not give each radio its own `name`, or omit `name`. The radios stop forming a group: each becomes its own tab stop, arrow keys no longer move between them, and more than one can be checked.
- Do not build the set from `<button>` elements with `aria-pressed`. It is announced as independent toggles with no single-selection semantics, even when the code allows only one to be pressed.
- Do not set `aria-checked` on a native `<input type="radio">`. The native `checked` state is what is exposed, and a stale `aria-checked` contradicts it.
- Do not render the group with no radio checked. A user who Tabs past it submits no value without having chosen to, and once any radio is checked, a native group cannot return to none.
- Do not combine unrelated questions in one group; one question per `<fieldset>` or `role="radiogroup"`.

## Customizable
- The grouping mechanism: `<fieldset>` with `<legend>` (most robust), or `role="radiogroup"` with `aria-labelledby` (choose this when `<legend>` styling or layout is the blocker). Both convey the group name.
- Which option is checked by default, as long as one is. Prefer the safest or most common choice (e.g., "Auto"); use a neutral option when no real option is a safe default.
- Per-option visual styling (`accent-color`, `appearance: none` with a painted indicator, or a visually hidden input beside a painted one), as long as each input stays focusable and operable, and the checked state is visible by more than color (see `global.use-of-color`) and under forced colors (see `global.forced-colors`).
- Layout in a column, inline, or as a segmented control, as long as the controls stay native radios and the reading and focus order is sensible.
- Manual fallback, when native radios cannot be used: a container with `role="radiogroup"` holding elements with `role="radio"` and `aria-checked="true|false"`. Implement a roving tabindex (the checked radio at `tabindex="0"` and every other at `tabindex="-1"`), arrow keys that move focus and check, and Space to check the focused radio.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

export function RadioGroup({ legend, options, value, onChange, hint }) {
  const name = useId();
  const hintId = `${name}-hint`;

  return (
    <fieldset>
      <legend>{legend}</legend>
      {hint ? <p id={hintId}>{hint}</p> : null}
      {options.map((option) => (
        <div key={option.value}>
          <input
            type="radio"
            id={`${name}-${option.value}`}
            name={name}
            value={option.value}
            checked={value === option.value}
            aria-describedby={hint ? hintId : undefined}
            onChange={() => onChange(option.value)}
          />
          <label htmlFor={`${name}-${option.value}`}>{option.label}</label>
        </div>
      ))}
    </fieldset>
  );
}

function RadioGroupExamples() {
  const [quality, setQuality] = useState("auto");
  const [plan, setPlan] = useState("undecided");

  return (
    <form>
      <RadioGroup
        legend="Video quality"
        value={quality}
        onChange={setQuality}
        options={[
          { value: "auto", label: "Auto" },
          { value: "high", label: "High" },
          { value: "data-saver", label: "Data saver" },
        ]}
      />
      {/* No real plan is a safe default, so a neutral option is checked. */}
      <RadioGroup
        legend="Plan"
        hint="You can change plans at any time."
        value={plan}
        onChange={setPlan}
        options={[
          { value: "undecided", label: "Decide later" },
          { value: "essential", label: "Essential, with ads" },
          { value: "premium", label: "Premium, ad-free" },
        ]}
      />
    </form>
  );
}
```
