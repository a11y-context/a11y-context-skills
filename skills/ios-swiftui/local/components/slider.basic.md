---
id: slider.basic
title: Slider
stack: ios/swiftui
status: beta
latest_version: 0.1.1
tags: [slider, range, adjustable, value, continuous]
aliases: [range slider, volume slider, brightness slider, Slider, value slider]
summary: A native SwiftUI Slider that VoiceOver adjusts by swiping up or down, paired with single-tap controls so the value is adjustable without a drag gesture.
---

# Slider

Pattern ID: `slider.basic`

A native SwiftUI `Slider` that VoiceOver adjusts by swiping up or down, paired with single-tap controls so the value is adjustable without a drag gesture.

## Use When
- Use when the user adjusts a value across a continuous or stepped numeric range by moving a thumb between a minimum and maximum (e.g., "Brightness", "Volume", "Speed"). Uses a native SwiftUI `Slider`, which VoiceOver adjusts by swiping up or down.

## Do Not Use When
- Do not use when the value changes in discrete single increments and a compact plus/minus control fits better (use `stepper.basic`).
- Do not use when the choice is among a small fixed set of labeled options rather than a numeric range (use `select.segmented`).
- Do not use when the control is a simple on/off setting (use `switch.basic`).

## Must Haves
- Use a native `Slider` so VoiceOver exposes the adjustable behavior automatically (swipe up or down to change the value) and Switch Control can adjust it. SwiftUI has no `.adjustable` trait to add; the native control provides adjustability, and a custom-drawn slider gets it from `accessibilityAdjustableAction` (per `global.custom-control-representation`).
- The slider has a specific accessible name. Supply it with the `Slider` label closure (`Slider(value:in:) { Text("Brightness") }`), whose text becomes the accessible name, or pair a visible `Text` label with `.accessibilityLabel`. A bare `Slider` has no inherent label.
- Set `.accessibilityValue` to a meaningful value with units when the default percentage is not self-explanatory (e.g., "$50", "Medium", "72 degrees").
- Provide a single-tap alternative to the drag gesture so the value can be changed without a path-based gesture: decrement and increment buttons, or a paired `Stepper` and `TextField` for fine and direct control.
  - Icon-only increment and decrement buttons each need an `.accessibilityLabel` (e.g., "Decrease brightness", "Increase brightness").
- Give repeated sliders on one screen unique accessible names.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not add a `.adjustable` trait; SwiftUI has no such trait (it exists only in UIKit). For a custom slider, confer adjustability with `.accessibilityAdjustableAction`, not a trait.
- Do not ship a slider adjustable only by dragging; provide a single-tap alternative.
- Do not leave the slider without a visible label and an accessible name.
- Do not leave `.accessibilityValue` at the default percentage when the value carries meaningful units the user needs (e.g., currency, temperature).
- Do not create icon-only increment or decrement buttons without accessible names.

## Customizable
- The single-tap alternative is the engineer's choice: increment and decrement buttons, a paired `Stepper`, a `TextField` for direct numeric entry, or a combination, as long as at least one single-tap path adjusts the value.
- The slider may show `minimumValueLabel` and `maximumValueLabel` for visible bounds; these are supplementary and do not replace the accessible name or value.
- `step:` may be set for discrete stops or omitted for continuous adjustment; both remain adjustable to VoiceOver.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct SliderBasicDemo: View {
    @State private var brightness = 50.0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brightness")

            HStack {
                // Single-tap alternative to dragging; icon-only buttons need names.
                Button {
                    brightness = max(0, brightness - 10)
                } label: {
                    Image(systemName: "sun.min")
                }
                .accessibilityLabel("Decrease brightness")

                Slider(value: $brightness, in: 0...100, step: 10) {
                    Text("Brightness")            // becomes the accessible name
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("100")
                }

                Button {
                    brightness = min(100, brightness + 10)
                } label: {
                    Image(systemName: "sun.max.fill")
                }
                .accessibilityLabel("Increase brightness")
            }
        }
    }
}
```
