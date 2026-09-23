---
id: radio.basic
title: Radio Button
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [radio, radio-group, selection, single-choice, mutually-exclusive]
aliases: [radio button, radio group, option button, single-select, mutually exclusive choice, custom radio]
summary: A mutually exclusive choice group built from custom Button elements, since SwiftUI has no native radio control, using the selected trait plus an accessibilityValue to announce the radio role and its checked or unchecked state.
---

# Radio Button

Pattern ID: `radio.basic`

A mutually exclusive choice group built from custom `Button` elements, since SwiftUI has no native radio control, using the selected trait plus an `.accessibilityValue` to announce the radio role and its checked or unchecked state.

## Use When
- Use when exactly one option must be chosen from a small, mutually exclusive set that stays fully visible as a list of selectable rows (e.g., "Choose color", "Choose a size"). Built from custom `Button` elements, since SwiftUI has no native radio control.
- Use when the always-visible radio layout is preferred over a control that collapses the choices behind a pop-up.

## Do Not Use When
- Do not use when any number of options in the group may be selected, including none (use `checkbox.basic`).
- Do not use when the control is a single persistent on/off setting that takes effect immediately (use `switch.basic`).
- Do not use when two to five options fit inline and each takes effect immediately on tap (use `select.segmented`).
- Do not use when one choice is made from a longer set and a compact pop-up button is preferred over an expanded list (use `select.menu`).

## Must Haves
- Build each option from a native `Button` styled to look like a radio, rather than a bare tap gesture on a shape, so the option stays operable by Switch Control and Full Keyboard Access even after the button trait is removed (see `global.custom-control-representation`; the custom-drawn circle is the visual, the `Button` supplies the operability).
- Remove the button trait from each option with `.accessibilityRemoveTraits(.isButton)`, since SwiftUI exposes no native radio trait and "Button" would misdescribe the control.
- Add the selected trait to the chosen option and remove it from the others (`.accessibilityAddTraits(.isSelected)` / `.accessibilityRemoveTraits(.isSelected)`), so VoiceOver announces which option is selected.
- Override the announced value on every option with `.accessibilityValue`, "Radio button, checked" for the selected option and "Radio button, unchecked" for the rest, so VoiceOver conveys the radio role and the option's state that no native trait supplies.
- Label the group container: apply `.accessibilityElement(children: .contain)` and an `.accessibilityLabel` matching the visible group heading, so VoiceOver announces the group name when focus first enters it.
- Each option has an accessible name matching its visible label text.
- The selected state is distinguishable by more than color: the radio glyph itself changes (an empty circle versus a filled or ringed circle), not only a color fill (per `global.semantic-color`).
- Let the radio glyph scale with the label under Dynamic Type; size it with the surrounding font rather than a fixed point frame that would clip at large sizes (per `global.dynamic-type`).
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not leave the options as plain `Button` elements with no trait or value changes; VoiceOver then announces each as a generic button with no indication that they form a single-select group or which one is selected.
- Do not build the option from a bare tap gesture on a shape; it becomes unreachable and inoperable for VoiceOver, Switch Control, and Full Keyboard Access.
- Do not omit the group label; without `.accessibilityElement(children: .contain)` plus `.accessibilityLabel`, VoiceOver users do not hear what the group is for.
- Do not convey the selected state by color alone; change the radio glyph.
- Do not fix the glyph to a static point size that fails to scale with Dynamic Type.

## Customizable
- Each option may render as a classic labeled circle or as a selectable card in a grid, as long as it wraps a real `Button`, keeps the selected state distinguishable without color, and carries the selected trait and value.
- The value wording may match the domain when it reads more clearly, as long as it conveys the radio role and reflects the checked or unchecked state and stays in sync with the visible selection.
- A native `Picker` may be used instead when a collapsed single-select control is acceptable; the custom radio group is for when an always-expanded set of radio options is specifically required.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct RadioGroupDemo: View {
    private let options = ["Black", "Gray", "White", "Red"]
    @State private var selected = "Black"

    var body: some View {
        // The container carries the group label so VoiceOver announces it
        // when focus first enters the group; it matches the visible heading.
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose color")

            ForEach(options, id: \.self) { option in
                RadioButton(title: option, isSelected: selected == option) {
                    selected = option
                    print("selected \(option)")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Choose color")
    }
}

struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        // A real Button underneath keeps Switch Control and keyboard operability;
        // the glyph change (not color) distinguishes selected from unselected,
        // and imageScale lets it grow with Dynamic Type.
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .imageScale(.large)
                Text(title)
            }
        }
        .accessibilityRemoveTraits(.isButton) // no native radio trait exists
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityRemoveTraits(isSelected ? [] : .isSelected)
        .accessibilityValue(isSelected ? "Radio button, checked" : "Radio button, unchecked")
    }
}
```
