# Feature Specification: Food Tracker iOS Application

**Feature Branch**: `001-food-tracker-app`
**Created**: 2026-03-13
**Status**: Draft
**Input**: User description: "Use ios_app_prd.md as the product requirements document to generate the system specification for the Food Tracker iOS application."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Search and Discover Food Items (Priority: P1)

A user wants to find a specific food item to understand its nutritional content. They open the app, type in a food name, and instantly see autocomplete suggestions. They can refine results using filters (protein minimum, calorie maximum, carb maximum) and sort by name, calories, or protein density. Selecting a result brings them to a detailed nutrition profile.

**Why this priority**: Search and discovery is the entry point to all other features. Without the ability to find food items, users cannot log meals or view nutrition information. This is the foundational user journey.

**Independent Test**: Can be fully tested by launching the app, typing a food name, applying filters, and verifying results appear — delivers immediate value as a nutrition lookup tool even without meal logging.

**Acceptance Scenarios**:

1. **Given** the user opens the search screen, **When** they type at least 1 character, **Then** autocomplete suggestions appear within 1 second.
2. **Given** search results are displayed, **When** the user applies a protein minimum filter of 10g, **Then** only food items with 10g or more protein are shown.
3. **Given** search results are displayed, **When** the user selects a sort option (e.g., "Calories"), **Then** results are reordered accordingly without requiring a new search.
4. **Given** the user submits a search with no matching results, **When** results load, **Then** a "No results found" message is shown with an option to clear filters.
5. **Given** the user has performed successful searches before, **When** they focus the search bar, **Then** the last 5 recent searches are shown as quick-access shortcuts.

---

### User Story 2 - View Detailed Nutrition Profile (Priority: P2)

A user selects a food item from search results to view its full nutritional breakdown. They can see macros displayed in a visual chart, switch between serving units (cup, container, grams, etc.), and adjust the quantity. The nutrition values update automatically based on their selection.

**Why this priority**: Nutrition detail is the core value proposition — users need accurate, adjustable nutrition data to make informed dietary choices. It directly enables the meal logging flow.

**Independent Test**: Can be fully tested by selecting any food item from search results, changing the serving unit and quantity, and verifying that nutrition values recalculate correctly — delivers value as a standalone nutrition calculator.

**Acceptance Scenarios**:

1. **Given** the user selects a food item, **When** the detail screen loads, **Then** a macro breakdown chart (Protein, Carbs, Fat) is displayed.
2. **Given** the food detail screen is open, **When** the user selects a different serving unit from the dropdown, **Then** all nutrition values update to reflect the new unit.
3. **Given** the user enters a custom weight value greater than 0, **When** they confirm the input, **Then** nutrition values scale proportionally.
4. **Given** the user enters a weight value of 0 or negative, **When** they attempt to confirm, **Then** an error message is displayed and the value is not accepted.
5. **Given** the food detail screen is open, **When** the user toggles the micronutrients view, **Then** additional details (Sodium, Fiber, etc.) are shown or hidden accordingly.

---

### User Story 3 - Log a Meal (Priority: P3)

A user wants to record what they ate for a meal. From the food detail screen, they add a food item to their current meal. They can add multiple food items before saving the meal entry with a meal type (Breakfast, Lunch, Dinner, Snack). The meal is saved immediately and remains accessible even when offline.

**Why this priority**: Meal logging is the primary retention feature — it gives users a reason to return daily. Offline-first persistence ensures the app is reliable regardless of connectivity.

**Independent Test**: Can be fully tested by adding one or more food items, saving as a named meal type, then disabling network connectivity and verifying the meal persists and is readable.

**Acceptance Scenarios**:

1. **Given** the user is on the food detail screen, **When** they tap "Add to Meal," **Then** the food item is added to the current active meal.
2. **Given** the user has added one or more food items, **When** they save the meal with a meal type selected, **Then** the meal is persisted locally and immediately visible in today's dashboard.
3. **Given** the device has no network connection, **When** the user logs a meal, **Then** the meal is saved locally and marked as pending sync.
4. **Given** multiple food items have been added to a meal, **When** the meal is saved, **Then** total calories and macros for the meal are calculated correctly as the sum of all items.

---

### User Story 4 - View Daily Dashboard and Progress (Priority: P4)

A user opens the app to see a summary of their day's nutrition. The dashboard shows total calories consumed, macronutrient progress bars against daily goals, and a list of all meals logged today. They can delete a meal from this screen if needed.

**Why this priority**: The dashboard provides motivation and accountability — it shows users how their daily intake compares to their goals. Builds the habit loop that drives daily engagement.

**Independent Test**: Can be fully tested by logging at least one meal and then viewing the dashboard — verifying that calorie ring, macro bars, and meal list all reflect the logged data accurately.

**Acceptance Scenarios**:

