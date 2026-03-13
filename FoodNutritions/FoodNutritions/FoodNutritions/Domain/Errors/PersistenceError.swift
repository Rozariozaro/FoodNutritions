import Foundation

enum PersistenceError: Error {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case recordNotFound(id: UUID)
    case deleteFailed(underlying: Error)
}
