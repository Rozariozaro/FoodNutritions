# Contract: FoodAPIClient

**Layer**: Data
**Branch**: `001-food-tracker-app` | **Date**: 2026-03-13
**Source**: `backend/openapi.json` + live API schema verification against `https://foodapi.rapheal.in/`

The `FoodAPIClient` is the sole networking interface for food data. All other layers depend on `FoodRepository` (Domain protocol), never on `FoodAPIClient` directly.

---

## Protocol

```swift
protocol FoodAPIClientProtocol {
    func searchFoods(query: String, limit: Int, filters: SearchFilters) async throws -> [FoodSearchResult]
    func autocomplete(query: String, limit: Int) async throws -> [AutocompleteSuggestion]
    func bulkNutrition(items: [MealItemRequest]) async throws -> NutritionResponse
}
```

> **Note**: `GET /nutrition` and `GET /units` currently return empty responses from the live API. `POST /nutrition/bulk` is the working nutrition lookup. `GET /units` returns `[]` — serving units are derived client-side from `_100g` fields. `/meal` and `/daily-nutrition` return only a single item (apparent backend limitation); nutrition aggregation is done client-side.

---

## Base URL & Auth

**Base URL**: `https://foodapi.rapheal.in`
**Auth**: `x-api-key` request header
**API key storage**: `.env` file (gitignored), read into `Config.xcconfig` → `Info.plist` key `FOOD_API_KEY` — never logged

---

## Endpoints

### 1. `GET /search` — Search Foods

Used for: FR-001, FR-002, FR-003, FR-004

**Query parameters**:

| Parameter | Type | Required | Default | Notes |
|---|---|---|---|---|
| `q` | `String` | Yes | — | Search term, min 1 char |
| `limit` | `Int` | No | 20 | Max 20 per FR-001 |
| `offset` | `Int` | No | 0 | Not used in v1 (no pagination) |
| `protein_min` | `Double` | No | 0 | FR-003 protein filter |
| `calories_max` | `Double` | No | 10000 | FR-003 calorie filter |
| `carbs_max` | `Double` | No | 10000 | FR-003 carb filter |
| `sodium_max_mg` | `Double` | No | 1000000 | Extended filter |
| `protein_density_min` | `Double` | No | 0 | FR-004 protein density sort/filter |
| `fiber_density_min` | `Double` | No | 0 | Extended filter |

**Headers**: `x-api-key: {API_KEY}`

**Verified response schema** (array of items):

```json
[
  {
    "id": 228,
    "name": "Chilli chicken",
    "type": "recipe",
    "calories_100g": 198.83,
    "protein_100g": 9.57,
    "carbs_100g": 2.86,
    "fat_100g": 16.56,
    "protein_density": 0.048,
    "rank": 0.667
  }
]
```

**Swift DTO**:

```swift
struct FoodSearchResult: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String          // "recipe" | "packaged"
    let calories100g: Double
    let protein100g: Double
    let carbs100g: Double
    let fat100g: Double
    let proteinDensity: Double
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, type, rank
        case calories100g    = "calories_100g"
        case protein100g     = "protein_100g"
        case carbs100g       = "carbs_100g"
        case fat100g         = "fat_100g"
        case proteinDensity  = "protein_density"
    }
}
```

**Swift filter model**:

```swift
struct SearchFilters {
    var proteinMin: Double = 0
    var caloriesMax: Double = 10_000
    var carbsMax: Double = 10_000
    var sodiumMaxMg: Double = 1_000_000
    var proteinDensityMin: Double = 0
    var fiberDensityMin: Double = 0
}
```

---

### 2. `GET /autocomplete` — Autocomplete Suggestions

Used for: FR-002

**Query parameters**:

| Parameter | Type | Required | Default |
|---|---|---|---|
| `q` | `String` | Yes | — |
| `limit` | `Int` | No | 10 |

**Headers**: `x-api-key: {API_KEY}`

**Verified response schema** (array of objects):

```json
[
  { "name": "Chicken 65",       "type": "packaged" },
  { "name": "Chicken 65 Masala","type": "packaged" },
  { "name": "Chicken and cheese souffle", "type": "recipe" }
]
```

**Swift DTO**:

```swift
struct AutocompleteSuggestion: Codable, Identifiable {
    let name: String
    let type: String    // "recipe" | "packaged"
    var id: String { name }
}
```

**Debounce**: Task cancel + `Task.sleep(for: .milliseconds(300))` on every keystroke.

---

