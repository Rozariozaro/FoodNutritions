import Foundation
import Observation

@Observable
@MainActor
final class HistoryProcessor {
    var state = HistoryState()
    private let mealRepository: MealRepositoryProtocol
    
    init(mealRepository: MealRepositoryProtocol) {
        self.mealRepository = mealRepository
    }
    
    func send(_ intent: HistoryIntent) {
        switch intent {
        case .loadDates:
            Task { await loadDates() }
        case .selectDate(let date):
            Task { await selectDate(date) }
        case .refresh:
            Task {
                await loadDates()
                await selectDate(state.selectedDate)
            }
        case .dismissError:
            state.errorMessage = nil
        }
    }
    
    private func loadDates() async {
        state.isLoading = true
        state.errorMessage = nil
        do {
            let dates = try await mealRepository.fetchAllMealDates()
            state.availableDates = dates
            
            // If current selected date is not in available dates and available dates is not empty,
            // default to the most recent date.
            let today = Calendar.current.startOfDay(for: Date())
            if !dates.contains(today) && !dates.isEmpty && state.availableDates.isEmpty {
                await selectDate(dates.first ?? today)
            } else if dates.contains(today) && state.meals.isEmpty {
                 await selectDate(today)
            }
        } catch {
            state.errorMessage = "Failed to load history dates: \(error.localizedDescription)"
        }
        state.isLoading = false
    }
    
    private func selectDate(_ date: Date) async {
        state.selectedDate = Calendar.current.startOfDay(for: date)
        state.isLoading = true
        state.errorMessage = nil
        do {
            state.meals = try await mealRepository.fetchMeals(for: state.selectedDate)
        } catch {
            state.errorMessage = "Failed to load meals for \(date.formatted(date: .abbreviated, time: .omitted))"
        }
        state.isLoading = false
    }
}
