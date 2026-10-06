---
id: segmented-button.basic
title: Segmented Button
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [segmented button, segmented control, single choice, multiple choice, selection, view switcher]
aliases: [SegmentedButton, SingleChoiceSegmentedButtonRow, MultiChoiceSegmentedButtonRow, segmented control, single-select segmented button, multi-select segmented button, toggle group, button group, view switcher]
summary: Row of two to five connected options, with exactly one selected or any number on at once. Material's single-choice segments report radio semantics and their position in the set; its multiple-choice segments report a checked state with no role and no position, so the caller adds both, and names the row either way.
---

# Segmented Button

Pattern ID: `segmented-button.basic`

Row of two to five connected options, with exactly one selected or any number on at once. Material's single-choice segments report radio semantics and their position in the set; its multiple-choice segments report a checked state with no role and no position, so the caller adds both, and names the row either way.

## Use When
- Use when the user chooses from two to five short options that stay visible together as one connected control.
- Use when exactly one option applies at a time, in a single-choice row (e.g., "Day", "Week", "Month"), or any number may be on, in a multiple-choice row (e.g., "Walk", "Bike", "Transit" as the ways a route may travel).
- Use when the choice takes effect immediately, such as changing how the content below is shown or sorted.

## Do Not Use When
- Do not use when there are more than five options or the labels are too long to fit side by side (use `radio.basic` or `checkbox.group`, or `select.basic` for a compact control).
- Do not use when each option opens its own pane of content, such as the sections of a profile (use `tabs.basic`).
- Do not use when the options filter a set of results (use `chip.filter`).
- Do not use when each control turns its own feature on and off, such as formatting in a toolbar (use `button.toggle`).
- Do not use when the control is a single on or off choice (use `switch.basic`).

## Must Haves
- Choose the row by how many options may be on: `SingleChoiceSegmentedButtonRow` when exactly one applies, `MultiChoiceSegmentedButtonRow` when any number may. The row decides what each segment reports: a single-choice segment reports `Role.RadioButton` and its selected state, a multiple-choice segment its checked state. Material's `SegmentedButton` is the reference implementation of both, with a 48dp target (`global.native-first`).
- In a single-choice row, ship with one segment selected, and keep it selected when the user activates it again. The segments report radio semantics, and a radio set has no state with nothing chosen. The row applies `selectableGroup()`, from which Compose derives each segment's position.
- In a multiple-choice row, pass `Modifier.semantics { role = Role.Checkbox }` to each segment. Material's multiple-choice segment sets no role, unlike the single-choice one.
- In a multiple-choice row, declare the set on the row with `collectionInfo = CollectionInfo(rowCount = 1, columnCount = count)`, and each segment's place with `collectionItemInfo = CollectionItemInfo(rowIndex = 0, rowSpan = 1, columnIndex = index, columnSpan = 1)`. `MultiChoiceSegmentedButtonRow` sets neither, so without them the row reports nothing of the set the single-choice row reports (`global.collection-semantics`).
- Name the row with `Modifier.semantics { contentDescription = "..." }` on the row, matching a visible label above or beside it (e.g., "Calendar view"), so a user entering the row hears what it chooses (`global.collection-semantics`).
- Give each segment a short text label, which becomes its name. A segment showing only an icon is named with `contentDescription` on its `Icon` (`global.icon`).
- Keep the check mark `SegmentedButton` draws on a selected or checked segment by default, or another icon shown only in that state. Passing `icon = {}`, or an icon shown in both states, leaves the state marked by the container color alone (`global.use-of-color`).
- If an option is unavailable, pass `enabled = false` to its segment, so it stays in the accessibility tree and reports that it is disabled.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not use the multiple-choice row and enforce a single choice in code, or the single-choice row and allow several. Each row's segments report its own kind of choice, so TalkBack describes a choice the row does not make.
- Do not add `selectableGroup()` to a multiple-choice row to report the set. Compose derives position from it only for selectable children, so checked segments gain nothing, and the modifier looks like the fix.
- Do not clear a single-choice selection when the selected segment is activated again.
- Do not build the row from `Button`s or clickable boxes in a `Row`. They report buttons with no selected or checked state and no position in the set.

## Customizable
- A multiple-choice row may start with none of its options on.
- A segment may show text, an icon, or both. With both, the icon is decorative and the text is the name.
- The row's visible label may sit above or beside it, provided its text matches the row's `contentDescription`.
- Colors come from `SegmentedButtonDefaults.colors()`, drawn from the theme's color scheme (`global.semantic-color`).

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun SegmentedButtonExamples() {
    val views = listOf("Day", "Week", "Month")
    var selectedView by remember { mutableIntStateOf(0) }
    val modes = listOf("Walk", "Bike", "Transit")
    val checkedModes = remember { mutableStateListOf(true, false, true) }

    Column {
        // Single choice: the row supplies radio semantics and each segment's position.
        Text("Calendar view")
        SingleChoiceSegmentedButtonRow(
            modifier = Modifier.semantics { contentDescription = "Calendar view" }
        ) {
            views.forEachIndexed { index, view ->
                SegmentedButton(
                    selected = index == selectedView,
                    onClick = { selectedView = index },
                    shape = SegmentedButtonDefaults.itemShape(index = index, count = views.size)
                ) {
                    Text(view)
                }
            }
        }

        // Multiple choice: the role and each segment's position are set by hand.
        Text("Travel modes")
        MultiChoiceSegmentedButtonRow(
            modifier = Modifier.semantics {
                contentDescription = "Travel modes"
                collectionInfo = CollectionInfo(rowCount = 1, columnCount = modes.size)
            }
        ) {
            modes.forEachIndexed { index, mode ->
                SegmentedButton(
                    checked = checkedModes[index],
                    onCheckedChange = { checkedModes[index] = it },
                    shape = SegmentedButtonDefaults.itemShape(index = index, count = modes.size),
                    modifier = Modifier.semantics {
                        role = Role.Checkbox
                        collectionItemInfo = CollectionItemInfo(
                            rowIndex = 0,
                            rowSpan = 1,
                            columnIndex = index,
                            columnSpan = 1
                        )
                    }
                ) {
                    Text(mode)
                }
            }
        }
    }
}
```
