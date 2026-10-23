---
id: navigation-drawer.modal
title: Navigation Drawer (Modal)
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [navigation drawer, drawer, side menu, navigation, overlay, modal]
aliases: [ModalNavigationDrawer, ModalDrawerSheet, NavigationDrawerItem, DrawerState, navigation drawer, side drawer, hamburger menu, nav drawer, side menu]
summary: Panel that slides over the screen holding the app's destinations, behind a scrim. Material's ModalNavigationDrawer names the panel and gives it a dismiss action and a scrim that closes it, but leaves the screen behind in the accessibility tree and does nothing with focus or keys, so containing TalkBack and the keyboard, Escape, and moving focus in and back are the caller's.
---

# Navigation Drawer (Modal)

Pattern ID: `navigation-drawer.modal`

Panel that slides over the screen holding the app's destinations, behind a scrim. Material's `ModalNavigationDrawer` names the panel and gives it a dismiss action and a scrim that closes it, but leaves the screen behind in the accessibility tree and does nothing with focus or keys, so containing TalkBack and the keyboard, Escape, and moving focus in and back are the caller's.

## Use When
- Use when the app's destinations are too many for a navigation bar, or are secondary, and open in a panel from a menu button (e.g., "Inbox", "Sent", "Drafts", "Settings").

## Do Not Use When
- Do not use when three to five top-level destinations stay visible along the bottom (use `navigation-bar.basic`).
- Do not use when the panel stays on screen beside the content (use `navigation-drawer.persistent`).
- Do not use when the panel holds commands rather than destinations (use `menu.basic` or `bottom-sheet.modal`).

## Must Haves
- The drawer is modal: while it is open it is the only thing TalkBack and the keyboard can reach, it announces itself by name, and it closes from the back gesture, Escape, the scrim, and TalkBack's dismiss action. Material's `ModalNavigationDrawer` with a `ModalDrawerSheet` supplies part of this: the pane title "Navigation menu", a dismiss action while open, back handling, and a scrim that TalkBack reaches as a control named "Close navigation menu". It leaves the screen behind in the accessibility tree and has no focus or key handling (`global.native-first`).
- While the drawer is open, remove the screen's content from the accessibility tree with `Modifier.clearAndSetSemantics {}` on the content's outermost composable, applied only while open. The content is covered by the scrim and cannot be tapped, so hiding it hides nothing a user can reach; the scrim stays in the tree as the way out (`global.merge-semantics`).
- Keep keyboard focus inside the drawer while it is open, with `Modifier.focusProperties { onExit = { if (drawerState.isOpen) cancelFocusChange() } }` followed by `Modifier.focusGroup()` on the `ModalDrawerSheet` (`global.focus-management`).
- When the drawer opens, move keyboard focus to the first destination with a `FocusRequester` requested from a `LaunchedEffect` once the drawer is open. Material's accessibility guidance puts initial focus on the first navigation item, the first interactive element in the drawer. When it closes without a choice, return focus to the menu button that opened it (`global.focus-management`).
- When a destination is chosen, close the drawer and place focus on the new screen as `global.screen-announcement` describes, rather than returning it to the menu button.
- Close the drawer on Escape with `Modifier.onKeyEvent` on the `ModalDrawerSheet`, as Material's Android guidance asks of every open drawer. `ModalNavigationDrawer` handles the back gesture and the back key and has no key handling of its own, the same gap `bottom-sheet.modal` closes for its sheet.
- Name the menu button that opens the drawer "Open navigation menu" on its `Icon`, the counterpart of Material's "Close navigation menu" on the scrim (`global.icon`).
- Build each destination with `NavigationDrawerItem`, which reports `Role.Tab` and a selected state, and put the items in a container with `Modifier.selectableGroup()` so each reports its position in the set (`global.collection-semantics`).
- Show the current destination by more than a hue change. When the items carry icons, use a filled icon for the current destination and outlined icons for the rest, as Material's guidance asks; `NavigationDrawerItem` also fills a container behind the current item, which a restyle keeps (`global.use-of-color`).
- Put a count on a destination as `badge.basic` describes, in words ("Inbox, 24 unread").

## Don'ts
- Do not leave the screen behind the open drawer in the accessibility tree. TalkBack swipes out of the drawer and into the screen it covers, and a keyboard Tabs out the same way without the focus containment above.
- Do not pass `gesturesEnabled = false` while the drawer is open. Material then ignores taps on the scrim as well as swipes, which takes away the plainest way out.
- Do not replace Material's scrim with a plain `Box`. The scrim is what carries "Close navigation menu" and the tap to close.
- Do not move focus back to the menu button after the user has chosen a destination. Focus belongs on the screen they asked for.

## Customizable
- The drawer may start with a header naming the app, and group its destinations into sections, each with a heading marked `heading()` (`global.headings`).
- An item may carry an icon beside its label, given `contentDescription = null` (`global.icon`).
- The drawer may open from the menu button only, with swipe gestures left enabled or not, provided the scrim and the back gesture still close it while it is open.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun NavigationDrawerExamples() {
    val destinations = listOf("Inbox", "Sent", "Drafts")
    var current by remember { mutableStateOf(destinations.first()) }
    val drawerState = rememberDrawerState(DrawerValue.Closed)
    val scope = rememberCoroutineScope()
    val menuButtonFocus = remember { FocusRequester() }
    val firstItemFocus = remember { FocusRequester() }
    var returnFocusToMenu by remember { mutableStateOf(false) }

    LaunchedEffect(drawerState.isOpen) {
        if (drawerState.isOpen) {
            firstItemFocus.requestFocus()
        } else if (returnFocusToMenu) {
            menuButtonFocus.requestFocus()
            returnFocusToMenu = false
        }
    }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                modifier = Modifier
                    .focusProperties { onExit = { if (drawerState.isOpen) cancelFocusChange() } }
                    .focusGroup()
                    .onKeyEvent { event ->
                        if (event.key == Key.Escape) {
                            scope.launch { drawerState.close() }
                            true
                        } else {
                            false
                        }
                    }
            ) {
                Column(modifier = Modifier.selectableGroup()) {
                    destinations.forEachIndexed { index, destination ->
                        NavigationDrawerItem(
                            label = { Text(destination) },
                            selected = destination == current,
                            onClick = {
                                current = destination
                                returnFocusToMenu = false
                                scope.launch { drawerState.close() }
                            },
                            modifier = if (index == 0) {
                                Modifier.focusRequester(firstItemFocus)
                            } else {
                                Modifier
                            }
                        )
                    }
                }
            }
        }
    ) {
        Scaffold(
            modifier = if (drawerState.isOpen) Modifier.clearAndSetSemantics { } else Modifier,
            topBar = {
                TopAppBar(
                    title = { Text(current, modifier = Modifier.semantics { heading() }) },
                    navigationIcon = {
                        IconButton(
                            onClick = {
                                returnFocusToMenu = true
                                scope.launch { drawerState.open() }
                            },
                            modifier = Modifier.focusRequester(menuButtonFocus)
                        ) {
                            Icon(Icons.Filled.Menu, contentDescription = "Open navigation menu")
                        }
                    }
                )
            }
        ) { innerPadding ->
            Box(modifier = Modifier.padding(innerPadding)) {
                /* the current destination's content */
            }
        }
    }
}
```
