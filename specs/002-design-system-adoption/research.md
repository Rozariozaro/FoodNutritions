# Research: Design System Adoption

**Feature**: `002-design-system-adoption`
**Date**: 2026-03-17
**Status**: Complete — no NEEDS CLARIFICATION items remain

---

## 1. Hardcoded Value Audit

Full inventory of hardcoded styling values discovered across `Core/UI/` and `Features/`, mapped to their token replacements.

### Core/UI — FoodCard.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 8` (VStack) | `AppSpacing.sm` |
| `spacing: 2` (VStacks) | `AppSpacing.xs` |
| `spacing: 16` (HStack macros) | `AppSpacing.md` |
| `.font(.headline)` | `AppTheme.typography.headline` |
| `.font(.caption)` | `AppTheme.typography.caption1` |
| `.font(.subheadline.bold())` | `AppTheme.typography.subhead` (+ `.bold()`) |
| `.font(.caption2.bold())` / `.font(.caption2)` | `AppTheme.typography.caption1` |
| `.foregroundStyle(.secondary)` | `AppTheme.colors.textSecondary` |
| `color: .blue` (MacroChip protein) | `AppTheme.colors.protein` |
| `color: .green` (MacroChip carbs) | `AppTheme.colors.carbs` |
| `color: .orange` (MacroChip fat) | `AppTheme.colors.fat` |
| `.padding(12)` | `.padding(AppTheme.spacing.sm + AppTheme.spacing.xs)` → use `AppSpacing.sm` (8) + explicit xs, or introduce `AppSpacing.smPlus`; simplest: `.padding(AppSpacing.sm)` for outer, keep internal tight spacing via xs |
| `.background(.background)` | `AppTheme.colors.surface` |
| `cornerRadius: 12` | `AppTheme.radius.md` |
| `.shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)` | `.appShadowSoft()` |

### Core/UI — CalorieRingView.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `var ringColor: Color = .orange` (default) | default → `AppColors.primary` |
| `isOverGoal ? .red : ringColor` | `isOverGoal ? AppColors.error : ringColor` |
| `.font(size < 100 ? .subheadline.bold() : .title2.bold())` | `size < 100 ? AppTypography.subhead.bold() : AppTypography.title2.bold()` |
| `.font(size < 100 ? .caption2 : .caption)` | `size < 100 ? AppTypography.caption1 : AppTypography.footnote` |
| `.foregroundStyle(.secondary)` | `AppColors.textSecondary` |
| `.foregroundStyle(isOverGoal ? .red : .primary)` | `isOverGoal ? AppColors.error : AppColors.textPrimary` |

### Core/UI — MacroProgressBar.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 4` (VStack) | `AppSpacing.xs` |
| `.font(.subheadline.weight(.medium))` | `AppTypography.subhead.weight(.medium)` |
| `.font(.caption)` | `AppTypography.caption1` |
| `.foregroundStyle(.secondary)` | `AppColors.textSecondary` |
| `var color: Color = .blue` (default) | default → `AppColors.protein` |

### Core/UI — MealItemRow.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 2` (both VStacks) | `AppSpacing.xs` |
| `.font(.headline)` | `AppTypography.headline` |
| `.font(.subheadline)` | `AppTypography.subhead` |
| `.font(.subheadline.bold())` | `AppTypography.subhead.bold()` |
| `.font(.caption2)` | `AppTypography.caption1` |
| `.foregroundStyle(.secondary)` | `AppColors.textSecondary` |

