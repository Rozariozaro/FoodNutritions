import Foundation

struct DailySummary {
    let date: Date
    let meals: [MealRecord]

    var totalCalories: Double { meals.flatMap(\.items).reduce(0) { $0 + $1.calories } }
    var totalProtein:  Double { meals.flatMap(\.items).reduce(0) { $0 + $1.protein } }
    var totalCarbs:    Double { meals.flatMap(\.items).reduce(0) { $0 + $1.carbs } }
    var totalFat:      Double { meals.flatMap(\.items).reduce(0) { $0 + $1.fat } }
}
