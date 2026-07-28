---
id: tabs.basic
title: Tabs
stack: web/react
status: beta
latest_version: 0.1.0
tags: [tabs, tablist, roving-tabindex, view-switching, disclosure, segmented-control]
aliases: [tabbed interface, tab panel, tab bar, view switcher, content switcher, segmented control, pill navigation, browse tabs]
summary: Same-page sections where one panel is visible at a time, using role="tablist", role="tab", and role="tabpanel" with aria-selected, a roving tabindex, and arrow-key traversal.
---

# Tabs

Pattern ID: `tabs.basic`

Same-page sections where one panel is visible at a time, using `role="tablist"`, `role="tab"`, and `role="tabpanel"` with `aria-selected`, a roving tabindex, and arrow-key traversal.

This pattern is same-page view switching: the tabs and their panels live in one document, and activating a tab displays a different panel in place without navigating or submitting anything. Visual style does not determine the role, so a segmented control that swaps visible panels is tabs, and a bar of links that load different URLs is not.

## Use When
- Use when a large amount of same-page content divides into a few clearly labeled sections at the same level, and the user views one section at a time (e.g., "Episodes", "Details", and "More Like This" on a title page).
- Use when one collection is presented through several filtered or status-partitioned views of the same kind of item (e.g., "Continue Watching", "Saved", and "Downloads" in a personal list).
- Use when the sections are consulted regularly by returning users, and the sections that start hidden are supplemental rather than critical.
- Use when switching between sections keeps the user in place, without loading a different URL or reloading the page.

## Do Not Use When
- Do not use when each tab is a link that loads a different URL or route (use `navigation-menu.basic`, or `navigation-menu.dropdown` when the navigation opens from a trigger).
- Do not use when the sections are steps in a sequence the user works through in order (use `stepper.basic`).
- Do not use when sections stack vertically and expand or collapse independently, with more than one open at a time (use `accordion.basic`, or `disclosure.basic` for a single show/hide section).
- Do not use when the control records a choice such as a filter value, a form field, or a setting rather than displaying a different panel of content (use `radio.group`, or `select.native` when one value is picked from a list).

## Must Haves

### Roles & structure
- The set of tabs is contained in an element with `role="tablist"`.
- Each tab has `role="tab"` and is contained within the tablist.
- Each tab uses a native `<button>` as its base element (preferred), or a non-native element with `role="tab"` only when a native button cannot be used.
  - If a non-native element is used, add `tabindex` and keyboard support for Enter and Space, ensuring Space prevents page scrolling while activating the tab.
- Each panel is an element with `role="tabpanel"`.
- Exactly one tabpanel is displayed at a time.
- Each tabpanel is shown/hidden in the DOM (e.g., via the `hidden` attribute), so that when hidden, its content cannot be reached by keyboard or screen readers.
- A vertically stacked tablist has `aria-orientation="vertical"`; a horizontal tablist omits the attribute.

### Accessible name
- The tablist has an accessible name, via `aria-labelledby` referencing a visible heading when one exists, otherwise via `aria-label`.
- Each tab's visible text is contained in its accessible name, and appears at the start of it when additional context is appended.
- Each tabpanel has `aria-labelledby` referencing the `id` of its tab.

### State & properties
- The selected tab has `aria-selected="true"` and every other tab has `aria-selected="false"`.
  - The `"false"` value is set explicitly, including on a tab that holds focus without being selected under manual activation.
- Each tab has `aria-controls` referencing the `id` of its tabpanel.
- The selected tab is distinguishable from unselected tabs by more than color (e.g., weight, an underline, or an icon), per `global.use-of-color`.

### Keyboard
- The tab set implements one activation model consistently (see Customizable for choosing one).
  - Under automatic activation, arrow-key movement also selects the newly focused tab and displays its panel.
  - Under manual activation, arrow-key movement changes focus only, and the selected tab and displayed panel do not change until Enter or Space.
- Right Arrow and Left Arrow move focus between tabs and wrap at the ends.
  - In a vertical tablist, Down Arrow performs as Right Arrow and Up Arrow performs as Left Arrow. A horizontal tablist leaves Up and Down Arrow alone so the page can still scroll.
- Home moves focus to the first tab and End moves focus to the last tab.
- Enter or Space activates the focused tab when it was not already activated on focus.
- Tab moves focus out of the tablist to the next element in the page tab sequence, never to another tab.

### Focus
- The selected tab has `tabindex="0"` and every other tab has `tabindex="-1"`, so the tablist is a single Tab stop.
  - Under manual activation, focus can rest on a tab whose `tabindex` is `-1`.
- When the tabpanel's content begins with a non-focusable element, the tabpanel has `tabindex="0"`, so that Tab from the tablist reaches the panel content instead of skipping past it.
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around the tabs and around the tabpanel when it is focusable.
  - The focus indicator on a focused tab is distinguishable from the selected-tab styling.

