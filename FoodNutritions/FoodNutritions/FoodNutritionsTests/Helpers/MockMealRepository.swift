import Foundation
@testable import FoodNutritions

final class MockMealRepository: MealRepositoryProtocol {
    var meals: [MealRecord] = []
    var errorToThrow: Error?

    var saveCallCount = 0
    var deleteCallCount = 0
    var updateCallCount = 0

    func saveMeal(_ meal: MealRecord) async throws {
        saveCallCount += 1
        if let error = errorToThrow { throw error }
        meals.append(meal)
    }

    func fetchMeals(for date: Date) async throws -> [MealRecord] {
        if let error = errorToThrow { throw error }
        return meals.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func fetchAllMealDates() async throws -> [Date] {
        if let error = errorToThrow { throw error }
        let dates = Set(meals.map { Calendar.current.startOfDay(for: $0.date) })
        return Array(dates).sorted(by: >)
    }

    func fetchMeal(id: UUID) async throws -> MealRecord? {
        if let error = errorToThrow { throw error }
        return meals.first { $0.id == id }
    }

    func updateMeal(_ meal: MealRecord) async throws {
        updateCallCount += 1
        if let error = errorToThrow { throw error }
        meal.updatedAt = Date()
    }

    func deleteMeal(id: UUID) async throws {
        deleteCallCount += 1
        if let error = errorToThrow { throw error }
        meals.removeAll { $0.id == id }
    }
}
