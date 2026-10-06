---
id: dialog.alert
title: Dialog (Alert)
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [dialog, alert, modal, confirmation, interruption]
aliases: [AlertDialog, BasicAlertDialog, alert, confirm dialog, confirmation dialog, modal dialog, popup dialog, are you sure]
summary: Modal message that interrupts to ask for a decision or report something the user must acknowledge. Material's dialog window blocks the screen and closes on back and Escape, but announces itself only as a generic "Dialog", so the title has to be the first thing the user lands on.
---

# Dialog (Alert)

Pattern ID: `dialog.alert`

Modal message that interrupts to ask for a decision or report something the user must acknowledge. Material's dialog window blocks the screen and closes on back and Escape, but announces itself only as a generic "Dialog", so the title has to be the first thing the user lands on.

`AlertDialog` and `BasicAlertDialog` render in a separate dialog window, so focus containment and the inert background come free, and back, Escape, and a tap outside all call `onDismissRequest`. The pane title Material sets is the localized word "Dialog", not the dialog's own title. The user hears that it is a dialog, and what it is about only when TalkBack reaches the first piece of content, which makes the content order part of the contract.

## Use When
- Use when the user must confirm or cancel an action before it happens, especially a destructive one (e.g., "Delete 3 photos?").
- Use when the app must report something the user has to acknowledge before continuing (e.g., "Your session expired").

## Do Not Use When
- Do not use when the message reports something without requiring a response (use `snackbar.basic`).
- Do not use when the message offers an optional action the user may ignore (use `snackbar.action`).
- Do not use when the surface holds a form, a list, or several controls the user works through (use `bottom-sheet.modal`).
- Do not use when the user picks from a list of commands (use `menu.basic`).

## Must Haves
- The dialog blocks the content behind it, contains focus, and closes on back, Escape, and a tap outside it. Material's `AlertDialog` is the reference implementation, through its dialog window and default `DialogProperties`; `BasicAlertDialog` meets the same contract with a layout the caller supplies (`global.native-first`).
- Give the dialog a title stating the question or the fact, as the first content the user reaches (e.g., "Delete 3 photos?"). Material announces only "Dialog" on open, so the title is where the user learns what the dialog is about.
- Give the `icon` slot's `Icon` `contentDescription = null`. The icon renders before the title, and a named icon puts its name first, ahead of the title.
- Label each button with what it does (e.g., "Delete" and "Cancel"), never "OK", "Yes", or "No". The buttons are read without the question in front of them.
- Make `onDismissRequest` do exactly what the dismiss button does, and never the confirming action. Back, Escape, and a tap outside all call it.
- Leave initial focus to the dialog. It opens in its own window, which takes input focus without a `FocusRequester`, and with the icon decorative the title is the first content TalkBack reaches. Do not request focus on a button when the dialog opens: it skips the title and leaves a destructive action one keypress away (`global.focus-management`).
- Restore input focus to the control that opened the dialog when it closes, by holding a `FocusRequester` for the trigger and requesting it on dismissal (`global.focus-management`).
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not route `onDismissRequest` to the confirming action. A user pressing back to get away would delete the photos.
- Do not put the question only in the `text` slot and leave the title generic, such as "Warning" or "Are you sure?". The title is the part the user lands on.
- Do not set `dismissOnBackPress = false` without a visible dismiss button. Back and Escape are then the only exits a keyboard or switch user has, and both are gone.
- Do not use an alert for a message that needs no decision. Interrupting with a dialog for "Saved" takes focus away from what the user was doing.
- Do not signal a destructive action by coloring the confirm button red alone. The label says "Delete" (`global.use-of-color`).
- Do not put a text field, a list, or other controls in an alert. A dialog that asks the user to fill something in is a bottom sheet or a full screen.

## Customizable
- `AlertDialog` supplies the slots and their order. `BasicAlertDialog` takes free-form content, which then carries the ordering duties itself: decorative icon, then the title, then the text, then the buttons with the dismiss button first.
- `dismissOnClickOutside = false` may be set for a decision the user must make deliberately. Back and Escape still close the dialog through `onDismissRequest`.
- `DialogProperties(windowTitle = ...)` may be set to the title text, which names the dialog's window. Whether TalkBack speaks it in place of Material's generic "Dialog" is not yet verified on a device.
- The confirm button may use a filled or tonal style and the dismiss button a text style. Emphasis is visual; both labels carry the meaning.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun AlertDialogExamples() {
    var open by remember { mutableStateOf(false) }
    val triggerFocus = remember { FocusRequester() }

    fun dismiss() {
        open = false
        triggerFocus.requestFocus()
    }

    Button(
        onClick = { open = true },
        modifier = Modifier.focusRequester(triggerFocus)
    ) {
        Text("Delete selected")
    }

    if (open) {
        AlertDialog(
            onDismissRequest = { dismiss() },
            icon = { Icon(Icons.Outlined.Delete, contentDescription = null) },
            title = { Text("Delete 3 photos?") },
            text = { Text("They will be removed from all your devices.") },
            dismissButton = {
                TextButton(onClick = { dismiss() }) { Text("Cancel") }
            },
            confirmButton = {
                TextButton(onClick = { /* delete */ dismiss() }) { Text("Delete") }
            }
        )
    }
}
```