### Core/UI — CalendarRibbon.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 12` (HStack dates) | `AppSpacing.sm` + `AppSpacing.xs` = closest is `AppSpacing.sm` (8) or a new `AppSpacing.smMd`; use `AppSpacing.md` (16) is too large; **Decision**: keep `12` as a layout-specific value mapped to `AppSpacing.sm + AppSpacing.xs` expressed as `AppSpacing.xs * 3`. Actually simplest: treat 12 as not a standard token gap — use `AppSpacing.sm` (8) to maintain grid. **Final**: `AppSpacing.sm` |
| `.padding(.vertical, 8)` | `.padding(.vertical, AppSpacing.sm)` |
| `spacing: 4` (VStack in DateCell) | `AppSpacing.xs` |
| `.font(.caption2.weight(.medium))` | `AppTypography.caption1` |
| `.font(.headline)` | `AppTypography.headline` |
| `.foregroundStyle(.secondary)` / `.foregroundStyle(.primary)` | `AppColors.textSecondary` / `AppColors.textPrimary` |
| `cornerRadius: 12` (all three RoundedRectangle) | `AppRadius.md` |
| `Color.blue.gradient` (selected bg) | `AppColors.primary` (gradient variant acceptable if retained) |
| `Color.blue` (today stroke) | `AppColors.primary` |
| `Color(.secondarySystemBackground)` (default bg) | `AppColors.surface` |
| `Color(.systemBackground)` (ribbon bg) | `AppColors.background` |
| `lineWidth: 1` — acceptable raw value for border stroke |

### Core/UI — NutritionSummaryView.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 12` (outer VStack) | `AppSpacing.sm` |
| `spacing: 8` (macro VStack) | `AppSpacing.sm` |
| `.font(.title.bold())` | `AppTypography.title1.bold()` |
| `.font(.caption)` | `AppTypography.caption1` |
| `.foregroundStyle(.secondary)` | `AppColors.textSecondary` |
| `.padding(.vertical, 8)` | `.padding(.vertical, AppSpacing.sm)` |
| `color: .blue` → `MacroProgressBar(color:)` | `AppColors.protein` |
| `color: .green` | `AppColors.carbs` |
| `color: .orange` | `AppColors.fat` |

### Core/UI — NutritionMacroHeader.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 32` (HStack) | `AppSpacing.xl` |
| `spacing: 12` (VStack macros) | `AppSpacing.sm` |
| `spacing: 4` (macroRow VStack) | `AppSpacing.xs` |
| `.font(.caption.bold())` | `AppTypography.caption1.bold()` |
| `.font(.caption)` | `AppTypography.caption1` |
| `.foregroundStyle(.secondary)` | `AppColors.textSecondary` |
| `.padding()` | `.padding(AppSpacing.md)` |
| `Color(.secondarySystemBackground)` | `AppColors.surface` |
| `cornerRadius: 20` — closest token is `AppRadius.lg` (16); **Decision**: use `AppRadius.lg` |
| `color: .blue/.green/.orange` (macroRow tint) | `AppColors.protein/.carbs/.fat` |
| `ringColor: .orange` | default → `AppColors.primary` |
| `minWidth: 100` — layout-specific, acceptable raw value |

### Features — DashboardView.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `.padding(.vertical, 8)` (offline banner) | `.padding(.vertical, AppSpacing.sm)` |
| `EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)` | `EdgeInsets(top: AppSpacing.md, leading: AppSpacing.md, bottom: AppSpacing.md, trailing: AppSpacing.md)` |
| `Color(.systemBackground)` | `AppColors.background` |
| `Color.clear.frame(height: 80)` — layout/spacing constant, use `AppSpacing.xxl + AppSpacing.xl` = 48+32=80 → express as `AppSpacing.xxl + AppSpacing.xl` |
| `.font(.title2.bold())` (FAB icon) | `AppTypography.title2.bold()` |
| `.foregroundStyle(.white)` | `.white` — acceptable for on-primary text |
| `Color.blue` (FAB fill) | `AppColors.primary` |
| `.shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)` | `.appShadowSoft()` |
| `.padding(24)` (FAB) | `.padding(AppSpacing.lg)` |

