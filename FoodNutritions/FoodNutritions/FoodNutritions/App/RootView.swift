import SwiftUI

enum AppRoute: Hashable {
    case search
    case foodDetail(FoodItem)
    case mealLog
}

struct RootView: View {
    // Per-tab navigation paths
    @State private var dashboardPath = NavigationPath()
    @State private var historyPath   = NavigationPath()

    // Processors
    @State private var dashboardProcessor: DashboardProcessor
    @State private var historyProcessor: HistoryProcessor
    @State private var mealLogProcessor: MealLogProcessor

    // Shared repos
    private let mealRepository: SwiftDataMealRepository
    private let foodRepository: FoodRepository
    private let recentSearchRepository: UserDefaultsRecentSearchRepository
    private let networkMonitor: NetworkMonitor

    init() {
        let mealRepo        = SwiftDataMealRepository(context: FoodNutritionsApp.sharedContext)
        let foodRepo        = FoodRepository(client: FoodAPIClient())
        let monitor         = NetworkMonitor()
        let recentSearchRepo = UserDefaultsRecentSearchRepository()

        mealRepository        = mealRepo
        foodRepository        = foodRepo
        recentSearchRepository = recentSearchRepo
        networkMonitor        = monitor

        _dashboardProcessor = State(initialValue: DashboardProcessor(mealRepository: mealRepo, networkMonitor: monitor))
        _historyProcessor   = State(initialValue: HistoryProcessor(mealRepository: mealRepo))
        _mealLogProcessor   = State(initialValue: MealLogProcessor(
            state: MealLogState(),
            mealRepository: mealRepo,
            foodRepository: foodRepo
        ))
    }

    var body: some View {
        TabView {
            // MARK: - Dashboard Tab
            NavigationStack(path: $dashboardPath) {
                DashboardView(
                    processor: dashboardProcessor,
                    onSearchRequested: {
                        // NAV-03: reset processor for a fresh meal before pushing
                        mealLogProcessor.send(.resetForNewMeal)
                        dashboardPath.append(AppRoute.search)
                    },
                    onMealSelected: { meal in
                        mealLogProcessor.send(.loadMealForEditing(meal))
                        dashboardPath.append(AppRoute.mealLog)
                    }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    dashboardDestination(route: route, path: $dashboardPath)
                }
            }
            .tabItem { Label("Dashboard", systemImage: "house.fill") }

            // MARK: - History Tab
            NavigationStack(path: $historyPath) {
                HistoryView(
                    processor: historyProcessor,
                    onMealSelected: { meal in
                        mealLogProcessor.send(.loadMealForEditing(meal))
                        historyPath.append(AppRoute.mealLog)
                    }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    historyDestination(route: route, path: $historyPath)
                }
            }
            .tabItem { Label("History", systemImage: "clock.fill") }
        }
    }

    // MARK: - Dashboard destinations

    @ViewBuilder
    private func dashboardDestination(route: AppRoute, path: Binding<NavigationPath>) -> some View {
        switch route {
        case .search:
            SearchView(
                processor: SearchProcessor(
                    foodRepository: foodRepository,
                    recentSearchRepository: recentSearchRepository,
                    networkMonitor: networkMonitor
                ),
                onFoodSelected: { food in
                    path.wrappedValue.append(AppRoute.foodDetail(food))
                }
            )
        case .foodDetail(let food):
            FoodDetailView(
                processor: FoodDetailProcessor(
                    state: FoodDetailState(foodItem: food),
                    foodRepository: foodRepository
                ),
                onItemAdded: { item in
                    // NAV-05: add item then pop FoodDetail, push MealLog
                    mealLogProcessor.send(.addItem(item))
                    path.wrappedValue.removeLast()          // pop .foodDetail
                    path.wrappedValue.append(AppRoute.mealLog)
                }
            )
        case .mealLog:
            MealLogView(
                processor: mealLogProcessor,
                onAddFoodRequested: {
                    // FUNC-01: allow adding more food while in MealLog
                    path.wrappedValue.append(AppRoute.search)
                }
            )
        }
    }

    // MARK: - History destinations

    @ViewBuilder
    private func historyDestination(route: AppRoute, path: Binding<NavigationPath>) -> some View {
        switch route {
        case .search:
            SearchView(
                processor: SearchProcessor(
                    foodRepository: foodRepository,
                    recentSearchRepository: recentSearchRepository,
                    networkMonitor: networkMonitor
                ),
                onFoodSelected: { food in
                    path.wrappedValue.append(AppRoute.foodDetail(food))
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
                    path.wrappedValue.removeLast()
                    path.wrappedValue.append(AppRoute.mealLog)
                }
            )
        case .mealLog:
            MealLogView(
                processor: mealLogProcessor,
                onAddFoodRequested: {
                    path.wrappedValue.append(AppRoute.search)
                }
            )
        }
    }
}
