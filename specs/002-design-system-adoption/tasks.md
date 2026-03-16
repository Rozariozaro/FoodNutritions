# Tasks: Design System Adoption

**Input**: Design documents from `/specs/002-design-system-adoption/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup (Token Foundation)

**Purpose**: Add the one missing token that all subsequent tasks depend on.

**⚠️ CRITICAL**: Phase B and C tasks that use `AppSpacing.smMd` require this to compile.

- [x] T001 Add `public static let smMd: CGFloat = 12` after the `sm` line in `FoodNutritions/FoodNutritions/FoodNutritions/Core/DesignTokens/AppSpacing.swift`

**Checkpoint**: `AppSpacing.smMd` resolves at all call sites — all story phases can now proceed.

---

## Phase 2: Foundational (No blocking prerequisites beyond T001)

*No additional shared infrastructure is required. All Core/UI components in Phase 3 and feature screens in Phase 4 are independently modifiable once T001 is complete.*

---

## Phase 3: User Story 2 — Core/UI Components Tokenised (Priority: P2) 🎯 MVP

> **Note**: US2 (Core/UI components) is implemented before US3 (feature screens) because feature screens consume these components. US1 (end-to-end consistency) is the emergent result of completing US2 + US3 together.

**Goal**: Eliminate all hardcoded styling from the 11 shared components in `Core/UI/`.

**Independent Test**: Inspect each `Core/UI` file — zero raw `Color`, `Font`, or numeric spacing/radius/shadow literals remain.

### Implementation for User Story 2

- [x] T002 [P] [US2] Tokenise `FoodCard.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/FoodCard.swift`:
  - `spacing: 8` → `AppSpacing.sm`; `spacing: 2` → `AppSpacing.xs`; `spacing: 16` → `AppSpacing.md`
  - `.font(.headline)` → `AppTypography.headline`; `.font(.caption)` / `.font(.caption2)` → `AppTypography.caption1`
  - `.font(.subheadline.bold())` → `AppTypography.subhead.bold()`; `.font(.caption2.bold())` → `AppTypography.caption1.bold()`
  - `.foregroundStyle(.secondary)` → `.foregroundStyle(AppColors.textSecondary)`
  - `color: .blue` → `AppColors.protein`; `color: .green` → `AppColors.carbs`; `color: .orange` → `AppColors.fat`
  - `.padding(12)` → `.padding(AppSpacing.smMd)`
  - `.background(.background)` → `.background(AppColors.surface)`
  - `cornerRadius: 12` → `AppRadius.md`
  - `.shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)` → `.appShadowSoft()`

- [x] T003 [P] [US2] Tokenise `CalorieRingView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/CalorieRingView.swift`:
  - Default `ringColor` parameter: `.orange` → `AppColors.primary`
  - `isOverGoal ? .red : ringColor` → `isOverGoal ? AppColors.error : ringColor`
  - `.subheadline.bold()` → `AppTypography.subhead.bold()`; `.title2.bold()` → `AppTypography.title2.bold()`
  - `.caption2` → `AppTypography.caption1`; `.caption` → `AppTypography.footnote`
  - `.foregroundStyle(.secondary)` → `.foregroundStyle(AppColors.textSecondary)`
  - `.foregroundStyle(isOverGoal ? .red : .primary)` → `.foregroundStyle(isOverGoal ? AppColors.error : AppColors.textPrimary)`

- [x] T004 [P] [US2] Tokenise `MacroProgressBar.swift` (Core/UI version) in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/MacroProgressBar.swift`:
  - `spacing: 4` → `AppSpacing.xs`
  - `.font(.subheadline.weight(.medium))` → `AppTypography.subhead.weight(.medium)`
  - `.font(.caption)` → `AppTypography.caption1`
  - `.foregroundStyle(.secondary)` → `.foregroundStyle(AppColors.textSecondary)`
  - Default `color` parameter: `.blue` → `AppColors.protein`
  - Add cross-reference comment: `// See also: Core/DesignTokens/MacroProgressBar.swift (simpler value/color/label API)`

- [x] T005 [P] [US2] Tokenise `MealItemRow.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/MealItemRow.swift`:
  - Both VStack `spacing: 2` → `AppSpacing.xs`
  - `.font(.headline)` → `AppTypography.headline`; `.font(.subheadline)` → `AppTypography.subhead`
  - `.font(.subheadline.bold())` → `AppTypography.subhead.bold()`; `.font(.caption2)` → `AppTypography.caption1`
  - `.foregroundStyle(.secondary)` → `.foregroundStyle(AppColors.textSecondary)`
  - Add cross-reference comment: `// See also: Core/DesignTokens/ListItemRow.swift (generic HStack layout wrapper)`

