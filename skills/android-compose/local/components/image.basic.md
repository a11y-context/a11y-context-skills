---
id: image.basic
title: Image
stack: android/compose
status: beta
latest_version: 0.1.1
tags: [image, icon, picture, graphic, decorative, informative, contentDescription]
aliases: [Image, Icon, AsyncImage, picture, photo, illustration, graphic, logo, status icon, decorative image, alt text]
summary: Picture or icon whose accessibility comes down to one decision about what it means. A meaningful image is named for what it conveys, a decorative one passes null and leaves the tree, and an empty string is not decorative.
---

# Image

Pattern ID: `image.basic`

Picture or icon whose accessibility comes down to one decision about what it means. A meaningful image is named for what it conveys, a decorative one passes `null` and leaves the tree, and an empty string is not decorative.

The empty string is where web habits break. On the web, `alt=""` is how an image is marked decorative. In Compose, `contentDescription = ""` is not `null`: `Image` and `Icon` still apply their semantics, with `Role.Image` and an empty name. Only `null` removes the image from the tree.

## Use When
- Use when a picture or icon conveys information the surrounding text does not (e.g., a product photo on a detail screen, a standalone status icon, a chart).
- Use when an image is decorative and needs to be kept out of the way of a screen reader (e.g., a background illustration, an icon beside text that already says the same thing).
- Use when an image contains text, such as a logo or a wordmark.

## Do Not Use When
- Do not use when the icon is the content of a control the user taps (use `button.basic`).
- Do not use when the image is the thumbnail inside a list row (use `list-item.basic`).
- Do not use when the image is a tile in a horizontally scrolling strip (use `content-shelf.basic`).
- Do not use when the graphic shows that work is in progress (use `progress-indicator.basic`).

## Must Haves
- Decide whether the image carries meaning before writing it. `Image` and `Icon` take `contentDescription` as a required parameter with no default, so every call site makes this choice explicitly (`global.icon`).
- Give a meaningful image a `contentDescription` naming what it conveys in context, not what it depicts. A green check beside an order is "Delivered", not "Green check mark".
- Give a decorative image `contentDescription = null`. It then applies no semantics at all and TalkBack does not stop on it.
- Pass `null` for a decorative image, never `""`. An empty string still applies `Role.Image` with an empty name, so the image stays in the tree.
- Give an image of text a `contentDescription` that matches the text it shows (e.g., a wordmark logo named with the company name).
- Give a complex image, such as a chart or a map, a short `contentDescription` stating its conclusion (e.g., "Weekly views, rising from 1,200 to 3,400"), and make the full data available as visible text or a table nearby, or one step away on another screen (e.g., a "View data" action beside the chart).
- Name a meaningful graphic drawn without `Image` or `Icon` yourself. `Modifier.paint`, `Canvas`, and `Modifier.background` apply no semantics, so set `Modifier.semantics { contentDescription = "..."; role = Role.Image }` on it, or it does not exist to a screen reader.
- Convey a status shown by an icon in more than its color. A red dot and a green dot that differ only in hue need a `contentDescription` each, or visible text beside them (`global.use-of-color`).

## Don'ts
- Do not pass `contentDescription = ""` to mark an image decorative. Use `null`.
- Do not describe the artwork when the image stands for something. A red circled cross on a failed upload is named "Upload failed", not "Red X".
- Do not name an image whose meaning the adjacent text already states. Both reach the user, and they hear the same thing twice.
- Do not open a description with "Image of" or "Picture of". `Image` and `Icon` apply `Role.Image`, and TalkBack announces the role on its own.
- Do not use a file name, an asset ID, or a generic word such as "image" or "icon" as the description.
- Do not render text as an image where a `Text` would do. Text in a bitmap does not scale with the user's font size (`global.text-scaling`).
- Do not use `Modifier.semantics { invisibleToUser() }` to hide a graphic. It is deprecated; `hideFromAccessibility()` replaces it, and for an `Image` or `Icon` passing `null` is simpler than either.

## Customizable
- The image may be loaded from resources, a bitmap, a vector, or the network through a library such as Coil's `AsyncImage`. Every one of these takes the same `contentDescription` parameter with the same meaning.
- `contentScale`, clipping, and shape are visual choices with no effect on the accessible name.
- A decorative illustration assembled from several drawn shapes may be removed in one step with `Modifier.semantics { hideFromAccessibility() }` on its container, instead of handling each shape.
- A long description may live in visible text below the image, or on a screen the user reaches from it, rather than in `contentDescription`, provided the `contentDescription` still states what the image is.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun ImageExamples(views: List<Int>) {
    Column {
        Image(
            painter = painterResource(R.drawable.skillet_hero),
            contentDescription = "Cast iron skillet, 12 inch, pre-seasoned"
        )

        Image(
            painter = painterResource(R.drawable.kitchen_illustration),
            contentDescription = null
        )

        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Filled.CheckCircle, contentDescription = null)
            Text("Delivered September 26")
        }

        Icon(Icons.Filled.Error, contentDescription = "Upload failed")

        Image(
            painter = painterResource(R.drawable.wordmark),
            contentDescription = "Acme Kitchen"
        )

        Canvas(
            modifier = Modifier
                .fillMaxWidth()
                .height(160.dp)
                .semantics {
                    contentDescription = "Weekly views, rising from 1,200 to 3,400"
                    role = Role.Image
                }
        ) {
            // draw the line chart from `views`
        }
    }
}
```
