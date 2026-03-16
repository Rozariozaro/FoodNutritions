import Foundation
import Observation

@Observable
final class DashboardProcessor {
    private(set) var state: DashboardState
    private let mealRepository: MealRepositoryProtocol
    let networkMonitor: NetworkMonitor
    private var notificationTask: Task<Void, Never>?

    init(
        state: DashboardState = DashboardState(),
        mealRepository: MealRepositoryProtocol,
        networkMonitor: NetworkMonitor
    ) {
        self.state = state
        self.mealRepository = mealRepository
        self.networkMonitor = networkMonitor

        // FUNC-03: reload when any meal is saved (e.g. from MealLog)
        notificationTask = Task { @MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .mealDidSave) {
                self?.send(.loadData)
            }
        }
    }

    deinit {
        notificationTask?.cancel()
    }
    
    func send(_ intent: DashboardIntent) {
        switch intent {
        case .loadData:
            Task { @MainActor in await loadTodayData() }
        case .deleteMeal(let id):
            Task { @MainActor in await deleteMeal(id: id) }
        case .dismissError:
            state.errorMessage = nil
        case .navigateToSearch:
            state.navigateToSearch = true
        case .navigateToHistory:
            state.navigateToHistory = true
        case .navigateToEditMeal(let meal):
            state.mealToEdit = meal
        }
    }
    
    @MainActor
    private func loadTodayData() async {
        state.isLoading = true
        state.errorMessage = nil
        
        do {
            let meals = try await mealRepository.fetchMeals(for: Date())
            state.todayMeals = meals
            state.summary = DailySummary.from(meals: meals)
        } catch {
            state.errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
        }
        
        state.isLoading = false
    }
    
    @MainActor
    private func deleteMeal(id: UUID) async {
        do {
            try await mealRepository.deleteMeal(id: id)
            // Reload data after deletion
            await loadTodayData()
        } catch {
            state.errorMessage = "Failed to delete meal: \(error.localizedDescription)"
        }
    }
}
