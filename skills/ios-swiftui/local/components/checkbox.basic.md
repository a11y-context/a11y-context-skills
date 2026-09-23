---
id: checkbox.basic
title: Checkbox
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [checkbox, form, selection, toggle, checkbox-group]
aliases: [check box, tickbox, form checkbox, Toggle checkbox, agree checkbox, multi-select]
summary: A checkbox built from a SwiftUI Toggle with a custom square toggle style, using accessibilityValue to announce Checked or Unchecked, since SwiftUI has no native checkbox control or trait.
---

# Checkbox

Pattern ID: `checkbox.basic`

A checkbox built from a SwiftUI `Toggle` with a custom square toggle style, using `.accessibilityValue` to announce Checked or Unchecked, since SwiftUI has no native checkbox control or trait.

## Use When
- Use when the user selects an independent binary option that is submitted with a form rather than taking effect immediately (e.g., "Accept Terms", "Remember me"). Uses a SwiftUI `Toggle` with a custom square `.toggleStyle`, since SwiftUI has no native checkbox control.
- Use when several such options form a group where any number may be selected (e.g., "Preferred contact method(s)": Email, Phone, Text).

## Do Not Use When
- Do not use when the control is a persistent on/off setting that takes effect immediately (use `switch.basic`).
- Do not use when the control toggles a feature in place within the current context (use `button.toggle`).
- Do not use when exactly one option must be chosen from a mutually exclusive set (use `radio.basic`).

## Must Haves
- Build the checkbox from a native `Toggle` with a custom `.toggleStyle` that draws the square box and checkmark (e.g., `square` when unchecked, `checkmark.square` when checked), rather than a `Button` or a bare tap gesture, so it keeps the underlying control semantics and stays operable by Switch Control and Full Keyboard Access.
- The checkbox has an accessible name matching its visible label; pass the label into the `Toggle` (e.g., `Toggle("Accept Terms", isOn: $accepted)` or the label closure).
- Override the announced value with `.accessibilityValue(isChecked ? "Checked" : "Unchecked")` so VoiceOver speaks Checked or Unchecked instead of the default On or Off.
- For a checkbox group, label the container: apply `.accessibilityElement(children: .contain)` and an `.accessibilityLabel` matching the visible group heading, so VoiceOver announces the group name when focus first enters it.
- The checked and unchecked states are distinguishable by more than color: the box glyph itself changes (empty square versus checkmark), not only a color fill (per `global.semantic-color`).
- Let the box glyph scale with the label under Dynamic Type; size it with the surrounding font (e.g., `.imageScale`) rather than a fixed point frame that would clip at large sizes.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a checkbox from a `Button` that swaps a checkmark image; VoiceOver then announces "Button" with no Checked or Unchecked value, and the state is invisible to screen reader users.
- Do not leave the checkbox announcing the default On or Off; set `.accessibilityValue` to Checked or Unchecked.
- Do not omit the group label on a set of related checkboxes; without `.accessibilityElement(children: .contain)` plus `.accessibilityLabel`, VoiceOver users do not hear what the group is for.
- Do not convey the checked state by color alone; change the box glyph.
- Do not fix the glyph to a static point size that fails to scale with Dynamic Type.

## Customizable
- The custom `.toggleStyle` may draw any recognizable checkbox appearance (square outline, filled check, rounded box) as long as it wraps a real `Toggle`, keeps the state distinguishable without color, and preserves the label and value.
- The value wording may match the domain when it reads more clearly than Checked or Unchecked (e.g., "Selected"/"Not selected"), as long as it reflects the binary state and stays in sync with the visible box.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct CheckboxDemo: View {
    @State private var acceptedTerms = false
    @State private var email = false
    @State private var phone = false
    @State private var text = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Single checkbox: Toggle + square style; value overridden to Checked/Unchecked
            Toggle("Accept Terms", isOn: $acceptedTerms)
                .toggleStyle(CheckboxToggleStyle())
                .accessibilityValue(acceptedTerms ? "Checked" : "Unchecked")

            // Checkbox group: the container carries the group label so VoiceOver
            // announces it when focus first enters the group.
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Email", isOn: $email)
                    .toggleStyle(CheckboxToggleStyle())
                    .accessibilityValue(email ? "Checked" : "Unchecked")
                Toggle("Phone", isOn: $phone)
                    .toggleStyle(CheckboxToggleStyle())
                    .accessibilityValue(phone ? "Checked" : "Unchecked")
                Toggle("Text", isOn: $text)
                    .toggleStyle(CheckboxToggleStyle())
                    .accessibilityValue(text ? "Checked" : "Unchecked")
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Preferred contact method(s)")
        }
    }
}

// A real Toggle underneath keeps Switch Control and keyboard operability; the glyph
// change (not color) distinguishes checked from unchecked, and it scales with Dynamic Type.
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .imageScale(.large)
            configuration.label
        }
        .contentShape(Rectangle())
        .onTapGesture { configuration.isOn.toggle() }
    }
}
```