- [x] T006 [P] [US2] Tokenise `CalendarRibbon.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/CalendarRibbon.swift`:
  - `Color(.systemBackground)` (ribbon bg) → `AppColors.background`
  - `spacing: 12` (date HStack) → `AppSpacing.smMd`
  - `.padding(.vertical, 8)` → `.padding(.vertical, AppSpacing.sm)`
  - `spacing: 4` (DateCell VStack) → `AppSpacing.xs`
  - `.font(.caption2.weight(.medium))` → `AppTypography.caption1.weight(.medium)`
  - `.font(.headline)` → `AppTypography.headline`
  - `.foregroundStyle(.secondary)` → `AppColors.textSecondary`; `.foregroundStyle(.primary)` → `AppColors.textPrimary`
  - All three `cornerRadius: 12` (RoundedRectangle) → `AppRadius.md`
  - `Color.blue.gradient` → `AppColors.primary.gradient`; `Color.blue` (today stroke) → `AppColors.primary`
  - `Color(.secondarySystemBackground)` → `AppColors.surface`

- [x] T007 [P] [US2] Tokenise `NutritionSummaryView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/NutritionSummaryView.swift`:
  - `spacing: 12` → `AppSpacing.smMd`; `spacing: 8` → `AppSpacing.sm`
  - `.font(.title.bold())` → `AppTypography.title1.bold()`
  - `.font(.caption)` → `AppTypography.caption1`
  - `.foregroundStyle(.secondary)` → `AppColors.textSecondary`
  - `.padding(.vertical, 8)` → `.padding(.vertical, AppSpacing.sm)`
  - `MacroProgressBar(color: .blue)` → `AppColors.protein`; `.green` → `AppColors.carbs`; `.orange` → `AppColors.fat`

- [x] T008 [P] [US2] Tokenise `NutritionMacroHeader.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/NutritionMacroHeader.swift`:
  - `spacing: 32` → `AppSpacing.xl`; `spacing: 12` → `AppSpacing.smMd`; `spacing: 4` → `AppSpacing.xs`
  - `.font(.caption.bold())` → `AppTypography.caption1.bold()`; `.font(.caption)` → `AppTypography.caption1`
  - `.foregroundStyle(.secondary)` → `AppColors.textSecondary`
  - `.padding()` → `.padding(AppSpacing.md)`
  - `Color(.secondarySystemBackground)` → `AppColors.surface`
  - `cornerRadius: 20` → `AppRadius.lg`
  - `color: .blue` / `.green` / `.orange` (in `macroRow`) → `AppColors.protein` / `.carbs` / `.fat`
  - Remove explicit `ringColor: .orange` argument (CalorieRingView now defaults to `AppColors.primary`)

- [x] T009 [P] [US2] Verify/tokenise `ErrorBanner.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/ErrorBanner.swift` — audit for any remaining hardcoded `Color`, `Font`, spacing, radius, or shadow literals and replace with tokens

- [x] T010 [P] [US2] Verify/tokenise `FoodDetailSection.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/FoodDetailSection.swift` — audit for any remaining hardcoded literals and replace with tokens

- [x] T011 [P] [US2] Verify/tokenise `MicronutrientListView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/MicronutrientListView.swift` — audit for any remaining hardcoded literals and replace with tokens

- [x] T012 [P] [US2] Verify/tokenise `SortMenuView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/UI/SortMenuView.swift` — audit for any remaining hardcoded literals and replace with tokens

**Checkpoint**: All 11 Core/UI components are token-aware. Feature screen tokenisation can now proceed.

---

## Phase 4: User Story 3 — Feature Screens Tokenised (Priority: P3)

**Goal**: Eliminate all inline hardcoded styling from the 5 feature screens under `Features/`.

**Independent Test**: Audit each feature screen file for absence of raw `Color(...)`, system font literals, numeric spacing literals in `.padding()` or `spacing:`, and raw `.shadow(...)` calls.

### Implementation for User Story 3

- [x] T013 [P] [US3] Tokenise `DashboardView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Features/Dashboard/DashboardView.swift`:
  - `.padding(.vertical, 8)` → `.padding(.vertical, AppSpacing.sm)`
  - `EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)` → `EdgeInsets(top: AppSpacing.md, leading: AppSpacing.md, bottom: AppSpacing.md, trailing: AppSpacing.md)`
  - `Color(.systemBackground)` → `AppColors.background`
  - `Color.clear.frame(height: 80)` → `Color.clear.frame(height: AppSpacing.xxl + AppSpacing.xl)`
  - `.font(.title2.bold())` (FAB label) → `AppTypography.title2.bold()`
  - `Color.blue` (FAB fill) → `AppColors.primary`
  - `.shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)` → `.appShadowSoft()`
  - `.padding(24)` (FAB) → `.padding(AppSpacing.lg)`

