---
id: select.basic
title: Select
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [select, dropdown, picker, single choice, form-control, value chooser]
aliases: [ExposedDropdownMenuBox, ExposedDropdownMenu, exposed dropdown, exposed dropdown menu, dropdown list, drop-down, picker, spinner, combo box, menuAnchor]
summary: Field showing one chosen value that opens a list of the others. Material's ExposedDropdownMenuBox reports the field as a dropdown list and opens it from touch, TalkBack, and the keyboard, but its menu items report no selection, so marking the current option is the caller's. The component is still marked experimental, so the call site opts in.
---

# Select

Pattern ID: `select.basic`

Field showing one chosen value that opens a list of the others. Material's `ExposedDropdownMenuBox` reports the field as a dropdown list and opens it from touch, TalkBack, and the keyboard, but its menu items report no selection, so marking the current option is the caller's. The component is still marked experimental, so the call site opts in.

## Use When
- Use when the user chooses one value from a list too long to show inline, in a compact field that shows the current choice (e.g., "Season", "Country", "Time zone").
- Use when the field sits among other form fields, or above content it switches, and the list is only needed while choosing.

## Do Not Use When
- Do not use when two to five short options can stay visible (use `segmented-button.basic`, or `radio.basic` for a list).
- Do not use when the user types to narrow the options (use `combobox.autocomplete`).
- Do not use when the list holds commands rather than values (use `menu.basic`).
- Do not use when any number of options may be chosen (use `checkbox.group`).

## Must Haves
- The field reports that it opens a list of values, shows the current value, and opens and closes from touch, TalkBack, and the keyboard. Material's `ExposedDropdownMenuBox`, with a read-only `TextField` carrying `Modifier.menuAnchor(ExposedDropdownMenuAnchorType.PrimaryNotEditable)`, is the reference implementation: the anchor reports `Role.DropdownList` with a click action, and Enter and Space open it. A design system's own select satisfies it by setting `Role.DropdownList` and a click action on its field (`global.native-first`).
- Opt in with `@OptIn(ExperimentalMaterial3Api::class)` on the composable that builds the select. `ExposedDropdownMenuBox`, `ExposedDropdownMenu`, and `ExposedDropdownMenuDefaults` are still marked experimental in Material's current stable release; the opt-in is the only line that changes when they are stabilized.
- Pass `menuAnchor` its anchor type. The overload without one is deprecated, and `PrimaryNotEditable` is the type for a field the user cannot type into.
- Name the field with the `TextField`'s `label`, and show the current value as its text, so TalkBack reads what the field chooses and what is chosen (`text-field.basic`).
- Mark the current option in the open list with `Modifier.semantics { selected = true }` on its `DropdownMenuItem`, and set `selected = false` on the others. `DropdownMenuItem` reports no role and no selection, so without it the list does not say which value is in force.
- Show the current option by more than color, such as a check-mark `trailingIcon` on its item, given `contentDescription = null` (`global.use-of-color`, `global.icon`).
- Close the list when an option is chosen.
- If the field is unavailable, pass `enabled = false` to both `menuAnchor` and the `TextField`, so it stays in the accessibility tree and reports that it is disabled.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a select from a clickable `Text` that opens a `DropdownMenu` with nothing else. It reports no role and no value, so TalkBack users hear a label they can activate with no sign it chooses anything.
- Do not make the field editable for a fixed list. An editable field is a combobox, with typing and filtering of its own (`combobox.autocomplete`).
- Do not leave the trailing arrow named. `ExposedDropdownMenuDefaults.TrailingIcon` is decorative already; a custom arrow takes `contentDescription = null` (`global.icon`).
- Do not show the current value only by a highlight on its item in the open list.

## Customizable
- `TextField` or `OutlinedTextField` may be the anchor; the semantics come from `menuAnchor`, not the field style.
- A select may be built from a button showing the current value and a `DropdownMenu`, provided the button reports `Role.DropdownList`, its name includes the current value (e.g., "Season, Season 2"), and the current option is marked in the list.
- The list may open in a full-screen dialog instead of a menu when it is long, provided the dialog names itself, marks the current option, and returns focus to the field when it closes (`dialog.alert`, `global.focus-management`).

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SelectExamples() {
    val seasons = listOf("Season 1", "Season 2", "Season 3")
    var currentSeason by remember { mutableStateOf(seasons.first()) }
    var expanded by remember { mutableStateOf(false) }

    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it }
    ) {
        TextField(
            value = currentSeason,
            onValueChange = { },
            readOnly = true,
            label = { Text("Season") },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = Modifier.menuAnchor(ExposedDropdownMenuAnchorType.PrimaryNotEditable)
        )
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            seasons.forEach { season ->
                DropdownMenuItem(
                    text = { Text(season) },
                    onClick = {
                        currentSeason = season
                        expanded = false
                    },
                    trailingIcon = if (season == currentSeason) {
                        { Icon(Icons.Filled.Check, contentDescription = null) }
                    } else {
                        null
                    },
                    modifier = Modifier.semantics { selected = season == currentSeason }
                )
            }
        }
    }
}
```
