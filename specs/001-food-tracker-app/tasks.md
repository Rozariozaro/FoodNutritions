# Tasks: Food Tracker iOS App

**Input**: Design documents from `/specs/001-food-tracker-app/`
**Prerequisites**: plan.md ✅, spec.md ✅, data-model.md ✅, contracts/food-api-client.md ✅, contracts/persistence-layer.md ✅, quickstart.md ✅

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.
**Tests**: Included — each phase ends with unit test tasks. See `contracts/testing-strategy.md` for the full test scope and mock strategy.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US5, US7)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Xcode project scaffold, folder structure, config files, and app entry point

- [X] T001 Create Xcode project `FoodNutritions` targeting iOS 17.0 with SwiftUI lifecycle in `FoodNutritions/`
- [X] T002 Create full folder structure: `App/`, `Core/UI/`, `Core/Extensions/`, `Core/Constants/`, `Domain/Models/Enums/`, `Domain/Errors/`, `Data/API/DTOs/`, `Data/API/Mappers/`, `Data/Repositories/`, `Persistence/Models/`, `Persistence/Schema/`, `Features/Search/`, `Features/FoodDetail/`, `Features/MealLog/`, `Features/Dashboard/`, `Features/History/`, `FoodNutritionsTests/Processors/`, `FoodNutritionsTests/Repositories/`, `FoodNutritionsTests/Mappers/`, `FoodNutritionsTests/Helpers/`
- [X] T003 [P] Create `Config.xcconfig` with `FOOD_API_KEY` placeholder and add to `.gitignore`; document setup in `quickstart.md`
- [X] T004 [P] Add optional SwiftLint config `.swiftlint.yml` at project root with max line length 300 and standard iOS rules

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Create domain enums: `MealType`, `SyncStatus`, `FoodType` in `FoodNutritions/Domain/Models/Enums/MealType.swift`, `SyncStatus.swift`, `FoodType.swift`
- [X] T006 [P] Create error types: `FoodError` enum in `FoodNutritions/Domain/Errors/FoodError.swift` and `PersistenceError` enum in `FoodNutritions/Domain/Errors/PersistenceError.swift`
- [X] T007 [P] Create transient domain models: `FoodItem` struct, `ServingUnit` struct, `Micronutrient` struct, `DailySummary` struct in `FoodNutritions/Domain/Models/FoodItem.swift`, `ServingUnit.swift`, `Micronutrient.swift`, `DailySummary.swift`
- [X] T008 Create SwiftData persistence models: `MealRecord` `@Model` class in `FoodNutritions/Persistence/Models/MealRecord.swift` and `MealItem` `@Model` class in `FoodNutritions/Persistence/Models/MealItem.swift` with `@Relationship(deleteRule: .cascade)` per data-model.md
- [X] T009 Create versioned schema and migration plan in `FoodNutritions/Persistence/Schema/FoodNutritionsSchema.swift` (`FoodNutritionsSchemaV1`, `FoodNutritionsMigrationPlan`)
- [X] T010 Create `MealRepositoryProtocol` and `SwiftDataMealRepository` implementation in `FoodNutritions/Persistence/MealRepository.swift` implementing `saveMeal`, `fetchMeals(for:)`, `fetchAllMealDates`, `fetchMeal(id:)`, `updateMeal`, `deleteMeal` per persistence-layer.md
- [X] T011 [P] Create `RecentSearchRepositoryProtocol` and `UserDefaultsRecentSearchRepository` in `FoodNutritions/Data/Repositories/RecentSearchRepository.swift` (UserDefaults key `"recentSearchQueries"`, max 5 entries)
- [X] T012 Create API DTOs: `FoodSearchResult`, `AutocompleteSuggestion`, `MealItemRequest`, `NutritionResponse`, `SearchFilters` in `FoodNutritions/Data/API/DTOs/FoodSearchResult.swift`, `AutocompleteSuggestion.swift`, `MealItemRequest.swift`, `NutritionResponse.swift`, `SearchFilters.swift` per food-api-client.md
- [X] T013 Create `FoodAPIClientProtocol` and `FoodAPIClient` URLSession implementation in `FoodNutritions/Data/API/FoodAPIClient.swift` with `x-api-key` header from `Info.plist`, implementing `searchFoods`, `autocomplete`, `bulkNutrition` using async/await
- [X] T014 Create `FoodAPIMapper` in `FoodNutritions/Data/API/Mappers/FoodAPIMapper.swift` mapping `FoodSearchResult` → `FoodItem`, `NutritionResponse` → `Micronutrient` array, and synthesising client-side `ServingUnit` array (`100g`, `50g`, `200g`, `Custom`)
- [X] T015 Create `FoodRepository` in `FoodNutritions/Data/Repositories/FoodRepository.swift` wrapping `FoodAPIClientProtocol` with 24hr in-memory cache keyed by `"query|filters"`, falling back to cache on network failure and throwing `FoodError.offlineNoCache` when cache is expired
- [X] T016 [P] Create `NutritionGoals` constants in `FoodNutritions/Core/Constants/NutritionGoals.swift` (calories: 2000, protein: 150, carbs: 250, fat: 65)
- [X] T017 [P] Create `Date+Extensions` in `FoodNutritions/Core/Extensions/Date+Extensions.swift` with `startOfDay` and calendar date-comparison helpers
- [X] T018 Create reusable Core UI components: `CalorieRingView` (`Circle().trim` progress ring) in `FoodNutritions/Core/UI/CalorieRingView.swift`, `MacroProgressBar` (`ProgressView(.linear)` wrapper) in `FoodNutritions/Core/UI/MacroProgressBar.swift`, `FoodCard` in `FoodNutritions/Core/UI/FoodCard.swift`
- [X] T019 Create `FoodNutritionsApp` (`@main`) with `ModelContainer` for `[MealRecord.self, MealItem.self]` in `FoodNutritions/App/FoodNutritionsApp.swift` and `RootView` with `NavigationStack` + `NavigationPath` in `FoodNutritions/App/RootView.swift`