- [x] T014 [P] [US3] Tokenise `SearchView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Features/Search/SearchView.swift`:
  - `spacing: 8` (searchBar HStack) → `AppSpacing.sm`
  - `.padding(10)` → `.padding(AppSpacing.sm)`
  - `.background(.quaternary)` → `.background(AppColors.surface)`
  - `cornerRadius: 12` (search field) → `AppRadius.md`
  - `.padding(.vertical, 8)` → `.padding(.vertical, AppSpacing.sm)`
  - `.padding(.horizontal, 16)` / `.padding(.leading, 16)` → `AppSpacing.md`
  - `.padding(.vertical, 12)` → `.padding(.vertical, AppSpacing.smMd)`
  - `.background(.regularMaterial)` (autocomplete) → `.background(AppColors.surfaceElevated)`
  - `cornerRadius: 12` (autocomplete) → `AppRadius.md`
  - `.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)` → `.appShadowSoft()`
  - `.padding(.top, 4)` → `.padding(.top, AppSpacing.xs)`
  - `spacing: 8` (recentSearches) → `AppSpacing.sm`
  - `.font(.subheadline.bold())` → `AppTypography.subhead.bold()`
  - `.foregroundStyle(.secondary)` → `AppColors.textSecondary`
  - `.padding(.top, 16)` → `.padding(.top, AppSpacing.md)`
  - `spacing: 12` (resultsSection) → `AppSpacing.smMd`
  - `.font(.subheadline)` → `AppTypography.subhead`
  - `.padding(.top, 8)` → `.padding(.top, AppSpacing.sm)`
  - `spacing: 16` (emptyState) → `AppSpacing.md`
  - `.padding(.top, 40)` → `.padding(.top, AppSpacing.xl)`
  - `.font(.caption)` (autocomplete label) → `AppTypography.caption1`

- [x] T015 [P] [US3] Tokenise `FoodDetailView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Features/FoodDetail/FoodDetailView.swift`:
  - `spacing: 24` → `AppSpacing.lg`; `spacing: 8` → `AppSpacing.sm`; `spacing: 4` → `AppSpacing.xs`
  - `.font(.largeTitle.bold())` → `AppTypography.largeTitle.bold()`
  - `.font(.headline)` → `AppTypography.headline`; `.font(.caption)` → `AppTypography.caption1`
  - `.font(.subheadline)` → `AppTypography.subhead`
  - `.foregroundStyle(.secondary)` → `AppColors.textSecondary`
  - `Color.blue` (button enabled) → `AppColors.primary`
  - `Color.gray` (button disabled) → `AppColors.textSecondary`
  - `cornerRadius: 15` → `AppRadius.lg`
  - `.padding()` (button) → `.padding(AppSpacing.md)`

- [x] T016 [P] [US3] Tokenise `MealLogView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Features/MealLog/MealLogView.swift`:
  - `cornerRadius: 12` (saving overlay) → `AppRadius.md`
  - `.background(.ultraThinMaterial)` → `.background(AppColors.surfaceElevated)`
  - `.padding()` (saving overlay) → `.padding(AppSpacing.md)`

- [x] T017 [P] [US3] Tokenise `HistoryView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Features/History/HistoryView.swift`:
  - `EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)` → `EdgeInsets(top: AppSpacing.sm, leading: 0, bottom: AppSpacing.sm, trailing: 0)`

**Checkpoint**: All 5 feature screens are token-aware. US1 (end-to-end visual consistency) is now satisfied.

---

## Phase 5: Polish — Cross-Reference Comments & Demo Update

**Purpose**: Complete FR-004 (cross-reference comments) and FR-008 (DesignSystemDemoView update).

- [x] T018 [P] Add cross-reference comment to `Core/DesignTokens/MacroProgressBar.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/DesignTokens/MacroProgressBar.swift`:
  - Add: `// See also: Core/UI/MacroProgressBar.swift (richer current/goal progress API for dashboard/summary use)`

- [x] T019 [P] Add cross-reference comment to `Core/DesignTokens/CircularProgressView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/DesignTokens/CircularProgressView.swift`:
  - Add: `// See also: Core/UI/CalorieRingView.swift (labelled calorie ring with goal text and over-goal state)`

- [x] T020 [P] Add cross-reference comment to `Core/DesignTokens/ListItemRow.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/DesignTokens/ListItemRow.swift`:
  - Add: `// See also: Core/UI/MealItemRow.swift (food-specific row with macro detail)`

