# Food Tracker iOS App - Technical Research Report

**Date:** 2026-03-13
**Branch:** 001-food-tracker-app

---

## 1. SwiftData Best Practices (iOS 17+)

### Decision
Use `@Model` classes with `@Relationship` for `MealRecord → [MealItem]`, `.cascade` delete rules, a single `ModelContainer` owned at the `App` level, and all mutations performed on `@MainActor`.

### Rationale
SwiftData's actor model pins `ModelContext` to the thread that created it. Using `@MainActor` throughout keeps UI updates and writes on the same actor, eliminating data-race crashes. Cascade deletes are declarative and prevent orphaned `MealItem` rows. A single `ModelContainer` shared via `.modelContainer(for:)` scene modifier ensures one SQLite store across the app.

### Alternatives Considered
- **Core Data** – More mature, but requires `NSManagedObjectContext`, `NSFetchRequest`, and substantial boilerplate. SwiftData compiles down to Core Data under the hood, so there is no raw-performance advantage in going back.
- **Background `ModelContext` for heavy writes** – Possible via `ModelContext(container)` off `@MainActor`, but requires manual `try context.save()` and careful actor isolation. Avoid unless bulk-importing large datasets.
- **CloudKit-backed container** – `ModelContainer(for: schema, configurations: [ModelConfiguration(cloudKitDatabase: .automatic)])` is available but adds complexity; defer to v2.

### Key Implementation Notes

**Model definition with cascade delete:**
```swift
@Model
final class MealRecord {
    var date: Date
    var mealType: String
    @Relationship(deleteRule: .cascade) var items: [MealItem] = []

    init(date: Date, mealType: String) {
        self.date = date
        self.mealType = mealType
    }
}

@Model
final class MealItem {
    var foodName: String
    var calories: Double
    var servingGrams: Double
    var meal: MealRecord?

    init(foodName: String, calories: Double, servingGrams: Double) {
        self.foodName = foodName
        self.calories = calories
        self.servingGrams = servingGrams
    }
}
```

**Container setup at App level:**
```swift
@main
struct FoodNutritionsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [MealRecord.self, MealItem.self])
    }
}
```

**Schema migration strategy:**
```swift
// Bump version enum when adding properties
enum FoodNutritionsSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [MealRecord.self, MealItem.self] }
}

enum FoodNutritionsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [FoodNutritionsSchemaV1.self] }
    static var stages: [MigrationStage] { [] } // lightweight migrations only for now
}
```

**Offline-first:** All writes go to the local SQLite store immediately; no network confirmation needed. Sync can be layered later via CloudKit.

---

## 2. MVI Pattern in SwiftUI (iOS 17+)

### Decision
Use `@Observable` (Swift 5.9 / iOS 17 Observation framework) for the Processor/ViewModel. Define `State` as a nested struct inside the Processor, and `Intent` as a nested enum. Views read `processor.state` directly; no `@Published` or `ObservableObject` required.

### Rationale
`@Observable` provides fine-grained dependency tracking — SwiftUI only re-renders the exact views that read changed properties, which is more efficient than `ObservableObject`+`@Published` where any change triggers a full view body evaluation. The MVI unidirectional flow (`View → Intent → Processor → State → View`) makes state mutations auditable and testable. iOS 17's `@Observable` is the idiomatic replacement for `ObservableObject`.

### Alternatives Considered
- **`ObservableObject` + `@StateObject`** – Fully supported pre-iOS 17; consider if targeting iOS 16. The `@Published` coarse-grained invalidation is its main drawback.
- **The Composable Architecture (TCA)** – Battle-tested Redux-style library. Adds a heavy dependency and learning curve; overkill for a solo/small-team app.
- **Pure MVVM with closures** – Simpler, but lacks intent auditing and makes unit testing mutations harder.

### Key Implementation Notes

**Processor with immutable State and Intent:**
```swift
@Observable
final class FoodSearchProcessor {

    // --- State (immutable snapshot) ---
    struct State {
        var query: String = ""
        var results: [FoodItem] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }

    // --- Intent ---
    enum Intent {
        case updateQuery(String)
        case search
        case selectFood(FoodItem)
        case clearResults
    }

    private(set) var state = State()

    // --- Process ---
    func send(_ intent: Intent) {
        switch intent {
        case .updateQuery(let q):
            state.query = q
        case .search:
            Task { await performSearch() }
        case .selectFood(let food):
            // navigate or log food
            break
        case .clearResults:
            state.results = []
        }
    }

    @MainActor
    private func performSearch() async {
        state.isLoading = true
        defer { state.isLoading = false }
        do {
            state.results = try await FoodAPIClient.search(query: state.query)
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
}
```

