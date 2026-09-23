---

id: "global_ruleset.baseline"
title: "Foundations"
toc_max_heading_level: 2
slug: "/foundations"
stack: "android/compose"
rule_set: "baseline"
status: "beta"
summary: "Baseline accessibility rules applied across most Jetpack Compose UI work."
cache_ttl_seconds: 86400
apply_policy:
  instruction: "Apply all MUST rules that match the current change scope. If the task does not touch a scope, do not introduce unrelated changes."
  scopes_in_order: ["screen", "layout", "component"]

---

# Foundations

The cross-cutting accessibility rules that apply across most Jetpack Compose work, independent of any single component. Each rule is a best practice an AI applies while authoring Compose code. Component patterns reference these rules rather than restating them.

Verification (audits, contrast measurement, on-device and human review) is a QA concern and lives in the QA layer, not here.

## Rule: Native First

```yaml
id: global.native-first
scope: [component]
```

### Must Haves
- An interactive control exposes three things to accessibility services: its role, its current state, and its actions. Reach for the component that already does all three rather than assembling one that does none.
- The Material 3 composable is the reference implementation of that contract. A component that wraps the Material composable satisfies it too, as does one that sets the same role, state, and actions itself.
- A control assembled from `Row`, `Box`, `Image`, and `Modifier.clickable` satisfies none of it by default, and has to declare all three by hand. When that is the only option, follow `global.custom-control-semantics`.
- When a component's own pattern states a fallback and its conditions, follow that pattern rather than this rule. The conditions under which the reference implementation cannot be used differ by component.

### Don'ts
- Do not treat a visual match as a semantic match. A `Row` containing a check glyph and a label renders like a checkbox and exposes none of a checkbox's role or state.
- Do not assume a component satisfies the contract because it is named after the control. Read what it sets: a wrapper that forwards to `Modifier.toggleable(role = Role.Checkbox)` qualifies, and one that forwards to a bare `clickable` does not.
- Do not hand-assemble a control from `androidx.compose.foundation` primitives when a component that already meets the contract is available to the project, whether that is the Material composable or the design system's own. Assembling one is the fallback, not the starting point.

## Rule: Merged Semantics

```yaml
id: global.merge-semantics
scope: [component]
```

### Must Haves
- Treat a composable that carries `Modifier.clickable`, `Modifier.toggleable`, `Modifier.selectable`, or a Material `ListItem` as a single accessibility node. Each of these sets `mergeDescendants = true` internally, so every descendant's text collapses into one announcement.
- When several text elements describe one thing, let the merge happen and check that the resulting announcement reads in a sensible order, because the merged name is the concatenation of descendant text in traversal order.
- When a row needs one primary action plus a secondary one, expose the secondary action as a `CustomAccessibilityAction` on the merged node rather than as a nested interactive child. TalkBack surfaces custom actions through its actions menu, which keeps the row a single stop.
- When a decorative child would pollute the merged name, remove it from the tree with `Modifier.clearAndSetSemantics { }` or, for an `Image` or `Icon`, with `contentDescription = null`.
- Apply `Modifier.semantics(mergeDescendants = true) { }` explicitly when a group of text and images forms one unit but carries no interaction, so it reads as one item instead of several.

### Don'ts
- Do not nest an interactive child inside an interactive parent. A child that merges cannot be absorbed by a parent that merges, so the result is two competing targets rather than the single row the layout suggests.
- Do not use `Modifier.clearAndSetSemantics { }` to hide a focusable control. It removes the node from every consumer, including the accessibility tree, leaving a control that is visible and operable by touch but unreachable by assistive technology.
- Do not rely on modifier order being irrelevant. `Modifier.clearAndSetSemantics` clears every semantics property applied after it in the chain.

## Rule: Touch Target Size

```yaml
id: global.touch-target-size
scope: [component]
```