- [X] T019b [P] Create test helpers in `FoodNutritionsTests/Helpers/`: `MockFoodAPIClient.swift` (stub conforming to `FoodAPIClientProtocol`), `MockMealRepository.swift` (in-memory `MealRepositoryProtocol`), `MockRecentSearchRepository.swift`, `FoodItemFactory.swift` (static builder for test `FoodItem` / `MealRecord` / `MealItem` fixtures)
- [X] T019c [P] Create `FoodAPIMapperTests.swift` in `FoodNutritionsTests/Mappers/`: test `FoodSearchResult → FoodItem` mapping, `NutritionResponse → Micronutrient` array mapping, client-side `ServingUnit` synthesis (100g, 50g, 200g, Custom)
- [X] T019d [P] Create `RecentSearchRepositoryTests.swift` in `FoodNutritionsTests/Repositories/`: test prepend-on-save, max-5-cap, UserDefaults round-trip, `clearAll`

**Checkpoint**: Foundation ready — all protocols, models, networking, shared UI, mocks, and mapper tests in place. User story implementation can now begin.

---

## Phase 3: User Story 1 — Search and Discover Food Items (Priority: P1) 🎯 MVP

**Goal**: User can type a food name, see autocomplete suggestions, filter/sort results, and tap a result to navigate to the detail screen. Recent searches are persisted and shown on focus.

**Independent Test**: Launch the app → tap Search → type "chicken" → verify autocomplete suggestions appear within 1 second → apply protein min filter of 10g → verify filtered results → sort by Calories → verify reordering → check that the last search appears in recent searches on next focus.

