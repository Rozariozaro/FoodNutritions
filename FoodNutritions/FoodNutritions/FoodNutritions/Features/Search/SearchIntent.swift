import Foundation

enum SearchIntent {
    case queryChanged(String)
    case filterChanged(SearchFilters)
    case sortChanged(SearchState.SortOption)
    case selectFood(FoodItem)
    case clearFilters
    case loadRecentSearches
}
