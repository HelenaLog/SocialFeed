import Foundation

enum StorageError: Error {
    case objectNotFound
    case fetchFailed
    case imageDataNotFound
    case databaseError(Error)
}
