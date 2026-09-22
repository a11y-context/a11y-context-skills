---
id: button.basic
title: Button
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [button, control, action, icon-button, fab, chip]
aliases: [btn, primary button, icon button, call to action, cta, IconButton, floating action button, fab, ExtendedFloatingActionButton, assist chip, suggestion chip, text button]
summary: Control that triggers an immediate action. Covers text, icon-only, floating, and action-chip presentations, which share one role and differ in where the accessible name comes from.
---

# Button

Pattern ID: `button.basic`

Control that triggers an immediate action. Covers text, icon-only, floating, and action-chip presentations, which share one role and differ in where the accessible name comes from.

## Use When
- Use when the user triggers an immediate action and stays on the current screen (e.g., "Save", "Add to Watchlist", "Play").
- Use when the action is presented as a floating action button, an icon-only control, or an assist or suggestion chip. All four carry `Role.Button` and no state of their own.

## Do Not Use When
- Do not use when the control represents an on or off state that persists after the tap (use `button.toggle`).
- Do not use when the control carries a `selected` state, such as a filter or a removable token (use `chip.filter` or `chip.input`).
- Do not use when the control opens a list of commands (use `menu.basic`).
- Do not use when the control opens a URL or leaves the app (use `link.standalone`).
- Do not use when the control is a row in a list that navigates elsewhere (use `list-item.basic`).

## Must Haves
- The control reports `Role.Button` and a click action. Material's `Button`, `IconButton`, `FloatingActionButton`, `AssistChip`, and `SuggestionChip` are the reference implementations across the presentations this pattern covers; anything else has to set both itself (`global.native-first`).
- The button has an accessible name that describes its purpose or action.
- When the button has visible text, that text serves as the accessible name and no `contentDescription` is set on it.
- An icon-only control takes its name from `contentDescription` on the control, and the `Icon` inside it carries `contentDescription = null`.
- When several buttons on one screen share visible text, such as a repeated "Edit" per row, give each a `contentDescription` that names what it acts on (e.g., "Edit username").
- When an `ExtendedFloatingActionButton` collapses to icon-only, set a `contentDescription` that survives the collapse. The visible text is the name while expanded and disappears while collapsed, so a control named only by its text becomes unnamed.
- Set `onClickLabel` when "Double tap to activate" would not tell the user what happens (e.g., `onClickLabel = "add to watchlist"`). This is the only supplementary text Compose exposes, and it completes the sentence TalkBack speaks.
- If the action is unavailable, pass `enabled = false` rather than removing the handler, so the control stays in the accessibility tree and reports that it is disabled.
- Give a `FloatingActionButton` a `traversalIndex` or a containing traversal group when it is drawn last but read first, because it sits outside the content flow and composition order will not match what the user sees (`global.traversal-order`).
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not build a button from `Row`, `Box`, or `Image` with `Modifier.clickable` when a Material composable exists. It renders identically and exposes no role, so TalkBack announces content with no indication it can be activated.
- Do not include the word "button" in `contentDescription`. TalkBack appends the role itself, so the control announces "Save button, button".
- Do not set `contentDescription` on the `Icon` inside a labeled button. The button's own name and the icon's name both reach the merged node, and the control announces twice.
- Do not put the result of the action in `contentDescription` when it belongs in `onClickLabel`. The name says what the control is; the click label says what activating it does.
- Do not disable a button by removing its `onClick` or wrapping it in a non-clickable container. Both leave a control that looks disabled and reports nothing, and the second silently drops the 48dp minimum that the Material composable applies only while it owns the callback.

## Customizable
- Any of the five button skins, `Button`, `ElevatedButton`, `FilledTonalButton`, `OutlinedButton`, and `TextButton`, is acceptable. They share one role and one set of semantics and differ only in container and elevation tokens.
- The same holds within each family: the four `IconButton` skins are interchangeable, as are the three `FloatingActionButton` sizes, and `AssistChip` and `SuggestionChip` differ by usage convention rather than by exposed semantics.
- `onClickLabel` is optional. Add it when the action's outcome is not obvious from the name, and omit it when the name already says what happens ("Save", "Delete").

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun ButtonExamples() {
    // Text-only. The visible text is the accessible name; set nothing else.
    Button(onClick = { /* save */ }) {
        Text("Save")
    }

    // Icon plus text. The text names the control, so the icon is decorative.
    Button(onClick = { /* download */ }) {
        Icon(Icons.Filled.Download, contentDescription = null)
        Text("Download")
    }

    // Icon-only. The name moves to the control, and onClickLabel says what happens.
    IconButton(
        onClick = { /* open settings */ },
        modifier = Modifier.semantics { onClick(label = "open settings") { false } }
    ) {
        Icon(Icons.Filled.Settings, contentDescription = "Settings")
    }

    // Repeated control. The row's subject goes in the name, or every row reads alike.
    IconButton(onClick = { /* edit */ }) {
        Icon(Icons.Filled.Edit, contentDescription = "Edit username")
    }

    // Extended FAB. The text is the name while expanded and gone while collapsed,
    // so the contentDescription is what survives.
    ExtendedFloatingActionButton(
        onClick = { /* compose */ },
        expanded = false,
        icon = { Icon(Icons.Filled.Add, contentDescription = null) },
        text = { Text("New list") },
        modifier = Modifier.semantics { contentDescription = "New list" }
    )

    // Assist chip. Role.Button, no selected state; a chip only in appearance.
    AssistChip(
        onClick = { /* filter by genre */ },
        label = { Text("Comedy") }
    )

    // Disabled. enabled = false keeps it in the tree and reports the state.
    Button(onClick = { /* never fires */ }, enabled = false) {
        Text("Submit")
    }
}
```
