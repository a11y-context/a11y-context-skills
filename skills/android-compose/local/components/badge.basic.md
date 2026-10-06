---
id: badge.basic
title: Badge
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [badge, count, notification, status, indicator, dot]
aliases: [Badge, BadgedBox, notification badge, count badge, unread count, dot badge, status dot, indicator]
summary: Small indicator on an icon or control reporting a count or a status. Material's Badge and BadgedBox set no semantics, so a badge's text joins its host's name as a bare number and a dot badge says nothing at all; the badge carries its meaning in words.
---

# Badge

Pattern ID: `badge.basic`

Small indicator on an icon or control reporting a count or a status. Material's `Badge` and `BadgedBox` set no semantics, so a badge's text joins its host's name as a bare number and a dot badge says nothing at all; the badge carries its meaning in words.

## Use When
- Use when a small indicator on or beside an element reports a count for it (e.g., unread notifications on a bell icon, items in a cart).
- Use when a small indicator reports a status of the element it sits on (e.g., "New" on a menu entry, an online dot on an avatar).

## Do Not Use When
- Do not use when the badge sits on a navigation bar item (use `navigation-bar.basic`, where Material clears the icon slot and the item carries the badge's meaning).
- Do not use when the user must learn of the change right away, without moving to the indicator (use `snackbar.basic`).
- Do not use when the indicator can be selected or removed (use `chip.filter` or `chip.input`).

## Must Haves
- The badge's meaning is part of its host's name, in words. Material's `BadgedBox` places the badge after its host and sets no semantics of its own, so inside a clickable host the badge's text merges into the host's name as drawn ("3"), and a dot badge contributes nothing (`global.native-first`).
- Replace the badge's own content with words, with `Modifier.clearAndSetSemantics { contentDescription = "..." }` on the `Badge`, saying what the value counts or what the status is (e.g., "3 unread" for a count, "Online" for a dot). It then follows the host's name in the merged announcement: "Notifications, 3 unread".
- When the host's name comes from text after the `BadgedBox`, such as a person's name beside an avatar, the badge would be read before it. Put a status on the row as `stateDescription` instead (e.g., "Online"), and clear the badge with `Modifier.clearAndSetSemantics {}` (`global.state-description`).
- Build the description from the same value the badge draws, so the two never disagree. A capped count reads as drawn (e.g., "99+ unread").
- When no badge is drawn, the host's name makes no claim about one. A bell with no badge is named "Notifications", not "Notifications, 0 unread".
- Keep the badge out of focus and give it no click action. It annotates its host and is reached through it.
- Distinguish badges that report different statuses by more than color, such as a shape or a label, alongside their different descriptions (`global.use-of-color`).

## Don'ts
- Do not leave a count badge's text to merge as it is drawn. A bare number tells the user nothing about what is being counted.
- Do not announce a badge change through a live region. A count that changes while the user is elsewhere interrupts work the badge is not urgent enough to interrupt.
- Do not write the count into the host's name and leave the badge's own text in the tree. The user hears the number twice.
- Do not make the badge a button or give it its own touch target.

## Customizable
- A badge may show a count, a short label such as "New", or a dot with no content.
- Whether a count is capped, and at what value, provided the description reads what is drawn.
- Whether a badge appears at zero, provided the host's name agrees with what is shown.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun BadgeExamples(unread: Int, online: Boolean) {
    IconButton(onClick = { /* open notifications */ }) {
        BadgedBox(
            badge = {
                if (unread > 0) {
                    val shown = if (unread > 99) "99+" else unread.toString()
                    Badge(
                        modifier = Modifier.clearAndSetSemantics {
                            contentDescription = "$shown unread"
                        }
                    ) {
                        Text(shown)
                    }
                }
            }
        ) {
            Icon(Icons.Filled.Notifications, contentDescription = "Notifications")
        }
    }

    Row(
        modifier = Modifier
            .clickable(onClickLabel = "open profile") { /* open */ }
            .heightIn(min = 48.dp)
            .semantics { if (online) stateDescription = "Online" },
        verticalAlignment = Alignment.CenterVertically
    ) {
        BadgedBox(
            badge = {
                if (online) {
                    Badge(modifier = Modifier.clearAndSetSemantics { })
                }
            }
        ) {
            Image(painterResource(R.drawable.avatar_jordan), contentDescription = null)
        }
        Text("Jordan Lee")
    }
}
```
