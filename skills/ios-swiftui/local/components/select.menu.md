---
id: select.menu
title: Select (Menu)
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [picker, select, dropdown, menu, single-choice]
aliases: [picker, menu picker, dropdown, pop-up button, MenuPickerStyle, single select]
summary: A SwiftUI Picker with the menu style, a pop-up button that shows the current value and opens a list to choose one option, named by the Picker label text rather than an accessibilityLabel.
---

# Select (Menu)

Pattern ID: `select.menu`

A SwiftUI `Picker` with the menu style: a pop-up button that shows the current value and opens a list to choose one option, named by the `Picker` label text rather than an `.accessibilityLabel`.

## Use When
- Use when the user chooses one value from a fixed set and the current choice is shown on a compact pop-up button (e.g., "Sort by", "Fruit", "Country"). Uses a SwiftUI `Picker` with `.pickerStyle(.menu)`.
- Use when the option set is longer than fits a segmented control but does not need a full-screen wheel.

## Do Not Use When
- Do not use when the items are commands or actions rather than a single selected value (use `menu.basic`).
- Do not use when the choice is among two to five options that fit inline (use `select.segmented`).
- Do not use when a spinning wheel of values is intended (use `select.wheel`).
- Do not use when the value is free text the user types (use `text-field.basic`).

## Must Haves
- Use a native `Picker` with `.pickerStyle(.menu)` so it exposes the pop-up button role, the current value, and the option list to VoiceOver and Switch Control.
- Name the picker with the `Picker` label text (`Picker("Fruit", selection: $fruit)`), which becomes the accessible name for the menu and default styles.
- Do not add an `.accessibilityLabel` to a menu-style or default-style `Picker`; it suppresses VoiceOver speaking the selected value when the picker is closed. The wheel and segmented styles are the opposite case, covered by `select.wheel` and `select.segmented`.
- Each option has clear, distinct text so the choices are distinguishable in the pop-up list.
- After the value changes, return VoiceOver focus to the picker with `@AccessibilityFocusState` and `.accessibilityFocused`, because `Picker` has no dismissal callback to restore focus.
- Provide a visible indication of what is being chosen when the on-button value alone does not convey it; the `Picker` label text can serve this, or a separate `Text` can precede the picker.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not add `.accessibilityLabel` to a menu-style or default-style `Picker`; it stops VoiceOver from announcing the selected value when closed. Name it through the `Picker` label text instead.
- Do not leave the `Picker` label empty (`Picker("", ...)`) on a menu style; VoiceOver then has no accessible name.
- Do not use a value `Picker` for a list of commands or actions; that is a `menu.basic`.
- Do not omit focus return after selection; without `@AccessibilityFocusState`, VoiceOver focus can jump away from the picker when the value changes.

## Customizable
- The current selection may also be shown in a separate visible `Text` (e.g., "Fruit: Apple") in addition to the on-button value, as long as it stays in sync with the binding.
- The option set may be static (a `ForEach` over a `CaseIterable` enum) or dynamic, as long as each option has stable, distinct text and a `.tag` matching the selection type.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct SelectMenuDemo: View {
    enum Fruit: String, CaseIterable, Identifiable {
        case apple = "Apple", banana = "Banana", cherry = "Cherry", grape = "Grape"
        var id: Self { self }
    }

    @State private var fruit: Fruit = .apple
    @AccessibilityFocusState private var pickerFocused: Bool

    var body: some View {
        // The Picker label ("Fruit") is the accessible name; do NOT add .accessibilityLabel here.
        Picker("Fruit", selection: $fruit) {
            ForEach(Fruit.allCases) { fruit in
                Text(fruit.rawValue).tag(fruit)
            }
        }
        .pickerStyle(.menu)
        .accessibilityFocused($pickerFocused)
        .onChange(of: fruit) {
            pickerFocused = true // return VoiceOver focus to the picker after the value changes
        }
    }
}
```
