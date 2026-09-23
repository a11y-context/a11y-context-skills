---
id: dialog.alert
title: Dialog (Alert)
stack: ios/swiftui
status: beta
latest_version: 0.1.1
tags: [alert, dialog, modal, confirmation, destructive]
aliases: [alert, alert dialog, confirmation alert, popup alert, delete confirmation, .alert]
summary: A native SwiftUI .alert modal that takes VoiceOver focus on presentation, with each action returning focus to the trigger because native alerts do not restore it automatically.
---

# Dialog (Alert)

Pattern ID: `dialog.alert`

A native SwiftUI `.alert` modal that takes VoiceOver focus on presentation, with each action returning focus to the trigger because native alerts do not restore it automatically.

## Use When
- Use when a brief, blocking message needs the user to acknowledge it or make a small choice before continuing (e.g., confirming a destructive action, acknowledging a required error). Uses the native SwiftUI `.alert()` modifier.
- Use when the choice is a short set of clearly labeled actions (typically one to three).

## Do Not Use When
- Do not use when the content is a non-blocking sheet of choices tied to a specific control (use `dialog.confirmation`).
- Do not use when the content is a larger form or multi-step flow (use `dialog.modal`).
- Do not use when the message is a transient status that does not require acknowledgement (use `global.announcements`).

## Must Haves
- Use the native `.alert(_:isPresented:actions:message:)` modifier so the alert is a real modal that takes VoiceOver focus on presentation and blocks interaction with the rest of the screen until it is dismissed.
- Provide the primary question or statement as the alert title, and any supporting detail in the `message:` closure.
- Return VoiceOver focus to the trigger on dismissal: bind the trigger with `@AccessibilityFocusState` and set it true inside every alert action's closure, because native alerts do not restore focus automatically.
- Give each action a specific label and the correct role: `.cancel` for the dismissive action and `.destructive` for a destructive one, so VoiceOver and the system present them correctly.
- Keep the action set short and the labels self-explanatory out of context (e.g., "Delete", "Cancel"), not "OK"/"Yes"/"No" where the outcome is ambiguous.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a custom view as a faux alert (a conditional `VStack` overlay); it does not receive VoiceOver focus on display, does not block the background, and does not restore focus on close. Use the native `.alert()`, or `dialog.modal` for a richer custom modal.
- Do not omit focus return; without `@AccessibilityFocusState` set in each action, VoiceOver focus is lost when the alert closes, which is a gap in the native control.
- Do not rely on color alone to signal a destructive action; use the `.destructive` role and a clear label, not only red text.
- Do not put lengthy content, forms, or many controls in an alert; use `dialog.modal` for that.

## Customizable
- The alert may have a single acknowledgement button or two or more actions (e.g., Cancel plus a confirming or destructive action), as long as every action returns focus to the trigger.
- The confirming action may carry the `.destructive` role, the `.confirm` role on OS versions that support it, or the default role when neither applies.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct DialogAlertDemo: View {
    @State private var showingAlert = false
    @AccessibilityFocusState private var triggerFocused: Bool

    var body: some View {
        Button("Remove Download", role: .destructive) {
            showingAlert = true
        }
        .accessibilityFocused($triggerFocused)
        .alert("Remove this download?", isPresented: $showingAlert) {
            // Each action returns VoiceOver focus to the trigger, since native
            // alerts do not restore it automatically.
            Button("Cancel", role: .cancel) {
                triggerFocused = true
            }
            Button("Remove", role: .destructive) {
                // perform the removal
                triggerFocused = true
            }
        } message: {
            Text("This episode will no longer be available offline.")
        }
    }
}
```
