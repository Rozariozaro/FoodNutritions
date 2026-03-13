import SwiftUI

enum AppRoute: Hashable {
    case foodDetail(FoodItem)
    case mealLog
    case editMeal(MealRecord)
    case history
}

struct RootView: View {
    @State private var navigationPath = NavigationPath()
    @State private var searchProcessor: SearchProcessor = {
        let client = FoodAPIClient()
        let repo = FoodRepository(client: client)
        return SearchProcessor(foodRepository: repo, recentSearchRepository: UserDefaultsRecentSearchRepository())
    }()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SearchView(
                processor: searchProcessor,
                onFoodSelected: { food in
                    navigationPath.append(AppRoute.foodDetail(food))
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .foodDetail(let food):
                    Text("FoodDetail: \(food.name)")
                case .mealLog:
                    Text("MealLog")
                case .editMeal(let meal):
                    Text("EditMeal: \(meal.mealType)")
                case .history:
                    Text("History")
                }
            }
        }
    }
}
