---
id: link.basic
title: Link
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [link, url, hyperlink, external, navigation]
aliases: [hyperlink, url link, external link, Link, web link, open url]
summary: SwiftUI Link that opens a URL or web view, exposing the link trait (with the redundant button trait removed) so VoiceOver signals that activating it leaves the app.
---

# Link

Pattern ID: `link.basic`

SwiftUI `Link(destination:)` that opens a URL or web view, exposing the link trait (with the redundant button trait removed) so VoiceOver signals that activating it leaves the app.

## Use When
- Use when a standalone control opens a URL in the browser or an in-app web view, or otherwise leaves the current app context (e.g., "View Weekly Ad", "Open Help Center", "Privacy Policy"). Uses a native SwiftUI `Link(destination:)`, whose link trait tells VoiceOver the control exits the app.
- Use when the destination is a web address rather than an in-app screen.

## Do Not Use When
- Do not use when the control triggers an immediate action and stays on the current screen (use `button.basic`).
- Do not use when the control drills into another in-app screen (use `list.row`).
- Do not use when the hyperlink sits inline within a run of paragraph text (use `link.inline`).

## Must Haves
- Use a native `Link(destination:)` so the control exposes the link trait and opens the URL through the system.
- The link has an accessible name that describes its specific destination or purpose. When the link has visible text, the visible text serves as the accessible name.
- Remove the redundant button trait when VoiceOver announces the link as "Button, Link": apply `.accessibilityRemoveTraits(.isButton)` so it announces only as a link. SwiftUI has historically added the button trait to `Link` alongside the link trait.
- Link text meets 4.5:1 contrast against its background in both light and dark appearances. Use an accent or tint color vetted for both appearances (per `global.semantic-color`); the default link tint can fall below 4.5:1.
- When the link sits inline with, or directly adjacent to, static text, distinguish it by more than color, e.g., `.underline()` on the label.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not implement a link as a `Button` that calls `UIApplication.shared.open(url)`; VoiceOver then announces "Button" instead of "Link", hiding that the control leaves the app.
- Do not use generic link text ("Click here", "here", "Read more", "Learn more") that does not describe the destination; the accessible name must be specific.
- Do not rely on color alone to mark a link placed among static text; add an underline or other non-color distinction.
- Do not leave the default button trait in place when it produces a "Button, Link" announcement.
- Do not include the word "Link" in the accessible name; VoiceOver already appends the link trait.

## Customizable
- The accessible name is normally the visible link text. When the visible text cannot be made specific on its own, add an `.accessibilityLabel` naming the destination, with the visible text appearing at the start of the label.
- The destination may open in the default browser or in an in-app web view (e.g., `SFSafariViewController`); the link trait and the labeling and contrast requirements are the same either way.
- An `.accessibilityHint` may be added when the destination is not obvious from the visible text (e.g., "Opens in your browser."). Most links with specific text do not need one.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct LinkBasicDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Standalone link: specific text; button trait removed so VoiceOver says only "Link".
            // The link tint must meet 4.5:1 in light and dark (set via AccentColor or .tint);
            // the default tint can fall short.
            Link("View Weekly Ad", destination: URL(string: "https://www.example.com/weekly-ad")!)
                .accessibilityRemoveTraits(.isButton)

            // Adjacent to static text: underline so it is distinct without color alone
            HStack(spacing: 4) {
                Text("Questions? Read our")
                Link(destination: URL(string: "https://www.example.com/help")!) {
                    Text("Help Center")
                        .underline()
                }
                .accessibilityRemoveTraits(.isButton)
            }

            // Icon + text link still names its destination; the icon stays decorative
            Link(destination: URL(string: "https://www.example.com/privacy")!) {
                Label("Privacy Policy", systemImage: "lock.shield")
            }
            .accessibilityRemoveTraits(.isButton)
        }
    }
}
```
