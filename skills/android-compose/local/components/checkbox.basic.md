---
id: checkbox.basic
title: Checkbox
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [checkbox, control, form-control, selection, toggleable]
aliases: [check box, tick box, form checkbox, agree checkbox, opt-in, Checkbox, toggleable]
summary: Yes or no choice submitted with a form, independent of any other checkbox beside it. The control and its label form one accessibility node, and the row that owns the toggle owns the role and the touch target.
---

# Checkbox

Pattern ID: `checkbox.basic`

Yes or no choice submitted with a form, independent of any other checkbox beside it. The control and its label form one accessibility node, and the row that owns the toggle owns the role and the touch target.

## Use When
- Use when a single control records an independent yes or no choice submitted with a form rather than taking effect immediately (e.g., "I agree to the Terms of Service", "Remember me on this device").
- Use when several checkboxes appear together and any number of them may be checked at once, each label standing on its own (e.g., a list of notification types).

## Do Not Use When
- Do not use when the options are mutually exclusive and exactly one must be chosen (use `radio.basic`).
- Do not use when toggling the control takes effect immediately as a persistent setting (use `switch.basic`).
- Do not use when the control turns a feature or formatting state on and off in the current context rather than recording a value to submit (use `button.toggle`).
- Do not use when a third mixed or partially checked state is required, such as a parent reflecting a mix of checked children (use `checkbox.tristate`).
- Do not use when several checkboxes answer one shared question and their labels are not meaningful without it. Group them and name the group, per `global.collection-semantics`.

## Must Haves
- The control reports `Role.Checkbox`, its checked state, and a click action. Material's `Checkbox` is the reference implementation of that contract; a design system's own checkbox satisfies it by forwarding to `Modifier.toggleable(role = Role.Checkbox)`, and a drawn box with a check glyph satisfies none of it (`global.native-first`).
- Put the control and its label in a row that carries `Modifier.toggleable(value = checked, onValueChange = onCheckedChange, role = Role.Checkbox)`, and set the `Checkbox`'s own `onCheckedChange = null`. The whole row then toggles, which is a larger target than the box alone and what TalkBack reads as one control.
- Size that row to at least 48dp. `Checkbox` applies the minimum only while it owns its callback, so hoisting state to the row moves the obligation to the row (`global.touch-target-size`).
- The row is a single accessibility node, and the label text inside it becomes the accessible name (`global.merge-semantics`).
- Word the label so it reads true when checked (e.g., "Remember me on this device"), because TalkBack announces the name followed by the state.
- Let the component report checked and unchecked. Set `stateDescription` only when the visible wording differs from the default, such as a box labeled "Included" and "Excluded" (`global.state-description`).
- Associate supporting text with the row by putting it inside the toggleable row, so it joins the merged name, or by setting `contentDescription` on the row when the supporting text is long enough that merging it would bury the label.
- When the choice is invalid, set `Modifier.semantics { error("...") }` on the row alongside visible error text. Do not move focus to the checkbox when the error appears; announce it instead (`global.announcements`).
- If the choice is unavailable, pass `enabled = false` to both the row's `toggleable` and the `Checkbox`, rather than removing the handler, so the control stays in the accessibility tree and reports that it is disabled.
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not nest an interactive child inside the toggleable row. A child that merges is not absorbed by a parent that merges, so the result is two competing targets rather than one.
- Do not leave `onCheckedChange` on the `Checkbox` while the row is also toggleable. Both become click targets, TalkBack reports two controls, and the row's announcement no longer matches what tapping it does.
- Do not put the label in a `Text` outside the toggleable row. It renders in the same place and lands outside the merged node, leaving the checkbox unnamed.
- Do not convey the checked state by drawing a filled box without a real `Checkbox` or a `Role.Checkbox` on the row. The appearance changes and the accessibility tree does not.
- Do not indicate a required choice or an error with color alone. Pair it with text and with `error()` on the row (`global.use-of-color`).

## Customizable
- The label may sit before or after the box, as long as both are inside the toggleable row.
- `Checkbox` accepts `colors` for brand treatment. Restyling through the parameter keeps the component's semantics; drawing a replacement box does not.
- Supporting text may be rendered inside the row, where it joins the accessible name, or omitted entirely. Where it is long, moving it out of the row and naming the row with `contentDescription` keeps the announcement short.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun CheckboxExamples() {
    var remember by remember { mutableStateOf(false) }
    var agreed by remember { mutableStateOf(false) }

    // The row owns the toggle, the role, and the 48dp target. The Checkbox's own
    // callback is null, which is what hands all three to the row.
    Row(
        modifier = Modifier
            .toggleable(
                value = remember,
                onValueChange = { remember = it },
                role = Role.Checkbox
            )
            .heightIn(min = 48.dp)
            .fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Checkbox(checked = remember, onCheckedChange = null)
        Text("Remember me on this device")
    }

    // Invalid state. error() announces the problem; focus stays where it is.
    Column {
        Row(
            modifier = Modifier
                .toggleable(
                    value = agreed,
                    onValueChange = { agreed = it },
                    role = Role.Checkbox
                )
                .heightIn(min = 48.dp)
                .semantics { if (!agreed) error("You must accept the terms to continue.") },
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(checked = agreed, onCheckedChange = null)
            Text("I agree to the Terms of Service")
        }
        if (!agreed) {
            Text("You must accept the terms to continue.")
        }
    }

    // Disabled. enabled = false on both, so the row reports the state and the
    // box matches it.
    Row(
        modifier = Modifier
            .toggleable(
                value = false,
                onValueChange = { },
                role = Role.Checkbox,
                enabled = false
            )
            .heightIn(min = 48.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Checkbox(checked = false, onCheckedChange = null, enabled = false)
        Text("Email me about new releases")
    }
}
```
