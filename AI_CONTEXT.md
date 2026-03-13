# AI_CONTEXT.md — FoodNutritions Agent Handoff

> Last updated: 2026-03-13
> Branch: `001-food-tracker-app`
> Completed through: **Phase 3 (US1 Search)**

---

## Project Overview

A native iOS food-tracking app. Users search for foods, view nutrition details, log meals, track daily progress, edit saved meals, and browse meal history — all offline-first.

---

## Architecture

### Pattern: MVI (Model–View–Intent) + SwiftData

```
View  →  Intent (enum)  →  Processor (@Observable)  →  State (struct)  →  View
```

- **State**: Plain `struct`, source of truth for a feature screen
- **Intent**: `enum` of user actions dispatched from the View
- **Processor**: `@Observable` class, handles business logic, calls repositories/API
- **View**: SwiftUI, reads from Processor's published state, dispatches Intents

### Technology Stack

- **Swift 5.9+**, **SwiftUI**, **SwiftData**, **Swift Concurrency** (async/await)
- **No third-party packages** (SwiftLint optional, dev-only)
- **iOS 17.0** minimum deployment target

---

## Project Structure

```
FoodNutritions/FoodNutritions/FoodNutritions/
├── App/
│   ├── FoodNutritionsApp.swift       # @main, ModelContainer setup
│   └── RootView.swift                # NavigationStack + NavigationPath routing
├── Core/
│   ├── Constants/NutritionGoals.swift  # calories:2000 protein:150 carbs:250 fat:65
│   ├── Extensions/Date+Extensions.swift
│   └── UI/
│       ├── CalorieRingView.swift     # Circle().trim progress ring
│       ├── MacroProgressBar.swift    # ProgressView(.linear) wrapper
│       └── FoodCard.swift
├── Domain/
│   ├── Models/
│   │   ├── Enums/MealType.swift      # breakfast/lunch/dinner/snack
│   │   ├── Enums/SyncStatus.swift    # pending/synced/failed
│   │   ├── Enums/FoodType.swift
│   │   ├── FoodItem.swift            # transient (not persisted)
│   │   ├── ServingUnit.swift         # 100g / 50g / 200g / Custom
│   │   ├── Micronutrient.swift
│   │   └── DailySummary.swift
│   └── Errors/
│       ├── FoodError.swift           # networkUnavailable/offlineNoCache/invalidResponse/…
│       └── PersistenceError.swift
├── Data/
│   ├── API/
│   │   ├── DTOs/                     # FoodSearchResult, AutocompleteSuggestion, MealItemRequest,
│   │   │                             #   NutritionResponse, SearchFilters
│   │   ├── Mappers/FoodAPIMapper.swift  # FoodSearchResult→FoodItem, NutritionResponse→[Micronutrient]
│   │   └── FoodAPIClient.swift       # URLSession, x-api-key header from Info.plist
│   └── Repositories/
│       ├── FoodRepository.swift      # 24hr in-memory cache, falls back on network failure
│       └── RecentSearchRepository.swift  # UserDefaults, max 5 entries
├── Persistence/
│   ├── Models/
│   │   ├── MealRecord.swift          # @Model, SwiftData
│   │   └── MealItem.swift            # @Model, cascade delete from MealRecord
│   ├── Schema/FoodNutritionsSchema.swift  # FoodNutritionsSchemaV1, FoodNutritionsMigrationPlan
│   └── MealRepository.swift          # SwiftDataMealRepository
└── Features/
    ├── Search/                        # ✅ COMPLETE (Phase 3)
    │   ├── SearchState.swift
    │   ├── SearchIntent.swift
    │   ├── SearchProcessor.swift      # debounce 300ms, client-side sort, recent searches
    │   └── SearchView.swift
    ├── FoodDetail/                    # ⏳ Phase 4 (next)
    ├── MealLog/                       # ⏳ Phase 5
    ├── Dashboard/                     # ⏳ Phase 6
    └── History/                       # ⏳ Phase 8

FoodNutritions/FoodNutritions/FoodNutritionsTests/
├── Helpers/        # MockFoodAPIClient, MockMealRepository, MockRecentSearchRepository, FoodItemFactory
├── Mappers/        # FoodAPIMapperTests
├── Processors/     # SearchProcessorTests (+ future: FoodDetailProcessor, MealLogProcessor, …)
└── Repositories/   # RecentSearchRepositoryTests (+ future: MealRepositoryTests)
```

---

## Backend API Contract

**Base URL**: `https://foodapi.rapheal.in`
**Auth**: `x-api-key` header (value from `Info.plist` → `FOOD_API_KEY` → `Config.xcconfig`)

