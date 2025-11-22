import Foundation

enum NetworkError: Error {
    case invalidResponse
    case invalidDecode
    case unableToComplete
    case invalidData
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response"
        case .invalidDecode: return "Failed to decode data"
        case .unableToComplete: return "Unable to complete request"
        case .invalidData: return "Invalid data received"
        }
    }
}
