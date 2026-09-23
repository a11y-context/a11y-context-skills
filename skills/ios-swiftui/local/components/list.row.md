---
id: list.row
title: List Row (Navigable)
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [list-row, navigation, navigationlink, drill-in, disclosure]
aliases: [navigation row, drill-in row, NavigationLink, settings row, disclosure row, list item]
summary: A NavigationLink rendered as a row in a List, where the whole row is one target that drills into another in-app screen and reads as a button to VoiceOver, with a decorative trailing disclosure chevron.
---

# List Row (Navigable)

Pattern ID: `list.row`

A `NavigationLink` rendered as a row in a `List`, where the whole row is one target that drills into another in-app screen and reads as a button to VoiceOver, with a decorative trailing disclosure chevron.

## Use When
- Use when tapping a row pushes another in-app screen and the whole row is the target (e.g., a "Settings" row that opens the Settings detail, a message that opens a thread). Uses a `NavigationLink` inside a `List`, so the row exposes the button trait and the system supplies the disclosure chevron.
- Use when a scrolling set of such rows forms a navigable list (a settings list, an inbox, a menu of sections).

## Do Not Use When
- Do not use when the control performs an in-place action and stays on the current screen (use `button.basic`).
- Do not use when the control opens a URL or leaves the app (use `link.basic`).
- Do not use when the row is a static, non-navigating list item (use `list.basic`).

## Must Haves
- Use a `NavigationLink` inside a `List` (or `Form`) so the whole row is a single accessible element with the button trait, and the system renders the decorative trailing disclosure chevron.
- The row has an accessible name describing its destination, taken from the row's visible label. When the row shows a title plus secondary text (subtitle or trailing value), they read together as one name.
- The row reads as a button, not a link. `NavigationLink` carries the button trait, not `.isLink`. Do not describe an in-app drill-in row as a "link".
- Keep the disclosure chevron decorative; do not give it a separate accessible element or label. Inside a `List`, `NavigationLink` supplies and hides it automatically.
- Follow the push and pop focus contract in `global_rules.md` (`global.navigation-focus`): the destination sets a `navigationTitle`, the system manages VoiceOver focus on push, and focus returns to this row on pop.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a drill-in row from `Text` or an `HStack` with an `.onTapGesture`; it exposes no button trait, is unreachable and inoperable for Switch Control and Full Keyboard Access, and leaves focus unmanaged so VoiceOver can land behind the pushed screen.
- Do not call a navigable row a "link" in its accessible name; VoiceOver announces it as a button, and "link" misleads users about where it goes.
- Do not add a separate accessible element or label to the disclosure chevron.
- Do not split a rich row into multiple sibling accessibility elements (title, subtitle, and chevron each focusable); combine them into one.
- Do not force VoiceOver focus to the back button or the destination title on push; let the system manage it, per `global.navigation-focus`.

## Customizable
- The row content may be a plain text label or a richer layout (title plus subtitle, a leading icon, a trailing value), as long as it resolves to one accessible element with a coherent name. If a custom row layout fragments into separate elements, combine them with `.accessibilityElement(children: .combine)`.
- The destination may be supplied by the value-based `NavigationLink(value:)` paired with `.navigationDestination(for:)`, or by the closure-based `NavigationLink { } label: { }`; both carry the same button semantics and system focus management.
- The trailing accessory may be the default disclosure chevron or a custom trailing element, provided it stays decorative and the whole row remains the single target.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct ListRowDemo: View {
    var body: some View {
        NavigationStack {
            List {
                // Whole row is one button-trait target; List supplies the decorative chevron.
                NavigationLink {
                    SettingDetail(title: "Account")
                } label: {
                    Text("Account")
                }

                // Rich row: title and subtitle combine into one accessible element automatically.
                NavigationLink {
                    SettingDetail(title: "Wi-Fi")
                } label: {
                    VStack(alignment: .leading) {
                        Text("Wi-Fi")
                        Text("Connected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingDetail: View {
    let title: String

    var body: some View {
        Text("\(title) settings")
            .navigationTitle(title) // destination has a title so the push is announced by name
    }
}
```
