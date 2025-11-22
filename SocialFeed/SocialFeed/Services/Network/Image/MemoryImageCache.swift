import UIKit

final class MemoryImageCache {
    
    // MARK: Private Properties
    
    private let cache = NSCache<NSString, UIImage>()
    private let dataCache = NSCache<NSString, NSData>()
    
    // MARK: Init
    
    init() {}
}

// MARK: - ImageCache

extension MemoryImageCache: ImageCache {
    func getImageData(forKey key: String) -> Data? {
        return dataCache.object(forKey: key as NSString) as Data?
    }
    
    func setImageData(_ data: Data, forKey key: String) {
        dataCache.setObject(data as NSData, forKey: key as NSString)
    }
}
