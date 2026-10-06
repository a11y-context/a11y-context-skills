---
id: tabs.basic
title: Tabs
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [tabs, tab row, segmented views, switch views, selection]
aliases: [Tab, TabRow, PrimaryTabRow, SecondaryTabRow, ScrollableTabRow, PrimaryScrollableTabRow, tab bar, tab strip, tabbed view]
summary: Row of tabs that switches between views of the same screen. Each tab reports Role.Tab, its selected state, and its position, and only the selected tab's content belongs in the tree. Unlike a navigation bar item, a tab keeps its icon's semantics.
---

# Tabs

Pattern ID: `tabs.basic`

Row of tabs that switches between views of the same screen. Each tab reports `Role.Tab`, its selected state, and its position, and only the selected tab's content belongs in the tree. Unlike a navigation bar item, a tab keeps its icon's semantics.

`Tab` and `NavigationBarItem` look alike and differ on one point. A navigation bar item clears its icon's semantics whenever its label shows; a tab does not. An icon named for its tab, beside a tab's text, makes the tab announce its name twice.

## Use When
- Use when one screen offers several views of the same subject and the user switches between them (e.g., "Overview", "Reviews", "Specifications" on a product).
- Use when the views are peers and the user is expected to move between them freely.

## Do Not Use When
- Do not use when the options are top-level destinations of the app (use `navigation-bar.basic`).
- Do not use when the control picks a value or filters a list in place (use `segmented-button.single`).
- Do not use when the sections are long and meant to be read in sequence (use `accordion.basic`).

## Must Haves
- Each tab reports `Role.Tab`, its selected state, and a click action, and the row reports position within the set. Material's `Tab` inside a `PrimaryTabRow`, `SecondaryTabRow`, or scrollable tab row is the reference implementation of that contract, through `selectable(role = Role.Tab)` on each tab and `selectableGroup()` on the row; a design system's own tabs satisfy it by forwarding to the same semantics, and hand-assembled ones satisfy none of it by default (`global.native-first`).
- Give each tab visible text that names its view.
- Give a tab's `Icon` `contentDescription = null` when the tab also has text. `Tab` keeps the icon's semantics, so a named icon repeats the tab's name (`global.icon`).
- Give an icon-only tab's `Icon` a `contentDescription` naming its view.
- Compose only the selected tab's content, so the other views are out of the accessibility tree rather than hidden behind the visible one.
- Keep the selected tab and the visible content in step when the content also responds to swiping, such as a `HorizontalPager`. A swipe that changes the view without moving the selection makes TalkBack report the wrong tab as selected.
- If a view is unavailable, pass `enabled = false` rather than removing the handler, so the control stays in the accessibility tree and reports that it is disabled.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not give a tab's icon the same `contentDescription` as its text. Unlike `NavigationBarItem`, `Tab` does not clear it.
- Do not build tabs from `Row` and `Modifier.clickable` items. They announce as buttons, report no selected state, and lose their position in the set.
- Do not keep the unselected views composed behind the selected one, such as stacked in a `Box` with the others hidden. Whether TalkBack skips a hidden view depends on how it was hidden; not composing it removes the question.
- Do not use tabs to run commands or submit choices. Each tab reports `Role.Tab`, which tells the user it shows a view.
- Do not convey the selected tab by color alone. The row's indicator line carries it; a restyled row that changes only the text tint does not (`global.use-of-color`).

## Customizable
- Primary or secondary styling and fixed or scrollable layout are visual choices with the same contract. A scrollable row suits more tabs than fit the width.
- Tabs may show text, an icon above text, or an icon alone.
- The views may change on tap only, or also on a horizontal swipe through a `HorizontalPager`, provided the selected tab follows the swipe.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun TabsExamples() {
    val tabs = listOf("Overview", "Reviews", "Specifications")
    var selected by rememberSaveable { mutableIntStateOf(0) }

    Column {
        PrimaryTabRow(selectedTabIndex = selected) {
            tabs.forEachIndexed { index, title ->
                Tab(
                    selected = selected == index,
                    onClick = { selected = index },
                    text = { Text(title) }
                )
            }
        }

        when (selected) {
            0 -> ProductOverview()
            1 -> ProductReviews()
            2 -> ProductSpecifications()
        }
    }
}

@Composable
fun SwipeableTabsExample(tabs: List<String>) {
    val pagerState = rememberPagerState { tabs.size }
    val scope = rememberCoroutineScope()

    Column {
        PrimaryTabRow(selectedTabIndex = pagerState.currentPage) {
            tabs.forEachIndexed { index, title ->
                Tab(
                    selected = pagerState.currentPage == index,
                    onClick = { scope.launch { pagerState.animateScrollToPage(index) } },
                    text = { Text(title) },
                    icon = { Icon(Icons.Outlined.Info, contentDescription = null) }
                )
            }
        }

        HorizontalPager(state = pagerState) { page ->
            TabPage(tabs[page])
        }
    }
}
```
