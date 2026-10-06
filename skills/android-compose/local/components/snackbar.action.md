---
id: snackbar.action
title: Snackbar with Action
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [snackbar, toast, undo, action, notification, live region]
aliases: [Snackbar, SnackbarHost, showSnackbar, actionLabel, undo snackbar, toast with action, action snackbar, retry message]
summary: Brief message carrying one action, such as Undo, shown without taking focus. Because focus never moves to it, its action is hard to reach from a keyboard and easy to miss with TalkBack, so the action must also be available somewhere else and the message must stay until dismissed.
---

# Snackbar with Action

Pattern ID: `snackbar.action`

Brief message carrying one action, such as Undo, shown without taking focus. Because focus never moves to it, its action is hard to reach from a keyboard and easy to miss with TalkBack, so the action must also be available somewhere else and the message must stay until dismissed.

The live region announces the message and nothing more. A TalkBack user hears "Message archived" and has to go looking for the Undo button at the bottom of the screen; a keyboard user has to tab to it from wherever focus was. Material already guards half of this: `showSnackbar` defaults an action snackbar to `SnackbarDuration.Indefinite`, so the action does not vanish while the user is on the way to it. The other half is the app's to supply.

## Use When
- Use when a brief message reports something the user did and offers one optional action on it (e.g., "Message archived" with "Undo", "Upload failed" with "Retry").
- Use when the user can safely ignore both the message and the action.

## Do Not Use When
- Do not use when the message needs no action (use `snackbar.basic`).
- Do not use when the user must decide before continuing (use `dialog.alert`).
- Do not use when the action is the only way to do something important, such as the only route to recover deleted work. Put it where the user can find it again.

## Must Haves
- The message is announced without moving focus, can be dismissed without a gesture, and stays until the user dismisses it. Material's `SnackbarHost` is the reference implementation of that contract, with `showSnackbar`'s default `SnackbarDuration.Indefinite` for a message that has an action (`global.native-first`).
- Make the action available somewhere else in the interface too, such as an Undo control on the screen itself, an entry in the screen's overflow menu, or a restore option on the archived item. Focus never moves to the snackbar, so the user may never reach its button.
- Show the message through `SnackbarHostState.showSnackbar` with an `actionLabel`, and keep the default duration, which is `SnackbarDuration.Indefinite` for a message with an action.
- Pass `withDismissAction = true`, so a message that stays until dismissed has a visible close control as well as its accessibility `dismiss` action.
- Label the action with what it does (e.g., "Undo", "Retry", "View"), not with its outcome.
- Carry one action. A second command belongs somewhere the user navigates to, not in a message they may not reach.
- Handle both results of `showSnackbar`: run the action on `SnackbarResult.ActionPerformed`, and treat `SnackbarResult.Dismissed` as the user declining it.
- Leave focus where it is when the message appears (`global.focus-management`).

## Don'ts
- Do not set `SnackbarDuration.Short` or `SnackbarDuration.Long` on an action snackbar. The message can leave before a TalkBack or switch user gets to the action.
- Do not move focus to the snackbar to make the action reachable. It interrupts the user, and the action belongs elsewhere as well anyway.
- Do not make the snackbar the only route to an action. A user who missed it cannot get it back.
- Do not render a `Snackbar` directly with its own `action` slot. Outside `SnackbarHost` it is not announced and has no dismiss action.
- Do not word the message so it only makes sense with the action (e.g., "Undo?"). The message is announced on its own.

## Customizable
- The action may also be offered through a keyboard shortcut, such as Ctrl+Z for Undo, in addition to the other route in the interface.
- The message may sit in the default position at the bottom of the `Scaffold`, or in a `SnackbarHost` placed elsewhere, provided it is still a `SnackbarHost`.
- `Snackbar` colors and shape may follow the brand through the host's `snackbar` slot, which keeps the host's semantics.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun SnackbarActionExamples(onArchive: () -> Unit, onUnarchive: () -> Unit) {
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    var canUndo by remember { mutableStateOf(false) }

    Scaffold(
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) }
    ) { padding ->
        Column(Modifier.padding(padding)) {
            Button(onClick = {
                onArchive()
                canUndo = true
                scope.launch {
                    val result = snackbarHostState.showSnackbar(
                        message = "Message archived",
                        actionLabel = "Undo",
                        withDismissAction = true
                    )
                    if (result == SnackbarResult.ActionPerformed) {
                        onUnarchive()
                        canUndo = false
                    }
                }
            }) {
                Text("Archive")
            }

            if (canUndo) {
                TextButton(onClick = {
                    onUnarchive()
                    canUndo = false
                    snackbarHostState.currentSnackbarData?.dismiss()
                }) {
                    Text("Undo archive")
                }
            }
        }
    }
}
```