### Must Haves
- Every tappable control accepts a tap across at least 48x48dp, matching Material's accessibility guidance. Treat 24x24dp as the absolute floor and 48dp as the size to build to.
  - Inline targets within a run of text are exempt from the minimum.
  - `Modifier.clickable` and `combinedClickable` already extend the tap area of an undersized control out to this minimum, so a Material component reaches it even when its drawn bounds are smaller. Material's button family relies on exactly this rather than reserving the space.
- Reserve the space with `Modifier.minimumInteractiveComponentSize()` where the control needs to occupy 48dp rather than merely accept a tap across it, such as when neighboring targets would otherwise sit closer than their own minimums allow. Place it before any size-constraining modifier, because a later `size()` or `height()` overrides it.
- When state is lifted out of a Material selection control so its own callback is null, size the wrapping `Modifier.toggleable` or `Modifier.selectable` row to at least 48dp. `Checkbox`, `RadioButton`, `Switch`, and `Slider` apply the minimum only while they own the callback, so hoisting state moves the obligation to the parent.
- When building a control from primitives, size it explicitly with `Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)` or `Modifier.defaultMinSize(...)`.
- Place `Modifier.padding` after `Modifier.clickable` in the chain when the padding should be part of the target. Order decides this: padding applied after `clickable` is inside the tappable area, and padding applied before it is not.

### Don'ts
- Do not assume the automatic extension covers a control that detects taps some other way. It is applied by `Modifier.clickable` and `combinedClickable`; a control built on `pointerInput` or a custom gesture detector gets none of it and has to be sized explicitly.
- Do not set `LocalMinimumInteractiveComponentSize` to `0.dp` to make a dense layout fit. That disables the enforcement for everything beneath it.
- Do not pad a control from the outside and count the padding as target. `Modifier.padding(12.dp).clickable { }` leaves the padding inert; the tappable area is still only the content.

## Rule: State Description

```yaml
id: global.state-description
scope: [component]
```

### Must Haves
- Express a control's current state through `Modifier.semantics { stateDescription = "..." }` when the state is discrete, such as selected, expanded, or a named mode.
- Express a control's current value through `progressBarRangeInfo` when the value is continuous or ranged, such as a slider position or a determinate progress amount. The two properties are separate, and the choice between them is the choice between a state and a value.
- Override the default state wording only when the visible wording differs from it. A switch showing "Allowed" and "Blocked" needs a `stateDescription` matching those words, because the default announcement says on and off.
- Keep the state out of the name. `contentDescription` says what the control is; `stateDescription` says what it currently is set to.

### Don'ts
- Do not concatenate the state into `contentDescription`. The name changes as the state changes, so the control appears to be a different control after every interaction.
- Do not set `stateDescription` on a control whose Material composable already reports its state correctly, which duplicates the announcement.

## Rule: Icons and Images

```yaml
id: global.icon
scope: [component]
```

### Must Haves
- Give an `Image` or `Icon` that carries meaning a `contentDescription` naming what it conveys, not what it depicts.
- Give an `Image` or `Icon` that is decorative, or that sits beside text saying the same thing, `contentDescription = null` so it leaves the accessibility tree.
- When an icon is the only content of a control, the control carries the name and the icon inside it is decorative. Name the `IconButton`, not both.

### Don'ts
- Do not describe the artwork when the icon stands for an action. A trash glyph on a delete control is named "Delete", not "Trash can".
- Do not leave `contentDescription` unset on a meaningful graphic. An unset description is not the same as `null`, and the element reports no name at all.

## Rule: Semantic Color

```yaml
id: global.semantic-color
scope: [component]
```

### Must Haves
- Colors for text, surfaces, and control chrome come from a theme whose values are checked against each other as a set and which adapts to light and dark, not from literals written at the call site.
- `MaterialTheme.colorScheme` is the reference implementation of that: its roles are paired tonal values, contrast-checked against their `on` counterparts, and switched automatically by `isSystemInDarkTheme()`. A design token set that is a theme in the same sense qualifies the same way.
- Use Material components with their default styling so a control's container, border, and state layers inherit their color relationships rather than being drawn by hand.
- Give any custom-drawn indicator a color-scheme role rather than a literal.
- When the app responds to the system contrast setting, read it through `UiModeManager.getContrast()` and register a `ContrastChangeListener`, then select a higher-contrast scheme. Android 14 and later.

