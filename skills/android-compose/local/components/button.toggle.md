---
id: button.toggle
title: Toggle Button
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [button, toggle, icon button, on-off, checked, favorite, formatting]
aliases: [toggle button, IconToggleButton, FilledIconToggleButton, FilledTonalIconToggleButton, OutlinedIconToggleButton, icon toggle, pressed button, favorite button, bookmark button, formatting toggle]
summary: Icon button that turns something on or off in place and keeps the same name in both states. Material's icon toggle buttons report a checked state, so the name says what the control turns on and the state says whether it is on; the standard toggle shows that state by color alone.
---

# Toggle Button

Pattern ID: `button.toggle`

Icon button that turns something on or off in place and keeps the same name in both states. Material's icon toggle buttons report a checked state, so the name says what the control turns on and the state says whether it is on; the standard toggle shows that state by color alone.

## Use When
- Use when a control turns a feature or attribute on and off in the current context and keeps the same name in both states (e.g., "Favorite", "Bookmark", "Mute").
- Use when several such controls sit together in a toolbar, each on or off independently (e.g., "Bold", "Italic", "Underline").

## Do Not Use When
- Do not use when the control's name changes to the action it performs next, such as "Play" becoming "Pause" (use `button.basic`).
- Do not use when the control is a persistent setting, such as "Dark theme" (use `switch.basic`).
- Do not use when the control records a value submitted with a form (use `checkbox.basic`).
- Do not use when two to five related options form one connected control (use `segmented-button.basic`).
- Do not use when the control filters a set of results (use `chip.filter`).

## Must Haves
- The control reports its on or off state, a name, and a click action. Material's `IconToggleButton`, `FilledIconToggleButton`, `FilledTonalIconToggleButton`, and `OutlinedIconToggleButton` are the reference implementation, reporting `Role.Checkbox` and a checked state with a 48dp target; an `IconButton` that swaps its icon reports no state at all (`global.native-first`).
- Name the control for what it turns on (e.g., "Favorite", "Mute") with `contentDescription` on its `Icon`, which the toggle merges into its own name (`global.icon`).
- Keep the name the same in both states. The control already reports checked or not checked, so a name that also changes ("Unmute" while checked) states the condition twice, in contradictory words.
- Word the name so it reads true when checked. A checked "Mute" means the sound is off.
- Show the checked state by more than its color. The standard `IconToggleButton` changes only the icon's color, so swap the icon as well (e.g., an outlined heart for a filled one). `OutlinedIconToggleButton` drops its border and fills its container when checked, which carries the state on its own (`global.use-of-color`).
- If the toggle is unavailable, pass `enabled = false` rather than removing the handler, so it stays in the accessibility tree and reports that it is disabled.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not change `contentDescription` with the state. The announcement then pairs the next action with the current state, such as "Unmute" with "checked".
- Do not build a toggle from an `IconButton` that swaps its icon on each tap. It looks the same and reports a button with no state, so a TalkBack user cannot tell whether the feature is on.
- Do not set `contentDescription` on both the toggle button and its `Icon`. Both reach the merged node, and the control announces its name twice.
- Do not nest a toggle button inside a clickable row or card. A child that merges is not absorbed by a parent that merges, so the two compete for the same taps (`global.merge-semantics`).

## Customizable
- Any of the four icon toggle skins is acceptable. They share one role and one set of semantics and differ in container and border treatment.
- A toggle may show a text label instead of an icon, built the way Material builds its filled toggles: a `Surface` taking `checked` and `onCheckedChange`, with `Modifier.semantics { role = Role.Checkbox }`. The text is the name and stays the same in both states. `ToggleButton`, Material's text toggle, is not in its stable API.
- Toggles in a toolbar may be laid out in any order, each with its own name and state.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun ToggleButtonExamples() {
    var favorite by remember { mutableStateOf(false) }
    var bold by remember { mutableStateOf(false) }
    var italic by remember { mutableStateOf(false) }

    IconToggleButton(
        checked = favorite,
        onCheckedChange = { favorite = it }
    ) {
        Icon(
            if (favorite) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
            contentDescription = "Favorite"
        )
    }

    Row {
        OutlinedIconToggleButton(
            checked = bold,
            onCheckedChange = { bold = it }
        ) {
            Icon(Icons.Filled.FormatBold, contentDescription = "Bold")
        }
        OutlinedIconToggleButton(
            checked = italic,
            onCheckedChange = { italic = it }
        ) {
            Icon(Icons.Filled.FormatItalic, contentDescription = "Italic")
        }
    }
}
```
