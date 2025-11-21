import UIKit

final class ImageService {
    
    // MARK: Private Properties
    
    private let imageLoader: ImageLoader
    private let imageCache: ImageCache
    private let storageService: StorageType
    
    // MARK: Init
    
    init(
        imageLoader: ImageLoader,
        imageCache: ImageCache,
        storageService: StorageType
    ) {
        self.imageLoader = imageLoader
        self.imageCache = imageCache
        self.storageService = storageService
    }
}

// MARK: - ImageServiceType

extension ImageService: ImageServiceType {
    func fetchImage(
        from urlString: String,
        completion: @escaping (Result<UIImage, NetworkError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidData))
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
                    completion(.failure(.invalidDecode))
                    return
                }
                self.imageCache.setImageData(data, forKey: urlString)
                self.storageService.saveImageData(data, for: urlString)
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