### Don'ts
- Do not hardcode colors as `Color(0xFF...)` or `Color.Black` for text or control chrome. A literal at the call site belongs to no theme, so it neither adapts nor participates in any contrast relationship.
- Do not assume the color scheme responds to the system "Increase contrast" setting. It adapts to light and dark on its own; contrast level is a separate integration the app opts into.
- Do not restyle a Material component in a way that removes its container or state-layer contrast.

## Rule: Use of Color

```yaml
id: global.use-of-color
scope: [component]
```

### Must Haves
- Carry every piece of information on a second channel besides color: a shape, an icon, a text label, or a position.
- Pair a color-coded status with its name in text or in `stateDescription`, so the status is announced as well as shown.
- Distinguish a selected item by more than its fill. Material's selection controls do this already through their glyph; a custom selectable surface does not.

### Don'ts
- Do not signal an error state with a red border alone. Pair it with `isError`, an error message, and `Modifier.semantics { error("...") }`.
- Do not distinguish a link from its surrounding text by color alone.

## Rule: Text Scaling

```yaml
id: global.text-scaling
scope: [layout, component]
```

### Must Haves
- Size text in `sp` so it scales with the user's font-size setting. Use the `MaterialTheme.typography` styles rather than a literal size wherever one fits.
- Let containers grow with their content, and place any screen that can overflow inside a `verticalScroll` or a `LazyColumn`.
- Size a non-text dimension that must track the type scale by reading `LocalDensity.current.fontScale` and multiplying, since Compose has no modifier that rescales a `dp` value by the font scale.

### Don'ts
- Do not size text in `dp`. It ignores the user's font-size setting entirely.
- Do not read `Configuration.fontScale` or a density-derived scalar as a single multiplier for text size. Android 14 and later scale large text proportionally less than small text, so no one factor describes the result.
- Do not apply a fixed `height` to a container holding scalable text, and do not add a truncating `maxLines` to meaningful content.

## Rule: Focus States

```yaml
id: global.focus-states
scope: [component]
```

### Must Haves
- Give any composable made focusable with `Modifier.focusable()` an explicit focus treatment, because a bare focusable composable draws nothing at rest.
- Draw the indicator as a border of at least 2dp around the control, in a `MaterialTheme.colorScheme` role that differs from both the control's own container color and the surface behind it. Key it to `isFocused` from `Modifier.onFocusChanged { }` for a single control, or to a custom `Indication` and `IndicationNodeFactory` where the treatment is reused.
- Show the indicator only while `LocalInputModeManager.current.inputMode` is `InputMode.Keyboard`, so it appears for hardware keyboard and D-pad navigation and not after a touch tap. This is Compose's equivalent of the web's `:focus-visible`, and unlike the web it is not automatic.
- Keep the focus treatment distinguishable from the hovered and pressed states. Material's default state layers separate focus from hover by a small opacity step, which does not reliably read as focus on its own.

### Don'ts
- Do not treat the default ripple or state layer as the focus indicator on a control you have styled yourself. It communicates a press, not a resting focus position.
- Do not remove a Material component's `indication` without supplying a replacement.
- Do not distinguish the focus indicator from the unfocused state by hue alone, since that fails for users who cannot separate the two colors.

## Rule: Focus Not Obscured

```yaml
id: global.focus-not-obscured
scope: [layout, component]
```

### Must Haves
- Scroll a newly focused item into view inside a scrolling container, using `BringIntoViewRequester` or `LazyListState.animateScrollToItem`, so focus never lands behind fixed chrome.
- Account for a `TopAppBar`, a `BottomAppBar`, a `NavigationBar`, or a bottom sheet overlapping the scrolling content beneath them.

