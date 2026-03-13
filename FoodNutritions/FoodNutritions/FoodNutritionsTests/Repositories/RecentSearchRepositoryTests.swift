import XCTest
@testable import FoodNutritions

final class RecentSearchRepositoryTests: XCTestCase {
    var sut: UserDefaultsRecentSearchRepository!
    let testDefaults = UserDefaults(suiteName: "RecentSearchTests")!

    override func setUp() {
        super.setUp()
        testDefaults.removeObject(forKey: "recentSearchQueries")
        sut = UserDefaultsRecentSearchRepository()
    }

    override func tearDown() {
        testDefaults.removeObject(forKey: "recentSearchQueries")
        super.tearDown()
    }

    func test_loadRecentSearches_emptyInitially() {
        XCTAssertTrue(sut.loadRecentSearches().isEmpty)
    }

    func test_saveSearch_prependsToFront() {
        sut.saveSearch("apple")
        sut.saveSearch("banana")
        let results = sut.loadRecentSearches()
        XCTAssertEqual(results.first, "banana")
        XCTAssertEqual(results.last, "apple")
    }

    func test_saveSearch_deduplicates() {
        sut.saveSearch("apple")
        sut.saveSearch("banana")
        sut.saveSearch("apple")
        let results = sut.loadRecentSearches()
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first, "apple")
    }

    func test_saveSearch_capsAtFive() {
        for i in 1...7 {
            sut.saveSearch("query\(i)")
        }
        let results = sut.loadRecentSearches()
        XCTAssertEqual(results.count, 5)
        XCTAssertEqual(results.first, "query7")
        XCTAssertFalse(results.contains("query1"))
        XCTAssertFalse(results.contains("query2"))
    }

    func test_clearAll_removesAllEntries() {
        sut.saveSearch("apple")
        sut.saveSearch("banana")
        sut.clearAll()
        XCTAssertTrue(sut.loadRecentSearches().isEmpty)
    }

    func test_userDefaultsRoundTrip_persistsAcrossInstances() {
        sut.saveSearch("chicken")
        let sut2 = UserDefaultsRecentSearchRepository()
        XCTAssertEqual(sut2.loadRecentSearches().first, "chicken")
    }
}
