import Foundation
import SwiftData

enum FoodNutritionsSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [MealRecord.self, MealItem.self] }
}

enum FoodNutritionsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [FoodNutritionsSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