| Endpoint | Method | Purpose |
|---|---|---|
| `/search` | GET | Search foods — params: `q`, `limit`, `protein_min`, `calories_max`, `carbs_max`, `sodium_max_mg`, `protein_density_min`, `fiber_density_min` |
| `/autocomplete` | GET | Autocomplete suggestions — params: `q`, `limit` |
| `/nutrition/bulk` | POST | Server-confirmed nutrition for meal items — body: `[MealItemRequest]` |

Full contract: [`specs/001-food-tracker-app/contracts/food-api-client.md`](specs/001-food-tracker-app/contracts/food-api-client.md)

---

## Key Design Decisions

- **Offline-first**: `FoodRepository` caches responses for 24hrs; falls back to cache on network failure; throws `FoodError.offlineNoCache` only when cache is expired
- **No third-party deps**: All networking is `URLSession`, persistence is `SwiftData`, UI is `SwiftUI`
- **Nutrition formula**: Client-side preview = `(per100g / 100.0) × grams`; server-confirmed via `POST /nutrition/bulk`
- **AutocompleteSuggestion IDs**: Uses `UUID()` (not `name`) to avoid duplicate `ForEach` IDs when API returns duplicate food names
- **Navigation**: Single `NavigationStack` + `NavigationPath` in `RootView`; all route pushes go through it

---

## Implementation Progress

| Phase | Status | Tasks |
|---|---|---|
| Phase 1: Setup | ✅ Complete | T001–T004 |
| Phase 2: Foundational | ✅ Complete | T005–T019d |
| Phase 3: US1 Search | ✅ Complete | T020–T023b |
| Phase 4: US2 Food Detail | ⏳ Next | T024–T027b |
| Phase 5: US3 Meal Log | ⏳ Pending | T028–T031b |
| Phase 6: US4 Dashboard | ⏳ Pending | T032–T035b |
| Phase 7: US5 Edit Meal | ⏳ Pending | T036–T040, T039b |
| Phase 8: US7 History | ⏳ Pending | T041–T044, T043b–T043c |
| Phase 9: Polish | ⏳ Pending | T045–T050 |

Full task list: [`specs/001-food-tracker-app/tasks.md`](specs/001-food-tracker-app/tasks.md)

---

## Next Steps for Incoming Agent

**Start with Phase 4 — US2 Food Detail** (T024–T027b):

1. `T024` [P] Create `FoodDetailState` in `Features/FoodDetail/FoodDetailState.swift`
2. `T025` [P] Create `FoodDetailIntent` in `Features/FoodDetail/FoodDetailIntent.swift`
3. `T026` Create `FoodDetailProcessor` — instant preview formula + `bulkNutrition` call + lazy micronutrients
4. `T027` Create `FoodDetailView` — macro chart, serving picker, quantity field, micronutrient toggle, "Add to Meal" button
5. `T027b` Create `FoodDetailProcessorTests`

**T024 and T025 can be written in parallel** (no dependencies between them).

### Acceptance Test for Phase 4
> Select any food from search results → verify macro chart renders → change serving unit to "50g" → verify values halve → enter custom quantity of 200 → verify values double → toggle micronutrients → verify Sodium/Fiber appear or show "Not available"

---

## Useful Reference Files

| File | Purpose |
|---|---|
| [`specs/001-food-tracker-app/spec.md`](specs/001-food-tracker-app/spec.md) | Full feature requirements (FR-001–FR-020) |
| [`specs/001-food-tracker-app/plan.md`](specs/001-food-tracker-app/plan.md) | Architecture decisions, navigation flow, component map |
| [`specs/001-food-tracker-app/data-model.md`](specs/001-food-tracker-app/data-model.md) | SwiftData schema, field types, relationships |
| [`specs/001-food-tracker-app/contracts/food-api-client.md`](specs/001-food-tracker-app/contracts/food-api-client.md) | API endpoints, request/response shapes |
| [`specs/001-food-tracker-app/contracts/persistence-layer.md`](specs/001-food-tracker-app/contracts/persistence-layer.md) | Repository protocol signatures |
| [`specs/001-food-tracker-app/contracts/testing-strategy.md`](specs/001-food-tracker-app/contracts/testing-strategy.md) | Mock strategy, test scope per phase |
| [`specs/001-food-tracker-app/quickstart.md`](specs/001-food-tracker-app/quickstart.md) | Dev setup: xcconfig, API key, simulator run |
| [`backend/openapi.json`](backend/openapi.json) | Full OpenAPI spec for the food API |
