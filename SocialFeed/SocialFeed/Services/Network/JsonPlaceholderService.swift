import Foundation

protocol APIServiceType {
    func fetchPosts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[PostDTO], NetworkError>) -> Void
    )
}

final class JsonPlaceholderService {
    
    // MARK: Private Properties
    
    private let networkClient: NetworkClient
    
    // MARK: Init
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
}

// MARK: APIServiceType

extension JsonPlaceholderService: APIServiceType {
    func fetchPosts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[PostDTO], NetworkError>) -> Void
    ) {
        request(
            JsonPlaceholderAPIEndpoint.posts(page: page, limit: limit),
            completion: completion
        )
    }
}

// MARK: - Private Methods

private extension JsonPlaceholderService {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = createURL(for: endpoint) else {
            completion(.failure(.unableToComplete))
            return
        }
        let request = NetworkRequest(url: url)
        networkClient.sendRequest(request, completion: completion)
    }
    
    func createURL(for endpoint: APIEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = JsonPlaceholderAPI.scheme
        components.host = JsonPlaceholderAPI.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        return components.url
    }
}
