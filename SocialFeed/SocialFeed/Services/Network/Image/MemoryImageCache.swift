import UIKit

final class MemoryImageCache {
    
    // MARK: Private Properties
    
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: Init
    
    init() {}
}

// MARK: - ImageCache

extension MemoryImageCache: ImageCache {
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
