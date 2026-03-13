# Implementation Plan: Food Tracker iOS App

**Branch**: `001-food-tracker-app` | **Date**: 2026-03-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-food-tracker-app/spec.md`

---

## Summary

Build an offline-first iOS food tracker app that lets users search for food items via the USDA FoodData Central API, view detailed nutrition profiles with adjustable serving sizes, log meals by type (Breakfast/Lunch/Dinner/Snack), and track daily macro/calorie progress against fixed goals. All meal data is persisted locally using SwiftData. The architecture follows MVI (Model-View-Intent) with `@Observable` Processors, strict layer separation (App/Core/Domain/Data/Persistence/Features), and Swift Concurrency throughout.

---

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: SwiftUI, SwiftData, Foundation, Swift Concurrency — Apple frameworks only (no third-party packages except optional SwiftLint)
**Storage**: SwiftData (SQLite) for `MealRecord` + `MealItem`; `UserDefaults` for `RecentSearch` (max 5 strings)
**Testing**: XCTest (unit + UI tests)
**Target Platform**: iOS 17.0+
**Project Type**: Native iOS mobile app (single target, SwiftUI)
**Performance Goals**: Search results ≤1s (SC-002); nutrition recalculation ≤0.5s (SC-003); dashboard update ≤1s (SC-005); full meal log flow ≤2min (SC-006)
**Constraints**: Offline-capable meal logging (SC-004); 24hr cached food search fallback (FR-019); no user accounts; no server sync in v1
**Scale/Scope**: Single user per device; unlimited meal history; up to 20 search results per query; 5 recent searches stored

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| **§1.1 Architecture First** — spec before code | ✅ PASS | spec.md complete, plan.md in progress |
| **§1.2 MVI with unidirectional data flow** | ✅ PASS | All features use View/State/Intent/Processor pattern with `@Observable` |
| **§1.3 Offline-First** — local persist + graceful fallback | ✅ PASS | SwiftData for meals; 24hr cache for food search; offline banner for network |
| **§2.1 iOS 17+** | ✅ PASS | Deployment target iOS 17.0 |
| **§2.2 Swift 5.9+** | ✅ PASS | Swift 5.9 required for `@Observable` |
| **§2.3 SwiftUI only** | ✅ PASS | No UIKit usage planned |
| **§2.4 Swift Concurrency only** | ✅ PASS | `async/await`, `Task`, `@MainActor` — no Combine, no callbacks |
| **§3 MVI structure** per feature | ✅ PASS | Each feature: `*View`, `*State`, `*Intent`, `*Processor` |
| **§4 Layered architecture** | ✅ PASS | App / Core / Domain / Data / Persistence / Features — strict boundaries |
| **§5 Networking via URLSession + async/await** | ✅ PASS | `FoodAPIClient` uses URLSession; isolated in Data layer |
| **§6 SwiftData for persistence** | ✅ PASS | `MealRecord` + `MealItem` as `@Model` classes with cascade delete |
| **§7 Feature module standards** | ✅ PASS | Each feature is a self-contained folder under `Features/` |
| **§8 NavigationStack** | ✅ PASS | State-driven navigation via `NavigationStack` + `NavigationPath` |
| **§9 4pt grid + reusable Core/UI components** | ✅ PASS | `CalorieRingView`, `MacroProgressBar`, `FoodCard` in `Core/UI/` |
| **§10 Error handling** | ✅ PASS | `FoodError` + `PersistenceError` enums; no crashes; offline fallback |
| **§11 XCTest unit + UI tests** | ✅ PASS | Processor logic, persistence layer, networking layer all tested |
| **§12 SwiftLint + no business logic in views** | ✅ PASS | All business logic in Processors; max 300 lines/file guideline |
| **§13 Performance — no main thread blocking** | ✅ PASS | All network + DB calls `await`-ed off main thread |
| **§14 Security — no token logging** | ✅ PASS | API key via `Config.xcconfig` (gitignored), never logged |
| **§16 Extensibility — modular for future sync/HealthKit** | ✅ PASS | `syncStatus` field on `MealRecord`; `MealRepositoryProtocol` abstraction |

**Gate result**: ✅ ALL PASS — no violations. Ready to proceed.

---

## Project Structure

### Documentation (this feature)

```text
specs/001-food-tracker-app/
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output — research-report.md (complete)
├── data-model.md        # Phase 1 output — entity definitions, Swift declarations
├── quickstart.md        # Phase 1 output — setup, folder structure, run instructions
├── contracts/
│   ├── food-api-client.md      # Phase 1 output — FDC API contract
│   └── persistence-layer.md    # Phase 1 output — SwiftData + MealRepository contract
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
FoodNutritions/
├── App/
│   ├── FoodNutritionsApp.swift       # @main, ModelContainer, NavigationStack root
│   └── RootView.swift
│
├── Core/
│   ├── UI/
│   │   ├── CalorieRingView.swift     # Circle().trim progress ring
│   │   ├── MacroProgressBar.swift    # ProgressView(.linear) wrapper
│   │   └── FoodCard.swift
│   ├── Extensions/
│   │   └── Date+Extensions.swift    # startOfDay helpers
│   └── Constants/
│       └── NutritionGoals.swift     # calories:2000, protein:150, carbs:250, fat:65
│
├── Domain/
│   ├── Models/
│   │   ├── FoodItem.swift           # Transient struct
│   │   ├── ServingUnit.swift        # Transient struct
│   │   ├── DailySummary.swift       # Computed struct
│   │   └── Enums/
│   │       ├── MealType.swift       # Breakfast/Lunch/Dinner/Snack
│   │       ├── SyncStatus.swift     # pending/synced
│   │       └── FoodType.swift       # generic/branded
│   └── Errors/
│       ├── FoodError.swift
│       └── PersistenceError.swift
│
├── Data/
│   ├── API/
│   │   ├── FoodAPIClient.swift      # URLSession + async/await; FoodAPIClientProtocol
│   │   ├── DTOs/
│   │   │   ├── FoodSearchResult.swift    # GET /search response item
│   │   │   ├── NutritionResponse.swift   # GET /nutrition response
│   │   │   ├── ServingUnitResponse.swift # GET /units response
│   │   │   └── MealItemRequest.swift     # POST /meal, /nutrition/bulk body item
│   │   └── Mappers/
│   │       └── FoodAPIMapper.swift  # API DTOs → Domain models (FoodItem, ServingUnit)
│   └── Repositories/
│       ├── FoodRepository.swift     # Search + 24hr in-memory/disk cache
│       └── RecentSearchRepository.swift  # UserDefaults, max 5 entries
│
├── Persistence/
│   ├── Models/
│   │   ├── MealRecord.swift         # @Model, cascade relationship
│   │   └── MealItem.swift           # @Model, child of MealRecord
│   ├── MealRepository.swift         # MealRepositoryProtocol impl (SwiftData CRUD)
│   └── Schema/
│       └── FoodNutritionsSchema.swift # VersionedSchema v1, MigrationPlan
│
├── Features/
│   ├── Dashboard/                   # FR-014, FR-015, FR-016, FR-020 — US4
│   │   ├── DashboardView.swift
│   │   ├── DashboardState.swift
│   │   ├── DashboardIntent.swift
│   │   └── DashboardProcessor.swift
│   ├── Search/                      # FR-001 to FR-005 — US1
│   │   ├── SearchView.swift
│   │   ├── SearchState.swift
│   │   ├── SearchIntent.swift
│   │   └── SearchProcessor.swift
│   ├── FoodDetail/                  # FR-006 to FR-010 — US2
│   │   ├── FoodDetailView.swift
│   │   ├── FoodDetailState.swift
│   │   ├── FoodDetailIntent.swift
│   │   └── FoodDetailProcessor.swift
│   ├── MealLog/                     # FR-011 to FR-013, FR-021 to FR-023 — US3, US5
│   │   ├── MealLogView.swift
│   │   ├── MealLogState.swift
│   │   ├── MealLogIntent.swift
│   │   └── MealLogProcessor.swift
│   └── History/                     # FR-017 — US7
│       ├── HistoryView.swift
│       ├── HistoryState.swift
│       ├── HistoryIntent.swift
│       └── HistoryProcessor.swift
│
└── FoodNutritionsTests/
    ├── Processors/
    │   ├── SearchProcessorTests.swift
    │   ├── FoodDetailProcessorTests.swift
    │   ├── MealLogProcessorTests.swift
    │   ├── DashboardProcessorTests.swift
    │   └── HistoryProcessorTests.swift
    ├── Repositories/
    │   ├── MealRepositoryTests.swift
    │   ├── FoodRepositoryTests.swift
    │   └── RecentSearchRepositoryTests.swift
    └── Mappers/
        └── FDCMapperTests.swift
