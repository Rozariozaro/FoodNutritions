# Feature Specification: Design System Adoption

**Feature Branch**: `002-design-system-adoption`
**Created**: 2026-03-17
**Status**: Draft
**Input**: User description: "Refactor the SwiftUI UI layer to adopt the design system. Replace hardcoded styling values with tokens from Core/DesignTokens and use reusable SwiftUI components from Core/UI (after modifying it based on the design tokens) across all screens under Features."

## Clarifications

### Session 2026-03-17

- Q: How should overlapping `Core/UI` and `Core/DesignTokens` components (e.g., both `MacroProgressBar` files) be reconciled? → A: Keep both files, make each independently token-aware, add a cross-reference comment in each pointing to the other.
- Q: When a view uses a system colour/material with no direct token equivalent (e.g., `.quaternary`, `Color(.systemBackground)`), what should happen? → A: Replace with the nearest semantic `AppColors` token; document the mapping in the Assumptions section.
- Q: What is the scope of the required `DesignSystemDemoView` update? → A: Minimal — add newly reconciled or updated components only; do not restructure or rewrite existing demo content.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consistent Visual Experience Across All Screens (Priority: P1)

As a developer maintaining the app, I need all screens to draw their colours, spacing, typography, and shape values from a single design token layer so that a single token change propagates everywhere automatically.

A user opening any screen in the app sees a visually consistent interface: the same surface colours, the same text styles, the same spacing rhythm, the same corner radii, and the same shadows — with no screen looking "different" from another due to locally overridden values.

**Why this priority**: Visual consistency is the primary goal of design system adoption. Every other story depends on the token layer being in place first.

**Independent Test**: Open each feature screen (Dashboard, Search, MealLog, FoodDetail, History) and verify all typography, colours, spacing, and radii match the design token definitions without any hardcoded overrides.

**Acceptance Scenarios**:

