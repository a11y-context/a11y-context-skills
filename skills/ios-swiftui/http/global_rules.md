---

id: "global_ruleset.baseline"
title: "Foundations"
toc_max_heading_level: 2
slug: "/foundations"
stack: "ios/swiftui"
rule_set: "baseline"
status: "beta"
summary: "Baseline accessibility rules applied across most SwiftUI UI work."
cache_ttl_seconds: 86400
apply_policy:
  instruction: "Apply all MUST rules that match the current change scope. If the task does not touch a scope, do not introduce unrelated changes."
  scopes_in_order: ["screen", "layout", "component"]

---

# Foundations

The cross-cutting accessibility rules that apply across most SwiftUI work, independent of any single component. Each rule is a best practice an AI applies while authoring SwiftUI code. Component patterns reference these rules rather than restating them.

Verification (audits, contrast measurement, on-device and human/LLM review) is a QA concern and lives in the QA layer, not here.

## Rule: Native First

```yaml
id: global.native-first
scope: [control, component]
```

### Must Haves
- An interactive control exposes three things to assistive technology: its role, its current value or state, and its actions. Reach for the control that already does all three rather than assembling one that does none.
- SwiftUI's own control is the reference implementation of that contract. `Button`, `Toggle`, `Slider`, `Stepper`, `Picker`, `TextField`, and `DatePicker` carry their traits, values, and actions without being told. A view that wraps one of them satisfies the contract too.
- A control assembled from `Text`, `Image`, `Shape`, and `.onTapGesture` satisfies none of it, and has to declare all three by hand. When that is the only option, follow `global.custom-control-representation`.
- When a component's own pattern states a fallback and its conditions, follow that pattern rather than this rule. The conditions under which the native control cannot be used differ by component.

### Don'ts
- Do not treat a visual match as a semantic match. An `HStack` of a checkmark `Image` and a `Text` renders like a checkbox and exposes none of a checkbox's trait or state.
- Do not replace a native control to gain a visual treatment a style modifier could have given it. A custom `ToggleStyle` keeps the underlying `Toggle`; a hand-drawn switch does not.

## Rule: Touch Target Size

```yaml
id: global.touch-target-size
scope: [component]
```

### Must Haves
- Every tappable control has a hit area of at least 24x24 points.
  - Inline targets within a run of text are exempt from this minimum.
  - For icon-only controls where the visible glyph is smaller than 24x24, use `.frame(minWidth: 24, minHeight: 24)` on the tappable element to extend the hit area without resizing the glyph.
- Prefer a 44x44 point hit area where layout allows, matching Apple's Human Interface Guidelines. Treat 44x44 as the target and 24x24 as the non-negotiable floor.

### Don'ts
- Do not rely on the visible glyph size alone to satisfy the minimum; extend the frame, not the icon.

## Rule: Focus States

```yaml
id: global.focus-states
scope: [component]
```

### Must Haves
- Every interactive control shows a visible system focus indicator for Full Keyboard Access, external-keyboard, and Switch Control users. The default `Button`, `Toggle`, and other native control styles preserve this automatically.

### Don'ts
- Do not apply a custom style modifier (e.g., a `ButtonStyle` or `ToggleStyle` built with `PlainButtonStyle` or a bespoke shape) that suppresses the system focus indicator without restoring an equivalent visible focus treatment.

## Rule: Semantic Color

```yaml
id: global.semantic-color
scope: [component]
```

### Must Haves
- Use semantic color for text and control surfaces: the design system's color tokens, or SwiftUI system colors (`.primary`, `.secondary`, `Color(.label)`, `Color(.systemBackground)`, `.tint`). These adapt to light and dark mode and are pre-vetted for contrast.
- Use native control styles (`.borderedProminent`, `.roundedBorder`, the system `Toggle`) so a control's border, track, and state fills inherit their contrast instead of being hand-drawn.
- Give any custom-drawn indicator (a selection outline, a custom toggle track) a semantic or design-token color rather than a fixed literal.

### Don'ts
- Do not hardcode raw colors (`Color.black`, `Color.white`, or gray literals like `Color(white: 0.7)`) for text or control chrome; they do not adapt to the color scheme and often fail contrast.
- Do not restyle a native control in a way that strips its default border, track, or state contrast.
- Do not convey a control's state (on/off, selected) by color alone; keep a shape, fill, or label difference as well.

## Rule: Dynamic Type

```yaml
id: global.dynamic-type
scope: [layout, component]
```

### Must Haves
- Use a built-in text style (`.body`, `.headline`, `.caption`) or a `Text` with no fixed point size, so text scales with the user's setting.
- Size any glyph-tracking dimension (icon size, control height, glyph padding) with `@ScaledMetric(relativeTo:)` rather than a fixed point value.
- Let text wrap and containers grow, and place long content in a `ScrollView`. For a `TextField` that can hold long input, use `axis: .vertical`.

