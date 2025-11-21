import Foundation

protocol PostServiceProtocol {
    func fetchPosts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[DisplayPost], Error>) -> Void
    )
}

final class PostService {
    
    // MARK: Private Properties
    
    private let networkService: APIServiceType
    private let storageService: StorageType
    private let networkMonitor: NetworkReachability
    
    // MARK: Init
    
    init(
        networkService: APIServiceType,
        storageService: StorageType,
        networkMonitor: NetworkReachability
    ) {
        self.networkService = networkService
        self.storageService = storageService
        self.networkMonitor = networkMonitor
    }
}

// MARK: PostServiceProtocol

extension PostService: PostServiceProtocol {
    func fetchPosts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[DisplayPost], Error>) -> Void
    ) {
        if networkMonitor.isConnected {
            loadFromNetwork(page: page, limit: limit, completion: completion)
        } else {
            loadFromStorage(completion: completion)
        }
    }
}

private extension PostService {
    func loadFromNetwork(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[DisplayPost], Error>) -> Void
    ) {
        networkService.fetchPosts(page: page, limit: limit) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let posts):
                let displayPosts = posts.map { DisplayPost(from: $0) }
                self.storageService.savePosts(displayPosts)
                completion(.success(displayPosts))
            case .failure(let error):
                self.loadFromStorage(completion: completion)
                print(error.localizedDescription)
            }
        }
    }
    
    func loadFromStorage(completion: @escaping (Result<[DisplayPost], Error>) -> Void) {
        storageService.fetchPosts { result in
            switch result {
            case .success(let posts):
                completion(.success(posts))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