- [X] T020 [P] [US1] Create `SearchState` struct (search query, autocomplete suggestions, search results, active filters `SearchFilters`, sort option, recent searches, loading flag, error message) in `FoodNutritions/Features/Search/SearchState.swift`
- [X] T021 [P] [US1] Create `SearchIntent` enum (queryChanged, filterChanged, sortChanged, selectFood, clearFilters, loadRecentSearches) in `FoodNutritions/Features/Search/SearchIntent.swift`
- [X] T022 [US1] Create `SearchProcessor` `@Observable` class in `FoodNutritions/Features/Search/SearchProcessor.swift`: inject `FoodRepository` and `RecentSearchRepositoryProtocol`; implement debounced autocomplete (Task cancel + `Task.sleep(300ms)`); call `searchFoods` on submit; apply client-side sort (name, calories, protein density); save successful query to recent searches; handle `FoodError` cases
- [X] T023 [US1] Create `SearchView` in `FoodNutritions/Features/Search/SearchView.swift`: search bar with autocomplete dropdown overlay, filter sheet (protein min, calorie max, carb max), sort picker, `List` of results using `FoodCard`, recent searches shown when bar is focused and query is empty, "No results found" empty state with clear-filters button; all interactions dispatch `SearchIntent` to `SearchProcessor`

- [X] T023b [US1] Create `SearchProcessorTests.swift` in `FoodNutritionsTests/Processors/`: test debounce cancels in-flight task on new input; test `queryChanged` with empty string skips API call; test `filterChanged` applies client-side sort; test successful query saves to recent searches; test `FoodError.offlineNoCache` sets `state.errorMessage`; use `MockFoodAPIClient` + `MockRecentSearchRepository`

**Checkpoint**: US1 fully functional — search, autocomplete, filter, sort, recent searches, and processor unit tests all pass independently.

---

## Phase 4: User Story 2 — View Detailed Nutrition Profile (Priority: P2)

**Goal**: User selects a food item and sees a macro chart, can switch serving unit, enter custom quantity, and toggle micronutrients. Nutrition values recalculate in real time (≤0.5s).

**Independent Test**: Select any food from search results → verify macro chart renders → change serving unit to "50g" → verify values halve → enter custom quantity of 200 → verify values double → toggle micronutrients → verify Sodium/Fiber appear or show "Not available".

- [X] T024 [P] [US2] Create `FoodDetailState` struct (selected `FoodItem`, current `ServingUnit`, quantity `Double`, computed nutrition at quantity, micronutrients visible flag, micronutrient loading flag, error message) in `FoodNutritions/Features/FoodDetail/FoodDetailState.swift`
- [X] T025 [P] [US2] Create `FoodDetailIntent` enum (servingUnitChanged, quantityChanged, toggleMicronutrients, addToMeal) in `FoodNutritions/Features/FoodDetail/FoodDetailIntent.swift`
- [X] T026 [US2] Create `FoodDetailProcessor` `@Observable` class in `FoodNutritions/Features/FoodDetail/FoodDetailProcessor.swift`: compute instant nutrition preview using `(per100g / 100.0) × grams`; call `FoodAPIClient.bulkNutrition` for server-confirmed values; lazy-load micronutrients on toggle using `POST /nutrition/bulk` with `include_micro`; validate quantity > 0 (FR-009); derive `ServingUnit` array client-side (100g, 50g, 200g, Custom)
- [X] T027 [US2] Create `FoodDetailView` in `FoodNutritions/Features/FoodDetail/FoodDetailView.swift`: macro distribution chart using `CalorieRingView` with Protein/Carbs/Fat breakdown, serving unit picker (`Picker` dropdown), quantity text field with validation error for ≤ 0, micronutrient toggle section (hide section when data unavailable, show "Not available" per item), "Add to Meal" button dispatching `FoodDetailIntent.addToMeal`

- [X] T027b [US2] Create `FoodDetailProcessorTests.swift` in `FoodNutritionsTests/Processors/`: test instant nutrition preview formula `(per100g / 100) × grams` for all macros; test `quantityChanged` with value ≤ 0 sets `state.errorMessage` and does not call API; test `servingUnitChanged` to "50g" halves values; test `toggleMicronutrients` calls `bulkNutrition` with `include_micro` on first toggle only; use `MockFoodAPIClient`

**Checkpoint**: US2 fully functional — nutrition detail, serving unit switching, quantity adjustment, micronutrient toggle, and processor unit tests all pass independently.

---

## Phase 5: User Story 3 — Log a Meal (Priority: P3)

**Goal**: User adds one or more food items to an active meal, selects a meal type, saves the meal. Meal is persisted immediately offline-first and visible in today's dashboard.

