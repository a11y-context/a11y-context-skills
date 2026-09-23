---
id: button.basic
title: Basic Button
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [button, control, action, icon-button]
aliases: [btn, primary button, icon button, call to action, cta]
summary: SwiftUI Button that triggers an action. Supports text-only, icon+text, and icon-only labeling patterns.
---

# Basic Button

Pattern ID: `button.basic`

SwiftUI `Button` that triggers an action. Supports text-only, icon+text, and icon-only labeling patterns.

## Use When
- Use when the user triggers an immediate action and stays on the current screen (e.g., "Save", "Add to List", "Play"), including opening a popover, modal, or bottom sheet.

## Do Not Use When
- Do not use when the control represents an on/off pressed state (use `button.toggle`).
- Do not use when the control drills into a new in-app screen (use `list.row`).
- Do not use when the control opens a URL or leaves the app (use `link.basic`).

## Must Haves
- Use a native `Button` for built-in VoiceOver semantics, the `.isButton` trait, and Switch Control / external-keyboard activation.
- The button has an accessible name that describes its purpose or action.
- When the button has visible text, the visible text serves as the accessible name.
- When additional context is needed beyond the visible text, add it via `.accessibilityLabel`, with the visible text appearing at the start of the label.
- For icon-only buttons, provide an accessible name via `.accessibilityLabel`.
- When multiple buttons on the same screen share visible text (e.g., a repeated "Edit" button per row), give each one a unique, specific `.accessibilityLabel` (e.g., "Edit Username") so VoiceOver users can distinguish them.
- Keep icons inside a button decorative to VoiceOver. `Image(systemName:)` inside a `Button` is decorative by default; label the button as a whole rather than adding a separate `.accessibilityLabel` to the icon.
- If the action is unavailable, disable the button with `.disabled(true)` so it becomes non-interactive and is announced as dimmed.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not include the word "Button" in `.accessibilityLabel`. VoiceOver already appends the "Button" trait, so this makes it announce "Button, Button".
- Do not create icon-only buttons without an `.accessibilityLabel` (no unlabeled icons).
- Do not use an `.accessibilityLabel` that conflicts with (or is wildly different from) the visible label text. Accessible names should at least begin with the visible label.

## Customizable
- An `.accessibilityHint` may be added when the result of the action is not obvious from the visible label (e.g., a song title that plays on tap might use "Plays the song."). Most buttons with a clear action label ("Save", "Delete") do not need one. Hints describe the result in third-person singular, never the gesture or control type ("button", "tap").

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct ButtonBasicDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            // Text-only
            Button("Save") {
                print("Saved")
            }

            // Icon + text
            Button {
                print("Downloaded")
            } label: {
                Label("Download", systemImage: "arrow.down.circle")
            }

            // Icon-only (must have accessible name)
            Button {
                print("Settings")
            } label: {
                Image(systemName: "gearshape")
            }
            .accessibilityLabel("Open settings")

            // Disabled
            Button("Disabled") {
                print("Won't fire")
            }
            .disabled(true)
        }
    }
}
```