1. **Given** any feature screen is displayed, **When** a developer inspects the source, **Then** every colour, font, spacing value, corner radius, and shadow visible on screen is traced back to a named token in `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, or `AppShadows`.
2. **Given** a token value is changed (e.g., `AppSpacing.md`), **When** the app is rebuilt, **Then** every component that referenced that token reflects the new value with no per-screen code change required.
3. **Given** a screen uses a semantic colour role (e.g., `textSecondary`), **When** the system switches between light and dark appearance, **Then** the colour adapts correctly because the asset catalogue backing the token handles the variant.

---

### User Story 2 - Core/UI Components Updated to Use Design Tokens (Priority: P2)

As a developer, I need all shared SwiftUI components in `Core/UI` to source their styling exclusively from design tokens and, where a matching component already exists in `Core/DesignTokens`, to reconcile the two into a consistent, token-aware implementation.

**Why this priority**: The shared components are the building blocks consumed by every feature screen. Until they use tokens, feature screens cannot correctly adopt the system even if they try.

**Independent Test**: Inspect each `Core/UI` component file (`FoodCard`, `CalorieRingView`, `MacroProgressBar`, `MealItemRow`, `CalendarRibbon`, `NutritionMacroHeader`, `NutritionSummaryView`, `ErrorBanner`, `FoodDetailSection`, `MicronutrientListView`, `SortMenuView`) and confirm zero hardcoded `Color`, `Font`, or numeric spacing/radius/shadow literals remain.

**Acceptance Scenarios**:

1. **Given** `FoodCard` is rendered, **When** inspected, **Then** its padding uses `AppSpacing`, background uses `AppColors.surface`, corner radius uses `AppRadius`, shadow uses `.appShadowSoft()`, and macro chip colours reference `AppColors.protein`, `AppColors.carbs`, and `AppColors.fat` instead of `.blue`, `.green`, `.orange`.
2. **Given** `CalorieRingView` is rendered, **When** inspected, **Then** the default ring colour is `AppColors.primary`, the over-goal colour is `AppColors.error`, and all text styles reference `AppTypography` tokens.
3. **Given** `Core/UI/MacroProgressBar` is rendered, **When** inspected, **Then** its spacing and font styles reference `AppTheme` tokens, consistent with the canonical `Core/DesignTokens/MacroProgressBar` component.

---

### User Story 3 - Feature Screens Replace Inline Styling with Tokens and Shared Components (Priority: P3)

As a developer, I need every feature screen under `Features/` (Dashboard, Search, MealLog, FoodDetail, History) to eliminate inline hardcoded styling by using either a token reference or a call to a shared `Core/UI` or `Core/DesignTokens` component.

**Why this priority**: Once the component library is token-aware (P2), applying it to feature screens is the final step — it delivers user-visible consistency and eliminates duplication.

**Independent Test**: Each feature screen file can be audited for absence of raw `Color(...)`, system font literals (`.font(.headline)` etc.), numeric spacing literals in `.padding()` or `spacing:`, and raw `.shadow(...)` calls. Any such occurrence should be replaced by a token or component.

**Acceptance Scenarios**:

1. **Given** `DashboardView` is displayed, **When** the floating action button is inspected, **Then** its fill colour references `AppColors.primary`, its shadow references `AppShadows` / `.appShadowSoft()`, and its padding references `AppSpacing`.
2. **Given** `SearchView`'s search bar autocomplete overlay is displayed, **When** inspected, **Then** the corner radius and shadow reference tokens rather than raw literals.
3. **Given** any feature screen composes a `MealItemRow`, `NutritionSummaryView`, or `CalorieRingView`, **When** rendered, **Then** it uses the shared `Core/UI` version updated under P2 — not an inline re-implementation.

---

### Edge Cases

- What happens when a `Core/UI` component has a parameter that currently accepts a raw `Color` (e.g., `CalorieRingView.ringColor`)? The parameter remains but its default value references the appropriate token; existing callers that pass explicit colours are unaffected.
- How does the system handle a design token colour name that has no matching asset catalogue entry at runtime? The `Color("name")` initialiser returns a silent clear fallback; missing catalogue entries must be treated as a build-time validation issue, not a runtime crash.
- What if a `Core/DesignTokens` component and a `Core/UI` component have overlapping responsibilities with different APIs? The refactor must reconcile them without breaking existing call sites in feature screens.
- What happens to hardcoded values inside private sub-views (e.g., `MacroChip` inside `FoodCard`)? They are in scope and must be tokenised as part of the parent component's refactor.
- What happens when a feature screen uses `Color(.systemBackground)` or `.quaternary` material? These are replaced with the nearest `AppColors` semantic token: `Color(.systemBackground)` → `AppColors.background`, `.quaternary` background → `AppColors.surface`.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every `Core/UI` Swift component MUST replace all hardcoded `Color`, `Font`, numeric padding/spacing, corner radius, and shadow values with references to the corresponding `AppTheme.*` token (or directly: `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppShadows`).
- **FR-002**: Macro-nutrient colour references in `Core/UI` components MUST use `AppColors.protein`, `AppColors.carbs`, and `AppColors.fat` instead of `.blue`, `.green`, and `.orange`.
- **FR-003**: Every feature screen under `Features/` MUST replace inline hardcoded styling values with token references or calls to shared `Core/UI` / `Core/DesignTokens` components.
- **FR-004**: Where a `Core/DesignTokens` component (`MacroProgressBar`, `CircularProgressView`, `Card`, `ListItemRow`, `Chip`, `PrimaryButton`, `SecondaryButton`) overlaps with a `Core/UI` component, both files MUST be kept independently token-aware (no merging, no migration of call sites); each file MUST include a source comment cross-referencing the other component and noting the distinction in their APIs.
- **FR-005**: The `AppTheme` facade MUST remain the single authoritative entry point for all token namespaces; no duplicate token definitions may exist across files.
- **FR-006**: All `Core/UI` and `Core/DesignTokens` component public APIs MUST remain backward-compatible at their call sites in feature screens; no feature screen MUST lose functionality to complete the refactor.
- **FR-007**: After the refactor, no `.swift` file under `Core/UI/` or `Features/` MUST contain raw numeric literals used as spacing, corner radius, or shadow radius values unless they are arguments to a token-defined constant.
- **FR-008**: The `DesignSystemDemoView` in `Core/DesignTokens` MUST be updated minimally — adding any newly reconciled or updated components that are not yet represented — without restructuring or rewriting existing demo content.

### Key Entities

- **Design Token**: A named, typed constant (colour, font, spacing value, radius, shadow) defined in `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, or `AppShadows`, accessible via `AppTheme`.
- **Shared Component (`Core/UI`)**: A SwiftUI `View` struct in `Core/UI/` consumed by feature screens; currently contains hardcoded values that must be tokenised.
- **Design Token Component (`Core/DesignTokens`)**: A SwiftUI `View` struct in `Core/DesignTokens/` that is already token-aware and serves as the canonical reference implementation.
- **Feature Screen**: A top-level SwiftUI `View` under `Features/` (Dashboard, Search, MealLog, FoodDetail, History) that assembles shared components and may contain local inline styling that must be eliminated.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the refactor, a source audit of all files in `Core/UI/` and `Features/` finds zero occurrences of raw colour literals (`.blue`, `.green`, `.orange`, `.red`, `Color(.systemBackground)`, `.quaternary`, etc.) used as component styling — all replaced by `AppColors.*` or `AppTheme.colors.*`.
- **SC-002**: After the refactor, a source audit of all files in `Core/UI/` and `Features/` finds zero occurrences of standalone hardcoded numeric padding, spacing, corner radius, or shadow radius values — all replaced by `AppSpacing.*`, `AppRadius.*`, or `AppShadows.*` references.
- **SC-003**: After the refactor, a source audit of all files in `Core/UI/` and `Features/` finds zero occurrences of system font literal calls (e.g., `.font(.headline)`, `.font(.caption)`, `.font(.subheadline)`) — all replaced by `AppTypography.*` via `AppTheme.typography.*`.
- **SC-004**: Changing one design token value and rebuilding the app results in a visually updated UI across all affected screens with no additional per-screen code changes required.
- **SC-005**: The `DesignSystemDemoView` renders all token-aware components without build errors or visual regressions.
- **SC-006**: All five feature screens (Dashboard, Search, MealLog, FoodDetail, History) build and run without errors after the refactor, with no functional behaviour changes.

---

## Assumptions

- The `Core/DesignTokens/` directory is the authoritative token source; token definitions there are correct and should not be changed as part of this refactor.
- The asset catalogue already contains entries for all named colours referenced in `AppColors` (e.g., `"background"`, `"surface"`, `"protein"`, etc.); any missing entries are a pre-existing issue outside this feature's scope.
- `Core/UI/MacroProgressBar.swift` (richer `current/goal` progress API) and `Core/DesignTokens/MacroProgressBar.swift` (simpler `value/color/label` API) serve different call sites and are kept as separate, independently token-aware components with no merging or call-site migration; each file will carry a cross-reference comment pointing to the other.
- Feature screens currently build and run correctly; this refactor introduces no behaviour changes, only styling source changes.
- `SecondaryButton` in `Core/DesignTokens` is already token-aware; it is in scope for reconciliation verification but not for API redesign.
- System colour/material mappings applied during this refactor: `Color(.systemBackground)` → `AppColors.background`; `.quaternary` search bar background → `AppColors.surface`; `.regularMaterial` autocomplete overlay → `AppColors.surfaceElevated`.