**View binding:**
```swift
struct FoodSearchView: View {
    @State private var processor = FoodSearchProcessor()

    var body: some View {
        VStack {
            TextField("Search food...", text: Binding(
                get: { processor.state.query },
                set: { processor.send(.updateQuery($0)) }
            ))
            if processor.state.isLoading {
                ProgressView()
            }
            List(processor.state.results) { food in
                Text(food.name)
                    .onTapGesture { processor.send(.selectFood(food)) }
            }
        }
    }
}
```

**Note:** Use `@State private var processor = FoodSearchProcessor()` (not `@StateObject`) because `@Observable` classes work with `@State` in iOS 17+.

---

## 3. Food Data API Options

### Decision
Use **USDA FoodData Central (FDC)** as the primary nutrition source for branded and SR Legacy foods, with **Open Food Facts (OFF)** as the fallback/barcode lookup layer.

### Rationale
FDC provides the highest nutrition data quality (USDA-verified) with a generous free tier (3,600 req/hour with a free API key). Its JSON responses map cleanly to `Codable` models. OFF excels at barcode scanning with 3M+ product database and is fully open/free (Creative Commons), making it ideal for packaged food lookup. Nutritionix and Edamam have better natural-language parsing but their free tiers are very limited (Nutritionix: 500 req/day; Edamam: 1,000 req/month on free plan).

### Alternatives Considered
- **Nutritionix** – Best natural-language food logging ("I ate 2 cups of rice"), 500 req/day free. Useful for v2 NLP feature.
- **Edamam** – Good branded food database, recipe analysis. Free tier (1,000 req/month) is too low for a search-heavy app.
- **Spoonacular** – Recipe-focused, not ideal for raw nutrition lookup.
- **CalorieNinjas** – Simple API, 10,000 req/month free, but smaller database and no serving-unit granularity.

### Key Implementation Notes

**USDA FDC search endpoint:**
```
GET https://api.nal.usda.gov/fdc/v1/foods/search
  ?query={term}
  &dataType=Branded,SR%20Legacy
  &pageSize=20
  &api_key={YOUR_KEY}
```

**Codable model for FDC:**
```swift
struct FDCSearchResponse: Codable {
    let foods: [FDCFood]
}

struct FDCFood: Codable, Identifiable {
    let fdcId: Int
    var id: Int { fdcId }
    let description: String
    let brandOwner: String?
    let servingSize: Double?
    let servingSizeUnit: String?
    let foodNutrients: [FDCNutrient]
}

struct FDCNutrient: Codable {
    let nutrientId: Int       // 1008 = Energy(kcal), 1003 = Protein, 1004 = Fat, 1005 = Carbs
    let nutrientName: String
    let value: Double?
    let unitName: String
}
```

**Open Food Facts barcode lookup:**
```
GET https://world.openfoodfacts.org/api/v2/product/{barcode}.json
```

**OFF Codable snippet:**
```swift
struct OFFProduct: Codable {
    let product: OFFProductDetail?
}
struct OFFProductDetail: Codable {
    let productName: String?
    let nutriments: OFFNutriments?
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case nutriments
    }
}
struct OFFNutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let fat100g: Double?
    let carbohydrates100g: Double?
    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case fat100g = "fat_100g"
        case carbohydrates100g = "carbohydrates_100g"
    }
}
```

---

## 4. Search Debouncing with Swift Async/Await

### Decision
Use **`Task` cancellation with `try await Task.sleep`** as the debounce mechanism. Store the debounce task in a property, cancel it on each new keystroke, and start a fresh one.

### Rationale
This is the idiomatic Swift Concurrency approach without importing Combine. It requires zero dependencies, works cleanly inside `@Observable` processors, and is straightforward to understand. `Task.sleep(for:)` with `.seconds(0.3)` plus `Task.checkCancellation()` gives precise control. `AsyncSequence`-based debounce operators exist but require a custom implementation or third-party package.

### Alternatives Considered
- **Combine `debounce(for:scheduler:)`** – Elegant but adds Combine dependency (though it ships with the OS). Mixing Combine with async/await requires `sink` + `async` bridge boilerplate.
- **Custom `AsyncSequence` debounce** – Possible via `AsyncStream` + `Task.sleep` inside `makeAsyncIterator`, but adds ~50 lines of infrastructure for no benefit over the simpler Task pattern.
- **`withTaskGroup` + `cancel()`** – Overcomplicated for this use case.

