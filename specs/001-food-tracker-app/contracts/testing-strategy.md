# Contract: Testing Strategy

**Branch**: `001-food-tracker-app` | **Date**: 2026-03-13
**Framework**: XCTest (unit tests only — no UI tests in v1)
**Location**: `FoodNutritionsTests/` alongside `FoodNutritions.xcodeproj`

---

## Scope

Unit tests cover all business logic. Views are not tested directly (no logic lives in views per MVI architecture).

| Layer | What is tested | Test file location |
|---|---|---|
| Mappers | DTO → Domain model mapping | `FoodNutritionsTests/Mappers/` |
| Repositories | UserDefaults round-trips; SwiftData CRUD via in-memory container | `FoodNutritionsTests/Repositories/` |
| Processors | All intent-handling logic, state transitions, error paths | `FoodNutritionsTests/Processors/` |
| Helpers/Mocks | Shared test doubles used across suites | `FoodNutritionsTests/Helpers/` |

---

## Test Infrastructure

### Mock Strategy

All external dependencies are replaced with protocol-conforming test doubles. Processors only depend on protocol abstractions, so no `@testable import` hacks are needed.

#### `MockFoodAPIClient` (`FoodAPIClientProtocol`)

```swift
final class MockFoodAPIClient: FoodAPIClientProtocol {
    var searchFoodsResult: Result<[FoodSearchResult], Error> = .success([])
    var autocompleteResult: Result<[AutocompleteSuggestion], Error> = .success([])
    var bulkNutritionResult: Result<NutritionResponse, Error> = .success(.fixture())

    var searchCallCount = 0
    var bulkNutritionCallCount = 0

    func searchFoods(query: String, limit: Int, filters: SearchFilters) async throws -> [FoodSearchResult] {
        searchCallCount += 1
        return try searchFoodsResult.get()
    }
    func autocomplete(query: String, limit: Int) async throws -> [AutocompleteSuggestion] {
        try autocompleteResult.get()
    }
    func bulkNutrition(items: [MealItemRequest]) async throws -> NutritionResponse {
        bulkNutritionCallCount += 1
        return try bulkNutritionResult.get()
    }
}
```

#### `MockMealRepository` (`MealRepositoryProtocol`)

```swift
final class MockMealRepository: MealRepositoryProtocol {
    var meals: [MealRecord] = []
    var savedMeals: [MealRecord] = []
    var deletedIds: [UUID] = []

    func saveMeal(_ meal: MealRecord) async throws { savedMeals.append(meal); meals.append(meal) }
    func fetchMeals(for date: Date) async throws -> [MealRecord] {
        let cal = Calendar.current
        return meals.filter { cal.isDate($0.date, inSameDayAs: date) }
    }
    func fetchAllMealDates() async throws -> [Date] {
        Set(meals.map { Calendar.current.startOfDay(for: $0.date) }).sorted()
    }
    func fetchMeal(id: UUID) async throws -> MealRecord? { meals.first { $0.id == id } }
    func updateMeal(_ meal: MealRecord) async throws {
        if let idx = meals.firstIndex(where: { $0.id == meal.id }) { meals[idx] = meal }
    }
    func deleteMeal(id: UUID) async throws {
        deletedIds.append(id)
        meals.removeAll { $0.id == id }
    }
}
```

#### `MockRecentSearchRepository` (`RecentSearchRepositoryProtocol`)

```swift
final class MockRecentSearchRepository: RecentSearchRepositoryProtocol {
    var searches: [String] = []
    func loadRecentSearches() -> [String] { searches }
    func saveSearch(_ query: String) { searches.insert(query, at: 0); if searches.count > 5 { searches.removeLast() } }
    func clearAll() { searches = [] }
}
```

#### `FoodItemFactory`

```swift
enum FoodItemFactory {
    static func makeFoodItem(id: Int = 1, name: String = "Test Food",
                             calories: Double = 200, protein: Double = 10,
                             carbs: Double = 20, fat: Double = 8) -> FoodItem {
        FoodItem(id: id, name: name, type: .recipe,
                 caloriesPer100g: calories, proteinPer100g: protein,
                 carbsPer100g: carbs, fatPer100g: fat,
                 proteinDensity: protein / calories,
                 micronutrients: [], servingUnits: ServingUnit.defaults)
    }

    static func makeMealRecord(date: Date = Date(), mealType: MealType = .lunch,
                               items: [MealItem] = []) -> MealRecord {
        let record = MealRecord(date: date, mealType: mealType)
        record.items = items.isEmpty ? [makeMealItem()] : items
        return record
    }

    static func makeMealItem(foodName: String = "Test Food",
                             grams: Double = 100, calories: Double = 200) -> MealItem {
        MealItem(apiItemId: 1, apiItemType: "recipe", foodName: foodName,
                 servingGrams: grams, calories: calories,
                 protein: 10, carbs: 20, fat: 8)
    }
}
```

---

## In-Memory SwiftData Container (for Repository Tests)

```swift
// Used in MealRepositoryTests only — NOT in Processor tests (Processors use MockMealRepository)
@MainActor
func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([MealRecord.self, MealItem.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}
```

---

## Test Coverage by File

### `FoodNutritionsTests/Mappers/FoodAPIMapperTests.swift`

| Test | Asserts |
|---|---|
| `testMapFoodSearchResultToFoodItem` | All fields mapped correctly; `FoodType` parsed from string |
| `testMapNutritionResponseToMicronutrients` | Returns `[Micronutrient]` with Fiber and Sodium |
| `testNilMicronutrientsWhenAbsent` | `fiber: nil`, `sodiumMg: nil` → empty micronutrient array |
| `testDefaultServingUnitsGenerated` | Returns exactly 4 units: 100g, 50g, 200g, Custom |

