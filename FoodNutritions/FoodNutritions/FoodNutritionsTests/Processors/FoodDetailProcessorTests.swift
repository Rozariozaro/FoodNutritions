import XCTest
@testable import FoodNutritions

final class FoodDetailProcessorTests: XCTestCase {
    var processor: FoodDetailProcessor!
    var mockClient: MockFoodAPIClient!
    var repository: FoodRepository!
    var testFood: FoodItem!

    override func setUp() {
        super.setUp()
        mockClient = MockFoodAPIClient()
        repository = FoodRepository(client: mockClient)
        
        testFood = FoodItemFactory.makeFoodItem(
            id: 1,
            name: "Test Food",
            type: .recipe,
            caloriesPer100g: 100,
            proteinPer100g: 10,
            carbsPer100g: 20,
            fatPer100g: 5
        )
        // Override serving units for testing custom math
        testFood.servingUnits = [
            ServingUnit(name: "100g", gramEquivalent: 100),
            ServingUnit(name: "One Egg", gramEquivalent: 50)
        ]
        
        let state = FoodDetailState(foodItem: testFood)
        processor = FoodDetailProcessor(state: state, foodRepository: repository)
    }

    func testInitialNutritionPreview() {
        print("DEBUG: Calories: \(processor.state.nutritionContext.calories)")
        print("DEBUG: Protein: \(processor.state.nutritionContext.protein)")
        XCTAssertEqual(processor.state.nutritionContext.calories, 100, accuracy: 0.1)
        XCTAssertEqual(processor.state.nutritionContext.protein, 10, accuracy: 0.1)
        XCTAssertEqual(processor.state.nutritionContext.carbs, 20, accuracy: 0.1)
        XCTAssertEqual(processor.state.nutritionContext.fat, 5, accuracy: 0.1)
    }

    func testQuantityChangedUpdatesNutritionInstantly() {
        processor.send(.quantityChanged(200))
        
        XCTAssertEqual(processor.state.nutritionContext.calories, 200)
        XCTAssertEqual(processor.state.nutritionContext.protein, 20)
        XCTAssertEqual(processor.state.nutritionContext.carbs, 40)
        XCTAssertEqual(processor.state.nutritionContext.fat, 10)
        XCTAssertNil(processor.state.errorMessage)
    }

    func testServingUnitChangedUpdatesNutritionInstantly() {
        let oneEgg = testFood.servingUnits[1]
        processor.send(.servingUnitChanged(oneEgg))
        
        // Initial quantity for non-gram unit should be 1.0 (50g)
        XCTAssertEqual(processor.state.quantity, 1.0)
        XCTAssertEqual(processor.state.nutritionContext.calories, 50)
        XCTAssertEqual(processor.state.nutritionContext.protein, 5)
    }

    func testNegativeQuantityShowsErrorMessage() {
        processor.send(.quantityChanged(-10))
        
        XCTAssertNotNil(processor.state.errorMessage)
        XCTAssertEqual(processor.state.errorMessage, "Quantity must be greater than 0")
    }

    func testToggleMicronutrientsCallsAPIOnFirstToggle() async {
        mockClient.bulkNutritionResult = FoodItemFactory.makeNutritionResponse(
            itemId: 1,
            itemType: "recipe",
            name: "Test Food",
            grams: 100,
            calories: 100,
            protein: 10,
            carbs: 20,
            fat: 5,
            fiber: 2.5,
            sodiumMg: 150
        )
        
        processor.send(.toggleMicronutrients)
        
        // Wait for async task
        try? await Task.sleep(for: .milliseconds(100))
        
        XCTAssertEqual(mockClient.bulkNutritionCallCount, 1)
        XCTAssertEqual(processor.state.foodItem.micronutrients.count, 2)
        XCTAssertEqual(processor.state.foodItem.micronutrients.first?.name, "Fiber")
        XCTAssertEqual(processor.state.foodItem.micronutrients.first?.value, 2.5)
    }
}
