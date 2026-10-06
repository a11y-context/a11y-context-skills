---
id: snackbar.basic
title: Snackbar
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [snackbar, toast, notification, status, message, live region]
aliases: [Snackbar, SnackbarHost, SnackbarHostState, showSnackbar, toast, status message, confirmation message, transient message]
summary: Brief message confirming something that already happened, shown at the bottom of the screen without taking focus. SnackbarHost supplies the announcement, the dismiss action, and the time extension a user can ask for; a Snackbar drawn outside it gets none of them.
---

# Snackbar

Pattern ID: `snackbar.basic`

Brief message confirming something that already happened, shown at the bottom of the screen without taking focus. `SnackbarHost` supplies the announcement, the dismiss action, and the time extension a user can ask for; a `Snackbar` drawn outside it gets none of them.

Everything accessible about a snackbar lives in `SnackbarHost`, not in `Snackbar`. While a message is showing, the host marks it as a polite live region, adds a `dismiss` accessibility action, and runs its duration through the system's recommended timeout, which lengthens it for a user who has asked for more time to read. The `Snackbar` composable itself sets none of that, so one rendered by hand behind a timer is silent to TalkBack and leaves on a schedule no user can change.

## Use When
- Use when a brief message confirms that something the user did has happened (e.g., "Draft saved", "Link copied").
- Use when the message needs no response and the user may ignore it.

## Do Not Use When
- Do not use when the message offers an action the user may want to take (use `snackbar.action`).
- Do not use when the user must respond before continuing (use `dialog.alert`).
- Do not use when the message reports an error in a field the user is filling in. Report it on the field (use `text-field.basic`).

## Must Haves
- The message is announced without moving focus, can be dismissed without a gesture, and stays on screen at least as long as the user's accessibility timeout asks. Material's `SnackbarHost` is the reference implementation of that contract, through a polite live region, a `dismiss` accessibility action, and a duration passed through the system's recommended timeout (`global.native-first`).
- Show the message through `SnackbarHostState.showSnackbar`, with the `SnackbarHost` placed in the screen's `Scaffold`.
- Leave focus where it is when the message appears (`global.focus-management`).
- Keep the message to one short sentence that makes sense without the screen around it (e.g., "Draft saved", not "Done").
- Use `SnackbarDuration.Short` or `SnackbarDuration.Long`. Both are lengthened for a user who has set a longer accessibility timeout.

## Don'ts
- Do not render a `Snackbar` directly, such as inside `AnimatedVisibility` with a `delay()` that hides it. It is then not announced, has no dismiss action, and ignores the user's timeout setting.
- Do not move focus to the message. It interrupts what the user was doing for something that needs nothing from them.
- Do not use `android.widget.Toast` in place of a snackbar. It is a different platform API from Material's, outside the screen's own content, and it cannot carry an action.
- Do not use a snackbar for anything the user has to see to continue. It leaves on its own.
- Do not show a message for each of a burst of actions. `showSnackbar` queues them, each waiting for the one before it to leave, so the user keeps hearing confirmations for things they finished long ago.

## Customizable
- The message may sit in the default position at the bottom of the `Scaffold`, or in a `SnackbarHost` placed elsewhere, provided it is still a `SnackbarHost`.
- `showSnackbar(withDismissAction = true)` may add a visible close control for a long message.
- `Snackbar` colors and shape may follow the brand through the host's `snackbar` slot, which keeps the host's semantics.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun SnackbarExamples() {
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    Scaffold(
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) }
    ) { padding ->
        Column(Modifier.padding(padding)) {
            Button(onClick = {
                /* save */
                scope.launch {
                    snackbarHostState.showSnackbar(
                        message = "Draft saved",
                        duration = SnackbarDuration.Short
                    )
                }
            }) {
                Text("Save draft")
            }
        }
    }
}
```
