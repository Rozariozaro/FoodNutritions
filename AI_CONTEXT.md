# AI_CONTEXT.md — FoodNutritions Agent Handoff

> Last updated: 2026-03-14
> Branch: `001-food-tracker-app`
> Completed through: **Phase 9 (Polish & Integration)** — All 59 tasks complete, build passing

---

## Project Overview

A native iOS food-tracking app. Users search for foods, view nutrition details, log meals, track daily progress, edit saved meals, and browse meal history — all offline-first.

---

## Architecture

### Pattern: MVI (Model-View-Intent) + SwiftData

```
View  ->  Intent (enum)  ->  Processor (@Observable)  ->  State (struct)  ->  View
```

- **State**: Plain `struct`, source of truth for a feature screen
- **Intent**: `enum` of user actions dispatched from the View
- **Processor**: `@Observable` class, handles business logic, calls repositories/API
- **View**: SwiftUI, reads from Processor's published state, dispatches Intents

### UI Component Convention
- **Core UI First**: All reusable UI components MUST be placed in `Core/UI/`.
- **Promotion Rule**: If a component is used or likely to be used in more than one feature, it MUST be moved to `Core/UI/`.
- **Audit Requirement**: Before creating a new view, developers MUST check `Core/UI/` to see if a similar component exists or can be generalized.
- **Consistency**: Maintain a consistent premium design language (gradients, micro-animations, clear typography) across all shared components.

### Technology Stack

- **Swift 5.9+**, **SwiftUI**, **SwiftData**, **Swift Concurrency** (async/await)
- **No third-party packages** (SwiftLint optional, dev-only)
- **iOS 17.0** minimum deployment target

---

## Project Structure

