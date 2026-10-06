---
id: menu.basic
title: Menu
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [menu, dropdown, overflow, commands, popup, actions]
aliases: [DropdownMenu, DropdownMenuItem, overflow menu, more menu, kebab menu, three-dot menu, context menu, action menu, popup menu, options menu]
summary: Pull-down list of commands opened from a button. Material's menu takes focus and closes on back and Escape on its own; its items carry no role, so each one's label has to stand on its own as a command.
---

# Menu

Pattern ID: `menu.basic`

Pull-down list of commands opened from a button. Material's menu takes focus and closes on back and Escape on its own; its items carry no role, so each one's label has to stand on its own as a command.

`DropdownMenu` is a focusable popup window, which is most of the contract: focus moves into it, the content behind it is out of reach, and back, Escape, and a tap outside all route to `onDismissRequest`. `DropdownMenuItem` is a plain clickable row with no role of its own.

## Use When
- Use when a button opens a short list of commands that act on the current screen or item (e.g., "Share", "Rename", "Delete" behind a "More options" button).
- Use when the commands are secondary and would crowd the screen if shown as buttons.

## Do Not Use When
- Do not use when the user picks a value that the control then displays (use `select.basic`).
- Do not use when the options navigate between top-level destinations (use `navigation-bar.basic`).
- Do not use when the user must choose before continuing and the choice needs explanation (use `dialog.alert`).
- Do not use when the list holds form fields, links to other screens, or headings. A menu holds commands.

## Must Haves
- The menu is a focusable popup that takes input focus when it opens and closes on back, Escape, and a tap outside it. Material's `DropdownMenu` is the reference implementation of that contract, through its default `PopupProperties(focusable = true)` (`global.native-first`).
- Name an overflow trigger "More options", through `contentDescription` on its `Icon`. It is the label Android uses for its own overflow control.
- When every row in a list carries its own menu, name each trigger for its row (e.g., "More options for Morning Mix"), or the triggers read alike (`button.basic`).
- Route every way of closing to `onDismissRequest`, and set the expanded state to `false` there. Back, Escape, and a tap outside the menu all call it; selecting an item does not, so each item's `onClick` closes the menu too.
- Move input focus to the first item when the menu opens, with a `FocusRequester` on that item requested from a `LaunchedEffect` inside the menu's content. The popup composes separately, so an effect in the parent can run before the item exists (`global.focus-management`).
- Restore input focus to the trigger when the menu closes, by holding a `FocusRequester` for the trigger and requesting it on dismissal (`global.focus-management`).
- Give each item a label that reads as a command out of context (e.g., "Rename playlist", not "Rename" beside nine other "Rename" buttons on the screen).
- Mark a destructive command by its label, not its color. "Delete" reads as destructive to every user; red text alone does not (`global.use-of-color`).
- Give an item that shows a check mark for an on or off setting a `stateDescription` on the item ("Checked" or "Not checked"), and give the check icon `contentDescription = null`. `DropdownMenuItem` reports no state of its own (`global.state-description`).
- Give leading and trailing icons on an item `contentDescription = null` when the item's text already names the command (`global.icon`).
- If a command is unavailable, pass `enabled = false` rather than removing the handler, so the control stays in the accessibility tree and reports that it is disabled.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not give the trigger `Role.DropdownList`. That role is for a control that chooses and displays a value, which is `select.basic`, and TalkBack announces it as one.
- Do not set `PopupProperties(focusable = false)` on a menu of commands. The popup then never takes focus, the user cannot reach the items from a keyboard, and back closes the screen behind it instead.
- Do not leave the menu open after an item runs its command. Close it in the item's `onClick`.
- Do not use a menu to hold a single command. One command is a button.
- Do not rely on item order to group commands. Use `HorizontalDivider` between groups so the separation is visible, and keep each label self-explanatory without it.

## Customizable
- The trigger may be an `IconButton`, a `TextButton`, or a list row's trailing control. Whatever it is, it carries the name.
- The trigger may also set `stateDescription` to "Expanded" or "Collapsed". Focus is inside the menu whenever it is open, so the collapsed state is the one users hear.
- Items may carry a leading icon, a trailing icon, or a trailing keyboard shortcut hint. All are decorative alongside the item's text.
- The menu may be anchored to its trigger or offset from it. Position has no effect on the contract.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun MenuExamples() {
    var expanded by remember { mutableStateOf(false) }
    var showLyrics by remember { mutableStateOf(true) }
    val triggerFocus = remember { FocusRequester() }
    val firstItemFocus = remember { FocusRequester() }

    fun close() {
        expanded = false
        triggerFocus.requestFocus()
    }

    Box {
        IconButton(
            onClick = { expanded = true },
            modifier = Modifier.focusRequester(triggerFocus)
        ) {
            Icon(Icons.Filled.MoreVert, contentDescription = "More options")
        }

        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { close() }
        ) {
            LaunchedEffect(Unit) { firstItemFocus.requestFocus() }

            DropdownMenuItem(
                text = { Text("Rename playlist") },
                onClick = { /* rename */ close() },
                leadingIcon = { Icon(Icons.Outlined.Edit, contentDescription = null) },
                modifier = Modifier.focusRequester(firstItemFocus)
            )
            DropdownMenuItem(
                text = { Text("Show lyrics") },
                onClick = { showLyrics = !showLyrics; close() },
                trailingIcon = {
                    if (showLyrics) Icon(Icons.Filled.Check, contentDescription = null)
                },
                modifier = Modifier.semantics {
                    stateDescription = if (showLyrics) "Checked" else "Not checked"
                }
            )
            HorizontalDivider()
            DropdownMenuItem(
                text = { Text("Delete playlist") },
                onClick = { /* delete */ close() },
                leadingIcon = { Icon(Icons.Outlined.Delete, contentDescription = null) }
            )
        }
    }
}
```