### Don'ts
- Do not rely on the scroll container's default behavior to reveal a focused item. It scrolls the item into the viewport, which is not the same as clearing fixed chrome drawn on top of that viewport.

## Rule: Motion

```yaml
id: global.motion
scope: [component]
```

### Must Haves
- Build animation from Compose's own APIs, such as `animate*AsState`, `Animatable`, and `AnimatedVisibility`. They read the system animation scale through `MotionDurationScale` and shorten or skip motion when the user turns animations off, with no extra code.
- When a hand-rolled timing loop is unavoidable, read `Settings.Global.ANIMATOR_DURATION_SCALE` and skip the motion when it is 0. There is no Compose `CompositionLocal` that reports the reduced-motion preference, and no `isReduceMotionEnabled()` API exists.
- Give any motion that starts on its own and runs longer than five seconds a control to pause or stop it, or replace it with a static equivalent. This covers auto-advancing carousels, looping background video, and animated placeholders.
- Move focus off a composable before removing it from composition, so focus is not lost when an animated element leaves the tree.

### Don'ts
- Do not drive motion from a `LaunchedEffect` with fixed delays. It bypasses the system animation scale entirely.
- Do not attach meaning to motion alone, such as signaling an error only by a shake.

## Rule: Custom Control Semantics

```yaml
id: global.custom-control-semantics
scope: [component]
```

### Must Haves
- Declare a role on any control drawn from `Canvas`, `Layout`, or raw gestures, using `Modifier.semantics { role = Role.X }` where the closed `Role` set has a member that fits.
- Declare the full bundle the native equivalent would have provided, because Compose has no API that exposes a hidden native control behind a custom-drawn one. It supplies the pieces and the author assembles them:
  - A toggle-like control needs a role, a `stateDescription`, and `Modifier.toggleable` or an `onClick` action.
  - An adjustable control needs a role, `progressBarRangeInfo`, and a `setProgress` action.
  - A selectable control needs a role, `selected`, and `Modifier.selectable` inside a `selectableGroup`.
- Bind the declared state to the same source the visible control draws from, so the announced value cannot drift from the rendered one.
- When no `Role` member fits, carry the meaning in `contentDescription` and `stateDescription` and declare the actions, rather than claiming a role that misdescribes the control.

### Don'ts
- Do not ship a custom-drawn control with only a tap gesture and a painted label. It has no role, no state, and no action, so it is inert to assistive technology.
- Do not assume `Role` covers the control. It has nine members, far fewer than the set of controls an app can draw.

## Rule: Collection Semantics

```yaml
id: global.collection-semantics
scope: [component]
```

### Must Haves
- Name the collection. A visible heading above a list does not become the list's name; nothing on Android associates the two. Set `Modifier.semantics { contentDescription = "..." }` on the container so a user who arrives by any route other than swiping past the heading still knows what they entered.
- Declare `collectionInfo` on the container and `collectionItemInfo` on each child when position within the set is meaningful. A `LazyColumn` or `LazyRow` announces that the user is in a list, and nothing else: not the collection's name, not item position, not total count.
- Give a non-uniform collection, such as a grid whose cells span variable widths, explicit row and column indices, since nothing derives them.
- Use stable `key` values on lazy items so the accessibility tree does not reshuffle when the list updates.

### Don'ts
- Do not hand-build a position announcement into each item's `contentDescription`. It duplicates what the collection properties report and goes stale when the list changes.

## Rule: Traversal Order

```yaml
id: global.traversal-order
scope: [layout]
```

### Must Haves
- Let composition order carry the reading order wherever it already matches the visual order, which is the usual case.
- Mark a container with `Modifier.semantics { isTraversalGroup = true }` when its children should be read together before traversal moves on, such as a card whose content is visually grouped.
- Set `traversalIndex` only on a node that is focusable or inside a container marked as a traversal group. It has no effect otherwise, and lower values are read first.
- Reorder explicitly when a composable is positioned by `Modifier.offset`, drawn in a different order than it appears, or overlaid, since composition order then disagrees with what the user sees.

