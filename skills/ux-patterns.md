---
name: ux-patterns
description: UX design patterns and interaction principles for WasteHero platform features. Designer-maintained. Loaded by bl-design when a requirement touches user-facing flows.
---

# UX Patterns

> **For the designer:** Fill in each section with WasteHero-specific patterns. The build agent reads this file before designing any frontend. Be specific — vague guidance will be ignored in favour of the agent's defaults.

---

## Navigation & Information Architecture

<!-- 
Describe how features are typically exposed in the nav.
Example:
- New list views always appear as a sub-item under the relevant domain section
- Modals are preferred over new pages for actions that don't require their own URL
- Breadcrumbs are required on any page more than 2 levels deep
-->

[FILL IN]

---

## List Views & Tables

<!--
Describe how data tables should behave.
Example:
- All list views must support search and column-based filtering
- Pagination: 25 rows default, user can change to 50 or 100
- Row actions appear on hover in the rightmost column
- Empty state must include an illustration and a primary CTA
- Sorting: clicking column header toggles asc/desc, third click removes sort
-->

[FILL IN]

---

## Forms & Input

<!--
Example:
- Inline validation on blur, not on keystroke
- Required fields marked with asterisk, not "optional" label on optional fields
- Submit button disabled until all required fields are valid
- Error messages appear below the field, not in a toast
- Date pickers use the platform date picker component, not native browser
-->

[FILL IN]

---

## Confirmation & Destructive Actions

<!--
Example:
- Destructive actions (delete, terminate, cancel contract) always require a confirmation modal
- Confirmation modal must name the specific item being affected: "Delete contract for John Smith?"
- Use red/danger styling on the confirm button
- Bulk destructive actions show count: "Delete 12 contracts?"
-->

[FILL IN]

---

## Loading & Async States

<!--
Example:
- Skeleton loaders for initial page load, spinner for subsequent async actions
- Optimistic updates for toggle/status changes
- Error states must offer a retry action
- Long operations (>3s) show a progress indicator
-->

[FILL IN]

---

## Notifications & Feedback

<!--
Example:
- Success: green toast, 3s auto-dismiss, top-right
- Error: red toast, persistent (user must dismiss), top-right
- Warning: yellow inline banner above the affected section
- Never use browser alert()
-->

[FILL IN]

---

## Mobile & Responsive

<!--
Example:
- Back-office features (admin, dispatcher) are desktop-first, must be usable on tablet
- Field worker features must be fully functional on mobile (375px+)
- Tables collapse to card lists on mobile
-->

[FILL IN]

---

## Examples

<!--
Add annotated screenshots or flow descriptions of existing features that the agent should match.
Example:

### Reference: Container Assignment Flow
1. User clicks "Assign Container" on a property row
2. A right-side drawer opens (not a modal) with a search field
3. Results appear as a list with container ID, type, and current status
4. Selecting a container shows a summary and an "Assign" button
5. On success: drawer closes, row updates inline, green toast appears

The agent should match this drawer pattern for similar assignment flows.
-->

[FILL IN]
