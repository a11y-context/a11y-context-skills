---
id: radio.basic
title: Radio Group
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [radio, radio button, single-select, mutually-exclusive, selection]
aliases: [radio button, radio group, single choice, one of many, RadioButton, selectableGroup, option list]
summary: Exactly one choice from a mutually exclusive set. The group carries selectableGroup, which is what makes each option announce its position in the set, and each row carries the selection rather than the button.
---

# Radio Group

Pattern ID: `radio.basic`

Exactly one choice from a mutually exclusive set. The group carries `selectableGroup`, which is what makes each option announce its position in the set, and each row carries the selection rather than the button.

## Use When
- Use when exactly one option must be chosen from a small set that stays fully visible as a list of rows (e.g., "Shipping speed", "Choose a plan").
- Use when the always-visible list is preferred over a control that collapses the choices behind a pop-up.

## Do Not Use When
- Do not use when any number of options may be chosen, including none (use `checkbox.basic`).
- Do not use when the control is a single persistent on or off setting (use `switch.basic`).
- Do not use when two to five options fit inline as one connected control (use `segmented-button.single`).
- Do not use when one choice comes from a longer set and a compact pop-up is preferred over an expanded list (use `select.basic`).

## Must Haves
- The control reports `Role.RadioButton` and its selected state. Material's `RadioButton` is the reference implementation of that contract; anything else has to set both itself (`global.native-first`).
- Ship the group with one option already selected. A radio group has no route back to nothing selected, so an empty start is a state the user can leave once and never return to, and it makes the group the one control on the screen that can be silently skipped. Where "none" is a legitimate answer, give it its own option rather than leaving the group empty.
- Put `Modifier.selectableGroup()` on the container holding the options. Without it the rows are unrelated selectable controls, and TalkBack does not announce which position in the set each one occupies.
- Put each option's control and label in a row that carries `Modifier.selectable(selected = isSelected, onClick = onSelect, role = Role.RadioButton)`, and set the `RadioButton`'s own `onClick = null`. The whole row then selects, and TalkBack reads it as one control.
- Size each row to at least 48dp. `RadioButton` applies the minimum only while it owns its callback, so hoisting selection to the row moves the obligation to the row (`global.touch-target-size`).
- Each row is a single accessibility node, and its label text becomes the accessible name (`global.merge-semantics`).
- Give the group a visible heading and name the group itself with `Modifier.semantics { contentDescription = "..." }` on the `selectableGroup` container, so a user entering the set hears what it is choosing between (`global.collection-semantics`).
- Mark the group's visible heading with `heading()`, so it can be reached directly (`global.headings`).
- Put an option's supporting text inside that option's selectable row so it joins the merged name. Compose has no `supportingText` slot on `RadioButton` and no equivalent of `aria-describedby`, so text placed outside the row is not associated with the option.
- Distinguish the selected option by more than its color. `RadioButton` draws a filled inner circle, which carries it; a custom row that changes only a background tint does not (`global.use-of-color`).
- If an option is unavailable, pass `enabled = false` to both the row's `selectable` and the `RadioButton`, so it stays in the accessibility tree and reports that it is disabled.
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not omit `selectableGroup()`. The rows still select correctly and still announce as radio buttons, and the user loses any sense of how many options there are or where they are among them. This is the failure that looks fine on screen and on a semantics dump.
- Do not nest an interactive child inside a selectable row. A child that merges is not absorbed by a parent that merges, so the result is two competing targets rather than one.
- Do not leave `onClick` on the `RadioButton` while the row is also selectable. Both become click targets and TalkBack reports two controls per option.
- Do not build the group from `Modifier.clickable` rows with a drawn circle. They announce as buttons with no selected state and no position in the set.
- Do not ship the group with nothing selected and rely on validation to catch it. Add a "None" option if none is a real answer; otherwise pick a default.

## Customizable
- The label may sit before or after the control, as long as both are inside the selectable row.
- An option may render as a labeled circle or as a selectable card, provided the row keeps `Role.RadioButton` and the selected state stays distinguishable without color.
- The group's name may come from `contentDescription` on the container or from the visible heading when the heading sits immediately before the group in traversal order. The explicit name is safer, because it survives a layout change that separates them.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun RadioGroupExamples() {
    val options = listOf("Standard", "Express", "Overnight")
    // The group opens with a selection. There is no route back to none, so
    // starting empty creates a state the user cannot return to.
    var selected by remember { mutableStateOf(options.first()) }

    Column {
        Text(
            text = "Shipping speed",
            modifier = Modifier.semantics { heading() }
        )

        Column(
            // selectableGroup is what makes each row announce its position in
            // the set. Without it the rows are unrelated selectable controls.
            modifier = Modifier
                .selectableGroup()
                .semantics { contentDescription = "Shipping speed" }
        ) {
            options.forEach { option ->
                Row(
                    modifier = Modifier
                        .selectable(
                            selected = (option == selected),
                            onClick = { selected = option },
                            role = Role.RadioButton
                        )
                        .heightIn(min = 48.dp)
                        .fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    RadioButton(selected = (option == selected), onClick = null)
                    Text(option)
                }
            }
        }
    }
}
```
