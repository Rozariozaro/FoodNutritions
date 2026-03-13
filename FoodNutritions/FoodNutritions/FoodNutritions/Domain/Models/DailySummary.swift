import Foundation

struct DailySummary {
    // Per-contract fields
    let date: Date
    let meals: [MealRecord]

    // Stored macro totals (used when constructing from raw scalars, e.g. MealLogState running totals)
    private var _calories: Double
    private var _protein: Double
    private var _carbs: Double
    private var _fat: Double
    private var _fiber: Double?
    private var _sodiumMg: Double?

    // Computed totals: prefer summing from meals when available, fall back to stored scalars
    var totalCalories: Double { meals.isEmpty ? _calories : meals.flatMap(\.items).reduce(0) { $0 + $1.calories } }
    var totalProtein:  Double { meals.isEmpty ? _protein  : meals.flatMap(\.items).reduce(0) { $0 + $1.protein } }
    var totalCarbs:    Double { meals.isEmpty ? _carbs    : meals.flatMap(\.items).reduce(0) { $0 + $1.carbs } }
    var totalFat:      Double { meals.isEmpty ? _fat      : meals.flatMap(\.items).reduce(0) { $0 + $1.fat } }

    // Legacy scalar accessors kept for existing call sites (MealLogState, DashboardState, HistoryView)
    var calories: Double { totalCalories }
    var protein:  Double { totalProtein }
    var carbs:    Double { totalCarbs }
    var fat:      Double { totalFat }
    var fiber:    Double? { _fiber }
    var sodiumMg: Double? { _sodiumMg }

    // Scalar init — used by MealLogState running totals and DashboardState zero state
    init(calories: Double, protein: Double, carbs: Double, fat: Double,
         fiber: Double? = nil, sodiumMg: Double? = nil,
         date: Date = Date(), meals: [MealRecord] = []) {
        self.date = date
        self.meals = meals
        self._calories = calories
        self._protein = protein
        self._carbs = carbs
        self._fat = fat
        self._fiber = fiber
        self._sodiumMg = sodiumMg
    }

    // Contract init — primary constructor per data-model.md
    init(date: Date, meals: [MealRecord]) {
        self.date = date
        self.meals = meals
        self._calories = 0
        self._protein = 0
        self._carbs = 0
        self._fat = 0
        self._fiber = nil
        self._sodiumMg = nil
    }

    static func from(items: [MealItem]) -> DailySummary {
        DailySummary(
            calories: items.reduce(0) { $0 + $1.calories },
            protein: items.reduce(0) { $0 + $1.protein },
            carbs: items.reduce(0) { $0 + $1.carbs },
            fat: items.reduce(0) { $0 + $1.fat },
            fiber: items.reduce(0) { $0 + ($1.fiber ?? 0) },
            sodiumMg: items.reduce(0) { $0 + ($1.sodiumMg ?? 0) }
        )
    }

    static func from(meals: [MealRecord], date: Date = Date()) -> DailySummary {
        DailySummary(date: date, meals: meals)
    }
}
