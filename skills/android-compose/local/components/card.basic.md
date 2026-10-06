---
id: card.basic
title: Card
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [card, container, surface, clickable card, grouped content]
aliases: [Card, ElevatedCard, OutlinedCard, clickable card, content card, info card, surface, tile]
summary: Surface grouping related content, either static or opening something when tapped. Material's static Card keeps its contents together in traversal order; its clickable overload merges everything into one stop with no role, so the order of that announcement, its click label, and any secondary actions are the caller's.
---

# Card

Pattern ID: `card.basic`

Surface grouping related content, either static or opening something when tapped. Material's static `Card` keeps its contents together in traversal order; its clickable overload merges everything into one stop with no role, so the order of that announcement, its click label, and any secondary actions are the caller's.

## Use When
- Use when related content about one thing is grouped on a surface (e.g., a recipe's photo, name, and cooking time).
- Use when tapping anywhere on that surface opens the thing it describes, in the card's clickable form.

## Do Not Use When
- Do not use when the item is a row in a vertical list (use `list-item.basic`).
- Do not use when the item is a tile in a horizontally scrolling strip (use `content-shelf.basic`).
- Do not use when the surface interrupts the screen to ask for a decision (use `dialog.alert` or `bottom-sheet.modal`).

## Must Haves
- A static card keeps its content together; a clickable card is one stop with a click action. Material's `Card`, `ElevatedCard`, and `OutlinedCard` are the reference implementation: the static overload marks the card a traversal group, so its contents are read in order before anything after it, and the `onClick` overload makes the surface clickable, merging its descendants into one node with a 48dp minimum and no role (`global.native-first`).
- In a clickable card, put the card's name first in its content, since the merged announcement is the descendants' text in traversal order, and give decorative images `contentDescription = null` (`global.merge-semantics`, `global.icon`).
- In a clickable card, set a click label when "Double tap to activate" would not say what happens (e.g., "open recipe"). `Card` takes no `onClickLabel` parameter; set it through `Modifier.semantics { onClick(label = "...", action = null) }`, as `button.basic` describes.
- In a clickable card, expose a secondary control, such as a share button, as a `CustomAccessibilityAction` on the card, and hide the control itself with `Modifier.clearAndSetSemantics {}` so the card stays one stop (`global.merge-semantics`).
- In a static card whose content forms one unit, apply `Modifier.semantics(mergeDescendants = true) {}` to the card so it reads as one item. A static card holding its own buttons stays unmerged, and each control is reached in order.
- In a static card, mark its title with `heading()` when several cards stack on a screen, so a TalkBack user can move between them (`global.headings`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not leave a button inside a clickable card in the accessibility tree. A child that merges is not absorbed by a parent that merges, so the user meets competing targets where the layout shows one card.
- Do not place what the user needs first, such as the item's name or price, at the end of a clickable card's content. The merged announcement reads it last, after everything else.

## Customizable
- `Card`, `ElevatedCard`, and `OutlinedCard` differ in container treatment and share the same semantics.
- A clickable card's content may be laid out in any visual order, provided the traversal order puts its name first.
- A card may hold an image, text, and controls in any combination, following the static or clickable branch above.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun CardExamples() {
    OutlinedCard {
        Column {
            Text("Delivery details", modifier = Modifier.semantics { heading() })
            Text("Arrives Thursday between 2 and 4 PM")
            TextButton(onClick = { /* change time */ }) {
                Text("Change delivery time")
            }
        }
    }

    Card(
        onClick = { /* open recipe */ },
        modifier = Modifier.semantics {
            onClick(label = "open recipe", action = null)
            customActions = listOf(
                CustomAccessibilityAction("Share") { /* share */ true }
            )
        }
    ) {
        Column {
            Text("Lemon pasta")
            Text("25 minutes")
            Image(painterResource(R.drawable.lemon_pasta), contentDescription = null)
            IconButton(
                onClick = { /* share */ },
                modifier = Modifier.clearAndSetSemantics { }
            ) {
                Icon(Icons.Filled.Share, contentDescription = null)
            }
        }
    }
}
```
