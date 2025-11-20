import Foundation

protocol APIEndpoint {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}
