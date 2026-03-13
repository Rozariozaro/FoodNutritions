# Data Model: Food Tracker iOS App

**Branch**: `001-food-tracker-app` | **Date**: 2026-03-13
**Source**: spec.md Key Entities + research.md SwiftData decisions

---

## Entity Overview

| Entity | Layer | Persistence | Source |
|---|---|---|---|
| `MealRecord` | Domain + Persistence | SwiftData `@Model` | Local device |
| `MealItem` | Domain + Persistence | SwiftData `@Model` | Local device |
| `FoodItem` | Domain | Transient (in-memory) | USDA FDC API |
| `ServingUnit` | Domain | Transient (in-memory) | USDA FDC API |
| `DailySummary` | Domain | Computed (derived) | Aggregated from `MealRecord` |
| `RecentSearch` | Persistence | UserDefaults (array, max 5) | Local device |

---

## 1. MealRecord

**Layer**: Persistence + Domain
**SwiftData model** — persisted to local SQLite via SwiftData.

### Fields

| Field | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | Non-null, unique, primary key | Auto-generated on init |
| `date` | `Date` | Non-null | Full timestamp; date component used for history grouping |
| `mealType` | `MealType` (enum → `String`) | Non-null | `Breakfast`, `Lunch`, `Dinner`, `Snack` |
| `items` | `[MealItem]` | Non-null, min 1 on save | Cascade-deleted with parent |
| `syncStatus` | `SyncStatus` (enum → `String`) | Non-null, default `.pending` | `pending`, `synced` — tracked but no upload in v1 |
| `createdAt` | `Date` | Non-null | Record creation timestamp |
| `updatedAt` | `Date` | Non-null | Updated on edit |

### Relationships

- **`MealRecord` → `[MealItem]`**: one-to-many, `deleteRule: .cascade`
- A `MealItem` belongs to exactly one `MealRecord` (inverse relationship)

### Validation Rules

- `items` must contain at least 1 `MealItem` before saving (enforced in Processor)
- `mealType` must be a valid `MealType` case

### State Transitions

```
Draft (in-memory) → Saved (persisted) → Edited (persisted) → Deleted (removed)
```

### Swift Declaration

```swift
@Model
final class MealRecord {
    var id: UUID = UUID()
    var date: Date
    var mealType: String          // MealType.rawValue
    var syncStatus: String = SyncStatus.pending.rawValue
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \MealItem.meal)
    var items: [MealItem] = []

    init(date: Date, mealType: MealType) {
        self.date = date
        self.mealType = mealType.rawValue
    }
}
```

---

## 2. MealItem

**Layer**: Persistence + Domain
**SwiftData model** — child of `MealRecord`, removed on parent deletion.

### Fields

| Field | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | Non-null, unique | Auto-generated on init |
| `apiItemId` | `Int` | Non-null | API `id` field from `FoodSearchResult` |
| `apiItemType` | `String` | Non-null | `"recipe"` or `"packaged"` — needed for `/nutrition/bulk` re-fetch |
| `foodName` | `String` | Non-null, non-empty | Display name from API |
| `servingGrams` | `Double` | > 0 | Quantity in grams as logged |
| `calories` | `Double` | ≥ 0 | Calculated at logged quantity |
| `protein` | `Double` | ≥ 0 | Grams protein at logged quantity |
| `carbs` | `Double` | ≥ 0 | Grams carbohydrates at logged quantity |
| `fat` | `Double` | ≥ 0 | Grams fat at logged quantity |
| `fiber` | `Double?` | ≥ 0 | From `NutritionResponse.fiber`; nil if not returned |
| `sodiumMg` | `Double?` | ≥ 0 | From `NutritionResponse.sodium_mg`; nil if not returned |
| `meal` | `MealRecord?` | Optional (inverse) | Parent record |

### Validation Rules

- `servingGrams` must be > 0 (reject 0 or negative — FR-009)
- All nutrient values clamped to ≥ 0 (guard against API negative values)

### Swift Declaration

```swift
@Model
final class MealItem {
    var id: UUID = UUID()
    var apiItemId: Int
    var apiItemType: String     // "recipe" | "packaged"
    var foodName: String
    var servingGrams: Double
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double?
    var sodiumMg: Double?
    var meal: MealRecord?

    init(apiItemId: Int, apiItemType: String, foodName: String,
         servingGrams: Double, calories: Double, protein: Double,
         carbs: Double, fat: Double, fiber: Double? = nil, sodiumMg: Double? = nil) {
        self.apiItemId = apiItemId
        self.apiItemType = apiItemType
        self.foodName = foodName
        self.servingGrams = max(servingGrams, 0.1)
        self.calories = max(calories, 0)
        self.protein = max(protein, 0)
        self.carbs = max(carbs, 0)
        self.fat = max(fat, 0)
        self.fiber = fiber
        self.sodiumMg = sodiumMg
    }
}
```

---

## 3. FoodItem (Domain — Transient)

