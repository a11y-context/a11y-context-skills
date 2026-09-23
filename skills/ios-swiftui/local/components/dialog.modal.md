---
id: dialog.modal
title: Dialog (Modal)
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [sheet, modal, dialog, bottom sheet, full screen cover]
aliases: [sheet, bottom sheet, modal sheet, full screen cover, .sheet, .fullScreenCover, presentationDetents]
summary: A native SwiftUI .sheet or .fullScreenCover modal that takes VoiceOver focus on presentation, carries a heading title and an explicit close control, and returns focus to the trigger via onDismiss because sheets do not restore it automatically.
---

# Dialog (Modal)

Pattern ID: `dialog.modal`

A native SwiftUI `.sheet` or `.fullScreenCover` modal that takes VoiceOver focus on presentation, carries a heading title and an explicit close control, and returns focus to the trigger via `onDismiss` because sheets do not restore it automatically.

## Use When
- Use when a self-contained task, form, or longer piece of content is presented in a modal that temporarily covers the current screen (e.g., compose, sign-up, a settings detail, a license agreement). Uses the native SwiftUI `.sheet(isPresented:onDismiss:content:)` modifier.
- Use when the modal task is immersive enough to occupy the whole screen rather than a partial sheet (use `.fullScreenCover(isPresented:onDismiss:content:)`).

## Do Not Use When
- Do not use when the content is a short blocking message that needs acknowledgement or a small choice (use `dialog.alert`).
- Do not use when the content is a short set of actions tied to a specific control (use `dialog.confirmation`).
- Do not use when the content is a small non-modal overlay anchored to a control (use `dialog.nonmodal`).
- Do not use when the user is navigating in-app to a new screen rather than opening a modal (use `list.row` and a `NavigationStack` push per `global.navigation-focus`).

## Must Haves
- Present with the native `.sheet(isPresented:onDismiss:content:)` modifier (or `.fullScreenCover` for a full-screen modal) so the modal takes VoiceOver focus on presentation and keeps VoiceOver interaction within its content until it is dismissed.
- Give the sheet a visible title and expose it to VoiceOver as a heading with `.accessibilityAddTraits(.isHeader)`, so VoiceOver users can identify and navigate to it by heading.
- Provide an explicit close or "Done" control; do not rely on the drag-to-dismiss gesture alone. A `.fullScreenCover` has no swipe-to-dismiss gesture, so an explicit close control (e.g., a "Done" button in a toolbar) is required there.
- Return VoiceOver focus to the trigger on dismissal: bind the trigger with `@AccessibilityFocusState` and set it in the `onDismiss:` closure, because sheets and full-screen covers do not restore focus to the trigger automatically (an Apple platform defect). See `global.focus-management`. Unlike `select.menu`, the `.sheet` `onDismiss:` callback fires on any dismissal, so `@AccessibilityFocusState` reliably restores focus here.
- Place the sheet's content inside a `ScrollView` so text and controls stay reachable and do not truncate at large Dynamic Type sizes (`global.dynamic-type`).
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a custom conditional `VStack` or overlay as a faux sheet; it does not receive VoiceOver focus on display, does not keep focus within the modal, does not restore focus on close, and lacks the built-in escape action. Use `.sheet` or `.fullScreenCover`.
- Do not omit focus return in `onDismiss:`; without `@AccessibilityFocusState`, VoiceOver focus is dropped back to the top of the underlying screen when the modal closes.
- Do not present a `.fullScreenCover` without an explicit close control; with no swipe-to-dismiss gesture, VoiceOver and other users can be trapped with no way out.
- Do not leave the sheet title as plain text with no heading trait; VoiceOver users lose the quick way to identify the modal.
- Do not place long content outside a `ScrollView`; it truncates at large Dynamic Type sizes instead of scrolling.
- Do not apply `.presentationBackgroundInteraction(.enabled)`; it makes the background reachable while the sheet is up, which breaks the modality this pattern asserts (VoiceOver focus is no longer kept within the modal).

## Customizable
- A `.sheet` may size itself with `.presentationDetents` (e.g., `[.medium, .large]`), as long as its content stays scrollable and the title and close control remain visible at every detent.
- The dismiss control may be a toolbar "Done" or "Close" button or an inline button; for a `.sheet`, the drag indicator may remain in addition to an explicit control, but not as the only way out.
- Either a `.sheet` (a partial, swipe-dismissable modal) or a `.fullScreenCover` (a full-screen modal that requires an explicit close control) may be used, depending on how immersive the task is.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct DialogModalDemo: View {
    @State private var showingSheet = false
    @AccessibilityFocusState private var triggerFocused: Bool

    var body: some View {
        Button("Show License Agreement") {
            showingSheet = true
        }
        .accessibilityFocused($triggerFocused)
        // onDismiss returns VoiceOver focus to the trigger, since sheets do
        // not restore it automatically. It fires on every dismissal.
        .sheet(isPresented: $showingSheet, onDismiss: { triggerFocused = true }) {
            // Content lives in a ScrollView so it scrolls, not truncates, at large text sizes.
            ScrollView {
                VStack(spacing: 16) {
                    Text("License Agreement")
                        .font(.title)
                        .accessibilityAddTraits(.isHeader) // title is a VoiceOver heading

                    Text("Full agreement text goes here…")

                    // Explicit close control; never rely on the drag gesture alone.
                    // A .fullScreenCover has no swipe-dismiss, so this is required there.
                    Button("Done") { showingSheet = false }
                }
                .padding()
            }
        }
    }
}
```
