---
id: navigation-bar.basic
title: Navigation Bar
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [navigation, bottom navigation, tab bar, destinations, top-level]
aliases: [NavigationBar, NavigationBarItem, bottom navigation, bottom nav, bottom bar, tab bar, BottomNavigation]
summary: Bar of three to five top-level destinations along the bottom of the screen. Each item reports Role.Tab, its selected state, and its position, and Material removes the icon's semantics whenever the label shows, which takes any badge with it.
---

# Navigation Bar

Pattern ID: `navigation-bar.basic`

Bar of three to five top-level destinations along the bottom of the screen. Each item reports `Role.Tab`, its selected state, and its position, and Material removes the icon's semantics whenever the label shows, which takes any badge with it.

`NavigationBarItem` wraps its icon in `clearAndSetSemantics {}` whenever a label is present and visible, so the label alone names the item. That is right for the icon's description and wrong for anything else drawn in the icon slot: a `BadgedBox` count sits inside the cleared box and never reaches TalkBack.

## Use When
- Use when the app has three to five top-level destinations the user moves between from anywhere (e.g., "Home", "Search", "Library", "Inbox").
- Use when the destinations are peers and none is a sub-view of another.

## Do Not Use When
- Do not use when the options switch between views inside one screen (use `tabs.basic`).
- Do not use when the layout is wide enough for a side rail (use `navigation-rail.basic`).
- Do not use when the bar holds actions for the current screen rather than destinations (use `bottom-app-bar.basic`).
- Do not use when there are more than five destinations (use `navigation-drawer.modal`).

## Must Haves
- Each item reports `Role.Tab`, its selected state, and a click action, and the bar reports position within the set. Material's `NavigationBar` and `NavigationBarItem` are the reference implementation of that contract, through `selectable(role = Role.Tab)` on each item and `selectableGroup()` on the bar; a design system's own bar satisfies it by forwarding to the same semantics, and a hand-assembled one satisfies none of it by default (`global.native-first`).
- Give each item a visible `label`.
- Give each item's `Icon` a `contentDescription` matching its label. Material discards it whenever the label is showing, and it is the item's only name when the label is hidden (`alwaysShowLabel = false` on an unselected item) or absent.
- Put a badge's meaning in the item's name, with `Modifier.semantics { contentDescription = "..." }` on the `NavigationBarItem` (e.g., "Inbox, 3 new messages"). A `BadgedBox` in the icon slot is cleared along with the icon whenever the label shows.
- Mark the selected item from the current destination, so the selected state TalkBack reports matches the screen the user is on.
- Give each destination a visible title when it opens, so moving between them is announced (`global.screen-announcement`).
- If a destination is unavailable, pass `enabled = false` rather than removing the handler, so the control stays in the accessibility tree and reports that it is disabled.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not give the icon `contentDescription = null` on the assumption that the label always names the item. Set `alwaysShowLabel = false` and every unselected item loses its name.
- Do not rely on a `BadgedBox` to announce a count or a dot. The item has to carry it.
- Do not build the bar from `Row` and `Modifier.clickable` items. They announce as buttons, report no selected state, and lose their position in the set.
- Do not put actions such as "Compose" or "Share" in the bar. Its items report `Role.Tab`, which tells the user each one is a place.
- Do not convey the selected item by color alone. Material draws an indicator shape behind the selected item's icon, which carries it; a restyled bar that changes only the tint does not (`global.use-of-color`).

## Customizable
- Labels may be shown on every item (`alwaysShowLabel = true`, the default) or on the selected item only. Hiding them is a visual choice that moves the naming duty to the icons.
- `NavigationBarItemDefaults.colors` and the container color may follow the brand, provided the selected state stays distinguishable without color.
- A badge may show a count or a dot. A dot's meaning goes in the item's name as words (e.g., "Inbox, new messages").

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun NavigationBarExamples(current: Destination, unread: Int, onNavigate: (Destination) -> Unit) {
    NavigationBar {
        Destination.entries.forEach { destination ->
            NavigationBarItem(
                selected = destination == current,
                onClick = { onNavigate(destination) },
                label = { Text(destination.label) },
                icon = {
                    if (destination == Destination.Inbox && unread > 0) {
                        BadgedBox(badge = { Badge { Text("$unread") } }) {
                            Icon(destination.icon, contentDescription = destination.label)
                        }
                    } else {
                        Icon(destination.icon, contentDescription = destination.label)
                    }
                },
                modifier = if (destination == Destination.Inbox && unread > 0) {
                    Modifier.semantics { contentDescription = "Inbox, $unread new messages" }
                } else {
                    Modifier
                }
            )
        }
    }
}
```