```
FoodNutritions/FoodNutritions/FoodNutritions/
├── FoodNutritions.xcodeproj
├── Config.xcconfig                    # FOOD_API_KEY placeholder (gitignored)
├── Info.plist                         # Reads FOOD_API_KEY from xcconfig
├── FoodNutritions/
│   ├── App/
│   │   ├── FoodNutritionsApp.swift       # @main, ModelContainer setup
│   │   └── RootView.swift                # NavigationStack + NavigationPath routing
│   ├── Core/
│   │   ├── Constants/NutritionGoals.swift  # calories:2000 protein:150 carbs:250 fat:65
│   │   ├── Extensions/Date+Extensions.swift
│   │   ├── Infrastructure/
│   │   │   └── NetworkMonitor.swift      # NWPathMonitor, @Observable offline detection
│   │   └── UI/
│   │       ├── CalorieRingView.swift     # Circle().trim progress ring
│   │       ├── MacroProgressBar.swift    # ProgressView(.linear) wrapper
│   │       ├── FoodCard.swift            # Search result card
│   │       ├── CalendarRibbon.swift      # Horizontal date picker for History
│   │       ├── ErrorBanner.swift         # Offline/error banner overlay
│   │       ├── FoodDetailSection.swift   # Reusable detail section layout
│   │       ├── MealItemRow.swift         # Meal item display row
│   │       ├── MicronutrientListView.swift # Micronutrient toggle list
│   │       ├── NutritionMacroHeader.swift  # Macro header display
│   │       ├── NutritionSummaryView.swift  # Nutrition summary card
│   │       └── SortMenuView.swift        # Sort option picker
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Enums/MealType.swift      # breakfast/lunch/dinner/snack
│   │   │   ├── Enums/SyncStatus.swift    # pending/synced
│   │   │   ├── Enums/FoodType.swift      # recipe/packaged
│   │   │   ├── FoodItem.swift            # transient (not persisted)
│   │   │   ├── ServingUnit.swift         # 100g / 50g / 200g / Custom
│   │   │   ├── Micronutrient.swift       # name/value/unit
│   │   │   └── DailySummary.swift        # computed from MealRecords
│   │   └── Errors/
│   │       ├── FoodError.swift           # networkUnavailable/offlineNoCache/invalidResponse/...
│   │       └── PersistenceError.swift    # saveFailed/fetchFailed/recordNotFound/deleteFailed
│   ├── Data/
│   │   ├── API/
│   │   │   ├── DTOs/                     # FoodSearchResult, AutocompleteSuggestion, MealItemRequest,
│   │   │   │                             #   NutritionResponse, SearchFilters
│   │   │   ├── Mappers/FoodAPIMapper.swift  # FoodSearchResult->FoodItem, NutritionResponse->[Micronutrient]
│   │   │   └── FoodAPIClient.swift       # URLSession, x-api-key header from Info.plist
│   │   └── Repositories/
│   │       ├── FoodRepository.swift      # FoodRepositoryProtocol + 24hr in-memory cache
│   │       └── RecentSearchRepository.swift  # UserDefaults, max 5 entries
│   ├── Persistence/
│   │   ├── Models/
│   │   │   ├── MealRecord.swift          # @Model, SwiftData
│   │   │   └── MealItem.swift            # @Model, cascade delete from MealRecord
│   │   ├── Schema/FoodNutritionsSchema.swift  # FoodNutritionsSchemaV1, FoodNutritionsMigrationPlan
│   │   └── MealRepository.swift          # MealRepositoryProtocol + SwiftDataMealRepository
│   └── Features/
│       ├── Search/                        # US1 (Phase 3) — FR-001 to FR-005
│       │   ├── SearchState.swift
│       │   ├── SearchIntent.swift
│       │   ├── SearchProcessor.swift      # debounce 300ms, client-side sort, recent searches
│       │   └── SearchView.swift
│       ├── FoodDetail/                    # US2 (Phase 4) — FR-006 to FR-010
│       │   ├── FoodDetailState.swift
│       │   ├── FoodDetailIntent.swift
│       │   ├── FoodDetailProcessor.swift  # instant preview + server-confirmed nutrition
│       │   └── FoodDetailView.swift
│       ├── MealLog/                       # US3+US5 (Phase 5+7) — FR-011 to FR-013, FR-021 to FR-023
│       │   ├── MealLogState.swift         # supports both create and edit mode
│       │   ├── MealLogIntent.swift
│       │   ├── MealLogProcessor.swift     # save + update meals, bulk nutrition
│       │   └── MealLogView.swift
│       ├── Dashboard/                     # US4 (Phase 6) — FR-014 to FR-016, FR-020
│       │   ├── DashboardState.swift
│       │   ├── DashboardIntent.swift
│       │   ├── DashboardProcessor.swift   # daily summary, meal deletion
│       │   └── DashboardView.swift
│       └── History/                       # US7 (Phase 8) — FR-017
│           ├── HistoryState.swift
│           ├── HistoryIntent.swift
│           ├── HistoryProcessor.swift
│           └── HistoryView.swift
│
├── FoodNutritionsTests/
│   ├── Helpers/
│   │   ├── MockFoodAPIClient.swift        # FoodAPIClientProtocol stub with call counters
│   │   ├── MockMealRepository.swift       # In-memory MealRepositoryProtocol
│   │   ├── MockRecentSearchRepository.swift
│   │   └── FoodItemFactory.swift          # Test fixture builder
│   ├── Mappers/
│   │   └── FoodAPIMapperTests.swift       # 8 tests: field mapping, type fallback, micronutrients, serving units
│   ├── Processors/
│   │   ├── SearchProcessorTests.swift     # 8 tests: debounce, empty query, sort, filters, offline, recent
│   │   ├── FoodDetailProcessorTests.swift # 5 tests: preview formula, serving change, quantity validation, micronutrients
│   │   └── MealLogProcessorTests.swift    # 4 tests: add/remove items, save success, save with no items
│   └── Repositories/
│       └── RecentSearchRepositoryTests.swift  # 6 tests: prepend, dedup, max-5, clear, round-trip
│
└── FoodNutritionsUITests/                 # Default Xcode UI test stubs (not actively used)
```

### Test Files Intentionally Skipped (per user request during implementation)

- `DashboardProcessorTests.swift` — T035b skipped
- `HistoryProcessorTests.swift` — T043b skipped
- `MealRepositoryTests.swift` — T043c skipped
- `FoodRepositoryTests.swift` — listed in plan.md but never tasked

---

## Backend API Contract

**Base URL**: `https://foodapi.rapheal.in`
**Auth**: `x-api-key` header (value from `Info.plist` -> `FOOD_API_KEY` -> `Config.xcconfig`)

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
- **Nutrition formula**: Client-side preview = `(per100g / 100.0) * grams`; server-confirmed via `POST /nutrition/bulk`
- **AutocompleteSuggestion IDs**: Uses `UUID()` (not `name`) to avoid duplicate `ForEach` IDs when API returns duplicate food names
- **Navigation**: Single `NavigationStack` + `NavigationPath` in `RootView`; all route pushes go through it
- **Protocol default params**: `FoodRepositoryProtocol` requires explicit `limit` parameter on `searchFoods` and `autocomplete` — Swift protocols don't propagate default argument values from concrete implementations. Always pass `limit: 20` for search and `limit: 10` for autocomplete.