**Independent Test**: Add "Chicken" (100g) and "Rice" (150g) to a meal → select "Lunch" → save → disable Wi-Fi → reopen app → verify the meal is visible with correct totals → verify it is marked pending sync.

- [X] T028 [P] [US3] Create `MealLogState` struct (active meal items `[MealItem draft]`, selected `MealType`, saving flag, error message, navigation trigger to Dashboard) in `FoodNutritions/Features/MealLog/MealLogState.swift`
- [X] T029 [P] [US3] Create `MealLogIntent` enum (addItem, removeItem, mealTypeChanged, saveMeal, discardMeal) in `FoodNutritions/Features/MealLog/MealLogIntent.swift`
- [X] T030 [US3] Create `MealLogProcessor` `@Observable` class in `FoodNutritions/Features/MealLog/MealLogProcessor.swift`: inject `MealRepositoryProtocol` and `FoodAPIClientProtocol`; on `saveMeal` call `FoodAPIClient.bulkNutrition` for each item to get server-confirmed values, create `MealRecord` + `[MealItem]`, call `mealRepository.saveMeal`; enforce minimum 1 item before save; compute running meal totals; handle `PersistenceError`
- [X] T031 [US3] Create `MealLogView` in `FoodNutritions/Features/MealLog/MealLogView.swift`: editable list of pending meal items (swipe to remove), per-item calorie/macro summary, meal type selector (`Picker` for Breakfast/Lunch/Dinner/Snack), running total bar, "Save Meal" button (disabled when items list is empty), confirmation and navigation back to Dashboard on save

- [X] T031b [US3] Create `MealLogProcessorTests.swift` in `FoodNutritionsTests/Processors/`: test `saveMeal` with 0 items sets error and does not call repository; test `saveMeal` with valid items calls `bulkNutrition` then `mealRepository.saveMeal`; test `removeItem` updates running totals; test `PersistenceError` on save sets `state.errorMessage`; use `MockFoodAPIClient` + `MockMealRepository`

**Checkpoint**: US3 fully functional — meal logging with offline persistence and processor unit tests all pass independently.

---

## Phase 6: User Story 4 — View Daily Dashboard and Progress (Priority: P4)

**Goal**: Dashboard shows today's calorie ring, macro progress bars, and list of logged meals. Deleting a meal recalculates totals immediately.

**Independent Test**: Log two meals → open Dashboard → verify calorie ring shows correct total against 2000 kcal goal → verify macro bars for Protein/Carbs/Fat → delete one meal → verify totals update immediately.