### Features — SearchView.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 8` (searchBar HStack) | `AppSpacing.sm` |
| `.padding(10)` (search field inner) | no exact token; use `AppSpacing.sm` (8) ≈ closest |
| `.background(.quaternary)` (search bg) | `AppColors.surface` |
| `cornerRadius: 12` (search field) | `AppRadius.md` |
| `.padding(.vertical, 8)` | `.padding(.vertical, AppSpacing.sm)` |
| `spacing: 0` (LazyVStack) — intentional layout |
| `.padding(.horizontal, 16)` (autocomplete row) | `.padding(.horizontal, AppSpacing.md)` |
| `.padding(.vertical, 12)` (autocomplete row) | `.padding(.vertical, AppSpacing.sm)` |
| `.padding(.leading, 16)` (Divider) | `.padding(.leading, AppSpacing.md)` |
| `.background(.regularMaterial)` (autocomplete) | `AppColors.surfaceElevated` |
| `cornerRadius: 12` (autocomplete) | `AppRadius.md` |
| `.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)` | `.appShadowSoft()` |
| `.padding(.top, 4)` | `.padding(.top, AppSpacing.xs)` |
| `spacing: 8` (recentSearches VStack) | `AppSpacing.sm` |
| `.font(.subheadline.bold())` | `AppTypography.subhead.bold()` |
| `.foregroundStyle(.secondary)` | `AppColors.textSecondary` |
| `.padding(.top, 16)` | `.padding(.top, AppSpacing.md)` |
| `.padding(.vertical, 8)` | `.padding(.vertical, AppSpacing.sm)` |
| `spacing: 12` (resultsSection VStack) | `AppSpacing.sm` |
| `.font(.subheadline)` | `AppTypography.subhead` |
| `.padding(.top, 8)` | `.padding(.top, AppSpacing.sm)` |
| `spacing: 16` (emptyState VStack) | `AppSpacing.md` |
| `.padding(.top, 40)` | `.padding(.top, AppSpacing.xl + AppSpacing.sm)` → use `AppSpacing.xl` (32) as closest |
| `.font(.caption)` (autocomplete type label) | `AppTypography.caption1` |

### Features — FoodDetailView.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `spacing: 24` (outer VStack) | `AppSpacing.lg` |
| `spacing: 8` (header VStack) | `AppSpacing.sm` |
| `spacing: 4` (FoodDetailSection inner VStacks) | `AppSpacing.xs` |
| `.font(.largeTitle.bold())` | `AppTypography.largeTitle.bold()` |
| `.font(.headline)` | `AppTypography.headline` |
| `.font(.caption)` | `AppTypography.caption1` |
| `.font(.subheadline)` | `AppTypography.subhead` |
| `.foregroundStyle(.secondary)` | `AppColors.textSecondary` |
| `.font(.headline)` (Add to Meal btn) | `AppTypography.headline` |
| `Color.blue` (Add to Meal enabled) | `AppColors.primary` |
| `Color.gray` (Add to Meal disabled) | `AppColors.textSecondary` (or `AppColors.separator`) |
| `cornerRadius: 15` | `AppRadius.lg` (16) |
| `.padding()` (button) | `.padding(AppSpacing.md)` |

### Features — MealLogView.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `cornerRadius: 12` (saving overlay) | `AppRadius.md` |
| `.background(.ultraThinMaterial)` (saving overlay) | `AppColors.surfaceElevated` |
| `.padding()` (saving overlay) | `.padding(AppSpacing.md)` |

### Features — HistoryView.swift

| Hardcoded | Replacement |
|-----------|-------------|
| `EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)` | `EdgeInsets(top: AppSpacing.sm, leading: 0, bottom: AppSpacing.sm, trailing: 0)` |

---

## 2. Component Reconciliation Map

| Core/UI Component | Overlapping Core/DesignTokens Component | Strategy |
|---|---|---|
| `MacroProgressBar` (current/goal API) | `MacroProgressBar` (value/color/label API) | Keep both; each independently token-aware; add cross-reference comment |
| `CalorieRingView` | `CircularProgressView` | Different APIs (CalorieRingView has labels+size param; CircularProgressView is minimal); keep both, both token-aware |
| `FoodCard` | `Card` (generic wrapper) | `FoodCard` uses `Card`-like layout but has food-specific content; `FoodCard` should adopt `Card` as its background container OR replicate token usage from `Card` directly; **Decision**: `FoodCard` adopts token values consistent with `Card` (surface bg, `radius.lg`, `appShadowSoft`) without wrapping in `Card` (avoids double-padding) |
| `MealItemRow` | `ListItemRow` (generic HStack wrapper) | `MealItemRow` has specific content layout; should be updated to use same token values as `ListItemRow` without delegation (avoids layout conflict) |
| No direct overlap | `Chip`, `PrimaryButton`, `SecondaryButton` | Already token-aware; verify no call sites in feature screens bypass them |

---