1. **Given** the user opens the app, **When** the dashboard loads, **Then** today's total calorie intake is displayed as a circular progress indicator.
2. **Given** meals have been logged today, **When** the dashboard loads, **Then** macronutrient progress bars show current intake for Protein, Carbs, and Fat.
3. **Given** the user logs a new meal, **When** they return to the dashboard, **Then** the calorie ring and macro bars update immediately to reflect the new totals.
4. **Given** a meal is listed on the dashboard, **When** the user deletes it, **Then** the meal is removed and daily totals are recalculated.

---

### User Story 5 - Edit a Saved Meal (Priority: P5)

A user realizes they logged the wrong quantity for a food item or wants to add a missed item to an existing meal. They open the meal from the dashboard or history screen, make their changes (adjust quantity, add or remove items), and save. The updated meal replaces the original and daily totals reflect the change immediately.

**Why this priority**: Editing prevents users from having to delete and re-log an entire meal for a single correction, reducing friction and improving data accuracy over time.

**Independent Test**: Can be fully tested by logging a meal, reopening it for edit, changing an item's quantity, saving, and verifying the dashboard totals update to reflect the change.

**Acceptance Scenarios**:

1. **Given** a saved meal exists, **When** the user opens it for editing, **Then** the existing food items and quantities are pre-populated and editable.
2. **Given** the user is editing a meal, **When** they change the quantity of an item to a valid value (> 0), **Then** the item's nutrition contribution updates accordingly.
3. **Given** the user is editing a meal, **When** they remove an item, **Then** that item is no longer part of the meal and the meal totals recalculate.
4. **Given** the user is editing a meal, **When** they add a new food item, **Then** the item is appended to the meal and totals reflect the addition.
5. **Given** the user saves the edited meal, **When** they return to the dashboard, **Then** daily nutrition totals reflect the updated meal data.

---

### User Story 7 - Browse Meal History (Priority: P7)

A user wants to review what they ate on previous days. They navigate to the meal history screen, browse past dates via a calendar ribbon, and see all meals logged on each selected date. They can tap on a meal entry to view its food items and nutritional details.

**Why this priority**: History view supports long-term dietary awareness and accountability. Users track patterns over time to understand and improve their eating habits.

**Independent Test**: Can be fully tested by logging meals on at least two different dates and then using the calendar ribbon to navigate between those dates, verifying correct meal data is shown for each.

**Acceptance Scenarios**:

1. **Given** the user opens the meal history screen, **When** they select a past date from the calendar ribbon, **Then** all meals logged on that date are displayed.
2. **Given** no meals were logged on a selected date, **When** the user selects that date, **Then** a "No meals logged" message is shown.
3. **Given** a historical meal is displayed, **When** the user taps on it, **Then** the food items and nutrition breakdown for that meal are shown.

---

### Edge Cases

- What happens when the food search service is unavailable? The app displays an offline banner and serves cached nutrition results from the last 24 hours if available; otherwise shows an appropriate message.
- What happens when the user enters 0 or a negative value for food quantity? The system rejects the input with a validation error and requires a value greater than 0 before proceeding.
- What happens when the device goes offline mid-session? Meal logging continues without interruption; items are saved locally and queued for future sync when connectivity is restored.
- What happens when the user clears all filters on an empty result set? The system re-runs the search without filters and displays updated results.
- What happens when more than 20 items match a search query? Only the top 20 results are shown; the user must refine their query to find items not in the visible set.
- What happens when a meal record is deleted? All associated food items for that meal are also removed, and daily nutrition totals on the dashboard recalculate immediately.
- What happens if a food item has no micronutrient data available? The micronutrient toggle section does not appear or shows a "Not available" message for that item.
- What happens if the user removes all items from a meal while editing? The meal cannot be saved in an empty state; the user must either add at least one item or discard the edit (leaving the original meal unchanged).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST allow users to search for food items by name, displaying up to 20 results within 1 second. Users refine their query to narrow results; no pagination or "load more" is provided.
- **FR-002**: The app MUST display autocomplete suggestions starting from the first character typed in the search field.
- **FR-003**: Users MUST be able to filter search results by minimum protein (grams), maximum calories, and maximum carbohydrates.
- **FR-004**: Users MUST be able to sort search results by name, calories, or protein density.
- **FR-005**: The app MUST store the last 5 successful search queries locally and display them when the search field is focused.
- **FR-006**: The app MUST display a visual macro distribution chart (Protein, Carbs, Fat) on the food detail screen.
- **FR-007**: Users MUST be able to select a serving unit from a dropdown on the food detail screen.
- **FR-008**: The app MUST recalculate and display updated nutrition values immediately when the user changes serving unit or quantity.
- **FR-009**: The app MUST reject weight/quantity inputs of 0 or below with a clear validation error message.
- **FR-010**: Users MUST be able to toggle the display of micronutrients (Sodium, Fiber, etc.) on the food detail screen.
- **FR-011**: Users MUST be able to add one or more food items to a single meal entry before saving.
- **FR-012**: The app MUST save meal entries to local storage immediately upon confirmation, independent of network connectivity.
- **FR-013**: Users MUST be able to assign a meal type (Breakfast, Lunch, Dinner, Snack) when saving a meal.
- **FR-014**: The dashboard MUST display today's total calorie intake as a circular progress indicator against a daily goal of 2000 kcal.
- **FR-015**: The dashboard MUST display macronutrient progress (Protein, Carbs, Fat) as progress bars against daily goals of 150g protein, 250g carbs, and 65g fat, updating in real time when meals are logged or deleted.
- **FR-016**: Users MUST be able to delete a meal from the dashboard, with daily totals recalculating immediately after deletion.
- **FR-017**: The meal history screen MUST allow users to browse all past dates back to their first logged meal via a calendar ribbon, and view all meals logged on each selected date.
- **FR-018**: The app MUST display an offline indicator when network connectivity is unavailable, while still allowing full meal logging.
- **FR-019**: The app MUST gracefully fall back to cached nutrition data from the last 24 hours when the food data service is unavailable.
- **FR-020**: When a meal is deleted, all associated food items within that meal MUST also be removed and daily nutrition totals MUST recalculate.
- **FR-021**: Users MUST be able to open a saved meal for editing from the dashboard or meal history screen.
- **FR-022**: While editing a meal, users MUST be able to adjust item quantities, remove existing items, and add new food items.
- **FR-023**: Saving an edited meal MUST immediately update the stored meal record and recalculate daily nutrition totals on the dashboard.

