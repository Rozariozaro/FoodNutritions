import SwiftUI
import SwiftData

@main
struct FoodNutritionsApp: App {
    static let container: ModelContainer = {
        try! ModelContainer(for: MealRecord.self, MealItem.self)
    }()
    
    @MainActor
    static var sharedContext: ModelContext {
        container.mainContext
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(Self.container)
    }
}
