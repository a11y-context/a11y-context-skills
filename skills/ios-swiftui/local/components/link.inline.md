---
id: link.inline
title: Inline Link
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [link, inline-link, hyperlink, attributed-string, markdown, text]
aliases: [inline link, text link, hyperlink in text, AttributedString link, markdown link, in-paragraph link]
summary: A hyperlink embedded in a run of Text via an AttributedString .link run (preferred) or Markdown, reachable through the VoiceOver Links rotor but non-operable under Full Keyboard Access and Voice Control because of Apple platform defects.
---

# Inline Link

Pattern ID: `link.inline`

A hyperlink embedded in a run of `Text` via an `AttributedString` `.link` run (preferred) or Markdown, reachable through the VoiceOver Links rotor but non-operable under Full Keyboard Access and Voice Control because of Apple platform defects.

Inline links inherit two Apple platform defects that a standalone `Link` control does not. Prefer `link.basic` whenever the hyperlink can stand as its own control or on its own line; reach for an inline link only when the hyperlink must sit inside a sentence, and always pair it with an operable alternative.

## Use When
- Use when a hyperlink must appear inside a running sentence or paragraph, surrounded by static text (e.g., "By continuing you agree to the Terms of Service."). Uses an `AttributedString` `.link` run (preferred) or Markdown inside a `Text`.

## Do Not Use When
- Do not use when the link can stand as its own control or on its own line (use `link.basic`, which is fully operable with Full Keyboard Access and Voice Control).
- Do not use when the target is an in-app screen rather than a URL (use `list.row`).
- Do not use when the control performs an in-app action rather than opening a URL (use `button.basic`).

## Must Haves
- Build the inline link with an `AttributedString` whose run sets `.link` to the URL, in preference to Markdown, because only `AttributedString` can also carry an underline to distinguish the link without color.
- Distinguish the inline link from surrounding text by more than color: set `.underlineStyle` on the `AttributedString` run. Markdown inline links cannot be underlined or restyled, so they cannot satisfy this on their own.
- The link run text is specific to its destination; avoid generic runs like "here" or "click here".
- Link text meets 4.5:1 contrast against its background in light and dark appearances (per `global.semantic-color`); the default inline link tint can fall below 4.5:1.
- Provide a fully operable alternative to the same destination for keyboard and Voice Control users. `AttributedString` and Markdown inline links are not focusable under Full Keyboard Access and not targetable by Voice Control Show Names or Show Numbers, an Apple platform defect. Supply a standalone `link.basic` to the same URL, or keep destinations that must be operable out of inline links.
- Keep each inline link's text meaningful on its own, because VoiceOver users reach inline links through the Links rotor, which lists them by name out of surrounding context.

## Don'ts
- Do not rely on an inline link as the only way to reach a destination that keyboard or Voice Control users must operate; the platform defect leaves it unreachable for them without a standalone alternative.
- Do not distinguish an inline link by color alone; set an underline via `AttributedString`.
- Do not use Markdown inline links when conformance depends on distinguishing the link without color, since Markdown links cannot be underlined or given a different text style than the surrounding run.
- Do not use generic inline link text ("here", "click here", "read more") that is not meaningful in the Links rotor.

## Customizable
- The underline is required for distinction, but its exact style (single, thick) is at the engineer's discretion as long as the link stays distinguishable without color.
- The operable alternative may be a visible standalone `link.basic`, or a repetition of the destination elsewhere on the screen as a `Link`, as long as keyboard and Voice Control users can reach the same URL.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct InlineLinkDemo: View {
    // AttributedString inline link: a settable underline distinguishes it without color alone.
    var agreement: AttributedString {
        var text = AttributedString("By continuing you agree to the Terms of Service.")
        if let range = text.range(of: "Terms of Service") {
            text[range].link = URL(string: "https://www.example.com/terms")
            text[range].underlineStyle = Text.LineStyle(nsUnderlineStyle: .single)
        }
        return text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(agreement)

            // Operable alternative to the same destination for Full Keyboard Access and
            // Voice Control users, who cannot reach the inline link above (Apple platform defect).
            Link("Read the Terms of Service", destination: URL(string: "https://www.example.com/terms")!)
                .accessibilityRemoveTraits(.isButton)
        }
    }
}
```