**Layer**: Domain
**Not persisted** — mapped from `FoodSearchResult` API DTO, held in-memory during the search/detail flow.

### Fields

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `Int` | `FoodSearchResult.id` | API item identifier |
| `name` | `String` | `FoodSearchResult.name` | Display name |
| `type` | `FoodType` | `FoodSearchResult.type` | `.recipe` or `.packaged` |
| `caloriesPer100g` | `Double` | `calories_100g` | Used for client-side scaling |
| `proteinPer100g` | `Double` | `protein_100g` | |
| `carbsPer100g` | `Double` | `carbs_100g` | |
| `fatPer100g` | `Double` | `fat_100g` | |
| `proteinDensity` | `Double` | `protein_density` | For sort FR-004 |
| `micronutrients` | `[Micronutrient]` | `POST /nutrition/bulk` with `include_micro` | Empty until user toggles; populated lazily |
| `servingUnits` | `[ServingUnit]` | Client-synthesised | `/units` returns `[]`; units derived from `_100g` fields |

### Swift Declaration

```swift
struct FoodItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let type: FoodType
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let proteinDensity: Double
    var micronutrients: [Micronutrient]
    var servingUnits: [ServingUnit]
}

enum FoodType: String, Codable {
    case recipe
    case packaged
}
```

---

## 4. ServingUnit (Domain — Transient)

**Layer**: Domain
**Not persisted** — retrieved from FDC API, used only during food detail / logging flow.

### Fields

| Field | Type | Notes |
|---|---|---|
| `name` | `String` | e.g., "cup", "container", "100g" |
| `gramEquivalent` | `Double` | Grams corresponding to 1 unit |

### Swift Declaration

```swift
struct ServingUnit: Identifiable, Hashable {
    let name: String
    let gramEquivalent: Double
    var id: String { name }
}
```

**Default unit**: Always include a "100g" unit (gramEquivalent = 100). Used as baseline for nutrition recalculation.

---

## 5. DailySummary (Domain — Computed)

**Layer**: Domain
**Not persisted** — derived by aggregating all `MealRecord` entries for a given calendar date. Recomputed whenever the meal list changes.

### Fields

| Field | Type | Notes |
|---|---|---|
| `date` | `Date` | Calendar date (day granularity) |
| `totalCalories` | `Double` | Sum of all meal item calories |
| `totalProtein` | `Double` | Sum of all meal item protein |
| `totalCarbs` | `Double` | Sum of all meal item carbs |
| `totalFat` | `Double` | Sum of all meal item fat |
| `meals` | `[MealRecord]` | All meals for this date |

### Default Daily Goals (FR-014, FR-015)

| Macro | Goal |
|---|---|
| Calories | 2000 kcal |
| Protein | 150g |
| Carbohydrates | 250g |
| Fat | 65g |

### Swift Declaration

```swift
struct DailySummary {
    let date: Date
    let meals: [MealRecord]

    var totalCalories: Double { meals.flatMap(\.items).reduce(0) { $0 + $1.calories } }
    var totalProtein:  Double { meals.flatMap(\.items).reduce(0) { $0 + $1.protein } }
    var totalCarbs:    Double { meals.flatMap(\.items).reduce(0) { $0 + $1.carbs } }
    var totalFat:      Double { meals.flatMap(\.items).reduce(0) { $0 + $1.fat } }
}
```

---

## 6. RecentSearch

**Layer**: Persistence
**Storage**: `UserDefaults` as `[String]` (ordered, max 5 entries).
**Not a SwiftData model** — simple string array, no relational structure needed.

### Rules

- Maximum 5 entries retained (FR-005)
- When a new successful query is added and the list is at capacity, the oldest entry is removed
- Stored under key: `"recentSearchQueries"`

---

## Supporting Enums

```swift
enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
    case snack     = "Snack"
}

enum SyncStatus: String, Codable {
    case pending = "pending"
    case synced  = "synced"
}

struct Micronutrient: Hashable {
    let name: String      // e.g., "Sodium", "Fiber"
    let value: Double
    let unit: String      // e.g., "mg", "g"
}
```

---

## Nutrition Calculation Rules

All nutrition values at a given quantity are calculated as:

```
nutrientAtQuantity = (nutrientPer100g / 100.0) × servingGrams
```

This is applied client-side when:
1. User changes serving unit on FoodDetail screen → `servingGrams = selectedUnit.gramEquivalent × quantity`
2. User enters a custom weight → `servingGrams = customWeight`
3. MealItem is created → values are pre-calculated and stored (snapshot at time of logging)

**Why snapshot**: Nutrition data from the API may change. Storing calculated values at log time preserves historical accuracy.

---

## SwiftData Schema Migration

```swift
enum FoodNutritionsSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [MealRecord.self, MealItem.self] }
}

enum FoodNutritionsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [FoodNutritionsSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
```

Bump `versionIdentifier` and add a `MigrationStage` whenever model fields are added or changed.
