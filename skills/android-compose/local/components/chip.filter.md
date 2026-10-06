---
id: chip.filter
title: Filter Chip
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [chip, filter, filter chip, selection, refine, tag]
aliases: [FilterChip, ElevatedFilterChip, filter chip, selectable chip, choice chip, tag, selectable tag, facet, refinement]
summary: Chip that turns a filter on or off for the content it sits above. Material's FilterChip reports a checkbox role and a selected state and drops its border when selected; naming the set of chips and announcing the changed results are the caller's.
---

# Filter Chip

Pattern ID: `chip.filter`

Chip that turns a filter on or off for the content it sits above. Material's `FilterChip` reports a checkbox role and a selected state and drops its border when selected; naming the set of chips and announcing the changed results are the caller's.

## Use When
- Use when the user narrows a set of content by turning one or more filters on and off, and the content updates in place (e.g., "Vegetarian", "Under 30 minutes", "Five stars" above a list of recipes).

## Do Not Use When
- Do not use when the chip performs an action rather than holding a state (use `button.basic`, which covers assist and suggestion chips).
- Do not use when the chip is a value the user entered and can remove (use `chip.input`).
- Do not use when only one option can be on at a time, such as a sort order (use `segmented-button.basic` or `radio.basic`).
- Do not use when the control is a persistent setting (use `switch.basic`).

## Must Haves
- Each chip reports its label, its selected state, and a click action. Material's `FilterChip` and `ElevatedFilterChip` are the reference implementation, reporting `Role.Checkbox` and a selected state on a selectable surface with a 48dp target; a chip drawn with `Modifier.clickable` and a tinted background reports neither (`global.native-first`).
- Name each chip with its visible label, worded so the filter stands on its own (e.g., "Vegetarian", not "Yes"). Give a leading or trailing icon `contentDescription = null` when the label already says what it shows (`global.icon`).
- Show the selected state by more than its color. `FilterChip` drops its border and fills its container when selected; keep that border change when restyling it, or show a check-mark `leadingIcon` while the chip is selected (`global.use-of-color`).
- Name the set of chips on its container with `Modifier.semantics { contentDescription = "..." }`, matching a visible label (e.g., "Filter recipes"), so a user entering the chips hears what they filter (`global.collection-semantics`).
- When selecting a chip changes the content, announce the new result once through a polite live region on a short status line (e.g., "12 recipes"), and leave focus on the chip (`global.announcements`).
- If a filter is unavailable, pass `enabled = false` rather than removing the handler, so the chip stays in the accessibility tree and reports that it is disabled.
- Meets the touch target baseline in `global_rules.md` (`global.touch-target-size`).
- Meets the focus states baseline in `global_rules.md` (`global.focus-states`).

## Don'ts
- Do not move focus to the results when a chip is selected. The user is choosing filters, and moving them loses their place among the chips.
- Do not make the results themselves a live region. TalkBack reads the changed content item by item instead of a short count.
- Do not build a filter from a `Button` whose color changes when it is on. It reports a button with no state.
- Do not use filter chips for a choice where only one can be on. They report independent checkboxes, so TalkBack describes filters that combine when the screen allows one.

## Customizable
- The chips may wrap in a `FlowRow` or scroll in a `LazyRow`.
- A "Clear filters" control may follow the chips, built as `button.basic` describes.
- `FilterChip` and `ElevatedFilterChip` differ only in elevation and share the same semantics.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun FilterChipExamples(resultCount: Int) {
    val filters = listOf("Vegetarian", "Under 30 minutes", "Five stars")
    val selected = remember { mutableStateListOf(false, false, false) }

    Column {
        Text("Filter recipes")
        FlowRow(
            modifier = Modifier.semantics { contentDescription = "Filter recipes" }
        ) {
            filters.forEachIndexed { index, filter ->
                FilterChip(
                    selected = selected[index],
                    onClick = { selected[index] = !selected[index] },
                    label = { Text(filter) },
                    leadingIcon = if (selected[index]) {
                        { Icon(Icons.Filled.Done, contentDescription = null) }
                    } else {
                        null
                    }
                )
            }
        }
        Text(
            "$resultCount recipes",
            modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite }
        )
    }
}
```
