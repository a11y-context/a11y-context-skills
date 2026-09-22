---
id: bottom-sheet.modal
title: Bottom Sheet (Modal)
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [bottom sheet, modal, overlay, dialog, sheet]
aliases: [modal bottom sheet, ModalBottomSheet, bottom drawer, action sheet, sheet, slide-up panel, tray]
summary: Overlay that rises from the bottom edge and blocks the content behind it. Most of the dismissal contract arrives with the component rather than the caller, and every part of it disappears under some configuration the caller controls.
---

# Bottom Sheet (Modal)

Pattern ID: `bottom-sheet.modal`

Overlay that rises from the bottom edge and blocks the content behind it. Most of the dismissal contract arrives with the component rather than the caller, and every part of it disappears under some configuration the caller controls.

`ModalBottomSheet` already supplies most of the dismissal contract: scrim tap, back press, and a drag handle carrying named expand, collapse, and dismiss actions. Every one of them is conditional on a parameter the caller sets, so the requirements below are about keeping them rather than building them.

## Use When
- Use when the user needs a set of actions, a list, or a short form that belongs to the current screen and should not replace it (e.g., a share sheet, a filter panel, a sort menu).
- Use when the user will work through several controls before dismissing, and the content blocks interaction with the screen behind it while they do.

## Do Not Use When
- Do not use when the background must stay reachable while the sheet is open (use `bottom-sheet.standard`).
- Do not use when the content is a message the user acknowledges or answers with one of two choices, and nothing else. A sheet holds a set of things; a dialog interrupts with one (use `dialog.alert`).
- Do not use when the content is a list of commands acting on one trigger (use `menu.basic`).
- Do not use when the message reports an outcome and needs no response (use `snackbar.basic`).

## Must Haves
- The sheet blocks the content behind it, announces itself when it opens, and can be dismissed without a drag gesture. Material's `ModalBottomSheet` is the reference implementation, supplying the scrim, back-press dismissal, the pane-change announcement, and the drag handle's accessibility actions; anything else owes all four (`global.native-first`).
- Keep the default drag handle. It is `clickable` and carries named `expand`, `collapse`, and `dismiss` accessibility actions, which is the non-gesture route to every state change the sheet offers. Passing `dragHandle = null` removes all of them.
- Leave `skipHiddenState` at its default. The named `dismiss` action is added only when the hidden state is reachable, and without it double-tapping the handle collapses the sheet instead of closing it.
- Leave `sheetSwipeEnabled` at its default, or supply another route to every state the sheet can reach. The handle's expand, collapse, and dismiss actions are all conditional on the sheet having more than one anchor and on swipe being enabled.
- Handle Escape from a hardware keyboard with `Modifier.onKeyEvent`. Compose does not, and back-press dismissal does not cover a keyboard user.
- Move focus into the sheet when it opens, using a `FocusRequester` requested from a `LaunchedEffect` (`global.focus-management`).
- Restore focus to the control that opened the sheet when it closes.
- Mark the sheet's title as a heading so a user can find it after entering (`global.headings`).
- Make the sheet's content scrollable, and set `contentWindowInsets` so it clears the system bars. A sheet whose content is cut off at large font sizes has no route to the controls below the fold (`global.text-scaling`).

## Don'ts
- Do not disable both scrim dismissal and back-press dismissal. `shouldDismissOnClickOutside` and `shouldDismissOnBackPress` are the two routes that survive when the drag handle is absent, and turning off both leaves a sheet with no non-gesture exit.
- Do not replace the drag handle with a decorative bar. The default one carries the accessibility actions; a `Box` drawn to look like it carries none.
- Do not assume the pane-change announcement names this sheet. Material sets a generic pane title internally, so the announcement says a sheet opened and not which one, which is why the content needs a heading.
- Do not add a close button and treat it as the accessible dismissal while removing the handle. A close button is reachable only after focus has entered the sheet; the handle's dismiss action is reachable from the actions menu at any point inside it.
- Do not let the sheet's content run under the navigation bar. The last control becomes unreachable at the bottom of the scroll.

## Customizable
- A visible close button may be added alongside the drag handle. It is a convenience rather than a substitute, and it does not replace any Must Have above.
- Scrim dismissal may be turned off for a destructive confirmation, so the user must choose an action explicitly, as long as back press or the handle's dismiss action remains.
- The sheet may open partially expanded or fully expanded. Both are reachable through the handle's named actions, so the choice is presentational.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun BottomSheetModalExamples() {
    var open by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState()
    val focusRequester = remember { FocusRequester() }
    val triggerRequester = remember { FocusRequester() }
    val filters = remember {
        mutableStateListOf(Filter("In stock"), Filter("Free shipping"), Filter("On sale"))
    }

    Button(
        onClick = { open = true },
        modifier = Modifier.focusRequester(triggerRequester)
    ) {
        Text("Filter results")
    }

    if (open) {
        ModalBottomSheet(
            onDismissRequest = {
                open = false
                // Focus goes back to what opened the sheet. Compose does not do this.
                triggerRequester.requestFocus()
            },
            sheetState = sheetState,
            // Default drag handle kept: it carries the expand, collapse, and
            // dismiss accessibility actions. Passing null removes all three.
            contentWindowInsets = { WindowInsets.safeDrawing }
        ) {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .focusRequester(focusRequester)
                    .focusable()
                    // Compose ships no Escape handling for this component.
                    .onKeyEvent { event ->
                        if (event.key == Key.Escape) {
                            open = false
                            true
                        } else {
                            false
                        }
                    }
            ) {
                // The pane-change announcement is generic, so the heading is how
                // a user finds out which sheet this is.
                Text(
                    text = "Filter results",
                    modifier = Modifier.semantics { heading() }
                )

                // Real content, so focus lands on something. Each row follows
                // checkbox.basic: the row owns the toggle, the role, and the
                // 48dp target, and the Checkbox's own callback is null.
                filters.forEach { filter ->
                    Row(
                        modifier = Modifier
                            .toggleable(
                                value = filter.on,
                                onValueChange = { filter.on = it },
                                role = Role.Checkbox
                            )
                            .heightIn(min = 48.dp)
                            .fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Checkbox(checked = filter.on, onCheckedChange = null)
                        Text(filter.label)
                    }
                }
            }
        }

        LaunchedEffect(Unit) { focusRequester.requestFocus() }
    }
}
```
