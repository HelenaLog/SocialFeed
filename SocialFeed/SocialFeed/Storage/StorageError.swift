import Foundation

enum StorageError: Error {
    case objectNotFound
    case fetchFailed
    case imageDataNotFound
    case databaseError(Error)
}

// MARK: - LocalizedError

extension StorageError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .objectNotFound:
            return "Requested data not found"
        case .fetchFailed:
            return "Failed to fetch data from storage"
        case .imageDataNotFound:
            return "Image data not found"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        }
    }
}
