---
id: link.inline
title: Inline Link
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [link, inline link, hyperlink, text, annotated string]
aliases: [LinkAnnotation, LinkAnnotation.Url, LinkAnnotation.Clickable, withLink, buildAnnotatedString, TextLinkStyles, hyperlink in text, link in paragraph]
summary: Link inside a sentence of body text, built with LinkAnnotation. TalkBack reaches it through its Links menu rather than as a stop of its own, and Material draws nothing when a keyboard focuses it, so the link's text and its focused style are the caller's to get right.
---

# Inline Link

Pattern ID: `link.inline`

Link inside a sentence of body text, built with `LinkAnnotation`. TalkBack reaches it through its Links menu rather than as a stop of its own, and Material draws nothing when a keyboard focuses it, so the link's text and its focused style are the caller's to get right.

Compose does not give an inline link a node of its own. It exposes each `LinkAnnotation` to accessibility services as a span on the surrounding text, a `URLSpan` for a URL and a `ClickableSpan` for an in-app action, and TalkBack lists those spans in its Links menu, out of the sentence they came from. A keyboard can Tab to each link, but the link's node sets no indication and Material's default link style sets no focused state, so the focus lands invisibly.

## Use When
- Use when a link sits inside a sentence or paragraph of body text (e.g., "By continuing, you agree to the terms of service and privacy policy.").
- Use when the linked words are part of the sentence and pulling them out would break it.

## Do Not Use When
- Do not use when the link stands on its own outside body text (use `link.basic`).
- Do not use when activating it performs an action on the current screen rather than opening something (use `button.basic`).

## Must Haves
- Each link is exposed to accessibility services as a link inside its text and is reachable from a keyboard. `LinkAnnotation.Url` and `LinkAnnotation.Clickable`, built with `withLink` in a `buildAnnotatedString` and rendered in Material's `Text`, are the reference implementation: Compose publishes each one as a `URLSpan` or `ClickableSpan` and makes it focusable (`global.native-first`).
- Use `LinkAnnotation.Url` for a web address, and `LinkAnnotation.Clickable` with a `linkInteractionListener` for an action inside the app.
- Give each link text that names its destination on its own (e.g., "privacy policy", not "here" or "this page"). TalkBack's Links menu lists the links by their text alone.
- Set a `focusedStyle` in the link's `TextLinkStyles` that differs from the resting style by more than the text's color, such as a background highlight behind the linked words. Material's default link style sets no focused state, and the link draws no focus indicator of its own (`global.focus-states`).
- Keep an underline on the link's resting style. Material's `Text` applies one by default; custom `TextLinkStyles` replace it, so they have to carry their own (`global.use-of-color`).
- Draw the link's color from the theme's color scheme, so it keeps its contrast against the text and background in light and dark themes (`global.semantic-color`).

## Don'ts
- Do not put a paragraph with inline links inside a clickable row or card. The links are a second set of targets inside a control that already merges its content (`global.merge-semantics`).
- Do not use `ClickableText`. It is deprecated, and is a `BasicText` with a tap detector: no link semantics, and nothing a keyboard can reach.
- Do not set `TextLinkStyles` with a color change alone. The link then differs from the surrounding text only by hue.
- Do not render inline links with `BasicText` and no `TextLinkStyles`. `BasicText` applies no link style, so the link looks like the rest of the sentence.
- Do not make a link carry a whole paragraph's meaning. TalkBack users meet it in the Links menu without the sentence.

## Customizable
- A paragraph may hold several links. Each is its own entry in the Links menu and its own keyboard stop.
- The `focusedStyle` may be a background color, a heavier underline, or both, provided it is visible against both the resting link and the text around it.
- `hoveredStyle` and `pressedStyle` may also be set for pointer and touch feedback; they do not replace `focusedStyle`.
- The tap area of an inline link is the linked text itself, which is expected inside a sentence. A link that must be easy to hit belongs outside the paragraph, in `link.basic`.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun InlineLinkExamples(onOpenSettings: () -> Unit) {
    val linkStyles = TextLinkStyles(
        style = SpanStyle(
            color = MaterialTheme.colorScheme.primary,
            textDecoration = TextDecoration.Underline
        ),
        focusedStyle = SpanStyle(
            background = MaterialTheme.colorScheme.primaryContainer,
            textDecoration = TextDecoration.Underline
        )
    )

    Text(
        buildAnnotatedString {
            append("By continuing, you agree to the ")
            withLink(LinkAnnotation.Url("https://example.com/terms", linkStyles)) {
                append("terms of service")
            }
            append(" and ")
            withLink(LinkAnnotation.Url("https://example.com/privacy", linkStyles)) {
                append("privacy policy")
            }
            append(". You can change this in ")
            withLink(
                LinkAnnotation.Clickable(
                    tag = "settings",
                    styles = linkStyles,
                    linkInteractionListener = { onOpenSettings() }
                )
            ) {
                append("privacy settings")
            }
            append(".")
        }
    )
}
```
