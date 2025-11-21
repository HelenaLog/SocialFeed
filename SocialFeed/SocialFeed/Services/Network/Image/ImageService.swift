import UIKit

enum ImageServiceError: Error {
    case network(NetworkError)
    case database(StorageError)
}

final class ImageService {
    
    // MARK: Private Properties
    
    private let imageLoader: ImageLoader
    private let imageCache: ImageCache
    private let storageService: StorageType
    private let networkMonitor: NetworkReachability
    
    // MARK: Init
    
    init(
        imageLoader: ImageLoader,
        imageCache: ImageCache,
        storageService: StorageType,
        networkMonitor: NetworkReachability
    ) {
        self.imageLoader = imageLoader
        self.imageCache = imageCache
        self.storageService = storageService
        self.networkMonitor = networkMonitor
    }
}

// MARK: - ImageServiceType

extension ImageService: ImageServiceType {
    func fetchImage(
        from urlString: String,
        completion: @escaping (Result<UIImage, ImageServiceError>) -> Void
    ) {
        if networkMonitor.isConnected {
            loadFromNetwork(urlString: urlString, completion: completion)
        } else {
            loadFromStorage(urlString: urlString, completion: completion)
        }
    }
}

// MARK: - Private Methods

private extension ImageService {
    func loadFromNetwork(
        urlString: String,
        completion: @escaping (Result<UIImage, ImageServiceError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.network(.unableToComplete)))
            return
        }
        
        if let cachedData = imageCache.getImageData(forKey: urlString),
           let image = UIImage(data: cachedData) {
            completion(.success(image))
            return
        }
        
        imageLoader.loadImage(from: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.failure(.network(.invalidDecode)))
                    return
                }
                self.imageCache.setImageData(data, forKey: urlString)
                self.storageService.saveImageData(data, for: urlString)
                completion(.success(image))
                
            case .failure:
                self.loadFromStorage(urlString: urlString, completion: completion)
            }
        }
    }
    
    func loadFromStorage(
        urlString: String,
        completion: @escaping (Result<UIImage, ImageServiceError>) -> Void
    ) {
        storageService.getImageData(for: urlString) { result in
            switch result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(.database(.objectNotFound)))
                }
            case .failure(let error):
                completion(.failure(.database(error)))
            }
        }
    }
}