### Key Entities

- **Food Item**: A transient representation of a food product retrieved from the food data source. Key attributes: name, type (generic/branded), calories, protein, carbs, fat per 100g. Not persisted locally.
- **Serving Unit**: A unit of measurement for a food item (e.g., cup, container, grams). Key attributes: unit name, gram equivalent. Retrieved from the data source on demand; not stored locally.
- **Meal Record**: A user-created meal entry stored on the device. Key attributes: unique identifier, date and time, meal type (Breakfast/Lunch/Dinner/Snack), collection of meal items, sync status (pending/synced). Persists offline.
- **Meal Item**: An individual food entry within a meal. Key attributes: food identifier, food name, quantity in grams, calories, protein, carbs, fat at the logged quantity. Belongs to exactly one Meal Record; removed when the parent meal is deleted.
- **Daily Summary**: A computed view aggregating all Meal Records for a given calendar date. Represents total calories and macronutrient totals. Derived from stored Meal Records; not persisted separately.
- **Recent Search**: A locally stored record of a previously successful search query. Maximum of 5 entries retained; oldest entry is replaced when the limit is reached.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find a food item and view its nutrition details in under 30 seconds from opening the app.
- **SC-002**: Search results and autocomplete suggestions appear within 1 second of the user typing.
- **SC-003**: Nutrition values on the food detail screen recalculate within 0.5 seconds of the user changing serving unit or quantity.
- **SC-004**: Meal logging succeeds 100% of the time regardless of whether the device is online or offline.
- **SC-005**: Daily nutrition totals on the dashboard update within 1 second of a meal being logged or deleted.
- **SC-006**: Users can complete a full meal log flow (search food, view details, add item, save meal) in under 2 minutes.
- **SC-007**: 90% of users successfully log their first meal on first use without encountering a blocking error.
- **SC-008**: All previously logged meals remain accessible and accurate after the app is closed and reopened, including under offline conditions.
- **SC-009**: Historical meal data is retrievable for any previously logged date without noticeable loading delays (under 1 second).

## Clarifications

### Session 2026-03-13

- Q: What are the predefined default daily nutrition goals shown on the dashboard? → A: 2000 kcal, 150g protein, 250g carbs, 65g fat
- Q: Is meal editing in scope (modifying a saved meal's items or quantities)? → A: Yes — users can edit a saved meal by adding/removing individual items or changing quantities
- Q: How many search results are shown per query, and is pagination supported? → A: Up to 20 results per search; no pagination — users refine their query to narrow results
- Q: Is any in-app data protection or access control required beyond the device lock screen? → A: No — the app relies solely on the device's native lock screen; no in-app PIN or biometric lock
- Q: How far back does the meal history calendar extend? → A: Unlimited — all dates back to the first ever logged meal are accessible

## Assumptions

- Users do not need an account or authentication to use the app; all data is stored locally on the device. Data protection relies solely on the device's native lock screen — no in-app PIN or biometric lock is provided.
- Daily macro goals use predefined defaults (2000 kcal, 150g protein, 250g carbs, 65g fat) and are not user-configurable in this version; goal customization is out of scope.
- Meal history is retained indefinitely on the device with no automatic data expiration. The calendar in the history screen extends back to the date of the first ever logged meal.
- The food data source is an existing external service; the app consumes it but does not manage or host it.
- Server synchronization of meal records is planned for a future version; this version covers local persistence only (sync status is tracked but no upload occurs).
- Search results are not persisted locally; only the last 5 search query strings are stored for quick access.
- The app is designed for a single user per device; multi-user profiles or account sharing are out of scope.
- Micronutrient data (Sodium, Fiber, etc.) availability depends on the food data source; the app displays whatever is provided and handles absent data gracefully.
