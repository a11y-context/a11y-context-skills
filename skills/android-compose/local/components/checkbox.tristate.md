---
id: checkbox.tristate
title: Tri-State Checkbox
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [checkbox, tristate, indeterminate, select all, parent checkbox, selection]
aliases: [TriStateCheckbox, triStateToggleable, ToggleableState, indeterminate checkbox, mixed checkbox, partially checked, select all, parent checkbox, nested checkboxes]
summary: Parent checkbox that checks or clears a set of child checkboxes and shows partially checked when only some of them are. Compose reports the third state as "Partially checked" without being asked; the parent's state has to be derived from its children rather than stored.
---

# Tri-State Checkbox

Pattern ID: `checkbox.tristate`

Parent checkbox that checks or clears a set of child checkboxes and shows partially checked when only some of them are. Compose reports the third state as "Partially checked" without being asked; the parent's state has to be derived from its children rather than stored.

## Use When
- Use when one checkbox checks or clears a set of related checkboxes beneath it and shows whether all, some, or none of them are checked (e.g., "All toppings" above "Cheese", "Mushrooms", "Olives").

## Do Not Use When
- Do not use when a checkbox stands on its own (use `checkbox.basic`), or sits in a set with no parent controlling it (use `checkbox.group`).
- Do not use when the third state is a value the user picks directly, such as include, exclude, or ignore (use `radio.basic` or `segmented-button.basic`).

## Must Haves
- The parent reports `Role.Checkbox`, one of three states, and a click action. Material's `TriStateCheckbox` is the reference implementation, through `Modifier.triStateToggleable`: checked and unchecked read as they do for any checkbox, and Compose supplies "Partially checked" as the third state's description. A `Checkbox` drawn with a dash reports only two states (`global.native-first`).
- Put the parent's box and label in a row that carries `Modifier.triStateToggleable(state = parentState, onClick = onParentClick, role = Role.Checkbox)`, and set the `TriStateCheckbox`'s own `onClick = null`. The whole row then toggles, and TalkBack reads it as one control.
- Size that row to at least 48dp. `TriStateCheckbox` applies the minimum only while it owns its callback, so hoisting the click to the row moves the obligation to the row (`global.touch-target-size`).
- Derive the parent's state from the children each time it is read: checked when all of them are, unchecked when none are, partially checked otherwise. A parent state stored separately goes stale the first time a child changes.
- When the parent is activated, set every child to match its new state: checking the parent checks them all, and clearing it clears them all. From partially checked, the default is to check every child.
- Name the parent for the set it controls (e.g., "All toppings"), not "Select all". TalkBack reads the parent's name and state with nothing else, so "Select all" does not say of what, and a screen with two such sets has two identical controls.
- Place the children directly after the parent in traversal order, each one a checkbox row built as `checkbox.basic` describes.
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not show the partially checked state by drawing a dash in a `Checkbox`. The control then reports checked or not checked while showing something else.
- Do not leave `onClick` on the `TriStateCheckbox` while the row is also toggleable. Both become click targets, and TalkBack reports two controls.
- Do not nest the children inside the parent's toggleable row. A child that merges is not absorbed by a parent that merges, so each child competes with the parent for the same taps (`global.merge-semantics`).
- Do not make the parent a live region to announce changes made through a child. TalkBack already reads the child's new state, and the parent's updated state is there when the user returns to it.

## Customizable
- The children may be indented beneath the parent or laid out flush with it, provided they follow it in traversal order.
- The parent may report a count in place of "Partially checked", such as "2 of 3 selected", by setting `stateDescription` only while its state is indeterminate. Set in every state, it also replaces checked and not checked (`global.state-description`).
- Activating the parent may step through three states instead of two: unchecked, then the mix of children the user last chose, then checked. The restored mix has to be one the user set, and the parent's state is still derived from the children.
- Sets may nest: a child may itself be the parent of a smaller set, provided each parent derives its state from its own children.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun TriStateCheckboxExamples() {
    val toppings = listOf("Cheese", "Mushrooms", "Olives")
    val checked = remember { mutableStateListOf(true, false, false) }
    val parentState = when {
        checked.all { it } -> ToggleableState.On
        checked.none { it } -> ToggleableState.Off
        else -> ToggleableState.Indeterminate
    }

    Column {
        Row(
            modifier = Modifier
                .triStateToggleable(
                    state = parentState,
                    onClick = {
                        val checkAll = parentState != ToggleableState.On
                        checked.indices.forEach { checked[it] = checkAll }
                    },
                    role = Role.Checkbox
                )
                .heightIn(min = 48.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TriStateCheckbox(state = parentState, onClick = null)
            Text("All toppings")
        }

        Column(modifier = Modifier.padding(start = 32.dp)) {
            toppings.forEachIndexed { index, topping ->
                Row(
                    modifier = Modifier
                        .toggleable(
                            value = checked[index],
                            onValueChange = { checked[index] = it },
                            role = Role.Checkbox
                        )
                        .heightIn(min = 48.dp)
                        .fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(checked = checked[index], onCheckedChange = null)
                    Text(topping)
                }
            }
        }
    }
}
```
