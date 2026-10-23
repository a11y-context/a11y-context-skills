---
id: bottom-app-bar.basic
title: Bottom App Bar
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [app bar, bottom app bar, toolbar, actions, floating action button]
aliases: [BottomAppBar, bottom toolbar, bottom action bar, action bar, FAB bar]
summary: Bar along the bottom of a screen holding a few actions and an optional floating action button. Material's BottomAppBar reads the actions in order and the floating button last, as one group, and sets nothing else, so each action's name and keeping the bar off the content above are the caller's.
---

# Bottom App Bar

Pattern ID: `bottom-app-bar.basic`

Bar along the bottom of a screen holding a few actions and an optional floating action button. Material's `BottomAppBar` reads the actions in order and the floating button last, as one group, and sets nothing else, so each action's name and keeping the bar off the content above are the caller's.

## Use When
- Use when a screen's main actions sit along the bottom, within reach of the thumb (e.g., "Archive", "Label", "Delete", with a "Compose" floating action button).

## Do Not Use When
- Do not use when the bar's items move between the app's top-level destinations and show which one is current (use `navigation-bar.basic`).
- Do not use when the actions belong beside the screen's title (use `top-app-bar.basic`).
- Do not use when the screen has a single floating action and nothing else (use `button.basic`).

## Must Haves
- The bar reads its actions in order and its floating action button last, as one group, and every item reports a button. Material's `BottomAppBar` is the reference implementation: a traversal group holding a row of actions followed by the `floatingActionButton` slot (`global.native-first`, `global.traversal-order`).
- Build each action as an icon button named on its `Icon` (e.g., "Archive"), as `button.basic` describes, and the floating action button the same way (e.g., "Compose").
- Build an action that turns something on or off as `button.toggle` describes, and move actions beyond the bar's room into an overflow menu named "More options" (`menu.basic`).
- Keep the bar's items to actions. An item that takes the user to a destination and stays marked as current belongs in a navigation bar, which reports its selection.
- Apply the `Scaffold`'s `innerPadding` to the content as `Modifier.padding`, so the scrolling area ends above the bar. Content scrolled beneath a bar can hold a focused item the bar then covers (`global.focus-not-obscured`).
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not give the bar's actions a selected state to show the current screen. They report buttons, and the user hears an action, not a place.
- Do not set `contentDescription` on the bar itself. Each action is its own stop and carries its own name.
- Do not lay out a bottom app bar and a navigation bar together. The user meets two bars of icon buttons at the bottom of the screen with nothing telling actions from destinations.

## Customizable
- The floating action button may be left out, or be an `ExtendedFloatingActionButton` with visible text, named as `button.basic` describes.
- The bar may hold up to about four actions; their order is the reading order.
- A bar that hides as the content scrolls takes a `BottomAppBarScrollBehavior`, which Material still marks experimental and which needs `@OptIn(ExperimentalMaterial3Api::class)`. Nothing else in this pattern changes.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun BottomAppBarExamples() {
    Scaffold(
        bottomBar = {
            BottomAppBar(
                actions = {
                    IconButton(onClick = { /* archive */ }) {
                        Icon(Icons.Filled.Archive, contentDescription = "Archive")
                    }
                    IconButton(onClick = { /* label */ }) {
                        Icon(Icons.AutoMirrored.Filled.Label, contentDescription = "Label")
                    }
                    IconButton(onClick = { /* delete */ }) {
                        Icon(Icons.Filled.Delete, contentDescription = "Delete")
                    }
                },
                floatingActionButton = {
                    FloatingActionButton(onClick = { /* compose */ }) {
                        Icon(Icons.Filled.Edit, contentDescription = "Compose")
                    }
                }
            )
        }
    ) { innerPadding ->
        LazyColumn(modifier = Modifier.padding(innerPadding)) {
            /* messages */
        }
    }
}
```
