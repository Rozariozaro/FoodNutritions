import Foundation
import SwiftData

@Model
final class MealRecord {
    @Attribute(.unique) var id: UUID = UUID()
    var date: Date
    var mealType: String
    var syncStatus: String = SyncStatus.pending.rawValue
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \MealItem.meal)
    var items: [MealItem] = []

    init(date: Date, mealType: MealType) {
        self.date = date
        self.mealType = mealType.rawValue
    }
}
