import Foundation

enum NetworkError: Error {
    case invalidResponse
    case invalidDecode
    case unableToComplete
    case invalidData
}