## Customizable
- Activation model. Automatic activation (as in the golden pattern) is appropriate when the panels are displayed without noticeable latency. Choose manual activation when activating a tab fetches panel data, navigates or refreshes the page, starts media playback, discards in-progress work, or renders slowly enough to be perceptible.
- Tab count and label length. Keep labels to 1-2 words and the set small enough to fit one unwrapped row; design systems converge on 3 to 5 tabs, with 8 a practical ceiling. When one section matters more than the rest, place it first and select it by default.
- Orientation. Horizontal is the default; a vertically stacked tablist is equally acceptable.
- How hidden panels are hidden. The `hidden` attribute keeps inactive panels mounted and preserves their state, including scroll position and form input, across switches. Rendering only the selected panel and unmounting the rest resets that state on every switch.
- Unavailable tabs. A tab that cannot currently be selected may carry `aria-disabled="true"` and stay in the arrow-key sequence so screen reader users can discover it, or be omitted from the set entirely. Do not use the native `disabled` attribute, which removes the tab from the arrow-key sequence.
- The tab base element: `<button role="tab">` (as in the golden pattern) or a non-native element with `role="tab"` plus hand-rolled focus and keyboard wiring.
- Collapsing to `accordion.basic` below a viewport breakpoint is at the engineer's discretion, as long as each layout implements its own pattern completely and focus is preserved across the swap.

## Don'ts
- Do not leave a tabpanel visible while its tab has `aria-selected="false"` (and vice versa).
- Do not derive arrow-key movement from the selected tab's index instead of the focused tab's index.
- Do not move focus off the activated tab. Activation leaves focus on that tab and does not move it into the tabpanel, open a window, submit a form, or navigate (WCAG 3.2.1 On Focus).

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

// Switch to "manual" when displaying a panel is not instantaneous.
const ACTIVATION = "automatic";

export function TabsDemo() {
  const baseId = useId();
  const [selectedIndex, setSelectedIndex] = useState(0);
  const tabRefs = useRef(new Map());

  const tabId = (index) => `${baseId}-tab-${index}`;
  const panelId = (index) => `${baseId}-panel-${index}`;

  function focusTab(index) {
    tabRefs.current.get(index)?.focus();
    if (ACTIVATION === "automatic") setSelectedIndex(index);
  }

  // Movement is computed from the FOCUSED tab's index, not the selected one.
  // The two diverge the moment activation is manual.
  function onTabKeyDown(index, event) {
    const last = SECTIONS.length - 1;
    switch (event.key) {
      case "ArrowRight":
        event.preventDefault();
        focusTab(index === last ? 0 : index + 1);
        break;
      case "ArrowLeft":
        event.preventDefault();
        focusTab(index === 0 ? last : index - 1);
        break;
      case "Home":
        event.preventDefault();
        focusTab(0);
        break;
      case "End":
        event.preventDefault();
        focusTab(last);
        break;
      case "Enter":
      case " ":
        event.preventDefault();
        setSelectedIndex(index);
        break;
      default:
        break;
    }
  }

  return (
    <div>
      <div role="tablist" aria-label="Browse by content type">
        {SECTIONS.map((section, index) => {
          const isSelected = index === selectedIndex;
          return (
            <button
              key={section.title}
              type="button"
              role="tab"
              id={tabId(index)}
              aria-selected={isSelected ? "true" : "false"}
              aria-controls={panelId(index)}
              // Roving tabindex: the tablist is one Tab stop.
              tabIndex={isSelected ? 0 : -1}
              ref={(el) => {
                if (el) tabRefs.current.set(index, el);
                else tabRefs.current.delete(index);
              }}
              // Safari does not focus a button on click, so focus and the
              // roving tabindex would drift apart without the explicit call.
              onClick={() => {
                tabRefs.current.get(index)?.focus();
                setSelectedIndex(index);
              }}
              onKeyDown={(event) => onTabKeyDown(index, event)}
              style={{
                fontWeight: isSelected ? 600 : 400,
                borderBottom: isSelected ? "3px solid" : "3px solid transparent",
              }}
            >
              {section.title}
            </button>
          );
        })}
      </div>

      {SECTIONS.map((section, index) => (
        <div
          key={section.title}
          role="tabpanel"
          id={panelId(index)}
          aria-labelledby={tabId(index)}
          hidden={index !== selectedIndex}
          // These panels start with non-focusable content, so tabindex="0"
          // puts the open panel in the tab sequence.
          tabIndex={0}
        >
          <ul>
            {section.titles.map((title) => (
              <li key={title}>{title}</li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}

const SECTIONS = [
  { title: "Movies", titles: ["Harbor Lights", "The Long Rewind", "Static Sky"] },
  { title: "Shows", titles: ["Signal Lost", "Night Dispatch", "The Quiet Hours"] },
  { title: "Live TV", titles: ["Sci-Fi Classics 24/7", "Retro Toons", "World News"] },
];
```

## Acceptance Checks

Keyboard
- Tab moves focus into the tablist and lands on the selected tab, and pressing Tab again moves focus out of the tablist rather than to another tab.
- When the visible panel begins with non-focusable content, Tab from the tablist moves focus to the panel itself.
- Right Arrow and Left Arrow move focus between tabs and wrap at both ends.
- Home moves focus to the first tab and End moves focus to the last tab.
- Under automatic activation, arrowing to a tab immediately displays its panel; under manual activation, the panel changes only on Enter or Space.
- The focused tab shows a visible focus indicator that is distinguishable from the selected-tab styling.

Screen Reader
- The container is announced as a tab list with its accessible name.
- Each tab is announced as a tab with its name, selected state, and position in the set (e.g., "Shows, tab, two of three").
- The newly displayed panel is announced with the activating tab's name and the tab panel role when focus moves into it.
- Inactive panels are absent from the reading order, so reading through the page never encounters hidden panel content.
