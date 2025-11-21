import UIKit

protocol FeedViewModelProtocol {
    var stateChanged: ((FeedState) -> Void)? { get set }
    var updateLikeButton: ((Int, Bool) -> Void)? { get set }
    
    func numberOfItems() -> Int
    func item(at index: Int) -> DisplayPost
    func fetchPosts()
    func toggleLike(for postId: Int, at index: Int)
    func fetchMorePosts()
    func refreshPosts()
    func fetchAvatar(for urlString: String, completion: @escaping (UIImage?) -> Void)
}

final class FeedViewModel {
    
    // MARK: Public Properties
    
    var stateChanged: ((FeedState) -> Void)?
    /// Флаг, указывающий на выполнение загрузки данных
    var isLoading: Bool = false {
        didSet {
            reload?()
        }
    }
    /// Closure для полного обновления таблицы
    var reload: (() -> Void)?
    /// Closure для обновления состояния кнопки лайка в конкретной ячейке
    var updateLikeButton: ((Int, Bool) -> Void)?
    /// Closure для отображения ошибок пользователю
    var showError: ((String) -> Void)?
    
    // MARK: Private Properties
    
    /// Массив постов для отображения в ленте
    private var posts = [DisplayPost]()
    /// Сервис для работы с постами
    private let postService: PostServiceType
    /// Сервис для загрузки изображений
    private let imageService: ImageServiceType
    /// Текущая страница для пагинации
    private var currentPage = 1
    /// Количество постов, загружаемых за один запрос
    private let limit = 10
    /// Флаг наличия дополнительных постов для загрузки
    private var hasMorePosts = true
    /// Флаг выполнения запроса (предотвращение параллельных запрос)
    private var isFetching = false
    /// Флаг выполнения операции обновления (pull-to-refresh)
    private var isRefreshing = false
    
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
    
    func item(at index: Int) -> DisplayPost {
        posts[index]
    }
    
    /// Загружает следующую страницу постов
    func fetchMorePosts() {
        /// Проверка возможности  загрузки дополнительных постов
        guard !isFetching, !isRefreshing, hasMorePosts else { return }
        currentPage += 1
        
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
        /// Проверка  возможности выполнения запроса
        guard !isFetching, hasMorePosts else { return }
        
        fetchPostData(isRefresh: false)
    }
    
    func toggleLike(for postId: Int, at index: Int) {
        /// Обновление локального состояния
        posts[index].isLiked.toggle()
        let newLikeState = posts[index].isLiked
        updateLikeButton?(index, newLikeState)
        /// Отправка изменений на сервер
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
        
        stateChanged?(.loading)
        
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
                if posts.count < self.limit {
                    self.hasMorePosts = false
                }
                
                if isRefresh {
                    self.posts = newPosts
                } else {
                    self.posts.append(contentsOf: newPosts)
                }
                
                DispatchQueue.main.async {
                    if self.posts.isEmpty {
                        self.stateChanged?(.empty)
                    } else {
                        self.stateChanged?(.success)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stateChanged?(.error(error.localizedDescription))
                }
            }
        }
    }
}