### 3. `POST /nutrition/bulk` — Nutrition for Items at a Given Weight

Used for: FoodDetail screen (FR-006–FR-010), MealLog totals

**Request body** (`application/json`) — array of `MealItemRequest`:

```json
[{ "item_type": "recipe", "item_id": 228, "grams": 100 }]
```

**Verified response schema** (single object — one item per request returns the item's nutrition):

```json
{
  "item_id": 228,
  "item_type": "recipe",
  "name": "Chilli chicken",
  "grams": 100.0,
  "calories": 198.83,
  "protein": 9.57,
  "carbs": 2.86,
  "fat": 16.56,
  "fiber": 0.99,
  "sodium_mg": 223.75
}
```

**Swift DTOs**:

```swift
struct MealItemRequest: Codable {
    let itemType: String
    let itemId: Int
    let grams: Double

    enum CodingKeys: String, CodingKey {
        case itemType = "item_type"
        case itemId   = "item_id"
        case grams
    }
}

struct NutritionResponse: Codable {
    let itemId: Int
    let itemType: String
    let name: String
    let grams: Double
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let sodiumMg: Double?

    enum CodingKeys: String, CodingKey {
        case itemId   = "item_id"
        case itemType = "item_type"
        case name, grams, calories, protein, carbs, fat, fiber
        case sodiumMg = "sodium_mg"
    }
}
```

**Usage pattern**: Call with a single-item array to get nutrition at a specific gram weight. Re-call whenever the user changes serving quantity on the FoodDetail screen (SC-003: ≤0.5s).

---

### 4. `GET /units` — Serving Units

**Status**: Returns `[]` for all tested items. **Not usable in v1.**

**Client-side fallback**: Serving units are synthesised from `FoodSearchResult` `_100g` fields:

```swift
// Always available — derived from search result
let units: [ServingUnit] = [
    ServingUnit(name: "100g",  gramEquivalent: 100),
    ServingUnit(name: "50g",   gramEquivalent: 50),
    ServingUnit(name: "200g",  gramEquivalent: 200),
    ServingUnit(name: "Custom", gramEquivalent: 0),  // user-entered grams
]
```

When the API returns units in a future version, replace the synthesised list with the API response.

---

### 5. `POST /meal` — Meal Nutrition (Backend Aggregation)

**Status**: Currently returns only the last item in the input array (apparent backend limitation). **Not used for aggregation in v1.**

Meal totals are computed **client-side** by summing `MealItem.calories`, `.protein`, `.carbs`, `.fat` across all items in a `MealRecord`.

---

### 6. `POST /daily-nutrition` — Daily Totals (Backend Aggregation)

**Status**: Same limitation as `/meal` — returns a single item. **Not used in v1.**

Daily totals on the Dashboard are computed **client-side** from SwiftData `MealRecord` aggregation via `DailySummary`.

---

## Nutrition Recalculation (Client-Side)

Since `/nutrition` (GET) is non-functional and `/nutrition/bulk` requires an API round-trip, nutrition preview on the FoodDetail screen uses two strategies:

1. **Instant preview** (no network): Scale `_100g` values from the search result:
   ```swift
   let factor = grams / 100.0
   let calories = result.calories100g * factor
   let protein  = result.protein100g  * factor
   // etc.
   ```

2. **Server-confirmed values** (for logging): Call `POST /nutrition/bulk` before saving a `MealItem` to get the authoritative `grams`-scaled values including `fiber` and `sodium_mg`.

---

## Caching Contract

Caching is owned by `FoodRepository`:

- Successful `/search` responses cached in-memory keyed by `"query|filters"`
- Cache TTL: 24 hours (FR-019)
- On network failure → return cached results if within TTL, else throw `FoodError.offlineNoCache`

---

## Error Handling

```swift
enum FoodError: Error {
    case networkUnavailable
    case offlineNoCache
    case invalidResponse
    case foodNotFound(itemId: Int)
    case validationError(message: String)   // 422
    case serverError(statusCode: Int)       // 5xx
}
```

| HTTP Status | App behavior |
|---|---|
| 200 | Parse and map |
| 422 | Show validation message from `detail` field |
| 5xx | Fall back to 24hr cache (FR-019) |
| Network error | Show offline banner (FR-018), serve cache |

---

## Security

- API key in `.env` → `Config.xcconfig` → `Info.plist` key `FOOD_API_KEY` (`.env` gitignored)
- Passed as `x-api-key` header only — never as query parameter, never logged
- All requests use HTTPS