## 3. Token Gap Analysis

### Missing tokens (no exact match):
- **12pt spacing**: Constitution grid allows 4, 8, 12, 16, 24, 32 — `AppSpacing` is missing `12`. The constitution specifies `12` as a valid grid step. **Decision**: Add `AppSpacing.smMd: CGFloat = 12` to `AppSpacing`. All `spacing: 12` / `padding(12)` / `cornerRadius: 12` occurrences that are layout-spacing map to this; corner-radius `12` maps to `AppRadius.md` (already 12).
- **80pt FAB clearance**: `AppSpacing.xxl (48) + AppSpacing.xl (32) = 80` — express inline as compound token reference, or as `AppSpacing.xxl + AppSpacing.xl`.
- **`cornerRadius: 20`** in NutritionMacroHeader: No token for 20. Closest is `AppRadius.lg` (16). **Decision**: Use `AppRadius.lg` — minor visual delta acceptable for consistency.
- **`cornerRadius: 15`** in FoodDetailView button: No token. Closest is `AppRadius.lg` (16). **Decision**: Use `AppRadius.lg`.

### New token to add:
- `AppSpacing.smMd: CGFloat = 12` — fills the constitution-defined grid step missing from the existing enum.

---

## 4. Decisions Summary

| Decision | Rationale |
|---|---|
| Add `AppSpacing.smMd = 12` | Constitution's 4pt grid lists 12 as a valid increment; currently missing from `AppSpacing` |
| `cornerRadius: 20` → `AppRadius.lg (16)` | No 20pt token; `lg` is closest; 4pt delta acceptable |
| `cornerRadius: 15` → `AppRadius.lg (16)` | Same rationale |
| `Color(.secondarySystemBackground)` → `AppColors.surface` | Semantic equivalence; surface is the elevated neutral tone |
| `Color(.systemBackground)` → `AppColors.background` | Direct semantic mapping |
| `.quaternary` → `AppColors.surface` | Closest neutral surface token |
| `.regularMaterial` → `AppColors.surfaceElevated` | Material overlays map to elevated surface |
| `.ultraThinMaterial` → `AppColors.surfaceElevated` | Same rationale |
| Keep both `MacroProgressBar` components | Serve different call sites; no call-site migration required |
| `FoodCard` tokens from `Card` without wrapping | Avoids double-padding; replicates `Card`'s token choices directly |
| `MealItemRow` tokens from `ListItemRow` without delegation | Same layout logic; different content layout prevents clean wrapper reuse |
| `spacing: 12` in CalendarRibbon date HStack | Constitution grid includes 12; maps to new `AppSpacing.smMd` |

---

## 5. Files Requiring Changes

### Core/DesignTokens (token source — add one token only):
- `AppSpacing.swift` — add `smMd: CGFloat = 12`

### Core/UI (11 components):
1. `FoodCard.swift` — colours, spacing, radius, shadow, macro chip colours
2. `CalorieRingView.swift` — default colour, error colour, text styles
3. `MacroProgressBar.swift` — spacing, font styles, default colour
4. `MealItemRow.swift` — font styles, spacing, secondary colour
5. `CalendarRibbon.swift` — colours, spacing, radius
6. `NutritionSummaryView.swift` — spacing, font styles, macro colours
7. `NutritionMacroHeader.swift` — spacing, colours, radius, macro colours
8. `ErrorBanner.swift` — verify (likely already clean or minimal)
9. `FoodDetailSection.swift` — verify
10. `MicronutrientListView.swift` — verify
11. `SortMenuView.swift` — verify

### Features (5 screens):
1. `DashboardView.swift` — FAB colour/shadow/padding, offline banner padding, systemBackground
2. `SearchView.swift` — search bar bg/radius, autocomplete overlay bg/shadow/radius, font styles, spacing
3. `FoodDetailView.swift` — button colour/radius, spacing, font styles
4. `MealLogView.swift` — saving overlay radius/bg/padding
5. `HistoryView.swift` — listRowInsets spacing

### Core/DesignTokens (demo update — minimal):
- `DesignSystemDemoView.swift` — add `MacroProgressBar` (Core/DesignTokens version) showcase row and `CircularProgressView` if not present