```

**Structure Decision**: Single iOS app target (Option 3 mobile-only variant). No backend API — the app consumes USDA FDC directly. All server sync deferred to v2 (§16 Future Extensibility).

---

## Complexity Tracking

No constitution violations. No entries required.

---

## Phase 0 Research Summary

All NEEDS CLARIFICATION items resolved. See [research-report.md](research-report.md) for full findings.

| Topic | Decision |
|---|---|
| Persistence | SwiftData `@Model` + `@Relationship(deleteRule: .cascade)` + `@MainActor` |
| Architecture | MVI with `@Observable` Processor + nested `State` struct + nested `Intent` enum |
| Food Data API | Custom FastAPI backend at `https://foodapi.rapheal.in/` (openapi.json in `backend/`) |
| Search debounce | `Task` cancel + `Task.sleep(for: .milliseconds(300))` — no Combine |
| Calorie ring | Custom `Circle().trim` Shape (~30 lines) |
| Macro bars | Native `ProgressView(value:total:).progressViewStyle(.linear)` |

---

## Phase 1 Design Artifacts

### data-model.md — [data-model.md](data-model.md)

| Entity | Type | Persistence |
|---|---|---|
| `MealRecord` | `@Model` class | SwiftData (SQLite) |
| `MealItem` | `@Model` class | SwiftData, cascade child |
| `FoodItem` | `struct` | Transient (in-memory) |
| `ServingUnit` | `struct` | Transient (in-memory) |
| `DailySummary` | `struct` | Computed from MealRecords |
| `RecentSearch` | `[String]` | UserDefaults, max 5 |