### Don'ts
- Do not set `traversalIndex` on every element in a screen to force an order. It is a correction for the cases where composition order is wrong, not a layout mechanism.

## Rule: Headings

```yaml
id: global.headings
scope: [layout]
```

### Must Haves
- Mark each major section header with `Modifier.semantics { heading() }`. This sets the platform heading flag that TalkBack's reading controls use for its Headings granularity, which is the only way a user skips between sections.
- Mark the title of a screen, a bottom sheet, or a dialog as a heading when it is rendered as content rather than supplied through a component's title slot.

### Don'ts
- Do not mark every bold or large text as a heading. A heading list that contains every label is as unusable as an empty one.
- Do not rely on font size or weight to communicate that text is a heading. Visual styling sets no semantics.

## Rule: Announcements

```yaml
id: global.announcements
scope: [component]
```

### Must Haves
- Announce a content change that the user did not navigate to by marking the changed element with `Modifier.semantics { liveRegion = LiveRegionMode.Polite }`, which speaks the new content without moving the user's place.
- Reserve `LiveRegionMode.Assertive` for content that must interrupt, such as a blocking error, because it cuts off whatever is being spoken.
- Announce a surface appearing, such as a bottom sheet or a pane replacing another, with `Modifier.semantics { paneTitle = "..." }` rather than a live region.
- Report a validation failure with `Modifier.semantics { error("...") }` on the field, alongside the component's own `isError` state.

### Don'ts
- Do not call `View.announceForAccessibility` or dispatch a `TYPE_ANNOUNCEMENT` event. Both are deprecated as of Android 16, API level 36.
- Do not place a live region on an item inside a lazy list. The item recomposes as the list scrolls and reannounces each time.
- Do not use a live region for a change the user caused and can already see the result of, such as text they are typing.

## Rule: Focus Management

```yaml
id: global.focus-management
scope: [layout, component]
```

### Must Haves
- Move input focus into a surface when it opens and the user has to deal with it before continuing: a modal dialog, a modal bottom sheet, a full-screen overlay. Use a `FocusRequester` and request focus from a `LaunchedEffect` once the content has entered composition.
- Move input focus to a blocking error when a submission fails, so the user lands on what stopped them rather than hunting for it.
- Leave focus where it is for anything else. Content that appears without demanding a response is announced, not focused.
- Restore input focus to the control that opened an overlay when the overlay closes, by holding a `FocusRequester` for the trigger and requesting it on dismissal.
- Treat input focus and the assistive-technology cursor as two systems. `FocusRequester` moves keyboard and D-pad focus; `Modifier.semantics { focused = true }` moves the TalkBack cursor. Neither moves the other.
- Contain focus inside a modal surface so that keyboard traversal cannot reach the content behind it.

### Don'ts
- Do not move focus to a status message, a toast-style surface, or a progress update. Taking focus for something the user did not have to act on drops them out of whatever they were reading, and they have to navigate back. Announce it instead, per `global.announcements`.
- Do not leave focus on a composable that has left the tree. It falls back to an arbitrary position, usually the top of the screen.

## Rule: Screen Announcement

```yaml
id: global.screen-announcement
scope: [screen]
```

### Must Haves
- Give every screen a visible title, rendered through a `TopAppBar` title slot or as a heading in the content.
- Set `Modifier.semantics { paneTitle = "..." }` on a surface that replaces or covers the screen without a navigation event, so its arrival is announced by name.
- Decide focus placement on navigation explicitly. Naming a screen and moving focus into it are unrelated on Android, and no navigation library guarantees the second.

### Don'ts
- Do not navigate to a screen that announces nothing. Without a title or a pane title, the change is silent.
- Do not assume the back gesture restores the accessibility cursor to the control that triggered the navigation.
