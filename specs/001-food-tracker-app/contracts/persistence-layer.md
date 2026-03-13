# Contract: Persistence Layer

**Layer**: Persistence
**Branch**: `001-food-tracker-app` | **Date**: 2026-03-13

The Persistence layer owns all local data storage via SwiftData. It exposes a `MealRepository` protocol consumed by Feature Processors. SwiftData internals never leak into Domain or Feature layers.

---

## Protocol

```swift
protocol MealRepositoryProtocol {
    // Create
    func saveMeal(_ meal: MealRecord) async throws

    // Read
    func fetchMeals(for date: Date) async throws -> [MealRecord]
    func fetchAllMealDates() async throws -> [Date]
    func fetchMeal(id: UUID) async throws -> MealRecord?

    // Update
    func updateMeal(_ meal: MealRecord) async throws

    // Delete
    func deleteMeal(id: UUID) async throws
}
```

---

## SwiftData Models

### MealRecord

```swift
@Model
final class MealRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mealType: String          // MealType.rawValue
    var syncStatus: String        // SyncStatus.rawValue
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MealItem.meal)
    var items: [MealItem]
}
```

### MealItem

```swift
@Model
final class MealItem {
    @Attribute(.unique) var id: UUID
    var fdcId: Int
    var foodName: String
    var servingGrams: Double
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var meal: MealRecord?
}
```

---

## ModelContainer Setup

Single container at app entry point, shared via SwiftUI environment:

```swift
@main
struct FoodNutritionsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [MealRecord.self, MealItem.self])
    }
}
```

---

## Threading Contract

- All `ModelContext` mutations run on `@MainActor`
- No background ModelContext in v1 (data volume does not warrant it)
- Processors call repository methods with `await` from within `@MainActor` async functions

---

## Query Patterns

### Fetch meals for a date

```swift
let calendar = Calendar.current
let start = calendar.startOfDay(for: date)
let end = calendar.date(byAdding: .day, value: 1, to: start)!

let descriptor = FetchDescriptor<MealRecord>(
    predicate: #Predicate { $0.date >= start && $0.date < end },
    sortBy: [SortDescriptor(\.date)]
)
let meals = try context.fetch(descriptor)
```

### Fetch all distinct meal dates (for history calendar)

```swift
let descriptor = FetchDescriptor<MealRecord>(
    sortBy: [SortDescriptor(\.date, order: .reverse)]
)
let allMeals = try context.fetch(descriptor)
let dates = Set(allMeals.map { Calendar.current.startOfDay(for: $0.date) })
```

---

## Error Handling

```swift
enum PersistenceError: Error {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case recordNotFound(id: UUID)
    case deleteFailed(underlying: Error)
}
```

All persistence errors bubble up to Processors, which update `state.errorMessage` for display.

---

## Offline Guarantee

SwiftData writes to a local SQLite file. All operations succeed without network connectivity. Meal logging is 100% offline-capable (FR-012, SC-004).

---

## RecentSearch Storage

Not a SwiftData model. Stored in `UserDefaults`:

```swift
protocol RecentSearchRepositoryProtocol {
    func loadRecentSearches() -> [String]
    func saveSearch(_ query: String)   // prepends, trims to max 5
    func clearAll()
}
```

Key: `"recentSearchQueries"` — stores `[String]` JSON-encoded array, max 5 entries.
