---
id: content-shelf.basic
title: Content Shelf
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [content-shelf, shelf, rail, horizontal-list, carousel, collection, browse]
aliases: [collection row, collection-row, content row, content rail, rail, strip, shelf, tile row, poster row, card row, media row, LazyRow, carousel row]
summary: Horizontally scrolling strip of tiles under a heading that says what the tiles have in common. A LazyRow reports that the user is in a list and nothing else, so the shelf's name, each tile's name, and every position announcement are the app's to supply.
---

# Content Shelf

Pattern ID: `content-shelf.basic`

Horizontally scrolling strip of tiles under a heading that says what the tiles have in common. A `LazyRow` reports that the user is in a list and nothing else, so the shelf's name, each tile's name, and every position announcement are the app's to supply.

A browse screen stacks several of these, and they are told apart only by their headings. Get the naming wrong and a user swiping through hears forty unlabeled posters in a row with no sense of which shelf ended and which began.

## Use When
- Use when several related items sit in a horizontally scrolling strip under a shared heading (e.g., "Customers also bought", "Continue watching", "Recently played").
- Use when more than one item is visible at a time and the rest are reached by scrolling sideways.
- Use when each item is a compact tile carrying artwork and, usually, a short title.

## Do Not Use When
- Do not use when the rows run down the screen rather than across it (use `list-item.basic`).
- Do not use when one item fills the strip at a time and the others are reached by paging (use `carousel.basic`).
- Do not use when items wrap across several rows and columns (use `grid.basic`).
- Do not use when the strip is a set of filters or categories the user selects among rather than content they open (use `chip.filter`).

## Must Haves
- Build the strip with `LazyRow` rather than a `Row` inside `Modifier.horizontalScroll`. Only the lazy layout reports itself as a collection, and only it avoids composing every tile in the set.
- Name the shelf on the `LazyRow` with `Modifier.semantics { contentDescription = "..." }`. The heading above it is read on the way past and is not attached to the strip, so a user who enters the tiles any other way hears only "in list" (`global.collection-semantics`).
- Give the shelf a visible heading naming the category, and mark it with `heading()`. The heading is what tells any user which shelf they are looking at, and marking it lets a TalkBack user move between shelves directly instead of swiping through every tile (`global.headings`).
- Declare `collectionInfo = CollectionInfo(rowCount = 1, columnCount = items.size)` on the `LazyRow` and `collectionItemInfo` on each tile with `rowIndex = 0` and `columnIndex` set to the item's index. A horizontal strip is one row of many columns; reversing the two reports a column of items and the position announcement comes out wrong.
- Index each tile against the full set, not against what is on screen. The count the user hears has to survive scrolling.
- Make each tile a single accessibility node by putting `Modifier.clickable` on the tile container rather than on the artwork or the title inside it (`global.merge-semantics`).
- Take each tile's name from the item data. Give the artwork `contentDescription = null` when the title is rendered as text below it, and set `contentDescription` on the tile to the item's title when the tile is artwork alone (`global.icon`).
- Fold a tile's badge or progress indicator into the tile's `stateDescription`, or into its name. Inside a merged node it contributes nothing on its own (`global.state-description`).
- Give a "See all" affordance a name that includes the shelf, such as `onClickLabel` or a `contentDescription` of "See all in Continue Watching". Ten identical "See all" buttons down a browse screen name nothing.
- Use stable `key` values on the lazy items, so the accessibility tree does not reshuffle when the shelf refreshes.
- Size each tile to at least 48dp in both dimensions (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not add Previous and Next paging buttons. `LazyRow` handles the accessibility scroll actions, so TalkBack's swipe and a keyboard's Tab both bring the next tile into view on their own. The buttons a web shelf needs are two extra stops per shelf here.
- Do not build a tile from several clickable children — artwork, title, and a favorite button each taking a tap. A child that merges is not absorbed by a parent that merges, so the user meets three stops where the layout shows one tile. A secondary action belongs in a `CustomAccessibilityAction` on the tile.
- Do not write the position into each tile's `contentDescription` by hand. It duplicates what `collectionItemInfo` reports and goes stale the moment the shelf reorders.
- Do not name a tile from its artwork filename or a generic string such as "poster". The title is in the data; use it.
- Do not rely on the heading alone to name the shelf. It is a separate node and nothing associates the two.
- Do not leave decorative artwork unnamed by omitting `contentDescription` entirely. An unset description is not the same as `null`, and the image reports no name rather than leaving the tree.

## Customizable
- A tile may be a bare `Box` with artwork, a `Card`, or a column of artwork with a title and metadata beneath, as long as the result is one node with a name from the data.
- The title may render as text under the artwork or live only in the accessible name where the design shows artwork alone. Where it renders as text, the artwork takes `contentDescription = null` so the tile does not say it twice.
- A shelf may carry a "See all" affordance beside its heading, or none.
- Metadata such as a rating, a year, or an episode count may join the tile's name. Put it after the title, so the tile announces what it is before it qualifies it.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun ContentShelfExamples() {
    val shelfTitle = "Customers also bought"
    val products = listOf(
        Product(id = "1", name = "Cast iron skillet", price = "$39.00", badge = null),
        Product(id = "2", name = "Enamel dutch oven", price = "$92.00", badge = "Only 2 left")
    )

    Column {
        Text(
            text = shelfTitle,
            modifier = Modifier.semantics { heading() }
        )

        LazyRow(
            // The heading above is a separate node. Without this, a user who
            // reaches the tiles any other way hears only "in list".
            modifier = Modifier.semantics {
                contentDescription = shelfTitle
                // One row, many columns. Swapping these reports the position
                // against the wrong axis.
                collectionInfo = CollectionInfo(rowCount = 1, columnCount = products.size)
            }
        ) {
            itemsIndexed(products, key = { _, p -> p.id }) { index, product ->
                var saved by remember { mutableStateOf(false) }

                Column(
                    modifier = Modifier
                        .width(160.dp)
                        .clickable(onClickLabel = "open product") { /* open */ }
                        .semantics {
                            collectionItemInfo = CollectionItemInfo(
                                rowIndex = 0, rowSpan = 1,
                                columnIndex = index, columnSpan = 1
                            )
                            // The stock badge is inside the merged node and
                            // contributes nothing on its own.
                            product.badge?.let { stateDescription = it }
                            // Add to cart reaches the user here rather than as
                            // a second stop inside the tile.
                            customActions = listOf(
                                CustomAccessibilityAction(
                                    label = if (saved) "Remove from cart" else "Add to cart"
                                ) { saved = !saved; true }
                            )
                        }
                ) {
                    // The name and price are rendered below and merge into the
                    // tile's name, so naming the image would repeat them.
                    Image(
                        painter = painterResource(R.drawable.product),
                        contentDescription = null,
                        modifier = Modifier.height(120.dp).fillMaxWidth()
                    )
                    Text(product.name)
                    Text(product.price)
                }
            }
        }

        // The shelf name is in the button's label, because "See all" repeated
        // down a browse screen names nothing.
        TextButton(
            onClick = { /* open shelf */ },
            modifier = Modifier.semantics { contentDescription = "See all in $shelfTitle" }
        ) {
            Text("See all")
        }
    }
}
```
