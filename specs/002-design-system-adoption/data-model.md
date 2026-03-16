# Data Model: Design System Adoption

**Feature**: `002-design-system-adoption`
**Date**: 2026-03-17

> This feature is a pure UI refactor — no new data models, persistence changes, or network contracts are introduced. The design token system is already defined as Swift enums and structs. This document records the token entity definitions and the one additive change required.

---

## Token Entities (existing, authoritative in `Core/DesignTokens/`)

### AppSpacing
Typed CGFloat constants defining the spacing scale.

| Token | Value | Grid Basis |
|-------|-------|-----------|
| `xs` | 4 | 4pt grid base |
| `sm` | 8 | 2× base |
| `smMd` *(new)* | 12 | 3× base — fills constitution-defined grid step |
| `md` | 16 | 4× base |
| `lg` | 24 | 6× base |
| `xl` | 32 | 8× base |
| `xxl` | 48 | 12× base |

**Change**: Add `public static let smMd: CGFloat = 12` to `AppSpacing`.

---

### AppRadius
Typed CGFloat constants for corner radii.

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8 | Small elements (progress bars) |
| `md` | 12 | Cards, inputs, overlays, chips |
| `lg` | 16 | Large cards, headers, buttons |
| `full` | 999 | Pills / fully-rounded |

No changes required.

---

### AppColors
Named `Color` constants backed by asset catalogue entries.

| Token | Semantic Role | Replaces |
|-------|--------------|---------|
| `background` | Page/screen background | `Color(.systemBackground)` |
| `surface` | Card/list row surface | `.background`, `Color(.secondarySystemBackground)`, `.quaternary` |
| `surfaceElevated` | Overlays, sheets, materials | `.regularMaterial`, `.ultraThinMaterial` |
| `primary` | Brand accent, interactive | `Color.blue`, `.blue` |
| `textPrimary` | Primary text | `.primary` |
| `textSecondary` | Secondary/caption text | `.secondary`, `Color.gray` |
| `protein` | Protein macro colour | `Color.blue` (macro context) |
| `carbs` | Carbs macro colour | `Color.green` |
| `fat` | Fat macro colour | `Color.orange` |
| `error` | Error/over-goal state | `Color.red`, `.red` |
| `separator` | Dividers, track fills | — |
| `accentLowContrast` | Subtle accents | — |

No new tokens required. System colour mapping is documented in research.md.

---

### AppTypography
Named `Font` constants.

| Token | Value | Replaces |
|-------|-------|---------|
| `largeTitle` | system 34 bold | `.font(.largeTitle.bold())` |
| `title1` | system 28 bold | `.font(.title.bold())` |
| `title2` | system 22 semibold | `.font(.title2.bold())` |
| `headline` | system 17 semibold | `.font(.headline)` |
| `body` | system 17 regular | `.font(.body)` |
| `subhead` | system 15 regular | `.font(.subheadline)` |
| `footnote` | system 13 regular | — |
| `caption1` | system 12 medium | `.font(.caption)`, `.font(.caption2)` |

No changes required. Bold/weight modifiers chain onto these tokens (e.g., `AppTypography.subhead.bold()`).

---

### AppRadius / AppShadows / AppTheme
No changes required to these files.

---

## Component Entities (no data model changes)

The refactor touches only the styling layer of existing `View` structs. No new `@Model`, `@Observable`, state struct, or intent enum is introduced. Public API signatures of all components are preserved.

### One-line delta summary per component group:

**Core/UI** — 11 components gain `AppTheme.*` token references in place of raw literals; default `Color` parameters updated to token defaults.

**Features** — 5 screens replace inline styling with token references; no layout logic changes.

**Core/DesignTokens** — `AppSpacing` gains `smMd`; `DesignSystemDemoView` gains minimal showcase rows for any newly token-aware components not yet displayed.
