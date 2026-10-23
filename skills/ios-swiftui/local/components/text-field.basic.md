---
id: text-field.basic
title: Text Field
stack: ios/swiftui
status: beta
latest_version: 0.3.0
tags: [text-field, form, input, autofill, secure-field]
aliases: [TextField, textfield, text input, input field, secure field, email field, password field]
summary: A single-line SwiftUI text field with a persistent visible label, since the field title renders only as placeholder text on iOS, with keyboardType and textContentType set so the correct keyboard and AutoFill appear.
---

# Text Field

Pattern ID: `text-field.basic`

A single-line SwiftUI `TextField` with a persistent visible label, since the field title renders only as placeholder text on iOS, with `.keyboardType` and `.textContentType` set so the correct keyboard and AutoFill appear.

## Use When
- Use when the user enters a single line of free-form text such as a name, email address, or search query (e.g., "Email", "Search").
- Use when the entered value maps to a system AutoFill category such as credentials or contact details, so the keyboard can offer to fill it (e.g., "Password", "One-Time Code", "Street Address").
- Use when the input has a natural on-screen keyboard tied to its data type, such as an email address or a numeric postal code.

## Do Not Use When
- Do not use when the user enters more than one line of text, such as a message body or review (use `text-editor.basic`).
- Do not use when the value is chosen from a fixed set of options rather than typed (use `select.menu`).
- Do not use when the value is a date or time selected from a calendar or wheel (use `date-picker.basic`).

## Must Haves
- Use a native `TextField` so the field exposes editable-text semantics, its name, and its typed value to VoiceOver (`global.native-first`).
- Give the field a persistent visible label in a `Text` placed with the field. On iOS the `TextField` title renders only as placeholder text, which disappears once the user types.
- Name the field with a `TextField` title that matches the visible label, and hide the visible `Text` from VoiceOver with `.accessibilityHidden(true)`, so the name is spoken once, on the field.
- Set `.keyboardType` to match the expected input (e.g., `.emailAddress`, `.numberPad`) so the correct software keyboard appears.
- Set `.textContentType` to the matching semantic type (e.g., `.emailAddress`, `.password`, `.oneTimeCode`, `.postalCode`) so AutoFill and QuickType offer the right value.
- Give the field a visible boundary that meets 3:1 non-text contrast against its background, e.g., `.textFieldStyle(.roundedBorder)` or `.border(.secondary)`; the default borderless `TextField` boundary can fall below 3:1.
- When the field can show a validation error, append the error text to the field's accessibility label dynamically (e.g., "Email, Enter a valid email address.") and signal it with more than color, so VoiceOver announces the error with the field name while the typed text remains the field's value, and the state is not conveyed by color alone.
  - Move VoiceOver focus to the errored field with `@AccessibilityFocusState` and `.accessibilityFocused` when validation fails on submit.
- Support Dynamic Type: use a built-in text style so the field's label and text scale, and allow the label to wrap rather than truncate at accessibility sizes.
- Meets the touch target size baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the system focus indicator baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not rely on a placeholder as the only label; the placeholder disappears once the user types, can fall below text contrast, and leaves the field with no accessible name for VoiceOver.
- Do not wrap the field in a `LabeledContent` styled to stack its label vertically above the field (a custom vertical `LabeledContentStyle`); VoiceOver then cannot double-tap to activate the field and Voice Control cannot target it by name, due to a known Apple bug.
- Do not add an `.accessibilityLabel` on top of a `LabeledContent`-supplied name; the extra label overrides the paired one and can desync from the visible text.
- Do not include the control type in the label (e.g., `.accessibilityLabel("Email text field")`); VoiceOver already announces "Text Field", so this doubles it.
- Do not add error text to the `.accessibilityValue`; it replaces the typed text, so VoiceOver stops speaking the field's actual value.
- Do not expose error text only through an `.accessibilityHint`; users can turn hints off in VoiceOver settings and would never hear the error.

## Customizable
- A horizontal `LabeledContent` (label beside the field) may replace the hidden `Text` label, as long as the field inside it carries no `.accessibilityLabel` of its own.
- A `prompt:` may supply example input as placeholder text (e.g., "name@example.com"); it does not replace the visible label.
- For masked secret entry, `SecureField` may replace `TextField`; it carries the same labeling and content-type requirements and additionally hides the typed value (pair it with `.textContentType(.password)`, `.newPassword`, or `.oneTimeCode`).
- The visual field style (`.textFieldStyle(.roundedBorder)`, a custom `.border`, or a bespoke background) is at the engineer's discretion as long as the boundary keeps 3:1 non-text contrast.
- Editing-behavior modifiers such as `.textInputAutocapitalization` and `.autocorrectionDisabled()` may be tuned to the field's data (e.g., disabling both on an email field) without affecting the accessible name.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```swift
import SwiftUI

struct TextFieldExamples: View {
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var zip = ""
    @State private var emailError: String?
    @AccessibilityFocusState private var emailFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Email")
                .accessibilityHidden(true)
            TextField("Email", text: $email, prompt: Text("name@example.com"))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel(emailError.map { "Email, \($0)" } ?? "Email")
                .accessibilityFocused($emailFocused)

            Text("Password")
                .accessibilityHidden(true)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)

            // Alternative: horizontal LabeledContent in place of the hidden Text label.
            LabeledContent("Full name") {
                TextField("", text: $fullName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
            }

            Text("ZIP code")
                .accessibilityHidden(true)
            TextField("ZIP code", text: $zip)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .textContentType(.postalCode)

            if let emailError {
                Text(emailError)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button("Sign In") {
                if email.contains("@") {
                    emailError = nil
                } else {
                    emailError = "Enter a valid email address."
                    emailFocused = true
                }
            }
        }
        .padding()
    }
}
```
