import UIKit

final class ImageService {
    
    // MARK: Private Properties
    
    private let imageLoader: ImageLoader
    private let imageCache: ImageCache
    
    // MARK: Init
    
    init(
        imageLoader: ImageLoader,
        imageCache: ImageCache
    ) {
        self.imageLoader = imageLoader
        self.imageCache = imageCache
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
        
        if let cachedImage = imageCache.getImage(forKey: urlString) {
            completion(.success(cachedImage))
            return
        }
        
        imageLoader.loadImage(from: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                self.imageCache.setImage(image, forKey: urlString)
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
