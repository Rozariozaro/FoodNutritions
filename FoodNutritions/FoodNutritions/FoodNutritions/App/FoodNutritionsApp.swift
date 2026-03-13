import SwiftUI
import SwiftData

@main
struct FoodNutritionsApp: App {
    private let container: ModelContainer = {
        try! ModelContainer(for: MealRecord.self, MealItem.self)
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
