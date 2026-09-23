---
id: list-item.basic
title: List Item
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [list item, row, list, collection, navigation]
aliases: [list row, ListItem, table row, cell, settings row, channel row, list tile, collection-row item]
summary: A row in a vertical list. The row is one accessibility node rather than the several elements it looks like, so a second control inside it becomes a custom action rather than a nested target.
---

# List Item

Pattern ID: `list-item.basic`

A row in a vertical list. The row is one accessibility node rather than the several elements it looks like, so a second control inside it becomes a custom action rather than a nested target.

A row carrying a title, a subtitle, an image, and a trailing control looks like four or five things and should read as one. Getting that wrong is the most common accessibility failure in a Compose list, and it is invisible to a scanner: every element has a name, contrast passes, and the tree is well formed.

## Use When
- Use when a row in a vertical list presents one item and, on tap, acts on that item or opens it (e.g., a message in an inbox, an order in a purchase history, a row in a settings screen).
- Use when the row carries several pieces of content, such as a thumbnail with a title and supporting text, that describe one thing.

## Do Not Use When
- Do not use when the tile sits in a horizontally scrolling row of content (use `content-shelf.basic`).
- Do not use when the control performs an in-place action and is not a row in a list (use `button.basic`).
- Do not use when the row is a selectable option in a mutually exclusive set (use `radio.basic`).
- Do not use when the row carries a setting that toggles in place (use `switch.basic`).

## Must Haves
- The row's content sits in a known order, because that order is the order its merged name reads in. Material's `ListItem` is the reference implementation and its slots supply that order; a hand-built `Row` satisfies it when composition order matches the reading order you want (`global.native-first`).
- Make the whole row the target when tapping it acts on the item, by putting `Modifier.clickable` on the `ListItem` rather than on the text inside it.
- The row is a single accessibility node. Its headline, overline, and supporting text merge into one name, read in traversal order, so order the slots so that name reads as a sentence (`global.merge-semantics`).
- Expose a secondary control inside the row as a `CustomAccessibilityAction` on the row rather than as a nested interactive child. TalkBack surfaces custom actions through its actions menu, which keeps the row a single stop.
- Set `onClickLabel` on the row when "Double tap to activate" would not say what happens (e.g., `onClickLabel = "open message"`).
- Give a leading thumbnail `contentDescription = null` when the row's text already names the item. The artwork repeats the title, and naming it makes the row announce the title twice (`global.icon`).
- Declare `collectionItemInfo` on each row and `collectionInfo` on the list when position in the set is meaningful. A `LazyColumn` announces that the user is in a list and reports neither position nor total (`global.collection-semantics`).
- Name the list itself on its container, not only its visible heading. A heading above a `LazyColumn` is read on the way past and is not attached to the list, so a user who enters the rows any other way hears only "in list" (`global.collection-semantics`).
- Give a progress bar or similar indicator inside the row a `stateDescription` on the row, or fold its value into the row's name. An indicator inside a merged node contributes nothing on its own (`global.state-description`).
- Size the row to at least 48dp (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not nest an interactive child inside a clickable row. A child that merges is not absorbed by a parent that merges, so a favorite button inside a clickable row becomes a second competing target rather than part of the row, and the user meets two stops where the layout shows one.
- Do not make the title clickable instead of the row. The tap target shrinks to the text, and the rest of the row, including the artwork the user is aiming at, does nothing.
- Do not give every element in the row its own `contentDescription`. They all reach the merged name and the row announces a run-on string.
- Do not leave a decorative thumbnail unnamed by omitting `contentDescription` entirely. An unset description is not the same as `null`, and the image reports no name rather than leaving the tree.
- Do not rely on `LazyColumn` to supply position. It says the user is in a list and stops there.

## Customizable
- The row may use `ListItem`'s slots or a hand-built `Row`, as long as the result is one node with a coherent name and a 48dp target. `ListItem` is preferred because its slot order is the order the name reads in.
- A row may carry one secondary action as a custom action, or several. Where there are more than about three, a row that opens a detail surface is usually easier to operate than a row with a long actions menu.
- A trailing chevron, a trailing value, or neither. A chevron is decorative and takes `contentDescription = null`.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun ListItemExamples() {
    val messages = listOf(
        Message(id = "1", from = "Dana Whitfield", preview = "Re: invoice for March", unread = true),
        Message(id = "2", from = "Support", preview = "Your ticket has been closed", unread = false)
    )

    LazyColumn(
        modifier = Modifier.semantics {
            contentDescription = "Inbox"
            collectionInfo = CollectionInfo(rowCount = messages.size, columnCount = 1)
        }
    ) {
        itemsIndexed(messages, key = { _, m -> m.id }) { index, message ->
            var unread by remember { mutableStateOf(message.unread) }

            ListItem(
                headlineContent = { Text(message.from) },
                supportingContent = { Text(message.preview) },
                // The avatar stands for the sender the headline already names,
                // so naming it makes the row say the sender twice.
                leadingContent = {
                    Image(
                        painter = painterResource(R.drawable.avatar),
                        contentDescription = null
                    )
                },
                // No nested IconButton here. A second clickable inside a
                // clickable row is not absorbed by the merge, and becomes a
                // rival target.
                trailingContent = {
                    if (unread) {
                        Box(Modifier.size(8.dp).background(MaterialTheme.colorScheme.primary, CircleShape))
                    }
                },
                modifier = Modifier
                    .clickable(onClickLabel = "open message") { /* open */ }
                    .heightIn(min = 48.dp)
                    .semantics {
                        collectionItemInfo = CollectionItemInfo(
                            rowIndex = index, rowSpan = 1, columnIndex = 0, columnSpan = 1
                        )
                        // The unread dot is inside the merged node and says
                        // nothing on its own, so the row carries it.
                        stateDescription = if (unread) "Unread" else "Read"
                        // The mark-as-read control reaches the user here,
                        // through the actions menu, instead of as a second stop
                        // in the list.
                        customActions = listOf(
                            CustomAccessibilityAction(
                                label = if (unread) "Mark as read" else "Mark as unread"
                            ) { unread = !unread; true }
                        )
                    }
            )
        }
    }
}
```