### Don'ts
- Do not set a fixed `.font(.system(size:))` on content text.
- Do not apply a truncating `.lineLimit()` to meaningful text, or wrap it in a fixed-height frame that clips it when enlarged.
- Do not clamp the app's Dynamic Type range to protect a layout; fix the layout instead.

## Rule: Custom Control Representation

```yaml
id: global.custom-control-representation
scope: [component]
```

### Must Haves
- Any control drawn from primitives (shapes, `Canvas`, `Path`, raw gestures) rather than a native control exposes a hidden native equivalent through `.accessibilityRepresentation { }`, supplying an accessible name, the current value (for a slider, stepper, or toggle), the correct role and trait, and the control's actions.
- Bind the representation and the visible control to the same state so the announced value stays in sync as the user interacts.
- For a control adjusted by dragging, add `.accessibilityAddTraits(.allowsDirectInteraction)` so a VoiceOver user can move it directly.

### Don'ts
- Do not ship a custom-drawn control with only a tap gesture and a visual label; it is unreachable and inoperable for VoiceOver, Switch Control, and Full Keyboard Access users.
- Do not hand-rebuild the contract with loose `.accessibilityLabel`, `.accessibilityValue`, and traits when a native representation supplies the role behaviors (adjustable actions, toggling) that loose traits alone do not.

## Rule: Navigation Focus

```yaml
id: global.navigation-focus
scope: [screen]
```

### Must Haves
- Set a `navigationTitle` on every pushed screen so its screen change is announced by name.
- Let the system manage VoiceOver focus on a `NavigationStack` push; do not force focus to the back button or an arbitrary element.
- On pop, restore focus to the row that triggered the navigation by binding it with `@AccessibilityFocusState` and setting that focus when the pushed screen is dismissed, where the system does not restore it.

### Don'ts
- Do not push a screen with no title, which leaves the change without a clear spoken announcement.
- Do not override the system's push-focus placement.

## Rule: Announcements

```yaml
id: global.announcements
scope: [component]
```

### Must Haves
- When a dynamic change updates on-screen content without moving focus (a status message, an updated cart count, an inline validation result, a passive confirmation), speak it to VoiceOver by posting an `AccessibilityNotification.Announcement("...")` so the user hears the change without losing their place.
- Post the announcement after the content actually appears, with a short delay (`DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)`), so VoiceOver does not drop the message while it commits the view update.
- Announce, rather than move focus, when the change is passive: informational content the user did not have to act on. Reserve moving focus (see `global.focus-management`) for content the user must interact with immediately, such as a newly presented overlay or a blocking error. This is the passive status-message path a component like `dialog.alert` redirects to when acknowledgement is not required.
- In a UIKit-backed view, post the equivalent `UIAccessibility.post(notification: .announcement, argument:)`.

### Don'ts
- Do not update an on-screen status silently; showing new `Text` without posting an announcement leaves VoiceOver users unaware the state changed.
- Do not move VoiceOver focus to a passive status message, which interrupts the user's place for information they did not choose to act on. Announce it instead.
- Do not post the announcement with no delay in the same run loop as the state change; VoiceOver may drop it before it speaks.

## Rule: Focus Management

```yaml
id: global.focus-management
scope: [layout, component]
```

### Must Haves
- When content appears that the user must act on immediately (a modal overlay, a newly revealed section, an error that blocks progress), move VoiceOver focus to it with a property bound by `@AccessibilityFocusState`, so the user is placed on the new content rather than left where they were.
- When an overlay closes, restore VoiceOver focus to the control that opened it. Bind that trigger with `@AccessibilityFocusState` and set it true as the overlay dismisses. Native `.alert()`, `.confirmationDialog()`, `.sheet()`, `.fullScreenCover()`, and `.popover()` do not restore focus automatically, an Apple platform defect, so restore it explicitly: from each action's closure for alerts and confirmation dialogs, or from the `onDismiss:` handler for sheets and full-screen covers.
- For a `TextField`, `@AccessibilityFocusState` does not return focus automatically after the keyboard is dismissed; restore it from the keyboard toolbar's Done button.
- This rule covers overlays, dynamic content reveals, and text-field focus restoration. For an in-app push/pop `NavigationStack` transition, follow `global.navigation-focus` instead.

### Don'ts
- Do not leave VoiceOver focus stranded behind a dismissed overlay; without an explicit restore, focus can jump to the top of the screen or an arbitrary element.
- Do not depend on `@AccessibilityFocusState` to return focus from a `Menu` or a `DatePicker`; it does not work with either, an Apple platform defect, so do not build a focus-restore contract around those controls.
- Do not move focus to passive content that does not require action; announce it instead (see `global.announcements`).