- [x] T021 Audit `DesignSystemDemoView.swift` in `FoodNutritions/FoodNutritions/FoodNutritions/Core/DesignTokens/DesignSystemDemoView.swift` and add minimal showcase rows for any token-aware components updated in Phase 3 that are not yet represented — do not restructure or reorder existing content

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2**: Vacuous (no additional foundational tasks)
- **Phase 3 (US2 — Core/UI)**: Requires T001 complete — all T002–T012 can then run in parallel
- **Phase 4 (US3 — Feature Screens)**: Requires Phase 3 complete (components must be tokenised first) — all T013–T017 can then run in parallel
- **Phase 5 (Polish)**: Requires Phase 3 complete; T018–T020 can run in parallel after T004 and T005; T021 runs after Phase 3+4 complete

### User Story Dependencies

- **US2 (P2 — Core/UI)**: Can start after T001 — no dependency on US3
- **US3 (P3 — Feature Screens)**: Can start after US2 is complete
- **US1 (P1 — Consistency)**: Achieved automatically when US2 + US3 + Phase 5 are complete

### Within User Story 2

- T002–T012 are all independent (different files) — run in parallel after T001

### Within User Story 3

- T013–T017 are all independent (different files) — run in parallel after US2 complete

---

## Parallel Example: User Story 2 (Core/UI Tokenisation)

```text
# After T001 completes, launch all T002–T012 together:
Task: T002 — FoodCard.swift
Task: T003 — CalorieRingView.swift
Task: T004 — MacroProgressBar.swift (Core/UI)
Task: T005 — MealItemRow.swift
Task: T006 — CalendarRibbon.swift
Task: T007 — NutritionSummaryView.swift
Task: T008 — NutritionMacroHeader.swift
Task: T009 — ErrorBanner.swift
Task: T010 — FoodDetailSection.swift
Task: T011 — MicronutrientListView.swift
Task: T012 — SortMenuView.swift
```

## Parallel Example: User Story 3 (Feature Screen Tokenisation)

```text
# After US2 complete, launch all T013–T017 together:
Task: T013 — DashboardView.swift
Task: T014 — SearchView.swift
Task: T015 — FoodDetailView.swift
Task: T016 — MealLogView.swift
Task: T017 — HistoryView.swift
```

---

## Implementation Strategy

### MVP First (US2 Only — Token-Aware Components)

1. Complete Phase 1: T001 — add `AppSpacing.smMd`
2. Complete Phase 3: T002–T012 — tokenise all Core/UI components
3. **STOP and VALIDATE**: Run SC-001, SC-002, SC-003 audits on `Core/UI/` only
4. Components are now fully token-aware; feature screens can adopt next

### Incremental Delivery

1. T001 → Token foundation complete
2. T002–T012 in parallel → Core/UI components token-aware (US2 ✅)
3. T013–T017 in parallel → Feature screens token-aware (US3 ✅)
4. T018–T021 → Cross-ref comments + demo update (Polish ✅)
5. Run full SC-001/SC-002/SC-003 audit → US1 verified ✅

### Parallel Team Strategy

With multiple developers:

1. Developer A: T001 (unblocks all)
2. Once T001 done:
   - Developer A: T002, T003, T004, T005, T006
   - Developer B: T007, T008, T009, T010, T011, T012
3. Once US2 done:
   - Developer A: T013, T014
   - Developer B: T015, T016, T017
4. Developer A: T018, T019, T020, T021 (Polish)

---

## Verification (post-implementation)

Run SC-001–SC-003 source audits from plan.md after all phases complete:

```bash
# SC-001: zero raw colour literals
grep -rn "\.blue\b\|\.green\b\|\.orange\b\|\.red\b\|Color(\.system\|secondarySystem\|\.quaternary\|regularMaterial\|ultraThinMaterial" \
  FoodNutritions/FoodNutritions/FoodNutritions/Core/UI \
  FoodNutritions/FoodNutritions/FoodNutritions/Features

# SC-002: zero raw numeric spacing/radius/shadow literals
grep -rn "\.padding([0-9]\|spacing: [0-9]\|cornerRadius: [0-9]\|\.shadow(color:" \
  FoodNutritions/FoodNutritions/FoodNutritions/Core/UI \
  FoodNutritions/FoodNutritions/FoodNutritions/Features

# SC-003: zero system font literal calls
grep -rn "\.font(\.\(headline\|subheadline\|caption\|largeTitle\|title\|body\|footnote\))" \
  FoodNutritions/FoodNutritions/FoodNutritions/Core/UI \
  FoodNutritions/FoodNutritions/FoodNutritions/Features
```

Expected: zero matches (exceptions: `#Preview` blocks and inline comments are acceptable).

---

## Notes

- [P] tasks touch different files — safe to run in parallel
- [Story] label maps each task to its user story for traceability
- No new files are created; all changes are in-place replacements
- No behaviour changes, only styling source changes
- Commit after each task or after completing an entire phase
- Stop at each **Checkpoint** to validate independently before proceeding
