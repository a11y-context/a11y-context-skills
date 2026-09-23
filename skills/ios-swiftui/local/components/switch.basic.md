---
id: switch.basic
title: Switch
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [switch, toggle, settings, on-off, form-control]
aliases: [toggle switch, preference toggle, settings toggle, Toggle, UISwitch]
summary: Native SwiftUI Toggle representing a persistent on/off setting. The label and switch state merge into a single accessible element.
---

# Switch

Pattern ID: `switch.basic`

Native SwiftUI `Toggle` representing a persistent on/off setting. The label and switch state merge into a single accessible element.

## Use When
- Use when a control represents a persistent binary setting that remains on or off beyond the current interaction (e.g., "Enable notifications", "Dark mode"). Uses a native SwiftUI `Toggle`, whose label and switch state merge into a single accessible element.
- Use when the setting takes effect immediately when toggled, without requiring form submission.
- Use when the control reflects the current state of a system or application preference.

## Do Not Use When
- Do not use when the control triggers an in-place action or transient feature toggle within the current context (use `button.toggle`).
- Do not use when more than two states are required, or the state cycles through several values (use `button.toggle`).

## Must Haves
- Use the native `Toggle` control rather than a custom composition, and pass the label directly into the initializer (e.g., `Toggle("Enable notifications", isOn: $binding)`) so the label, switch role, and on/off state merge into a single accessible element.
- The switch has an accessible name that describes the setting. Often this is worded to be true when the switch is on (e.g., "Enable notifications").
- When there is no unique visible label (e.g., repeated switches in a list sharing generic visual text), give each `Toggle` a unique, specific `.accessibilityLabel`.
- When the on/off state is represented by visible value text other than "On"/"Off" (e.g., "Allowed"/"Blocked", "Dark"/"Light"), set `.accessibilityValue` to match so VoiceOver announces the correct state instead of defaulting to generic On/Off wording.
- The off-state fill maintains at least 3:1 contrast against the adjacent background, so the off state is distinguishable by more than color (a plain light gray is a common offender).
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a switch out of a custom `HStack` of `Text` plus a shape-based knob without grouping it. Without an explicit `Toggle` (or `.accessibilityElement(children: .combine)`), the label and the control become two disconnected accessibility elements instead of one combined name-and-state announcement.
- Do not leave `.accessibilityValue` mismatched with the visible value text when the switch shows custom state wording instead of On/Off.
- Do not rely on color alone (e.g., green vs. gray) to convey on/off state; the off state must remain distinguishable through sufficient contrast.

## Customizable
- A custom `.toggleStyle` may restyle appearance (color, shape, knob position) as long as it continues to wrap a real `Toggle` underneath, preserving native semantics rather than rebuilding the control from scratch.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct SwitchBasicDemo: View {
    @State private var notifications = false
    @State private var displayMode = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Native Toggle: label, switch, and state merge into one accessible element
            Toggle("Enable notifications", isOn: $notifications)

            // Custom value text instead of On/Off; accessibilityValue must match
            Toggle(isOn: $displayMode) {
                Text("Display Mode")
            }
            .accessibilityValue(displayMode ? "Dark" : "Light")
        }
    }
}
```
