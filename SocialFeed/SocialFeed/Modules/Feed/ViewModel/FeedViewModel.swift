import UIKit

protocol FeedViewModelProtocol {
    var stateChanged: ((FeedState) -> Void)? { get set }
    var updateLikeButton: ((Int, Bool) -> Void)? { get set }
    
    func numberOfItems() -> Int
    func item(at index: Int) -> PostViewItem
    func fetchPosts()
    func toggleLike(for postId: Int, at index: Int)
    func fetchMorePosts()
    func refreshPosts()
    func fetchAvatar(for urlString: String, completion: @escaping (UIImage?) -> Void)
}

final class FeedViewModel {
    
    // MARK: Public Properties
    
    /// Closure для отслеживания изменения состояния
    var stateChanged: ((FeedState) -> Void)?
    /// Closure для обновления состояния кнопки лайка в конкретной ячейке
    var updateLikeButton: ((Int, Bool) -> Void)?
    /// Текущее состояние
    var currentState: FeedState = .loading {
        didSet {
            stateChanged?(currentState)
        }
    }
    
    // MARK: Private Properties
    
    /// Массив постов для отображения в ленте
    private var posts = [PostViewItem]()
    /// Сервис для работы с постами
    private let postService: PostServiceType
    /// Сервис для загрузки изображений
    private let imageService: ImageServiceType
    /// Текущая страница для пагинации
    private var currentPage = PointConstants.startPage
    /// Количество постов, загружаемых за один запрос
    private let limit = PointConstants.limit
    /// Флаг наличия дополнительных постов для загрузки
    private var hasMorePosts = true
    /// Флаг выполнения запроса (предотвращение параллельных запрос)
    private var isFetching = false
    /// Флаг выполнения операции обновления (pull-to-refresh)
    private var isRefreshing = false
    /// Флаг, указывающий, что идет загрузка
    private var isLoading = false
    
    // MARK: Init
    
    init(
        postService: PostServiceType,
        imageService: ImageServiceType
    ) {
        self.postService = postService
        self.imageService = imageService
    }
}

// MARK: - FeedViewModelProtocol

extension FeedViewModel: FeedViewModelProtocol {
    
    func numberOfItems() -> Int {
        posts.count
    }
    
    func item(at index: Int) -> PostViewItem {
        posts[index]
    }
    
    /// Загружает следующую страницу постов
    func fetchMorePosts() {
        /// Проверка возможности  загрузки дополнительных постов
        guard !isFetching, !isRefreshing, !isLoading, hasMorePosts else { return }
        currentPage += PointConstants.pageIncrement
        fetchPostData(isRefresh: false)
    }
    
    /// Обновляет ленту с начала (pull-to-refresh)
    func refreshPosts() {
        /// Проверка, что не выполняется другой запрос
        guard !isFetching else { return }
        
        /// Сброс состояния для начала с первой страницы
        isRefreshing = true
        hasMorePosts = true
        currentPage = 1
        fetchPostData(isRefresh: true)
    }
    
    func fetchPosts() {
        currentState = .loading
        /// Проверка  возможности выполнения запроса
        guard
            !isFetching,
            !isRefreshing,
            hasMorePosts
        else {
            return
        }
        fetchPostData(isRefresh: false)
    }
    
    func toggleLike(for postId: Int, at index: Int) {
        /// Обновление локального состояния
        posts[index].isLiked.toggle()
        let newLikeState = posts[index].isLiked
        updateLikeButton?(index, newLikeState)
        /// Сохранение изменений
        postService.toggleLike(for: postId)
    }
    
    func fetchAvatar(for avatarURL: String, completion: @escaping (UIImage?) -> Void) {
        imageService.fetchImage(from: avatarURL) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure:
                completion(nil)
            }
        }
    }
}

// MARK: - Private Methods

private extension FeedViewModel {
    func fetchPostData(isRefresh: Bool) {
        
        /// Установка флагов загрузки
        isFetching = true
        isLoading = true
        
        /// Вызов сетевого сервиса
        postService.fetchPosts(page: currentPage, limit: limit) { [weak self] result in
            guard let self else { return }
            
            /// Сброс флагов загрузки
            self.isFetching = false
            self.isLoading = false
            
            /// Сброс флага обновления
            if isRefresh { self.isRefreshing = false }
            
            switch result {
            case .success(let newPosts):
                /// Проверка наличия дополнительных постов
                self.hasMorePosts = newPosts.count >= self.limit
                
                if isRefresh {
                    self.posts = newPosts
                } else {
                    self.posts.append(contentsOf: newPosts)
                }
                
                if self.posts.isEmpty {
                    self.currentState = .empty
                } else if isRefresh {
                    self.currentState = .success
                } else {
                    let startIndex = self.posts.count - newPosts.count
                    self.currentState = startIndex == .zero
                    ? .success
                    : .pagination(startIndex: startIndex, count: newPosts.count)
                }
            case .failure(let error):
                if !isRefresh { self.currentPage -= PointConstants.pageDecrement }
                switch error {
                case .network(let networkError):
                    handleNetworkError(networkError)
                case .database(let storageError):
                    handleDatabaseError(storageError)
                }
            }
        }
    }
    
    func handleNetworkError(_ networkError: NetworkError) {
        if !posts.isEmpty {
            currentState = .success
            return
        }
        currentState = .error(networkError.localizedDescription)
    }
    
    func handleDatabaseError(_ storageError: StorageError) {
        switch storageError {
        case .objectNotFound:
            posts = []
            currentState = .empty
        default:
            currentState = posts.isEmpty ? .empty : .error(storageError.localizedDescription)
        }
    }
}

// MARK: - Constants

private extension FeedViewModel {
    
    // MARK: PointConstants
    
    enum PointConstants {
        static let startPage = 1
        static let limit = 5
        static let pageIncrement = 1
        static let pageDecrement = 1
    }
}
