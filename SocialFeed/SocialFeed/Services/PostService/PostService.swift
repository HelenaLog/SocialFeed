import Foundation

protocol PostServiceType {
    func fetchPosts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[PostViewItem], Error>) -> Void
    )
    func toggleLike(for postId: Int)
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

extension PostService: PostServiceType {
    func fetchPosts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[PostViewItem], Error>) -> Void
    ) {
        if networkMonitor.isConnected {
            loadFromNetwork(page: page, limit: limit, completion: completion)
        } else {
            loadFromStorage(page: page, limit: limit, completion: completion)
        }
    }
    
    func toggleLike(for postId: Int) {
        storageService.toggleLike(for: postId)
    }
}

private extension PostService {
    func loadFromNetwork(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[PostViewItem], Error>) -> Void
    ) {
        networkService.fetchPosts(page: page, limit: limit) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let posts):
                let displayPosts = posts.map { PostViewItem(from: $0) }
                self.storageService.savePosts(displayPosts)
                completion(.success(displayPosts))
            case .failure(let error):
                self.loadFromStorage(page: page, limit: limit, completion: completion)
                print(error.localizedDescription)
            }
        }
    }
    
    func loadFromStorage(page: Int, limit: Int, completion: @escaping (Result<[PostViewItem], Error>) -> Void) {
        storageService.fetchPosts(page: page, limit: limit) { result in
            switch result {
            case .success(let posts):
                completion(.success(posts))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
