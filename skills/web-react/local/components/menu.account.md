---
id: menu.account
title: Account Menu
stack: web/react
status: beta
latest_version: 0.2.1
tags: [menu, account, profile, disclosure, popover]
aliases: [account dropdown, account menu, profile menu, user menu, avatar menu, settings menu]
summary: A non-modal, button-invoked account menu that reveals a small list of links and optional actions. Uses aria-expanded plus DOM show/hide so keyboard users Tab into items and Esc closes.
---

# Account Menu

Pattern ID: `menu.account`

A non-modal, button-invoked account menu that reveals a small list of links and optional actions. Uses `aria-expanded` plus DOM show/hide so keyboard users Tab into items and Esc closes.

## Use When
- Use when providing a compact set of account-related destinations or actions (Profile, Settings, Billing, Sign out).
- Use when the trigger is a dedicated control (avatar button, "Account" button) with no other primary action.
- Use when the menu content is short and stable (typically 3–10 items).
- Use when (usually) the menu is in the top-right area of a webpage.

## Do Not Use When
- Do not use for primary site navigation with multiple sibling dropdowns (use `navigation-menu.basic`).
- Do not use for choosing a form value (use `select.basic`, or `combobox` if searchable).
- Do not use for dense command palettes or application-style decision trees that require arrow-key navigation and focus management (use `menu.menubar`).

## Must Haves
- The invoking control is a native `<button>` (preferred), or `role="button"` only when a native button cannot be used.
  - If using `role="button"`, add `tabindex="0"` and keyboard support for Enter and Space, ensuring Space prevents page scrolling while activating.
- The invoking button reflects open state of the menu with `aria-expanded="true|false"`. This state toggle is the core signal of the pattern; the implementation fails without it.
- The invoking button is associated to the menu container with `aria-controls="IDREF"`.
- The menu content is shown/hidden in the DOM (for example via the `hidden` attribute) so that when closed, menu content cannot be reached by keyboard or screen readers.
- When the menu opens, focus remains on the invoking button.
  - Keyboard users reach the first menu item with Tab.
- The menu does not trap focus. Users can Tab through the menu items and continue to the rest of the page.
- When focus moves outside the button + menu (Tab away, click elsewhere), the menu closes.
- Esc closes the menu and returns focus to the invoking button.
- Menu items are contained in a list structure (`<ul><li>…</li></ul>`).
  - Items are links, buttons, and/or static text.
  - Any buttons and links comply with the rules for the button/link patterns.
- Ensure a visible focus state (e.g., a 2px solid outline offset by 1-2px) around the button that opens the menu, as well as the links and buttons inside.

## Customizable
- Whether the menu closes when a menu item is activated (often yes).
- Whether the menu includes non-interactive text (for example signed-in email) or separators.
- Menu positioning (left/right alignment, above/below) as long as it does not break reading and focus order.
- Accessible labeling strategy:
  - Trigger button label (for example "Account" or "Open account menu").
  - Optional label for the list (for example `aria-label="Account"` on the list, or wrap with a labeled container).

## Don'ts
- Do not render the invoking button without `aria-expanded`; `aria-haspopup` alone does not convey open/closed state.
- Do not make hover or pointer click the only way to open the menu; opening must also work with keyboard Enter and Space (native button activation).
- Do not use `role="menu"` / `role="menuitem"` unless you implement the full keyboard and focus behavior expected of composite menu widgets.
- Do not position the menu in the DOM far away from the trigger in a way that breaks focus order or causes screen readers to encounter the menu in an unexpected location.
- Do not leave the menu visible or accessible to screen readers while `aria-expanded="false"` (and vice versa).
- Do not close the menu in a way that strands focus (for example removing the focused element without moving focus).

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

export function AccountMenu() {
  const [open, setOpen] = useState(false);
  const btnRef = useRef(null);
  const listRef = useRef(null);

  const close = useCallback(() => setOpen(false), []);
  const toggle = useCallback(() => setOpen(v => !v), []);

  // Close on outside click (non-modal).
  useEffect(() => {
    if (!open) return;
    const onPointerDown = (e) => {
      const btn = btnRef.current;
      const list = listRef.current;
      if (!btn || !list) return;
      if (!btn.contains(e.target) && !list.contains(e.target)) close();
    };
    document.addEventListener("pointerdown", onPointerDown);
    return () => document.removeEventListener("pointerdown", onPointerDown);
  }, [open, close]);

  // Close when focus leaves button + list.
  useEffect(() => {
    if (!open) return;
    const onFocusIn = (e) => {
      const btn = btnRef.current;
      const list = listRef.current;
      if (!btn || !list) return;
      if (!btn.contains(e.target) && !list.contains(e.target)) close();
    };
    document.addEventListener("focusin", onFocusIn, true);
    return () => document.removeEventListener("focusin", onFocusIn, true);
  }, [open, close]);

  // Esc closes and returns focus to the trigger.
  useEffect(() => {
    if (!open) return;
    const onKeyDown = (e) => {
      if (e.key !== "Escape") return;
      e.preventDefault();
      close();
      requestAnimationFrame(() => btnRef.current?.focus());
    };
    document.addEventListener("keydown", onKeyDown, true);
    return () => document.removeEventListener("keydown", onKeyDown, true);
  }, [open, close]);

  // Close on Tab out (last->next) and Shift+Tab out (first->button).
  const onListKeyDown = (e) => {
    if (!open || e.key !== "Tab") return;

    const list = listRef.current;
    if (!list) return;

    const focusables = Array.from(
      list.querySelectorAll(
        'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    );

    if (!focusables.length) return;

    const first = focusables[0];
    const last = focusables[focusables.length - 1];

    if (!e.shiftKey && document.activeElement === last) close();
    if (e.shiftKey && document.activeElement === first) close();
  };

  return (
    <div>
      <button
        ref={btnRef}
        id="account-menu-button"
        type="button"
        aria-haspopup="true"
        aria-expanded={open ? "true" : "false"}
        aria-controls="account-menu"
        onClick={toggle}
      >
        Account
      </button>

      <ul
        id="account-menu"
        ref={listRef}
        hidden={!open}
        aria-label="Account"
        onKeyDown={onListKeyDown}
      >
        <li><a href="/profile">Profile</a></li>
        <li><a href="/settings">Settings</a></li>
        <li><a href="/billing">Billing</a></li>
        <li><button type="button" onClick={close}>Sign out</button></li>
      </ul>
    </div>
  );
}
```

## Acceptance Checks

Keyboard
- Tab lands on the invoking button.
- Enter or Space activates the button to open and close the menu.
- When opened, focus remains on the invoking button.
- Tab moves from the button into the first menu item, then through each item, then out to the next focusable element on the page.
- Shift+Tab moves backward from the first menu item to the invoking button.
- Esc closes the menu and returns focus to the invoking button.
- If focus moves outside the button + menu (Tab away or click elsewhere), the menu closes.

Screen Reader
- The invoking button announces expanded/collapsed state via `aria-expanded`; the attribute is present and flips between `"true"` and `"false"` on every open and close.
- When closed, menu items are not reachable.
- When open, the list and its items are reachable in reading and focus order.
- Links announce as links and navigate correctly.
- Buttons announce as buttons and activate correctly.
