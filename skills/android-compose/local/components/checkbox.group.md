---
id: checkbox.group
title: Checkbox Group
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [checkbox, checkbox group, group, multiple choice, selection, form-control]
aliases: [checkbox list, multiple checkboxes, check all that apply, multi-select, CollectionInfo, CollectionItemInfo, toggleable group]
summary: Several checkboxes that together answer one question, any number of them checked. Nothing on Android ties a label to a set of controls, and selectableGroup does nothing for checkboxes, so the set's name, its position information, and its one group-level error are all the caller's.
---

# Checkbox Group

Pattern ID: `checkbox.group`

Several checkboxes that together answer one question, any number of them checked. Nothing on Android ties a label to a set of controls, and `selectableGroup` does nothing for checkboxes, so the set's name, its position information, and its one group-level error are all the caller's.

## Use When
- Use when several checkboxes together answer one question and each option's label is not meaningful without it (e.g., "How should we contact you?" with "Email", "Text message", "Phone call").
- Use when the user may check none, one, or several of the options, and the set may need one requirement checked as a whole (e.g., "Select at least one").

## Do Not Use When
- Do not use when a single checkbox stands on its own (use `checkbox.basic`).
- Do not use when exactly one option may be chosen (use `radio.basic`).
- Do not use when a parent checkbox checks or clears the whole set (use `checkbox.tristate`).
- Do not use when two to five short options sit side by side as one connected control (use `segmented-button.basic`).
- Do not use when the options filter a set of results (use `chip.filter`).

## Must Haves
- Build each option as a checkbox row, as `checkbox.basic` describes: the row carries `Modifier.toggleable(role = Role.Checkbox)`, the `Checkbox` inside it `onCheckedChange = null`, and the row is at least 48dp tall.
- Give the set a visible label that states its question, marked with `heading()`, and name the container holding the options with `Modifier.semantics { contentDescription = "..." }` matching it. Nothing associates a visible label with a set of controls on Android, so a user who reaches the options by any route other than the label does not otherwise hear the question (`global.collection-semantics`, `global.headings`).
- Declare the set on the container with `collectionInfo = CollectionInfo(rowCount = count, columnCount = 1)`, and each option's place with `collectionItemInfo = CollectionItemInfo(rowIndex = index, rowSpan = 1, columnIndex = 0, columnSpan = 1)` on its row. `selectableGroup()` derives position only from selectable children, so it adds nothing to checkbox rows (`global.collection-semantics`).
- Put a group-level hint (e.g., "Select at least one") in visible text after the label and before the first option, so it is read on the way into the set. Compose has nothing that attaches a hint to each option.
- When the set's requirement is not met, show one error for the whole set, in visible text after the label, and announce it once by making that text a polite live region (`global.announcements`). Check the requirement when the form is submitted, not as each option changes, and leave focus where it is.
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not add `selectableGroup()` to the container to report the set. It compiles, adds nothing for checkboxes, and looks like the fix.
- Do not set `error()` on every option for a requirement that belongs to the set. The user hears the same error at each stop.
- Do not give the options radio semantics or `Modifier.selectable`. Checkboxes allow several choices, and `Role.RadioButton` tells the user only one counts.
- Do not make the container clickable or set `mergeDescendants` on it. The options collapse into one stop and can no longer be checked one at a time (`global.merge-semantics`).
- Do not combine unrelated questions in one set; give each question its own container and name.

## Customizable
- The options may be laid out in a column, a grid, or a wrapping flow, provided the collection properties report their real rows and columns.
- The hint may be left out when the set has no requirement.
- The visible label may be a heading or plain text styled as a label, provided the container's `contentDescription` matches it.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun CheckboxGroupExamples(showError: Boolean) {
    val methods = listOf("Email", "Text message", "Phone call")
    val checked = remember { mutableStateListOf(false, false, false) }

    Column {
        Text(
            "How should we contact you?",
            modifier = Modifier.semantics { heading() }
        )
        Text("Select at least one.")
        if (showError) {
            Text(
                "Choose at least one way to contact you.",
                modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite }
            )
        }

        Column(
            modifier = Modifier.semantics {
                contentDescription = "How should we contact you?"
                collectionInfo = CollectionInfo(rowCount = methods.size, columnCount = 1)
            }
        ) {
            methods.forEachIndexed { index, method ->
                Row(
                    modifier = Modifier
                        .toggleable(
                            value = checked[index],
                            onValueChange = { checked[index] = it },
                            role = Role.Checkbox
                        )
                        .heightIn(min = 48.dp)
                        .fillMaxWidth()
                        .semantics {
                            collectionItemInfo = CollectionItemInfo(
                                rowIndex = index,
                                rowSpan = 1,
                                columnIndex = 0,
                                columnSpan = 1
                            )
                        },
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(checked = checked[index], onCheckedChange = null)
                    Text(method)
                }
            }
        }
    }
}
```
