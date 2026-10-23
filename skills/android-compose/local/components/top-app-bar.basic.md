---
id: top-app-bar.basic
title: Top App Bar
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [app bar, top app bar, toolbar, title, navigation icon, actions, header]
aliases: [TopAppBar, CenterAlignedTopAppBar, MediumTopAppBar, LargeTopAppBar, toolbar, action bar, app bar, title bar, screen header, up button]
summary: Bar across the top of a screen holding its title, a navigation control, and a few actions. Material's top app bars read those in order as one group, but none marks the title as a heading, so the heading, the navigation control's name, and keeping the bar off the content beneath are the caller's.
---

# Top App Bar

Pattern ID: `top-app-bar.basic`

Bar across the top of a screen holding its title, a navigation control, and a few actions. Material's top app bars read those in order as one group, but none marks the title as a heading, so the heading, the navigation control's name, and keeping the bar off the content beneath are the caller's.

## Use When
- Use when a screen shows its title at the top, with a back or menu control before it and a few actions after it (e.g., "Inbox" with "Search" and "More options").

## Do Not Use When
- Do not use when the bar moves between the app's top-level destinations (use `navigation-bar.basic` or `tabs.basic`).
- Do not use when the screen's actions sit along the bottom (use `bottom-app-bar.basic`).
- Do not use when the title belongs to a dialog or a sheet (use `dialog.alert` or `bottom-sheet.modal`).

## Must Haves
- The bar reads its navigation control, the screen's title, and its actions, in that order, as one group. Material's `TopAppBar`, `CenterAlignedTopAppBar`, `MediumTopAppBar`, and `LargeTopAppBar` are the reference implementation: each marks itself a traversal group and lays out the navigation icon, the title, and the actions in that order (`global.native-first`, `global.traversal-order`).
- Mark the title with `Modifier.semantics { heading() }`. None of Material's top app bars marks it, and it is the heading a TalkBack user reaches first on the screen (`global.headings`).
- Make the title the screen's name, as visible text (`global.screen-announcement`).
- Name the navigation control on its `Icon` for what it does: "Navigate up" for an arrow that returns to the previous level, the label Android uses for that control, or "Open navigation menu" for a menu icon that opens a drawer (`navigation-drawer.modal`). Use `Icons.AutoMirrored.Filled.ArrowBack` so the arrow points the right way in right-to-left layouts (`global.icon`).
- Name each action on its `Icon`, as `button.basic` describes. Move actions beyond the first few into an overflow menu named "More options" (`menu.basic`), and build an action that turns something on or off as `button.toggle` describes.
- Apply the `Scaffold`'s `innerPadding` to the content as `Modifier.padding`, so the scrolling area starts below the bar. Content scrolled beneath a bar can hold a focused item the bar then covers (`global.focus-not-obscured`).
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not name the navigation control for its shape ("Arrow", "Hamburger"). The user needs what it does.
- Do not mark anything else in the bar as a heading. The title is the bar's only heading.
- Do not build a two-row bar by stacking a small title over a large one. `MediumTopAppBar` and `LargeTopAppBar` hide one of their two titles from accessibility services while they collapse; a hand-built pair is read twice.
- Do not show the screen's name only as an image with no name. When the bar shows a logo in place of text, the logo carries the name.

## Customizable
- Any of the four bars may be used; they share the same semantics and differ in size and title alignment.
- A logo may stand in for the title text, as an `Image` with a `contentDescription` naming the screen or the app, marked with `heading()`.
- A bar that collapses or hides as the content scrolls takes a `TopAppBarScrollBehavior`, which Material still marks experimental and which needs `@OptIn(ExperimentalMaterial3Api::class)`. Nothing else in this pattern changes.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun TopAppBarExamples(onNavigateUp: () -> Unit) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text("Inbox", modifier = Modifier.semantics { heading() })
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateUp) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Navigate up")
                    }
                },
                actions = {
                    IconButton(onClick = { /* search */ }) {
                        Icon(Icons.Filled.Search, contentDescription = "Search")
                    }
                    IconButton(onClick = { /* open the menu, as menu.basic describes */ }) {
                        Icon(Icons.Filled.MoreVert, contentDescription = "More options")
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
