---
id: stepper.basic
title: Stepper
stack: ios/swiftui
status: beta
latest_version: 0.1.3
tags: [stepper, increment, decrement, value, quantity]
aliases: [plus minus, quantity stepper, increment control, Stepper, counter]
summary: A native SwiftUI Stepper whose visible label text becomes its accessible name and which VoiceOver increments or decrements automatically, with no .adjustable trait to add.
---

# Stepper

Pattern ID: `stepper.basic`

A native SwiftUI `Stepper` whose visible label text becomes its accessible name and which VoiceOver increments or decrements automatically, with no `.adjustable` trait to add.

## Use When
- Use when the user increases or decreases a value in discrete single increments with plus and minus controls (e.g., "Tickets", "Copies", "Quantity").

## Do Not Use When
- Do not use when the value spans a wide continuous range better suited to a thumb slider (use `slider.basic`).
- Do not use when the choice is among labeled options rather than a number (use `select.menu`).

## Must Haves
- Use a native `Stepper` so its increment and decrement behavior is exposed to VoiceOver and operable by Switch Control automatically. SwiftUI has no `.adjustable` trait to add; a custom increment control gets its behavior from `accessibilityAdjustableAction` (per `global.custom-control-representation`) (`global.native-first`).
- Give the stepper an accessible name from its visible label using the label closure (`Stepper(value: $tickets) { Text("Tickets: \(tickets)") }`), whose text becomes the accessible name. A manual `.accessibilityLabel` is unnecessary in this case.
  - When the stepper's visible label is empty (e.g., the count is shown in a separate `Text` or `TextField`), add an `.accessibilityLabel` so the stepper is still named.
- When the current value is not part of the label text, set `.accessibilityValue` so VoiceOver announces the value along with the name.
- For a wide range, pair the stepper with a `TextField` for direct entry so users are not forced to tap many times; give the paired field the same accessible name.
- Give repeated steppers on one screen unique accessible names.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not add a `.adjustable` trait; SwiftUI has none (it is a UIKit trait). A native `Stepper` provides the behavior, and a custom control uses `.accessibilityAdjustableAction`.

## Customizable
- The value may be carried in the label text (`Text("Tickets: \(tickets)")`) or announced through `.accessibilityValue` while the label stays static; either keeps the value discoverable.
- A paired `TextField` for direct entry is optional on a small range.
- The increment size (`step:`) and bounds (`in:`) are the engineer's choice for the value being adjusted.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct StepperExamples: View {
    @State private var tickets = 1
    @State private var copies = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Stepper(value: $tickets, in: 1...10) {
                Text("Tickets: \(tickets)")
            }

            HStack {
                Text("Copies")
                TextField("", value: $copies, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .accessibilityLabel("Copies")
                Stepper("", value: $copies, in: 1...100)
                    .accessibilityLabel("Copies")
                    .accessibilityValue("\(copies)")
            }
        }
    }
}
```
