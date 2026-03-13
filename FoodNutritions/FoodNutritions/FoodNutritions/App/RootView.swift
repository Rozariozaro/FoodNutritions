import SwiftUI

enum AppRoute: Hashable {
    case search
    case foodDetail(FoodItem)
    case mealLog
    case editMeal(MealRecord)
    case history
}

struct RootView: View {
    @State private var navigationPath = NavigationPath()
    
    // Shared repositories
    private let foodRepository = FoodRepository(client: FoodAPIClient())
    private let recentSearchRepository = UserDefaultsRecentSearchRepository()
    
    // Infrastructure
    private let networkMonitor = NetworkMonitor()
    
    // Processors
    @State private var dashboardProcessor: DashboardProcessor
    @State private var mealLogProcessor: MealLogProcessor
    @State private var historyProcessor: HistoryProcessor
    
    init() {
        let mealRepo = SwiftDataMealRepository(context: FoodNutritionsApp.sharedContext)
        let foodRepo = FoodRepository(client: FoodAPIClient())
        
        let networkMonitor = NetworkMonitor()
        _dashboardProcessor = State(initialValue: DashboardProcessor(mealRepository: mealRepo, networkMonitor: networkMonitor))
        _mealLogProcessor = State(initialValue: MealLogProcessor(state: MealLogState(), mealRepository: mealRepo, foodRepository: foodRepo))
        _historyProcessor = State(initialValue: HistoryProcessor(mealRepository: mealRepo))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView {
                DashboardView(
                    processor: dashboardProcessor,
                    onSearchRequested: {
                        navigationPath.append(AppRoute.search)
                    },
                    onMealSelected: { meal in
                        navigationPath.append(AppRoute.editMeal(meal))
                    }
                )
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

                HistoryView(
                    processor: historyProcessor,
                    onMealSelected: { meal in
                        navigationPath.append(AppRoute.editMeal(meal))
                    }
                )
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .search:
                    SearchView(
                        processor: SearchProcessor(
                            foodRepository: foodRepository,
                            recentSearchRepository: recentSearchRepository,
                            networkMonitor: networkMonitor
                        ),
                        onFoodSelected: { food in
                            navigationPath.append(AppRoute.foodDetail(food))
                        }
                    )
                case .foodDetail(let food):
                    FoodDetailView(
                        processor: FoodDetailProcessor(
                            state: FoodDetailState(foodItem: food),
                            foodRepository: foodRepository
                        ),
                        onItemAdded: { item in
                            mealLogProcessor.send(.addItem(item))
                            navigationPath.append(AppRoute.mealLog)
                        }
                    )
                case .mealLog:
                    MealLogView(processor: mealLogProcessor)
                case .editMeal(let meal):
                    {
                        mealLogProcessor.send(.loadMealForEditing(meal))
                        return MealLogView(processor: mealLogProcessor)
                    }()
                case .history:
                    EmptyView()
                }
            }
        }
    }
}
