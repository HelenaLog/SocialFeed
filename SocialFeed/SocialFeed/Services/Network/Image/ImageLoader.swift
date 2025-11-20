import UIKit

protocol ImageLoader {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void)
}
