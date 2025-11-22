import UIKit

protocol ImageCache {
    func getImageData(forKey key: String) -> Data?
    func setImageData(_ data: Data, forKey key: String)
}
