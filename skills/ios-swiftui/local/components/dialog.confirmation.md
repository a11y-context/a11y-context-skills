---
id: dialog.confirmation
title: Dialog (Confirmation)
stack: ios/swiftui
status: beta
latest_version: 0.1.0
tags: [confirmation, action-sheet, dialog, destructive, actions]
aliases: [action sheet, confirmation dialog, .confirmationDialog, actionSheet, delete confirmation, bottom sheet actions]
summary: A native SwiftUI .confirmationDialog action sheet that takes VoiceOver focus on presentation, with each action returning focus to the trigger because native confirmation dialogs do not restore it automatically.
---

# Dialog (Confirmation)

Pattern ID: `dialog.confirmation`

A native SwiftUI `.confirmationDialog` action sheet that takes VoiceOver focus on presentation, with each action returning focus to the trigger because native confirmation dialogs do not restore it automatically.

## Use When
- Use when a control offers a short set of actions to confirm or choose from, presented as an action sheet anchored to that control (e.g., confirming a destructive delete, picking one of a few actions on an item). Uses the native SwiftUI `.confirmationDialog(_:isPresented:titleVisibility:actions:message:)` modifier.
- Use when the choice is a small set of clearly labeled actions (typically two to four) plus a cancel.

## Do Not Use When
- Do not use when a brief, blocking message needs the user to acknowledge it or make a small decision before continuing (use `dialog.alert`).
- Do not use when the content is a larger form or multi-step task (use `dialog.modal`).
- Do not use when the items are commands pulled down from a control rather than a one-time confirmation or choice (use `menu.basic`).
- Do not use when the user is choosing a single persistent value rather than committing an action (use `select.menu`).

## Must Haves
- Use the native `.confirmationDialog(_:isPresented:titleVisibility:actions:message:)` modifier so the action sheet is a real overlay that takes VoiceOver focus on presentation and blocks interaction with the rest of the screen until it is dismissed.
- Provide the primary question or statement as the dialog title, and put any supporting detail in the `message:` closure.
- Set `titleVisibility: .visible` so the title is shown and spoken, unless the triggering context already makes the choice clear (see Customizable).
- Return VoiceOver focus to the trigger on dismissal: bind the trigger with `@AccessibilityFocusState` and set it true inside every action's closure, because native confirmation dialogs do not restore focus automatically, which is an Apple platform defect. See `global.focus-management`.
- Give each action a specific label and the correct role: `.cancel` for the dismissive action and `.destructive` for a destructive one, so VoiceOver and the system present them correctly.
- Keep the action set short and the labels self-explanatory out of context (e.g., "Discard Draft", "Keep Editing"), not "OK"/"Yes"/"No" where the outcome is ambiguous.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a custom view as a faux action sheet (a conditional `VStack` overlay); it does not receive VoiceOver focus on display, does not block the background, and does not restore focus on close. Use the native `.confirmationDialog()`, or `dialog.modal` for a richer custom modal.
- Do not omit focus return; without `@AccessibilityFocusState` set in each action, VoiceOver focus is lost when the dialog closes, which is a gap in the native control.
- Do not rely on color alone to signal a destructive action; use the `.destructive` role and a clear label, not only red text.
- Do not put forms, many controls, or lengthy content in a confirmation dialog; use `dialog.modal` for that.

## Customizable
- The dialog may present a single confirming action plus cancel, or several actions plus cancel, as long as every action returns focus to the trigger.
- The confirming action may carry the `.destructive` role, or the default role when the action is not destructive.
- The title may be hidden with `titleVisibility: .hidden` when the triggering context already makes the choice clear, as long as the message or action labels still convey what is being confirmed.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct DialogConfirmationDemo: View {
    @State private var showingDialog = false
    @AccessibilityFocusState private var triggerFocused: Bool

    var body: some View {
        Button("Discard Draft", role: .destructive) {
            showingDialog = true
        }
        .accessibilityFocused($triggerFocused)
        .confirmationDialog(
            "Discard this draft?",
            isPresented: $showingDialog,
            titleVisibility: .visible
        ) {
            // Each action returns VoiceOver focus to the trigger, since native
            // confirmation dialogs do not restore it automatically.
            Button("Discard Draft", role: .destructive) {
                print("Draft discarded")
                triggerFocused = true
            }
            Button("Keep Editing", role: .cancel) {
                triggerFocused = true
            }
        } message: {
            Text("Your unsent changes will be lost.")
        }
    }
}
```
