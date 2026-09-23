---
id: text-field.basic
title: Text Field
stack: android/compose
status: beta
latest_version: 0.2.0
tags: [text-field, form, input, autofill, error, keyboard]
aliases: [textfield, text input, input field, edit text, EditText, TextField, OutlinedTextField, BasicTextField, password field, search field, secure field]
summary: Single-line text entry whose accessible name has to come from the field's own label slot rather than a Text beside it. Supporting text and error messages are separate nodes the component does not attach, so both have to be associated deliberately.
---

# Text Field

Pattern ID: `text-field.basic`

Single-line text entry built from the Material text field, whose `label` slot supplies the accessible name. Supporting text and error messages are separate nodes the component does not attach, so both have to be associated deliberately.

The trap is `isError`. Setting it turns the field red and announces a generic error string, not the message sitting right underneath it, so the field reads as wrong without ever saying why.

## Use When
- Use when the user types a single line of free text, such as a name, an email address, or a search term.
- Use when the value maps to a system autofill category, so the keyboard can offer to fill it (e.g., a password, a one-time code, a postal code).
- Use when the input has a natural software keyboard tied to its type, such as an email address or a phone number.

## Do Not Use When
- Do not use when the user types more than one line, such as a message body or a review. The same component takes `singleLine = false`, and the multi-line case has its own labeling and scrolling requirements.
- Do not use when the value comes from a fixed set rather than being typed (use `select.basic`).
- Do not use when the value is a date or a time chosen from a picker (use `date-picker.basic`).
- Do not use when the field is one cell of a segmented code entry (use `pin-input.basic`).

## Must Haves
- The field reports editable-text semantics and takes its accessible name from its visible label. Material's `TextField` and `OutlinedTextField` are the reference implementations, supplying that through the `label` slot along with the focus and error states; `BasicTextField` supplies the editing and none of the rest (`global.native-first`).
- Supply the visible label through the `label` slot. It is what gives the field its accessible name, and it stays on screen as the floating label once the user types.
- Set your own `Modifier.semantics { error("...") }` with the real message when the field is invalid. Material's `isError` applies `error()` with a generic default string and does not read the supporting text, so `isError` alone announces that something is wrong and never what.
- Keep `isError = true` alongside it, because that is what drives the visual error treatment and the error color.
- Repeat the error message as visible text, through the `supportingText` slot, so it is not available only to TalkBack (`global.use-of-color`).
- Treat `supportingText` as a separate node, not as part of the field. The component lays it out below the field without attaching it, so TalkBack reaches it as its own element after the field rather than as a description of it. Where the hint must be heard with the field, fold it into the label or into a `contentDescription` on the field instead.
- Set `keyboardOptions` with the `KeyboardType` that matches the input, so the right software keyboard appears (e.g., `KeyboardType.Email`, `KeyboardType.Number`).
- Set `imeAction` to match the field's place in the form, and handle it in `keyboardActions`, so the keyboard's action key advances or submits instead of inserting a newline.
- Set `Modifier.semantics { contentType = ContentType.EmailAddress }` or the matching type on any field that maps to an autofill category, so autofill offers the right value.
- Announce a validation error rather than moving focus to the field when the error appears after submit. Moving focus loses the user's place in a form (`global.announcements`).
- Label a trailing icon button, such as a password reveal or a clear-text control, and give it a `stateDescription` when it toggles. It is a real control inside the field and needs its own name.
- If the field is unavailable, pass `enabled = false` rather than removing the field or making it non-interactive, so it stays in the accessibility tree and reports that it is disabled.
- Use `readOnly = true` rather than `enabled = false` for a value the user may read and copy but not change, such as an order number. A disabled field is skipped by some navigation and cannot be selected; a read-only one stays focusable and its text stays reachable.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not rely on `isError` to announce the error message. It announces a generic string; the message the user needs is the one you pass to `error()`.
- Do not use `placeholder` as the field's only label. It is replaced by the typed text and leaves the field unnamed once the user starts typing.
- Do not put the label in a `Text` above the field instead of in the `label` slot. It renders identically and leaves the field with no name.
- Do not include the control type in the label, such as "Email text field". The component already reports that it is an editable field.
- Do not build the field from `BasicTextField` without adding the label, error, and container semantics yourself. It is the primitive Material decorates, not a finished field.
- Do not set `contentDescription` on a field that already has a `label`. It replaces the name rather than adding to it, and the two drift apart.
- Do not convey the error state with the red outline alone (`global.use-of-color`).

## Customizable
- `TextField` or `OutlinedTextField` is a visual choice. Both carry the same semantics and the same obligations.
- The supporting text may carry a hint, a character count, an error message, or nothing.
- A field the user cannot edit may be `readOnly` or disabled. The choice is a semantic one, not a visual one: read-only keeps the value reachable, disabled removes it from the interaction flow.
- `prefix`, `suffix`, `leadingIcon`, and `trailingIcon` are available. A decorative leading icon takes `contentDescription = null`; an interactive trailing one needs a name.
- For masked entry, `visualTransformation = PasswordVisualTransformation()` with the password content type. The labeling requirements are unchanged, and the reveal control is a labeled toggle.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun TextFieldExamples() {
    var email by remember { mutableStateOf("") }
    var submitted by remember { mutableStateOf(false) }
    val invalid = submitted && !email.contains("@")
    val errorMessage = "Enter an email address that includes an @."

    Column {
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            // The label slot is the accessible name. A Text above the field
            // would look the same and leave the field unnamed.
            label = { Text("Email") },
            singleLine = true,
            isError = invalid,
            supportingText = {
                // Visible copy. The component does not attach this to the
                // field, so it is read as its own element after it.
                Text(if (invalid) errorMessage else "We use this to send receipts.")
            },
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Email,
                imeAction = ImeAction.Next
            ),
            modifier = Modifier
                .fillMaxWidth()
                .semantics {
                    contentType = ContentType.EmailAddress
                    // isError on its own announces a generic default string.
                    // This is what makes TalkBack say what is actually wrong.
                    if (invalid) error(errorMessage)
                }
        )

        // Password, with a labeled reveal control. The toggle is a real button
        // inside the field and carries its own name and state.
        var password by remember { mutableStateOf("") }
        var revealed by remember { mutableStateOf(false) }

        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            singleLine = true,
            visualTransformation =
                if (revealed) VisualTransformation.None else PasswordVisualTransformation(),
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.Password,
                imeAction = ImeAction.Done
            ),
            trailingIcon = {
                IconButton(
                    onClick = { revealed = !revealed },
                    modifier = Modifier.semantics {
                        stateDescription = if (revealed) "Shown" else "Hidden"
                    }
                ) {
                    Icon(
                        imageVector = if (revealed) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                        contentDescription = "Show password"
                    )
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .semantics { contentType = ContentType.Password }
        )
    }
}
```
