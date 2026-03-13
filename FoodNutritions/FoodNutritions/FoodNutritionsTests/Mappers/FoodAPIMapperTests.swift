import XCTest
@testable import FoodNutritions

final class FoodAPIMapperTests: XCTestCase {

    // MARK: - FoodSearchResult → FoodItem

    func test_foodItem_mapsAllFields() {
        let dto = FoodItemFactory.makeFoodSearchResult(
            id: 42, name: "Chilli Chicken", type: "recipe",
            calories100g: 198.83, protein100g: 9.57, carbs100g: 2.86,
            fat100g: 16.56, proteinDensity: 0.048
        )
        let item = FoodAPIMapper.foodItem(from: dto)
        XCTAssertEqual(item.id, 42)
        XCTAssertEqual(item.name, "Chilli Chicken")
        XCTAssertEqual(item.type, .recipe)
        XCTAssertEqual(item.caloriesPer100g, 198.83, accuracy: 0.001)
        XCTAssertEqual(item.proteinPer100g, 9.57, accuracy: 0.001)
        XCTAssertEqual(item.carbsPer100g, 2.86, accuracy: 0.001)
        XCTAssertEqual(item.fatPer100g, 16.56, accuracy: 0.001)
        XCTAssertEqual(item.proteinDensity, 0.048, accuracy: 0.0001)
        XCTAssertTrue(item.micronutrients.isEmpty)
    }

    func test_foodItem_unknownTypeFallsBackToRecipe() {
        let dto = FoodItemFactory.makeFoodSearchResult(type: "unknown_type")
        let item = FoodAPIMapper.foodItem(from: dto)
        XCTAssertEqual(item.type, .recipe)
    }

    func test_foodItem_packagedTypeMapping() {
        let dto = FoodItemFactory.makeFoodSearchResult(type: "packaged")
        let item = FoodAPIMapper.foodItem(from: dto)
        XCTAssertEqual(item.type, .packaged)
    }

    // MARK: - NutritionResponse → Micronutrient array

    func test_micronutrients_mapsFiberAndSodium() {
        let response = FoodItemFactory.makeNutritionResponse(fiber: 2.5, sodiumMg: 150)
        let micros = FoodAPIMapper.micronutrients(from: response)
        XCTAssertEqual(micros.count, 2)
        let fiber = micros.first { $0.name == "Fiber" }
        let sodium = micros.first { $0.name == "Sodium" }
        XCTAssertEqual(fiber!.value, 2.5, accuracy: 0.001)
        XCTAssertEqual(fiber!.unit, "g")
        XCTAssertEqual(sodium!.value, 150, accuracy: 0.001)
        XCTAssertEqual(sodium!.unit, "mg")
    }

    func test_micronutrients_nilFiberAndSodiumYieldsEmpty() {
        let response = FoodItemFactory.makeNutritionResponse(fiber: nil, sodiumMg: nil)
        let micros = FoodAPIMapper.micronutrients(from: response)
        XCTAssertTrue(micros.isEmpty)
    }

    func test_micronutrients_onlyFiber() {
        let response = FoodItemFactory.makeNutritionResponse(fiber: 3.0, sodiumMg: nil)
        let micros = FoodAPIMapper.micronutrients(from: response)
        XCTAssertEqual(micros.count, 1)
        XCTAssertEqual(micros.first?.name, "Fiber")
    }

    // MARK: - ServingUnit synthesis

    func test_synthesiseServingUnits_returnsCorrectFour() {
        let units = FoodAPIMapper.synthesiseServingUnits()
        XCTAssertEqual(units.count, 4)
        XCTAssertEqual(units[0].name, "100g")
        XCTAssertEqual(units[0].gramEquivalent, 100)
        XCTAssertEqual(units[1].name, "50g")
        XCTAssertEqual(units[1].gramEquivalent, 50)
        XCTAssertEqual(units[2].name, "200g")
        XCTAssertEqual(units[2].gramEquivalent, 200)
        XCTAssertEqual(units[3].name, "Custom")
        XCTAssertEqual(units[3].gramEquivalent, 0)
    }

    func test_foodItem_includesSynthesisedServingUnits() {
        let dto = FoodItemFactory.makeFoodSearchResult()
        let item = FoodAPIMapper.foodItem(from: dto)
        XCTAssertEqual(item.servingUnits.count, 4)
    }
}