---

## Implementation Progress

| Phase | Status | Tasks |
|---|---|---|
| Phase 1: Setup | ✅ Complete | T001-T004 |
| Phase 2: Foundational | ✅ Complete | T005-T019d |
| Phase 3: US1 Search | ✅ Complete | T020-T023b |
| Phase 4: US2 Food Detail | ✅ Complete | T024-T027b |
| Phase 5: US3 Meal Log | ✅ Complete | T028-T031b |
| Phase 6: US4 Dashboard | ✅ Complete | T032-T035b (tests skipped) |
| Phase 7: US5 Edit Meal | ✅ Complete | T036-T040, T039b (tests skipped) |
| Phase 8: US7 History | ✅ Complete | T041-T044, T043b-T043c (tests skipped) |
| Phase 9: Polish | ✅ Complete | T045-T050 |

**Build status**: Passing (Xcode 26.3.0 RC, iOS Simulator 26.2, 2026-03-14)

Full task list: [`specs/001-food-tracker-app/tasks.md`](specs/001-food-tracker-app/tasks.md)

---

## Known Issues & Fixes

### Fixed: SearchProcessor missing `limit` argument (2026-03-14)

`SearchProcessor.swift` called `foodRepository.autocomplete(query:)` and `foodRepository.searchFoods(query:filters:)` without the required `limit` parameter. Fixed by adding `limit: 10` to autocomplete and `limit: 20` to searchFoods. Root cause: Swift protocol dispatch doesn't propagate default argument values from the concrete `FoodRepository` class to callers using the `FoodRepositoryProtocol` type.

---

## Next Steps for Incoming Agent

All 59 tasks across 9 phases are complete and the project builds successfully. Potential follow-up work:

### Test Coverage Gaps (if tests are prioritized)

1. Create `DashboardProcessorTests.swift` — 4 tests per testing-strategy.md contract
2. Create `HistoryProcessorTests.swift` — 3 tests per testing-strategy.md contract
3. Create `MealRepositoryTests.swift` — 6 tests per testing-strategy.md contract (requires in-memory SwiftData container)
4. Add missing edit-mode tests to `MealLogProcessorTests.swift` — 3 tests: `testLoadMealForEditingPopulatesState`, `testUpdateMealWithNoItemsSetsError`, `testUpdateMealCallsRepositoryUpdateMeal`
5. Add `testToggleMicronutrientsTwiceCallsAPIOnce` to `FoodDetailProcessorTests.swift`
6. Optionally create `FoodRepositoryTests.swift` (in plan.md but never formally tasked)

### Feature Enhancements (v2 scope)

- User-configurable daily macro goals (currently hardcoded: 2000 kcal, 150g protein, 250g carbs, 65g fat)
- Server sync for meal records (syncStatus field is tracked but no upload occurs in v1)
- HealthKit integration
- Multi-user profiles

---

## Useful Reference Files

| File | Purpose |
|---|---|
| [`specs/001-food-tracker-app/spec.md`](specs/001-food-tracker-app/spec.md) | Full feature requirements (FR-001-FR-023) |
| [`specs/001-food-tracker-app/plan.md`](specs/001-food-tracker-app/plan.md) | Architecture decisions, navigation flow, component map |
| [`specs/001-food-tracker-app/data-model.md`](specs/001-food-tracker-app/data-model.md) | SwiftData schema, field types, relationships |
| [`specs/001-food-tracker-app/contracts/food-api-client.md`](specs/001-food-tracker-app/contracts/food-api-client.md) | API endpoints, request/response shapes |
| [`specs/001-food-tracker-app/contracts/persistence-layer.md`](specs/001-food-tracker-app/contracts/persistence-layer.md) | Repository protocol signatures |
| [`specs/001-food-tracker-app/contracts/testing-strategy.md`](specs/001-food-tracker-app/contracts/testing-strategy.md) | Mock strategy, test scope per phase |
| [`specs/001-food-tracker-app/quickstart.md`](specs/001-food-tracker-app/quickstart.md) | Dev setup: xcconfig, API key, simulator run |
| [`backend/openapi.json`](backend/openapi.json) | Full OpenAPI spec for the food API |
