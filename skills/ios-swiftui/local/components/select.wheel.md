---
id: select.wheel
title: Select (Wheel)
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [picker, select, wheel, spinner, single-choice]
aliases: [picker, wheel picker, spinner, drum picker, WheelPickerStyle, single select]
summary: A SwiftUI Picker with the wheel style, an always-visible spinning drum of values that requires an accessibilityLabel matching its visible label plus accessibilityElement(children:.contain) for VoiceOver to speak the name.
---

# Select (Wheel)

Pattern ID: `select.wheel`

A SwiftUI `Picker` with the wheel style: an always-visible spinning drum of values that requires an `.accessibilityLabel` matching its visible label plus `.accessibilityElement(children: .contain)` for VoiceOver to speak the name.

## Use When
- Use when the user chooses one value from a fixed set shown as an always-visible spinning drum the user scrolls in place (e.g., a quantity, a unit, a short list of options). Uses a SwiftUI `Picker` with `.pickerStyle(.wheel)`.
- Use when the option set is best browsed by scrolling and the wheel is meant to stay on screen rather than pop up.

## Do Not Use When
- Do not use when the choice should collapse into a compact pop-up button that shows only the current value (use `select.menu`).
- Do not use when the choice is among two to five options that fit inline as segments (use `select.segmented`).
- Do not use when the value is a date or time (use `date-picker.basic`, which provides the correct wheel semantics and formatting).
- Do not use when the items are commands or actions rather than a single selected value (use `menu.basic`).

## Must Haves
- Use a native `Picker` with `.pickerStyle(.wheel)` so it exposes the wheel's role, the current value, and the option list to VoiceOver and Switch Control.
- Add an `.accessibilityLabel` whose text matches the picker's visible label (e.g., `.accessibilityLabel("Fruit")`), and set `.accessibilityElement(children: .contain)` on the picker. Without both, VoiceOver speaks neither the `Picker` label text nor the `.accessibilityLabel`, leaving the wheel unnamed.
- This is the opposite of the menu and default styles: a menu-style `Picker` is named by its `Picker` label text and must not carry an `.accessibilityLabel` (see `select.menu`), whereas the wheel style requires the `.accessibilityLabel` plus `.contain` to be named at all.
- Provide a visible label for the wheel so sighted users know what is being chosen, and keep the `.accessibilityLabel` matching it.
- Each option has clear, distinct text so the values are distinguishable as they scroll under VoiceOver.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not omit `.accessibilityElement(children: .contain)` on a wheel-style `Picker`; without it the accessibility label is not spoken and the wheel is announced with no name.
- Do not rely on the `Picker` label text alone to name a wheel-style picker; unlike the menu and default styles, wheel-style ignores it for VoiceOver naming.
- Do not leave the wheel unlabeled (`Picker("", ...)` with no `.accessibilityLabel`); VoiceOver then has no accessible name for it.
- Do not use a wheel-style value `Picker` for a list of commands or actions; that is a `menu.basic`.

## Customizable
- The current selection may also be shown in a separate visible `Text` (e.g., "Fruit: Apple") above the wheel, as long as it stays in sync with the binding.
- The option set may be static (a `ForEach` over a `CaseIterable` enum) or dynamic, as long as each option has stable, distinct text and a `.tag` matching the selection type.
- The visible label may be supplied by the `Picker` label text, a preceding `Text`, or both; the `.accessibilityLabel` must match whichever visible text names the wheel.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct SelectWheelDemo: View {
    enum Fruit: String, CaseIterable, Identifiable {
        case apple = "Apple", banana = "Banana", cherry = "Cherry", grape = "Grape"
        var id: Self { self }
    }

    @State private var fruit: Fruit = .apple

    var body: some View {
        // Wheel style names itself ONLY with .accessibilityLabel + .contain.
        // This is the opposite of the menu style, which is named by its Picker label text.
        Picker("Fruit", selection: $fruit) {
            ForEach(Fruit.allCases) { fruit in
                Text(fruit.rawValue).tag(fruit)
            }
        }
        .pickerStyle(.wheel)
        .accessibilityElement(children: .contain) // required, or the label is not spoken
        .accessibilityLabel("Fruit")               // must match the visible label text
    }
}
```
