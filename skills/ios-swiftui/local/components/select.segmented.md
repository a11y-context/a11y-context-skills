---
id: select.segmented
title: Select (Segmented)
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [picker, select, segmented, single-choice, mutually-exclusive]
aliases: [segmented control, segmented picker, Picker, SegmentedPickerStyle, UISegmentedControl, single select]
summary: A SwiftUI Picker with the segmented style, showing two to five mutually exclusive options inline where selecting one takes effect immediately, and which requires an accessibilityLabel matching its visible label plus accessibilityElement children contain to be named to VoiceOver.
---

# Select (Segmented)

Pattern ID: `select.segmented`

A SwiftUI `Picker` with the segmented style, showing two to five mutually exclusive options inline where selecting one takes effect immediately, and which requires an `.accessibilityLabel` matching its visible label plus `.accessibilityElement(children: .contain)` to be named to VoiceOver.

## Use When
- Use when the user picks one value from a small fixed set of two to five options that all stay visible at once (e.g., "Day / Week / Month", "Red / Green / Blue"). Uses a SwiftUI `Picker` with `.pickerStyle(.segmented)`.
- Use when the choice takes effect immediately and no confirmation step is needed.
- Use when each option label is short enough that all segments fit inline without truncation.

## Do Not Use When
- Do not use when there are more than five options, or the labels are too long to fit inline, or a compact single-value display is wanted (use `select.menu`).
- Do not use when the intent is to spin through values on a rotating wheel (use `select.wheel`).
- Do not use when the control is a single on/off setting (use `switch.basic`, or `button.toggle` for an in-context toggle).
- Do not use when the segments switch between top-level sections of the app; that is the job of a tab bar, not a selection control (use `tab-bar.basic`).

## Must Haves
- Use a native `Picker` with `.pickerStyle(.segmented)` so the segments expose their selectable roles and current selection to VoiceOver and Switch Control.
- Give the picker an `.accessibilityLabel` that matches its visible label text, AND apply `.accessibilityElement(children: .contain)` to the picker. With the segmented style, the `Picker` label text alone is not spoken; the label is announced only when both modifiers are present. This is the opposite of the menu style in `select.menu`, where an `.accessibilityLabel` is forbidden and the `Picker` label text serves as the name.
- Provide a visible label for the group (the `Picker` label text or a preceding `Text`) so a sighted user knows what the segments choose, and match the `.accessibilityLabel` to it.
- Each segment has clear, distinct text so the options are distinguishable and each `.tag` matches the selection type.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not rely on the `Picker` label text alone to name a segmented picker; without `.accessibilityElement(children: .contain)`, the `.accessibilityLabel` is not spoken and VoiceOver users hear only the segment text, never the group label.
- Do not carry over the menu-style rule of omitting `.accessibilityLabel`; the segmented style is the documented opposite and needs the label set.
- Do not leave the group unlabeled (`Picker("", ...)` with no `.accessibilityLabel`); the segments then have no group name.
- Do not convey the selected segment by color alone; keep the native segmented style so the selection is shown by fill and shape, not only tint.

## Customizable
- The current selection may also be shown in a separate visible `Text` (e.g., "Fruit: Apple") in addition to the highlighted segment, as long as it stays in sync with the binding.
- The option set may be static (a `ForEach` over a `CaseIterable` enum) or dynamic, as long as each option has stable, distinct text and a `.tag` matching the selection type.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct SelectSegmentedDemo: View {
    enum Fruit: String, CaseIterable, Identifiable {
        case apple = "Apple", banana = "Banana", cherry = "Cherry"
        var id: Self { self }
    }

    @State private var fruit: Fruit = .apple

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Visible group label for sighted users.
            Text("Fruit")
            Picker("Fruit", selection: $fruit) {
                ForEach(Fruit.allCases) { fruit in
                    Text(fruit.rawValue).tag(fruit)
                }
            }
            .pickerStyle(.segmented)
            // Segmented style needs BOTH of these or the label is not spoken to VoiceOver;
            // this is the opposite of the menu style, which forbids .accessibilityLabel.
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Fruit")
            .onChange(of: fruit) {
                print("selection took effect immediately: \(fruit.rawValue)")
            }
        }
    }
}
```