Nutrition recalculation formula: `nutrientAtQuantity = (nutrientPer100g / 100.0) × servingGrams`

### contracts/ — [food-api-client.md](contracts/food-api-client.md) | [persistence-layer.md](contracts/persistence-layer.md)

- **FoodAPIClientProtocol**: `searchFoods`, `autocomplete`, `fetchNutrition`, `fetchUnits`, `calculateMeal`, `bulkNutrition` — backed by `https://foodapi.rapheal.in/`
- **MealRepositoryProtocol**: `saveMeal`, `fetchMeals(for:)`, `fetchAllMealDates`, `updateMeal`, `deleteMeal`
- **RecentSearchRepositoryProtocol**: `loadRecentSearches`, `saveSearch`, `clearAll`
- Error types: `FoodError`, `PersistenceError`

### quickstart.md — [quickstart.md](quickstart.md)

- Prerequisites: Xcode 15+, iOS 17+, free USDA FDC API key
- No third-party dependencies (SwiftLint optional)
- API key via `Config.xcconfig` (gitignored)
- Full folder structure documented

---

## Feature → Requirement Mapping

| Feature Module | User Stories | Functional Requirements |
|---|---|---|
| Search | US1 | FR-001, FR-002, FR-003, FR-004, FR-005 |
| FoodDetail | US2 | FR-006, FR-007, FR-008, FR-009, FR-010 |
| MealLog | US3, US5 | FR-011, FR-012, FR-013, FR-021, FR-022, FR-023 |
| Dashboard | US4 | FR-014, FR-015, FR-016, FR-020 |
| History | US7 | FR-017 |
| Cross-cutting | All | FR-018 (offline banner), FR-019 (cache fallback) |

---

## Navigation Flow

```
App Launch
    └── DashboardView (root)
        ├── → SearchView (tap Search icon)
        │       └── → FoodDetailView (tap food result)
        │               └── → MealLogView (tap "Add to Meal")
        │                       └── (save) → back to DashboardView
        ├── → HistoryView (tap History tab)
        │       └── → FoodDetailView (tap historical meal)
        └── → MealLogView (tap existing meal to edit)
```

Navigation driver: `NavigationStack` + `NavigationPath` in `RootView`. Each screen is pushed by Intent (e.g., `SearchIntent.selectFood(food)` triggers navigation to FoodDetail).

---

## Post-Design Constitution Re-Check

| Check | Status |
|---|---|
| All layers have clear boundaries | ✅ Domain has no import of Data/Persistence |
| Feature Processors only depend on Protocol abstractions | ✅ `MealRepositoryProtocol`, `FoodAPIClientProtocol` |
| SwiftData models isolated to Persistence layer | ✅ Features work with Domain models only |
| No Combine usage introduced | ✅ Debounce via Task cancellation only |
| NavigationStack state-driven | ✅ `NavigationPath` driven by Processor state |
| Reusable components in Core/UI | ✅ `CalorieRingView`, `MacroProgressBar`, `FoodCard` |

**Post-design gate**: ✅ ALL PASS
