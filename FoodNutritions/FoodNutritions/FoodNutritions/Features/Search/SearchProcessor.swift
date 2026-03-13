import Foundation
import Observation

@Observable
final class SearchProcessor {
    private(set) var state = SearchState()

    private let foodRepository: FoodRepository
    private let recentSearchRepository: RecentSearchRepositoryProtocol
    private var debounceTask: Task<Void, Never>?

    init(foodRepository: FoodRepository, recentSearchRepository: RecentSearchRepositoryProtocol) {
        self.foodRepository = foodRepository
        self.recentSearchRepository = recentSearchRepository
    }

    func send(_ intent: SearchIntent) {
        switch intent {
        case .queryChanged(let query):
            state.query = query
            state.errorMessage = nil
            debounceTask?.cancel()
            if query.isEmpty {
                state.autocompleteSuggestions = []
                state.searchResults = []
                return
            }
            debounceTask = Task {
                do {
                    try await Task.sleep(for: .milliseconds(300))
                    guard !Task.isCancelled else { return }
                    await fetchAutocomplete(query: query)
                } catch {}
            }

        case .filterChanged(let filters):
            state.filters = filters
            let currentResults = state.searchResults
            state.searchResults = applySort(to: currentResults, option: state.sortOption)

        case .sortChanged(let option):
            state.sortOption = option
            state.searchResults = applySort(to: state.searchResults, option: option)

        case .selectFood:
            break

        case .clearFilters:
            state.filters = SearchFilters()
            if !state.query.isEmpty {
                Task { await performSearch(query: state.query) }
            }

        case .loadRecentSearches:
            state.recentSearches = recentSearchRepository.loadRecentSearches()
        }
    }

    func submitSearch() {
        let query = state.query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        debounceTask?.cancel()
        Task { await performSearch(query: query) }
    }

    // MARK: - Private

    private func fetchAutocomplete(query: String) async {
        do {
            let suggestions = try await foodRepository.autocomplete(query: query)
            guard !Task.isCancelled else { return }
            state.autocompleteSuggestions = suggestions
        } catch {
            // autocomplete errors are silent
        }
    }

    private func performSearch(query: String) async {
        state.isLoading = true
        state.errorMessage = nil
        do {
            let results = try await foodRepository.searchFoods(query: query, filters: state.filters)
            state.searchResults = applySort(to: results, option: state.sortOption)
            state.autocompleteSuggestions = []
            recentSearchRepository.saveSearch(query)
            state.recentSearches = recentSearchRepository.loadRecentSearches()
        } catch FoodError.offlineNoCache {
            state.errorMessage = "You're offline and no cached results are available."
        } catch FoodError.networkUnavailable {
            state.errorMessage = "Network unavailable. Check your connection."
        } catch {
            state.errorMessage = error.localizedDescription
        }
        state.isLoading = false
    }

    private func applySort(to items: [FoodItem], option: SearchState.SortOption) -> [FoodItem] {
        switch option {
        case .relevance:
            return items
        case .name:
            return items.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .calories:
            return items.sorted { $0.caloriesPer100g < $1.caloriesPer100g }
        case .proteinDensity:
            return items.sorted { $0.proteinDensity > $1.proteinDensity }
        }
    }
}
