import XCTest
@testable import FoodNutritions

final class MealLogProcessorTests: XCTestCase {
    var processor: MealLogProcessor!
    var mockMealRepo: MockMealRepository!
    var mockAPIClient: MockFoodAPIClient!
    var foodRepo: FoodRepository!
    
    @MainActor
    override func setUp() async throws {
        mockMealRepo = MockMealRepository()
        mockAPIClient = MockFoodAPIClient()
        foodRepo = FoodRepository(client: mockAPIClient)
        
        let state = MealLogState()
        processor = MealLogProcessor(
            state: state,
            mealRepository: mockMealRepo,
            foodRepository: foodRepo
        )
    }
    
    func testAddItemUpdatesTotals() {
        // Given
        let item = FoodItemFactory.makeMealItem(foodName: "Egg", calories: 100, protein: 10, carbs: 1, fat: 8)
        
        // When
        processor.send(.addItem(item))
        
        // Then
        XCTAssertEqual(processor.state.items.count, 1)
        XCTAssertEqual(processor.state.totals.calories, 100)
        XCTAssertEqual(processor.state.totals.protein, 10)
    }
    
    func testRemoveItemUpdatesTotals() {
        // Given
        let item1 = FoodItemFactory.makeMealItem(foodName: "Egg", calories: 100)
        let item2 = FoodItemFactory.makeMealItem(foodName: "Toast", calories: 150)
        processor.send(.addItem(item1))
        processor.send(.addItem(item2))
        
        // When
        processor.send(.removeItem(item1.id))
        
        // Then
        XCTAssertEqual(processor.state.items.count, 1)
        XCTAssertEqual(processor.state.totals.calories, 150)
    }
    
    @MainActor
    func testSaveMealSuccess() async {
        // Given
        let item = FoodItemFactory.makeMealItem(foodName: "Egg", calories: 100)
        processor.send(.addItem(item))
        processor.send(.mealTypeChanged(.breakfast))
        
        // When
        processor.send(.saveMeal)
        
        // Wait for async task
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(mockMealRepo.saveCallCount, 1)
        XCTAssertTrue(processor.state.shouldNavigateBack)
        XCTAssertEqual(processor.state.items.count, 0)
        XCTAssertEqual(processor.state.totals.calories, 0)
    }
    
    @MainActor
    func testSaveMealFailsWithNoItems() async {
        // When
        processor.send(.saveMeal)
        
        // Then
        XCTAssertEqual(mockMealRepo.saveCallCount, 0)
        XCTAssertNotNil(processor.state.errorMessage)
    }
}