---

### `FoodNutritionsTests/Repositories/RecentSearchRepositoryTests.swift`

| Test | Asserts |
|---|---|
| `testSaveSearchPrependsToList` | First saved item is at index 0 |
| `testMaxFiveEntries` | Saving a 6th item removes the oldest |
| `testUserDefaultsRoundTrip` | Loaded list equals saved list after re-init |
| `testClearAllEmptiesList` | `loadRecentSearches()` returns `[]` after `clearAll()` |
| `testDuplicateQueryDeduplicatedAndMoved` | Saving an existing query moves it to top |

---

### `FoodNutritionsTests/Repositories/MealRepositoryTests.swift`

| Test | Asserts |
|---|---|
| `testSaveAndFetchMealForDate` | Saved meal is returned by `fetchMeals(for:)` on same day |
| `testFetchMealsByDateDoesNotCrossDay` | Yesterday's meal not returned for today |
| `testCascadeDeleteRemovesMealItems` | Deleting `MealRecord` removes all child `MealItem`s |
| `testFetchAllMealDatesReturnsDistinctDays` | Two meals on same day → one date returned |
| `testFetchMealByIdReturnsNilForUnknown` | `fetchMeal(id: UUID())` returns nil |
| `testUpdateMealPersistsChanges` | Updated `mealType` is returned on re-fetch |

---

### `FoodNutritionsTests/Processors/SearchProcessorTests.swift`

| Test | Asserts |
|---|---|
| `testEmptyQuerySkipsAPICall` | `searchCallCount == 0` when query is `""` |
| `testQueryChangedCallsAutocomplete` | `autocomplete` called after debounce |
| `testSuccessfulSearchSavesToRecentSearches` | `MockRecentSearchRepository.searches` contains query |
| `testOfflineNoCacheErrorSetsErrorMessage` | `state.errorMessage` is non-nil |
| `testClientSideSortByCalories` | Results ordered ascending by calories |
| `testFilterChangedAppliesProteinMin` | Results with protein < min are excluded |

---

### `FoodNutritionsTests/Processors/FoodDetailProcessorTests.swift`

| Test | Asserts |
|---|---|
| `testNutritionPreviewFormula` | `calories == (caloriesPer100g / 100) × grams` |
| `testServingUnitChangedTo50gHalvesValues` | All macros halved vs 100g baseline |
| `testQuantityZeroSetsErrorMessage` | `state.errorMessage != nil`; API not called |
| `testQuantityNegativeSetsErrorMessage` | Same as above for negative input |
| `testToggleMicronutrientsCallsBulkNutrition` | `bulkNutritionCallCount == 1` on first toggle |
| `testToggleMicronutrientsTwiceCallsAPIOnce` | `bulkNutritionCallCount == 1` (cached after first load) |

---

### `FoodNutritionsTests/Processors/MealLogProcessorTests.swift`

| Test | Asserts |
|---|---|
| `testSaveMealWithNoItemsSetsError` | `state.errorMessage != nil`; repo not called |
| `testSaveMealCallsBulkNutritionThenRepository` | `bulkNutritionCallCount == itemCount`; `savedMeals.count == 1` |
| `testRemoveItemUpdatesTotals` | Running total calories decrease by removed item's calories |
| `testPersistenceErrorOnSaveSetsErrorMessage` | `state.errorMessage` set when repo throws |
| `testLoadMealForEditingPopulatesState` | `state.items == meal.items`; `state.isEditMode == true` |
| `testUpdateMealWithNoItemsSetsError` | `state.errorMessage != nil` in edit mode |
| `testUpdateMealCallsRepositoryUpdateMeal` | `MockMealRepository.meals` reflects updated record |

---

### `FoodNutritionsTests/Processors/DashboardProcessorTests.swift`

| Test | Asserts |
|---|---|
| `testLoadTodayAggregatesSummaryCorrectly` | `summary.totalCalories == sum of all item calories` |
| `testDeleteMealRecomputesSummary` | Totals decrease after deletion |
| `testDeleteOnlyMealYieldsZeroTotals` | All totals == 0 after last meal deleted |
| `testDeleteMealCallsRepositoryDeleteMeal` | `deletedIds` contains the deleted meal's id |

---

### `FoodNutritionsTests/Processors/HistoryProcessorTests.swift`

| Test | Asserts |
|---|---|
| `testLoadAllDatesReturnsCorrectSet` | Matches dates of meals in mock repo |
| `testSelectDateWithMealsPopulatesState` | `state.meals` matches meals for that date |
| `testSelectDateWithNoMealsYieldsEmptyArray` | `state.meals == []`; `state.errorMessage == nil` |

---

## What is NOT Tested

| Excluded | Reason |
|---|---|
| SwiftUI Views | No business logic in views (MVI); UI tested via manual acceptance scenarios in spec.md |
| `FoodNutritionsApp` entry point | Requires full simulator; covered by quickstart.md validation (T049) |
| Navigation wiring in `RootView` | Integration concern; covered by manual end-to-end flow (T049) |
| Network responses from live API | Covered by mock; live API validated manually during T047 performance check |

---

## Running Tests

```bash
# From command line (requires Xcode CLT)
xcodebuild test \
  -scheme FoodNutritions \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:FoodNutritionsTests

# Or in Xcode: Cmd+U
```

All tests must pass before Phase 9 is marked complete (T050).