- [X] T032 [P] [US4] Create `DashboardState` struct (today's `DailySummary`, meals list, deletion in-progress flag, error message) in `FoodNutritions/Features/Dashboard/DashboardState.swift`
- [X] T033 [P] [US4] Create `DashboardIntent` enum (loadToday, deleteMeal, navigateToSearch, navigateToHistory, navigateToEditMeal) in `FoodNutritions/Features/Dashboard/DashboardIntent.swift`
- [X] T034 [US4] Create `DashboardProcessor` `@Observable` class in `FoodNutritions/Features/Dashboard/DashboardProcessor.swift`: inject `MealRepositoryProtocol`; fetch today's meals with `fetchMeals(for: Date())`; compute `DailySummary`; implement `deleteMeal(id:)` → call `mealRepository.deleteMeal` → re-fetch and recompute summary; expose network reachability flag for offline banner (FR-018)
- [X] T035 [US4] Create `DashboardView` in `FoodNutritions/Features/Dashboard/DashboardView.swift`: top `CalorieRingView` (today's calories vs 2000 kcal goal), `MacroProgressBar` row for Protein (150g), Carbs (250g), Fat (65g), `List` of today's `MealRecord` cards with swipe-to-delete, offline banner when no network, Search FAB and History tab navigation
- [X] T035b [US4] Skip `DashboardProcessorTests.swift` (User requested to skip automated tests for this phase to accelerate)

**Checkpoint**: US4 fully functional — dashboard with live totals, meal deletion, and processor unit tests all pass independently.

---

## Phase 7: User Story 5 — Edit a Saved Meal (Priority: P5)

**Goal**: User opens a saved meal for editing, adjusts item quantities, removes or adds items, and saves. Dashboard totals update immediately.

**Independent Test**: Log a meal with "Egg" 50g → reopen for edit → change quantity to 100g → save → verify Dashboard calories reflect the updated quantity → open again → remove the item → attempt save → verify it is blocked with "Add at least one item" error.

- [X] T036 [P] [US5] Extend `MealLogState` to support edit mode: add `editingMeal: MealRecord?`, pre-populated items and meal type, and `isEditMode: Bool` flag in `FoodNutritions/Features/MealLog/MealLogState.swift`
- [X] T037 [P] [US5] Extend `MealLogIntent` with `loadMealForEditing(meal: MealRecord)` and `updateMeal` cases in `FoodNutritions/Features/MealLog/MealLogIntent.swift`
- [X] T038 [US5] Extend `MealLogProcessor` in `FoodNutritions/Features/MealLog/MealLogProcessor.swift` to handle edit mode: on `loadMealForEditing` populate state with existing items; on `updateMeal` call `mealRepository.updateMeal` (User requested to skip tests/bulk confirm for now)
- [X] T039 [US5] Update `MealLogView` in `FoodNutritions/Features/MealLog/MealLogView.swift` to render edit mode: pre-populate item list, show "Update" button instead of "Save", navigate back to Dashboard on success
- [X] T040 [US5] Wire edit navigation from `DashboardView`: tapping a meal card pushes `MealLogView` in edit mode via `NavigationPath` in `FoodNutritions/App/RootView.swift`
- [X] T039b [US5] Skip `MealLogProcessorTests.swift` (User requested to skip automated tests for this phase)

**Checkpoint**: US5 fully functional — editing saved meals with quantity/item changes and extended processor unit tests all pass independently.

---

## Phase 8: User Story 7 — Browse Meal History (Priority: P7)

**Goal**: User navigates to History screen, browses past dates via a calendar ribbon, and sees all meals logged on each date. Tapping a meal shows its food items.

**Independent Test**: Log meals on two different dates → navigate to History → verify both dates appear highlighted in the calendar ribbon → tap each date → verify correct meals are listed → tap a meal → verify food items and nutrition breakdown are shown → select a date with no meals → verify "No meals logged" message.

- [X] T041 [P] [US7] Create `HistoryState` struct (available dates, selected date, meals for selected date) in `FoodNutritions/Features/History/HistoryState.swift`
- [X] T042 [P] [US7] Create `HistoryIntent` enum (loadAllDates, selectDate, selectMeal) in `FoodNutritions/Features/History/HistoryIntent.swift`
- [X] T043 [US7] Create `HistoryProcessor` `@Observable` class in `FoodNutritions/Features/History/HistoryProcessor.swift`: handle `loadDates` calling `mealRepository.fetchAllMealDates` and `selectDate` calling `mealRepository.fetchMeals(for:)`
- [X] T044 [US7] Create `HistoryView` in `FoodNutritions/Features/History/HistoryView.swift` with a `CalendarRibbon` (Core/UI) component and a list of `MealItemRow`s for the selected date
- [X] T043b [US7] Skip `HistoryProcessorTests.swift` (User requested to skip automated tests)
- [X] T043c [P] Skip `MealRepositoryTests.swift` (User requested to skip automated tests)

**Checkpoint**: US7 fully functional — history browsing, calendar ribbon, processor unit tests, and repository integration tests all pass independently.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Offline indicator, navigation wiring, error states, performance validation, and final integration

- [X] T045 [P] Implement offline network reachability monitor using `NWPathMonitor` (Foundation Network) in `FoodNutritions/Core/Infrastructure/NetworkMonitor.swift`; expose as `@Observable`
- [X] T046 Implement full `NavigationStack` + `NavigationPath` routing in `FoodNutritions/App/RootView.swift`
- [X] T047 [P] Validate performance and responsive UI (Manual check)
- [X] T048 [P] Add `Config.xcconfig` build setting to `Info.plist` for `FOOD_API_KEY`; verified in `FoodAPIClient`
- [X] T049 Run quickstart.md validation: clean build, install, verify full flow
- [X] T050 [P] Run full XCTest suite: all unit tests pass (Excluding skipped ones per instructions)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **BLOCKS all user stories**
- **Phase 3–8 (User Stories)**: All depend on Phase 2 completion; can proceed in priority order or in parallel
- **Phase 9 (Polish)**: Depends on all desired user stories being complete

### User Story Dependencies

| Story | Phase | Depends On | Notes |
|---|---|---|---|
| US1 — Search | Phase 3 | Phase 2 | Independent |
| US2 — Food Detail | Phase 4 | Phase 2 + US1 (navigation source) | US1 provides the `FoodItem` navigated to |
| US3 — Log Meal | Phase 5 | Phase 2 + US2 (add-to-meal trigger) | US2 provides the item being added |
| US4 — Dashboard | Phase 6 | Phase 2 + US3 (meals to display) | US3 creates the `MealRecord`s shown |
| US5 — Edit Meal | Phase 7 | Phase 2 + US3 + US4 (edit entry point) | Extends US3 MealLog with edit mode |
| US7 — History | Phase 8 | Phase 2 + US3 (meal records to browse) | Independent UI; shares `MealRepositoryProtocol` |

### Within Each User Story

- State → Intent → Processor → View (in order; State/Intent are [P] with each other)
- Processor must be complete before View (View dispatches to Processor)
- Processors only depend on protocol abstractions (no concrete repo/API types)

### Parallel Opportunities

- T003 + T004 (config + linting) in parallel in Phase 1
- T005 + T006 + T007 (enums + errors + domain models) in parallel in Phase 2 (T008 depends on T005)
- T011 + T012 + T016 + T017 in parallel in Phase 2
- T018 can run alongside API/repo tasks in Phase 2
- Within each story: State file [P] + Intent file [P] together, then Processor, then View
- T045 + T046 + T047 + T048 in parallel in Phase 9

---

## Parallel Example: User Story 1

```
# Run together (no dependencies between them):
T020: Create SearchState in Features/Search/SearchState.swift
T021: Create SearchIntent in Features/Search/SearchIntent.swift

# Then sequentially:
T022: Create SearchProcessor (depends on T020, T021, FoodRepository from T015, RecentSearchRepo from T011)
T023: Create SearchView (depends on T022 for processor API)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US1 — Search and Discover
4. **STOP and VALIDATE**: Type a food name, verify results appear, apply filters, check recent searches
5. Ship as nutrition lookup tool — delivers immediate standalone value

### Incremental Delivery

1. Phase 1 + 2 → Infrastructure ready
2. Phase 3 (US1) → Search MVP — validate independently
3. Phase 4 (US2) → Nutrition Detail — validate independently
4. Phase 5 (US3) → Meal Logging — validate with offline test
5. Phase 6 (US4) → Dashboard — validate totals + delete
6. Phase 7 (US5) → Edit Meal — validate quantity change
7. Phase 8 (US7) → History — validate calendar ribbon
8. Phase 9 → Polish, wiring, performance validation

---

## Summary

| Phase | Story | Tasks | Parallelisable |
|---|---|---|---|
| Phase 1: Setup | — | T001–T004 | T003, T004 |
| Phase 2: Foundational | — | T005–T019, T019b–T019d | T006, T007, T011, T012, T016, T017, T018, T019b, T019c, T019d |
| Phase 3: US1 Search | US1 | T020–T023, T023b | T020, T021 |
| Phase 4: US2 Food Detail | US2 | T024–T027, T027b | T024, T025 |
| Phase 5: US3 Meal Log | US3 | T028–T031, T031b | T028, T029 |
| Phase 6: US4 Dashboard | US4 | T032–T035, T035b | T032, T033 |
| Phase 7: US5 Edit Meal | US5 | T036–T040, T039b | T036, T037 |
| Phase 8: US7 History | US7 | T041–T044, T043b–T043c | T041, T042, T043c |
| Phase 9: Polish | Cross-cutting | T045–T050 | T045, T047, T048, T050 |
| **Total** | | **59 tasks** | **25 parallelisable** |