### Key Implementation Notes

**Debounce pattern inside an `@Observable` Processor:**
```swift
@Observable
final class FoodSearchProcessor {
    private(set) var results: [FoodItem] = []
    private(set) var isLoading = false
    private var debounceTask: Task<Void, Never>?

    func queryChanged(_ newQuery: String) {
        debounceTask?.cancel()
        guard !newQuery.isEmpty else {
            results = []
            return
        }
        debounceTask = Task {
            do {
                // 300ms debounce window
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()
                await performSearch(query: newQuery)
            } catch {
                // Task was cancelled — new keystroke arrived, do nothing
            }
        }
    }

    @MainActor
    private func performSearch(query: String) async {
        isLoading = true
        defer { isLoading = false }
        results = (try? await FoodAPIClient.search(query: query)) ?? []
    }
}
```

**Wiring to TextField in the View:**
```swift
TextField("Search...", text: $query)
    .onChange(of: query) { _, newValue in
        processor.queryChanged(newValue)
    }
```

**Key behaviour:** When a task is cancelled mid-sleep, `Task.sleep` throws `CancellationError`. The `catch` block silently discards it. Only the task that survives the full 300ms window proceeds to the network call.

---

## 5. SwiftUI Circular Progress & Macro Charts

### Decision
- **Calorie ring:** Custom `Shape` using `Path` + `trim` (not Swift Charts). Wrap in a reusable `CalorieRingView`.
- **Macro progress bars:** Native `ProgressView(value:total:)` with `.progressViewStyle(.linear)` plus a custom accent color — no custom shape needed.

### Rationale
Swift Charts (iOS 16+) is excellent for time-series and bar charts but is not designed for circular ring progress indicators; it requires awkward hacks. A 30-line custom `Shape` with `Circle().trim(from:to:)` and `strokeBorder` produces a pixel-perfect animated ring with full control over colors, line width, and gradient. For macro bars, native `ProgressView` handles the common case and respects Dynamic Type/accessibility; reach for a custom view only if the design calls for stacked/segmented bars.

### Alternatives Considered
- **Swift Charts `SectorMark`** – Suitable for pie charts, but not a single-arc progress ring. Requires iOS 17 and still needs custom overlay to show remaining arc differently from filled arc.
- **Third-party (e.g., `DSFSparkline`, `Charts` SPM)** – Adds dependency for something achievable natively in ~30 lines.
- **`Canvas` API** – More performant for many simultaneous rings (e.g., watchOS), but harder to animate and compose with SwiftUI layout.

### Key Implementation Notes

**Circular calorie ring:**
```swift
struct CalorieRingView: View {
    var consumed: Double
    var goal: Double
    var ringColor: Color = .orange
    var lineWidth: CGFloat = 18

    private var progress: Double {
        min(consumed / max(goal, 1), 1.0)
    }

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(ringColor.opacity(0.2), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            // Center label
            VStack(spacing: 2) {
                Text("\(Int(consumed))")
                    .font(.title2.bold())
                Text("/ \(Int(goal)) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(lineWidth / 2)
    }
}
```

**Macro progress bars:**
```swift
struct MacroProgressRow: View {
    var label: String
    var consumed: Double
    var goal: Double
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.subheadline.bold())
                Spacer()
                Text("\(Int(consumed))g / \(Int(goal))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: consumed, total: max(goal, 1))
                .tint(color)
                .progressViewStyle(.linear)
        }
    }
}

// Usage
MacroProgressRow(label: "Protein", consumed: 75, goal: 150, color: .blue)
MacroProgressRow(label: "Carbs",   consumed: 180, goal: 250, color: .yellow)
MacroProgressRow(label: "Fat",     consumed: 40,  goal: 65,  color: .red)
```

**Animating the ring on data change:** Wrap `consumed` in `withAnimation(.easeInOut)` at the call site or use `animation(_:value:)` modifier directly on the `trim` circle as shown above.

---

## Summary Table

| Topic | Chosen Approach | iOS Min |
|---|---|---|
| Persistence | SwiftData `@Model` + cascade | iOS 17 |
| Architecture | MVI with `@Observable` Processor | iOS 17 |
| Food Data API | USDA FDC (primary) + OFF (barcode) | N/A |
| Search Debounce | `Task` cancel + `Task.sleep(300ms)` | iOS 15 |
| Calorie Ring | Custom `Circle().trim` Shape | iOS 15 |
| Macro Bars | Native `ProgressView(.linear)` | iOS 14 |
