import Foundation

enum FoodError: Error {
    case networkUnavailable
    case offlineNoCache
    case invalidResponse
    case foodNotFound(itemId: Int)
    case validationError(message: String)
    case serverError(statusCode: Int)
}
