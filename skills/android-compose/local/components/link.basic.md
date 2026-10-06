---
id: link.basic
title: Link
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [link, url, external, navigation, web page]
aliases: [standalone link, TextButton link, hyperlink, learn more link, external link, open in browser, LocalUriHandler]
summary: Link that stands on its own and opens a web page or another app. Compose has no link role and no Link composable, so a standalone link is a TextButton whose text names the destination; a text link's tap area is only as large as its letters.
---

# Link

Pattern ID: `link.basic`

Link that stands on its own and opens a web page or another app. Compose has no link role and no Link composable, so a standalone link is a `TextButton` whose text names the destination; a text link's tap area is only as large as its letters.

The two ways to make a link in Compose behave differently. A `LinkAnnotation` in a `Text` is announced as a link, but Compose clips its tap area to the outline of the linked characters, so a short standalone link is a small target with no focus treatment of its own. A `TextButton` is announced as a button, and comes with the 48dp target and the focus indicator a standalone control needs. Outside a sentence, the second is the one that works.

## Use When
- Use when a control outside a paragraph opens a web page, a document, or another app (e.g., "Privacy policy", "Terms of service", "View on map").
- Use when the destination is a place the user goes to, not an action performed on the current screen.

## Do Not Use When
- Do not use when the link sits inside a sentence of body text (use `link.inline`).
- Do not use when activating it performs an action on the current screen, such as saving or deleting (use `button.basic`).
- Do not use when it moves between the app's top-level destinations (use `navigation-bar.basic`).

## Must Haves
- The link reports a click action and a name stating its destination. Compose has no link role, so Material's `TextButton` is the reference implementation, reporting `Role.Button` with a 48dp target and a focus indicator; a design system's own link satisfies it by forwarding to the same semantics, and a hand-assembled one satisfies none of it by default (`global.native-first`).
- Give the link visible text naming its destination specifically (e.g., "Privacy policy", not "Learn more" or "Click here").
- When more context is needed than the visible text carries, set `contentDescription` on the link, opening with the visible text (e.g., "Learn more about cookies").
- Set a click label when the link leaves the app (e.g., "open in browser"), so the user knows activating it takes them out of the app. `TextButton` takes no `onClickLabel` parameter; set it through `Modifier.semantics { onClick(label = "...", action = null) }`, as `button.basic` describes.
- Open the destination through `LocalUriHandler` or an `Intent`, so it opens in the user's browser or the app that handles it.
- Give an icon beside the link's text, such as an external-link arrow, `contentDescription = null` (`global.icon`).
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a standalone link from a `Text` holding a single `LinkAnnotation`. Its tap area is clipped to the outline of its characters, and Material draws no focus indicator for it.
- Do not use `Modifier.clickable` on a `Text` without `role = Role.Button`, an `onClickLabel`, and a 48dp minimum. It is then announced as text the user can activate, with no sign of what it does.
- Do not repeat the same vague text for several links on one screen, such as three "Learn more" links. Each one needs a name that tells it apart.
- Do not use `ClickableText`. It is deprecated, and is a `BasicText` with a tap detector: no link semantics, and nothing a keyboard can reach.

## Customizable
- The link may be a `TextButton`, or a `Text` with `Modifier.clickable(role = Role.Button, onClickLabel = "...")` and `Modifier.heightIn(min = 48.dp)` when it must not look like a button. Both meet the same contract.
- The text may be underlined, or set in the theme's primary color, to read as a link. Where it sits directly beside body text, use the underline, so it is not set apart by color alone (`global.use-of-color`).
- An icon may mark a link that leaves the app. The `onClickLabel` carries that meaning for TalkBack.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun LinkExamples() {
    val uriHandler = LocalUriHandler.current

    Column {
        TextButton(
            onClick = { uriHandler.openUri("https://example.com/privacy") },
            modifier = Modifier.semantics { onClick(label = "open in browser", action = null) }
        ) {
            Text("Privacy policy")
            Icon(
                Icons.AutoMirrored.Filled.OpenInNew,
                contentDescription = null,
                modifier = Modifier.padding(start = 4.dp).size(16.dp)
            )
        }

        TextButton(
            onClick = { uriHandler.openUri("https://example.com/help/cookies") },
            modifier = Modifier.semantics {
                contentDescription = "Learn more about cookies"
                onClick(label = "open in browser", action = null)
            }
        ) {
            Text("Learn more")
        }
    }
}
```
