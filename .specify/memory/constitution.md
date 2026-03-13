# Food Tracker iOS App --- Project Constitution

Version: 1.0\
Scope: Applies to all code, architecture, and specifications within this
repository.

------------------------------------------------------------------------

# 1. Core Principles

## 1.1 Architecture First

All implementation must follow a predefined architecture and
specification workflow.\
No feature should be implemented without:

1.  Specification
2.  Architecture alignment
3.  Task generation

Implementation must never bypass the specification layer.

## 1.2 Predictable State Management

The application must enforce **unidirectional data flow** using the
**MVI (Model‑View‑Intent)** architecture pattern.

State transitions must always be explicit, deterministic, and testable.

## 1.3 Offline‑First Behavior

User actions must never depend on network availability.

The system must: - Persist user actions locally - Recover gracefully
from network failures - Sync with backend services when connectivity is
restored

------------------------------------------------------------------------

# 2. Platform Constraints

## 2.1 Supported Platform

-   iOS 17+

## 2.2 Language

-   Swift 5.9+

## 2.3 UI Framework

-   SwiftUI only
-   UIKit usage is prohibited unless explicitly required for system
    APIs.

## 2.4 Concurrency Model

Only **Swift Concurrency** is allowed.

Permitted tools:

-   async / await
-   Task
-   TaskGroup
-   Actor isolation
-   MainActor

Prohibited:

-   Callback‑based networking
-   Completion handler pyramids
-   Third‑party concurrency frameworks

------------------------------------------------------------------------

# 3. Architectural Pattern

## 3.1 MVI Structure

Each feature must follow the following structure:

View\
State\
Intent\
Processor

### View

Responsible for:

-   Rendering UI from State
-   Dispatching Intents
-   No business logic

### State

Immutable struct representing UI state.

Example:

SearchState FoodDetailState DailySummaryState

Rules:

-   Must be immutable
-   Must represent the entire UI snapshot

### Intent

Enum describing user actions.

Examples:

updateQuery(String)\
addMealItem(FoodItem)\
deleteMeal(UUID)

### Processor

Responsible for:

-   Handling intents
-   Performing side effects
-   Updating state

Processors must:

-   Be testable
-   Be isolated from UI

------------------------------------------------------------------------

# 4. Layered Architecture

The project must follow strict layer boundaries.

## 4.1 Layers

App\
Core\
Domain\
Data\
Persistence\
Features

### App

Application entry point and navigation.

### Core

Shared utilities:

-   Theme
-   Constants
-   Extensions
-   Helpers

### Domain

Business models and rules.

Examples:

FoodItem\
NutritionProfile\
DailySummary

Domain must remain independent of:

-   UI
-   Networking
-   Persistence

### Data

Responsible for:

-   API integration
-   Data transformation
-   DTO models

### Persistence

Responsible for:

-   SwiftData storage
-   Local caching
-   Offline data recovery

### Features

UI modules implementing app functionality.

Each feature must be fully modular.

Example:

Features/Search\
Features/FoodDetail\
Features/Dashboard\
Features/History

------------------------------------------------------------------------

# 5. Networking Standards

Networking must use:

URLSession + async/await

Rules:

-   All API responses must conform to Codable
-   API layer must be isolated inside Data module
-   Networking must be abstracted through a service layer

Example:

FoodAPIClient

Responsibilities:

-   search foods
-   fetch autocomplete
-   fetch nutrition
-   fetch units

------------------------------------------------------------------------

# 6. Persistence Standards

Offline persistence must use **SwiftData**.

Primary models:

MealRecord\
MealItemRecord

Requirements:

-   Immediate local writes
-   Background syncing support
-   Data integrity validation

All SwiftData models must:

-   Include unique identifiers
-   Support migration strategy

------------------------------------------------------------------------

# 7. Feature Module Standards

Each feature must contain:

View\
State\
Intent\
Processor

Example structure:

Features/Search/

SearchView.swift\
SearchState.swift\
SearchIntent.swift\
SearchProcessor.swift

Rules:

-   Feature logic must not leak into other modules
-   Domain models must be reused instead of duplicated

------------------------------------------------------------------------

# 8. Navigation Rules

Navigation must use:

NavigationStack

Navigation must be:

-   declarative
-   state driven

Screens:

Dashboard\
Search\
Food Detail\
Meal History

------------------------------------------------------------------------

# 9. UI / UX Standards

## 9.1 Layout

All layouts must follow a **4pt grid system**.

Spacing increments:

4, 8, 12, 16, 24, 32

## 9.2 Components

Reusable UI components must be placed inside:

Core/UI

Examples:

MacroProgressBar\
NutritionDonutChart\
FoodCard

## 9.3 Animations

All transitions must support:

-   Smooth animations
-   Haptic feedback for state changes

------------------------------------------------------------------------

# 10. Error Handling

The system must gracefully handle:

Network failure\
API errors\
Empty search results\
Invalid user inputs

Requirements:

-   No crashes
-   Clear user feedback
-   Offline fallback

------------------------------------------------------------------------

# 11. Testing Requirements

Minimum coverage expectations:

Unit tests for:

State transitions\
Processor logic\
Networking layer\
Persistence layer

Testing frameworks:

XCTest

Mocking must be used for:

API responses

------------------------------------------------------------------------

# 12. Code Quality Rules

The following are mandatory:

-   SwiftLint compliance
-   Modular code structure
-   No business logic inside SwiftUI Views

Maximum file length guideline:

300 lines per file

Functions must remain small and readable.

------------------------------------------------------------------------

# 13. Performance Standards

The application must:

-   Maintain smooth scrolling
-   Avoid blocking the main thread
-   Minimize unnecessary state updates

Large operations must run in background tasks.

------------------------------------------------------------------------

# 14. Security

Sensitive data must never be stored unencrypted.

The application must avoid:

-   logging private data
-   exposing tokens

------------------------------------------------------------------------

# 15. Specification Workflow

All development must follow the Spec‑Driven workflow:

1.  Constitution
2.  Specification
3.  Architecture Plan
4.  Task Generation
5.  Implementation

No direct coding without specifications.

------------------------------------------------------------------------

# 16. Future Extensibility

The architecture must support:

-   Server sync for meals
-   Cloud backup
-   Advanced analytics
-   HealthKit integration

The design must remain modular to enable these extensions.

