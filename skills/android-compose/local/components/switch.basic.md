---
id: switch.basic
title: Switch
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [switch, toggle, settings, on-off, form-control]
aliases: [toggle switch, preference toggle, settings toggle, Switch, on off toggle, toggleable]
summary: Persistent on or off setting that takes effect immediately. The control and its label form one accessibility node, and the row that owns the toggle owns the role and the touch target.
---

# Switch

Pattern ID: `switch.basic`

Persistent on or off setting that takes effect immediately. The control and its label form one accessibility node, and the row that owns the toggle owns the role and the touch target.

## Use When
- Use when a control represents a persistent binary setting that stays on or off beyond the current interaction (e.g., "Enable notifications", "Dark mode").
- Use when the setting takes effect the moment it is toggled, with no form to submit.

## Do Not Use When
- Do not use when the value is submitted with a form rather than taking effect immediately (use `checkbox.basic`).
- Do not use when the control turns a feature or formatting state on and off in the current context rather than recording a setting (use `button.toggle`).
- Do not use when more than two states are required (use `button.toggle`).
- Do not use when exactly one option must be chosen from a set (use `radio.basic`).

## Must Haves
- The control reports `Role.Switch`, its checked state, and a click action. Material's `Switch` is the reference implementation of that contract; anything else has to set all three itself (`global.native-first`).
- Put the control and its label in a row that carries `Modifier.toggleable(value = checked, onValueChange = onCheckedChange, role = Role.Switch)`, and set the `Switch`'s own `onCheckedChange = null`. The whole row then toggles, which is a larger target than the track and what TalkBack reads as one control.
- Size that row to at least 48dp. `Switch` applies the minimum only while it owns its callback, so hoisting state to the row moves the obligation to the row (`global.touch-target-size`).
- The row is a single accessibility node, and the label text inside it becomes the accessible name (`global.merge-semantics`).
- Word the label so it reads true when the switch is on (e.g., "Enable notifications"), because TalkBack announces the name followed by the state.
- Let the component report on and off. Set `stateDescription` only when the visible wording differs from the default, such as a switch showing "Allowed" and "Blocked" (`global.state-description`).
- Put supporting text inside the toggleable row so it joins the merged name, or, when it is long enough that merging would bury the label, leave it in the row visually and set `contentDescription` on the row to the label alone. Compose has no `supportingText` slot on `Switch` and no equivalent of `aria-describedby`, so the text either merges or is lost.
- When several switches share generic visible text, such as a repeated row label inside a list of accounts, give each row a `contentDescription` naming which setting it controls.
- If the setting is unavailable, pass `enabled = false` to both the row's `toggleable` and the `Switch`, rather than removing the handler, so the control stays in the accessibility tree and reports that it is disabled.
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not nest an interactive child inside the toggleable row. A child that merges is not absorbed by a parent that merges, so the result is two competing targets rather than one.
- Do not leave `onCheckedChange` on the `Switch` while the row is also toggleable. Both become click targets and TalkBack reports two controls.
- Do not put the label in a `Text` outside the toggleable row. It renders in the same place and lands outside the merged node, leaving the switch unnamed.
- Do not use a switch for something that is not a setting, such as running an action or filtering a list. The role tells the user the state persists, and it will not.
- Do not rely on the track color to convey the state. The `Switch` thumb position carries it, and a restyled track that changes only in hue does not (`global.use-of-color`).

## Customizable
- The label may sit before or after the switch, as long as both are inside the toggleable row. A settings row conventionally puts the label first and the switch at the trailing edge.
- `Switch` accepts `colors` and a `thumbContent` slot for brand treatment. Restyling through the parameters keeps the component's semantics; drawing a replacement track does not.
- Supporting text may be rendered inside the row, where it joins the accessible name, or omitted.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun SwitchExamples() {
    var notifications by remember { mutableStateOf(true) }
    var privacy by remember { mutableStateOf(false) }

    // The row owns the toggle, the role, and the 48dp target. The Switch's own
    // callback is null, which is what hands all three to the row.
    Row(
        modifier = Modifier
            .toggleable(
                value = notifications,
                onValueChange = { notifications = it },
                role = Role.Switch
            )
            .heightIn(min = 48.dp)
            .fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text("Enable notifications", modifier = Modifier.weight(1f))
        Switch(checked = notifications, onCheckedChange = null)
    }

    // Custom visible wording, so stateDescription matches what is on screen
    // instead of the default on and off.
    Row(
        modifier = Modifier
            .toggleable(
                value = privacy,
                onValueChange = { privacy = it },
                role = Role.Switch
            )
            .heightIn(min = 48.dp)
            .fillMaxWidth()
            .semantics { stateDescription = if (privacy) "Allowed" else "Blocked" },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text("Personalized ads", modifier = Modifier.weight(1f))
        Text(if (privacy) "Allowed" else "Blocked")
        Switch(checked = privacy, onCheckedChange = null)
    }

    // Disabled. enabled = false on both, so the row reports the state.
    Row(
        modifier = Modifier
            .toggleable(
                value = false,
                onValueChange = { },
                role = Role.Switch,
                enabled = false
            )
            .heightIn(min = 48.dp)
            .fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text("Download over cellular", modifier = Modifier.weight(1f))
        Switch(checked = false, onCheckedChange = null, enabled = false)
    }
}
```
