---
id: chip.input
title: Input Chip
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [chip, input chip, token, removable, entered value, tag]
aliases: [InputChip, input chip, token, removable chip, removable tag, recipient chip, entity chip, tag input, CustomAccessibilityAction]
summary: Chip standing for a value the user entered, such as a recipient or a tag, that can be selected and removed. Material's InputChip is a single click target, and its trailing icon is content rather than a button, so removal is the caller's to build, as a remove button inside the chip plus a Remove action on it.
---

# Input Chip

Pattern ID: `chip.input`

Chip standing for a value the user entered, such as a recipient or a tag, that can be selected and removed. Material's `InputChip` is a single click target, and its trailing icon is content rather than a button, so removal is the caller's to build, as a remove button inside the chip plus a Remove action on it.

## Use When
- Use when values the user entered are shown as tokens they can select and remove (e.g., recipients in a "To" field, tags added to a photo).

## Do Not Use When
- Do not use when the chip filters content (use `chip.filter`).
- Do not use when the chip performs an action (use `button.basic`, which covers assist and suggestion chips).
- Do not use when tapping the token does something other than select it, such as opening its details (use `button.basic` with an `AssistChip`, and add removal the same way).

## Must Haves
- The chip reports its label, its selected state, a click action, and a remove action. Material's `InputChip` is the reference implementation of the first three, reporting `Role.Checkbox` and a selected state on a selectable surface with a 48dp target. Its `trailingIcon` slot is content, not a control: an icon placed there joins the chip's name and does nothing when tapped on its own (`global.native-first`).
- Give the chip a remove button of its own in the `trailingIcon` slot: a box at least 24dp square carrying `Modifier.clickable(role = Role.Button)`, holding a close `Icon` named for what it removes (e.g., "Remove Alex Rivera"), which the button merges into its own name. TalkBack meets it as its own stop after the chip, the way Android's View-based Material chip exposes its close icon. The chip is too short for a 48dp target inside it, so 24dp is the floor (`global.touch-target-size`, `global.icon`).
- This is the one place a control nests inside another on purpose. The remove button is visibly separate and named for what it acts on, so it stands as its own target rather than competing with the chip (`global.merge-semantics`).
- Also expose removal as a `CustomAccessibilityAction` labeled "Remove" in the chip's `customActions`, so a TalkBack user on the chip can remove it from the actions menu without moving to the button.
- Name the chip with its visible label. Give an avatar or leading icon `contentDescription = null` when it shows the person or thing the label names (`global.icon`).
- When a chip is removed, move focus to a neighboring chip or to the text field the chips belong to. The removed chip takes focus with it, which leaves a keyboard or TalkBack user nowhere (`global.focus-management`).
- Name the set of chips on its container with `Modifier.semantics { contentDescription = "..." }` (e.g., "Recipients") (`global.collection-semantics`).
- Keep the selected state visible by more than color. `InputChip` drops its border and fills its container when selected; keep that border change when restyling it (`global.use-of-color`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not hide the remove button from TalkBack with `clearAndSetSemantics {}` and rely on the custom action alone. A user who does not know the actions menu has no way to find it.
- Do not use an `IconButton` as the remove button. It reserves a 48dp box, which stretches the chip.
- Do not name the close icon without making it a button. It then joins the chip's name ("Alex Rivera, Remove Alex Rivera"), and tapping it only selects the chip.
- Do not remove the chip on its main click. `InputChip` reports a selected state on every chip, so TalkBack announces a selection the tap does not make.
- Do not remove a chip without moving focus somewhere deliberate.

## Customizable
- The chip may show an avatar or a leading icon, which `InputChip` places before the label.
- A chip that has keyboard focus may also be removed with Backspace or Delete, through `Modifier.onKeyEvent` on the chip.
- Removal may also be announced ("Alex Rivera removed") through a polite live region, in addition to moving focus.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun InputChipExamples() {
    val recipients = remember { mutableStateListOf("Alex Rivera", "Sam Chen") }
    val selected = remember { mutableStateListOf<String>() }
    val fieldFocus = remember { FocusRequester() }
    var entry by remember { mutableStateOf("") }

    Column {
        FlowRow(modifier = Modifier.semantics { contentDescription = "Recipients" }) {
            recipients.forEach { name ->
                val remove = {
                    recipients.remove(name)
                    selected.remove(name)
                    fieldFocus.requestFocus()
                }
                InputChip(
                    selected = name in selected,
                    onClick = {
                        if (name in selected) selected.remove(name) else selected.add(name)
                    },
                    label = { Text(name) },
                    trailingIcon = {
                        Box(
                            modifier = Modifier
                                .size(24.dp)
                                .clickable(role = Role.Button) { remove() },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                Icons.Filled.Close,
                                contentDescription = "Remove $name",
                                modifier = Modifier.size(InputChipDefaults.IconSize)
                            )
                        }
                    },
                    modifier = Modifier.semantics {
                        customActions = listOf(
                            CustomAccessibilityAction("Remove") { remove(); true }
                        )
                    }
                )
            }
        }

        TextField(
            value = entry,
            onValueChange = { entry = it },
            label = { Text("Add recipient") },
            modifier = Modifier.focusRequester(fieldFocus)
        )
    }
}
```
