import Foundation

enum JsonPlaceholderAPIEndpoint: APIEndpoint {
    case posts(page: Int, limit: Int)
    
    var path: String {
        switch self {
        case .posts:
            return "/posts"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .posts(let page, let limit):
            return [
                URLQueryItem(name: "_page", value: "\(page)"),
                URLQueryItem(name: "_limit", value: "\(limit)")
            ]
        }
    }
}
