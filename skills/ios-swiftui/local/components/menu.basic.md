---
id: menu.basic
title: Menu
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [menu, pull-down, commands, actions, overflow]
aliases: [Menu, pull-down menu, overflow menu, ellipsis menu, more button, action menu]
summary: A SwiftUI Menu that presents a pull-down list of command buttons, takes VoiceOver focus when opened, with commands carrying the destructive role where applicable.
---

# Menu

Pattern ID: `menu.basic`

A SwiftUI `Menu` that presents a pull-down list of command buttons, takes VoiceOver focus when opened, with commands carrying the destructive role where applicable.

## Use When
- Use when a trigger reveals a pull-down list of two or more commands the user runs (e.g., "Duplicate", "Rename", "Delete"), or an overflow "more" control that groups in-place actions. Uses a SwiftUI `Menu` with `Button` actions.
- Use when collecting several in-place actions behind one compact control (an icon-only ellipsis or "more" button) keeps the primary UI uncluttered.

## Do Not Use When
- Do not use when the user is choosing one persistent value from a set rather than running a command (use `select.menu`).
- Do not use when a single one-time decision interrupts the task and must be acknowledged before continuing (use `dialog.confirmation`).
- Do not use when there is a single, always-visible action (use `button.basic`).

## Must Haves
- Use a native `Menu` so the trigger exposes the pop-up button role and the menu receives VoiceOver focus when it opens.
- Give the trigger an accessible name. A text trigger (`Menu("Actions")`) is named by its label text; an icon-only trigger (an ellipsis or "more" glyph) needs an `.accessibilityLabel` (e.g., "Map options").
- Populate the menu with `Button` actions, each with a clear, specific label that reads well out of context.
- Give a destructive command `role: .destructive` so the system presents it as destructive, rather than signaling it with red text alone (see `global.semantic-color`).
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a faux menu from a custom `VStack` or conditional overlay of buttons; it does not receive VoiceOver focus when shown and is not announced as a pop-up button. Use the native `Menu`.
- Do not leave an icon-only trigger without an `.accessibilityLabel`; VoiceOver then has no accessible name for it.
- Do not attempt to restore VoiceOver focus to the trigger after the menu closes with `@AccessibilityFocusState`. Unlike a `.sheet()` or `.popover()`, a native `Menu` does not return focus to its trigger and cannot be forced to, an Apple platform defect. Do not paper over it with a workaround that lands focus somewhere misleading.
- Do not convey a command's selected state with a trailing checkmark `Image` only; it disappears at the largest Dynamic Type sizes. Use a `Picker` inside the `Menu` for a checked choice, whose checkmark stays visible.
- Do not rely on `Section` header text to be exposed as a heading; native menu section headers lack the heading trait and have insufficient contrast (an Apple platform defect).

## Customizable
- The trigger may be a text label (`Menu("Actions")`), an icon plus text, or an icon-only control; an icon-only trigger may name itself with `.accessibilityLabel`.
- Commands may be grouped with `Section`, as long as the grouping is not the only way the structure is conveyed to VoiceOver: native menu section headers are missing the heading trait (see Don'ts).
- A menu may host a `Picker` for a checked sub-choice; its selection checkmark stays visible at all Dynamic Type sizes, unlike a manually drawn trailing checkmark `Image`.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct MenuBasicDemo: View {
    var body: some View {
        HStack {
            // Text trigger: the "Actions" label is the accessible name.
            Menu("Actions") {
                Button("Duplicate") { print("Duplicate") }
                Button("Rename") { print("Rename") }
                // Destructive role, not red text alone.
                Button("Delete", role: .destructive) { print("Delete") }
            }

            // Icon-only trigger needs an explicit accessible name.
            Menu {
                Button("Show Map") { print("Show Map") }
                Button("Share") { print("Share") }
            } label: {
                Image(systemName: "ellipsis")
            }
            .accessibilityLabel("Map options")
        }
        // A native Menu takes VoiceOver focus when opened. On close it does NOT
        // return focus to the trigger, and @AccessibilityFocusState cannot restore
        // it, an Apple platform defect, unlike .sheet() or .popover().
    }
}
```
