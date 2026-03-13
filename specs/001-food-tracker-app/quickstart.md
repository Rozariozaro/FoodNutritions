# Quickstart: Food Tracker iOS App

**Branch**: `001-food-tracker-app` | **Date**: 2026-03-13

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Xcode | 15.0+ | Required for Swift 5.9 + SwiftData + `@Observable` |
| iOS Simulator / Device | iOS 17.0+ | SwiftData and `@Observable` require iOS 17 |
| Swift | 5.9+ | Bundled with Xcode 15 |
| Food API Key | — | `x-api-key` for `https://foodapi.rapheal.in/` — see `backend/openapi.json` |

No third-party package manager setup is required — this project uses only Apple frameworks.

---

## Project Setup

### 1. Create Xcode Project

```
File → New → Project → iOS → App
Product Name: FoodNutritions
Bundle ID: com.yourname.foodnutritions
Interface: SwiftUI
Language: Swift
Storage: None (SwiftData added manually)
```

### 2. Set Deployment Target

```
Target → General → Minimum Deployments → iOS 17.0
```

### 3. Configure API Key

Create `Config.xcconfig` at the project root (add to `.gitignore`):

```
FOOD_API_KEY = YOUR_KEY_HERE
FOOD_API_BASE_URL = https://foodapi.rapheal.in
```

In `Info.plist`, add:
```xml
<key>FOOD_API_KEY</key>
<string>$(FOOD_API_KEY)</string>
<key>FOOD_API_BASE_URL</key>
<string>$(FOOD_API_BASE_URL)</string>
```

Read in code:
```swift
let apiKey = Bundle.main.infoDictionary?["FOOD_API_KEY"] as? String ?? ""
let baseURL = Bundle.main.infoDictionary?["FOOD_API_BASE_URL"] as? String ?? ""
```

### 4. Add SwiftLint (Optional but required by Constitution §12)

Via Xcode Package Dependencies:
```
https://github.com/realm/SwiftLint
```
Add a Build Phase Run Script:
```bash
if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi
```

---

## Folder Structure

```
FoodNutritions/
├── App/
│   ├── FoodNutritionsApp.swift       # @main entry, ModelContainer setup
│   └── RootView.swift                # NavigationStack root
│
├── Core/
│   ├── UI/
│   │   ├── CalorieRingView.swift     # Reusable circular progress ring
│   │   ├── MacroProgressBar.swift    # Reusable macro progress bar
│   │   └── FoodCard.swift            # Food item list row
│   ├── Extensions/
│   │   └── Date+Extensions.swift
│   └── Constants/
│       └── NutritionGoals.swift      # Default daily goals (2000/150/250/65)
│
├── Domain/
│   ├── Models/
│   │   ├── FoodItem.swift
│   │   ├── ServingUnit.swift
│   │   ├── DailySummary.swift
│   │   └── Enums/
│   │       ├── MealType.swift
│   │       ├── SyncStatus.swift
│   │       └── FoodType.swift
│   └── Errors/
│       ├── FoodError.swift
│       └── PersistenceError.swift
│
├── Data/
│   ├── API/
│   │   ├── FoodAPIClient.swift       # URLSession + async/await; foodapi.rapheal.in
│   │   ├── DTOs/
│   │   │   ├── FoodSearchResult.swift
│   │   │   ├── NutritionResponse.swift
│   │   │   ├── ServingUnitResponse.swift
│   │   │   └── MealItemRequest.swift
│   │   └── Mappers/
│   │       └── FoodAPIMapper.swift   # API DTOs → FoodItem, ServingUnit
│   └── Repositories/
│       ├── FoodRepository.swift      # Search + cache logic
│       └── RecentSearchRepository.swift
│
├── Persistence/
│   ├── Models/
│   │   ├── MealRecord.swift          # @Model
│   │   └── MealItem.swift            # @Model
│   ├── MealRepository.swift          # SwiftData CRUD
│   └── Schema/
│       └── FoodNutritionsSchema.swift # VersionedSchema + MigrationPlan
│
└── Features/
    ├── Dashboard/
    │   ├── DashboardView.swift
    │   ├── DashboardState.swift
    │   ├── DashboardIntent.swift
    │   └── DashboardProcessor.swift
    ├── Search/
    │   ├── SearchView.swift
    │   ├── SearchState.swift
    │   ├── SearchIntent.swift
    │   └── SearchProcessor.swift
    ├── FoodDetail/
    │   ├── FoodDetailView.swift
    │   ├── FoodDetailState.swift
    │   ├── FoodDetailIntent.swift
    │   └── FoodDetailProcessor.swift
    ├── MealLog/
    │   ├── MealLogView.swift
    │   ├── MealLogState.swift
    │   ├── MealLogIntent.swift
    │   └── MealLogProcessor.swift
    └── History/
        ├── HistoryView.swift
        ├── HistoryState.swift
        ├── HistoryIntent.swift
        └── HistoryProcessor.swift
```

---

## Running the App

1. Open `FoodNutritions.xcodeproj` in Xcode 15
2. Select an iOS 17 simulator (e.g., iPhone 15)
3. Press `Cmd+R`

The app launches to the Dashboard. No seed data is loaded — log a meal to see the dashboard populate.

---

## Running Tests

```
Cmd+U  (Product → Test)
```

Test targets:
- `FoodNutritonsTests` — Unit tests for Processors, Repositories, Mappers
- `FoodNutritionsUITests` — UI tests for critical flows (search → detail → log)

---

## Key Flow: Log a Meal

1. Dashboard → tap Search (magnifier icon)
2. Type a food name → debounced search fires after 300ms
3. Tap a result → FoodDetail screen opens
4. Adjust serving unit / quantity → nutrition recalculates live
5. Tap "Add to Meal" → food added to active meal draft
6. Tap "Save Meal" → select meal type → confirm
7. Dashboard updates immediately with new calorie/macro totals

---

## Daily Nutrition Goals (Hardcoded — v1)

```swift
// Core/Constants/NutritionGoals.swift
enum NutritionGoals {
    static let calories: Double = 2000
    static let protein:  Double = 150
    static let carbs:    Double = 250
    static let fat:      Double = 65
}
```

---

## Offline Behavior

The app is offline-first by design:
- Meal logging always works (SwiftData local SQLite)
- Food search falls back to 24hr cache when offline
- An offline banner appears when connectivity is unavailable
- Sync status is tracked per `MealRecord` (`pending`/`synced`) but no upload occurs in v1
