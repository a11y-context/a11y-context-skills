---
id: progress-indicator.basic
title: Progress Indicator
stack: android/compose
status: beta
latest_version: 0.1.0
tags: [progress, progress bar, loading, spinner, busy, upload, download, percentage]
aliases: [LinearProgressIndicator, CircularProgressIndicator, progress bar, progress ring, loading spinner, spinner, activity indicator, busy indicator, determinate progress, indeterminate progress, ProgressBarRangeInfo, progressSemantics]
summary: Bar or ring showing that work is under way, with or without a measure of how much is done. Material reports a value or an indeterminate state but names neither, so on its own the indicator says "45 percent" or "in progress" without saying of what, and nothing says when the work ends.
---

# Progress Indicator

Pattern ID: `progress-indicator.basic`

Bar or ring showing that work is under way, with or without a measure of how much is done. Material reports a value or an indeterminate state but names neither, so on its own the indicator says "45 percent" or "in progress" without saying of what, and nothing says when the work ends.

## Use When
- Use when the app knows how much of a task is done and how much remains, and shows it (e.g., an upload, a download, a multi-step import).
- Use when work is under way and the app cannot say how much remains (e.g., loading a screen's content, contacting a server).
- Use when a control shows that its own action is in progress, such as a button that displays a spinner while it saves.

## Do Not Use When
- Do not use when the user sets the value (use `slider.basic`).

## Must Haves
- The indicator is determinate when the app knows how much of the work is done, and reports that amount; it is indeterminate when the app does not, and reports only that work is under way. Material's `LinearProgressIndicator` and `CircularProgressIndicator` are the reference implementation, through `ProgressBarRangeInfo` for the first and `progressSemantics()` for the second; a hand-drawn bar or spinner reports neither by default (`global.native-first`).
- For a determinate indicator, pass `progress` as a lambda (`progress = { fraction }`) with the fraction done, from 0 to 1; for an indeterminate one, leave `progress` out. The overload taking a `Float` is deprecated, and Material reports `NaN` as 0, so a miscalculated value reads as an empty bar rather than failing.
- Name an indicator that stands on its own for the work it tracks, with `Modifier.semantics { contentDescription = "..." }` on the indicator (e.g., "Uploading 3 photos", "Loading reviews").
- When the indicator sits inside a control, carry the progress in the control and remove the indicator's own semantics with `Modifier.clearAndSetSemantics {}`. The indicator merges its own semantics, so inside a merged control it stays a second stop. For a determinate indicator, set the amount as the control's `stateDescription` (e.g., "45 percent"); for an indeterminate one, change the control's label (e.g., "Save" becomes "Saving").
- Keep a control focusable while it shows its own progress, and ignore a repeat activation in its click handler. A clickable set to `enabled = false` drops its focusable node, so a keyboard user who has just pressed it loses focus the moment it starts showing progress.
- Announce the end of the work, success or failure alike, with a polite live region on the content or status text that replaces the indicator (`global.announcements`).
- Remove the indicator from composition when the work ends, so it does not stay in the tree reporting progress.

## Don'ts
- Do not leave a standalone indicator unnamed. TalkBack reads a percentage, or that something is in progress, with nothing to say what.
- Do not make the indicator itself a live region. A determinate one would read every change in value aloud; an indeterminate one would announce only that work started, which the user usually caused.
- Do not show a visible percentage beside a determinate indicator and leave both in the tree. The user hears the value twice; hide the label with `Modifier.clearAndSetSemantics {}` or fold the indicator into the label.
- Do not disable the control that started the work. Its focus goes with it.
- Do not end the work silently. A user who cannot see the screen has no other way to learn that it finished or failed.
- Do not move focus to the indicator, or to the content when it arrives, unless the user has to act on it (`global.focus-management`).
- Do not build a bar from a `Box` with a fractional width, or a spinner by rotating an `Icon` forever. Neither reports progress.

## Customizable
- Linear or circular is a visual choice with the same contract.
- An indicator may start indeterminate and become determinate once the total is known, by beginning to pass `progress`.
- A visible label naming the work may sit beside a standalone indicator, in which case the indicator's `contentDescription` matches it.
- The arrival message may be the loaded content itself, marked as a polite live region, or a short status line such as "12 reviews loaded".
- Colors come from the theme's color scheme, so the indicator keeps its contrast against the track and the surface in light and dark themes (`global.semantic-color`).

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```kotlin
@Composable
fun ProgressIndicatorExamples(
    uploaded: Int,
    total: Int,
    reviews: List<Review>?,
    reviewsFailed: Boolean,
    downloadFraction: Float?,
    saving: Boolean,
    onSave: () -> Unit
) {
    Column {
        if (uploaded < total) {
            // Determinate: the amount done is known, so it is passed as `progress`.
            LinearProgressIndicator(
                progress = { uploaded.toFloat() / total },
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { contentDescription = "Uploading $total photos" }
            )
        } else {
            Text(
                "$total photos uploaded",
                modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite }
            )
        }

        when {
            reviewsFailed -> Text(
                "Reviews could not be loaded",
                modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite }
            )
            // Indeterminate: the amount done is unknown, so `progress` is left out.
            reviews == null -> CircularProgressIndicator(
                modifier = Modifier.semantics { contentDescription = "Loading reviews" }
            )
            else -> Text(
                "${reviews.size} reviews",
                modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite }
            )
        }

        Button(
            onClick = { /* download or cancel */ },
            modifier = Modifier.semantics {
                if (downloadFraction != null) {
                    stateDescription = "${(downloadFraction * 100).roundToInt()} percent"
                }
            }
        ) {
            if (downloadFraction != null) {
                // Determinate, in a button: its stateDescription carries the amount.
                CircularProgressIndicator(
                    progress = { downloadFraction },
                    modifier = Modifier.size(18.dp).clearAndSetSemantics {}
                )
                Spacer(Modifier.width(8.dp))
                Text("Downloading episode")
            } else {
                Text("Download episode")
            }
        }

        Button(onClick = { if (!saving) onSave() }) {
            if (saving) {
                // Indeterminate, in a button: its label change carries the state.
                CircularProgressIndicator(
                    modifier = Modifier.size(18.dp).clearAndSetSemantics {},
                    strokeWidth = 2.dp
                )
                Spacer(Modifier.width(8.dp))
                Text("Saving")
            } else {
                Text("Save")
            }
        }
    }
}
```
