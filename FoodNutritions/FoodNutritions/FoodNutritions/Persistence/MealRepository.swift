import Foundation
import SwiftData

protocol MealRepositoryProtocol {
    func saveMeal(_ meal: MealRecord) async throws
    func fetchMeals(for date: Date) async throws -> [MealRecord]
    func fetchAllMealDates() async throws -> [Date]
    func fetchMeal(id: UUID) async throws -> MealRecord?
    func updateMeal(_ meal: MealRecord) async throws
    func deleteMeal(id: UUID) async throws
}

@MainActor
final class SwiftDataMealRepository: MealRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func saveMeal(_ meal: MealRecord) async throws {
        do {
            context.insert(meal)
            try context.save()
        } catch {
            throw PersistenceError.saveFailed(underlying: error)
        }
    }

    func fetchMeals(for date: Date) async throws -> [MealRecord] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return []
        }
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate { $0.date >= start && $0.date < end },
            sortBy: [SortDescriptor(\.date)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw PersistenceError.fetchFailed(underlying: error)
        }
    }

    func fetchAllMealDates() async throws -> [Date] {
        let descriptor = FetchDescriptor<MealRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            let allMeals = try context.fetch(descriptor)
            let dates = Set(allMeals.map { Calendar.current.startOfDay(for: $0.date) })
            return Array(dates).sorted(by: >)
        } catch {
            throw PersistenceError.fetchFailed(underlying: error)
        }
    }

    func fetchMeal(id: UUID) async throws -> MealRecord? {
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate { $0.id == id }
        )
        do {
            return try context.fetch(descriptor).first
        } catch {
            throw PersistenceError.fetchFailed(underlying: error)
        }
    }

    func updateMeal(_ meal: MealRecord) async throws {
        do {
            meal.updatedAt = Date()
            try context.save()
        } catch {
            throw PersistenceError.saveFailed(underlying: error)
        }
    }

    func deleteMeal(id: UUID) async throws {
        guard let meal = try await fetchMeal(id: id) else {
            throw PersistenceError.recordNotFound(id: id)
        }
        do {
            context.delete(meal)
            try context.save()
        } catch {
            throw PersistenceError.deleteFailed(underlying: error)
        }
    }
}
